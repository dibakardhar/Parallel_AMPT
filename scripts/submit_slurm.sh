#!/usr/bin/env bash
# ============================================================
# submit_slurm.sh
# ------------------------------------------------------------
# SLURM array-job template for running AMPT on a cluster.
# Each array task handles one run_* directory.
#
# Usage:
#   sbatch submit_slurm.sh
#
# Adjust --array to match the number of run_* directories.
# ============================================================

#SBATCH --job-name=ampt
#SBATCH --array=1-100
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=24:00:00
#SBATCH --output=slurm_logs/ampt_%A_%a.out
#SBATCH --error=slurm_logs/ampt_%A_%a.err

set -euo pipefail

# --- create log directory ----------------------------------
mkdir -p slurm_logs

# --- environment -------------------------------------------
# Uncomment / adjust for your cluster:
# module load root
# module load gcc

RUN_ID=${SLURM_ARRAY_TASK_ID}
RUN_DIR="runs/run_${RUN_ID}"

echo "==============================================="
echo " SLURM job : ${SLURM_JOB_ID}"
echo " Array ID  : ${RUN_ID}"
echo " Run dir   : ${RUN_DIR}"
echo " Node      : $(hostname)"
echo " Started   : $(date)"
echo "==============================================="

if [ ! -d "${RUN_DIR}" ]; then
    echo "ERROR: ${RUN_DIR} does not exist."
    exit 1
fi

# --- run AMPT ----------------------------------------------
cd "${RUN_DIR}"
./ampt.x > ampt.log 2>&1

echo "==============================================="
echo " Finished : $(date)"
echo "==============================================="
