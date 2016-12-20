##############################################################################
################        DRAMMS RAVENS CREATION SCRIP           ###############
################           Angel Garcia de la Garza            ###############
################              angelgar@upenn.edu               ###############
################                 10/17/2016                    ###############
##############################################################################

##Read in Arguments from command line

## List of subjects
listSubjects=$1

#Path where qeue should output logs
logPath=$2

#Root of input paths
InRoot=$3

##Root of output paths
OutRoot=$4

LOG_FILE=`ls -d $logPath`;

##PNC Template Path
pncTemplate=`ls -d /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz`;

#Echo out the name of the list of subjects
echo $listSubjects

priorCTGM=`ls -d /data/joy/BBL/studies/pnc/template/priors/prior_grey_thr01_1mm.nii.gz`


#Start loop to submit job per subject
cat $listSubjects | while read i; do 
    
    #grep bblid and scan id 
    bblid=`echo $i | cut -d "," -f1`; 
    scanid=`echo $i | cut -d "," -f2`; 
    
    echo $bblid,$scanid;
    
    #Find output directory
    subDir=`ls -d ${OutRoot}/${bblid}/${scanid}/`;
    echo $subDir;

    ##Find extracted brain, segmentation from atropos
    mprage=`ls -d ${InRoot}/${bblid}/${scanid}/ExtractedBrain0N4.nii.gz`;
    seg=`ls -d ${InRoot}/${bblid}/${scanid}/atropos3class_seg.nii.gz`;

    ##DRAMMS needs a segmentation in character datatype so you need to create it 
    name=`echo ${InRoot}/${bblid}/${scanid}/atropos3class_seg_char`;
    fslmaths $seg $name -odt "char";
    

    #Name deformation field 
    defName=`echo ${subDir}/${bblid}_${scanid}_deformation_field.nii.gz`;

    #Name Brain in Template Space
    OutName=`echo ${bblid}_${scanid}_BrainExtractedT1_inTemplateSpace.nii.gz`;
    
    #Name ravens output 
    ravens=`echo ${subDir}/${bblid}_${scanid}_RAVENS`;

    #Out Text file with Mean over CT GM
    ctOut=`echo ${subDir}/${bblid}_${scanid}_MeanGM_CT_RAVENS2.txt`

    #Create script 
    #Create command for dramms
    command=` echo /data/joy/BBL/applications/dramms/bin/dramms -S $mprage -T $pncTemplate -D $defName -R $ravens -l 1,2,3 -L $name`;

    #Create command for mean over CT GM 
    commandMean=`echo fslstats ${ravens}_2.nii.gz -k ${priorCTGM} -M '>' ${subDir}/${bblid}_${scanid}_MeanGM_CT_RAVENS2.txt`;
    
    #Create command to warp template to subject space
    tempSuSpaceName=`echo ${subDir}/${bblid}_${scanid}_templateInSubjectSpace`
    commandWarp=`echo /data/joy/BBL/applications/dramms/bin/dramms-warp $pncTemplate $defName $tempSuSpaceName`

    commandPath=`echo ${LOG_FILE}/temp.sh`
    echo '#!/bin/bash' > $commandPath
    echo 'echo List of Subjects:' $listSubjects >> $commandPath
    echo 'echo Logs Output Path:' $logPath >> $commandPath
    echo 'echo Input Directory Root:' $InRoot >> $commandPath
    echo 'echo Output Directory Root:' $OutRoot >> $commandPath
    echo 'echo' $bblid,$scanid >> $commandPath
    echo 'echo' $command >> $commandPath
    echo $command >> $commandPath
    echo 'echo' $commandWarp >> $commandPath
    echo $commandWarp >> $commandPath
    echo 'echo' $commandMean >> $commandPath
    echo $commandMean >> $commandPath

    name=`echo DRAMMS_${bblid}_${scanid}`;

    #Submit to qeue
    qsub -cwd -o ${LOG_FILE} -e ${LOG_FILE} -N $name -l h_vmem=14.5G,s_vmem=14.0G  $commandPath 

done
