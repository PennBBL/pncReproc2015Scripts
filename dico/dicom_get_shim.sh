#!/bin/bash
# ---------------------------------------------------------------
# dicom_get_shim.sh
#
# Get the shim current values from a Siemens dicom file
# Writes them out to stdout
# 
# NOTE:
# The entries for the higher order values are sometime missing!
# We write "-99999" in those places
# ---------------------------------------------------------------

Usage() {
    echo ""
    echo "Usage: `basename $0` dicomfile"
    echo ""
    exit 1
}
if [ $# -ne 1 ]; then
    Usage
fi

# --- the old way  ---
#infoA=`dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent"`
#shimsA=( $infoA )
#infoB=`dicom_hdr -sexinfo $1 | grep "sGRADSPEC.lOffset"`
#shimsB=( $infoB )
#if [ ${#shimsA[@]} -eq 15 -a ${#shimsB[@]} -eq 9 ] ; then 
#    echo "${shimsA[2]} ${shimsA[5]} ${shimsA[8]} ${shimsA[11]} ${shimsA[14]} ${shimsB[2]} ${shimsB[5]} ${shimsB[8]}"
#else
#    echo "missing shim entry!"
#    exit 1
#fi

# --- some dicoms are missing certain shim values, so do this cumbersome seach ---
lineX=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.lOffsetX"` )
lineY=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.lOffsetY"` )
lineZ=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.lOffsetZ"` )
line0=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent\[0\]"` )
line1=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent\[1\]"` )
line2=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent\[2\]"` )
line3=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent\[3\]"` )
line4=( `dicom_hdr -sexinfo $1 | grep "sGRADSPEC.alShimCurrent\[4\]"` )

# --- replace any missing shim values with "-99999" ---
vals=""
if [ ${#lineX[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${lineX[2]}"; fi
if [ ${#lineY[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${lineY[2]}"; fi
if [ ${#lineZ[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${lineZ[2]}"; fi
if [ ${#line0[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${line0[2]}"; fi
if [ ${#line1[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${line1[2]}"; fi
if [ ${#line2[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${line2[2]}"; fi
if [ ${#line3[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${line3[2]}"; fi
if [ ${#line4[@]} -ne 3 ]; then vals="$vals -99999"; else vals="$vals ${line4[2]}"; fi

echo $vals

exit 0
