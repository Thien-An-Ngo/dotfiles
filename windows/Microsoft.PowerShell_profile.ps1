# PowerShell profile — mirrors ~/.zshrc for Windows

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Aliases
if (Get-Command lsd -ErrorAction SilentlyContinue)    { Set-Alias ls lsd }
if (Get-Command bat -ErrorAction SilentlyContinue)    { Set-Alias cat bat }
if (Get-Command rg -ErrorAction SilentlyContinue)     { function grep { rg @args } }
if (Get-Command fd -ErrorAction SilentlyContinue)     { function find { fd @args } }
if (Get-Command btop -ErrorAction SilentlyContinue)   { Set-Alias top btop }
if (Get-Command procs -ErrorAction SilentlyContinue)  { Set-Alias ps procs }
if (Get-Command yazi -ErrorAction SilentlyContinue)   { Set-Alias y yazi }
if (Get-Command tldr -ErrorAction SilentlyContinue)   { Set-Alias help tldr }
if (Get-Command gitui -ErrorAction SilentlyContinue)  { Set-Alias gu gitui }

Set-Alias g git
function glog { git log --oneline --graph --decorate @args }

# zoxide cd alias
Set-Alias cd z -Option AllScope -Force

# Local overrides
$localProfile = "$env:USERPROFILE\.config\powershell_profile.local.ps1"
if (Test-Path $localProfile) { . $localProfile }
