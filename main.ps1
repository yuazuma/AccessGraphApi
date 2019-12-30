Install-Module -Name MSAL.PS -RequiredVersion 4.2.1.3
Install-Module -Name JWTDetails -RequiredVersion 1.0.1

Import-Module -Name MSAL.PS
Import-Module -Name JWTDetails

$clientID = '<アプリケーションキーのGUID>'
$clientSecret = '<アプリケーションシークレット>'
$tenantID = '<テナントのGUID>'

# トークンを取得する
$secureClientSecret = (ConvertTo-SecureString $clientSecret -AsPlainText -Force)
$acquiredToken = Get-MsalToken -clientID $clientID -clientSecret $secureClientSecret -tenantID $tenantID
$acquiredToken.AccessToken | Get-JWTDetails

# ユーザー一覧を取得する
$users = Invoke-RestMethod -Headers @{Authorization = "Bearer $($acquiredToken.AccessToken)" } `
    -Uri  'https://graph.microsoft.com/v1.0/users' `
    -Method Get
$users.value | ForEach-Object{Write-Host $_}

# チーム一覧を取得する
$userId = $users.value[0].id # temp

$teams = Invoke-RestMethod -Headers @{Authorization = "Bearer $($acquiredToken.AccessToken)" } `
    -Uri "https://graph.microsoft.com/v1.0/users/$($userId)/joinedTeams" `
    -Method Get
$teams.value | ForEach-Object{Write-Host $_}

# チャネル一覧を取得する
$teamId = $teams.value[0].id # temp

$channels = Invoke-RestMethod -Headers @{Authorization = "Bearer $($acquiredToken.AccessToken)" } `
    -Uri "https://graph.microsoft.com/v1.0/teams/$($teamId)/channels" `
    -Method Get
$channels.value | ForEach-Object{Write-Host $_}

# メッセージ一覧を取得する
$channelId = $channels.value[0].id # temp

$messages = Invoke-RestMethod -Headers @{Authorization = "Bearer $($acquiredToken.AccessToken)" } `
    -Uri "https://graph.microsoft.com/beta/teams/$($teamId)/channels/$($channelId)/messages" `
    -Method Get
$messages.value | ForEach-Object{Write-Host $_}
