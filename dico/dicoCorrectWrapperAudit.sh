#!/bin/bash
# ---------------------------------------------------------------
# dicoCorrectWrapperAudit.sh
#
# Use this script to find how many 1.) complete raw B0's exist,
#	2.) How many rps maps exist
#	3.) How many restBolds exist
#	4.) How many pcasl's exist
#	5.) How many idemo and fracbacks exist
#
# afgr December 10 2015
# ---------------------------------------------------------------

# Now grab all of the subjects and scan dates that we are going to be cycling through for the various modalities 
myName=`whoami`
timeOfExecution=`date +%y_%m_%d_%H_%M_%S`
allRawSubjList=`find /data/joy/BBL/studies/pnc/rawData/ -maxdepth 2 -mindepth 2 -type d`
allBblid=`echo ${allRawSubjList} | cut -f 8 -d '/'`
allScanandDate=`echo ${allRawSubjList} | cut -f 9 -d '/'`
allScanid=`echo ${allScanandDate} | cut -f 1 -d 'x'`
allDateid=`echo ${allScanandDate} | cut -f 2 -d 'x'`
allSubjLength=`echo ${allRawSubjList} | wc -l`
outputCSV="/home/${myName}/auditOutput_${timeOfExecution}.csv"


# Prime a output audit csv
echo "BBLID,SCANID,DATE,b0map,restbold100,restbold124,restbolddico,pcasl,pcasldico,idemo,idemodico,frac2back,frac2backdico,rpsMap,flagStatus"  > ${outputCSV}

# Now declare some statics
processedDataPath="/data/joy/BBL/studies/pnc/processedData"
rpsMapPath="${processedDataPath}/b0map/"
fracPath="${processedDataPath}/frac2back/dico/"
restPath="${processedDataPath}/restbold/dico/"
idemoPath="${processedDataPath}/idemo/dico/"
pcaslPath="${processedDataPath}/pcasl/dico/"
rawDataPath="/data/joy/BBL/studies/pnc/rawData/"



# Now begin a for loop which will go through each subject and look to see if directoryes and files are present
for indPath in ${allRawSubjList} ; do
  echo "Now working on ${indPath}"
  
  # Set all of the check variables to 0
  b0MapStatus=0
  restBold100Status=0
  restBold124Status=0
  restBoldDicoStatus=0
  pcaslStatus=0
  pcaslDicoStatus=0
  idemoStatus=0
  idemoDicoStatus=0
  frac2backStatus=0
  frac2backDicoStatus=0
  rpsMapStatus=0
  flagStatus=""

  # Now grab some subject dependent values
  bblid=`echo ${indPath} | cut -f 8 -d '/'`
  scanAndDate=`echo ${indPath} | cut -f 9 -d '/'`
  scanId=`echo ${scanAndDate} | cut -f 2 -d 'x'`
  dateId=`echo ${scanAndDate} | cut -f 1 -d 'x'`

  # Now go through each flag and declare if it is there or not
  rawDataSubjPath="${rawDataPath}${bblid}/${dateId}x${scanId}/"

  # loop through each directory for each modality and find the images of interest
  # Start with b0 maps
  for b0check in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*B0MAP*"` ; do
    b0MapStatus=$((b0MapStatus+1)) ; 
  done

  # Now do restbolds 100 volumes 
  for restCheck in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*restbold*100"` ; do
    for restScanCheck in `find ${restCheck} -type f -name "*nii.gz"` ; do
      restBold100Status=$((restBold100Status+1)) ; 
    done
  done

  # Now do restbold 124 volumes
  for restCheck in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*restbold*124"` ; do
    for restScanCheck in `find ${restCheck} -type f -name "*nii.gz"` ; do
      restBold124Status=$((restBold124Status+1)) ;
    done 
  done

  # Now do the restbold dico
  if [ ${restBold124Status} > 0 ] ; then
    for restCheck in `find ${restPath}${bblid}/${dateId}x${scanId}/ -maxdepth 1 -mindepth 1 -type f -name "*dico.nii"` ; do 
      restBoldDicoStatus=$((restBoldDicoStatus+1)) ; 
    done
  fi
  # Now do the pcasl raw scan... wihich will be a little bit more interesting
  for pcaslCheck in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*pcasl*"` ; do
    quietRun=`ls ${pcaslCheck}/nifti/*SEQ??.nii.gz` ;
    if [ ! -z "${quietRun}" ] ; then
      pcaslStatus=$((pcaslStatus+1)) ;
    else
       queitRun=`ls ${pcaslCheck}/nifti/*1200ms.nii.gz` ;
       if [ ! -z "${queitRun}" ] ; then
         pcaslStatus=$((pcaslStatus+1)) ; 
       fi
    fi
  done
  
  # Now do the dico pcasl
  if [ ${pcaslStatus} > 0 ] ; then 
    for pcaslCheck in `find ${pcaslPath}${bblid}/${dateId}x${scanId}/ -maxdepth 1 -mindepth 1 -type f -name "*dico.nii"` ; do
      pcaslDicoStatus=$((pcaslDicoStatus+1)) ; 
    done
  fi
  
  # Now do the idemo data 
  for idemoCheck in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*idemo*"` ; do
    for idemoScanCheck in `find ${idemoCheck} -maxdepth 2 -type f -name "*nii.gz"` ; do 
      idemoStatus=$((idemoStatus+1)) ; 
    done
  done

  # Now do the idemo dico
  if [ ${idemoStatus} > 0 ] ; then 
    for idemoCheck in `find ${idemoPath}${bblid}/${dateId}x${scanId}/ -maxdepth 1 -mindepth 1 -type f -name "*dico.nii"` ; do
       idemoDicoStatus=$((idemoDicoStatus+1)) ; 
    done
  fi

  # Now do the frac back noise and what not
  for fracCheck in `find ${rawDataSubjPath} -maxdepth 1 -mindepth 1 -type d -name "*frac2back*"` ; do
    for fracScanCheck in `find ${fracCheck} -type f -name "*nii.gz"` ; do
      frac2backStatus=$((frac2backStatus+1)) ; 
    done
  done

  # Now frac dico
  if [ ${frac2backStatus} > 0 ] ; then
    for fracCheck in `find ${fracPath}${bblid}/${dateId}x${scanId}/ -maxdepth 1 -mindepth 1 -type f -name "*dico.nii"` ; do
      frac2backDicoStatus=$((frac2backDicoStatus+1)) ;
    done
  fi

  # Now do that other noise... errr rps maps
  if [ ${b0MapStatus} > 0 ] ; then 
    for rpsCheck in `find ${rpsMapPath}${bblid}/${dateId}x${scanId}/ -maxdepth 1 -mindepth 1 -type f -name "*rps*"` ; do
      rpsMapStatus=$((rpsMapStatus+1)) ; 
    done
  fi
  
  # Now go through a series of flag checks and if any of them come back positivie change the flag to 1
  if [[ ${b0MapStatus} -gt "0" && ${rpsMapStatus} -eq 0 ]] ; then
    flagStatus+=1 ; 
  fi
  if [[ ${rpsMapStatus} -ge "1" && ${restBold124Status} -gt "0" && ${restBoldDicoStatus} -eq "0" ]] ; then
    flagStatus+=2 ; 
  fi
  if [[ ${rpsMapStatus} -ge "1" && ${pcaslStatus} -gt "0" && ${pcaslDicoStatus} -eq "0" ]] ; then
    flagStatus+=3 ;
  fi
  if [[ ${rpsMapStatus} -ge "1" && ${idemoDicoStatus} -gt "0" && ${idemoDicoStatus} -eq "0" ]] ; then
    flagStatus+=4 ; 
  fi
  if [[ ${rpsMapStatus} -ge "1" && ${frac2backStatus} -gt "0" && ${frac2backDicoStatus} -eq "0" ]] ; then
    flagStatus+=5 ; 
  fi
  


  # Now echo some back of of this junk 
  echo "${bblid},${scanId},${dateId},${b0MapStatus},${restBold100Status},${restBold124Status},${restBoldDicoStatus},${pcaslStatus},${pcaslDicoStatus},${idemoStatus},${idemoDicoStatus},${frac2backStatus},${frac2backDicoStatus},${rpsMapStatus},${flagStatus}" >> ${outputCSV}
 
done
