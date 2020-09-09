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

# Variable to receive the codes of the Power BI workspaces
$Workspace = Get-PowerBIWorkspace -Scope Organization -Include All

# Defines the directory and name of the file to be exported to the CSV file
$Dir = "YOUR_DIR\DATASOURCE_CSV.csv"

# Client ID obtained by creating an application in Azure
$clientId = "Your-ClientID"

# Your email to connect to the Power BI service
$username = "Your-Email" 

# Your password to connect to the PowerBI service
$password = "Your-Password"

$body = @{
    "resource" = “https://analysis.windows.net/powerbi/api";
    "client_id" = $clientId;
    "grant_type" = "password";
    "username" = $pbiUsername;
    "password" = $pbiPassword;
    "scope" = "openid"
}
$authResponse = Invoke-RestMethod -Uri $authUrl –Method POST -Body $body

# Loop for each workspace and for each dataset, get the data from the column below
Remove-Item $ExportFile -Force -ErrorAction SilentlyContinue
foreach($workspace in $Workspaces)
{

    # Variable to receive Power BI datasets
    $DataSets = Get-PowerBIDataset -WorkspaceId $workspace.Id #| where {$_.isRefreshable -eq $true}
    foreach($dataset in $DataSets)
    {
        # Variable of the dataset ID that will be placed in the API URL
        $DatasetID = $dataset.Id

        # URL that will be used for data extraction, with the DatasetID variable
        $restURL = "https://api.powerbi.com/v1.0/myorg/datasets/$DatasetID/datasources"

        $headers = @{
            "Content-Type" = "application/json";
            "Authorization" = $authResponse.token_type + " " + $authResponse.access_token
        }

        # Receive records via URL
        $Results = Invoke-PowerBIRestMethod -Url $restURL -Method Get | ConvertFrom-Json
        foreach($result in $Results.value)
        {
            $errorDetails = $result.serviceExceptionJson | ConvertFrom-Json -ErrorAction SilentlyContinue
            $ItemResult = New-Object psobject
            $ItemResult | Add-Member -Name "WorkspaceID"       -Value $workspace.Id                     -MemberType NoteProperty
            $ItemResult | Add-Member -Name "DatasetID"         -Value $dataset.Id                       -MemberType NoteProperty
            $ItemResult | Add-Member -Name "connectionDetails" -Value $result.connectionDetails         -MemberType NoteProperty
            $ItemResult | Add-Member -Name "connectionString"  -Value $result.connectionString          -MemberType NoteProperty
            $ItemResult | Add-Member -Name "datasourceId"      -Value $result.datasourceId              -MemberType NoteProperty
            $ItemResult | Add-Member -Name "datasourceType"    -Value $result.datasourceType            -MemberType NoteProperty
            $ItemResult | Add-Member -Name "gatewayId"         -Value $result.gatewayId                 -MemberType NoteProperty
            $ItemResult | Add-Member -Name "name"              -Value $result.name                      -MemberType NoteProperty
            $ItemResult | Add-Member -Name "database"          -Value $result.database                  -MemberType NoteProperty
            $ItemResult | Add-Member -Name "server"            -Value $result.server                    -MemberType NoteProperty
            $ItemResult | Add-Member -Name "url"               -Value $result.url                       -MemberType NoteProperty
            $ItemResult | Add-Member -Name "errorDescription"  -Value $errorDetails.errorDescription    -MemberType NoteProperty
            $ItemResult | Export-Csv -Path $Dir -Append -NoTypeInformation -Encoding UTF8
        }
    }
}   

# Disconnects from PowerBI service
Disconnect-PowerBIServiceAccount