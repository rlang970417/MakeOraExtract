# Global Vars
$ROOT_DIR=split-path (split-path $MyInvocation.MyCommand.Path -parent) -parent
$OracleDLLPath="$ROOT_DIR/lib/Oracle.ManagedDataAccess.dll"
$cfgFile="$ROOT_DIR/etc/cfg.json"
$sqlFile="$ROOT_DIR/dat/in/pstmt.sql"

# Functions
function Check-PSVersion
{
    if (($PSVersionTable.PSVersion).Major -ne 7)
    {
        Write-Host "This is an unsupported version of PowerShell. Install the following : "
        Write-Host "https://github.com/PowerShell/PowerShell"
        exit
    }
}

function Get-Cfg
{
    # Verify our configuration libray
	if (!(Test-Path $OracleDLLPath))
    {
        Write-Host "Check your installtion directory of `lib`. Missing Oracle DLL file."
        exit
    }
	
    # Verify our configuration file exists
    if (!(Test-Path $cfgFile))
    {
        Write-Host "Check your installtion directory of `etc`. Missing JSON file."
        exit
    }

    # Verify our SQL prepared statement file exists
    if (!(Test-Path $sqlFile))
    {
        Write-Host "Check your installtion directory of `dat`. Missing Prepared SQL file."
        exit
    }
	
	return Get-Content -Path $cfgFile -Raw | ConvertFrom-Json
}

function Get-KeyFile
{
    param
    (
        [Parameter (Mandatory = $true)] [String]$KeyFile
    )

    # Verify our configuration files exists
    if (!(Test-Path $KeyFile))
    {
        Write-Host "File missing : $KeyFile . "
        Write-Host "Please generate one with : $ROOT_DIR/lib/MakeAESFiles.psm1 ."
        exit
    }

        return Get-Content $KeyFile
}

function Get-PassFile
{
    param
    (
        [Parameter (Mandatory = $true)] [String]$KeyFile,
        [Parameter (Mandatory = $true)] [String]$PassFile
    )

    # Verify our configuration files exists
    if (!(Test-Path $KeyFile))
    {
        Write-Host "File missing : $KeyFile ."
        Write-Host "Please generate one with : $ROOT_DIR/lib/MakeAESFiles.psm1 ."
        exit
    }

    if (!(Test-Path $PassFile))
    {
        Write-Host "File missing : $PassFile . "
        Write-Host "Please generate one with : $ROOT_DIR/lib/MakeAESFiles.psm1 ."
        exit
    }

    $readKey = Get-KeyFile $KeyFile
    $readSecStr = Get-Content $PassFile | ConvertTo-SecureString -Key $readKey
    return ConvertFrom-SecureString -SecureString $readSecStr -AsPlainText
}
# Define our script variables from our JSON configuration file
function Get-Conn
{   
    param
    (
        [Parameter (Mandatory = $true)] [String]$Server,
	    [Parameter (Mandatory = $true)] [String]$Port,
	    [Parameter (Mandatory = $true)] [String]$Service,
	    [Parameter (Mandatory = $true)] [String]$DBuser,
	    [Parameter (Mandatory = $true)] [String]$DBpass
    )
    $datasource = " (DESCRIPTION =
                     (ADDRESS =
                     (PROTOCOL = TCP)
                     (HOST  = $Server)(PORT = $Port))
                     (CONNECT_DATA = (SERVER =  DEDICATED)
                     (SERVICE_NAME = $Service)
                     (METHOD =  BASIC)
                     (RETRIES = 180)
                     (DELAY = 5))))"
    $username = $DBuser
    $password = $DBpass

    #Create the connection string
    return $connectionstring = 'User Id=' + $username + ';Password=' + $password + ';Data Source=' + $datasource 
}

function Make-Extract
{
    param
    (
        [Parameter (Mandatory = $true)] [String]$ConnString,
        [Parameter (Mandatory = $true)] [String]$PreparedStmt,
        [Parameter (Mandatory = $true)] [String]$ExtractFile
    )
    #Load Required Types and modules
    Add-Type -Path $OracleDLLPath

    #Create the connection object
    $con = New-Object Oracle.ManagedDataAccess.Client.OracleConnection($ConnString)

    #Create a command and configure it
    $cmd = $con.CreateCommand()
    $cmd.CommandText = $PreparedStmt
    $cmd.CommandTimeout = 3600 #Seconds
    $cmd.FetchSize = 10000000 #10MB
	
    #Creates a data adapter for the command
    $da = New-Object Oracle.ManagedDataAccess.Client.OracleDataAdapter($cmd);

    #The Data adapter will fill this DataTable
    $resultSet = New-Object System.Data.DataTable

    #Only here the query is sent and executed in Oracle 
    [void]$da.fill($resultSet)
  
    #Close the connection
    $con.Close()

    # Export out dataset to our output file
    $resultSet | Export-Csv $ExtractFile -NoTypeInformation
}

function Main
{
    # Perform system check
    Check-PSVersion
    
    # Define and init our variable arguments
    $jsonCfg = Get-Cfg
	
    #$dbPass = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromBase64String($jsonCfg.database.pass))
    $dbPass = Get-PassFile $jsonCfg.file.aes $jsonCfg.file.pass
    $myConn = Get-Conn $jsonCfg.database.server $jsonCfg.database.port $jsonCfg.database.sid $jsonCfg.database.user $dbPass
    $queryStatment = [IO.File]::ReadAllText($sqlFile) #Be careful not to terminate it with a semicolon, it doesn't like it
	
    # Extract our data from Oracle
    Make-Extract $myConn $queryStatment $jsonCfg.file.output
}

Main
