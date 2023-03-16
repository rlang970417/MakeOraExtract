<#
    Script : MakeEncryptPass.ps1
	USAGE : ${SCRIPT}
	ARGS: None. This script is interactive.
	DESC : This script will generate a Base64 pass phrase to use with Powershell

    REF : https://www.pdq.com/blog/secure-password-with-powershell-encrypting-credentials-part-2/
#>
$secureString = Read-Host -Prompt "Please provide the password to encrypt : " -AsSecureString

# Encrypt Password
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((ConvertFrom-SecureString -SecureString $secureString -AsPlainText)))