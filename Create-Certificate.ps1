$getParams = @{
    Message  = "Please enter a name for the certificate in the 'User name' text box and a password to encrypt the exported PFX file in the 'Password' text box."
    UserName = "MySelfSignedCertificate"
}
$credential = Get-Credential @getParams

if ($null -eq $credential.Password) {
    exit
}

$certStoreLocation = "Cert:\CurrentUser\My"
$newParams = @{
    CertStoreLocation = $certStoreLocation
    HashAlgorithm     = "SHA256"
    FriendlyName      = $credential.UserName
    KeyExportPolicy   = "Exportable"
    KeyUsage          = "DigitalSignature"
    NotAfter          = (Get-Date).AddYears(2)
    Provider          = "Microsoft Strong Cryptographic Provider"
    Subject           = "CN=" + $credential.UserName
    Type              = "CodeSigning"
}

$certificate = New-SelfSignedCertificate @newParams
$exportCerParams = @{
    Cert     = $certificate 
    FilePath = [IO.Path]::ChangeExtension($credential.UserName, "cer") 
}

Export-Certificate @exportCerParams

$exportPfxParams = @{
    Cert     = Join-Path -Path $certStoreLocation -ChildPath $certificate.Thumbprint
    FilePath = [IO.Path]::ChangeExtension($credential.UserName, "pfx")
    Password = $credential.Password
}

Export-PfxCertificate @exportPfxParams

Write-Output "
Exported the public key (*.cer) and public-private key pair (*.pfx) and
installed the certificate in the $certStoreLocation certificate store.

To use this certificate without errors, manually move the certificate to the
trusted root certificate store (WARNING: this will make the self-signed
certificate a root authority).

Finally, run Add-Signature.ps1 to sign files."
