# Third-party tools

clone-orchestrator does not bundle these tools. It routes to them and installs them only on request, from the official URLs and pinned versions in `tools.json`. Each keeps its own license.

| Tool | URL | License | Pin |
|---|---|---|---|
| Replica Skill | https://github.com/Jakeschincariol/replica-skill | MIT | commit 77c9436fb3d18c3d58169efb8caf4fe906b0dc51 |
| REA | https://github.com/morluto/rea | MIT | npm rea-agents 6.8.0 |
| clone-website | https://github.com/JCodesMore/ai-website-cloner-template | MIT | tag v0.6.1 |
| clone-team | https://github.com/Varalix-Digitech-Solutions/clone-team | MIT | commit 31e9862290ff120df60549f121636bd77257b322 |
| MCP Web Clone (Perfect Web Clone IDE) | https://github.com/ericshang98/Perfect-Web-Clone-IDE | MIT | commit 01f3affe4ef8a9e25dd1b6b54aee1001bffa6576 |
| UI Reverse Engineering (ui-clone-skills) | https://github.com/voidmatcha/ui-clone-skills | Apache-2.0 | commit c6dacc7a14ca1bc655dbda99c25cbfd5f0baf3e6 |
| Android Reverse Engineering Skill | https://github.com/SimoneAvogadro/android-reverse-engineering-skill | Apache-2.0 | tag v1.7.0 |

Licenses were read from each repository's LICENSE file at the pinned version.

## TODO

- Android: resolved. Marketplace `android-reverse-engineering-skill`, plugin `android-reverse-engineering`; installed by the scripts. `jadx` must be installed separately.
- MCP Web Clone: confirm whether `mcp-web-clone` is a rename or a fork of Perfect-Web-Clone-IDE, and record resolved dependency versions after install.
- clone-website and clone-team: re-verify claims in the original spec (git worktrees, `claude --chrome`) against future releases.
