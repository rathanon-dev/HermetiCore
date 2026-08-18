<a id="top"></a>

# 🔒 กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Hermetic Separation)
[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [🇬🇧 Read in English](../en/02_TWO_TIER_RULES.md)

---

## 1. Tier 1 (AI Control Plane)
- **ตำแหน่ง:** `tools/`, `.mcp/`, `.skills/`
- **ขอบเขต:** สำหรับเครื่องมือของ AI Agent เท่านั้น
- **ข้อห้าม:** ห้ามรัน `npm install` หรือ `pip install` สำหรับโปรเจกต์ลงใน Tier 1 เด็ดขาด

---

## 2. Tier 2 (Project Data Plane)
- **ตำแหน่ง:** `projects/<project_name>/runtime/`
- **ขอบเขต:** รันไทม์เฉพาะของแต่ละโปรเจกต์
- **การแยกส่วน:** ทุก dependencies (`node_modules`, `.venv`, CUDA DLLs) จะต้องถูกกักขังอยู่ในโฟลเดอร์ของโปรเจกต์นั้น 100%

---

[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [🏛️ สถาปัตยกรรมระบบ](01_ARCHITECTURE.md) | [⬆️ กลับขึ้นด้านบน (Back to Top)](#top)
