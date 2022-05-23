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
    $Split_Report_Name = $report_name.split(".")
    $R_N = $Split_Report_Name[0]

    $workspace_name = "$env:WS_Name"
    $scriptpath = "$env:SystemDefaultWorkingDirectory\CSV_Artifact\Server_URL.csv"
    $server_name = python.exe "$env:SystemDefaultWorkingDirectory\CSV_Artifact\Python_Script.py" $R_N $workspace_name $scriptpath
    
    if($server_name -eq "No1") 
    {
    echo "Report Not Found, Please Check Server_URL file again"
    exit 1
    }
    if($server_name -eq "No2") 
    {
    echo "Report Name is coming more than one time, Please Check Server_URL file again"
    exit 1
    }
}
