#!/usr/bin/env bash
# ============================================================
# merge_root.sh
# ------------------------------------------------------------
# Merges all AMPT ROOT outputs produced by the parallel runs
# into a single ROOT file using `hadd`.
#
# Usage:
#   ./merge_root.sh [RUN_DIR] [OUTPUT_FILE]
#
# Example:
#   ./merge_root.sh runs merged_ampt.root
# ============================================================

set -euo pipefail

RUN_DIR=${1:-runs}
OUTPUT=${2:-merged_ampt.root}

# --- sanity checks -----------------------------------------
if ! command -v hadd >/dev/null 2>&1; then
    echo "ERROR: 'hadd' not found. Source ROOT first:"
    echo "       source \$ROOTSYS/bin/thisroot.sh"
    exit 1
fi

if [ ! -d "${RUN_DIR}" ]; then
    echo "ERROR: run directory '${RUN_DIR}' does not exist."
    exit 1
fi

# --- collect output files ----------------------------------
FILES=$(ls ${RUN_DIR}/run_*/ampt.out 2>/dev/null || true)
if [ -z "${FILES}" ]; then
    echo "ERROR: no ampt.out files found in ${RUN_DIR}/run_*/"
    exit 1
fi

N_FILES=$(echo "${FILES}" | wc -l)
echo "==============================================="
echo " Merging ${N_FILES} ROOT files"
echo " Output : ${OUTPUT}"
echo "==============================================="

# --- merge --------------------------------------------------
hadd -f "${OUTPUT}" ${FILES}

echo "==============================================="
echo " Done. Merged file: ${OUTPUT}"
ls -lh "${OUTPUT}"
echo "==============================================="
