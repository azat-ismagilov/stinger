#!/bin/bash

#Colors info https://ffmpeg.org/ffmpeg-utils.html#Color
color1="red"
color2="yellow"
color3="blue"
color4="white"
image="logo.png"

duration=2
strip_length=300

config="\
[0]trim=duration=$((duration/2))[alpha];\
[alpha]split=4[alpha1][alpha2][alpha3][alpha4];\
[alpha1]crop=1920:1080:0:0[alpha1];\
[alpha2]crop=1920:1080:$((strip_length)):0[alpha2];\
[alpha3]crop=1920:1080:$((strip_length*2)):0[alpha3];\
[alpha4]crop=1920:1080:$((strip_length*3)):0[alpha4];\
\
[1][alpha1]alphamerge=shortest=1[color1];\
[2][alpha2]alphamerge=shortest=1[color2];\
[3][alpha3]alphamerge=shortest=1[color3];\
\
[color1][color2]overlay[start];\
[start][color3]overlay[start];\
[start]split=2[start][finish];\
[finish]reverse,hflip,vflip[finish];\
[start][finish]concat[out];\
\
[alpha4]split=2[alpha4][alpha4_r];\
[alpha4_r]reverse,hflip,vflip[alpha4_r];\
[alpha4][alpha4_r]concat[alpha4];\
\
[5]trim=duration=$((duration/10))[logo];\
[logo]scale=w='512':h='512':force_original_aspect_ratio=decrease[logo];\
[4][logo]overlay=x=W/2-w/2:y=H/2-h/2[logo];\
[logo][alpha4]alphamerge=shortest=1[logo];\
\
[out][logo]overlay[out];\
\
[6][out]overlay=shortest=1[out]
"

echo $config

ffmpeg \
    -i src/across.avi \
    -f lavfi -i "color=${color1}:s=1920x1080" \
    -f lavfi -i "color=${color2}:s=1920x1080" \
    -f lavfi -i "color=${color3}:s=1920x1080" \
    -f lavfi -i "color=${color4}:s=1920x1080" \
    -i ${image} \
    -filter_complex ${config}\
    -map [out] -codec:v qtrle output.mov
