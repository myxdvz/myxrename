#! /bin/bash

# Set your source and target directories
# torrentDirectory="/path/to/source"
# mediaDirectory="/path/to/target"

#default values
torrentDirectory="/Volumes/plex/torrents/complete/audiobooks"
mediaDirectory="/Volumes/plex/media/audiobooks/audiobookshelf"
output="f"
filename="myxrename"
declare -i torrentCount=0

#get commandline arguments
while getopts t:m:o:f:h flag
do
    case "${flag}" in
        t) torrentDirectory=${OPTARG};;
        m) mediaDirectory=${OPTARG};;
        o) output=${OPTARG};;
        f) filename=${OPTARG};;
        h) echo "myxrename.sh -t [Torrent Directory] -m [Media Directory] -o [f|e] -f [OutputFilename]";exit 1
    esac
done

#add rundate to file
filename+="_$(date -u +%Y%m%d%H%M%S).sh"

#process what output is expected
case "${output}" in
    f) echo "#Generating script file to hardlink files from " $torrentDirectory  " to " $mediaDirectory > $filename;;
    e) echo "#Executing script file to hardlink files from " $torrentDirectory  " to " $mediaDirectory > $filename
esac

#echo $torrentDirectory
#echo $mediaDirectory
#echo $output
#echo $filename

# Find all M4B files recursively in the source directory
find "$torrentDirectory" -type f \( -iname "*.m4b" \) | while read -r file; do
    #increment torrent counter
    torrentCount=$(( torrentCount + 1 ))
    echo $torrentCount ") source: " $file
    echo "# " $torrentCount ") source: " $file >> $filename
    
    # Find the Author, Series, Part and Title
    metadata=$(ffprobe -loglevel error -show_entries format_tags=artist,album,title,series,part,series-part,isbn,asin,audible_asin,composer -of default=noprint_wrappers=1:nokey=0 -print_format compact "$file")
    echo "#" $metadata >> $filename
    
    #reset all variables
    relativePath=""
    author="Unknown"
    series=""
    part=""
    title=""
    subtitle=""
    seriespart=""

    #Parse the metadata into variables
    while IFS='|' read -ra TAGS; do 
        #echo $TAGS
        for tag in "${TAGS[@]}"; do
            if [ "$tag" != "format" ] 
            then
                #echo "tag >>" $tag "\r\n"
                #if it's this tag, set variable
                while IFS='=' read -ra ITEMS; do
                    #echo "items >>" ${ITEMS[0]} " and " ${ITEMS[1]}
                    if [ "${ITEMS[0]}" = "tag:artist" ] 
                    then
                        author="${ITEMS[1]//[.]/}"
                        echo "author=" "${author}"
                    fi
                    if [ "${ITEMS[0]}" = "tag:title" ] 
                    then
                        title="${ITEMS[1]//[:]/_}"
                        title="${title// (Unabridged)/}"
                        echo "title=" "${title}"
                    fi
                    if [ "${ITEMS[0]}" = "tag:SERIES" ] 
                    then
                        series="${ITEMS[1]//[:]/_}"
                    fi
                    if [ "${ITEMS[0]}" = "tag:PART" ] 
                    then
                        part="${ITEMS[1]//[:]/_}"
                        echo "part=" "${part}"
                    fi
                    if [ "${ITEMS[0]}" = "tag:album" ] 
                    then
                        subtitle="${ITEMS[1]//[:]/_}"
                        subtitle="${subtitle// (Unabridged)/}"
                        echo "subtitle=" "${subtitle}"
                    fi
                done <<< $tag
            fi
        done
    done <<< "$metadata" 

    #if series and part are found, use that - otherwise use subtitle
    if [ -n "${part}" ]
    then
        seriespart="${series} #${part}"
    else
        series=$subtitle    
        seriespart=""
    fi
    echo "series=" "${series}"
    echo "seriespart=" "${seriespart}"

    #if theres an author and a title
    if [ -n "$title" ]
    then 
        #if this is just a book with no series
        if [ "$series" != "$title" ] 
        then
            #add series in the path
            if [ -z "$seriespart" ]
            then
                # multiple books with bad tags in one torrent folder, use this
                # targetDirectory="${mediaDirectory}/${author}/${series}"
                targetDirectory="${mediaDirectory}/${author}/${series}/${title}"
            else 
                targetDirectory="${mediaDirectory}/${author}/${series}/${seriespart} - ${title}"
            fi
        else
            targetDirectory="${mediaDirectory}/${author}/${title}"
        fi

        #check if the existing targetDirectory exists, likely not, unless I already have the book
        if [ ! -e "$targetDirectory" ]; then
            # Create target directory
            if [ "$output" = "f" ]; then
                echo mkdir -p "\"$targetDirectory\"" >> $filename
            fi
            if [ "$output" = "e" ]; then
                echo "Creating a new folder - " $targetDirectory
                mkdir -p "$targetDirectory" 
            fi            
        fi

        # Create a hard link in the target directory, increment count
        relativePath="$(dirname "$file")"
        echo ln "\"${file}\"" "\"${targetDirectory}\""/ >> $filename
        if [ "$output" = "e" ]; then
            echo "Hard Linking ${relativePath}/*.* to ${targetDirectory}/"
            ln "${file}" "${targetDirectory}"/
        fi
    fi
done

echo "Completed renaming and hardlinking torrent files..."
