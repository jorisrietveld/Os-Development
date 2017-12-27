#!/usr/bin/env bash

SomeFonts=("nvscript" "O8" "Banner" "OS2" "reverse" "Rectangles" "s-relief" "speed" "smslant" "roman" "small" "sub-zero" "swampland" "Slant" "timesofl" "Tombstone" "xtimes" "s-relief" "Nancyj-Underlined" "nancyj-improved" "nancyj-fancy" "Modular" "mini" "miniwi" "larry3d" "Kban" "jazmine" "Georgi16" "Fuzzy" "fire_font-s" "f15_____" "Elite" "Electronic" "maxiwi" "eftifont" "doom" "Doh" "digital" "defleppard" "Cosmike" "Cybermedium" "Cyberlarge" "cricket" "Gradient" "Contessa" "colossal" "Computer" "contrast" "Chunky" "charact6" "broadway_kb" "Broadway" "bright" "Bigfig" "Banner3-D" "Alligator" "Bloody" "Alligator2" "Bolger" "3D-ASCII" "3-D" "3d")

for font in "${SomeFonts[@]}"
do
   toilet -t -f ${font} 'Jorix OS' | boxes -d twisted -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d text-box -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d stark2 -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d simple -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d shell -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d scroll-akn -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d peek -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d santa -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d parchment -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d nuke -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d netdata -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d mouse -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d ian_jones -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d html-cmt -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d html -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d headline -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d girl -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d face -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d dog -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d diamonds -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d columns -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d ccel -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d cc -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d cat -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d capgirl -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d caml -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d boy -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d boxquote -a hc -p h8 | toilet --gay -f term -t
   toilet -t -f ${font} 'Jorix OS' | boxes -d ada-box -a hc -p h8 | toilet --gay -f term -t
done
