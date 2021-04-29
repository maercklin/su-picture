#!/bin/bash
#-----------------------------------------------------------------------------
# SU-Picture - Example scripts to convert a picture file to CWP/SU format,
# use it as velocity model for sufdmod2, and create a wave propagation movie
#
# 03_Create_Movie.sh - Create wavefield snapshot images and movie (H.264 MP4)
#-----------------------------------------------------------------------------
# Nils Maercklin, March 2021


### Input and output file names:

# Input velocity file (binary floats) and corresponding parameter file:
vbinfile="velocity.bin"
vparfile="${vbinfile%.*}.par"

# Input SU files:
sufile="picture.su"     # original picture converted to SU
hsfile="hseis.su"       # horizontal line (shot gather) from "sufdmod2"
wfile="wavefield.su"    # wavefield snapshots from "sufdmod2"

# Output movie file:
mp4file="movie.mp4"     # output video file

# Output directory for (temporary) image files (frames of final movie):
imagedir="Images"  



### Modeling and display parameters:

# Get parameters for velocity model (model dimensions and sampling):
. $vparfile 

n1=$n1 d1=$d1 f1=$f1   # vertical model dimensions and sampling
n2=$n2 d2=$d2 f2=$f2   # horizontal model dimensions and sampling

mt=40                  # number of time steps (dt) per output time step
                       # as used by "sufdmod2" (used here for mute calculation)

clip=0.5               # display clip value for snapshots and shot gather

# Get time sample interval (used for mute calculation):
dt=`suwind < $hsfile count=1 | sugethw key=dt output=geom`



### Create snapshot images (frames) for the movie:

# Create subdirectory for images:
if [ ! -d Images ]; then mkdir Images; fi

# PostScript plot of original picture in grayscale (see "psimage" self-doc"):
supsimage <$sufile width=6 height=9 labelsize=12 titlesize=20  \
        title="Picture" verbose=0 > picture.eps

# PostScript plot of velocity model in color (see "psimage" self-doc"):
psimage <$vbinfile par=$vparfile width=6 height=9 labelsize=12 titlesize=20 \
        threecolor=1 whls=1.0,0,1.0 ghls=0,.9,1.0 bhls=0,.5,.5 \
        legend=1 lheight=0.1 lstyle=horibottom units=m/s \
        title="Velocity Model" verbose=0 > model.eps

# PostScript contour plot of velocity model (see "pscontour" self-doc"): 
# (to be used as overlay on wavefield snapshots)
pscontour <$vbinfile par=$vparfile wbox=6 hbox=9 labelsize=12 titlesize=20 \
        fc=1500 dc=1000 nc=6 nlabelc=0 ccolor=turquoise cwidth=0 > contours.eps


# Loop over wavefield snapshots (snapshot index assumed in header FLDR):
for fldr in `sugethw <$wfile key=fldr output=geom | sort -nu`
do
    # Get snapshot index with leading zeroes (for image file name):
    ii=`echo $fldr | awk '{printf("%04d", $1)}'`

    # Calculate mute time for shot gather:
    tmute=`echo $fldr $dt $mt | awk '{printf("%.3f", $1*$2*$3/1000000)}'`

    # Diagnostic print (echo snapshot index and time):
    echo "Snapshot $ii at t=$tmute ..." 2> /dev/stderr


    # PostScript label of snapshot time (warning message suppressed):
    pslabel t="$tmute s" size=24 f="Helvetica" \
        bcolor="#BBB" > label.eps  2>/dev/null


    # Select wavefield snapshot by index in header FLDR 
    # and create PostScript image plot of wavefield snapshot:
    suwind <$wfile key=fldr min=$fldr max=$fldr |
    sushw key=tracl,tracr a=0,0 |
    supsimage clip=$clip threecolor=0 verbose=0 width=6 height=9 \
        labelsize=12 titlesize=20 title="Wave Field" \
        gridwidth=0 gridcolor=green > wave.eps


    # Mute shot gather at current snapshot time 
    # and create PostScript image plot of muted shot gather:
    sumute <$hsfile xmute=0 tmute=$tmute mode=1 |
    supsimage clip=$clip threecolor=0 verbose=0 width=6 height=9 \
        labelsize=12 titlesize=20 title="Shot Gather" \
        gridwidth=0 gridcolor=green t > seis.eps


    # Merge all PostScript plots into one image and convert to PNG format:
    ${CWPROOT}/bin/psmerge \
            in=picture.eps  translate=0,0 \
            in=model.eps    translate=6.5,0 \
            in=wave.eps     translate=0,9.7 \
            in=contours.eps translate=0,9.7 \
            in=seis.eps     translate=6.5,9.7 \
            in=label.eps    translate=1.7,11.3 |
    convert eps:- png:- > ${imagedir}/image${ii}.png

done



### Create movie from individual images (frames):

# Create movie using "ffmpeg" (see its documentation for details):
ffmpeg -framerate 20 -pattern_type glob -i "${imagedir}/image????.png" \
        -c:v libx264 -pix_fmt yuv420p  $mp4file


# Diagnostic print (echo output movie file name):
echo "Output movie: $mp4file" 2> /dev/stderr



### Clean-up:

# Remove the temporary PostScript files:
rm -f picture.eps model.eps wave.eps seis.eps label.eps contours.eps 

# Remove individual images created in the loop above:
# (images may be kept for testing "ffmpeg" parameters)
# rm -f image???.png 

exit 0
