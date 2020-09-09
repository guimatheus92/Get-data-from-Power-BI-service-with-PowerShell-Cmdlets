# To execute the script without agreeing with the execution policy
Set-ExecutionPolicy Bypass -Scope Process

# Import the Power BI admin module
Import-Module MicrosoftPowerBIMgmt.Admin

# Your email to connect to the Power BI service
$username = "Your-Email" 

# Your password to connect to the PowerBI service
$password = "Your-Password" | ConvertTo-SecureString -asPlainText -Force

# Run the credential according to the login and password above
$credential = New-Object System.Management.Automation.PSCredential($username, $password)

# Connect to the Power BI service using credentials
Connect-PowerBIServiceAccount -Credential $credential

$Session = New-PSSession -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Credential $credential `
    -Authentication Basic `
    -AllowRedirection

Import-PSSession $Session

# Variable to receive the codes of the Power BI workspaces
$Workspace = Get-PowerBIWorkspace -Scope Organization -Include All

# Variable to save the final result
$Result = @()

# Loop for each workspace, get the data from the column below
ForEach ($workspace in $Workspace)
    {
        # Create a new object that would store the information
        $ItemResult = New-Object System.Object
        $ItemResult | Add-Member -type NoteProperty -name WorkspaceID -value $workspace.Id
        $ItemResult | Add-Member -type NoteProperty -name WorkspaceName -value $workspace.Name
        $ItemResult | Add-Member -type NoteProperty -name IsReadOnly -value $workspace.IsReadOnly
        $ItemResult | Add-Member -type NoteProperty -name IsOnDedicatedCapacity -value $workspace.IsOnDedicatedCapacity
        $ItemResult | Add-Member -type NoteProperty -name CapacityId -value $workspace.CapacityId
        $ItemResult | Add-Member -type NoteProperty -name Description -value $workspace.Description
        $ItemResult | Add-Member -type NoteProperty -name WorkspaceType -value $workspace.Type
        $ItemResult | Add-Member -type NoteProperty -name State -value $workspace.State
        $ItemResult | Add-Member -type NoteProperty -name IsOrphaned -value $workspace.IsOrphaned

        # Put the item result and append it to the result object
        $Result +=$ItemResult
    }

# To check the final result on the screen
#$Result | Select WorkspaceID, WorkspaceName, IsReadOnly, IsOnDedicatedCapacity, CapacityId, Description, WorkspaceType, State, IsOrphaned, Users, Reports, Dashboards, Datasets, Dataflows, Workbooks | format-table -auto -wrap | Out-String      

# Defines the directory and name of the file to be exported to the CSV file
$Dir = "YOUR_DIR\WORKSPACE_CSV.csv"

# Exports the result to the CSV file in the directory informed above
$Result | Export-Csv $Dir -NoTypeInformation -Encoding UTF8

# Disconnects from the session
Remove-PSSession $Session

# Disconnects from PowerBI service
Disconnect-PowerBIServiceAccount