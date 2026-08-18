<a id="top"></a>

<div align="center">

# ⚡ HermetiCore
### Autonomous Zero-Footprint Engineering Workstation
**The Universal, Self-Assembling Developer Environment for Autonomous AI Agents**

[![Status](https://img.shields.io/badge/Status-Production%20Ready-00F0FF.svg?style=for-the-badge&logo=rocket)](https://github.com/rathanon-dev/HermetiCore)
[![Architecture](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2012207-7928CA.svg?style=for-the-badge&logo=blueprint)](doc/th/01_ARCHITECTURE.md)
[![Separation](https://img.shields.io/badge/Isolation-Two--Tier%20Hermetic-00DF72.svg?style=for-the-badge&logo=shield)](doc/th/02_TWO_TIER_RULES.md)
[![Playwright](https://img.shields.io/badge/Browser-Playwright%20MCP-FF0055.svg?style=for-the-badge&logo=playwright)](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)

---

**[🇹🇭 ภาษาไทย (TH)](README.th.md)** | **[🇬🇧 English (EN)](README.en.md)** | **[🔑 ตั้งค่าความลับ (.env / SSH / Token)](config/README.md)** | **[🏛️ สถาปัตยกรรม](doc/th/01_ARCHITECTURE.md)** | **[🔒 กฎเหล็ก 2 ชั้น](doc/th/02_TWO_TIER_RULES.md)** | **[🎭 Playwright MCP](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)**

</div>

---

## 🌟 จุดเด่นของระบบ (Core Capabilities)

- ⚡ **1-Click Self-Assembly:** โคลนโปรเจกต์ขนาดเพียง **~95 KB** แล้วดับเบิ้ลคลิก `start.bat` ระบบจะประกอบร่าง Toolchains ทั้งหมดให้ใน 10 วินาที
- 🔒 **Two-Tier Hermetic Separation:** แบ่งแยก **Tier 1 (เครื่องมือ AI / MCP / Skills)** ออกจาก **Tier 2 (ซอร์สโค้ด / Runtime / .venv)** เด็ดขาด 100%
- 🔑 **Zero-Leak Credentials Hub:** ระบบจัดการความลับแยกขาดประจำเครื่อง (`config/.env` และ `id_ed25519`) ปลอดภัยจากการ Push สู่สาธารณะ 100%
- 🎭 **Mandatory Microsoft Playwright MCP:** ควบคุมเบราว์เซอร์อัตโนมัติด้วย Playwright แยก Context ไร้การรั่วไหลของคุกกี้ และรองรับ Proxy LAN
- 🚀 **LAN Acceleration Aware:** ตรวจจับ **OmniProxy LAN Gateway** (`192.168.1.10:8080`) อัตโนมัติ ดาวน์โหลดและติดตั้งความเร็วระดับ LAN
- 🧠 **Embedded ADHD Divergent Engine:** ฝังระบบระดมความคิดและทดสอบสถาปัตยกรรมแบบคู่ขนาน 5 มิติ

---

## 🚀 เริ่มต้นใช้งานใน 10 วินาที (Quick Start)

เลือกระหว่างวิธี **1-Click (ไม่ต้องมี Git)** หรือวิธี **Git Clone มาตรฐาน**:

### ⚡ วิธีที่ 1: 1-Click Zero-Git Installer (แนะนำสำหรับเครื่องใหม่ / ติดตั้งทันที)
[![Download auto-install.bat](https://img.shields.io/badge/Download-auto--install.bat%20(No%20Git%20Required)-00F0FF?style=for-the-badge&logo=windows&logoColor=black)](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat)

1. ดาวน์โหลดไฟล์ [`auto-install.bat`](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat) จาก GitHub Release
2. วางไฟล์ไว้ในโฟลเดอร์ที่ต้องการ (เช่น Desktop หรือ `D:\`) แล้วดับเบิ้ลคลิกเพื่อรัน
3. ระบบจะแตกไฟล์และสร้างสภาพแวดล้อม `HermetiCore` ให้พร้อมใช้งานทันทีโดยไม่ต้องลง Git!

*(หรือรันคำสั่งบรรทัดเดียวผ่าน PowerShell)*:
```powershell
irm https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat -OutFile auto-install.bat; .\auto-install.bat
```

---

### 💻 วิธีที่ 2: Standard Git Clone (สำหรับเครื่องที่มี Git อยู่แล้ว)
```powershell
git clone https://github.com/rathanon-dev/HermetiCore.git
cd HermetiCore
.\start.bat
```

### 🔑 การตั้งค่ากุญแจและความลับ (Credentials & Access Token)
> ดูวิธีใส่ GitHub Token และ SSH Key ฉบับย่อได้ที่: [**`config/README.md (คู่มือจัดการความลับ)`**](config/README.md)
> * คัดลอก `config/env.example` เป็น `config/.env` แล้วใส่ `GITHUB_PERSONAL_ACCESS_TOKEN`

### 🤖 สั่งงาน AI Agent
ส่งคำสั่งนี้ให้ AI (Antigravity / Claude / Copilot):
> *"อ่านและปฏิบัติตามกฎใน `AI_BOOTSTRAP_PROTOCOL.md` ในโฟลเดอร์นี้ เพื่อเริ่มพัฒนาโปรเจกต์"*


---

## 📂 แผนผังโครงสร้างโฟลเดอร์ (Directory Taxonomy)

```text
HermetiCore/
├── start.bat                 # ⚡ ดับเบิ้ลคลิกเพื่อ Auto-Install และเปิดใช้งานทันที
├── setup.ps1                 # 🧬 สคริปต์งอกระบบและดึง Toolchains/MCP/Skills
├── AI_BOOTSTRAP_PROTOCOL.md  # 📜 กฎควบคุม AI Agent ประจำระบบ
├── README.md                 # 📄 หน้าหลักภาษาไทย (TH)
├── README.en.md              # 📄 หน้าหลักภาษาอังกฤษ (EN)
├── PROJECTS_MAP.md           # 🗺️ ดัชนีสรุปโครงการทั้งหมด
│
├── tools/                    # 🛠️ [Tier 1] คลังรันไทม์พกพา (7z, Aria2, Git, gh, Node, Python)
├── .skills/adhd/             # 🧠 [AI Cognitive] ADHD Divergent Ideation Engine
├── .mcp/                     # 🔌 [AI Tools] Playwright, Neo4j, Redis, SQLite, Git, Shell
├── logs/                     # 📋 [Logs] AI_MULTI_AGENT_LOG.md & ADHD_STRESS_TEST_REPORT.md
├── config/                   # 🔑 [Config] ศูนย์รวมการตั้งค่า & ความลับ (Zero-Leak)
│   ├── env.example           # 📄 แม่แบบ Environment & Token (ก๊อปปี้ไปเป็น .env)
│   └── README.md             # 📖 คู่มือตั้งค่า SSH Key & Fine-Grained PAT
├── doc/                      # 📚 [Docs] คู่มือฉบับเต็มภาษาไทย (doc/th) และอังกฤษ (doc/en)
│
└── projects/                 # 📦 [Tier 2] พื้นที่พัฒนาโปรเจกต์ (แยก Runtime อิสระ)
    └── _template_fullstack/  # 🧬 แม่แบบ Full-Stack (specs, design, services, runtime, staging, repo)
```

---

## 📖 เอกสารเพิ่มเติม (Documentation Hub)

- 🇹🇭 **ภาษาไทย (Thai):**
  - [สถาปัตยกรรมระบบ (Architecture)](doc/th/01_ARCHITECTURE.md)
  - [กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Rules)](doc/th/02_TWO_TIER_RULES.md)
  - [มาตรฐาน Playwright Browser MCP (Autify Benchmark)](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)
  - [สถาปัตยกรรมเครื่องมือและข้อกำหนดสิทธิ์ (Tooling Pipeline & Licenses)](doc/th/04_TOOLING_AND_LICENSES.md)
  - [🔑 คู่มือจัดการความลับ & Credentials (.env / SSH / Fine-Grained PAT)](config/README.md)
- 🇬🇧 **English (EN):**
  - [System Architecture](doc/en/01_ARCHITECTURE.md)
  - [Two-Tier Hermetic Rules](doc/en/02_TWO_TIER_RULES.md)
  - [Playwright Browser MCP Specification](doc/en/03_PLAYWRIGHT_MCP_SPEC.md)
  - [🔑 Credentials & Secret Management Hub](config/README.md)

---

## 🙏 เครดิตและเครื่องมือที่อ้างอิง (Credits & Acknowledgements)

| เครื่องมือ / มาตรฐาน | ผู้สร้าง | บทบาทในโปรเจกต์ |
|---|---|---|
| [ADHD Divergent Ideation Skill](https://github.com/UditAkhourii/adhd) | Udit Akhourii | ระบบระดมความคิดแบบคู่ขนาน 5 มิติ (`.skills/adhd/`) |
| [Playwright MCP Server](https://github.com/executeautomation/playwright-mcp) | ExecuteAutomation | Browser Engine สำหรับ AI (`@executeautomation/playwright-mcp-server`) |
| [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) | Anthropic | Open Standard สำหรับเชื่อม AI Agent กับ Tools & Services |
| [ISO/IEC/IEEE 12207:2017](https://www.iso.org/standard/63712.html) | ISO / IEC / IEEE | มาตรฐานวงจรชีวิตซอฟต์แวร์ *(Self-Declared Conformity per ISO/IEC 17050-1)* |
| [PEP 621](https://peps.python.org/pep-0621/) | Python Software Foundation | มาตรฐาน `pyproject.toml` สำหรับ Python Project Metadata |
| [Sigstore / Rekor](https://www.sigstore.dev/) | Linux Foundation | ระบบ Supply Chain Security & Commit Attestation |
| [Autify Engineering Blog](https://autify.com/blog/playwright-vs-puppeteer) | Autify | แหล่งอ้างอิงเปรียบเทียบ Playwright vs Puppeteer |
| [7-Zip (CommandLine)](https://www.7-zip.org/) | Igor Pavlov | Core Unzipper ประจำระบบ (ดึงผ่าน NuGet) |
| [Aria2](https://github.com/aria2/aria2) | Tatsuhiro Tsujikawa | Multi-connection Downloader ประจำระบบ |
| [MinGit & GitHub CLI](https://github.com/git-for-windows/git) | Git for Windows | Version Control แบบพกพาไร้การติดตั้ง |
| [Node.js](https://nodejs.org/) | OpenJS Foundation | Web & MCP Engine Runtime |
| [Python 3.12](https://www.python.org/) | Python Software Foundation | AI & Data Science Runtime (ดึงผ่าน NuGet) |
| [NVIDIA CUDA & cuDNN](https://developer.nvidia.com/) | NVIDIA Corporation | Zero-Footprint GPU Acceleration DLLs |

> **หมายเหตุทางกฎหมาย:** โปรเจกต์นี้เผยแพร่ภายใต้ [MIT License](LICENSE) แบบ Open Source "AS IS" ไม่มีการรับประกันเชิงพาณิชย์ใดๆ
> การอ้างอิง ISO/IEC/IEEE 12207:2017 เป็น **Self-Assessed Alignment** ตามมาตรฐาน ISO/IEC 17050-1 ไม่ใช่การรับรองโดยองค์กร ISO โดยตรง

---

[🏠 หน้าหลัก (Home)](README.md) | [🇹🇭 ภาษาไทย (TH)](README.th.md) | [🇬🇧 English (EN)](README.en.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](LICENSE)
