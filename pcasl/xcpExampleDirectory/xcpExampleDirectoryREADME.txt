This is an example direcoty from the output of the xcpEngine pcasl pipeline.
All of the files ending with .nii.gz are actually text files which contain a very brief explanation of what they would contain.
Files that do not end with .nii.gz are actual output from a subject that has been run through the pipeline.
Here is a breif explanation of all files whihc are not .nii.gz extensions:
	xcpExampleDirectory)
		1.) exampleFile_derivsNative: a file containing a list of images that are in Native space to be used for the norm module
		2.) exampleFile_derivsNorm: a file containing a list of images that have been normalized
		3.) exampleFile.dsn: a subject specific design file
		4.) exampleFile_quality.csv: subject's quality metrics
	xcpExampleDirectory/asl
		1.) exampleFile_aslQuality.csv: a file containing quality metrics computed in the asl module
		2.) exampleFile_aslQuantSST1.log: a log from the output of the qunatifacation for this image
		3.) exampleFile_aslQuantStdT1.log: a log from the output of the qunatifacation for this image
	xcpExampleDirectory/coreg
		1.) exampleFile_coregQuality.csv: a file containing quality metrics computed in the coreg module
		2.) exampleFile_seq2struct.mat: a file containing the transformtaion matrix for the sequence to structural
		3.) exampleFile_seq2struct.png: a image of the transformation
		4.) exampleFile_seq2struct.txt: a text file containing the information from the transformation matrix
		5.) exampleFile_struct2seq.mat: a file containing the transformation matrix for the structural to sequence
		6.) exampleFile_struct2seq.txt:	a text file containing the information from the transformation matrix
	xcpExampleDirectory/dico
		1.) exampleFile_rawQuality.csv: a file containing quality metrics computed in the dico module
		2.) exampleFile_shims.txt: a file detailing the shims computed during the acqusition to try to homogenize the magnetic field
	xcpExampleDirectory/exampleFile_logs
		1.) exampleFile_audit: a file containing a binary indication for if a module completed
		2.) exampleFile_versions: a file containing version information from the xcpEngine used
		3.) pcasl_exampleFile_log: a log file detailing the xcpEngine's processing information
	xcpExampleDirectory/norm
		1.) exampleFile_ep2std.png: a image of the transformation
		2.) exampleFile_normQuality.csv: a file containing quality metrics computed in the norm module
	xcpExampleDirectory/prestats/mc
		1.) disp.png: a image with the displacement metrics computed during the motion correction
		2.) exampleFile_absMeanRMS.txt: a file with the absMeanRMS value
		3.) exampleFile_fd.1D: a file framewise displacment metrics
		4.) exampleFile_realignment.1D: a file with the realignement metrics
		5.) exampleFile_relMeanRMS.txt: a file with the relMeanRMS value
		6.) exampleFile_relRMS.1D: a file with the relRMS for each time point
		7.) exampleFile_rms_nvolFailQA.txt: a file contaiing the number of time points that are excluded due to motion
		8.) exampleFile_tmask.1D: a file indicating which time points to mask out
		9.) rot.png: a image of the roational motion computed during motion correction
		10.) trans.png: a image of the translation motion computed during motion correction
	xcpExampleDirectory/roiquant/GlasserPNC
		1.) exampleFile_GlasserPNC_val_asl_quant_ssT1.1D: a file containing subject specific cbf values for the glasser segmentation
		2.) exampleFile_GlasserPNC_val_asl_quant_stdT1.1D: a file conaining standard T1 cbf values for the glasser segmentation
	xcpExampleDirectory/roiquant/JLF
		1.) exampleFile_JLF_val_asl_quant_ssT1.1D: a file containing subject specific cbf values for the JLF segmentation
		2.) exampleFile_JLF_val_asl_quant_stdT1.1D: a file conaining standard T1 cbf values for the JLF segmentation
		
	
	
