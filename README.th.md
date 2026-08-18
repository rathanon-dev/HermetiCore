# 🇹🇭 HermetiCore - คู่มือฉบับภาษาไทย

ยินดีต้อนรับสู่ **HermetiCore** สภาพแวดล้อมพัฒนาระบบ AI แบบ Bare-Metal พกพา ไม่ทิ้งร่องรอย และกักขังการทำงาน 100%

---

## 🏛️ สถาปัตยกรรมแบบ 2 ชั้น (Two-Tier Architecture)

1. **Tier 1 (AI Control Plane):**
   - โฟลเดอร์ `tools/`, `.mcp/`, `.skills/`
   - สำหรับให้ AI Agent ใช้สำรวจ Draft และสั่งงาน MCP Servers
   - ห้ามติดตั้งแพ็กเกจของโปรเจกต์ลงในชั้นนี้เด็ดขาด
2. **Tier 2 (Project Data Plane):**
   - โฟลเดอร์ `projects/<name>/runtime/`
   - กักขัง Dependencies ทั้งหมด (`node_modules`, `.venv`, CUDA DLLs) ไว้ภายในโปรเจกต์ 100%

---

## ⚡ วิธีการใช้งาน (Quick Start)

### ⚡ วิธีที่ 1: 1-Click Zero-Git (ไม่ต้องมี Git ในเครื่อง)
[![Download auto-install.bat](https://img.shields.io/badge/Download-auto--install.bat%20(No%20Git%20Required)-00F0FF?style=for-the-badge&logo=windows&logoColor=black)](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat)

1. ดาวน์โหลด [`auto-install.bat`](https://github.com/rathanon-dev/HermetiCore/releases/latest/download/auto-install.bat) แล้วดับเบิ้ลคลิกเพื่อรัน
2. ระบบจะดาวน์โหลดและแตกไฟล์ Toolchain ทั้งหมดแบบไร้การติดตั้ง

### 💻 วิธีที่ 2: Standard Git Clone
```powershell
git clone https://github.com/rathanon-dev/HermetiCore.git
cd HermetiCore
.\start.bat
```

### 🤖 สั่งงาน AI Agent
ส่ง Prompt ให้ AI:
> *"อ่านและปฏิบัติตามกฎใน `AI_BOOTSTRAP_PROTOCOL.md` ในโฟลเดอร์นี้"*

---

## 📖 เอกสารเชิงลึก
- 🏛️ [01_ARCHITECTURE.md - ภาพรวมสถาปัตยกรรมระบบ](doc/th/01_ARCHITECTURE.md)
- 🔒 [02_TWO_TIER_RULES.md - กฎเหล็กการแยกขาด 2 ชั้น](doc/th/02_TWO_TIER_RULES.md)
- 🎭 [03_PLAYWRIGHT_MCP_SPEC.md - มาตรฐาน Playwright Browser MCP](doc/th/03_PLAYWRIGHT_MCP_SPEC.md)
- 🔑 [config/README.md - คู่มือจัดการความลับ & Credentials (.env / SSH / Fine-Grained PAT)](config/README.md)

---

## 🙏 เครดิตและเครื่องมือที่อ้างอิง

ดูรายละเอียดเต็มได้ที่ [หน้าหลัก README.md](README.md#-เครดิตและเครื่องมือที่อ้างอิง-credits--acknowledgements)

---

[🏠 หน้าหลัก (Home)](README.md) | [🇬🇧 English](README.en.md) | [⬆️ กลับด้านบน](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](LICENSE)
