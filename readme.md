# gIcon
This is a simple little script for Windows that adds ever so slightly deeper integration with the Explorer shell. I got tired of Google ignoring basic conventions of storage providers on Windows by ignoring the File Explorer sidebar and instead using Quick Access pinning. This script changes all that by adding a Google Drive entry on the sidebar instead, just like OneDrive and Dropbox do. 

This not only looks pretty, but it also has the added benefit of browsing directory trees directly from the sidebar. 

![Example Image](https://raw.githubusercontent.com/scratchfive/gIcon/master/resources/demo.jpg)

## Usage
Run without parameters for help. This script has full support for custom Google Drive paths but will default to the same default path that Google uses which is in your USERPROFILE folder. 

```
gicon.bat [-i | -r] "CUSTOM_PATH"
```

This script is non invasive and works by making a few registry modifications. The icon used is the default Backup & Sync icon included in Google's client. This allows the icon to remain dynamically attached to sync status so you can get a quick overview of if your Drive is in sync or not. Everything the script does can be reversed safely.