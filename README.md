# myxrename
A bash script to take a source folder, pull metadata information, create a tree structure on the target folder and hardlinks all files

## Usage:
./myxrename.sh -t <Torrent Directory> -m <Media Directory> -o [f|e] -f <Output filename>

-t is ideally your torrent directory,                  /data/torrents/completed/audiobooks
-m is ideally your media or audiobookshelf directory,  /data/media/audiobookshelf
-f is the output filename.  This always get generated regardless of the value of -o
-o is f by default. It generates a script file that you can review and tweak before executing.  If set to e, it will actually execute the script

**It takes the following tags**
* tags:artist = Author
* tags:title = Title
* tags:album = Subtitle
* tags:SERIES = Series
* tags:PART = Series part or number

**It also takes the following for future usage**
* tags:composer = Narrator
* tags:isbn = ISBN
* tags:audible_asin = ASIN

**If the SERIES and PART tags are available, it uses those. Otherwise, the Subtitle is assumed as the series.**

**It builds the following heirarchy on the target folder**
* <mediaDirector>/Author/Title
* <mediaDirector>/Author/Series/SeriesPart - Title

## Dependencies
Requires ffprobe (which comes with ffmpeg) to work
 	[title] (https://ffmpeg.org/)

