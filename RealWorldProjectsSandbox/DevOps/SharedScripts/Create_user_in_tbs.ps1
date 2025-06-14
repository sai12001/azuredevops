Param(
    [Parameter(Mandatory=$true)][string]$databaseServer,
    [Parameter(Mandatory=$true)][string]$adminUser,
    [Parameter(Mandatory=$true)][string]$adminPassword,
    [Parameter(Mandatory=$true)][string]$Login,
    [Parameter(Mandatory=$true)][string]$password,
    [Parameter(Mandatory=$true)][string]$databases
)


Function Execute-Procedure {

    Process
    {
        $ConnectionString = "Data Source='$databaseServer';Initial Catalog=DBA;User ID='$AdminUser'; password='$AdminPassword'"
        Write-Host $ConnectionString

        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = $ConnectionString
        
        $query = 'EXEC Create_User ' + "'$Login'" + ',' + "'$password'" + ',' + "'$databases'"

        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 0
        $cmd.CommandText = $query

        try
        {
            $scon.Open()
            return $cmd.ExecuteNonQuery()
        }
        catch [Exception]
        {
            Write-Warning $_.Exception.Message
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }
    }
}

Execute-Procedure -databaseServer 