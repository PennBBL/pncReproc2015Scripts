subjlist=${1}
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")
bblid=`echo ${subj} | cut -f 1 -d ,`
scanid=`echo ${subj} | cut -f 2 -d ,`
dateid=`echo ${subj} | cut -f 3 -d ,`
inputImage="/data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfLabels.nii.gz"
outputImage="/data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfWmSeg.nii.gz"
/data/joy/BBL/projects/pncReproc2015/pncReproc2015Scripts/jlf/wmSegmentation/createDistanceMetricsMask.sh ${inputImage} ${outputImage}
