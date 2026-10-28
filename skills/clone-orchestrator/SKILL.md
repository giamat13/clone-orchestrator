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
2. Diff the result against the reference (screenshots, computed styles, or feature matrix).
3. If it fails, fix and repeat. Maximum 3 iterations, then stop and report what still differs.

## Failure handling

- A tool is missing: tell the user which one, point to INSTALL.md, offer the next best route from the table. Do not install silently.
- A tool fails twice on the same input: switch to the support tool, or report.
- Login wall, CAPTCHA, or paywall: stop and ask the user. Never bypass them.

## Safety rules

- Rebuild with original code, copy, assets and branding. Never copy proprietary code, images, fonts, logos or text.
- Analyze only targets the user owns or is allowed to study (APKs, binaries and extensions: the user's own or permitted).
- No scraping behind authentication, no credential use, no rate-limit evasion, no license or DRM circumvention.
- Do not edit `~/.claude.json` or settings by hand; use `claude mcp add` and `claude plugin` after a backup.
- Do not push, publish or deploy without explicit approval.

## Reports

After each phase print one line: `[phase] <what was done> -> <result> | next: <step>`.
At the end, summarize in the user's language: what was built, what differs from the reference, what is left.

## References

Per-tool notes are in `references/<tool>.md`: install state, commands, limits.
