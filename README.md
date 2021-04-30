SU-Picture

This is a collection of example shell scripts (bash) to convert a picture 
file to CWP/SU Seismic Unix format (i.e., SEGY traces), use use it as a 
velocity model for SUFDMOD2 (acoustic finite-difference modelling), and 
create a wave propagation movie with FFMPEG. 

The scripts may also serve as a starting point for "seismic processing" of 
any picture.


REQUIREMENTS

CWP/SU Seismic Unix, ImageMagick ("convert" command), FFMPEG, bash 
on a Unix/Linux system. The scripts were tested on macOS 10.13 and 11.3.


SCRIPT DESCRIPTION

00_Clean.sh         - Remove files created by the scripts 01, 02, 03, 04

01_Convert_Image.sh - Convert image file to SU format, scale it for use as
                      velocity model, and show QC displays

02_Run_Sufdmod2.sh  - Run finite-difference (FD) modeling "sufdmod2" 

03_Show_Output.sh   - X-Window QC displays of seismograms and two snapshots   
                      (not required to create the movie)      

04_Create_Movie.sh  - Create wavefield snapshot images and movie (H.264 MP4)


Running the scripts 01, 02, and 04 in order converts a given picture file 
(JPG, PNG, ...) to CWP/SU format, creates synthetic seismogram snapshots 
via acoustic finite differencing (FD), and finally creates a movie from the 
FD results. The X-Window displays are not essential.
An example picture file is included here ("Picture.jpg").


REFERENCES

The CWP/SU: Seismic Un*x Package - a free open seismic processing, research, 
and educational software package: 
    https://wiki.seismic-unix.org 
    https://github.com/JohnWStockwellJr/SeisUnix

ImageMagick:
    https://imagemagick.org
    https://github.com/ImageMagick/ImageMagick

FFMPEG A complete, cross-platform solution to record, convert and stream 
audio and video:
    https://ffmpeg.org


AUTHOR

Nils Maercklin, April 2021

https://github.com/maercklin
https://www.linkedin.com/in/maercklin/
https://www.researchgate.net/profile/Nils-Maercklin
