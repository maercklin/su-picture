#!/bin/bash
#-----------------------------------------------------------------------------
# SU-Picture - Example scripts to convert a picture file to CWP/SU format,
# use it as velocity model for sufdmod2, and create a wave propagation movie
#
# 02_Run_Sufdmod2.sh - Run finite-difference (FD) modeling "sufdmod2" 
#-----------------------------------------------------------------------------
# Nils Maercklin, March 2021


### Input and output file names:

# Input velocity file (binary floats) and corresponding parameter file:
vbinfile="velocity.bin"
vparfile="${vbinfile%.*}.par"

# Output SU files of "sufdmod2" (see its self-doc for details):
ssfile="sseis.su"      # source seismogram
hsfile="hseis.su"      # horizontal line of seismograms (shot gather)
vsfile="vseis.su"      # vertical line of seismograms (VSP)
wfile="wavefield.su"   # wavefield snapshots



### Modeling parameters:

# Get parameters for velocity model (model dimensions and sampling):
. $vparfile 

# Modeling parameters (see "sufdmod2" self-doc for more information):
n1=$n1 d1=$d1 f1=$f1   # vertical model dimensions and sampling
n2=$n2 d2=$d2 f2=$f2   # horizontal model dimensions and sampling
xs=10 zs=10            # point source coordinates X and Z
hsz=0                  # depth of horizontal line of seismograms
vsx=0                  # position of vertical line of seismograms
tmax=4                 # maximum time for FD modeling in seconds
mt=40                  # number of time steps (dt) per output time step
                       # (used for wavefield snapshots)
abs=1,1,1,1            # absorbing boundary conditions
verbose=2              # verbose level for diagnostic messages



### FD modeling:

# Run "sufdmod2" finite-difference modeling, write snapshot index to header
# FLDR, output wavefield file ($wfile), and show X-Window movie display:
sufdmod2 <$vbinfile nz=$n1 dz=$d1 nx=$n2 dx=$d2 f1=$f1 f2=$f2 \
        xs=$xs zs=$zs hsz=$hsz vsx=$vsx hsfile=$hsfile \
        vsfile=$vsfile ssfile=$ssfile verbose=$verbose \
        tmax=$tmax abs=$abs mt=$mt |
sushw key=fldr j=$n2 c=1 |
tee $wfile |
suxmovie  clip=1.0 \
        title="Acoustic Finite-Differencing: %g" windowtitle="Movie" \
        n1=$n1 d1=$d1 f1=$f1 n2=$n2 d2=$d2 f2=$f2 cmap=gray loop=2 interp=0 &

# Note: Comment out "tee $wfile" if wavefield file is not needed, i.e., for 
# for quick testing only. If X-Window movie is not wanted, run this instead:
# sufdmod2 < $vbinfile nz=$n1 dz=$d1 nx=$n2 dx=$d2 \
#        xs=$xs zs=$zs hsz=$hsz vsx=$vsx hsfile=$hsfile \
#        vsfile=$vsfile ssfile=$ssfile verbose=$verbose  \
#        tmax=$tmax abs=$abs mt=$mt |
# sushw key=fldr j=$n2 c=1 > $wfile


exit 0
