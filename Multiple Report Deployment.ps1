cd Report_Artifact
Get-ChildItem -Name
$W_N = Get-ChildItem -Name

cd $W_N
Get-ChildItem -Name
$contents = Get-ChildItem -Name
$type= $contents.GetType()

if($type.Name -eq "String"){
   $content = ,$contents
}
else{$content = $contents }

$len=$content.length


for($i=0; $i -le $len-1; $i++)
{
    $report_name = $content[$i]
    $applicationId = "$env:App_ID"
    $clientsec = "$env:Client_Secret" | ConvertTo-SecureString -AsPlainText -Force
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $applicationId, $clientsec

    Connect-PowerBIServiceAccount -ServicePrincipal -Credential $credential -TenantId "$env:Tenant_ID"

    $workspaceObject = ( Get-PowerBIWorkspace -Name "$env:WS_Name" )
    $groupid=$workspaceObject.id
    $sourcepath1= "$env:SystemDefaultWorkingDirectory"
    $sourcepath2= "Report_Artifact"
    $sourcepath3= $W_N
    $sourcepath4= $report_name
    $path = "$sourcepath1\$sourcepath2\$sourcepath3\$sourcepath4"
    $path.ToString()
    New-PowerBIReport -Path "$path" -Workspace $workspaceObject -ConflictAction CreateOrOverwrite

    $Split_Report_Name = $report_name.split(".")
    $R_N = $Split_Report_Name[0]

    ForEach ($dataset in (Get-PowerBIDataset -WorkspaceId $groupid ))
    {
        if ($dataset.name -eq $R_N)
        {
            $ID = $dataset.Id
        }
    }

    $uri = "groups/$groupid/datasets/$ID/Default.TakeOver"

    # Try to bind to a new gateway
    try {
        Invoke-PowerBIRestMethod -Url $uri -Method Post
        # Show error if we had a non-terminating error which catch won't catch
        if (-Not $?)
            {
                $errmsg = Resolve-PowerBIError -Last
                $errmsg.Message
            }
        }
    catch {
        $errmsg = Resolve-PowerBIError -Last
        $errmsg.Message
    }
    

    $workspace_name = "$env:WS_Name"
    $scriptpath = "$env:SystemDefaultWorkingDirectory\CSV_Artifact\Server_URL.csv"
    $server_name = python.exe "$env:SystemDefaultWorkingDirectory\CSV_Artifact\Python_Script.py" $R_N $workspace_name $scriptpath
    
  
    $postParams = @{
        updateDetails =@(
            @{
                name="Source"
                newValue=$server_name
            }
        )
    } | ConvertTo-Json

    Invoke-PowerBIRestMethod -Url "groups/$groupid/datasets/$ID/Default.UpdateParameters" -Method Post -Body $postParams | ConvertFrom-Json

}
Disconnect-PowerBIServiceAccount