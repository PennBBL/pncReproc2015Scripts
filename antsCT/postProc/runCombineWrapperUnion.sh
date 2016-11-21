subjlist=${1}
noParcText="/home/arosen/makeGmMaps/noParcSubjs.csv"
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")
bblid=`echo ${subj} | cut -f 1 -d ,`
scanid=`echo ${subj} | cut -f 2 -d ,`
dateid=`echo ${subj} | cut -f 3 -d ,`
antsPath="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/${dateid}x${scanid}/BrainSegmentation.nii.gz"
parcImg=`ls /data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfLabels.nii.gz`
outputImage="/data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfLabelsANTsCTUnion.nii.gz"
/home/arosen/pncReproc2015Scripts/antsCT/createUnionJLFAndCTGMMask.sh ${parcImg} ${antsPath} ${outputImage} /home/arosen/volDiff.csv   
