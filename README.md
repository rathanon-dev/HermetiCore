<a id="top"></a>

<div align="center">

# ⚡ METABASE AI (LABBASE-5)
### Autonomous Zero-Footprint Engineering Workstation
**The Universal, Self-Assembling Developer Environment for Autonomous AI Agents**

[![Status](https://img.shields.io/badge/Status-Production%20Ready-00F0FF.svg?style=for-the-badge&logo=rocket)](https://github.com/rathanon-dev/MetaBase-AI)
[![Architecture](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2012207-7928CA.svg?style=for-the-badge&logo=blueprint)](doc/th/01_ARCHITECTURE.md)
[![Separation](https://img.shields.io/badge/Isolation-Two--Tier%20Hermetic-00DF72.svg?style=for-the-badge&logo=shield)](doc/th/02_TWO_TIER_RULES.md)
[![Playwright](https://img.shields.io/badge/Browser-Playwright%20MCP-FF0055.svg?style=for-the-badge&logo=playwright)](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)

---

**[🇹🇭 ภาษาไทย (TH)](README.th.md)** | **[🇬🇧 English (EN)](README.en.md)** | **[🏛️ สถาปัตยกรรมระบบ](doc/th/01_ARCHITECTURE.md)** | **[🔒 กฎเหล็ก 2 ชั้น](doc/th/02_TWO_TIER_RULES.md)** | **[🎭 มาตรฐาน Playwright MCP](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)**

</div>

---

## 🌟 จุดเด่นของระบบ (Core Capabilities)

- ⚡ **1-Click Self-Assembly:** โคลนโปรเจกต์ขนาดเพียง **~95 KB** แล้วดับเบิ้ลคลิก `start.bat` ระบบจะประกอบร่าง Toolchains ทั้งหมดให้ใน 10 วินาที
- 🔒 **Two-Tier Hermetic Separation:** แบ่งแยก **Tier 1 (เครื่องมือ AI / MCP / Skills)** ออกจาก **Tier 2 (ซอร์สโค้ด / Runtime / .venv)** เด็ดขาด 100%
- 🎭 **Mandatory Microsoft Playwright MCP:** ควบคุมเบราว์เซอร์อัตโนมัติด้วย Playwright แยก Context ไร้การรั่วไหลของคุกกี้ และรองรับ Proxy LAN
- 🚀 **LAN Acceleration Aware:** ตรวจจับ **OmniProxy LAN Gateway** (`192.168.1.10:8080`) อัตโนมัติ ดาวน์โหลดและติดตั้งความเร็วระดับ LAN
- 🧠 **Embedded ADHD Divergent Engine:** ฝังระบบระดมความคิดและทดสอบสถาปัตยกรรมแบบคู่ขนาน 5 มิติ

---

## 🚀 เริ่มต้นใช้งานใน 10 วินาที (Quick Start)

### 1. โคลน Repository
```powershell
git clone https://github.com/rathanon-dev/MetaBase-AI.git
cd MetaBase-AI
```

### 2. รันสคริปต์ประกอบร่าง
ดับเบิ้ลคลิกที่ไฟล์ **`start.bat`** (หรือรันผ่าน PowerShell):
```powershell
.\start.bat
```

### 3. สั่งงาน AI Agent
ส่งคำสั่งนี้ให้ AI (Antigravity / Claude / Copilot):
> *"อ่านและปฏิบัติตามกฎใน `AI_BOOTSTRAP_PROTOCOL.md` ในโฟลเดอร์นี้ เพื่อเริ่มพัฒนาโปรเจกต์"*

---

## 📂 แผนผังโครงสร้างโฟลเดอร์ (Directory Taxonomy)

```text
MetaBase-AI/
├── start.bat                 # ⚡ ดับเบิ้ลคลิกเพื่อ Auto-Install และเปิดใช้งานทันที
├── setup.ps1                 # 🧬 สคริปต์งอกระบบและดึง Toolchains/MCP/Skills
├── AI_BOOTSTRAP_PROTOCOL.md  # 📜 กฎควบคุม AI Agent ประจำระบบ
├── README.md                 # 📄 หน้าหลักภาษาไทย (TH)
├── README.en.md              # 📄 หน้าหลักภาษาอังกฤษ (EN)
├── PROJECTS_MAP.md           # 🗺️ ดัชนีสรุปโครงการทั้งหมด
│
├── tools/                    # 🛠️ [Tier 1] คลังรันไทม์พกพา (7z, Aria2, Git, Node, Python)
├── .skills/adhd/             # 🧠 [AI Cognitive] ADHD Divergent Ideation Engine
├── .mcp/                     # 🔌 [AI Tools] Playwright, Neo4j, Redis, SQLite, Git, Shell
├── logs/                     # 📋 [Logs] AI_MULTI_AGENT_LOG.md & ADHD_STRESS_TEST_REPORT.md
├── config/                   # 🔑 [Config] SSH Keys & OmniProxy settings
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
- 🇬🇧 **English (EN):**
  - [System Architecture](doc/en/01_ARCHITECTURE.md)
  - [Two-Tier Hermetic Rules](doc/en/02_TWO_TIER_RULES.md)
  - [Playwright Browser MCP Specification](doc/en/03_PLAYWRIGHT_MCP_SPEC.md)

---

[🏠 หน้าหลัก (Home)](README.md) | [🇹🇭 ภาษาไทย (TH)](README.th.md) | [🇬🇧 English (EN)](README.en.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)

*ผู้พัฒนาและดูแลโครงการ: [@rathanon-dev](https://github.com/rathanon-dev)*
