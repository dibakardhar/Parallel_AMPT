#!/usr/bin/env bash
# ============================================================
# run_parallel.sh
# ------------------------------------------------------------
# Runs all AMPT jobs inside runs/run_* in parallel using
# GNU Parallel.
#
# Usage:
#   ./run_parallel.sh [N_JOBS] [RUN_DIR]
#
# Example:
#   ./run_parallel.sh 8 runs
# ============================================================

set -euo pipefail

N_JOBS=${1:-8}          # number of parallel jobs (default: 8)
RUN_DIR=${2:-runs}      # directory containing run_* subdirs

# --- sanity checks -----------------------------------------
if ! command -v parallel >/dev/null 2>&1; then
    echo "ERROR: GNU Parallel not found. Install it first."
    exit 1
fi

if [ ! -d "${RUN_DIR}" ]; then
    echo "ERROR: run directory '${RUN_DIR}' does not exist."
    exit 1
fi

# --- count jobs --------------------------------------------
N_RUNS=$(ls -d ${RUN_DIR}/run_* 2>/dev/null | wc -l)
if [ "${N_RUNS}" -eq 0 ]; then
    echo "ERROR: no run_* directories found in '${RUN_DIR}'."
    exit 1
fi

echo "==============================================="
echo " Parallel AMPT run"
echo "-----------------------------------------------"
echo " Run directory : ${RUN_DIR}"
echo " Total jobs    : ${N_RUNS}"
echo " Parallel slots: ${N_JOBS}"
echo "==============================================="

# --- launch -------------------------------------------------
start_time=$(date +%s)

ls -d ${RUN_DIR}/run_* | \
  parallel -j "${N_JOBS}" \
           --joblog parallel.log \
           --progress \
           --halt now,fail=1 \
    'cd {} && echo "[START] {}" && ./ampt.x > ampt.log 2>&1 && echo "[DONE]  {}"'

end_time=$(date +%s)
elapsed=$(( end_time - start_time ))

echo "==============================================="
echo " All jobs finished in ${elapsed} seconds."
echo " Job log: parallel.log"
echo "==============================================="
