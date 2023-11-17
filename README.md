# File Integrity Monitor (FIM) PowerShell Script

<br>

## About 
This PowerShell script provides a basic File Integrity Monitoring (FIM) tool to monitor changes in files within a specified folder using hash algorithms. It allows you to create a baseline of file hashes and then monitor for any changes, additions, or deletions in real-time.
<br>
## How to Use

### Run script
After installing file, simply run `.\fim.ps1` in powershell. 

### Choose Action
Choose whether to collect a baseline or start monitoring files with the current baseline.
> If you don't have baseline already you can still select option B. This will automatically create for you.

### Specify Folder Path:
Enter the path of the folder you want to monitor.

### Choose Hash Algorithm:
Select the hash algorithm you want to use for file hashing.
> Default is SHA512.

### Save Outputs (Optional):
You can also save outputs in a log file.

### Monitoring:
The script will continuously monitor the specified folder for file changes based on the selected options.
