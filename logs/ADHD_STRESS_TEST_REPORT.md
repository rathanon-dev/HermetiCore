# à¸£à¸²à¸¢à¸‡à¸²à¸™à¸œà¸¥à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸šà¸„à¸§à¸²à¸¡à¸—à¸™à¸—à¸²à¸™à¸£à¸°à¸šà¸š HermetiCore (ADHD Stress-Test Report)

- **à¸§à¸±à¸™à¹à¸¥à¸°à¹€à¸§à¸¥à¸²à¸—à¸µà¹ˆà¸—à¸”à¸ªà¸­à¸š:** 2026-08-19 05:14:23
- **à¸•à¸³à¹à¸«à¸™à¹ˆà¸‡à¹‚à¸Ÿà¸¥à¹€à¸”à¸­à¸£à¹Œà¸—à¸”à¸ªà¸­à¸š:** D:\HermetiCore
- **à¹€à¸§à¸¥à¸²à¸£à¸§à¸¡à¹ƒà¸™à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸šà¸—à¸¸à¸à¸à¸£à¸“à¸µ:** 27.47 à¸§à¸´à¸™à¸²à¸—à¸µ
- **à¸œà¸¥à¸ªà¸£à¸¸à¸›à¸ à¸²à¸žà¸£à¸§à¸¡:** PASSED (100% RELIABLE)

---

## à¸•à¸²à¸£à¸²à¸‡à¸ªà¸£à¸¸à¸›à¸œà¸¥à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸šà¹à¸•à¹ˆà¸¥à¸°à¸à¸£à¸“à¸µ (Test Matrix)

| à¸«à¸¡à¸§à¸”à¸«à¸¡à¸¹à¹ˆ (Category) | à¸à¸£à¸“à¸µà¸—à¸”à¸ªà¸­à¸š (Scenario) | à¸ªà¸–à¸²à¸™à¸° | à¹€à¸§à¸¥à¸² | à¸£à¸²à¸¢à¸¥à¸°à¹€à¸­à¸µà¸¢à¸”à¸—à¸²à¸‡à¸§à¸´à¸¨à¸§à¸à¸£à¸£à¸¡ / à¸«à¸¥à¸±à¸à¸à¸²à¸™à¸à¸²à¸£à¸—à¸”à¸ªà¸­à¸š |
|---|---|---|---|---|
| **Cold Boot** | setup.ps1 -AutoBootstrap | PASS | 11.13s | All 5 tools successfully hydrated and unblocked |
| **Batch Validation** | start.bat Integrity | PASS | 0s | Contains valid setup invocation & isolation PATH |
| **Batch Validation** | start-workspace.bat Integrity | PASS | 0s | Contains valid setup invocation & isolation PATH |
| **Batch Validation** | auto-install.bat Integrity | PASS | 0s | Contains valid setup invocation & isolation PATH |
| **Batch Validation** | auto-install-ai-workstation.bat Integrity | PASS | 0s | Contains valid setup invocation & isolation PATH |
| **Warm Boot** | setup.ps1 Fast-Path Skip | PASS | 1.01s | Skipped all redundant downloads in 1.01s |
| **Warm Boot** | start.bat Instant Path Skip | PASS | 0s | Instant tool detection (<0.02s), zero network overhead |
| **Concurrency** | Simultaneous Double-Click Lock | PASS | 10.26s | PID Mutex lock successfully blocked duplicate instance and prevented file collision |
| **Self-Healing** | Dead Lockfile PID Recovery | PASS | 1.02s | Detected stale lock from crashed PID, safely overrode lock |
| **Telemetry** | Ephemeral Toolchain Execution | PASS | 0.35s | Git: git version 2.46.0.windows.1 | Node: v20.17.0 | Python: Python 3.12.5 | Aria2: aria2 version 1.37.0 |


---

## à¸‚à¹‰à¸­à¸¡à¸¹à¸¥ Telemetry à¹à¸¥à¸°à¸„à¸§à¸²à¸¡à¸žà¸£à¹‰à¸­à¸¡à¸‚à¸­à¸‡à¹€à¸„à¸£à¸·à¹ˆà¸­à¸‡à¸¡à¸·à¸­ Tier 1

- **Git Portable:** git version 2.46.0.windows.1
- **Node.js LTS:** v20.17.0 (npm: 10.8.2)
- **Python Embedded:** Python 3.12.5
- **Aria2 Multi-Connection Engine:** aria2 version 1.37.0
- **7-Zip Command Line:** 7za.exe (NuGet Isolated Package)

---

## à¸œà¸¥à¸à¸²à¸£à¸žà¸´à¸ªà¸¹à¸ˆà¸™à¹Œà¸„à¸§à¸²à¸¡à¸—à¸™à¸—à¸²à¸™à¸•à¹ˆà¸­ Edge Cases

1. **Cold-Boot Zero-Install (à¹€à¸£à¸´à¹ˆà¸¡à¸ˆà¸²à¸à¸¨à¸¹à¸™à¸¢à¹Œ):** à¸”à¸¶à¸‡à¹€à¸„à¸£à¸·à¹ˆà¸­à¸‡à¸¡à¸·à¸­à¸„à¸£à¸š 5 à¸•à¸±à¸§à¹à¸šà¸šà¹„à¸¡à¹ˆà¸¡à¸µà¸‚à¹‰à¸­à¸œà¸´à¸”à¸žà¸¥à¸²à¸” à¹à¸¡à¹‰à¹„à¸¡à¹ˆà¸¡à¸µà¹‚à¸›à¸£à¹à¸à¸£à¸¡à¹ƒà¸”à¹† à¹ƒà¸™ Windows
2. **Warm-Boot Idempotency (à¹€à¸›à¸´à¸”à¸‹à¹‰à¸³à¹€à¸¡à¸·à¹ˆà¸­à¸¡à¸µà¹à¸¥à¹‰à¸§):** à¹€à¸Šà¹‡à¸„à¸‚à¹‰à¸²à¸¡à¹„à¸”à¹‰à¹ƒà¸™à¹€à¸§à¸¥à¸²à¹„à¸¡à¹ˆà¸–à¸¶à¸‡ 1.5 à¸§à¸´à¸™à¸²à¸—à¸µ à¹„à¸¡à¹ˆà¹€à¸›à¸¥à¸·à¸­à¸‡à¹€à¸™à¹‡à¸•à¹à¸¥à¸°à¹„à¸¡à¹ˆà¸”à¸²à¸§à¸™à¹Œà¹‚à¸«à¸¥à¸”à¸‹à¹‰à¸³
3. **Double-Click Collision (à¸à¸”à¸‹à¹‰à¸³/à¸à¸”à¸«à¸¥à¸²à¸¢à¸•à¸±à¸§à¸žà¸£à¹‰à¸­à¸¡à¸à¸±à¸™):** à¸£à¸°à¸šà¸šà¹ƒà¸Šà¹‰ PID Mutex Lock (.setup-lock) à¸šà¸¥à¹‡à¸­à¸à¹‚à¸›à¸£à¹€à¸‹à¸ªà¸—à¸µà¹ˆà¸ªà¸­à¸‡à¸—à¸±à¸™à¸—à¸µ à¹„à¸¡à¹ˆà¹€à¸à¸´à¸”à¸›à¸±à¸à¸«à¸²à¹„à¸Ÿà¸¥à¹Œà¸—à¸±à¸šà¸à¸±à¸™à¸ˆà¸™à¸žà¸±à¸‡
4. **Dead PID Recovery (à¸à¸²à¸£à¸à¸¹à¹‰à¸„à¸·à¸™à¹€à¸¡à¸·à¹ˆà¸­à¹‚à¸›à¸£à¹€à¸‹à¸ªà¹€à¸à¹ˆà¸²à¸„à¹‰à¸²à¸‡):** à¸£à¸°à¸šà¸šà¸•à¸£à¸§à¸ˆà¸ˆà¸±à¸šà¸«à¸¡à¸²à¸¢à¹€à¸¥à¸‚ PID à¸—à¸µà¹ˆà¸•à¸²à¸¢à¹à¸¥à¹‰à¸§ à¹à¸¥à¸°à¸›à¸¥à¸”à¸¥à¹‡à¸­à¸à¸•à¸±à¸§à¹€à¸­à¸‡à¸­à¸±à¸•à¹‚à¸™à¸¡à¸±à¸•à¸´
5. **Session-Level PATH Isolation:** à¸•à¸±à¸§à¹à¸›à¸£ PATH à¸à¸±à¸‡à¹€à¸‰à¸žà¸²à¸°à¹ƒà¸™à¹€à¸‹à¸ªà¸Šà¸±à¸™ à¹„à¸¡à¹ˆà¸›à¸™à¹€à¸›à¸·à¹‰à¸­à¸™ Windows Registry à¸ªà¹ˆà¸§à¸™à¸à¸¥à¸²à¸‡

---

[à¸à¸¥à¸±à¸šà¸ªà¸¹à¹ˆà¸«à¸™à¹‰à¸²à¸«à¸¥à¸±à¸ (Back to README)](../README.md) | [à¸ªà¸–à¸²à¸›à¸±à¸•à¸¢à¸à¸£à¸£à¸¡à¸£à¸°à¸šà¸š](../doc/th/01_ARCHITECTURE.md)
