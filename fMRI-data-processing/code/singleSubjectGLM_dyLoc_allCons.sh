#!/bin/bash                      
#SBATCH -t 10:00:00          # walltime = 1 hours and 30 minutes
#SBATCH -N 1                 # one node
#SBATCH -n 2                 # two CPU (hyperthreaded) cores
#SBATCH -o /PATH/TO/faces/code/logs/subjGLM_%j.out
#SBATCH -e /PATH/TO/faces/code/logs/subjGLM_%j.err
#SBATCH --mem=10GB 

# load modules
module load openmind/mrimages/0.1
module load openmind/freesurfer/6.0.0
module load openmind/fsl/5.0.9
module load mit/matlab/2020b

# assign variables
export SUBJECTS_DIR="/PATH/TO/brains/subjAnats/"
export LIBGL_ALWAYS_INDIRECT=1

# Execute commands to run your program here. Here is an example of python.
wkdir=$1
subj=$2

echo "subject = " ${subj}
echo "analysis directory = " ${wkdir}

cd ${wkdir}


for hemi in lh rh
do
	for rList in dylocOdd dylocEven 
	do
		# analyses in fsaverage space
		anaName=dyloc-fsSurf-${hemi}-sm4-${rList}
		# mkanalysis-sess -a ${anaName} -surface fsaverage ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm dyLoc.para  -nconditions 5 -refeventdur 18 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
		# mkcontrast-sess -analysis ${anaName} -contrast FvO -a 1 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast FvBSOSc -a 1 -c 4 -c 2 -c 3 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast SvO -a 3 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast SvFBOSc -a 3 -c 4 -c 2 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast SvSc -a 3 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast BvO -a 2 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast BvFSOSc -a 2 -c 4 -c 3 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast BvSc -a 2 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast OvFBSSc -a 4 -c 2 -c 3 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast OvSc -a 4 -c 5
		selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite

		# analyses in subject-specific surface space
		anaName=dyloc-surfSelf-${hemi}-sm4-${rList}
		# mkanalysis-sess -a ${anaName} -surface self ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm dyLoc.para  -nconditions 5 -refeventdur 18 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
		# mkcontrast-sess -analysis ${anaName} -contrast FvO -a 1 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast FvBSOSc -a 1 -c 4 -c 2 -c 3 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast SvO -a 3 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast SvFBOSc -a 3 -c 4 -c 2 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast SvSc -a 3 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast BvO -a 2 -c 4
		# mkcontrast-sess -analysis ${anaName} -contrast BvFSOSc -a 2 -c 4 -c 3 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast BvSc -a 2 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast OvFBSSc -a 4 -c 2 -c 3 -c 1 -c 5
		# mkcontrast-sess -analysis ${anaName} -contrast OvSc -a 4 -c 5
		selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite

	done

	rList=dylocAllRuns
	# analyses in fsaverage space
	anaName=dyloc-fsSurf-${hemi}-sm4-dylocAll
	# mkanalysis-sess -a ${anaName} -surface fsaverage ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm dyLoc.para  -nconditions 5 -refeventdur 18 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast FvO -a 1 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast FvBSOSc -a 1 -c 4 -c 2 -c 3 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast SvO -a 3 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast SvFBOSc -a 3 -c 4 -c 2 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast SvSc -a 3 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast BvO -a 2 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast BvFSOSc -a 2 -c 4 -c 3 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast BvSc -a 2 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast OvFBSSc -a 4 -c 2 -c 3 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast OvSc -a 4 -c 5
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite
	# analyses in subject-specific surface space
	anaName=dyloc-surfSelf-${hemi}-sm4-dylocAll
	# mkanalysis-sess -a ${anaName} -surface self ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm dyLoc.para  -nconditions 5 -refeventdur 18 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast FvO -a 1 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast FvBSOSc -a 1 -c 4 -c 2 -c 3 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast SvO -a 3 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast SvFBOSc -a 3 -c 4 -c 2 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast SvSc -a 3 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast BvO -a 2 -c 4
	# mkcontrast-sess -analysis ${anaName} -contrast BvFSOSc -a 2 -c 4 -c 3 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast BvSc -a 2 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast OvFBSSc -a 4 -c 2 -c 3 -c 1 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast OvSc -a 4 -c 5
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite

done



# selxavg3-sess -s SAX_EIB_17 -df sessdir -analysis dyloc-surfSelf-rh-sm4-dylocOdd -overwrite
preproc-sess -s SAX_EIB_38 -df sessdir -surface fsaverage rh -per-session -fwhm 2 -force -fsd bold -runlistfile dylocAllRuns

mkanalysis-sess -a dyloc-fsSurf-rh-sm4-dylocAll -surface self rh -fsd bold -fwhm 4 -event-related -per-run -paradigm dyLoc.para  -nconditions 5 -refeventdur 18 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile dylocAll

selxavg3-sess -s SAX_EIB_38 -df sessdir -analysis dyloc-surfSelf-rh-sm4-dylocEven -overwrite


selxavg3-sess -s SAX_EIB_38 -df sessdir -analysis dyloc-fsSurf-rh-sm4-dylocAll -overwrite

selxavg3-sess -s SAX_EIB_38 -df sessdir -analysis dyloc-fsSurf-rh-sm4-dylocAll -overwrite
selxavg3-sess -s SAX_EIB_38 -df sessdir -analysis dyloc-fsSurf-rh-sm4-dylocEven -overwrite





