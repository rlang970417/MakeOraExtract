<#
    Module for making AES files
#>
function Make-KeyFile
{
    param
    (
        [Parameter (Mandatory = $true)] [String]$KeyFile
    )
	
    # Verify our configuration file does not exist
    if (Test-Path $KeyFile)
    {
        Write-Host "A file already exists at : $KeyFile"
	Write-Host "Program will take no further action!"
        exit
    }
	
    # Make Key File
    $Key = New-Object Byte[] 32   # You can use 16, 24, or 32 for AES
    [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($Key)
    $Key | out-file $KeyFile
}

function Make-PassFile
{
    param
    (
        [Parameter (Mandatory = $true)] [String]$KeyFile,
        [Parameter (Mandatory = $true)] [String]$PassFile,
	[Parameter (Mandatory = $true)] [String]$PassStr
    )
	
    # Verify our configuration file does not exist
    if (Test-Path $PassFile)
    {
        Write-Host "A file already exists at : $PassFile"
	Write-Host "Program will take no further action!"
        exit
    }

    $Key = Get-Content $KeyFile
    $Password = $PassStr | ConvertTo-SecureString -AsPlainText -Force
    $Password | ConvertFrom-SecureString -key $Key | Out-File $PassFile
}
