> 🆕 Do the same easely with 🌐 [`https://thomasdelorge.github.io/library-streaming-checker/`](https://thomasdelorge.github.io/library-streaming-checker/)

# Plex2StreamingServices


A script to check if your Plex's movies are already in Netflix, Disney+, Amazon Prime Video, etc ..

Inspirated from https://github.com/SpaceK33z/plex2netflix (deprecated)

## Option 1 : searching into localfile
- Edit $apiKey, $streamingServiceSubscribed and $language variables in the script (ligne 4-6)
- Plex library organization : 1 folder/movie with format '%movie_name (%year%)" (i use FileBot 4.7.9 to do this quickly)
```
C:.
├───#Chef (2014)
│       #Chef (2014).mkv
├───20 ans d'écart (2013)
│       20 ans d'écart (2013).fr.srt
│       20 ans d'écart (2013).mkv
├───30 jours max (2020)
│       30 jours max (2020).fr.srt
│       30 jours max (2020).mkv
├───A Star Is Born (2018)
│       A Star Is Born (2018).mkv
├───About Time (2013)
│       About Time (2013).mkv
```
- Move the .ps1 file into the directory containing all your movie and start

## Option 2 : searching into plex movies
- Complete setup part (first lines of the .ps1 file) and start the script

## Screenshots
![alt text](https://github.com/thomasdelorge/Plex2StreamingServices/blob/main/screenshot.jpg?raw=true "Console screenshot")
