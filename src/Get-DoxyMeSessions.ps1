
function Get-DoxyMeSessions {
    [cmdletbinding()]
    <#
.SYNOPSIS
Get-DoxyMeSessions returns a list of sessions from the DoxyMe 
.PARAMETER Username
A DoxyMe username with admin or owner rights to the entity being exported
.PARAMETER Password
The password for the account specified by the Username parameter
.EXAMPLE
#get the sessions
Get-DoxyMeSessions -Username "user@tenant.com" -Password "$up3r$3cur3"
.EXAMPLE
#pretty print those sessions to the screen, sorting by starttime, and only showing the things you want to see
Get-DoxyMeSessions -Username "user@tenant.com" -Password "$up3r$3cur3" | Sort-Object -Property startTime | Format-Table -Property providerFirstName, providerLastName, startTime, durationSeconds
.EXAMPLE
#send those sessions to a CSV file so you can fiddle with them in Excel
Get-DoxyMeSessions -Username "user@tenant.com" -Password "$up3r$3cur3" | Sort-Object -Property startTime | Export-Csv -Path .\doxyme-sessions.csv
#>
    param(
        [parameter(Mandatory = $true, HelpMessage = "You must supply a username")]
        [string]
        $Username,

        [parameter(Mandatory = $true, HelpMessage = "You must supply a password")]
        [string]
        $Password,

        [parameter(Mandatory = $false, HelpMessage = "Would you like to print the authorization token to the screen?")]
        [bool]
        $ShowToken = $false
    )

    process {
        #build the body of the login POST
        $login_body = @{
            email    = $Username
            password = $password
        }

        #set header for login POST
        $login_header = @{
            Content = "application/xwww-form-urlencoded"
        }

        try {
            #do the login POST request
            $login_json = Invoke-RestMethod -Uri "https://api.doxy.me/api/users/login" -Method "Post" -Body $login_body -Headers $login_header

            $auth_token = $login_json.id

            if ($ShowToken) {
                write-host "Access Token: $auth_token"
            }

            #set header for session GET
            $history_header = @{
                Authorization = $auth_token
                Accept        = "application/json, text/plain, */*"
            }
        
            #do the session GET
            $session_history = Invoke-RestMethod -Uri "https://api.doxy.me/api/sessions/exportClinic" -Method "Get" -Headers $history_header

            #output the session data
            $session_history
        }
        catch {
            "Oops, something went wrong!"
            $_
        }
    }
}