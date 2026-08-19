#!/bin/bash                      
#SBATCH -t 03:30:00          # walltime = 1 hours and 30 minutes
#SBATCH -N 1                 # one node
#SBATCH -n 2                 # two CPU (hyperthreaded) cores
#SBATCH -o /PATH/TO/faces/code/logs/subjGLM_%j.out
#SBATCH -e /PATH/TO/faces/code/logs/subjGLM_%j.err
#SBATCH --mem=3GB 

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

rList=eib2Runs

# 1 nh nonsocial happy
# 2 nu nonsocial unhappy
# 3 rh reward happy
# 4 ru reward unhappy



for hemi in lh rh
do
	# analyses in fsaverage space
	anaName=eib2-fsSurf-${hemi}-sm4
	# mkanalysis-sess -a ${anaName} -surface fsaverage ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm eib2.para  -nconditions 4 -refeventdur 3 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast NONPOSvsNONNEG -a 1 -c 2
	# mkcontrast-sess -analysis ${anaName} -contrast REWPOSvsREWNEG -a 3 -c 4 
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite 
	# analyses in subject-specific surface space
	anaName=eib2-surfSelf-${hemi}-sm4
	# mkanalysis-sess -a ${anaName} -surface self ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm eib2.para  -nconditions 4 -refeventdur 3 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast NONPOSvsNONNEG -a 1 -c 2
	# mkcontrast-sess -analysis ${anaName} -contrast REWPOSvsREWNEG -a 3 -c 4 
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite 

done
