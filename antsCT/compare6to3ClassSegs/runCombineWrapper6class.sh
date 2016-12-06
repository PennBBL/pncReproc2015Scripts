subjlist=${1}
noParcText="/home/arosen/makeGmMaps/noParcSubjs.csv"
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")
bblid=`echo ${subj} | cut -f 1 -d ,`
scanid=`echo ${subj} | cut -f 2 -d ,`
dateid=`echo ${subj} | cut -f 3 -d ,`
antsPath="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/${dateid}x${scanid}/"
outImg="atropos3class6classmask.nii.gz"
parcImg="/data/joy/BBL/studies/pnc/processedData/structural/jlf/${bblid}/${dateid}x${scanid}/${bblid}_${dateid}x${scanid}_jlfLabels.nii.gz"
parcDir="JLF6classexplore"
scriptToCall=""
templateImg="/data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz"
if [ -z ${parcImg} ] ; then 
  echo "${bblid},${scanid},${dateid}" >> ${noParcText}  
else
  /home/arosen/pncReproc2015Scripts/antsCT/compare6to3ClassSegs/antsCTPostProcAndGMD6classMask.sh -d ${antsPath} -o ${outImg} -p ${parcImg} -P ${parcDir} -t ${templateImg} -s 0; 
fi
  
