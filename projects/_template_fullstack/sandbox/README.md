# 🧪 sandbox/ — Project Ephemeral Test Environment

This folder contains **everything needed to simulate and test the project** under realistic conditions.
It is **never committed to git** (except the documented structure files).

---

## 📁 Structure

```text
sandbox/
├── demo_users/                  # 👤 Isolated browser profiles for Playwright multi-user simulation
│   ├── user_alice/              # Alice's full browser context (cookies, localStorage, session)
│   │   └── profile/             # Playwright userDataDir — passed to browser.newContext()
│   └── user_bob/                # Bob's full browser context (completely isolated from Alice)
│       └── profile/
├── mock_data/                   # 📝 Seed data: Fake users, chat rooms, API fixtures (committed to git)
│   ├── seed_users.json
│   └── seed_chat_rooms.json
└── temp/                        # 🗑️ Project-local ephemeral files (auto-cleaned, gitignored)
```

---

## 🔒 Isolation Rules (ADHD-Audited)

1. **`demo_users/` isolation:** Each user folder maps to a completely separate `userDataDir` for Playwright.
   - ✅ Cookie, LocalStorage, IndexedDB are 100% isolated between users.
   - ✅ Simulates multi-user LAN sessions without session collision.

2. **`temp/` hygiene:** This is the project's own trash can.
   - ✅ Gitignored via `projects/**/sandbox/temp/`
   - ✅ **Root `D:\MetaBase-AI\temp\` is SEPARATE** — for bootstrap downloads only, auto-deleted.

3. **`mock_data/` is static:** JSON seed files ARE committed to git — they are the canonical demo dataset.
