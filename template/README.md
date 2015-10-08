# pncReproc2015

re-processing PNC data on CFN in consistent/reproducible fashion which can be applied across all developmental datasets

project directory for this is here:

/data/jag/BBL/projects/pncReproc2015

This github repo is cloned and operates from here:

/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts

Steps thus far:

1) Some re-organization to ensure consistent naming of T1

/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/reOrg/renameRawT1.sh

1) Select template subject sample:

/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template//selectTemplateSampleV2.R

Associated markdown file is here (executed locally rather than on cluster)

/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template//selectTemplateSampleV2.Rmd 

PDF output w/ sanity checking is here:

/data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template//selectTemplateSampleV2.pdf

Subject lists and demo data for 120 subjects are here:

/data/jag/BBL/projects/pncReproc2015/template/subjectLists

Symlinked images to be used for template are here:

/data/jag/BBL/projects/pncReproc2015/template/images/


2) Creating an initial template with buildTemplateParallel

Initially ran this without a target, rigid + affine only

//data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template/initialTemplate1Btp.sh

Output here:

/data/jag/BBL/projects/pncReproc2015/template/initialTemplate1

Second iteration using that as a target, default parameters

//data/jag/BBL/projects/pncReproc2015/pncReproc2015Scripts/template/initialTemplate2Btp.sh

Output here:

/data/jag/BBL/projects/pncReproc2015/template/initialTemplate2/






