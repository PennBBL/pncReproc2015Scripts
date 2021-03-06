subjlist=${1}
noParcText="/home/arosen/makeGmMaps/noParcSubjs.csv"
subj=$(cat $subjlist | sed -n "${SGE_TASK_ID}p")
bblid=`echo ${subj} | cut -f 1 -d ,`
scanid=`echo ${subj} | cut -f 2 -d ,`
dateid=`echo ${subj} | cut -f 3 -d ,`
antsPath="/data/joy/BBL/studies/pnc/processedData/structural/antsCorticalThickness/${bblid}/${dateid}x${scanid}/"
outImg="atropos3class.nii.gz"
parcImg="/data/joy/BBL/applications/xcpEngine/networks/graspPNCdeepStructures2mm227.nii.gz"
parcDir="graspPNC227"
scriptToCall=""
templateImg="/data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz"
if [ -z ${parcImg} ] ; then 
  echo "${bblid},${scanid},${dateid}" >> ${noParcText}  
else
  /home/arosen/pncReproc2015Scripts/antsCT/postProc/antsCTPostProcAndGMD.sh -d ${antsPath} -o ${outImg} -p ${parcImg} -P ${parcDir} -t ${templateImg} -s 1; 
fi
  
