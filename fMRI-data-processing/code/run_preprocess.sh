#!/bin/bash                      
#SBATCH -t 03:30:00          # walltime = 1 hours and 30 minutes
#SBATCH -N 1                 # one node
#SBATCH -n 2                 # two CPU (hyperthreaded) cores
#SBATCH -o /PATH/TO/faces/code/logs/preproc_%j.out
#SBATCH -e /PATH/TO/faces/code/logs/preproc_%j.err
#SBATCH --mem=50GB 

# load modules
module load openmind/mrimages/0.1
module load openmind/freesurfer/6.0.0
module load openmind/fsl/5.0.9
module load mit/matlab/2020b

# assign variables
export SUBJECTS_DIR="/PATH/TO/brains/subjAnats/"
export LIBGL_ALWAYS_INDIRECT=1

wkdir=$1
subjList=$2
cd ${wkdir}
preproc-sess ‐sf ${subjList} ‐df sessdir ‐per‐run ‐fsd bold ‐fwhm 0 ‐force

