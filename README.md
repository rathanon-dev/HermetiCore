<a id="top"></a>

# 🏛️ MetaBase AI (LabBase-5)
> **สถานีพัฒนาซอฟต์แวร์แบบพกพาสำหรับ AI สากล (Zero-Global-Pollution)**

[![TH](https://img.shields.io/badge/lang-th-green.svg)](README.th.md)
[![EN](https://img.shields.io/badge/lang-en-blue.svg)](README.en.md)
[![Standard: ISO/IEC/IEEE 12207](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2012207-blue.svg)](https://www.iso.org/standard/63711.html)
[![Standard: ISO/IEC/IEEE 42010](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2042010-blue.svg)](https://www.iso.org/standard/74427.html)
[![Twelve-Factor: Compliant](https://img.shields.io/badge/Twelve--Factor-Compliant-success.svg)](https://12factor.net/)
[![Platform: Windows Bare--Metal](https://img.shields.io/badge/Platform-Windows%20Bare--Metal%20(No%20Docker)-orange.svg)]()
[![AI Protocol: Anthropic MCP](https://img.shields.io/badge/Protocol-Anthropic%20MCP%20Ready-purple.svg)]()

> 🌐 **Navigation:** **[🏠 หน้าหลัก (Home)](README.md)** | **[🇹🇭 ภาษาไทย (TH)](README.th.md)** | **[🇬🇧 English (EN)](README.en.md)** | **[🗺️ แผนที่โครงการ (Projects Map)](PROJECTS_MAP.md)**

---

## 📌 ภาพรวมสถาปัตยกรรม (Architecture Overview)

**MetaBase AI (LabBase-5)** คือระบบสถานีพัฒนาซอฟต์แวร์พกพาแบบไร้ขยะ (Zero-Footprint Autonomous Workstation) สำหรับการทำงานร่วมกับ AI Agent ยุคใหม่ (Antigravity, Claude Code, Copilot) โดยทำงานบน Windows แบบ Bare-Metal ไม่ต้องติดตั้งโปรแกรมลงใน System PATH, ไม่ต้องพึ่งพา Docker, และไม่กินแรมเครื่อง

### ✨ คุณสมบัติเด่น (Core Highlights)
1. **⚡ Spore Self-Assembly (งอกระบบใน 1 คลิก):**
   - ตัว Git Repo มีขนาดเล็กจิ๋ว (< 80 KB) เพียงดับเบิ้ลคลิก `start.bat` ระบบจะดาวน์โหลด 7z, Aria2, Git, Node LTS, Python 3.12 และกางโฟลเดอร์ให้พร้อมใช้งานใน 10 วินาที
2. **🏛️ กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Hermetic Separation):**
   - **Tier 1 (AI Control Plane):** คลังเครื่องมือและ MCP ของ AI (7z, Git, Node, Python, Chrome DevTools MCP, ADHD Engine) สะอาดและไม่มีวันพัง
   - **Tier 2 (Project Data Plane):** โปรเจกต์แต่ละตัวมี `runtime/` เฉพาะของตัวเอง แพ็กเกจ `node_modules` และไลบรารีจะไม่ย้อนกลับมากวนระบบส่วนกลาง
3. **🌐 OmniProxy LAN Acceleration:**
   - ตรวจจับ Caching Gateway อัตโนมัติ (`http://192.168.1.10:8080`) ช่วยสตรีมไฟล์ขนาดใหญ่ผ่าน LAN ด้วยความเร็วสูง
4. **📋 กระบวนการต้นน้ำ สู่ ปลายน้ำ (End-to-End Lifecycle):**
   - สกัด Requirement ใน `specs/` $\rightarrow$ ดีไซน์ใน `design/` $\rightarrow$ โค้ดใน `services/` $\rightarrow$ ตรวจรับงานใน `staging/human/` $\rightarrow$ ปล่อยงานใน `repo/`

---

## 🚀 วิธีการติดตั้งและเริ่มต้นใช้งาน (Quick Start)

### 1. ดาวน์โหลดหรือโคลนโปรเจกต์
```powershell
git clone https://github.com/rathanon-dev/MetaBase-AI.git
cd MetaBase-AI
```

### 2. รันระบบในคลิกเดียว
ดับเบิ้ลคลิกไฟล์ **`start.bat`** (หรือรันผ่าน PowerShell):
```powershell
.\start.bat
```
*ระบบจะตรวจสอบเครือข่าย ดาวน์โหลดเครื่องมือ Tier 1 และเปิดหน้าต่าง Terminal พร้อมคำสั่งเริ่มต้นให้ทันที*

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
├── .mcp/                     # 🔌 [AI Tools] Chrome DevTools, Filesystem, SQLite, Git MCP
├── logs/                     # 📋 [Logs] system_log.jsonl & AI_MULTI_AGENT_LOG.md
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
- 🇬🇧 **English (EN):**
  - [System Architecture](doc/en/01_ARCHITECTURE.md)
  - [Two-Tier Hermetic Rules](doc/en/02_TWO_TIER_RULES.md)

---

[🏠 หน้าหลัก (Home)](README.md) | [🇹🇭 ภาษาไทย (TH)](README.th.md) | [🇬🇧 English (EN)](README.en.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)

*ผู้พัฒนาและดูแลโครงการ: [@rathanon-dev](https://github.com/rathanon-dev)*
