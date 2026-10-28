# Installation / התקנה

## English

### Quick start (skill only)

Windows (PowerShell):

```powershell
git clone https://github.com/GIAMAT13/clone-orchestrator
cd clone-orchestrator
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SkillOnly
```

macOS / Linux / Git Bash:

```bash
git clone https://github.com/GIAMAT13/clone-orchestrator
cd clone-orchestrator
./install.sh --skill-only
```

Then open a NEW Claude Code session. The skill triggers on phrases such as "clone this site" and can also be invoked as `/clone-orchestrator`.

### Installing the routed tools

Run the script without `--skill-only` (`-SkillOnly` on PowerShell). It prints the full plan and the exact commands, asks before every step, installs only the official URLs pinned in `tools.json`, skips what is already installed, and ends with a summary: installed / skipped / failed / manual. Use `--dry-run` (`-DryRun`) to see the plan without changing anything.

| Tool | Install | Notes |
|---|---|---|
| Replica Skill | script | copies `replica-*` skills |
| REA | script | `npm install --global rea-agents@6.8.0`, then `rea setup --client claude_code` |
| clone-website | manual | template project; clone tag v0.6.1 into a folder you choose, `npm install`, Node 24+ |
| clone-team | script | copies the skill |
| MCP Web Clone | manual | Python venv, pip, playwright, then `claude mcp add` (requirements are unpinned upstream) |
| UI Reverse Engineering | script | needs `uv` and Python 3.11+; live URLs only |
| Android RE | script | needs Java 17+ and the `jadx` CLI on PATH (download `jadx-1.5.6.zip` from the official skylot/jadx releases, extract, add `bin` to PATH; the winget package ships only the GUI and pulls in Java 11) |

Settings are changed only through `claude mcp` / `claude plugin` commands, after a backup.

### Verify

```
claude mcp list
```

and list `~/.claude/skills`. Then ask Claude: "clone this site: <your URL>".

---

## עברית

### התקנה מהירה (ה-skill בלבד)

ב-Windows (PowerShell):

```powershell
git clone https://github.com/GIAMAT13/clone-orchestrator
cd clone-orchestrator
powershell -ExecutionPolicy Bypass -File .\install.ps1 -SkillOnly
```

ב-macOS / Linux / Git Bash:

```bash
git clone https://github.com/GIAMAT13/clone-orchestrator
cd clone-orchestrator
./install.sh --skill-only
```

אחר כך פותחים session חדש של Claude Code. ה-skill מופעל מביטויים כמו "שכפל את האתר" או "clone this site", ואפשר גם להפעיל אותו עם `/clone-orchestrator`.

### התקנת הכלים שהוא מנתב אליהם

מריצים את הסקריפט בלי `--skill-only` (בפורמט PowerShell: בלי `-SkillOnly`). הסקריפט מדפיס את התוכנית המלאה ואת הפקודות המדויקות, שואל לפני כל שלב, מתקין רק את הכתובות הרשמיות הנעולות ב-`tools.json`, מדלג על מה שכבר מותקן, ומסיים בסיכום: הותקן / דולג / נכשל / ידני. עם `--dry-run` (`-DryRun`) רואים את התוכנית בלי לשנות דבר.

כלים שמסומנים "manual" בטבלה שלמעלה דורשים התקנה ידנית לפי ההערות. שינויים בהגדרות נעשים רק דרך הפקודות `claude mcp` ו-`claude plugin`, אחרי גיבוי.

### בדיקה

```
claude mcp list
```

ורשימת התיקייה `~/.claude/skills`. אחר כך אפשר לבקש מ-Claude: "שכפל את האתר: <הכתובת שלך>".
