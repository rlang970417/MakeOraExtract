<#

#>
#
# Update configuration with directory pathing of your deployment
#
$MyCfg = (Get-ChildItem -Path .. -Filter "cfg.json" -Recurse -ErrorAction SilentlyContinue -Force).DirectoryName + "/cfg.json"
$MyAesFile = (Get-ChildItem -Path .. -Filter "AES.key" -Recurse -ErrorAction SilentlyContinue -Force).DirectoryName + "/AES.key"
((Get-Content -path $MyCfg -Raw) -replace './AES.key',"$MyAesFile") | Set-Content -Path $MyCfg
$MyPassFile = (Get-ChildItem -Path .. -Filter "Pass.txt" -Recurse -ErrorAction SilentlyContinue -Force).DirectoryName + "/Pass.txt"
((Get-Content -path $MyCfg -Raw) -replace './Pass.txt',"$MyPassFile") | Set-Content -Path $MyCfg
# I/O files
$MyInFile = (Get-ChildItem -Path .. -Filter "pstmt.sql" -Recurse -ErrorAction SilentlyContinue -Force).DirectoryName + "/pstmt.sql"
((Get-Content -path $MyCfg -Raw) -replace '../dat/in/pstmt.sql',"$MyInFile") | Set-Content -Path $MyCfg
$MyOutFile = (Get-ChildItem -Path .. -Filter "__stdnt_out_file.csv" -Recurse -ErrorAction SilentlyContinue -Force).DirectoryName + "/oracle_extract.csv"
((Get-Content -path $MyCfg -Raw) -replace '../dat/out/stdnt_out_file.csv',"$MyOutFile") | Set-Content -Path $MyCfg

#
# User Menu
# 
$MySrvrAddr = Read-Host -Prompt "What is your Oracle DB Server IP Address? "
$MySrvrPort = Read-Host -Prompt "What port is your Oracle DB listening on? "
$MySrvrSid = Read-Host -Prompt "What is the name of your Oracle DB SID or Service Name? "
$MySrvrUser = Read-Host -Prompt "What is your Oracle DB user name? "

# 
# Implement change
#
Write-Host "Updating deployed configuration file ..."
((Get-Content -path $MyCfg -Raw) -replace '192.168.1.212',"$MySrvrAddr") | Set-Content -Path $MyCfg
((Get-Content -path $MyCfg -Raw) -replace '1521',"$MySrvrPort") | Set-Content -Path $MyCfg
((Get-Content -path $MyCfg -Raw) -replace 'ZDBT01L',"$MySrvrSid") | Set-Content -Path $MyCfg
((Get-Content -path $MyCfg -Raw) -replace 'reporter',"$MySrvrUser") | Set-Content -Path $MyCfg
Write-Host "File's Done!"
