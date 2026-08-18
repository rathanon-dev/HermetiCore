# 🇬🇧 HermetiCore - English Manual

Welcome to **HermetiCore**, the universal, zero-footprint, self-assembling developer environment designed for autonomous AI agents.

---

## 🏛️ Two-Tier Architecture Standard

1. **Tier 1 (AI Control Plane):**
   - Dedicated exclusively to AI Agent tooling (`tools/`, `.mcp/`, `.skills/`).
   - Houses portable runtimes (Git, gh, Node LTS, Python 3.12, 7z, Aria2) and MCP servers.
   - Negative constraint: Never install project dependencies into Tier 1.
2. **Tier 2 (Project Data Plane):**
   - Located at `projects/<project_name>/runtime/`.
   - 100% hermetic isolation for project dependencies (`node_modules/`, `.venv/`, isolated CUDA DLLs).

---

## ⚡ Quick Start
 
### ⚡ Option 1: 1-Click Zero-Git Installer (No Host Git Required)
[![Download auto-install.bat](https://img.shields.io/badge/Download-auto--install.bat%20(No%20Git%20Required)-00F0FF?style=for-the-badge&logo=windows&logoColor=black)](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat)

1. Download [`auto-install.bat`](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat) from the latest GitHub Release.
2. Double-click `auto-install.bat` anywhere to extract and provision the workspace automatically.

### 💻 Option 2: Standard Git Clone
```powershell
git clone https://github.com/rathanon-dev/HermetiCore.git
cd HermetiCore
.\start.bat
```

### 🔑 Credentials & Personal Access Token Setup
See quick guide at [**`config/README.md`**](config/README.md) to configure your GitHub Personal Access Token (`.env`) and Ed25519 SSH Key.

### 🤖 Prompt your AI Agent
> *"Read and execute the rules in `AI_BOOTSTRAP_PROTOCOL.md` in this directory."*

---

## 📖 Technical Documentation
- 🏛️ [01_ARCHITECTURE.md - Deep Architecture Overview](doc/en/01_ARCHITECTURE.md)
- 🔒 [02_TWO_TIER_RULES.md - Two-Tier Hermetic Separation Standard](doc/en/02_TWO_TIER_RULES.md)
- 🎭 [03_PLAYWRIGHT_MCP_SPEC.md - Playwright Browser MCP Specification](doc/en/03_PLAYWRIGHT_MCP_SPEC.md)
- 🔑 [config/README.md - Credentials & Secret Management Hub (.env / SSH / Fine-Grained PAT)](config/README.md)

---

## 🙏 Credits & Acknowledgements

Full credits table available at [Main README.md](README.md#-credits--acknowledgements)

---

[🏠 Home](README.md) | [🇹🇭 Thai](README.th.md) | [⬆️ Back to Top](#top)

**Maintainer:** [@rathanon-dev](https://github.com/rathanon-dev) · **License:** [MIT](LICENSE)
