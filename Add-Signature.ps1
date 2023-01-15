param(
    [Parameter(Mandatory = $true)]
    [String]
    $PfxCertificatePath
)

$certificate = Get-PfxCertificate -FilePath $PfxCertificatePath
Set-AuthenticodeSignature -Certificate $certificate
