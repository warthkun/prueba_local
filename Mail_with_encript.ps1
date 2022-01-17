Add-Type -assemblyName "System.Security"

$ChosenCertificate = "C:\Temp\prueba\prueba.cer"
$Recipient = 'recipient@hotmai.com'

$MailClient = New-Object System.Net.Mail.SmtpClient "smtp.live.com"
$Message = New-Object System.Net.Mail.MailMessage
$Message.To.Add($Recipient)
$Message.From = "fromemailo@hotmail.com"
$Message.Subject = "Unencrypted subject of the message"
$Body = "Encrypted body of the message"
$MIMEMessage = New-Object system.Text.StringBuilder
$MIMEMessage.AppendLine('Content-Type: text/plain; charset="iso-8859-1"') | Out-Null
$MIMEMessage.AppendLine('Content-Transfer-Encoding: 7bit') | Out-Null
$MIMEMessage.AppendLine() | Out-Null
$MIMEMessage.AppendLine($Body) | Out-Null
[Byte[]] $BodyBytes = [System.Text.Encoding]::ASCII.GetBytes($MIMEMessage.ToString())
$ContentInfo = New-Object System.Security.Cryptography.Pkcs.ContentInfo (,$BodyBytes)
$CMSRecipient = New-Object System.Security.Cryptography.Pkcs.CmsRecipient $ChosenCertificate
$EnvelopedCMS = New-Object System.Security.Cryptography.Pkcs.EnvelopedCms $ContentInfo
$EnvelopedCMS.Encrypt($CMSRecipient)
[Byte[]] $EncryptedBytes = $EnvelopedCMS.Encode()
$MemoryStream = New-Object System.IO.MemoryStream @(,$EncryptedBytes)
$AlternateView = New-Object System.Net.Mail.AlternateView($MemoryStream, "application/pkcs7-mime; smime-type=enveloped-data;name=smime.p7m")
$Message.AlternateViews.Add($AlternateView)
$MailClient.EnableSsl = $true
$MailClient.Credentials = $cred2
$MailClient.Send($Message)