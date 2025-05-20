<#
    Script: Find-Orphaned-Media.ps1
    Description: Scans an Obsidian vault for orphaned media files and optionally moves them to an archive folder. 
                 Designed for large vaults and optimized for PowerShell 7+.

    Author: John Kyle
    Created: 2025-05-20
    Version: 1.0.0
    License: MIT (see LICENSE file for details)
    GitHub: https://github.com/johnkyle4/obsidian-media-audit
#>
<#
    This script scans a specified vault directory for orphaned media files (images, videos, etc.) that are not linked in any Markdown files.
    It generates a report of these orphaned files and optionally moves them to an archive directory.
    Usage:
    1. Generate a Report Only (No Moving):
       pwsh -File .\Find-Orphaned-Media.ps1 -VaultPath "C:\Path\To\Vault" -OutputPath "C:\Path\To\Output\orphans.csv"
    2. Generate a Report and Move Orphans:
       pwsh -File .\Find-Orphaned-Media.ps1 -VaultPath "C:\Path\To\Vault" -OutputPath "C:\Path\To\Output\orphans.csv" -ArchivePath "C:\Path\To\Vault\_archived_orphans" -MoveOrphans
    3. Specify File Extensions to Check:
       pwsh -File .\Find-Orphaned-Media.ps1 -VaultPath "C:\Path\To\Vault" -OutputPath "C:\Path\To\Output\orphans.csv" -Extensions "jpg", "png", "mp4"
#>

param (
    [string]$VaultPath = ".",
    [string]$OutputPath = ".\orphaned_media.csv",
    [string]$ArchivePath = "",
    [switch]$MoveOrphans,
    [string[]]$Extensions = @("jpg", "jpeg", "png", "gif", "bmp", "svg", "pdf", "mp4", "mov", "avi", "mkv", "mp3", "wav", "flac")
)

# Resolve Vault Path
$VaultPath = Resolve-Path -Path $VaultPath | Select-Object -ExpandProperty Path
if ($OutputPath -eq "") {
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
    $OutputPath = Join-Path -Path (Get-Location) -ChildPath "orphans-$timestamp.csv"
}

if ($ArchivePath -ne "") {
    $ArchivePath = Join-Path -Path (Get-Location) -ChildPath $ArchivePath
}

Write-Output "Scanning vault at $VaultPath..."

# Get all media files with case-insensitive extension matching
$mediaFiles = Get-ChildItem -Path $VaultPath -Recurse -File | Where-Object {
    $Extensions -contains ($_.Extension.TrimStart(".").ToLower())
}

# Get all Markdown files
$mdFiles = Get-ChildItem -Path $VaultPath -Recurse -Include *.md -File

# Prepare orphan list
$orphans = @()

foreach ($media in $mediaFiles) {
    $fileName = $media.Name
    $escapedFileName = [regex]::Escape($fileName)
    $wikiPattern = "!\[\[\s*$escapedFileName\s*\]\]"
    $mdPattern = "!\[.*?\]\(.*?$escapedFileName.*?\)"
    $found = $false

    foreach ($mdFile in $mdFiles) {
        $content = Get-Content -LiteralPath $mdFile.FullName -Raw
        if ($content -match $wikiPattern -or $content -match $mdPattern) {
            $found = $true
            break
        }
    }

    if (-not $found) {
        $orphans += [PSCustomObject]@{
            FileName     = $media.Name
            Path         = $media.FullName
            Extension    = $media.Extension
            LastModified = $media.LastWriteTime
            FileSizeKB   = [math]::Round($media.Length / 1KB, 1)
                }
    }
}

# Output to CSV
if ($orphans.Count -gt 0) {
    $orphans | Export-Csv -Path $OutputPath -NoTypeInformation
    Write-Output "Orphaned media files found: $($orphans.Count)"
    Write-Output "Report saved to: $OutputPath"

    if ($MoveOrphans -and $ArchivePath -ne "") {
        if (-not (Test-Path -Path $ArchivePath)) {
            New-Item -Path $ArchivePath -ItemType Directory | Out-Null
            Write-Output "Created archive folder at: $ArchivePath"
        }

        foreach ($orphan in $orphans) {
            $destination = Join-Path -Path $ArchivePath -ChildPath $orphan.FileName
            Move-Item -Path $orphan.Path -Destination $destination -Force
            Write-Output "Moved: $($orphan.FileName)"
        }

        Write-Output "All orphaned files moved to archive: $ArchivePath"
        Write-Output "Total Files Moved: $($orphans.Count)"
    } elseif ($MoveOrphans -and $ArchivePath -eq "") {
        Write-Output "ArchivePath not specified. Skipping file move."
    }
} else {
    Write-Output "No orphaned media files found. Vault is clean."
}
