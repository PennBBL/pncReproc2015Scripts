#!/bin/bash

# Do FA values
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/n2416_64dir_nativespace_fa_JHU-ICBM-tracts-maxprob-thr25-1mm-LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals2.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_path_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals3.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *fa*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmpVals3.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/merged.csv
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_path_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_path_nativespace2_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects -name *fa*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/tmpValsL3.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAValues/tmp/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now do AD
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/n2416_64dir_nativespace_ad_JHU-ICBM-tracts-maxprob-thr25-1mm-LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals2.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals3.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *ad*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmpVals3.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/merged.csv
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace2_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects -name *ad*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/tmpValsL3.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepADValues/tmp/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1


# Now do RD
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/n2416_64dir_nativespace_rd_JHU-ICBM-tracts-maxprob-thr25-1mm-LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals1.csv
#rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals2.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals2.csv
#rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals3.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *rd*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace2_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects -name *rd*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/tmpValsL3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDValues/tmp/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now do TR
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/n2416_64dir_nativespace_tr_JHU-ICBM-tracts-maxprob-thr25-1mm-LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals1.csv
#rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals2.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path2_nativespace_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals2.csv
#rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals3.csv
#for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-tracts-maxprob-thr0-1mm-LPI-2dtitk_lstat/subjects/ -name *_tr_*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path2_nativespace_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_path_nativespace3_JHU-ICBM-Labels-1mm_LPI_2dtitk_lstat/subjects -name *_tr_*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/tmpValsL3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepTRValues/tmp/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1


## Now do all of the GM ROI's
# Start with FA
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_path_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_path_nativespace2_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_jlf_path_nativespace3_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects -name *fa*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepFAGMValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1


# Now do AD 
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_ad_path_nativespace2_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/tmpVals3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_jlf_path_nativespace3_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects -name *_ad_*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepADGMValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now do RD
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_rd_path_nativespace2_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_jlf_path_nativespace3_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects -name *_rd_*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepRDGMValues/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1

# Now do TR
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals1.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path2_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals1.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals2.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_tr_path_nativespace_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects/ -name *_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals2.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals3.csv
for i in `find /data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/dtitk_fa_ad_tr_rd_jlf_path_nativespace3_pncTemplateJLF_Labels_LPI_2dtitk_go1_n14_template_lstat/subjects -name *_tr_*_mean.csv` ; do vals=`tr -s '\n' ',' < ${i} | tr -d '"'` ; echo "${i},${vals}" ; done >> /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/tmpVals3.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/merged.csv
rm /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/merged.csv
cd /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/
/home/arosen/adroseHelperScripts/bash/mergeCSV.sh 1
mv /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/tmp/merged.csv /data/joy/BBL/projects/pncReproc2015/diffusion/prepMDValues/

## Now do WM lobes
for i in tr ad rd fa ; do 
  tmpPath="/data/joy/BBL/projects/pncReproc2015/diffusionResourceFiles/S-lstat_extraction_lists/n2416_64dir_nativespace_${i}_pncTemplateJLF_WMSegmentation_LPI_2dtitk_go1_n14_template_lstat/subjects/"
  tmpOutput="/data/joy/BBL/projects/pncReproc2015/diffusion/prep${i}WMLobularVal/"
  mkdir -p ${tmpOutput}
  rm ${tmpOutput}/*csv
  for d in `find ${tmpPath} -name "*_mean.csv"` ; do 
    vals=`tr -s '\n' ',' < ${d} | tr -d '"'`
    echo ${d},${vals} >> ${tmpOutput}merged.csv ; 
  done
done
