# Gmail SMTP settings
$smtpServer = "smtp.gmail.com"
$smtpPort   = 587

# Email details
$displayName = "Your Name"
$emailFrom   = "your mail@gmail.com"
$attachmentPath = Join-Path $env:USERPROFILE "Desktop\CV.pdf"

# Get data from text file WITH EXPLICIT UTF-8 ENCODING
$dataFile = Join-Path $env:USERPROFILE "Desktop\data.txt"  #where your data file is
$emailLines = Get-Content $dataFile -Encoding UTF8
$emailEntries = @()
$currentEntry = @()
foreach ($line in $emailLines) {
    # If a new email address is encountered and there is an ongoing entry, start a new entry.
    if ($line -match '^[^@\s]+@[^@\s]+\.[^@\s]+$' -and $currentEntry.Count -gt 0) {
         $emailEntries += ,($currentEntry -join "`r`n")
         $currentEntry = @()
    }
    $currentEntry += $line
}
if ($currentEntry.Count -gt 0) {
    $emailEntries += ,($currentEntry -join "`r`n")
}

# Configure SMTP client
$smtpClient = New-Object System.Net.Mail.SmtpClient($smtpServer, $smtpPort)
$smtpClient.EnableSsl = $true

# Get credentials securely
$credential = Get-Credential -UserName $emailFrom -Message "Enter Gmail App Password"
$smtpClient.Credentials = $credential.GetNetworkCredential()

# Counter for progress tracking
$count = 0
$total = $emailEntries.Count

foreach ($entry in $emailEntries) {
    $count++
    try {
        # Parse email data
        $lines = $entry -split '\r?\n'
        $mailTo = $lines[0].Trim()
        $subject = ($lines | Where-Object { $_ -match '^Subject:' }) -replace '^Subject:\s*', ''
        $body = ($lines | Where-Object { $_ -notmatch '^Subject:' -and $_ -ne $mailTo }) -join "`r`n"

        # Create mail message with UTF-8 encoding
        $mailMessage = New-Object System.Net.Mail.MailMessage
        $mailMessage.From = New-Object System.Net.Mail.MailAddress($emailFrom, $displayName)
        $mailMessage.To.Add($mailTo)
        $mailMessage.Subject = $subject
        $mailMessage.Body = $body
        $mailMessage.SubjectEncoding = [System.Text.Encoding]::UTF8
        $mailMessage.BodyEncoding = [System.Text.Encoding]::UTF8
        $mailMessage.IsBodyHtml = $false

        # Add attachment
        $attachment = New-Object System.Net.Mail.Attachment($attachmentPath)
        $mailMessage.Attachments.Add($attachment)

        # Send email
        Write-Host "[$count/$total] Sending to $mailTo..."
        $smtpClient.Send($mailMessage)
        Write-Host "Successfully sent to $mailTo" -ForegroundColor Green
    }
    catch {
        Write-Host "Error sending to $mailTo : $_" -ForegroundColor Red
    }
    finally {
        if ($attachment) { $attachment.Dispose() }
        if ($mailMessage) { $mailMessage.Dispose() }
    }
}

$smtpClient.Dispose()
Write-Host "Process completed. Sent $count/$total emails." -ForegroundColor Cyan
