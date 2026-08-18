<a id="top"></a>

# 🏛️ MetaBase AI (LabBase-5) - คู่มือฉบับภาษาไทย
[🏠 หน้าหลัก (Home)](README.md) | [🇬🇧 Read in English](README.en.md) | [🗺️ แผนที่โครงการ (Projects Map)](PROJECTS_MAP.md)

[![TH](https://img.shields.io/badge/lang-th-green.svg)](README.th.md)
[![EN](https://img.shields.io/badge/lang-en-blue.svg)](README.en.md)
[![Standard: ISO/IEC/IEEE 12207](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2012207-blue.svg)](https://www.iso.org/standard/63711.html)
[![Standard: ISO/IEC/IEEE 42010](https://img.shields.io/badge/Standard-ISO%2FIEC%2FIEEE%2042010-blue.svg)](https://www.iso.org/standard/74427.html)
[![Twelve-Factor: Compliant](https://img.shields.io/badge/Twelve--Factor-Compliant-success.svg)](https://12factor.net/)

---

## 🧭 1. ปรัชญาและแนวคิดการออกแบบ (Design Philosophy)

**MetaBase AI** ถูกสร้างขึ้นบนแนวคิด **"Zero-Global-Pollution & Mechanical Sympathy"**:
1. **ไม่แตะต้อง System PATH:** คอมพิวเตอร์ของระบบหลักจะสะอาด 100% เสมอ
2. **ไม่ใช้ Docker บน Windows:** ตัดปัญหาการกินแรม 4–8 GB ของ WSL2/vmmem และปัญหาความหน่วงของ Cross-Filesystem
3. **ทำงานร่วมกับ AI ได้ทุกค่าย:** ด้วยมาตรฐาน Model Context Protocol (MCP) และ Two-Tier Sandbox

---

## 🛠️ 2. การทำงานของ Tier 1 และ Tier 2

### 🔹 Tier 1 (AI Control Plane):
- โฟลเดอร์ `tools/` มีเครื่องมือระดับราก: 7-Zip, Aria2, MinGit, Node LTS, Python 3.12
- เป็นเครื่องมือประจำตัวของ AI ในการทำบรีฟงาน สเก็ตช์ภาพ และสร้างแม่แบบ
- **ห้ามติดตั้ง npm หรือ pip ของโปรเจกต์ลงในนี้เด็ดขาด**

### 🔹 Tier 2 (Project Data Plane):
- โฟลเดอร์ `projects/<name>/runtime/` คือรันไทม์เฉพาะของแต่ละงาน
- เมื่อสั่ง `npm install` หรือ `pip install` ทุกอย่างจะถูกขังไว้ในโฟลเดอร์โปรเจกต์นั้น 100%

---

## 🚀 3. ขั้นตอนการพัฒนา (End-to-End Workflow)

```
[1. specs/ (ความต้องการ)] ──> [2. design/ (ภาพร่าง/Figma)] ──> [3. services/ (เขียนโค้ด)] 
                                                                    │
[6. repo/ (ซิงค์ขึ้น Git)] <── [5. staging/human/ (คนตรวจรับ)] <── [4. staging/ai/ (AI เทสต์)]
```

---

## 📖 เอกสารเชิงลึก
- [สถาปัตยกรรมระบบ (Architecture)](doc/th/01_ARCHITECTURE.md)
- [กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Rules)](doc/th/02_TWO_TIER_RULES.md)

---

[🏠 หน้าหลัก (Home)](README.md) | [🇬🇧 Read in English](README.en.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)

*จัดทำโดย: [@rathanon-dev](https://github.com/rathanon-dev)*
