#!/usr/bin/env bash
# Installs the clone-orchestrator skill and, optionally, the tools it routes to.
# Prints the plan, asks before each step, installs only pinned official URLs,
# skips what is installed, is safe to re-run, and never pipes downloads to a shell.
# Usage: ./install.sh [--skill-only] [--dry-run] [--yes]
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_HOME}/skills"
SRC_DIR="${CLAUDE_HOME}/clone-orchestrator-src"
BACKUP_DIR="${CLAUDE_HOME}/clone-orchestrator-backup/$(date +%Y%m%d-%H%M%S)"

SKILL_ONLY=0; DRY=0; YES=0
for a in "$@"; do
  case "$a" in
    --skill-only) SKILL_ONLY=1 ;;
    --dry-run) DRY=1 ;;
    --yes) YES=1 ;;
    *) echo "unknown option: $a"; exit 2 ;;
  esac
done

INSTALLED=(); SKIPPED=(); FAILED=(); MANUAL=()

confirm() {
  echo "  > $1"
  [ "$DRY" = 1 ] && return 1
  [ "$YES" = 1 ] && return 0
  read -r -p "    Run this? [y/N] " ans
  [[ "$ans" =~ ^([yY]|yes)$ ]]
}

backup_settings() {
  [ -d "$BACKUP_DIR" ] && return
  mkdir -p "$BACKUP_DIR"
  [ -f "${HOME}/.claude.json" ] && cp "${HOME}/.claude.json" "$BACKUP_DIR/"
  [ -f "${CLAUDE_HOME}/settings.json" ] && cp "${CLAUDE_HOME}/settings.json" "$BACKUP_DIR/"
  echo "  Backup written to $BACKUP_DIR"
}

# Reads a field of one tool from tools.json using python (no network, no eval of downloads).
PY=python3
command -v python3 >/dev/null 2>&1 || PY=python

tool_field() {
  "$PY" - "$ROOT/tools.json" "$1" "$2" <<'EOF'
import json, sys
d = json.load(open(sys.argv[1]))
v = next(x for x in d["tools"] if x["id"] == sys.argv[2])
for k in sys.argv[3].split("."):
    v = v.get(k, "") if isinstance(v, dict) else ""
print(v)
EOF
}

clone_pinned() {
  local id="$1" url ref dest
  url="$(tool_field "$id" url)"
  ref="$(tool_field "$id" pin.commit)"; [ -z "$ref" ] && ref="$(tool_field "$id" pin.value)"
  dest="${SRC_DIR}/${id}"
  [ -d "$dest" ] || git -c core.longpaths=true clone "$url" "$dest" || return 1
  git -C "$dest" -c advice.detachedHead=false checkout "$ref" || return 1
  echo "$dest"
}

install_skill() {
  local from="$ROOT/skills/clone-orchestrator" to="$SKILLS_DIR/clone-orchestrator"
  echo; echo "[clone-orchestrator] copy $from -> $to"
  if [ -f "$to/SKILL.md" ] && cmp -s "$from/SKILL.md" "$to/SKILL.md"; then
    SKIPPED+=("clone-orchestrator (already installed, identical)"); return
  fi
  if confirm "cp -r $from $to"; then
    if [ -d "$to" ]; then backup_settings; mv "$to" "$to.bak-$(date +%Y%m%d%H%M%S)"; fi
    mkdir -p "$SKILLS_DIR" && cp -r "$from" "$to" && INSTALLED+=("clone-orchestrator") || FAILED+=("clone-orchestrator")
  else
    SKIPPED+=("clone-orchestrator (declined or dry run)")
  fi
}

install_tool() {
  local id="$1" d
  echo; echo "[$id] $(tool_field "$id" name)  $(tool_field "$id" url)  ($(tool_field "$id" license), pin $(tool_field "$id" pin.value))"
  case "$id" in
    replica)
      [ -d "$SKILLS_DIR/replica-recon" ] && { SKIPPED+=("replica (already installed)"); return; }
      if confirm "git clone + checkout pin, copy replica-* folders into $SKILLS_DIR"; then
        d="$(clone_pinned replica)" || { FAILED+=("replica"); return; }
        for s in "$d"/replica-*/; do cp -r "$s" "$SKILLS_DIR/$(basename "$s")"; done
        INSTALLED+=("replica")
      else SKIPPED+=("replica (declined)"); fi ;;
    clone-team)
      [ -d "$SKILLS_DIR/clone-team" ] && { SKIPPED+=("clone-team (already installed)"); return; }
      if confirm "git clone + checkout pin, copy skills/clone-team into $SKILLS_DIR"; then
        d="$(clone_pinned clone-team)" || { FAILED+=("clone-team"); return; }
        cp -r "$d/skills/clone-team" "$SKILLS_DIR/clone-team" && INSTALLED+=("clone-team") || FAILED+=("clone-team")
      else SKIPPED+=("clone-team (declined)"); fi ;;
    rea)
      command -v npm >/dev/null || { FAILED+=("rea: npm not found"); return; }
      if npm ls -g rea-agents --depth=0 2>/dev/null | grep -q 'rea-agents@6\.8\.0'; then SKIPPED+=("rea (6.8.0 already installed)"); return; fi
      echo "  Note: this upgrades an older installed rea-agents to the pinned version."
      if confirm "npm install --global rea-agents@6.8.0"; then
        npm install --global rea-agents@6.8.0 && INSTALLED+=("rea (then run: rea setup --client claude_code, rea doctor)") || FAILED+=("rea")
      else SKIPPED+=("rea (declined)"); fi ;;
    ui-reverse-engineering)
      command -v uv >/dev/null || { FAILED+=("ui-reverse-engineering: uv not found"); return; }
      if confirm "git clone + checkout pin; claude plugin marketplace add <clone>; claude plugin install ui-clone-skills@voidmatcha"; then
        backup_settings
        d="$(clone_pinned ui-reverse-engineering)" || { FAILED+=("ui-reverse-engineering"); return; }
        claude plugin marketplace add "$d" && claude plugin install ui-clone-skills@voidmatcha \
          && INSTALLED+=("ui-reverse-engineering") || FAILED+=("ui-reverse-engineering")
      else SKIPPED+=("ui-reverse-engineering (declined)"); fi ;;
    *)
      MANUAL+=("$id: $(tool_field "$id" installNote)") ;;
  esac
}

echo "clone-orchestrator installer"
echo "Skill target: $SKILLS_DIR"
[ "$DRY" = 1 ] && echo "DRY RUN: nothing will be changed."

install_skill
if [ "$SKILL_ONLY" = 0 ]; then
  for id in replica rea clone-website clone-team mcp-web-clone ui-reverse-engineering android; do
    install_tool "$id"
  done
fi

echo; echo "=== Summary ==="
echo "Installed: ${INSTALLED[*]:-}"
echo "Skipped:   ${SKIPPED[*]:-}"
echo "Failed:    ${FAILED[*]:-}"
echo "Manual:    ${MANUAL[*]:-}"
echo; echo "Open a NEW Claude Code session so the skills load."
[ "${#FAILED[@]}" -gt 0 ] && exit 1
exit 0
