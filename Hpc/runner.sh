#!/bin/bash -l

#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --array=1-80%80
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

##################################
# Setup random seed info
##################################
EXPERIMENT_OFFSET=0
SEED=$((SLURM_ARRAY_TASK_ID + EXPERIMENT_OFFSET))

##################################
# Treatments
##################################

NSGA2__MIN=1
NSGA2__MAX=40

LEXICASE__MIN=41
LEXICASE__MAX=80


##################################
# Conditions
##################################

if [ ${SLURM_ARRAY_TASK_ID} -ge ${NSGA2__MIN} ] && [ ${SLURM_ARRAY_TASK_ID} -le ${NSGA2__MAX} ] ; then
  SELECTION=NSGA2

elif [ ${SLURM_ARRAY_TASK_ID} -ge ${LEXICASE__MIN} ] && [ ${SLURM_ARRAY_TASK_ID} -le ${LEXICASE__MAX} ] ; then
  SELECTION=Lexicase

else
  echo "${SEED} from ${PROBLEM} failed to launch" >> /home/hernandezj45/Repos/GPTP-2O24-FINAL/GPTP-2024-Lexicase-Analysis/Results/failtolaunch.txt
fi

##################################
# Data dump directory
##################################

DATA_DIR=/home/hernandezj45/Repos/AutoQTL-Adventures/Results/${SELECTION}/${SEED}

python /home/hernandezj45/Repos/AutoQTL-Adventures/selection-diff.py \
--selection ${SELECTION} \
--seed ${SEED} \
--savepath ${DATA_DIR}