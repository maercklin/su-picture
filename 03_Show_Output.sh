#!/bin/bash
#-----------------------------------------------------------------------------
# SU-Picture - Example scripts to convert a picture file to CWP/SU format,
# use it as velocity model for sufdmod2, and create a wave propagation movie
#
# 03_Show_Output.sh - X-Window QC displays of seismograms and two snapshots           
#-----------------------------------------------------------------------------
# Nils Maercklin, March 2021


### Input and output file names:

# Input velocity file (binary floats) and corresponding parameter file:
vbinfile="velocity.bin"
vparfile="${vbinfile%.*}.par"

# Input SU files:
hsfile="hseis.su"    # horizontal line (shot gather) from "sufdmod2"
vsfile="vseis.su"    # vertical line (VSP) from "sufdmod2"
wfile="wavefield.su" # wavefield snapshots from "sufdmod2"



### Display and modeling parameter:
fldr1=60            # index of first snapshot to be plotted
fldr2=90            # index of second snapshot to be plotted

clip=0.5            # display clip value for snapshots and shot gather

mt=40               # number of time steps (dt) per output time step
                    # as used by "sufdmod2" (for time calculation only)

# Get time sample interval (used for mute calculation):
dt=`suwind < $hsfile count=1 | sugethw key=dt output=geom`



### QC displays (X-Window graphics) of output seismograms:

# Calculate snapshot times to be displayed as curve on shot gather:
echo $fldr1 $dt $mt |
awk '{t=$1*$2*$3/1000000; print t, 0; print t, 999999}' > time1.txt

echo $fldr2 $dt $mt |
awk '{t=$1*$2*$3/1000000; print t, 0; print t, 999999}' > time2.txt


# X-Window display of horizontal line of seismograms (shot gather):
suximage <$hsfile clip=$clip grid1=dot grid2=dot legend=1 cmap=rgb0 \
        windowtitle=Horizontal title=$hsfile xbox=50 wbox=400 hbox=500 \
        curve=time1.txt,time2.txt curvecolor=green,red npair=2,2 \
        label1=Time label2=Distance &

# X-Window display of vertical line of seismograms (VSP):
suximage <$vsfile clip=$clip grid1=dot grid2=dot legend=1 cmap=rgb0 \
        windowtitle=VSP title=$vsfile xbox=450 wbox=400 hbox=500 \
        curve=time1.txt,time2.txt curvecolor=green,red npair=2,2 \
        label1=Time label2=Depth style=normal &


# X-Window display of first wavefield snapshot:
suwind <$wfile key=fldr min=$fldr1 max=$fldr1 |
sushw key=tracl,tracr a=0,0 |
suximage clip=$clip grid1=dot grid2=dot legend=1 cmap=rgb0 titlecolor=green \
        windowtitle=Snapshot title="Snapshot $fldr1" \
        label1=Depth label2=Distance xbox=450 wbox=400 hbox=500 &

# X-Window display of second wavefield snapshot:
suwind <$wfile key=fldr min=$fldr2 max=$fldr2 |
sushw key=tracl,tracr a=0,0 |
suximage clip=$clip grid1=dot grid2=dot legend=1 cmap=rgb0 titlecolor=red \
        windowtitle=Snapshot title="Snapshot $fldr2" \
        label1=Depth label2=Distance xbox=850 wbox=400 hbox=500 &



### Clean-up:

# Remove the temporary text file:
sleep 2
rm -f time1.txt time2.txt

exit 0
