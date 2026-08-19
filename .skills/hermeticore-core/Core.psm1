# ==============================================================================
# HermetiCore — Core Utilities (Proxy, Resilient Downloads, Failsafe Extraction)
# ==============================================================================

function Get-HermetiProxy {
    param ([string]$WorkspaceRoot)
    $envFile = Join-Path $WorkspaceRoot "config\.env"
    if (-not (Test-Path $envFile)) { return $null }
    
    $envContent = Get-Content $envFile
    $proxyMatch = $envContent | Where-Object { $_ -match "^OMNIPROXY_URL=`"(.*)`"" }
    if (-not $proxyMatch) { return $null }
    
    $proxyUrl = $matches[1]
    try {
        $uri = [System.Uri]$proxyUrl
        $tcp = New-Object Net.Sockets.TcpClient
        $async = $tcp.BeginConnect($uri.Host, $uri.Port, $null, $null)
        if ($async.AsyncWaitHandle.WaitOne(1200, $true) -and $tcp.Connected) {
            $tcp.Close()
            return $proxyUrl
        }
        $tcp.Close()
    } catch {}
    return $null
}

function Invoke-HermetiAPI {
    param (
        [Parameter(Mandatory=$true)][string]$Url,
        [string]$ProxyUrl = $null,
        [switch]$AsJson
    )
    $effectiveUrl = if ($ProxyUrl) { "$ProxyUrl/$Url" } else { $Url }
    try {
        if ($AsJson) {
            return Invoke-RestMethod -Uri $effectiveUrl -UseBasicParsing -TimeoutSec 15
        } else {
            $res = Invoke-WebRequest -Uri $effectiveUrl -UseBasicParsing -TimeoutSec 15
            return $res.Content
        }
    } catch {
        Write-Warning "API fetch failed: $($_.Exception.Message)"
        return $null
    }
}

function Expand-HermetiArchive {
    param (
        [Parameter(Mandatory=$true)][string]$FilePath,
        [Parameter(Mandatory=$true)][string]$Destination,
        [string]$ToolsDir = ""
    )
    $7za = if ($ToolsDir) { Join-Path $ToolsDir "7zip\7za.exe" } else { "" }
    
    if (-not (Test-Path $Destination)) { New-Item -ItemType Directory -Path $Destination -Force | Out-Null }

    if ($7za -and (Test-Path $7za)) {
        $testOut = & $7za t $FilePath -bsp0 -bso0 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Archive integrity check failed (Corrupted file)" }
        & $7za x $FilePath "-o$Destination" -y -bsp0 -bso0 | Out-Null
        if ($LASTEXITCODE -eq 0) { return }
    }

    if ($FilePath.EndsWith(".zip") -or $FilePath.EndsWith(".nupkg")) {
        Write-Host " [*] Fallback: Using native Windows Expand-Archive..." -ForegroundColor Yellow
        Expand-Archive -Path $FilePath -DestinationPath $Destination -Force
        return
    }
    throw "Failed to extract $FilePath (7za missing and not a .zip/.nupkg)"
}

function Invoke-HermetiDownload {
    param (
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutFile,
        [string]$ProxyUrl = $null,
        [string]$ToolsDir = "",
        [long]$ExpectedSize = 0
    )
    $effectiveUrl = if ($ProxyUrl) { "$ProxyUrl/$Url" } else { $Url }
    $outDir = Split-Path $OutFile -Parent
    $fileName = Split-Path $OutFile -Leaf
    if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }

    $aria2 = if ($ToolsDir) { Join-Path $ToolsDir "aria2\aria2c.exe" } else { "" }

    if ($aria2 -and (Test-Path $aria2)) {
        & $aria2 -x 8 -s 8 -d $outDir -o $fileName $effectiveUrl --console-log-level=warn | Out-Null
        if ((Test-Path $OutFile) -and ($ExpectedSize -eq 0 -or (Get-Item $OutFile).Length -eq $ExpectedSize)) { return }
        if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    }

    $curlExe = Get-Command "curl.exe" -ErrorAction SilentlyContinue
    if ($curlExe) {
        Write-Host " [*] Fallback: Using cURL..." -ForegroundColor Yellow
        & $curlExe.Source -L -f -A "Mozilla/5.0" -s $effectiveUrl -o $OutFile
        if ((Test-Path $OutFile) -and ($ExpectedSize -eq 0 -or (Get-Item $OutFile).Length -eq $ExpectedSize)) { return }
        if (Test-Path $OutFile) { Remove-Item $OutFile -Force }
    }

    Write-Host " [*] Fallback: Using native PowerShell Invoke-WebRequest..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $effectiveUrl -OutFile $OutFile -UseBasicParsing
    if ((Test-Path $OutFile) -and ($ExpectedSize -eq 0 -or (Get-Item $OutFile).Length -eq $ExpectedSize)) { return }
    
    throw "Download failed across all engines for: $Url"
}



# ==============================================================================
# Dynamic Version Resolution (Evergreen API Fetchers)
# ==============================================================================

function Get-HermetiLatestGitHubAsset {
    param([string]$Repo, [string]$AssetRegex, [string]$ProxyUrl)
    $url = "https://api.github.com/repos/$Repo/releases/latest"
    $res = Invoke-HermetiAPI -Url $url -ProxyUrl $ProxyUrl -AsJson
    if (-not $res) { throw "Failed to fetch GitHub release for $Repo" }
    $asset = $res.assets | Where-Object { $_.name -match $AssetRegex } | Select-Object -First 1
    if (-not $asset) { throw "No asset matching $AssetRegex found in $Repo" }
    return $asset.browser_download_url
}

function Get-HermetiLatestNuGetVersion {
    param([string]$PackageId, [string]$ProxyUrl)
    $url = "https://azuresearch-usnc.nuget.org/query?q=packageid:$PackageId&prerelease=false"
    $res = Invoke-HermetiAPI -Url $url -ProxyUrl $ProxyUrl -AsJson
    if (-not $res -or -not $res.data) { throw "Failed to fetch NuGet version for $PackageId" }
    return $res.data[0].version
}

function Get-HermetiLatestNodeVersion {
    param([string]$ProxyUrl)
    $url = "https://nodejs.org/dist/index.json"
    $res = Invoke-HermetiAPI -Url $url -ProxyUrl $ProxyUrl -AsJson
    if (-not $res) { throw "Failed to fetch Node.js versions" }
    return $res[0].version.TrimStart('v')
}

Export-ModuleMember -Function Get-HermetiProxy, Invoke-HermetiAPI, Expand-HermetiArchive, Invoke-HermetiDownload, Get-HermetiLatestGitHubAsset, Get-HermetiLatestNuGetVersion, Get-HermetiLatestNodeVersion
