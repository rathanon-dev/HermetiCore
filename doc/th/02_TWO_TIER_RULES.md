<a id="top"></a>

# 🔒 กฎเหล็กการแยกขาด 2 ชั้น (Two-Tier Hermetic Separation)
[⬅️ กลับสู่หน้าหลัก (Back to README)](../../README.md) | [🇬🇧 Read in English](../en/02_TWO_TIER_RULES.md)

---

## 1. Tier 1 (AI Control Plane)
- **ตำแหน่ง:** `tools/`, `.mcp/`, `.skills/`
- **ขอบเขต:** สำหรับเครื่องมือของ AI Agent เท่านั้น
- **กฎเหล็ก Host Detachment:** AI ต้องใช้ Portable Tools (`tools/git`, `tools/node`, `tools/python312`) ภายใน Tier 1 เท่านั้น **ห้ามใช้ Global Git/Node/Python ของเครื่องหลัก (Host Machine) เด็ดขาด**
- **ข้อห้าม:** ห้ามรัน `npm install` หรือ `pip install` สำหรับโปรเจกต์ลงใน Tier 1 เด็ดขาด

---

## 2. Tier 2 (Project Data Plane)
- **ตำแหน่ง:** `projects/<project_name>/runtime/`
- **ขอบเขต:** รันไทม์เฉพาะของแต่ละโปรเจกต์
- **การแยกส่วน:** ทุก dependencies (`node_modules`, `.venv`, CUDA DLLs) จะต้องถูกกักขังอยู่ในโฟลเดอร์ของโปรเจกต์นั้น 100% ไม่อนุญาตให้ย้อนกลับมาปนเปื้อน Tier 1 Base

---

---

**การนำทาง:** [🏠 หน้าหลัก](../../README.md) | [🇹🇭 ภาษาไทย](../../README.th.md) | [🇬🇧 English](../../README.en.md) | [🏛️ สถาปัตยกรรม](01_ARCHITECTURE.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [⬆️ กลับด้านบน](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](../../LICENSE) · [เครดิตทั้งหมด](../../README.md#-เครดิตและเครื่องมือที่อ้างอิง-credits--acknowledgements)
