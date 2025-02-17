#Function to get the winget command regarding execution context (User, System...)

Function Get-WingetCmd {

    #Get WinGet Path (if Admin context)
    # Includes Workaround for ARM64 (removed X64 and replaces it with a wildcard)
    $ResolveWingetPath = Resolve-Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*_*__8wekyb3d8bbwe" | Sort-Object { [version]($_.Path -replace '^[^\d]+_((\d+\.)*\d+)_.*', '$1') }

    if ($ResolveWingetPath) {
        #If multiple version, pick last one
        $WingetPath = $ResolveWingetPath[-1].Path
    }

    #If running under System or Admin context obtain Winget from Program Files
    if((([System.Security.Principal.WindowsIdentity]::GetCurrent().User) -eq "S-1-5-18") -or ($WingetPath)){
        if (Test-Path "$WingetPath\winget.exe") {
            $Script:Winget = "$WingetPath\winget.exe"
        }
    }else{
        #Get Winget Location in User context
        if (Test-Path "$env:LocalAppData\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe") {
            $Script:Winget = "$env:LocalAppData\Microsoft\WindowsApps\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\winget.exe"
        }
    }

    If(!($Script:Winget)){
        Write-ToLog "Winget not installed or detected !" "Red"
        return $false
    }

    #Run winget to list apps and accept source agrements (necessary on first run)
    & $Winget list --accept-source-agreements -s winget | Out-Null

    #Log Winget installed version
    $WingetVer = & $Winget --version
    Write-ToLog "Winget Version: $WingetVer"

    return $true

}
