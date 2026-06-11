Write-Host ""
Write-Host "Folder Copy + SHA1 Checksum Verification Tool" -ForegroundColor Cyan
Write-Host "---------------------------------------------"
Write-Host "This script copies files from one folder to another."
Write-Host "It does NOT move or delete anything."
Write-Host "It also creates SHA1 checksum reports to verify the copy."
Write-Host ""

# Ask user for paths
$source = Read-Host "Paste the SOURCE folder path"
$destination = Read-Host "Paste the DESTINATION folder path"

# Remove quotation marks if the user pasted paths with quotes
# Also remove any ending backslash so relative paths calculate cleanly
$source = $source.Trim('"').TrimEnd('\')
$destination = $destination.Trim('"').TrimEnd('\')

# Check that the source exists
if (-not (Test-Path $source)) {
    Write-Host ""
    Write-Host "ERROR: The source folder does not exist." -ForegroundColor Red
    Write-Host "Please check the path and try again."
    Write-Host "Source entered: $source"
    Write-Host ""
    exit
}

# Create the destination folder if it does not already exist
if (-not (Test-Path $destination)) {
    Write-Host ""
    Write-Host "Destination folder does not exist yet. Creating it now..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
}

# Create timestamped report file names
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$desktop = [Environment]::GetFolderPath("Desktop")

$robocopyLog = Join-Path $desktop "Copy_Robocopy_Log_$timestamp.txt"
$sourceManifest = Join-Path $desktop "Source_SHA1_Manifest_$timestamp.csv"
$destinationManifest = Join-Path $desktop "Destination_SHA1_Manifest_$timestamp.csv"
$compareReport = Join-Path $desktop "Checksum_Compare_Report_SHA1_$timestamp.csv"

Write-Host ""
Write-Host "Source folder:"
Write-Host $source
Write-Host ""
Write-Host "Destination folder:"
Write-Host $destination
Write-Host ""
Write-Host "Reports will be saved to your Desktop."
Write-Host ""

Write-Host "This process may take a long time for large folders." -ForegroundColor Yellow
Write-Host "Please do not close this PowerShell window while it is running."
Write-Host ""

$confirm = Read-Host "Type COPY to start"

if ($confirm -ne "COPY") {
    Write-Host ""
    Write-Host "Cancelled. No files were copied."
    Write-Host ""
    exit
}

Write-Host ""
Write-Host "STEP 1: Copying files and folders..." -ForegroundColor Yellow
Write-Host ""

# Robocopy notes:
# /E copies all subfolders, including empty folders
# /Z uses restartable mode
# /R:3 retries failed files 3 times
# /W:10 waits 10 seconds between retries
# /MT:8 copies multiple files at once
# /COPY:DAT copies file Data, Attributes, and Timestamps
# /DCOPY:DAT copies folder Data, Attributes, and Timestamps
# /TEE shows output on screen and saves it to the log
robocopy $source $destination /E /Z /R:3 /W:10 /MT:8 /COPY:DAT /DCOPY:DAT /TEE /LOG:$robocopyLog

# Save Robocopy exit code
$robocopyExitCode = $LASTEXITCODE

Write-Host ""

if ($robocopyExitCode -ge 8) {
    Write-Host "WARNING: Robocopy reported a serious error." -ForegroundColor Red
    Write-Host "Robocopy exit code: $robocopyExitCode"
    Write-Host "Please review the Robocopy log carefully:"
    Write-Host $robocopyLog
    Write-Host ""
    Write-Host "The script will still continue with checksum verification so you can see exactly what copied and what did not."
}
else {
    Write-Host "Robocopy completed without a serious error." -ForegroundColor Green
    Write-Host "Robocopy exit code: $robocopyExitCode"
}

Write-Host ""
Write-Host "STEP 2: Creating SHA1 checksum manifest for the source folder..." -ForegroundColor Yellow
Write-Host ""

$sourceFiles = @(Get-ChildItem -Path $source -File -Recurse -ErrorAction SilentlyContinue)
$sourceTotal = $sourceFiles.Count
$sourceCounter = 0

$sourceHashes = foreach ($file in $sourceFiles) {
    $sourceCounter++

    if ($sourceTotal -gt 0) {
        $percent = [math]::Round(($sourceCounter / $sourceTotal) * 100, 2)
    }
    else {
        $percent = 100
    }

    Write-Progress `
        -Activity "Creating source SHA1 checksums" `
        -Status "File $sourceCounter of $sourceTotal - $($file.Name)" `
        -PercentComplete $percent

    try {
        $relativePath = $file.FullName.Substring($source.Length).TrimStart('\')
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA1

        [PSCustomObject]@{
            RelativePath = $relativePath
            FullPath     = $file.FullName
            SizeBytes    = $file.Length
            SHA1         = $hash.Hash
        }
    }
    catch {
        [PSCustomObject]@{
            RelativePath = $file.FullName.Substring($source.Length).TrimStart('\')
            FullPath     = $file.FullName
            SizeBytes    = $file.Length
            SHA1         = "ERROR_READING_FILE"
        }
    }
}

Write-Progress -Activity "Creating source SHA1 checksums" -Completed

$sourceHashes | Export-Csv -Path $sourceManifest -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Source checksum manifest created:"
Write-Host $sourceManifest

Write-Host ""
Write-Host "STEP 3: Creating SHA1 checksum manifest for the destination folder..." -ForegroundColor Yellow
Write-Host ""

$destinationFiles = @(Get-ChildItem -Path $destination -File -Recurse -ErrorAction SilentlyContinue)
$destinationTotal = $destinationFiles.Count
$destinationCounter = 0

$destinationHashes = foreach ($file in $destinationFiles) {
    $destinationCounter++

    if ($destinationTotal -gt 0) {
        $percent = [math]::Round(($destinationCounter / $destinationTotal) * 100, 2)
    }
    else {
        $percent = 100
    }

    Write-Progress `
        -Activity "Creating destination SHA1 checksums" `
        -Status "File $destinationCounter of $destinationTotal - $($file.Name)" `
        -PercentComplete $percent

    try {
        $relativePath = $file.FullName.Substring($destination.Length).TrimStart('\')
        $hash = Get-FileHash -Path $file.FullName -Algorithm SHA1

        [PSCustomObject]@{
            RelativePath = $relativePath
            FullPath     = $file.FullName
            SizeBytes    = $file.Length
            SHA1         = $hash.Hash
        }
    }
    catch {
        [PSCustomObject]@{
            RelativePath = $file.FullName.Substring($destination.Length).TrimStart('\')
            FullPath     = $file.FullName
            SizeBytes    = $file.Length
            SHA1         = "ERROR_READING_FILE"
        }
    }
}

Write-Progress -Activity "Creating destination SHA1 checksums" -Completed

$destinationHashes | Export-Csv -Path $destinationManifest -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Destination checksum manifest created:"
Write-Host $destinationManifest

Write-Host ""
Write-Host "STEP 4: Comparing source and destination checksums..." -ForegroundColor Yellow
Write-Host ""

$sourceByPath = @{}
foreach ($item in $sourceHashes) {
    $sourceByPath[$item.RelativePath] = $item
}

$destinationByPath = @{}
foreach ($item in $destinationHashes) {
    $destinationByPath[$item.RelativePath] = $item
}

$allPaths = @($sourceByPath.Keys + $destinationByPath.Keys) | Sort-Object -Unique
$compareTotal = $allPaths.Count
$compareCounter = 0

$comparison = foreach ($path in $allPaths) {
    $compareCounter++

    if ($compareTotal -gt 0) {
        $percent = [math]::Round(($compareCounter / $compareTotal) * 100, 2)
    }
    else {
        $percent = 100
    }

    Write-Progress `
        -Activity "Comparing checksums" `
        -Status "File $compareCounter of $compareTotal - $path" `
        -PercentComplete $percent

    $src = $sourceByPath[$path]
    $dst = $destinationByPath[$path]

    if ($null -eq $src) {
        $status = "EXTRA_IN_DESTINATION"
    }
    elseif ($null -eq $dst) {
        $status = "MISSING_IN_DESTINATION"
    }
    elseif ($src.SHA1 -eq "ERROR_READING_FILE") {
        $status = "ERROR_READING_SOURCE"
    }
    elseif ($dst.SHA1 -eq "ERROR_READING_FILE") {
        $status = "ERROR_READING_DESTINATION"
    }
    elseif ($src.SHA1 -eq $dst.SHA1) {
        $status = "MATCH"
    }
    else {
        $status = "MISMATCH"
    }

    [PSCustomObject]@{
        RelativePath         = $path
        Status               = $status
        SourceSizeBytes      = if ($src) { $src.SizeBytes } else { "" }
        DestinationSizeBytes = if ($dst) { $dst.SizeBytes } else { "" }
        SourceSHA1           = if ($src) { $src.SHA1 } else { "" }
        DestinationSHA1      = if ($dst) { $dst.SHA1 } else { "" }
    }
}

Write-Progress -Activity "Comparing checksums" -Completed

$comparison | Export-Csv -Path $compareReport -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "DONE!" -ForegroundColor Green
Write-Host ""

Write-Host "Files created on your Desktop:"
Write-Host ""
Write-Host "Robocopy log:"
Write-Host $robocopyLog
Write-Host ""
Write-Host "Source SHA1 manifest:"
Write-Host $sourceManifest
Write-Host ""
Write-Host "Destination SHA1 manifest:"
Write-Host $destinationManifest
Write-Host ""
Write-Host "Checksum comparison report:"
Write-Host $compareReport
Write-Host ""

$summary = $comparison | Group-Object Status | Select-Object Name, Count

Write-Host "Checksum Summary:"
$summary | Format-Table -AutoSize

Write-Host ""
Write-Host "What you want to see: MATCH for every source file." -ForegroundColor Green
Write-Host "If you see MISMATCH, MISSING_IN_DESTINATION, ERROR_READING_SOURCE, or ERROR_READING_DESTINATION, review the comparison report." -ForegroundColor Yellow
Write-Host "If you see EXTRA_IN_DESTINATION, that means the destination folder already had files that were not in the source folder."
Write-Host ""

if ($robocopyExitCode -ge 8) {
    Write-Host "Reminder: Robocopy reported a serious error, so please review the Robocopy log too." -ForegroundColor Red
    Write-Host $robocopyLog
    Write-Host ""
}

Write-Host "You may now close this window."
Write-Host ""
