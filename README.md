\# 📁 Folder Copy + SHA1 Verification Tool



A PowerShell script for copying folders and verifying that the copied files match the originals using SHA1 checksums.



This tool is designed for archival, digitization, vendor scan, SharePoint/OneDrive, physical media, and network drive transfer workflows.



\---



\## ✨ Features



\* Copies files from one folder to another

\* Preserves nested folder structures

\* Copies empty folders

\* Does \*\*not\*\* move or delete original files

\* Creates a SHA1 manifest for the source folder

\* Creates a SHA1 manifest for the destination folder

\* Compares source and destination checksums

\* Creates a final CSV verification report

\* Includes progress bars during checksum creation and comparison

\* Saves all reports to the Desktop



\---



\## 🧰 What You Need



\* Windows computer

\* PowerShell

\* Access to the source folder

\* Permission to write to the destination folder

\* Enough storage space in the destination location



PowerShell is included with Windows, so no additional software is required.



\---



\## 📦 Common Uses



This script can be used to copy and verify files from:



\* External hard drives

\* Flash drives

\* Local computer folders

\* Network drives

\* Synced SharePoint or OneDrive folders

\* Vendor scan deliveries

\* Digitization project folders



\---



\## 🚫 What This Script Does Not Do



This script does \*\*not\*\*:



\* Delete files

\* Move files

\* Rename files

\* Change file contents

\* Upload files to the cloud

\* Replace a digital preservation system



It is a copy and verification tool.



\---



\## 📝 Saving the Script



1\. Open \*\*Notepad\*\*.

2\. Paste the PowerShell script.

3\. Click \*\*File > Save As\*\*.

4\. Name the file:



```text

Copy-With-SHA1-Verification.ps1

```



5\. Change \*\*Save as type\*\* to:



```text

All Files

```



6\. Save it somewhere easy to find, such as the Desktop.



\---



\## ▶️ Running the Script



1\. Right-click the `.ps1` file.

2\. Select \*\*Run with PowerShell\*\*.

3\. Paste the source folder path when prompted.

4\. Paste the destination folder path when prompted.

5\. Type:



```text

COPY

```



6\. Press \*\*Enter\*\*.



The script will then begin copying files and creating verification reports.



\---



\## 📍 Source and Destination Paths



The \*\*source folder\*\* is the folder you are copying from.



Example source paths:



```text

E:\\Box001

```



```text

C:\\Users\\YourName\\Desktop\\TransferFolder

```



```text

C:\\Users\\YourName\\OneDrive - Organization Name\\Shared Folder

```



The \*\*destination folder\*\* is the folder you are copying to.



Example destination paths:



```text

J:\\Digital\_Projects\\Vendor\_Scans\\Box001

```



```text

D:\\Preservation\_Copies\\Box001

```



If the destination folder does not exist, the script will try to create it.



\---



\## 🪜 Workflow



The script runs in four main stages:



\### 1. Copy Files and Folders



The script uses Robocopy to copy files, subfolders, empty folders, timestamps, and basic file attributes.



\### 2. Create Source SHA1 Manifest



The script calculates a SHA1 checksum for every file in the source folder.



\### 3. Create Destination SHA1 Manifest



The script calculates a SHA1 checksum for every file in the destination folder.



\### 4. Compare Checksums



The script compares the source and destination checksums and creates a final CSV report.



\---



\## 📊 Progress Bars



During checksum creation and comparison, the script displays progress bars in PowerShell.



The progress bars show:



\* Which step is running

\* How many files have been processed

\* The total number of files

\* The current file being checked



Example:



```text

Creating destination SHA1 checksums

File 148 of 932 - image0148.tif

```



This is especially helpful for large transfers or slow network drives.



\---



\## 📄 Reports Created



All reports are saved to the Desktop.



\### Robocopy Log



A text log showing what happened during the copy.



```text

Copy\_Robocopy\_Log\_2026-06-11\_14-30-00.txt

```



\### Source SHA1 Manifest



A CSV listing source files and their SHA1 checksums.



```text

Source\_SHA1\_Manifest\_2026-06-11\_14-30-00.csv

```



\### Destination SHA1 Manifest



A CSV listing destination files and their SHA1 checksums.



```text

Destination\_SHA1\_Manifest\_2026-06-11\_14-30-00.csv

```



\### Checksum Comparison Report



A CSV comparing source and destination files.



```text

Checksum\_Compare\_Report\_SHA1\_2026-06-11\_14-30-00.csv

```



This is the main report to review.



\---



\## ✅ Reading the Comparison Report



Open the checksum comparison report in Excel and review the `Status` column.



| Status                      | Meaning                                                        |

| --------------------------- | -------------------------------------------------------------- |

| `MATCH`                     | The source and destination files match.                        |

| `MISMATCH`                  | The files exist in both locations, but their checksums differ. |

| `MISSING\_IN\_DESTINATION`    | The file exists in the source but not in the destination.      |

| `EXTRA\_IN\_DESTINATION`      | The file exists in the destination but not in the source.      |

| `ERROR\_READING\_SOURCE`      | The source file could not be read.                             |

| `ERROR\_READING\_DESTINATION` | The destination file could not be read.                        |



For a successful transfer, every file should show:



```text

MATCH

```



\---



\## 🔁 If Something Fails



If the report shows `MISMATCH`, `MISSING\_IN\_DESTINATION`, or a read error:



1\. Do not delete the original files.

2\. Run the script again with the same source and destination.

3\. Review the new comparison report.



Robocopy can skip files that already copied successfully and retry files that failed.



\---



\## 🗂️ Nested Folders



The script preserves nested folder structures.



Example source:



```text

Box001

&#x20;   Folder001

&#x20;       image001.tif

&#x20;       image002.tif

&#x20;   Folder002

&#x20;       document001.pdf

```



Example destination:



```text

Box001

&#x20;   Folder001

&#x20;       image001.tif

&#x20;       image002.tif

&#x20;   Folder002

&#x20;       document001.pdf

```



\---



\## 🧾 About SHA1



SHA1 is a checksum algorithm used to create a digital fingerprint for a file.



If the source file and destination file have the same SHA1 checksum, the file contents match.



This script uses SHA1 for transfer verification. Some preservation workflows may require SHA256 instead, depending on institutional policy.



\---



\## ☁️ SharePoint and OneDrive Notes



If copying from SharePoint or OneDrive, it is best to fully download the files before running the script.



In File Explorer:



1\. Right-click the SharePoint or OneDrive folder.

2\. Select \*\*Always keep on this device\*\*.

3\. Wait for OneDrive to finish syncing.

4\. Run the script.



After the transfer is complete and verified, you can right-click the folder and choose \*\*Free up space\*\* if needed.



\---



\## 💾 Physical Media Notes



If copying from an external hard drive, flash drive, CD, DVD, or other physical media:



\* Keep the media connected until the script finishes.

\* Do not unplug the device during the transfer.

\* Save the reports with the project documentation.

\* If errors appear, the media may be unreadable, damaged, or disconnected.



\---



\## 🌙 Tips for Large Transfers



\* Copy one box or major folder at a time.

\* Keep the computer awake.

\* Do not close PowerShell while the script is running.

\* Expect destination checksums on network drives to take longer.

\* Save all CSV reports with the project or accession documentation.

\* Review the comparison report before deleting, moving, or changing anything.



\---



\## 🧡 Final Check



A successful transfer should show:



```text

MATCH

```



for every file in the checksum comparison report.



