# MakeOraExtract

## Introduction

A PowerShell script designed to create a data extract from an Oracle database using "Oracle.ManagedDataAccess". There are numerous helper modules and scripts to setup your environment located in the "lib" and "sbin" respectively. The script makes use of AES encryption.

1. Generate your AES key file and Pass file using the following process.
```Powershell
    cd ./MakeOraExtract/lib
	Import-Module ./MakeAESFiles
	Make-KeyFile ../etc/AES.key
	Make-PassFile ../etc/AES.key ../etc/Pass.txt "YourPassWordHere"
```

2. Update your configuration file to match your deployment directory paths
```Powershell
    cd ./MakeOraExtract/lib 
    pwsh ./UpdateCfg.ps1
```

3. Update the following file with your Oracle SQL query.
```Powershell
    Get Content ./MakeOraExtract/dat/in/pstmt.sql 
```

4. Generate your extract file
```Powershell
    cd ./MakeOraExtract/bin
    pwsh ./MakeOraExtract.ps1	
```