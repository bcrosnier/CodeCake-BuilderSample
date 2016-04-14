# This PowerShell module contains helpers to build and use the CodeCake builder project.

<#
 .Synopsis
  Prepares the CodeCake builder project for build.

 .Description
  Prepares the CodeCake builder project for build, by downloading nuget.exe and using it to
  restore packages for its solution.

 .Parameter BuilderSolutionDirectory
  The path to the directory containing the packages.config used by the CodeCake builder project

 .Parameter ToolsDirectory
  The path to the directory which should contain nuget.exe.
  It will be created if it does not exist.

 .Parameter NuGetDownloadUrl
  The URL pointing to the latest NuGet command line executable,
  from which to download the utility if required.
#>
Function Initialize-CodeCakeBuilder {
    param(
        [string]$builderSolutionDirectory = $PSScriptRoot,
        [string]$toolsDirectory = [io.path]::combine($PSScriptRoot, 'Tools'),
        [string]$nuGetDownloadUrl = 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe'
    )

    $builderPackagesConfig = [io.path]::combine($builderSolutionDirectory, 'packages.config')

    # Create Tools directory
    New-Item -ItemType Directory -Force $toolsDirectory | Out-Null

    # Download nuget.exe, if missing
    $nugetExe = Join-Path $toolsDirectory 'nuget.exe'
    if (!(Test-Path $nugetExe)) {
        Write-Verbose "Downloading nuget.exe to $nugetExe"
        Invoke-WebRequest -Uri "$nuGetDownloadUrl" -OutFile "$nugetExe"
        # Ensure nuget.exe was correctly downloaded
        if (!(Test-Path $nugetExe)) {
            Throw "Could not find nuget.exe after downloading: $nugetExe"
        }
    }

    # Restore the packages for the CodeCake builder solution
    &$nugetExe restore "$builderPackagesConfig" -SolutionDirectory "$builderSolutionDirectory"
}

<#
 .Synopsis
  Gets the path to msbuild.exe.

 .Description
  Gets the path to msbuild.exe, using the Windows registry, or fail.
#>
Function Get-MsBuild {
    # Find MSBuild for .NET 4
    $dotNetVersion = '4.0'
    $regKey = "HKLM:\software\Microsoft\MSBuild\ToolsVersions\$dotNetVersion"
    $regProperty = 'MSBuildToolsPath'
    $msbuildExe = join-path -path (Get-ItemProperty $regKey).$regProperty -childpath 'msbuild.exe'
    if (!(Test-Path $msbuildExe)) {
        Throw "msbuild.exe was not found in registry or does not exist at path: $msbuildExe"
    }
    return $msbuildExe
}

<#
 .Synopsis
  Builds the CodeCake builder project.

 .Description
  Calls MsBuild on the CodeCake builder project, and returns the path to the bulder binary.

 .Parameter ProjectFile
  The path to the .csproj file to build.

 .Parameter Configuration
  The build configuration name to use when building the CodeCake builder project (Debug, Release)
#>
Function Build-CodeCakeBuilder {
    param(
        [string]$projectFile = [io.path]::combine($PSScriptRoot, 'CodeCakeBuilder.csproj'),
        [string]$configuration = 'Release'
    )
    $msbuildExe = Get-MsBuild
    $msBuildConfigParam = "/p:Configuration=$configuration"

    & $msbuildExe "$projectFile" $msBuildConfigParam | %{ Write-Verbose $_; }

    $projectDir = [io.path]::GetDirectoryName($projectFile)
    
    $projectBaseName = [io.path]::GetFileNameWithoutExtension($projectFile)
    $outFileName = "$projectBaseName.exe"

    $outputFile = [io.path]::combine($projectDir, 'bin', $configuration, $outFileName)

    if (!(Test-Path $outputFile)) { Throw "Could not find output file: $outputFile" }

    return $outputFile
}

<#
 .Synopsis
  Builds and invokes the CodeCake builder project.

 .Description
  Builds the CodeCake builder project with MsBuild, then invokes the resulting binary.

 .Parameter Configuration
  The build configuration name to use when building the CodeCake builder project (Debug, Release)

 .Parameter Target
  The name of the target to invoke in the CodeCake builder project.
#>
Function Invoke-CodeCakeBuilder {
    param(
        [string]$configuration = 'Release',
        [parameter(mandatory=$false, ValueFromRemainingArguments=$true)]$RemainingArgs
    )
    $builderExe = Build-CodeCakeBuilder -configuration $configuration
    
    Write-Verbose "Calling: $builderExe $RemainingArgs"

    & $builderExe $RemainingArgs
}

export-modulemember -function Initialize-CodeCakeBuilder
export-modulemember -function Invoke-CodeCakeBuilder