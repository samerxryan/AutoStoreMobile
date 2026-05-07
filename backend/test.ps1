try {
    $body = @{
        email = "admin@autoparts.tn"
        password = "admin123"
    } | ConvertTo-Json
    $res = Invoke-RestMethod -Uri "http://localhost:8081/api/auth/login" -Method Post -Body $body -ContentType "application/json"
    Write-Output "TOKEN: $($res.token)"
} catch {
    $stream = $_.Exception.Response.GetResponseStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $msg = $reader.ReadToEnd()
    Write-Output $msg
}
