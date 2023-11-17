Function Calculate-File-Hash($filePath, $hash) {
    $fileHash = Get-FileHash -Algorithm $hash -Path $filePath 
    return $fileHash
}

Function CheckFolder() {

    if (-not ($FolderLocationForFIM)) {
        Write-Host ""
        Write-Host "You must specify Path!" -ForegroundColor Red
        Write-Host ""
        exit
    }
    elseif (-not (Test-Path $FolderLocationForFIM -PathType Container)) {
        Write-Host ""
        Write-Host "Invalid Path!" -ForegroundColor Red
        Write-Host ""
        exit
    }

}
Function Define-Algorithm() {
    Write-Host ""
    Write-Host "Select which hash algorithm you want to use" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "    1 -> SHA1" -ForegroundColor Cyan
    Write-Host "    2 -> SHA256" -ForegroundColor Yellow
    Write-Host "    3 -> SHA384" -ForegroundColor Green
    Write-Host "    4 -> SHA512" -ForegroundColor DarkGray
    Write-Host "    5 -> MD5" -ForegroundColor DarkRed
    Write-Host ""

    $hashType = Read-Host -Prompt "Enter 1-5"
    $availableHashes = @('SHA1', 'SHA256', 'SHA384', 'SHA512','MD5')
    $allowedHashTypes = 1, 2, 3, 4, 5

    if ($hashType -eq "") {
        $hashType = "SHA512"
        return $hashType
    }

    elseif ($hashType -notin $allowedHashTypes) {
        Write-Host ""
        Write-Host "Invalid Number!" -ForegroundColor Red
        Write-Host ""
        exit
    }
     $hashType = $availableHashes[$hashType -1]
     return $hashType
}
Function Create-Base-Line($hash) {
    CheckFolder
    $files = Get-ChildItem -Path $FolderLocationForFIM
    foreach ($file in $files) {
        
        $fileHash = Calculate-File-Hash $file.FullName $hash
        "$($fileHash.Path)|$($fileHash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }
}

Function Baseline-Handling($process, $hash) {
    $baseLineExists = Test-Path -Path .\baseline.txt
    
    if ($baseLineExists) {
        if ($process -eq "process-a") {
            Remove-Item -Path .\baseline.txt
        }
    }
    elseif ($process -eq "process-b") {
        Write-Host ""
        Write-Host "No BaseLine file found!" -ForegroundColor Red
        Write-Host "BaseLine Creating Automatically"
        Create-Base-Line($hash)
    }
}

Write-Host ""
Write-Host " ~Welcome to File Integrity Monitoring Tool~ "
Write-Host ""
Write-Host ""
Write-Host " What would you like to do? " -ForegroundColor Magenta
Write-Host ""
Write-Host "     A -> Collect Baseline"  -ForegroundColor Yellow
Write-Host "     B -> Start Monitoring Files with current Baseline file" -ForegroundColor DarkYellow
Write-Host ""

$processType = Read-Host -Prompt "Enter 'A' or 'B'" 

clear
Write-Host ""
Write-Host " Enter the path of the folder you want to check" -ForegroundColor Magenta
Write-Host ""
$FolderLocationForFIM = Read-Host -Prompt "Enter PATH"

if ($processType -eq "A".ToUpper()) {

    CheckFolder
    Baseline-Handling("process-a")
    $hashTypeForA = Define-Algorithm
    
    Create-Base-Line($hashTypeForA)
    
    
    Write-Host ""
    Write-Host "baseline.txt created!" -ForegroundColor Green
    Write-Host ""
}
elseif ($processType -eq "B".ToUpper()) {
    clear
    CheckFolder
    $hashTypeForB = Define-Algorithm
    
    clear
    Write-Host ""
    Write-Host " Want to save the outputs? " -ForegroundColor Magenta
    Write-Host ""
    Write-Host "     Y -> Yes"  -ForegroundColor Green
    Write-Host "     N -> No"   -ForegroundColor Red
    Write-Host ""
    $checkSave = Read-Host -Prompt "Enter 'Y' or 'N'"
    
    clear
    Baseline-Handling "process-b" $hashTypeForB

    $fileHashDictionary = @{}
    $filePathsAndHashes = Get-Content -Path .\baseline.txt
    
    foreach ($f in $filePathsAndHashes) {
        $fileHashDictionary.add($f.Split("|")[0],$f.Split("|")[1])
    }

    Write-Host ""
    Write-Host "Monitoring Started..." -ForegroundColor Cyan 
    Write-Host ""
    
    while ($true) {
        Start-Sleep -Seconds 1
        $files = Get-ChildItem -Path $FolderLocationForFIM

        foreach ($f in $files) {
            $hash = Calculate-File-Hash $f.FullName $hashTypeForB

            if ($fileHashDictionary[$hash.Path] -eq $null) {
                Write-Host "$($hash.Path) has been created! [$(Get-Date)]" -ForegroundColor Green

                if ($checkSave -eq "Y".ToUpper()) {
                    Out-File -FilePath .\fim_output.log -Append -InputObject " File Created! $($hash.Path) - $($hash.Hash) - $(Get-Date)" 
                }
            }
            else {
                if ($fileHashDictionary[$hash.Path] -eq $hash.Hash) {
                }
                else {
                    Write-Host "$($hash.Path) has changed! [$(Get-Date)]" -ForegroundColor Yellow

                    if ($checkSave -eq "Y".ToUpper()) {
                        Out-File -FilePath .\fim_output.log -Append -InputObject " File Changed! $($hash.Path) - $($hash.Hash) - $(Get-Date)" 
                    }
                }
            }
        }

        foreach ($key in $fileHashDictionary.Keys) {
            $baselineFileStillExists = Test-Path -Path $key
            if (-Not $baselineFileStillExists) {
                Write-Host "$($key) has been deleted! [$(Get-Date)]" -ForegroundColor DarkRed -BackgroundColor Gray

                if ($checkSave -eq "Y".ToUpper()) {
                    Out-File -FilePath .\fim_output.log -Append -InputObject " File Deleted! $($hash.Path) - $($hash.Hash) - $(Get-Date)" 
                }
            }
        }
    }
}
else {
    Write-Host ""
    Write-Host "Invalid input!" -ForegroundColor Red 
}
