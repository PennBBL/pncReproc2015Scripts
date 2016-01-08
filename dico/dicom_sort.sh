#!/bin/bash
# ---------------------------------------------------------------
# DICOM_SORT.sh
#
# Take a list of dicom filenames and 
#   echo back the filenames sorted in order by series, echo and image number.
#
# NOTE: this script does NOT rename dicom files or write the files to new folders.
#   It just prints the filenames in sorted order to stdout.
#
# Created: M Elliott 6/2013
# ---------------------------------------------------------------

if [ $# -lt 3 ]; then
	echo "usage: `basename $0` dcmfile1 [-get_series_info] dcmfile2 [dcmfile3 ... dcmfileN]"
	exit 1
fi

# --- Check if -get_series_info flag was set ---
get_series_info=0
case $1 in 
    -get_series_info)   get_series_info=1    
                        shift ;;

    -*)                 echo "Unrecognized switch: $1"
                        exit 1 ;;

     *)                  ;;
esac

dcmfiles=( $@ )
ndcm=${#dcmfiles[@]}

# --- Sort files by series, echo and image number ----
tmpdir=`mktemp -d`                              # make a temp working folder
filelist=$tmpdir/filelist.txt
touch $filelist
#seriescount[999]="x";       # don't need this to initialize array size
nseries=0;
for (( i=0;   i<$ndcm;  i++ )); do
    dcminfo=(`dicom_hdr ${dcmfiles[$i]} 2>/dev/null | grep "Series Number"`) 
    np=${#dcminfo[@]}
    snum=`echo ${dcminfo[$np-1]} | tr -d 'Number//'`

    dcminfo=(`dicom_hdr ${dcmfiles[$i]} 2>/dev/null | grep "Instance Number"`) 
    np=${#dcminfo[@]}
    inum=`echo ${dcminfo[$np-1]} | tr -d 'Number//'`

    dcminfo=(`dicom_hdr ${dcmfiles[$i]} 2>/dev/null | grep "Echo Number"`) 
    np=${#dcminfo[@]}
    enum=`echo ${dcminfo[$np-1]} | tr -d 'Number//'`

    xnum=$(( $snum * 10000 + $enum * 1000 + $inum ))    # make an index to sort    
    echo "${dcmfiles[$i]} $xnum " >> $filelist

    # count how many files found in each series
    if [ "${seriescount[$snum]}" = "" ]; then 
        seriescount[$snum]=1;
        let nseries+=1
    else 
        let seriescount[$snum]+=1
    fi
done
sortfile=$tmpdir/sortlist.txt; sort -n -k 2 $filelist > $sortfile             # sort by the column of "xnums"
cutfile=$tmpdir/cutlist.txt; cut -f 1 --delimiter=" " $sortfile > $cutfile    # cut out the column sorted filenames
dcmfiles=( `cat $cutfile` )
echo ${dcmfiles[@]}

if [ $get_series_info -eq 1 ]; then
    echo "Series_info: $nseries ${seriescount[@]}"
fi

rm -f $tmpdir/filelist.txt $tmpdir/sortlist.txt $tmpdir/cutlist.txt 
rmdir $tmpdir
exit 0
