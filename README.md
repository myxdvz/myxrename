# myxrename
A bash script that does the following
- take a source folder, ideally your torrents download folder where your audiobook files are
- recursively find all the M4B files in it, and for each file
  - pull and parse metadata information
  - create a tree structure on the target folder, ideally your media folder (like your abs audiobook library folder)
  - and hardlinks all files from the parent folder of the M4B file to the target folder

## Usage:
./myxrename.sh -t "Torrent Directory" -m "Media Directory" -o [f|e] -f "Output filename"

| Flag | Description | Default Value |
| ----------- | ----------- | ----------- |
|-t |is ideally your torrent directory|/data/torrents/completed/audiobooks
|-m |is ideally your media or audiobookshelf directory|/data/media/audiobookshelf
|-f |is the output filename.  This always get generated regardless of the value of -o|myxrename_YYMMDDHHMMss.sh
|-o |if set to e, it will actually execute the script  (Untested)|f|

## How it works
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

*If the SERIES and PART tags are available, it uses those. Otherwise, the Subtitle is assumed as the series.*

**It builds the following heirarchy on the target folder**
* <mediaDirector>/Author/Title
* <mediaDirector>/Author/Series/SeriesPart - Title

## FAQ
**Q:  What if there are no tags?**
<p>A: The file is skipped</p>

**Q:  What if there's no author/artist tag?**
<p>A: Author is set to "Unknown"</p>

**Q:  What if there's no title tag?**
<p>A: The file is skipped</p>

## Dependencies
Requires ffprobe (which comes with [ffmpeg](https://ffmpeg.org/)) to work
Note that hardlinks only work if the source and target directories are in the SAME volume


