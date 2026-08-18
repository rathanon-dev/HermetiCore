# 🇬🇧 HermetiCore - English Manual

Welcome to **HermetiCore**, the universal, zero-footprint, self-assembling developer environment designed for autonomous AI agents.

---

## 🏛️ Two-Tier Architecture Standard

1. **Tier 1 (AI Control Plane):**
   - Dedicated exclusively to AI Agent tooling (`tools/`, `.mcp/`, `.skills/`).
   - Houses portable runtimes (Git, Node LTS, Python 3.12, 7z, Aria2) and MCP servers.
   - Negative constraint: Never install project dependencies into Tier 1.
2. **Tier 2 (Project Data Plane):**
   - Located at `projects/<project_name>/runtime/`.
   - 100% hermetic isolation for project dependencies (`node_modules/`, `.venv/`, isolated CUDA DLLs).

---

## ⚡ Quick Start

1. Double-click `start.bat` or run:
   ```powershell
   .\start.bat
   ```
2. The self-assembling engine will hydrate all toolchains into memory without touching system registries.
3. Prompt your AI Agent:
   > *"Read and execute the rules in `AI_BOOTSTRAP_PROTOCOL.md` in this directory."*

---

## 📖 Technical Documentation
- 🏛️ [01_ARCHITECTURE.md - Deep Architecture Overview](doc/en/01_ARCHITECTURE.md)
- 🔒 [02_TWO_TIER_RULES.md - Two-Tier Hermetic Separation Standard](doc/en/02_TWO_TIER_RULES.md)
- 🎭 [03_PLAYWRIGHT_MCP_SPEC.md - Playwright Browser MCP Specification](doc/en/03_PLAYWRIGHT_MCP_SPEC.md)

---

## 🙏 Credits & Acknowledgements

Full credits table available at [Main README.md](README.md#-credits--acknowledgements)

---

[🏠 Home](README.md) | [🇹🇭 Thai](README.th.md) | [⬆️ Back to Top](#top)

**Maintainer:** [@rathanon-dev](https://github.com/rathanon-dev) · **License:** [MIT](LICENSE)
