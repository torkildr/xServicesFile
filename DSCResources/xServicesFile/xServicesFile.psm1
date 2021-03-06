$servicesFile = "${env:windir}\system32\drivers\etc\services"

# interesing groups: 1 (service name), 2 (port), 3 (protocol), 5 (alias) & 7 (comment (sans #))
$serviceGroups = "([^#\s]+)\s+(\d+)\/(tcp|udp)(\s+([^#$]+))?(#(.*)$)?"

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$ServiceName,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$PortNumber,

		[parameter(Mandatory = $true)]
		[ValidateSet("tcp","udp")]
		[System.String]
		$Protocol
	)

	$returnValue = @{
		ServiceName = [System.String] $ServiceName
		PortNumber = [System.UInt32] $PortNumber
		Protocol = [System.String] $Protocol
		Alias = [System.String] ""
		Comment = [System.String] ""
        Ensure = [System.String]
	}

    Write-Verbose ("Checking services file ""{0}""" -f $servicesFile)
    try {
        $services = (Get-Content $servicesFile) -match "^[^#]*$ServiceName\s+$PortNumber/$Protocol"

        if ($services.count -eq 1)
        {
            Write-Verbose "Found service match: $ServiceName $PortNumber/$Protocol"

            if ($services[0] -match $serviceGroups)
            {
                $returnValue["Alias"] = $Matches[5]
                $returnValue["Comment"] = $Matches[7]
            }
                        
            $returnValue["Ensure"] = "Present"
        }
        elseif ($services.Count -eq 0)
        {
            Write-Verbose "No service match: $ServiceName $PortNumber/$Protocol"

            $returnValue["Ensure"] = "Absent"
        }
        else
        {
            throw "Invalid servies file, found multiple entries of ""$ServiceName $PortNumber/$Protocol"""
        }
    } catch {
        $exception = $_    
        Write-Verbose ("An Exception occoured: {0}" -f $exception.message)

        while ($exception.InnerException -ne $null)
        {
            $exception = $exception.InnerException
            Write-Verbose ("Inner exception: {0}" -f $exception.message)
        }        
    }

	$returnValue
}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$ServiceName,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$PortNumber,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure = "Present",

		[parameter(Mandatory = $true)]
		[ValidateSet("tcp","udp")]
		[System.String]
		$Protocol,

		[System.String]
		$Alias = "",

		[System.String]
		$Comment = ""
	)

    # first remove from file
    Write-Verbose "Removing $ServiceName $PortNumber/$Protocol from services file"
    ((Get-Content $servicesFile) -notmatch "^[^#]*$ServiceName\s+$PortNumber/$Protocol" -notmatch "^\s*$") | Set-Content $servicesFile

    if ($Ensure -eq "Present")
    {
        Write-Verbose "Adding $ServiceName $PortNumber/$Protocol to services file"

        $entry = "${ServiceName}`t${PortNumber}/${Protocol}"

        if (![String]::IsNullOrWhiteSpace($Alias)) {
            $entry += "`t${Alias}"
        }

        if (![String]::IsNullOrWhiteSpace($Comment)) {
            $entry += "`t#${Comment}"
        }

        Add-Content -Path $servicesFile -Value $entry -Force -Encoding ASCII
        Write-Verbose "$ServiceName $PortNumber/$Protocol successfully added to services file"
    }
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$ServiceName,

		[parameter(Mandatory = $true)]
		[System.UInt32]
		$PortNumber,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[parameter(Mandatory = $true)]
		[ValidateSet("tcp","udp")]
		[System.String]
		$Protocol,

		[System.String]
		$Alias,

		[System.String]
		$Comment
	)

	$result = [System.Boolean]

    $services = (Get-Content $servicesFile) -match "^[^#]*$ServiceName\s+$PortNumber/$Protocol"
    $entryExists = $services.count -eq 1

	Write-Verbose "Testing for presense of $ServiceName $PortNumber/$Protocol"
    
    if ($entryExists)
    {
        Write-Verbose "Service is present"

        if ($Ensure -eq "Present") {
            $result = $true
        } else {
            $result = $false
        }
    }
    else
    {
        Write-Verbose "Service is absent"

        if ($Ensure -eq "Absent") {
            $result = $true
        } else {
            $result = $false
        }
    }

	$result
}


Export-ModuleMember -Function *-TargetResource

