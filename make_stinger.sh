#!/bin/bash

#Colors info https://ffmpeg.org/ffmpeg-utils.html#Color
color1="red"
color2="yellow"
color3="blue"
image="logo.png"

config="\
[0]negate[alpha0];\
[1]negate[alpha1];\
[2]negate[alpha2];\
[6]scale=w=512:h=512:force_original_aspect_ratio=decrease[logo];\
[3][alpha0]alphamerge=shortest=1[color1];\
[4][alpha1]alphamerge=shortest=1[color2];\
[5][logo]overlay=W/2-w/2:H/2-h/2[logo-color3];\
[logo-color3][alpha2]alphamerge=shortest=1[color3];\
[color1][color2]overlay[a];\
[a][color3]overlay[out]
"

echo $config

ffmpeg \
    -i layer1.mov \
    -i layer2.mov \
    -i layer3.mov \
    -f lavfi -i "color=${color1}:s=1920x1080" \
    -f lavfi -i "color=${color2}:s=1920x1080" \
    -f lavfi -i "color=${color3}:s=1920x1080" \
    -i ${image} \
    -filter_complex ${config}\
    -map [out] -codec:v qtrle output.mov
