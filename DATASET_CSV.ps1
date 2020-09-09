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

# Loop for each workspace and for each dataset, get the data from the column below
$DataSets =
ForEach ($workspace in $Workspace)
    {
    Write-Host $workspace.Name
    ForEach ($dataset in (Get-PowerBIDataset -Scope Organization -WorkspaceId $workspace.Id))
        {
        [pscustomobject]@{
            WorkspaceID = $workspace.Id
            DatasetID = $dataset.Id
            DatasetName = $dataset.Name
            ConfiguredBy = $dataset.ConfiguredBy
            DefaultRetentionPolicy = $dataset.DefaultRetentionPolicy
            AddRowsApiEnabled = $dataset.AddRowsApiEnabled
            Tables = $dataset.Tables
            WebUrl = $dataset.WebUrl
            Relationships = $dataset.Relationships
            Datasources = $dataset.Datasources
            DefaultMode = $dataset.DefaultMode
            IsRefreshable = $dataset.IsRefreshable
            IsEffectiveIdentityRequired = $dataset.IsEffectiveIdentityRequired
            IsEffectiveIdentityRolesRequired = $dataset.IsEffectiveIdentityRolesRequired
            IsOnPremGatewayRequired = $dataset.IsOnPremGatewayRequired
            TargetStorageMode = $dataset.TargetStorageMode
            ActualStorage = $dataset.ActualStorage
            CreatedDate = $dataset.CreatedDate
            ContentProviderType = $dataset.ContentProviderType
            }
        }
    }

# Defines the directory and name of the file to be exported to the CSV file
$Dir = "YOUR_DIR\DATASET_CSV.csv"

# Exports the result to the CSV file in the directory informed above
$Result | Export-Csv $Dir -NoTypeInformation -Encoding UTF8

# Disconnects from the session
Remove-PSSession $Session

# Disconnects from PowerBI service
Disconnect-PowerBIServiceAccount