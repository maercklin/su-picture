#!/bin/bash
#-----------------------------------------------------------------------------
# SU-Picture - Example scripts to convert a picture file to CWP/SU format,
# use it as velocity model for sufdmod2, and create a wave propagation movie
#
# 01_Convert_Image.sh - Convert image file to SU format, scale it for use as
#                       velocity model, and show QC displays
#-----------------------------------------------------------------------------
# Nils Maercklin, March 2021


### Input and output file names:

# Input image file name (color or grayscale JPG, PNG, GIF, etc.)
inputfile="Picture.jpg"

# Output file names:
txtfile="picture.txt"          # temporary text file (can be removed later)
sufile="picture.su"            # image converted to SU (max. amplitude = 1)

vbinfile="velocity.bin"        # velocity file (binary floats)
vparfile="${vbinfile%.*}.par"  # velocity parameter file (i.e. model size)



### Convert image file to SU format:

# Convert input picture to grayscale and output as temporary text file:
convert -colorspace gray $inputfile txt:- | sed 's/[(),]/ /g' > $txtfile

# Get image dimensions from temporary text file (d1,d2 set arbitrarily):
n2=`head -1 $txtfile | awk '{print $5}'`
n1=`head -1 $txtfile | awk '{print $6}'`
scale=`head -1 $txtfile | awk '{print $7}'`
d1=5
d2=5
f1=0
f2=0
dt=`echo $d1 | awk '{print $1*1000}'`

# Convert text file to SU format with sample values between 0 and 1:
sed 1d $txtfile |
awk '{print (scale-$3)/scale}' scale=$scale |
a2b n1=$n2 |
transp n1=$n2 n2=$n1 |
suaddhead ns=$n1 |
sushw key=trid,dt,d1,d2,tracl,tracf,tracr \
        a=1,$dt,$d1,$d2,1,1,1 b=0,0,0,0,1,1,1 > $sufile



### Create a velocity model for "sufdmod2":

# Create a scaled binary file that can be used as seismic velocity model:
# (velocity values between "bias" and "bias+scale", i.e., here 1500-3500)
sugain <$sufile scale=2000 |
sugain bias=1500 |
sustrip > $vbinfile

# Save velocity model dimensions as SU parameter file:
echo "n1=$n1 n2=$n2 d1=$d1 d2=$d2 f1=$f1 f2=$f2" > $vparfile



### QC displays (X-Window graphics):

# X-Window display of SU file:
suximage < $sufile grid1=dot grid2=dot legend=1 cmap=rgb0 \
        windowtitle=Picture title=$vbinfile xbox=50 wbox=400 hbox=500 \
        label1=Depth label2=Distance &

# X-Window display of binary velocity file:
ximage < $vbinfile par=$vparfile grid1=dot grid2=dot legend=1 cmap=hsv2 \
        windowtitle=Velocity title=$vbinfile xbox=475 wbox=400 hbox=500 \
        label1=Depth label2=Distance &

exit 0
