<a id="top"></a>
[🏠 หน้าหลัก (Home)](../../README.md) > [📚 เอกสารภาษาไทย (TH)] > 📄 **สถาปัตยกรรมเครื่องมือและข้อกำหนดสิทธิ์ (Tooling & Licenses)**

# 📜 สถาปัตยกรรมเครื่องมือและข้อกำหนดสิทธิ์ (Tooling Pipeline & Licenses)

เอกสารนี้อธิบายสถาปัตยกรรม "การดึงเครื่องมือ (Bootstrapping)" ของโปรเจกต์ HermetiCore อย่างละเอียด เพื่อให้เกิดความโปร่งใสในด้านข้อกำหนดสิทธิ์ (Licenses) และแสดงให้เห็นถึงความสามารถของระบบที่สามารถประกอบร่างตัวเองได้แบบ 100% Zero-Footprint.

---

## 1. ปรัชญาการออกแบบ (Design Philosophy)
โปรเจกต์ HermetiCore **ไม่มีการแนบไฟล์ Binary ใดๆ (เช่น .exe, .dll) มาใน Repository นี้เด็ดขาด** 
เราใช้หลักการ **"Infrastructure as Code (IaC) - Portable Edition"** โดยเมื่อรัน `setup.ps1` ระบบจะวิ่งไปดาวน์โหลด Official Releases จากต้นทางของแต่ละโปรเจกต์โดยตรง แตกไฟล์บนหน่วยความจำ และจัดเก็บในรูปแบบ Isolated (Portable) โดยไม่แตะต้อง Registry หรือ Path ของ Windows เลย.

---

## 2. รายการเครื่องมือ, สถาปัตยกรรมการดึง, และข้อกำหนดสิทธิ์ (Tooling & Licenses)

### 2.1. 7-Zip (Core Unzipper)
*   **Role:** เป็นเครื่องมือชิ้นแรกสุด (God Tool) ที่ใช้แตกไฟล์แพ็กเกจทุกตัวบนโลก Windows
*   **Fetch Method:** ดึงผ่านระบบ **NuGet API** ของ Microsoft (`7-Zip.CommandLine`) แบบ Zip file ทำให้เราได้ `7za.exe` มาใช้งานทันทีโดยไม่ต้อง Install
*   **License:** GNU LGPL (GNU Lesser General Public License)
*   **Source:** [7-zip.org](https://www.7-zip.org/) / [NuGet](https://www.nuget.org/packages/7-Zip.CommandLine)

### 2.2. Aria2 (High-Speed Downloader)
*   **Role:** จรวดเร่งความเร็วในการดาวน์โหลดไฟล์ใหญ่ๆ แบบแยกส่วน (Multi-connection)
*   **Fetch Method:** ดึงตรงจากหน้า **GitHub Releases** (`aria2-1.37.0-win-64bit-build1.zip`)
*   **License:** GPLv2 (General Public License version 2.0)
*   **Source:** [aria2/aria2 on GitHub](https://github.com/aria2/aria2)

### 2.3. MinGit (Version Control)
*   **Role:** ระบบ SCM ขั้นพื้นฐานสำหรับการดึงโปรเจกต์ (Clone) โดยตัด UI และของที่ไม่จำเป็นออก
*   **Fetch Method:** ดึงเวอร์ชัน "MinGit" (Minimal Git) จาก **GitHub Releases** (`git-for-windows`)
*   **License:** GPLv2
*   **Source:** [git-for-windows/git on GitHub](https://github.com/git-for-windows/git)

### 2.4. Node.js (Web & MCP Engine)
*   **Role:** รันไทม์หลักสำหรับสร้าง Next.js, รัน Playwright, และรัน Model Context Protocol (MCP) Servers
*   **Fetch Method:** ดึงไฟล์ `.zip` สำหรับ Windows จาก **nodejs.org** โดยตรง แล้วแตกไฟล์ลงโฟลเดอร์ `tools/node`
*   **License:** MIT License
*   **Source:** [nodejs.org](https://nodejs.org/)

### 2.5. Python 3.12 (AI & Data Science Engine)
*   **Role:** รันไทม์หลักสำหรับ ComfyUI, PyTorch, และ AI Models แบบ Local
*   **Fetch Method:** แทนที่จะดึงไฟล์ `.zip` ธรรมดา ระบบทำการดึงผ่าน **NuGet API** (`python.3.12.nupkg` และ `pythonarm64`) ซึ่งเป็นแพ็กเกจที่ทำเพื่อ CI/CD ทำให้ได้ `pip` และ Environment ที่สมบูรณ์แบบโดยไม่ต้องดัดแปลงระบบแฮ็กแบบวิธีดั้งเดิม
*   **License:** PSF License (Python Software Foundation License)
*   **Source:** [python.org](https://www.python.org/) / [NuGet (Python)](https://www.nuget.org/packages/python)

### 2.6. NVIDIA CUDA Core & cuDNN (GPU Acceleration)
*   **Role:** ไดรเวอร์ระดับลึกสำหรับการประมวลผล AI/Machine Learning
*   **Fetch Method (Zero-Footprint):** ระบบ **"ไม่ได้"** ให้ผู้ใช้โหลดไฟล์ Installer `.exe` ของ NVIDIA มาติดตั้งลงเครื่อง (ซึ่งหนักเป็น GBs และฝังรากลึก) แต่ระบบจะทำการยิง API ไปดึงไฟล์ JSON กระจายของ NVIDIA และสกัดเอาเฉพาะไฟล์ `.dll` แก่นแท้ (เช่น `cublas.dll`, `cudnn.dll`) ออกมาใส่โฟลเดอร์ `bin` พกพา เพื่อให้ Python รันแบบ Just-in-Time 
*   **License:** NVIDIA EULA (End User License Agreement)
*   **Source:** [developer.nvidia.com](https://developer.nvidia.com/)

---

## 3. สรุปความคุ้มครองทางลิขสิทธิ์ (Compliance Statement)
ผู้พัฒนาโปรเจกต์ HermetiCore ขอยืนยันว่า:
1. โค้ดทั้งหมดใน Repository นี้ทำหน้าที่เสมือน "บอทดาวน์โหลดอัตโนมัติ" (Automation Wrapper) เท่านั้น
2. เราไม่มีการทำซ้ำ (Reproduce) หรือแจกจ่าย (Distribute) ทรัพย์สินทางปัญญาของ Third-Party ใดๆ
3. ผู้ใช้งาน (End-User) จะเป็นผู้เชื่อมต่ออินเทอร์เน็ตและดาวน์โหลดไฟล์เหล่านั้นมาที่เครื่องตนเองตามสิทธิ์การใช้งานของแพลตฟอร์มต้นทาง 100%

---

**การนำทาง (Navigation):** [🏠 หน้าหลัก (Home)](../../README.md) | [🏛️ สถาปัตยกรรม (Architecture)](01_ARCHITECTURE.md) | [🔒 กฎ 2 ชั้น (Two-Tier Rules)](02_TWO_TIER_RULES.md) | [🎭 Playwright MCP](03_PLAYWRIGHT_MCP_SPEC.md) | [📜 ข้อกำหนด (Licenses)](04_TOOLING_AND_LICENSES.md) | [⬆️ กลับด้านบน (Top)](#top)

**ผู้พัฒนาและดูแลโครงการ:** [@rathanon-dev](https://github.com/rathanon-dev) · **สัญญาอนุญาต:** [MIT](../../LICENSE)
