# clone-orchestrator

A routing skill for Claude Code. Say "clone this site", "recreate this app" or "reverse engineer this APK" and it classifies the target, picks the right installed tool, runs the phases, and checks the result against the reference.

It does not clone anything itself. It routes to existing open-source tools and keeps the process safe and bounded.

## Routing

| Target | Primary tool |
|---|---|
| Website | clone-website (+ UI Reverse Engineering for animation) |
| Web app | Replica Skill (+ REA, MCP Web Clone) |
| Android APK | Android reverse engineering skill (+ REA) |
| Mobile app, no APK | Replica Skill (+ clone-team) |
| Screenshot / video only | Replica Skill (no pixel-exact tool included) |
| Game | REA |

Rules built into the skill: at most 3 parallel subagents, a test-and-diff quality gate with at most 3 iterations, no bypassing logins or CAPTCHAs, original code and assets only.

## Install

See [INSTALL.md](INSTALL.md) (English and Hebrew). Short version:

```bash
./install.sh --skill-only        # macOS / Linux / Git Bash
.\install.ps1 -SkillOnly         # Windows PowerShell
```

## Layout

- `skills/clone-orchestrator/` - the skill and per-tool references
- `tools.json` - official URLs, licenses and pinned versions
- `install.sh`, `install.ps1` - confirmation-driven, idempotent installers
- `THIRD_PARTY.md` - licenses of the routed tools

## Responsible use

Use it only on targets you own or are allowed to study. Do not copy proprietary code, assets, fonts, logos or text. See the safety rules in `SKILL.md`.

## License

MIT. See [LICENSE](LICENSE). Third-party tools keep their own licenses, listed in [THIRD_PARTY.md](THIRD_PARTY.md).
