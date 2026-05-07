try {
    $body = @{
        email = "admin99@autoparts.tn"
        password = "admin123"
        firstName = "A"
        lastName = "B"
    } | ConvertTo-Json
    Invoke-RestMethod -Uri "http://localhost:8081/api/auth/register" -Method Post -Body $body -ContentType "application/json"
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $msg = $reader.ReadToEnd()
    Write-Output $msg
}
