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

rList=eib1Runs

# 1 mu male unhappy
# 2 fu female unhappy
# 3 mh male happy
# 4 fh female happy
# 5 nu non-social unhappy
# 6 su social unahppy
# 7 nh non-social happy
# 8 sh social happy

# analyses in fsaverage space
for hemi in lh rh
do
	# analyses in fsaverage space
	anaName=eib1-fsSurf-${hemi}-sm4
	# mkanalysis-sess -a ${anaName} -surface fsaverage ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm eib1.para  -nconditions 8 -refeventdur 3 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast SOCvsNON -a 6 -a 8 -c 5 -c 7
	# mkcontrast-sess -analysis ${anaName} -contrast FACEvsCART -a 1 -a 2 -a 3 -a 4 -c 5 -c 6 -c 7 -c 8
	# mkcontrast-sess -analysis ${anaName} -contrast HAPvsSAD -a 3 -a 4 -a 7 -a 8 -c 1 -c 2 -c 5 -c 6
	# mkcontrast-sess -analysis ${anaName} -contrast SOCPOSvsSOCNEG -a 8 -c 6
	# mkcontrast-sess -analysis ${anaName} -contrast NONPOSvsNONNEG -a 7 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast FACEPOSvsFACENEG -a 3 -a 4 -c 1 -c 2
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite 
	# analyses in subject-specific surface space
	anaName=eib1-surfSelf-${hemi}-sm4
	# mkanalysis-sess -a ${anaName} -surface self ${hemi} -fsd bold -fwhm 4 -event-related -per-run -paradigm eib1.para  -nconditions 8 -refeventdur 3 -tpexclude exTPs.txt -TR 2 -spmhrf 0 -polyfit 1 -mcextreg -runlistfile ${rList}
	# mkcontrast-sess -analysis ${anaName} -contrast SOCvsNON -a 6 -a 8 -c 5 -c 7
	# mkcontrast-sess -analysis ${anaName} -contrast FACEvsCART -a 1 -a 2 -a 3 -a 4 -c 5 -c 6 -c 7 -c 8
	# mkcontrast-sess -analysis ${anaName} -contrast HAPvsSAD -a 3 -a 4 -a 7 -a 8 -c 1 -c 2 -c 5 -c 6
	# mkcontrast-sess -analysis ${anaName} -contrast SOCPOSvsSOCNEG -a 8 -c 6
	# mkcontrast-sess -analysis ${anaName} -contrast NONPOSvsNONNEG -a 7 -c 5
	# mkcontrast-sess -analysis ${anaName} -contrast FACEPOSvsFACENEG -a 3 -a 4 -c 1 -c 2
	selxavg3-sess -s ${subj} -df sessdir -analysis ${anaName} -overwrite 

done
