# 📁 Folder Copy + SHA1 Verification Tool

A PowerShell script for copying folders and verifying that the copied files match the originals using SHA1 checksums.

This tool is designed for archival, digitization, vendor scan, SharePoint/OneDrive, physical media, and network drive transfer workflows.

---

## ✨ Features

* Copies files from one folder to another
* Preserves nested folder structures
* Copies empty folders
* Does **not** move or delete original files
* Creates a SHA1 manifest for the source folder
* Creates a SHA1 manifest for the destination folder
* Compares source and destination checksums
* Creates a final CSV verification report
* Includes progress bars during checksum creation and comparison
* Saves all reports to the Desktop
* Handles pasted paths with quotation marks or ending backslashes
* Captures Robocopy exit codes and warns if a serious copy error occurs
* Creates timestamped report files so older reports are not overwritten

---

## 🧰 Requirements

* Windows computer
* PowerShell
* Access to the source folder
* Permission to write to the destination folder
* Enough storage space in the destination location

PowerShell and Robocopy are included with Windows, so no additional software is required.

---

## 📦 Common Uses

This script can be used to copy and verify files from:

* External hard drives
* Flash drives
* Local computer folders
* Network drives
* Synced SharePoint or OneDrive folders
* Vendor scan deliveries
* Digitization project folders
* Physical media, if readable by the computer

---

## 🚫 What This Script Does Not Do

This script does **not**:

* Delete files
* Move files
* Rename files
* Change file contents
* Upload files to the cloud
* Replace a digital preservation system

It is a copy and verification tool.

---

## ⚠️ Important Notes

* The source folder must already exist. If the source path is incorrect, the script will stop before copying anything.
* The destination folder will be created if it does not already exist.
* When prompted, type `COPY` in all capital letters to begin.
* Each report includes a date and time in the file name so older reports are not overwritten.
* The script copies file data, attributes, and timestamps.
* The script does not copy advanced security permissions, ownership metadata, or auditing information.
* For the cleanest verification report, use an empty destination folder when possible.

---

## 📝 Saving the Script

1. Open **Notepad**.
2. Paste the PowerShell script.
3. Click **File > Save As**.
4. Name the file:

```text
Copy-With-SHA1-Verification.ps1
```

5. Change **Save as type** to:

```text
All Files
```

6. Save it somewhere easy to find, such as the Desktop.

---

## ▶️ Running the Script

1. Right-click the `.ps1` file.
2. Select **Run with PowerShell**.
3. Paste the source folder path when prompted.
4. Paste the destination folder path when prompted.
5. Type:

```text
COPY
```

6. Press **Enter**.

`COPY` must be typed in all capital letters. If anything else is entered, the script will cancel and no files will be copied.

The script will then begin copying files and creating verification reports.

---

## 📍 Source and Destination Paths

The **source folder** is the folder you are copying from.

Example source paths:

```text
E:\Box001
```

```text
C:\Users\YourName\Desktop\TransferFolder
```

```text
C:\Users\YourName\OneDrive - Organization Name\Shared Folder
```

The **destination folder** is the folder you are copying to.

Example destination paths:

```text
J:\Digital_Projects\Vendor_Scans\Box001
```

```text
D:\Preservation_Copies\Box001
```

If the destination folder does not exist, the script will try to create it.

The script also cleans up pasted paths by removing quotation marks and ending backslashes. For example, these should both work:

```text
"J:\Digital_Projects\Vendor_Scans\Box001"
```

```text
J:\Digital_Projects\Vendor_Scans\Box001\
```

---

## 🪜 Workflow

The script runs in four main stages.

### 1. Copy Files and Folders

The script uses Robocopy to copy files, subfolders, empty folders, timestamps, and basic file attributes.

Robocopy is run with options that support restartable copying, limited retries, multithreaded copying, and logging.

### 2. Check the Robocopy Result

After the copy step, the script captures the Robocopy exit code.

Robocopy exit codes below `8` are not treated as serious errors by this script. If Robocopy returns exit code `8` or higher, the script displays a warning and points to the Robocopy log.

The script will still continue to the checksum steps so the final report can show what copied, what is missing, and what does not match.

### 3. Create SHA1 Manifests

The script creates two checksum manifests:

* one for the source folder
* one for the destination folder

Each manifest includes:

* relative file path
* full file path
* file size in bytes
* SHA1 checksum

### 4. Compare Checksums

The script compares source and destination files by relative path and SHA1 checksum.

It then creates a final CSV report showing the status of each file.

---

## 📊 Progress Bars

During checksum creation and comparison, the script displays progress bars in PowerShell.

The progress bars show:

* which step is running
* how many files have been processed
* the total number of files
* the current file being checked

Example:

```text
Creating destination SHA1 checksums
File 148 of 932 - image0148.tif
```

This is especially helpful for large transfers or slow network drives.

---

## 📄 Reports Created

All reports are saved to the Desktop.

Each report includes a timestamp in the file name so that reports from previous runs are not overwritten.

### Robocopy Log

A text log showing what happened during the copy.

Example file name:

```text
Copy_Robocopy_Log_2026-06-11_14-30-00.txt
```

Review this log if Robocopy reports a serious error.

### Source SHA1 Manifest

A CSV listing source files and their SHA1 checksums.

Example file name:

```text
Source_SHA1_Manifest_2026-06-11_14-30-00.csv
```

### Destination SHA1 Manifest

A CSV listing destination files and their SHA1 checksums.

Example file name:

```text
Destination_SHA1_Manifest_2026-06-11_14-30-00.csv
```

### Checksum Comparison Report

A CSV comparing source and destination files.

Example file name:

```text
Checksum_Compare_Report_SHA1_2026-06-11_14-30-00.csv
```

This is the main report to review.

---

## ✅ Reading the Comparison Report

Open the checksum comparison report in Excel and review the `Status` column.

| Status                      | Meaning                                                        |
| --------------------------- | -------------------------------------------------------------- |
| `MATCH`                     | The source and destination files match.                        |
| `MISMATCH`                  | The files exist in both locations, but their checksums differ. |
| `MISSING_IN_DESTINATION`    | The file exists in the source but not in the destination.      |
| `EXTRA_IN_DESTINATION`      | The file exists in the destination but not in the source.      |
| `ERROR_READING_SOURCE`      | The source file could not be read.                             |
| `ERROR_READING_DESTINATION` | The destination file could not be read.                        |

For a successful transfer, every source file should show:

```text
MATCH
```

---

## ➕ About `EXTRA_IN_DESTINATION`

`EXTRA_IN_DESTINATION` means the destination folder contains a file that was not found in the source folder.

This does **not always mean the copy failed**.

It usually means the destination folder already had files in it before the script was run.

To avoid extra-file warnings, start with an empty destination folder when possible.

---

## 🔁 If Something Fails

If the comparison report shows:

* `MISMATCH`
* `MISSING_IN_DESTINATION`
* `ERROR_READING_SOURCE`
* `ERROR_READING_DESTINATION`

do not delete the original files.

Recommended next steps:

1. Review the checksum comparison report.
2. Review the Robocopy log if the script reported a Robocopy warning.
3. Check that both the source and destination locations are still connected and accessible.
4. Run the script again with the same source and destination.
5. Review the new comparison report.

Robocopy can skip files that already copied successfully and retry files that failed.

---

## 🗂️ Nested Folders

The script preserves nested folder structures.

Example source:

```text
Box001
    Folder001
        image001.tif
        image002.tif
    Folder002
        document001.pdf
```

Example destination:

```text
Box001
    Folder001
        image001.tif
        image002.tif
    Folder002
        document001.pdf
```

---

## 📭 Empty Folders

The script copies empty folders.

If the source folder contains empty folders but no files, the Robocopy log will still document the folder copy. However, the SHA1 manifests may not contain file rows because checksums are only created for files, not folders.

---

## 🧾 About SHA1

SHA1 is a checksum algorithm used to create a digital fingerprint for a file.

If the source file and destination file have the same SHA1 checksum, the file contents match.

This script uses SHA1 for transfer verification. Some preservation workflows may require SHA256 instead, depending on institutional policy.

---

## ☁️ SharePoint and OneDrive Notes

If copying from SharePoint or OneDrive, it is best to fully download the files before running the script.

In File Explorer:

1. Right-click the SharePoint or OneDrive folder.
2. Select **Always keep on this device**.
3. Wait for OneDrive to finish syncing.
4. Run the script.

After the transfer is complete and verified, you can right-click the folder and choose **Free up space** if needed.

---

## 💾 Physical Media Notes

If copying from an external hard drive, flash drive, CD, DVD, or other physical media:

* Keep the media connected until the script finishes.
* Do not unplug the device during the transfer.
* Save the reports with the project documentation.
* If errors appear, check that the media is still connected and readable.
* Some errors may indicate damaged or unreadable files.

---

## 🌙 Tips for Large Transfers

* Copy one box or major folder at a time.
* Use an empty destination folder when possible.
* Keep the computer awake.
* Do not close PowerShell while the script is running.
* Expect destination checksums on network drives to take longer.
* Save all CSV reports with the project or accession documentation.
* Review the comparison report before deleting, moving, or changing anything.

---

## 🧡 Final Check

A successful transfer should show:

```text
MATCH
```

for every source file in the checksum comparison report.

If the script reports a Robocopy exit code of `8` or higher, review the Robocopy log even if some files show `MATCH` in the checksum report.
