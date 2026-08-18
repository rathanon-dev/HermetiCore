# 🧬 AI BOOTSTRAP PROTOCOL (LABBASE-5 MASTER SPEC)
## The Two-Tier Hermetic Separation Standard

> **MANDATORY AI DIRECTIVE:** Any AI agent (Antigravity, Claude, Copilot) operating inside `LabBase-5` MUST strictly enforce the boundary between **Tier 1 (AI Control Plane)** and **Tier 2 (Project Data Plane)** without exception.

---

## 🏛️ 1. กฎเหล็กการแบ่งแยก 2 ชั้น (The Two-Tier Architecture Axiom)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  TIER 1: AI CONTROL PLANE (Root tools/ & .mcp/ - สำหรับ AI เท่านั้น)         │
│                                                                             │
│  • ความเป็นเจ้าของ: เป็นพื้นที่และเครื่องมือเฉพาะของ AI Agent               │
│  • สิ่งที่บรรจุ: 7z, Aria2, Git, Node LTS, Python 3.12, MCP Hub             │
│    (Neo4j, Redis, Postgres, SQLite, Puppeteer Browser Driver, PyWin32)      │
│  • หน้าที่: ใช้เฉพาะช่วง "ต้นน้ำ" (Drafting, สกัด Requirement, Scaffold)   │
│  • ⛔ กฎเหล็กข้อห้าม: ห้าม AI สั่ง npm install หรือ pip install แพ็กเกจของ    │
│    โปรเจกต์ลงใน Tier 1 Root เด็ดขาด!                                        │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (AI ทำหน้าที่เป็นผู้สร้างและวางสเปก)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│  TIER 2: PROJECT DATA PLANE (projects/<name>/runtime/ - สำหรับโปรเจกต์)      │
│                                                                             │
│  • ความเป็นเจ้าของ: เป็นพื้นที่รันไทม์เฉพาะของแต่ละโปรเจกต์                 │
│  • สิ่งที่บรรจุ: Node.js, Python, node_modules, .venv, CUDA DLLs ประจำงาน   │
│  • มาตรฐาน Python ยุคใหม่: ใช้ pyproject.toml (PEP 621) ห้ามใช้ text ล้วน    │
│  • หน้าที่: ทุกคำสั่ง `npm install`, `pip install`, `npm run dev`, `build`   │
│    จะต้องรันผ่าน Runtime ภายในโฟลเดอร์ `projects/<name>/runtime/` เท่านั้น    │
│  • 🔒 การแยกส่วน: โปรเจกต์ A และ B มี Runtime อิสระต่อกัน 100%             │
│    ไม่มีการแชร์ node_modules ข้ามโปรเจกต์ และไม่ย้อนกลับไปกวน Tier 1 Base   │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🎯 2. เสาหลัก 3 เฟรมเวิร์ก (The 3 Framework Pillars)

1. **PowerShell Engine (Windows Automation Backbone):**
   - รองรับทั้ง **PowerShell 5.1 (Desktop)** ในตัว Windows และ **PowerShell 7.x (Core)**
   - ทำงานแบบ Bare-Metal Zero-Admin Scripting

2. **Node.js LTS Engine (Web & MCP Ecosystem):**
   - พัฒนาเว็บด้วย Next.js, React, Tailwind, TypeScript
   - รัน MCP Servers และเชื่อมต่อ OmniProxy LAN Cache อัตโนมัติ

3. **Modern Python 3.12 Engine (AI & Data Science):**
   - บังคับใช้มาตรฐาน **`pyproject.toml` (PEP 517/518/621)** เสมอ (เทียบเท่า `package.json` ของ Node)
   - รองรับ PyTorch, CUDA Dynamic DLLs, FastAPI, และ ComfyUI

---

## 📋 3. วงจรการทำงานของ AI (Lifecycle Operational Rules)

### 🔹 สเต็ปที่ 1: ช่วงตั้งต้น / ร่างไอเดีย (Drafting Phase)
- AI สามารถใช้เครื่องมือใน **Tier 1 (`tools/`)** และ MCP ต่างๆ (Neo4j Graph, Redis, SQLite, Puppeteer Driver) ในการค้นหาข้อมูล, ร่างข้อกำหนดใน `specs/01_REQUIREMENTS.md`, และดึง Design Tokens จาก Figma มาใส่ใน `design/`

### 🔹 สเต็ปที่ 2: ช่วงขึ้นโครงสร้างและติดตั้งโค้ด (Construction Phase)
- เมื่อเริ่มพัฒนาโค้ดหรือติดตั้ง Dependencies (เช่น `npm install` หรือ `pip install`):
  - **AI จะต้องสั่งงานผ่าน Runtime ในโฟลเดอร์ของโปรเจกต์นั้นเสมอ (`projects/<name>/runtime/`)**
  - หากโปรเจกต์ใช้ Node.js: ให้โหลด Node.js พกพามาใส่ใน `projects/<name>/runtime/tools/node/`
  - หากโปรเจกต์ใช้ Python + GPU: ให้โหลด Python + CUDA DLLs มาใส่ใน `projects/<name>/runtime/tools/nvidia/`
  - ทุกแพ็กเกจจะถูกกักขังไว้ในโฟลเดอร์โปรเจกต์นั้น 100%

### 🔹 สเต็ปที่ 3: ช่วงทดสอบและส่งมอบงาน (Verification & Gate Phase)
- AI ทดสอบความถูกต้องใน `staging/ai/` โดยรันผ่าน Runtime เฉพาะของโปรเจกต์
- ส่งต่อให้คนทดสอบใน `staging/human/` ผ่านไฟล์ `start_verify.bat`
- ซิงค์โค้ดที่ผ่านการอนุมัติเข้า `repo/` เพื่อทำ Git Push

---

## 📜 4. ข้อกำหนดการบันทึก Audit Log อย่างต่อเนื่อง (Continuous Multi-Agent Logging)

> **MANDATORY LOGGING RULE:** ทุกครั้งที่ AI Agent ทำการปรับปรุงโค้ด, รัน Stress-Test, หรือเปลี่ยนผ่านสเตจสำคัญ **จะต้องเพิ่มประวัติ (Append Log)** เข้าไปในไฟล์ **[`logs/AI_MULTI_AGENT_LOG.md`](file:///D:/MetaBase-AI/logs/AI_MULTI_AGENT_LOG.md)** เสมอ เพื่อให้ Human Architect สามารถตรวจสอบย้อนหลังได้ทุกขั้นตอน

---

## 🛡️ 5. การันตีความปลอดภัย (Zero Contamination Guarantee)
1. **Tier 1 Root Base** จะสะอาดและไม่เปลี่ยนสภาพตลอดไป (Immutable AI Workstation)
2. **Tier 2 Projects** สามารถลบทิ้ง แตกไฟล์ใหม่ หรือย้ายไปเครื่องอื่นได้ทันทีโดยไม่พัง
