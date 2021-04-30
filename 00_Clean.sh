#!/bin/bash
#-----------------------------------------------------------------------------
# SU-Picture - Example scripts to convert a picture file to CWP/SU format,
# use it as velocity model for sufdmod2, and create a wave propagation movie
#
# 00_Clean.sh - Remove files created by the example scripts 01, 02, 03, 04
#-----------------------------------------------------------------------------
# Nils Maercklin, March 2021

# Remove created files (file names as in original scripts by NM):
rm -f picture.txt picture.su sseis.su hseis.su vseis.su wavefield.su
rm -f velocity.bin velocity.par
rm -f picture.eps model.eps wave.eps seis.eps label.eps contours.eps 
rm -f Images/image????.png

# Remove created subdirectory (if not empty):
if [ -d Images ]; then rmdir Images; fi

# Ask to remove created movie file (as originally named):
if [ -f movie.mp4 ]; then rm -i movie.mp4; fi

exit 0
