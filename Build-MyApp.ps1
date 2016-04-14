$VerbosePreference = 'Continue' # Enable Verbose
$ErrorActionPreference = 'Stop' # Stop on error

# Force working directory to script directory
Push-Location $PSScriptRoot

# Load module
if(Get-Module -name 'CodeCakeBuilder'){ Remove-Module CodeCakeBuilder }
Import-Module .\CodeCakeBuilder\CodeCakeBuilder.psm1

# Bootstrap
Initialize-CodeCakeBuilder

# Build & call
Invoke-CodeCakeBuilder -NoInteraction -target=Default

# Restore previous working directory
Pop-Location