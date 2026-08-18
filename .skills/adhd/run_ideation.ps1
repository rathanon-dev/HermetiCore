# ======================================================================
# ADHD DIVERGENT COGNITIVE IDEATOR RUNNER (MCP & CLI BRIDGE)
# ======================================================================
param (
    [string]$Problem = "Evaluate and architecture stress-test current project design"
)

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host " [ADHD] Activating Divergent Cognitive Engine..." -ForegroundColor Cyan
Write-Host " [ADHD] Problem Context: $Problem" -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan

$skillDoc = Join-Path $PSScriptRoot "SKILL.md"
if (Test-Path $skillDoc) {
    Write-Host " [OK] Cognitive Protocol Loaded: $skillDoc" -ForegroundColor Green
    Write-Host " Frames Active: [Hardware Engineer, Logistics, Biology, Speedrunner, Scrappy]" -ForegroundColor White
} else {
    Write-Host " [WARN] SKILL.md not found in $($PSScriptRoot)" -ForegroundColor Yellow
}
