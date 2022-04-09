################################
### SETTINGS : TO COMPLETE ! ###
################################
$ApiKey = "CHANGEME" # TMDB's API Documentation : https://developers.themoviedb.org/3/getting-started/introduction
$streamingServiceSubscribed = "Netflix,Amazon Prime Video,Disney Plus" # all streaming services you're subscribed (separated by comma). List at https://developers.themoviedb.org/3/watch-providers/get-movie-providers
$language = "CHANGEME" # TMDB's API Documentation :https://developers.themoviedb.org/3/getting-started/languages
$plexIp = "CHANGEME"
$plexToken = "CHANGEME"

##############
### SCRIPT ###
##############

# User choose between plex API call or Local file searching
$answer = Read-Host "Would you like to request Plex's api or user local directory ? (plex/local)"
if ($answer -eq "plex") {
    [XML]$plexMoviesList = Invoke-WebRequest -Uri "http://$($plexIp):32400/library/sections/1/all?X-Plex-Token=$plexToken"
    $movies = $plexMoviesList.MediaContainer.Video | Select-Object title
}
elseif ($answer -eq "local"){
    $answer2 = Read-Host "Please enter path to movies directory"
    if (!(Test-Path "$answer2")){ 
        Write-Host "Directory $answer doesn't exist !" -ForegroundColor Red
        pause
        exit
    }
    $movies = Get-ChildItem -Path "$answer2" -Directory | Select-Object name
}
else { exit }


# ForEach Movie
foreach ($movie in $movies) {

    if ($answer -eq "plex"){
        $movie = $movie.title
    }
    elseif ($answer -eq "local"){
        $movie = $movie.name
    }

    # Rework name for plex api
    $movieName = $movie -replace " ", "+" -replace "\+\(....\)",'' -replace "#",""

    # Api call : find tmdb id with movie name
    $searchMovieIdByName = Invoke-WebRequest -Uri "http://api.themoviedb.org/3/search/movie?api_key=$ApiKey&query=$movieName&language=$language"

    # Check StatusCode is 200 (OK)
    if ($searchMovieIdByName.StatusCode -ne 200){
        Write-Host "$movie API's call failed ($($searchMovieIdByName.StatusDescription))" -ForegroundColor Red
        Pause
        continue
    }

    # Convert response to Json
    $searchMovieIdByName = $searchMovieIdByName.content | ConvertFrom-Json

    # Check how many movies as been found
    # If 0 or >1 : error
    if ($searchMovieIdByName.Count -eq 0){
        Write-Host "$movie : Movie not found in TMDB" -ForegroundColor Yellow
        continue
    }
    ElseIf ($searchMovieIdByName.Count -gt 1){
        Write-Host "$movie : Multiples movies founded with this name" -ForegroundColor Yellow
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
        $flag = $null
        $streamingServiceSubscribed = $streamingServiceSubscribed -split ','
        foreach ($service in $streamingServiceSubscribed){
            if ($streamingServiceAvailableName -eq $service){
                $flag = "true"
            }
        }

        if ($flag -eq "true"){
            Write-Host "$movie : Already available in $streamingServiceAvailableName" -ForegroundColor Red
        }
        else {
            Write-Host "$movie : OK" -ForegroundColor Green
        }
    }
    else {
        Write-Host "$movie : OK" -ForegroundColor Green
    }
} 
