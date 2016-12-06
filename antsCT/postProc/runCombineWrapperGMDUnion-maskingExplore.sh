subjlist=${1}
noParcText="/home/arosen/makeGmMaps/noParcSubjs.csv"
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")
bblid=`echo ${subj} | cut -f 1 -d ,`
scanid=`echo ${subj} | cut -f 2 -d ,`
dateid=`echo ${subj} | cut -f 3 -d ,`
antsPath="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/${dateid}x${scanid}/"
outImg="atropos3class.nii.gz"
parcImg=`ls /data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfLabelsANTsCTIntersection.nii.gz`
parcDir="JLF_Union-MaskingExplore"
templateImg="/data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz"
if [ -z ${parcImg} ] ; then 
  echo "${bblid},${scanid},${dateid}" >> ${noParcText}  
else
  /home/arosen/pncReproc2015Scripts/antsCT/postProc/antsCTPostProcAndGMD.sh -d ${antsPath} -o ${outImg} -p ${parcImg} -P ${parcDir} -t ${templateImg} -s 0; 
fi
  
