#!/usr/bin/env bash

# prerequisites:
#  - imagemagick
#  - ghostscript
#
# an easy way to install them is through homebrew ( http://brew.sh ):
# $ brew update
# $ brew install imagemagick ghostscript

IFS=$'\n'
buildNumber=$1
flavor=$2
buildType=$3
PROJECT_ROOT=`pwd`
cornerBackgroundColor=$4
textColor=$5
shadowColor=$6
topText=$flavor

#Check if convert/identify are installed
CONVERT=`which convert`
IDENTIFY=`which identify`

if [[ "${CONVERT}x" == "x" ]]
then
    CONVERT="/usr/local/bin/convert"
    IDENTIFY="/usr/local/bin/identify"
fi


function modifyIcon() {
  width=$1
  filename=$2

  FONT_SIZE=$(echo "$width * .125" | bc -l)

    #Generate shadows.png image with the shadows of the ribbon
    $CONVERT -size 256x256 -channel RGBA xc:none -background none -stroke "${shadowColor}" \
    	-draw "stroke-width 1 path 'M 0,0 L 110,0' path 'M 0,0 L 0,110' path 'M 255,255 L 145,255' path 'M 255,255 L 255,145'" \
    	-blur 0x22 shadows.png

    #Generate corners.png image with the corners of the ribbon
    $CONVERT -size 256x256 -channel RGBA xc:none -background none -fill "${cornerBackgroundColor}" \
    		\( -stroke none -draw "path 'M 0,0 L 125,0 0,125 Z' path 'M 256,256 L 131,256 256,131 Z' image over 0,0  0,0 'shadows.png'" \) \
    		\( -stroke ${textColor} -draw "stroke-width 1.5 path 'M 119,0 L 0,119' path 'M 135,256 L 256,135" \) \
            corners.png


    $CONVERT corners.png -resize ${width}x${width} resizedRibbon.png

    #Apply shadows, corner and ribbon to the icon
    $CONVERT "${filename}" -draw "image over 0,0  0,0  'resizedRibbon.png'" -set option:my:bottom_right '%[fx:w*0.85],%[fx:h*0.85]' -set option:my:top_left '%[fx:w*0.17],%[fx:h*0.17]' \
          \( -fill ${textColor} -pointsize ${FONT_SIZE} -font $PROJECT_ROOT/Montserrat-Bold.ttf -background none label:" ${buildNumber} " \
             +distort SRT '%[fx:w/2],%[fx:h/2] 1 -45 %[my:bottom_right]' \
          \) \( -fill ${textColor} -pointsize ${FONT_SIZE} -font $PROJECT_ROOT/Montserrat-Bold.ttf -background none label:" ${topText} " \
             +distort SRT '%[fx:w/2],%[fx:h/2] 1 -45 %[my:top_left]' \
          \) -layers flatten "${filename}"

  # cleanup
  rm -f shadows.png
  rm -f corners.png
  rm -f resizedRibbon.png
}

function generateIcon () {
  echo "searching for launcher icons..."
  cd "build/intermediates/res/merged/${flavor}/${buildType}"

  # find and process
  for icon in `find . -name *ic*launcher*.png`; do
    echo "processing ${icon}"
    WIDTH=$(${IDENTIFY} -format %w "${icon}")
    modifyIcon $WIDTH $icon
  done

  
  # cleanup
  rm -f resizedRibbon.png
}
 
generateIcon

