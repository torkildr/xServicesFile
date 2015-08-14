configuration ServicesFile_Example_Part1 {
    Import-DscResource -Name xServicesFile

    Node "localhost" {
        xServicesFile Http {
            Ensure = "Present"
            Protocol = "tcp"
            PortNumber = 80
            ServiceName = "http"
        }

        xServicesFile Leet1 {
            Ensure = "Present"
            Protocol = "tcp"
            PortNumber = 13371
            ServiceName = "leet"
            Comment = "Should be removed"
        }
    }
}

configuration ServicesFile_Example_Part2 {
    Import-DscResource -Name xServicesFile

    Node "localhost" {
        xServicesFile Leet2 {
            Ensure = "Absent"
            Protocol = "tcp"
            PortNumber = 13371
            ServiceName = "leet"
        }

        xServicesFile Leet3 {
            Ensure = "Present"
            Protocol = "tcp"
            PortNumber = 13372
            ServiceName = "leet"
            Comment = "Should be present after run"
        }
    }
}

#Get-DscResource

ServicesFile_Example_Part1
ServicesFile_Example_Part2

Start-DscConfiguration -Force -Wait -Verbose -Path .\ServicesFile_Example_Part1
Start-DscConfiguration -Force -Wait -Verbose -Path .\ServicesFile_Example_Part2
