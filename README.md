# xServicesFile DSC Resource
This repository contains a custom DSC Resource.

The resource is highly inspired by the "HostsFile" DSC Resource which at one point in time could be found at [github.com/PowerShellOrg/DSC](https://github.com/PowerShellOrg/DSC).

## What?
This DSC Resources is inteded to use for modifying the "services" file in Windows (typically found under C:\Windows\system32\drivers\etc\services).

**In its current condition the resource should be viewed as experimental.**

## How?
A simple feature complete example would be something like this.
```PowerShell
        xServicesFile Leet {
            Ensure = "Present"
            ServiceName = "leet"
            PortNumber = 1337
            Protocol = "tcp"
            Alias = "altname"
            Comment = "Comment about service"
        }
```
Also, be sure to check out the Examples-folder

## Todo?
Yes, very much so. I am happy to accept pull requests

 - Testing
 - Path to Services file as parameter

## License?
Yeah, sure, why not.

The resource is licensed under the MIT License, and is made by Torkild Retvedt.