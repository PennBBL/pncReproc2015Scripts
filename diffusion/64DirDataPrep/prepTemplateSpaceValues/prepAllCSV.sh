#!/bin/bash
# This script will be used to combine all of the values in template space for the diffusion data.
# It is going to mirror VERY closley to the script that does this for the natiuve space images
# Poor BASH coding practice very much so abound here. 
# Written by AFGR 

# Define any ststics up here
scriptPath="/home/arosen/pncReproc2015Scripts/diffusion/64DirDataPrep/"
dateValue=`date +%Y%m%d`
dataFreeze="/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/"
tmpDataDir="/data/joy/BBL/projects/pncReproc2015/diffusion/"

# First rm any dangerouse files that could come from differing sources
rm ${tmpDataDir}/prepFAValues/*csv
rm ${tmpDataDir}/prepADValues/*csv
rm ${tmpDataDir}/prepRDValues/*csv
rm ${tmpDataDir}/prepTRValues/*csv


# Do FA values
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_fa_path1_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_fa_path2_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals2.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now produce these values and store them into the data freeze directory
# Special steps will have to be taken here in order to make sure both 
Rscript ${scriptPath}/prepFAValues/prepFaValues.R
mv ${dataFreeze}/n1601_JHUTractFA_${dateValue}.csv ${dataFreeze}/n1601_JHUTractFA_TemplateSpace_${dateValue}.csv 
rm ${dataFreeze}/n1601_JHULabelsFA_${dateValue}.csv

# Now onto AD values
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_ad_path_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_ad_path2_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals2.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# now as ever, produce the values
Rscript ${scriptPath}/prepADValues/prepADValues.R
mv ${dataFreeze}/n1601_JHUTractAD_${dateValue}.csv ${dataFreeze}/n1601_JHUTractAD_TemplateSpace_${dateValue}.csv 
rm ${dataFreeze}/n1601_JHULabelsAD_${dateValue}.csv

# Now onto RD values
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_rd_path_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_rd_path2_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals2.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# AND NOW WHODA GUESSED IT LETS PREP THE VALUES!
Rscript ${scriptPath}/prepRDValues/prepRDValues.R
mv ${dataFreeze}/n1601_JHUTractRD_${dateValue}.csv ${dataFreeze}/n1601_JHUTractRD_TemplateSpace_${dateValue}.csv 
rm ${dataFreeze}/n1601_JHULabelsRD_${dateValue}.csv

# Now onto TR
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_tr_path_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/go2416_64dir_tr_path2_JHU_ROIs_in_GO1space_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals2.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now produce em 
Rscript ${scriptPath}/prepTRValues/prepTRValues.R
mv ${dataFreeze}/n1601_JHUTractTR_${dateValue}.csv ${dataFreeze}/n1601_JHUTractTR_TemplateSpace_${dateValue}.csv 
rm ${dataFreeze}/n1601_JHULabelsTR_${dateValue}.csv
