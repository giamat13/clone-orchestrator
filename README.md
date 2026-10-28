# clone-orchestrator

A routing skill for Claude Code. Say "clone this", "recreate this app" or "reverse engineer this" about almost any target (website, web app, desktop app, APK, browser extension, game, binary, backend product, screenshot) and it classifies the target, picks the right installed tool, runs the phases, and checks the result against the reference.

It does not clone anything itself. It routes to existing open-source tools and keeps the process safe and bounded. Website-only tools (clone-website, clone-team, UI Reverse Engineering, MCP Web Clone) run only on websites and web apps.

## Routing

| Target | Primary tool |
|---|---|
| Website | clone-website (+ UI Reverse Engineering for animation) |
| Web app | Replica Skill (+ REA, MCP Web Clone, clone-team) |
| Desktop app | REA (+ Replica for flows) |
| Android APK | Android reverse engineering skill (+ REA) |
| Mobile app, no file | Replica Skill |
| Browser extension | REA (+ Replica) |
| Game | REA (+ Replica) |
| Binary / firmware / library | REA |
| Backend / SaaS product | Replica Skill (architect, backend) |
| Screenshot / video only | Replica Skill (no pixel-exact tool included) |

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
