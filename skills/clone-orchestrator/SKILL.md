---
name: clone-orchestrator
description: General entry point for "clone / recreate / copy / reverse-engineer / build something like X" for ANY kind of target - website, web app, desktop or Electron app, Android APK, mobile app, browser extension, game, binary or firmware, backend/API product, or just a screenshot or video. Classifies the target first and routes to the right installed tool, so website-only tools run only on websites. Use for "clone this", "recreate this app", "copy this UI", "reverse engineer this", "build something like X", or in Hebrew "שכפל", "תעתיק", "תבנה משהו כמו", "הנדסה לאחור".
---

# clone-orchestrator

Routing skill. It does not clone anything itself: it classifies the target, picks the tool, runs the phases and checks the result. It is the entry point for ALL cloning requests, not only websites.

## Step 0 - classify the target

| Class | Signal |
|---|---|
| Website | public URL, mostly static or marketing pages |
| Web app | URL behind login, heavy JS, dashboards, SPA |
| Desktop app | Electron or native installer, `.exe`, `.dmg`, `.app`, `.msi` |
| Android APK | `.apk` / `.xapk` file or package name |
| Mobile app, no file | store link only |
| Browser extension | `.crx`, `.xpi`, extension store link |
| Game | web game, engine build, native game |
| Binary / firmware / library | compiled file, firmware image, `.dll`, `.so`, WASM |
| Backend / SaaS product | "build something like Stripe/Notion", API or data model focus |
| Screenshot / video only | image or recording, no URL or file |
| Anything else | classify to the nearest row above |

If the class is ambiguous, ask exactly ONE question (for example: "Is this a public URL or a logged-in app?") and wait. Never ask more than one.

## Copy level

Two axes, set per request. Never ask about them.

**Design** (visuals and UI): `low`, `medium`, `high`, `full`
- `low`: screen structure. Design is free.
- `medium`: plus layout, spacing and sizes per section, and animations, scroll effects and transitions.
- `high`: plus computed styles (type scale, spacing, radius, shadow) at three widths.
- `full`: plus component states (hover, focus, disabled, empty, error).

**Features:** `none`, `minimal`, `low`, `medium`, `high`, `full`
- `none`: no features. Only the screens, with no logic.
- `minimal`: only the features of the main action, from start to end.
- `low`: all must features.
- `medium`: all must features, plus the should features of the central parts.
- `high`: all must and should features.
- `full`: everything, including could. Run [full-feature-sweep.md](references/full-feature-sweep.md) before building, without asking.
- `+` after a features level, up to five (e.g. `high++`): Claude adds features of its own on top of that level, and decides how many each `+` adds. Each added feature is marked in the report.

Accepted Hebrew words: design נמוך, בינוני, גבוה, מלא; features אין, מינימלי, נמוך, בינוני, גבוה, מלא. A level word with no axis named is read as design.

Defaults: design `full`, features `full`. Colours are never copied at any level. Text, images, font files, logos and code stay the user's at every level: a level changes what is built and measured, never what may be copied.

| Target | Max design level |
|---|---|
| Public website | `full` |
| Web app | `full`, only in the user's own account |
| Desktop app, screenshots or video | `medium`. Animations cannot be verified and are marked in the report |
| APK, mobile app without file, extension, game, binary/firmware, backend/SaaS | `low` |

Features have no technical cap. Anything behind a login is built only in the user's own account. Anything not visible from outside is marked unverified.

Above a cap: clamp to the cap and say so in the report. To change a level mid-job, rerun only the gate of the axis that changed.

## Routing table

| Class | Primary tool | Support | Reference |
|---|---|---|---|
| Website | clone-website (template project) | UI Reverse Engineering, clone-team for large jobs | clone-website, ui-reverse-engineering, clone-team |
| Web app | Replica Skill (recon -> architect -> build) | REA for bundles/runtime, MCP Web Clone for capture (if installed), clone-team | replica, rea, mcp-web-clone, clone-team |
| Desktop app | REA (Electron, native, managed) | Replica for flows and UI rebuild | rea, replica |
| Android APK | Android reverse engineering skill | REA for native/managed code | android, rea |
| Mobile app, no file | Replica Skill (store listing, public screens) | none | replica |
| Browser extension | REA (JS source recovery) | Replica for rebuild plan | rea, replica |
| Game | REA (client analysis) | Replica for design docs | rea, replica |
| Binary / firmware / library | REA | none | rea |
| Backend / SaaS product | Replica Skill (architect, backend) | REA if a web bundle is available | replica, rea |
| Screenshot / video only | Replica Skill (recon from images, design tokens) | none installed does pixel-exact screenshot-to-code; say so | replica |

## Website-only tools

clone-website, clone-team, UI Reverse Engineering and MCP Web Clone are built for websites and web apps. Use them ONLY for the Website and Web app classes. For every other class pick from the other tools. If a request for another class also triggers one of these skills by wording alone (for example "clone this app" for a desktop app), ignore it and follow this table.

UI Reverse Engineering needs a LIVE URL. It does not accept screenshots or video.

## Parallelism

- At most 3 subagents at once. Independent slices only (separate pages, modules or components).
- Never run two subagents that write the same file or directory.
- Shared steps (recon, design tokens, data model) run first, alone.
- clone-team and clone-website manage their own workers; do not stack extra subagents on top.

## Quality gate (every phase)

1. Run the project's tests or build.
2. Diff against the reference with the tools for the active levels. Each design level includes the checks of the levels below it:
   - design `low`: screen inventory against the recon map
   - design `medium`: replica-diff layout diff (colour ignored), visual-debug transition diff
   - design `high`: AE/SSIM and computed-style diff (visual-debug)
   - design `full`: replica-test for component states
   - features: replica-diff parity score for the level's set. `full` also checks against the list from [full-feature-sweep.md](references/full-feature-sweep.md)
3. If it fails, fix and repeat. Maximum 3 iterations, then stop and report what still differs.

## Failure handling

- A tool is missing: tell the user which one, point to INSTALL.md, offer the next best route from the table. Do not install silently.
- A tool fails twice on the same input: switch to the support tool, or report.
- Login wall, CAPTCHA, or paywall: stop and ask the user. Never bypass them.

## Safety rules

- Rebuild with your own code, copy, assets and branding. Never copy proprietary code, images, fonts, logos or text.
- Analyze only targets the user owns or is allowed to study (APKs, binaries and extensions: the user's own or permitted).
- No scraping behind authentication, no credential use, no rate-limit evasion, no license or DRM circumvention.
- Do not edit `~/.claude.json` or settings by hand; use `claude mcp add` and `claude plugin` after a backup.
- Do not push, publish or deploy without explicit approval.

## Reports

After each phase print one line: `[phase] <what was done> -> <result> | next: <step>`. The first phase line also names both levels, e.g. `[design] high | [features] medium`.
At the end, summarize in the user's language: what was built, what differs from the reference, what is left.

## References

Per-tool notes are in `references/<tool>.md`: install state, commands, limits.
