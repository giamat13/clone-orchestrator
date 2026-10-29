# Full features sweep

Runs when the features level is `full`. Start it without asking. Its web passes use the deep-research skill (see [deep-research.md](deep-research.md)).

## Input

- Target: product name or URL. If the target is not named, ask for it, once.
- The user's own account, only when the user gives access. Never bypass a login, CAPTCHA or paywall.
- The feature matrix from replica-recon, if one exists.

## Passes

Run four passes, then the final sweep. Every pass adds to one shared list. Run every pass, even when an earlier one found nothing new.

1. **Inventory.** Official docs, help center, product pages, store listing, and the settings and menus of the user's own account.
2. **Community.** Forums, Reddit, Hacker News, reviews, tutorials, release notes of older versions.
3. **Hidden.** Keyboard shortcuts, hidden settings, debug or developer menus, easter eggs, undocumented behaviour. Public sources and the user's own account only. No binary reverse engineering in this procedure.
4. **Cross-check.** Confirm every item from passes 1 to 3 with a second source, or with direct observation in the user's account. Keep unconfirmed items in the list, marked unverified.

**Final sweep.** Run the final-sweep queries below. Add any new item and verify it the same way. The sweep does not start another round.

## Queries

- Inventory: `[target] features`, `[target] help center`, `[target] changelog`, `[target] plans features`
- Community: `[target] reddit features`, `[target] hidden features`, `[target] tips and tricks`, `[target] review`
- Hidden: `[target] easter egg`, `[target] keyboard shortcuts`, `[target] hidden settings`, `[target] undocumented feature`, `[target] secret menu`
- Cross-check: `[target] [feature name]`, `[feature name] [target] how to`
- Final sweep: `[target] all features list`, `[target] features [year]`, `[target] what's new`, `[target] missed features`

## Rules

- No source, no entry. Every item carries a URL or a direct observation.
- Never fabricate. A feature that cannot be confirmed is kept as unverified, not dropped.
- Priority is `must`, `should` or `could`. Easter eggs and hidden features are `could` unless the user says otherwise.
- Merge duplicates by name and keep every source.
- Stop after the final sweep.

## Output

Write the list to `features-<target>.md` in the working project:

| Feature | Category | Priority | Found in pass | Sources | Status |
|---|---|---|---|---|---|

`Status` is `verified` or `unverified`. Then report the passes run, the new items per pass, and the number of unverified items.
