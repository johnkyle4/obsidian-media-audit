Obsidian Media Audit Script
This PowerShell script helps you identify and manage orphaned media files (images, videos, audio, PDFs) in your Obsidian vault. It's designed to help reduce clutter and reclaim disk space by reporting files that are no longer linked in your notes.

Features
Identifies orphaned media files that are not referenced in any .md files.

Detects both ![[filename.jpg]] and Markdown-style ![](filename.jpg) links.

Generates timestamped CSV reports.

Optionally moves orphaned files to an archive folder for manual review or deletion.

Optimized for PowerShell 7+ and VSCode Tasks integration.

Usage
1. Run from PowerShell Terminal
powershell
Copy
Edit
pwsh -File "Find-Orphaned-Media.ps1" -VaultPath "C:\Path\To\Vault" -MoveOrphans -ArchivePath "C:\Path\To\Vault\_archived_orphans"
-VaultPath: Full path to your Obsidian vault.

-MoveOrphans: (Optional) Moves orphaned media files.

-ArchivePath: (Optional) Where orphaned files should be moved.

-OutputPath: (Optional) Custom output path for the CSV. If not provided, a timestamped file will be created in the current directory.

2. Run from VSCode
This project includes a .vscode/tasks.json file with two pre-configured tasks:

Run Orphaned Media Script (Report + Move): Generates a report and moves files to an archive folder.

Run Orphaned Media Script (Report Only): Generates a report without modifying files.

The script automatically opens the CSV report in VSCode when finished.

Example Report Output
FileName	Path	Extension	LastModified
image1.jpg	C:\Vault\media\image1.jpg	.jpg	2024-05-01 12:34 PM

Future Enhancements
Add support for excluding folders or file patterns

Add a progress bar for large vaults

Allow direct deletion of orphaned files with confirmation

License
MIT License. Use it, modify it, and share it freely.

