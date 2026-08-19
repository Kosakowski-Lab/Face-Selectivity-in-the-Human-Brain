#!/bin/bash   


wkdir=/PATH/TO/faces/skerry2014/dyLoc/analysis/
subjList=dylocSubjs  
sbatch run_preprocess.sh ${wkdir} ${subjList}

wkdir=/PATH/TO/faces/skerry2014/eib1/analysis/
subjList=eib1Subjs
sbatch run_preprocess.sh ${wkdir} ${subjList}

wkdir=/PATH/TO/faces/skerry2014/eib2/analysis/
subjList=eib2Subjs
sbatch run_preprocess.sh ${wkdir} ${subjList}

wkdir=/PATH/TO/faces/skerry2014/tom/analysis/
subjList=tomSubjs
sbatch run_preprocess.sh ${wkdir} ${subjList}



