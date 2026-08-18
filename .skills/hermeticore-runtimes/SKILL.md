---
name: hermeticore-runtimes
description: "Core Scaffolding Scripts for Deploying Isolated Runtimes in Tier 2"
---

# HermetiCore Runtime Scaffolders (Tier 2)

**CRITICAL RULE:** Do NOT write your own PowerShell or shell scripts to download/install Node.js or Python. You MUST use these scaffolders to guarantee architectural compliance, proxy-awareness, and zero-footprint isolation.

These scripts automatically use Tier 1's `aria2` and `7-zip` for extreme performance, and read `config/.env` for `OMNIPROXY_URL`.

## Available Runtimes

All scripts are located in `.skills\hermeticore-runtimes\`

### 1. Node.js
Deploy a local, portable Node.js runtime inside a specific project.
```powershell
& ".\.skills\hermeticore-runtimes\Runtime-Node.ps1" -TargetProjectName "my-web-app" -NodeVersion "20.17.0"
```
**Outcome:** `projects\my-web-app\runtime\tools\node\node.exe`

### 2. Python (Standard)
Deploy a portable Python environment via NuGet API. Includes `pip`.
```powershell
& ".\.skills\hermeticore-runtimes\Runtime-Python.ps1" -TargetProjectName "my-api-app" -PythonVersion "3.12.5"
```
**Outcome:** `projects\my-api-app\runtime\tools\python\python.exe`

### 3. Python (with CUDA GPU Acceleration)
Deploy Python + NVIDIA CUDA Core DLLs (cublas, cudart, nvrtc) injected directly into the project's bin folder for zero-footprint GPU acceleration (Perfect for PyTorch/ComfyUI).
```powershell
& ".\.skills\hermeticore-runtimes\Runtime-Python-CUDA.ps1" -TargetProjectName "my-ai-app" -PythonVersion "3.12.5" -CudaVersion "12.1.1"
```
**Outcome:** 
- `projects\my-ai-app\runtime\tools\python\python.exe`
- `projects\my-ai-app\runtime\tools\nvidia\bin\*.dll` (Must be added to `$env:PATH` before running PyTorch).
