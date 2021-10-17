# Remove the PlayOn stuff with your name and IP address from the beginning and end of videos.

Clear-Host

# ffmpeg needs to be in your path environment variable or you'll need to put the full path to it

$DELETE_OLD_MP4 = $true
$FFMPEG_ERROR_LEVEL = "-nostats -loglevel fatal"
$SECONDS_TO_REMOVE_FROM_END = 10
$SECONDS_TO_REMOVE_FROM_START = 4
$START_PATH = "C:\temp"
$TEMP_PATH = "C:\temp"



#region Functions

Function Get-MP4Duration($file) {
    $duration = (& ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 $file)
    return $duration
}


#endregion

# If there are no subfolders use the base path
$playonVideos = Get-ChildItem -Path $START_PATH -Recurse -Directory # | ? { $_.PSIsContainer }
if ($playonVideos.Count -lt 1) { $playonVideos = $START_PATH }

$files = ""

write-host "Processing`r`n$playonVideos"

foreach ($playonVideo in $playonVideos) {
    if ($mp4s) { $mp4s = $null }
    if ($playonVideo.Fullname) { $playonVideo = $playonVideo.FullName }
    $playonVideo = $playonVideo.Trim("\")
    if (!$TEMP_PATH) { $TEMP_PATH = $playonVideo }
    Set-Location $playonVideo
    $mp4s = Get-ChildItem ($playonVideo + "\*") -Include "*.mp4"
    foreach ($mp4 in $mp4s) {
        Write-Host "Converting $($mp4.Name)"
        $fullname = $mp4.FullName
        $tempFile = $TEMP_PATH + "\temp.mp4"
        if ((Test-Path $tempFile)) {
            Remove-Item $tempFile
        }
        $duration = (Get-MP4Duration $fullname) - $SECONDS_TO_REMOVE_FROM_END
        & ffmpeg -i $fullname -ss $SECONDS_TO_REMOVE_FROM_START -map 0 -c copy -t $duration $tempFile -nostats -loglevel fatal
        Move-Item -LiteralPath $tempFile -Destination $fullname -Force
    }
}
