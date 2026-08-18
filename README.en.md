<a id="top"></a>

# 🏛️ MetaBase AI (LabBase-5) - English Manual
> **The Zero-Footprint, AI-Augmented Autonomous Engineering Workstation**

[![TH](https://img.shields.io/badge/lang-th-green.svg)](README.th.md)
[![EN](https://img.shields.io/badge/lang-en-blue.svg)](README.en.md)
[![Standard: ISO/IEC/IEEE 12207](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2012207-blue.svg)](https://www.iso.org/standard/63711.html)
[![Standard: ISO/IEC/IEEE 42010](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2042010-blue.svg)](https://www.iso.org/standard/74427.html)
[![Twelve-Factor: Compliant](https://img.shields.io/badge/Twelve--Factor-Compliant-success.svg)](https://12factor.net/)
[![Platform: Windows Bare--Metal](https://img.shields.io/badge/Platform-Windows%20Bare--Metal%20(No%20Docker)-orange.svg)]()
[![AI Protocol: Anthropic MCP](https://img.shields.io/badge/Protocol-Anthropic%20MCP%20Ready-purple.svg)]()

> 🌐 **Navigation:** **[🏠 Home (Thai)](README.md)** | **[🇹🇭 ภาษาไทย (TH)](README.th.md)** | **[🇬🇧 English (EN)](README.en.md)** | **[🗺️ Projects Map](PROJECTS_MAP.md)**

---

## 📌 Executive Overview

**MetaBase AI (LabBase-5)** is a lightweight, zero-footprint developer environment designed specifically for pairing with autonomous AI coding agents (Antigravity, Claude Code, GitHub Copilot). It operates natively on Windows without requiring global registry modifications, admin privileges, or heavy Docker virtualization overhead.

### 🌟 Core Architectural Pillars
1. **⚡ Spore Self-Assembly (1-Click Boot):**
   - The upstream Git repository is ultra-minimal (< 80 KB). Double-clicking `start.bat` provisions 7-Zip, Aria2, MinGit, Node.js LTS, and Python 3.12 within 10–15 seconds via LAN/Direct mirrors.
2. **🏛️ Two-Tier Hermetic Separation Standard:**
   - **Tier 1 (AI Control Plane):** Houses root tools (7z, Git, Node, Python, Chrome DevTools MCP, ADHD Engine) exclusively for AI orchestration. Never polluted with project packages.
   - **Tier 2 (Project Data Plane):** Each project operates its own self-contained `runtime/` environment. Dependencies (`node_modules`, `.venv`, CUDA DLLs) remain 100% isolated.
3. **🌐 OmniProxy LAN Acceleration:**
   - Automatically detects and hooks into a local caching gateway (`http://192.168.1.10:8080`) to stream large packages (PyTorch wheels, Node archives) at internal LAN speeds.
4. **📋 End-to-End Lifecycle Pipeline (ISO/IEC/IEEE 12207):**
   - Requirements in `specs/` $\rightarrow$ Design Tokens in `design/` $\rightarrow$ Polyglot Code in `services/` $\rightarrow$ Human Gate in `staging/human/` $\rightarrow$ Production in `repo/`.

---

## 🚀 Quick Start Guide

### 1. Clone the Repository
```powershell
git clone https://github.com/rathanon-dev/MetaBase-AI.git
cd MetaBase-AI
```

### 2. One-Click Bootstrap
Double-click **`start.bat`** (or launch from PowerShell):
```powershell
.\start.bat
```
*The script verifies network topology, downloads Tier 1 tools into `tools/`, and opens an ephemeral terminal session with injected paths.*

### 3. Handoff to AI Agent
Send this directive to your AI agent (Antigravity / Claude / Copilot):
> *"Read and adhere to the rules defined in `AI_BOOTSTRAP_PROTOCOL.md` in this directory to begin development."*

---

## 📂 Directory Taxonomy

```text
MetaBase-AI/
├── start.bat                 # ⚡ 1-Click Bootstrap Launcher
├── setup.ps1                 # 🧬 Master Self-Assembling Engine
├── AI_BOOTSTRAP_PROTOCOL.md  # 📜 AI Agent Directives & Two-Tier Rules
├── README.md                 # 📄 Primary Documentation (Thai)
├── README.en.md              # 📄 English Documentation
├── PROJECTS_MAP.md           # 🗺️ Master Project Catalog
│
├── tools/                    # 🛠️ [Tier 1] Portable Toolchains (7z, Aria2, Git, Node, Python)
├── .skills/adhd/             # 🧠 [AI Cognitive] ADHD Divergent Ideation Engine
├── .mcp/                     # 🔌 [AI Tools] Chrome DevTools, Filesystem, SQLite, Git MCP
├── logs/                     # 📋 [Logs] system_log.jsonl & AI_MULTI_AGENT_LOG.md
├── config/                   # 🔑 [Config] SSH Keys & OmniProxy settings
├── doc/                      # 📚 [Docs] In-depth technical specifications
│
└── projects/                 # 📦 [Tier 2] Isolated Project Pods
    └── _template_fullstack/  # 🧬 Full-Stack Monorepo Template
```

---

## 📖 Deep Documentation
- [System Architecture](doc/en/01_ARCHITECTURE.md)
- [Two-Tier Hermetic Rules](doc/en/02_TWO_TIER_RULES.md)

---

## 📜 Standards & Compliance
- **ISO/IEC/IEEE 12207:2017**: Systems and software engineering — Software life cycle processes
- **ISO/IEC/IEEE 42010:2022**: Software, systems and enterprise — Architecture description
- **The Twelve-Factor App**: Factor II (Dependency Isolation) & Factor X (Dev/Prod Parity)
- **Anthropic Model Context Protocol (MCP)**: Universal AI Tool Interoperability

---

[🏠 Home (Thai)](README.md) | [🇹🇭 ภาษาไทย (TH)](README.th.md) | [🇬🇧 English (EN)](README.en.md) | [⬆️ Back to Top](#top)

*Maintained by [@rathanon-dev](https://github.com/rathanon-dev)*
