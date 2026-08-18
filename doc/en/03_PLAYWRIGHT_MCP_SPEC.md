<a id="top"></a>

# 🎭 Playwright Browser MCP Engine Specification
[⬅️ Back to Main README](../../README.md) | [🇹🇭 อ่านฉบับภาษาไทย](../th/03_PLAYWRIGHT_MCP_SPEC.md)

---

## 📌 Executive Summary: Why MetaBase-AI Mandates Playwright

In an autonomous AI workstation, AI Agents require robust "eyes and hands" to execute visual UI inspection, automated E2E testing, visual regression analysis, and resilient data extraction.

Based on industry benchmarks and the comprehensive analysis by **Autify ([Playwright vs Puppeteer: What's the Difference?](https://autify.com/blog/playwright-vs-puppeteer))**, the original core creators of Puppeteer at Google migrated to Microsoft in 2020 to build **Playwright**, solving the architectural limits of earlier tools.

---

## 🥊 Engineering Benchmark: Playwright vs Puppeteer for Autonomous AI

| Feature | 🎭 Microsoft Playwright *(Mandatory)* | 🐕 Google Puppeteer *(Deprecated)* | AI Agent Impact |
|---|---|---|---|
| **Auto-Waiting Engine** | ✅ **100% Native** (Waits for actionable, visible, stable DOM) | ❌ Requires manual `waitForSelector()` or arbitrary timers | Prevents flaky interactions due to asynchronous rendering. |
| **Multi-Context Sandbox** | ✅ `browser.newContext()` creates isolated sessions in **< 5ms** | ⚠️ Must spawn heavy browser processes | Test multi-user apps (e.g. LAN Share Chat) with zero cookie collisions. |
| **Engine Compatibility** | ✅ **Chromium, Firefox, WebKit (Safari)** | ⚠️ Primary focus on Chromium | Full cross-engine visual verification. |
| **Network & Proxy Routing** | ✅ Granular per-context proxy & route mocking | ⚠️ Global process-level proxy only | Enables seamless OmniProxy LAN (`192.168.1.10:8080`) routing. |
| **Multi-Language SDK** | ✅ TypeScript/Node.js, Python, C#, Java | ❌ JavaScript/Node.js focused | Unified SDK across all MetaBase-AI pillars. |

---

## 🏛️ Zero-Pollution Playwright MCP Architecture

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│ 🧠 AI AGENT (Antigravity / Claude / Copilot)                                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (JSON-RPC Protocol)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│ 🔌 TIER 1: Playwright MCP Server (@executeautomation/playwright-mcp-server) │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Headless Sandbox Execution (Zero user desktop disruption)                 │
│ • Isolated Browser Storage: tools/playwright-browsers/ (Zero user pollution)│
│ • LAN Proxy Routing: OmniProxy Gateway (192.168.1.10:8080)                   │
│ • Exposed Tool Suite:                                                       │
│   ├── playwright_navigate (Open Target URL / Localhost)                     │
│   ├── playwright_screenshot (Visual UI capture for Agent analysis)          │
│   ├── playwright_click / fill (Form inputs, button clicks)                  │
│   ├── playwright_evaluate (Execute JavaScript DOM extraction)               │
│   └── playwright_get_console_logs (Intercept client runtime errors)          │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ (Automated Verification)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│ 🌐 TIER 2: Project Runtime Web Services (Next.js :3000 / FastAPI :8000)     │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

[⬅️ Back to Main README](../../README.md) | [🏛️ System Architecture](01_ARCHITECTURE.md) | [🔒 Two-Tier Rules](02_TWO_TIER_RULES.md) | [⬆️ Back to Top](#top)
