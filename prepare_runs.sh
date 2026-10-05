#!/usr/bin/env bash
# ============================================================
# prepare_runs.sh
# ------------------------------------------------------------
# Creates N independent run directories, each containing:
#   - a copy of the AMPT executable
#   - a copy of ampt.in with UNIQUE random seeds injected
#   - an empty log directory
#
# Two seed lines are tagged in config/ampt.in:
#   - HIJING seed  -> tagged with  ! hijing_seed
#   - ZPC seed     -> tagged with  ! zpc_seed
#
# Usage:
#   ./prepare_runs.sh [N_RUNS] [RUN_DIR] [BINARY] [TEMPLATE]
#
# Example:
#   ./prepare_runs.sh 100 runs ampt/ampt.x config/ampt.in
# ============================================================

set -euo pipefail

N_RUNS=${1:-10}                        # number of runs to create
RUN_DIR=${2:-runs}                     # output parent directory
BINARY=${3:-ampt/ampt.x}               # compiled AMPT executable
TEMPLATE=${4:-config/ampt.in}          # template input file

# --- sanity checks -----------------------------------------
if [ ! -f "${BINARY}" ]; then
    echo "ERROR: AMPT binary '${BINARY}' not found."
    echo "       Did you compile AMPT first? (cd ampt && make)"
    exit 1
fi

if [ ! -f "${TEMPLATE}" ]; then
    echo "ERROR: template '${TEMPLATE}' not found."
    exit 1
fi

# verify the seed tags exist in the template
if ! grep -q '! hijing_seed' "${TEMPLATE}"; then
    echo "ERROR: tag '! hijing_seed' not found in ${TEMPLATE}."
    echo "       Add it to the HIJING random-seed line."
    exit 1
fi
if ! grep -q '! zpc_seed' "${TEMPLATE}"; then
    echo "ERROR: tag '! zpc_seed' not found in ${TEMPLATE}."
    echo "       Add it to the parton-cascade random-seed line."
    exit 1
fi

# --- create parent dir -------------------------------------
mkdir -p "${RUN_DIR}"

echo "==============================================="
echo " Preparing ${N_RUNS} run directories"
echo "-----------------------------------------------"
echo " Parent dir : ${RUN_DIR}"
echo " Binary     : ${BINARY}"
echo " Template   : ${TEMPLATE}"
echo "==============================================="

# --- loop over runs ----------------------------------------
for i in $(seq 1 "${N_RUNS}"); do

    # zero-padded run id (e.g. run_007)
    RUN_ID=$(printf "%03d" "${i}")
    THIS_DIR="${RUN_DIR}/run_${RUN_ID}"

    mkdir -p "${THIS_DIR}"
    cp "${BINARY}"   "${THIS_DIR}/ampt.x"
    cp "${TEMPLATE}" "${THIS_DIR}/ampt.in"
    chmod +x         "${THIS_DIR}/ampt.x"

    # --- inject unique seeds per run -----------------------
    # HIJING seed: unique per run
    sed -i "s/^[0-9]\+\( *! *hijing_seed\)/${i}\1/" "${THIS_DIR}/ampt.in"

    # ZPC seed: offset by 100000 so it differs from HIJING seed
    # (change the offset if you prefer a different scheme)
    ZPC_SEED=$(( i + 100000 ))
    sed -i "s/^[0-9]\+\( *! *zpc_seed\)/${ZPC_SEED}\1/" "${THIS_DIR}/ampt.in"

    echo "[OK] ${THIS_DIR}  (hijing_seed=${i}, zpc_seed=${ZPC_SEED})"
done

echo "==============================================="
echo " Done. ${N_RUNS} directories created."
echo " Next step: ./run_parallel.sh 8 ${RUN_DIR}"
echo "==============================================="
