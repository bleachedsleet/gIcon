### Active development on this project has [been moved to GitLab](https://gitlab.com/scratchfive/gIcon). This project will be archived once the migration is fully complete and will no longer be updated. This migration is made in protest of GitHub's [continuing support of ICE](https://www.theverge.com/2019/10/9/20906213/github-ice-microsoft-software-email-contract-immigration-nonprofit-donation). 

# gIcon
This is a simple little script for Windows that adds ever so slightly deeper integration with the Explorer shell. I got tired of Google ignoring basic conventions of storage providers on Windows by ignoring the File Explorer sidebar and instead using Quick Access pinning. This script changes all that by adding a Google Drive entry on the sidebar instead, just like OneDrive and Dropbox do. 

This not only looks pretty, but it also has the added benefit of browsing directory trees directly from the sidebar. 

![Example Image](https://raw.githubusercontent.com/scratchfive/gIcon/master/resources/demo.jpg)

## Usage
Run without parameters for help. This script has full support for custom Google Drive paths but will default to the same default path that Google uses which is in your USERPROFILE folder. 

```
gicon.bat [-r | -i] [ g | t | e ] [CUSTOM_PATH] [SERVICE_ID]

-r ........................ Remove icon
-i ........................ Install icon and select service. Possible services include "g" for Google Drive, "t" for Tresorit Drive and "e" for ExpanDrive

[CUSTOM_PATH] is an optional parameter for defining a custom location for the sync or mount point of the service

[SERVICE_ID] is an optional parameter for defining the name you wish to display in the sidebar. This is required for ExpanDrive and is currently ignored for all other services, though this may change in the future. 
```

This script is non invasive and works by making a few registry modifications. The icon used is the default Backup & Sync icon included in Google's client. This allows the icon to remain dynamically attached to sync status so you can get a quick overview of if your Drive is in sync or not. Everything the script does can be reversed safely.

Currently, Google Drive ("g"), Tresorit ("t") and ExpanDrive ("e") are fully supported services. ExpanDrive requires a service ID to be declared, which is the name you'd like to display in the File Explorer sidebar. This is because ExpanDrive can itself support multiple services so gIcon can't safely assume the name of the service you are adding. 

## A note on adding services
Although any service can now be added, the current implementation requires adding code to the source directly which is far from ideal. This will be changed in the next update to allow an easier and safer way of making service changes, but until then, this feature will remain officially unsupported and undocumented. 

## Known Issues
- Tresorit version bumps will break this script. I aim to fix this in the next release (the current version 0.8x is supported; all previous and future point releases will break this script).
- Currently, there is no way to remove individual service icons. It's all or nothing. This will be fixed soon.
- The providers database will not update on removal. This isn't horrible, but could lead to filesize swelling if used often.

## Looking Ahead
- Service ID detection for ExpanDrive. This can be accomplished by parsing volume names on mounts and should be included in the next release. This is being tracked in [an issue](https://github.com/scratchfive/gIcon/issues/1#issue-447819092)
- Remove database reliance. Services can be parsed directly from the registry keys. This eliminates the need for an additional file, increases portability and allows for targeted removal of individual services. I'm testing this in an internal build, but direct registry access through BATCH has a performance cost that is difficult to work around. The current method is much faster. 
