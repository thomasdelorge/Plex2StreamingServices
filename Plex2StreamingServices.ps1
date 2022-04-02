################################
### SETTINGS : TO COMPLETE ! ###
################################
$ApiKey = "XXXXXXXXXXXXXXXXXXXXXX" # TMDB's API Documentation : https://developers.themoviedb.org/3/getting-started/introduction
$streamingServiceSubscribed = "Netflix,Amazon Prime Video,Disney Plus" # all streaming services you're subscribed (separated by comma). List at https://developers.themoviedb.org/3/watch-providers/get-movie-providers
$language = "FR" # TMDB's API Documentation :https://developers.themoviedb.org/3/getting-started/languages

##############
### SCRIPT ###
##############

# Get movie list
$movieList = Get-ChildItem -Path "$PSScriptRoot" -Directory

# ForEach Movie
foreach ($movie in $movieList) {
    # Name's rework
    $movieOriginalName = "$($movie.name)"
    $movieName = $movieOriginalName -replace " ", "+" -replace "\+\(....\)",'' -replace "#",""

    # Api call : find tmdb id with movie name
    $searchMovieIdByName = Invoke-WebRequest -Uri "http://api.themoviedb.org/3/search/movie?api_key=$ApiKey&query=$movieName&language=$language"

    # Check StatusCode is 200 (OK)
    if ($searchMovieIdByName.StatusCode -ne 200){
        Write-Host "$movieOriginalName API's call failed ($($searchMovieIdByName.StatusDescription))" -ForegroundColor Red
        Pause
        continue
    }

    # Convert response to Json
    $searchMovieIdByName = $searchMovieIdByName.content | ConvertFrom-Json

    # Check how many movies as been found
    # If 0 or >1 : error
    if ($searchMovieIdByName.Count -eq 0){
        Write-Host "$movieOriginalName : Movie not found in TMDB" -ForegroundColor Yellow
        continue
    }
    ElseIf ($searchMovieIdByName.Count -gt 1){
        Write-Host "$movieOriginalName : Multiples movies founded with this name" -ForegroundColor Yellow
        continue
    }

    $movieId = $searchMovieIdByName.results.id

    # Api call : Streaming services available for this movie ?
    $streamingServiceAvailable = Invoke-WebRequest -Uri "https://api.themoviedb.org/3/movie/$movieId/watch/providers?api_key=$ApiKey"
    $streamingServiceAvailable = $streamingServiceAvailable.content | ConvertFrom-Json

    # Check results
    $streamingServiceAvailableCount = $streamingServiceAvailable.results.$language.flatrate.count
    if ($streamingServiceAvailableCount -gt 0){
        $streamingServiceAvailableName = $streamingServiceAvailable.results.$language.flatrate.provider_name -join ", "

        # Check with streaming service subscribed ($streamingServiceSubscribed)
        try{ Clear-Variable flag }
        catch {Clear-Host}
        $streamingServiceSubscribed = $streamingServiceSubscribed -split ','
        foreach ($service in $streamingServiceSubscribed){
            if ($streamingServiceAvailableName -eq $service){
                $flag = "true"
            }
        }

        if ($flag -eq "true"){
            Write-Host "$movieOriginalName : Already available in $streamingServiceAvailableName" -ForegroundColor Red
        }
        else {
            Write-Host "$movieOriginalName : OK" -ForegroundColor Green
        }
    }
    else {
        Write-Host "$movieOriginalName : OK" -ForegroundColor Green
    }
}