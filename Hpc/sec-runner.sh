#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-120%120
#SBATCH -t 2:00:00
#SBATCH --mem=1GB
#SBATCH --job-name=aqtl
#SBATCH -p defq,moore
#SBATCH --exclude=esplhpc-cp040

##################################
# Setup environment
##################################

source /home/hernandezj45/anaconda3/etc/profile.d/conda.sh
conda activate autoqtl-env
 pip install -e autoqtl

##################################
# Setup random seed info
##################################
EXPERIMENT_OFFSET=80
SEED=$((SLURM_ARRAY_TASK_ID + EXPERIMENT_OFFSET))

##################################
# Treatments
##################################

MAX_ERROR__MIN=1
MAX_ERROR__MAX=40

MEANAE__MIN=41
MEANAE__MAX=80

MEDIANAE__MIN=81
MEDIANAE__MAX=120


##################################
# Conditions
##################################

if [ ${SLURM_ARRAY_TASK_ID} -ge ${MAX_ERROR__MIN} ] && [ ${SLURM_ARRAY_TASK_ID} -le ${MAX_ERROR__MAX} ] ; then
  SCORER=neg_mean_absolute_error
  DIR=MeanAE

elif [ ${SLURM_ARRAY_TASK_ID} -ge ${MEANAE__MIN} ] && [ ${SLURM_ARRAY_TASK_ID} -le ${MEANAE__MAX} ] ; then
  SCORER=neg_median_absolute_error
  DIR=MedianAE

elif [ ${SLURM_ARRAY_TASK_ID} -ge ${MEDIANAE__MIN} ] && [ ${SLURM_ARRAY_TASK_ID} -le ${MEDIANAE__MAX} ] ; then
  SCORER=max_error
  DIR=MaxError

else
  echo "${SEED} from ${PROBLEM} failed to launch" >> /home/hernandezj45/Repos/GPTP-2O24-FINAL/GPTP-2024-Lexicase-Analysis/Results/failtolaunch.txt
fi

##################################
# Data dump directory
##################################

DATA_DIR=/home/hernandezj45/Repos/AutoQTL-Adventures/Results/${DIR}/${SEED}

python /home/hernandezj45/Repos/AutoQTL-Adventures/selection-diff.py \
--selection ${SCORER} \
--seed ${SEED} \
--savepath ${DATA_DIR}