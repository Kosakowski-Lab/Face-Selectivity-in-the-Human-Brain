#!/bin/bash   

# EvLab DyLoc
wkdir=/PATH/TO/faces/EvLab/dyLoc/analysis/
for SUBJ in sub121 sub164 sub197 sub256 sub301 sub345 sub376 sub425 sub041 sub124 sub165 sub198 sub257 sub320 sub348 sub377 sub426 sub050 sub125 sub166 sub199 sub260 sub322 sub349 sub382 sub427 sub053 sub127 sub168 sub201 sub261 sub323 sub350 sub401 sub522 sub072 sub129 sub170 sub207 sub265 sub326 sub363 sub402 sub523 sub087 sub135 sub172 sub211 sub266 sub327 sub364 sub403 sub091 sub138 sub173 sub212 sub267 sub329 sub365 sub405 sub093 sub143 sub174 sub214 sub288 sub330 sub366 sub408 sub094 sub147 sub175 sub224 sub289 sub334 sub368 sub409 sub097 sub158 sub179 sub248 sub290 sub338 sub369 sub416 sub102 sub160 sub184 sub249 sub291 sub342 sub370 sub417 sub115 sub162 sub185 sub252 sub292 sub343 sub371 sub423 sub120 sub163 sub189 sub255 sub296 sub344 sub375 sub424
do
	sbatch singleSubjectGLM_dyLoc_allCons.sh ${wkdir} ${SUBJ}
done

# # EvLab gesture
# wkdir=/PATH/TO/faces/EvLab/gesture/analysis/
# for SUBJ in sub189 sub214 sub256 sub261 sub266 sub291 sub426 sub168 sub211 sub255 sub257 sub265 sub267 sub292
# do
# 	sbatch singleSubjectGLM_gesture.sh ${wkdir} ${SUBJ}
# done
