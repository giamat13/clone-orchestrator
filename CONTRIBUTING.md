# Contributing

Thanks for helping. Keep changes small and focused.

- Adding or changing a tool: update `tools.json` with its official URL, license and a pinned version (tag or commit), add `skills/clone-orchestrator/references/<tool>.md`, add a row to the routing table in `SKILL.md` and to `THIRD_PARTY.md`. Verify every URL before adding it; do not invent URLs.
- Keep `SKILL.md` around 150 lines.
- Installers must stay idempotent, ask before each step, never pipe downloaded content into a shell, and change settings only through official `claude` commands after a backup.
- No secrets, tokens or personal paths in any file.
- Repository files are in English. `INSTALL.md` is bilingual (English and Hebrew).

Open an issue first for larger changes.
