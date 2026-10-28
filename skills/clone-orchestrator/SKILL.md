---
name: clone-orchestrator
description: Routes a "clone / recreate / reverse-engineer this" request to the right installed tool (website, web app, Android APK, mobile app, screenshot/video, game). Use when the user says "clone this site", "recreate this app", "copy this UI", "reverse engineer this APK", "build something like X", or in Hebrew "שכפל את האתר", "תעתיק את האפליקציה", "תבנה משהו כמו", "הנדסה לאחור".
---

# clone-orchestrator

Routing skill. It does not clone anything itself: it classifies the target, picks the tool, runs the phases and checks the result.

## Step 0 - classify the target

| Target | Signal |
|---|---|
| Website | public URL, mostly static or marketing pages |
| Web app | URL behind login, heavy JS, dashboards, SPA |
| Android APK | `.apk` / `.xapk` file or package name |
| Mobile app, no APK | store link only, no file |
| Screenshot / video only | image or recording, no URL |
| Game | web game, engine build, or native game |

If the class is ambiguous, ask exactly ONE question (for example: "Is this a public URL or a logged-in app?") and wait. Never ask more than one.

## Routing table

| Target | Primary tool | Support | Reference |
|---|---|---|---|
| Website | clone-website (template project) | UI Reverse Engineering for animation/layout fidelity | references/clone-website.md, references/ui-reverse-engineering.md |
| Web app | Replica Skill (recon -> architect -> build) | REA for bundle/runtime analysis, MCP Web Clone for page capture | references/replica.md, references/rea.md, references/mcp-web-clone.md |
| Android APK | Android reverse engineering skill | REA for native/managed code | references/android.md, references/rea.md |
| Mobile app, no APK | Replica Skill (store listing, public screens) | clone-team for parallel work | references/replica.md, references/clone-team.md |
| Screenshot / video only | Replica Skill (recon from images) | none installed handles pixel-exact screenshot-to-code; say so | references/replica.md |
| Game | REA (client analysis) | Replica for design docs | references/rea.md |

UI Reverse Engineering needs a LIVE URL. It does not accept screenshots or video. Never route a screenshot-only target to it.

## Parallelism

- At most 3 subagents at once. Independent slices only (separate pages, separate modules).
- Never run two subagents that write the same file or directory.
- Shared steps (recon, design tokens, data model) run first, alone.
- clone-team and clone-website manage their own workers; do not stack extra subagents on top.

## Quality gate (every phase)

1. Run the project's tests or build.
2. Diff the result against the reference (screenshots, computed styles, or feature matrix).
3. If it fails, fix and repeat. Maximum 3 iterations, then stop and report what is still different. Do not loop forever.

## Failure handling

- A tool is missing: tell the user which one, point to INSTALL.md, offer the next best route from the table. Do not install silently.
- A tool fails twice on the same input: switch to the support tool, or report.
- Login wall, CAPTCHA, or paywall: stop and ask the user. Never try to bypass them.

## Safety rules

- Rebuild with original code, copy, assets and branding. Never copy the target's proprietary code, images, fonts, logos or text.
- Only analyze targets the user owns or is allowed to study. For APKs, only the user's own or permitted apps.
- No scraping behind authentication, no credential use, no rate-limit evasion.
- Do not edit `~/.claude.json` or settings by hand; use `claude mcp add` and `claude plugin` commands, after a backup.
- Do not push, publish or deploy without explicit approval.

## Reports

After each phase print one line: `[phase] <what was done> -> <result> | next: <step>`.
At the end, give a short summary in the user's language: what was built, what differs from the reference, what is left.

## References

Per-tool notes are in `references/<tool>.md`: install state, commands, limits.
