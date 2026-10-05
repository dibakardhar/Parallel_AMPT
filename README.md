# Parallel_AMPT

![License](https://img.shields.io/badge/license-GPLv3-blue)
![AMPT](https://img.shields.io/badge/AMPT-parallel-green)
![GNU Parallel](https://img.shields.io/badge/GNU%20Parallel-required-orange)

A parallelized workflow for running the **A Multi-Phase Transport (AMPT) Model**
across multiple CPU cores using [GNU Parallel](https://www.gnu.org/software/parallel/).

This repository provides:
- The AMPT source code (`ampt.zip`) — unmodified original distribution.
- A ready-to-use workflow to run many AMPT jobs in parallel on a single machine
  or HPC node.
- Instructions for reproducing results, merging outputs, and scaling to large
  event samples.

---

## ⚡ Quick Start

```bash
git clone https://github.com/dibakardhar/Parallel_AMPT.git
cd Parallel_AMPT
unzip ampt.zip && cd ampt && make && cd ..
chmod +x prepare_runs.sh run_parallel.sh scripts/*.sh
./prepare_runs.sh 10 runs
./run_parallel.sh 4 runs
./scripts/merge_root.sh runs merged.root
```

That's it — 10 independent AMPT runs, 4 executed in parallel, merged into one
ROOT file.

---

## 📚 Table of Contents

1. [About AMPT](#about-ampt)
2. [Original Source & Citation](#original-source--citation)
3. [Repository Contents](#repository-contents)
4. [Prerequisites](#prerequisites)
5. [Installation](#installation)
6. [Configuration](#configuration)
7. [Running AMPT in Parallel with GNU Parallel](#running-ampt-in-parallel-with-gnu-parallel)
8. [Merging Output](#merging-output)
9. [Scaling to HPC / SLURM](#scaling-to-hpc--slurm)
10. [Troubleshooting](#troubleshooting)
11. [License](#license)
12. [Acknowledgements](#acknowledgements)

---

## About AMPT

**AMPT (A Multi-Phase Transport)** is a widely used Monte Carlo event generator
for relativistic heavy-ion collisions. It simulates the full collision evolution
including:

- Initial conditions from HIJING
- Partonic scatterings via ZPC / Zhang's Parton Cascade
- Hadronization via quark coalescence
- Hadronic rescatterings via ART

For more details, see the official AMPT page:
🔗 https://myweb.ecu.edu/linz/ampt/

---

## Original Source & Citation

The AMPT source code included here (`ampt.zip`) is **unmodified** and is
redistributed for convenience. All credit belongs to the original authors.

**Please cite the following papers if you use AMPT in your research:**

```bibtex
@article{Lin:2004nb,
  author  = {Lin, Zi-Wei and Ko, Che Ming and Li, Bao-An and Zhang, Bin and Pal, Subrata},
  title   = {A Multi-phase transport model for relativistic heavy ion collisions},
  journal = {Phys. Rev. C},
  volume  = {72},
  pages   = {064901},
  year    = {2005},
  doi     = {10.1103/PhysRevC.72.064901},
  eprint  = {nucl-th/0411110},
}

@article{Lin:2000ke,
  author  = {Lin, Zi-Wei and Ko, Che Ming and Li, Bao-An and Zhang, Bin and Pal, Subrata},
  title   = {Multiphase transport model for relativistic heavy ion collisions},
  journal = {Phys. Rev. C},
  volume  = {64},
  pages   = {011902},
  year    = {2001},
  doi     = {10.1103/PhysRevC.64.011902},
}
```

Additional references (HIJING, ZPC, ART) are listed inside the AMPT manual
`ampt.pdf` included in `ampt.zip`.

**Original download:**
🔗 https://myweb.ecu.edu/linz/ampt/

---

## Repository Contents

```
Parallel_AMPT/
├── README.md               # This file
├── LICENSE
├── .gitignore
├── ampt.zip                # Original AMPT source code
├── prepare_runs.sh         # Creates N unique run directories
├── run_parallel.sh         # Launches all runs with GNU Parallel
├── config/
│   └── ampt.in             # AMPT input file (with seed tags)
└── scripts/
    ├── merge_root.sh       # Merge multiple ROOT outputs
    └── submit_slurm.sh     # SLURM batch submission template
```

---

## Prerequisites

Before running, ensure the following are installed:

| Package        | Version       | Purpose                        |
|----------------|---------------|--------------------------------|
| GCC / GFortran | ≥ 4.8         | Compile AMPT                   |
| ROOT           | ≥ 5.34 / 6.x  | Analysis & NTuple output       |
| GNU Parallel   | ≥ 20161222    | Parallel job scheduling        |
| make           | any           | Build system                   |
| unzip          | any           | Extract source                 |

Install GNU Parallel on Debian/Ubuntu:
```bash
sudo apt-get install parallel
```

On RHEL/CentOS:
```bash
sudo yum install parallel
```

On macOS (Homebrew):
```bash
brew install parallel
```

> ⚠️ Note: GNU Parallel is different from `moreutils`'s `parallel`. Verify with
> `parallel --version` — it must report **GNU parallel**.

---

## Installation

### Step 1 — Clone the repository
```bash
git clone https://github.com/dibakardhar/Parallel_AMPT.git
cd Parallel_AMPT
```

### Step 2 — Extract AMPT source
```bash
unzip ampt.zip
cd ampt
```

### Step 3 — Set environment variables
Add to your `~/.bashrc` (adjust paths to your system):
```bash
export ROOTSYS=/path/to/root
export PATH=$ROOTSYS/bin:$PATH
export LD_LIBRARY_PATH=$ROOTSYS/lib:$LD_LIBRARY_PATH
```

### Step 4 — Compile AMPT
```bash
source ~/.bashrc
make
```
This produces the executable `ampt.x` (or `ampt`) in the source directory.

---

## Configuration

AMPT is controlled by the input file `config/ampt.in`. This repository ships
the real AMPT input file with **two tagged seed lines** — `! hijing_seed` and
`! zpc_seed` — that `prepare_runs.sh` uses to inject a unique seed into every
parallel run.

```fortran
900            ! EFRM (sqrt(S_NN) in GeV if FRAME is CMS)
CMS             ! FRAME
A               ! PROJ
A               ! TARG
1             ! IAP (projectile A number)
1              ! IZP (projectile Z number)
1             ! IAT (target A number)
1             ! IZT (target Z number)
100		! NEVNT (total number of events)
0.              ! BMIN (mininum impact parameter in fm)
1.		! BMAX (maximum impact parameter in fm, also see below)
4		! ISOFT (D=4): select Default AMPT or String Melting(see below)
150		! NTMAX: number of timesteps (D=150), see below
0.2		! DT: timestep in fm (hadron cascade time= DT*NTMAX) (D=0.2)
0.30		! PARJ(41): parameter a in Lund symmetric splitting function
0.15    	! PARJ(42): parameter b in Lund symmetric splitting function
1	      	! (D=1,yes;0,no) flag for popcorn mechanism(netbaryon stopping)
1.0	      	! PARJ(5) to control BMBbar vs BBbar in popcorn (D=1.0)
1		! shadowing flag (Default=1,yes; 0,no)
0		! quenching flag (D=0,no; 1,yes)
2.0		! quenching parameter -dE/dx (GeV/fm) in case quenching flag=1
2.0		! p0 cutoff in HIJING for minijet productions (D=2.0)
2.265d0  	! parton screening mass in fm^(-1) (D=2.265d0), see below
0		! IZPC: (D=0 forward-angle parton scatterings; 100,isotropic)
0.33d0		! alpha in parton cascade (D=0.33d0), see parton screening mass
1d6		! dpcoal in GeV
1d6		! drcoal in fm
0		! ihjsed: take HIJING seed from below (D=0)or at runtime(11)
13150909	! random seed for HIJING  ! hijing_seed
8		! random seed for parton cascade  ! zpc_seed
0		! flag for K0s weak decays (D=0,no; 1,yes)
1		! flag for phi decays at end of hadron cascade (D=1,yes; 0,no)
0		! flag for pi0 decays at end of hadron cascade (D=0,no; 1,yes)
0		! optional OSCAR output (D=0,no; 1,yes; 2&3,more parton info)
0		! flag for perturbative deuteron calculation (D=0,no; 1or2,yes)
1		! integer factor for perturbative deuterons(>=1 & <=10000)
1		! choice of cross section assumptions for deuteron reactions
-7.		! Pt in GeV: generate events with >=1 minijet above this value
1000		! maxmiss (D=1000): maximum # of tries to repeat a HIJING event
3		! flag on initial and final state radiation (D=3,both yes; 0,no)
1		! flag on Kt kick (D=1,yes; 0,no)
0		! flag to turn on quark pair embedding (D=0,no; 1,yes)
7., 0.		! Initial Px and Py values (GeV) of the embedded quark (u or d)
0., 0.		! Initial x & y values (fm) of the embedded back-to-back q/qbar
1, 5., 0.       ! nsembd(D=0), psembd (in GeV),tmaxembd (in radian).
0 		! Flag to enable users to modify shadowing (D=0,no; 1,yes)
1.d0		! Factor used to modify nuclear shadowing
0		! Flag for random orientation of reaction plane (D=0,no; 1,yes)
```

Each parallel job should have:
- Its own **working directory** (`runs/run_001`, `runs/run_002`, …)
- Its own **HIJING seed** (tagged `! hijing_seed`)
- Its own **ZPC seed** (tagged `! zpc_seed`)

`prepare_runs.sh` handles all of this automatically.

---

## Running AMPT in Parallel with GNU Parallel

### Step 1 — Prepare N independent run directories

Use the helper script (recommended):

```bash
chmod +x prepare_runs.sh
./prepare_runs.sh 100 runs ampt/ampt.x config/ampt.in
```

This creates `runs/run_001/`, `runs/run_002/`, … each containing:
- a copy of `ampt.x`
- a copy of `config/ampt.in` with unique seeds injected

Manual equivalent (if you prefer to do it yourself):

```bash
mkdir -p runs
N=100
for i in $(seq 1 $N); do
    RUN_ID=$(printf "%03d" "$i")
    mkdir -p "runs/run_${RUN_ID}"
    cp ampt/ampt.x     "runs/run_${RUN_ID}/"
    cp config/ampt.in  "runs/run_${RUN_ID}/"
    sed -i "s/^[0-9]\+\( *! *hijing_seed\)/$i\1/"       "runs/run_${RUN_ID}/ampt.in"
    ZPC_SEED=$(( i + 100000 ))
    sed -i "s/^[0-9]\+\( *! *zpc_seed\)/${ZPC_SEED}\1/" "runs/run_${RUN_ID}/ampt.in"
done
```

### Step 2 — Run all jobs in parallel

Using the provided wrapper `run_parallel.sh`:

```bash
#!/usr/bin/env bash
# run_parallel.sh
# Usage: ./run_parallel.sh <N_JOBS> <RUN_DIR>

N_JOBS=${1:-8}
RUN_DIR=${2:-runs}

ls -d ${RUN_DIR}/run_* | \
  parallel -j ${N_JOBS} --joblog parallel.log --progress \
    'cd {} && ./ampt.x > ampt.log 2>&1'
```

Execute:

```bash
chmod +x run_parallel.sh
./run_parallel.sh 8 runs
```

### Step 3 — Explanation of GNU Parallel flags

| Flag            | Meaning                                                        |
|-----------------|----------------------------------------------------------------|
| `-j N`          | Run N jobs simultaneously (set to number of physical cores)    |
| `--joblog FILE` | Writes a log of each job (start, end, exit status)             |
| `--progress`    | Shows live progress bar                                        |
| `--halt now,fail=1` | (optional) Stop everything if any job fails                |
| `--bar`         | (alternative) ASCII progress bar                               |

### Step 4 — Verify completion

```bash
grep -c "DONE" runs/run_*/ampt.log       # each log should show DONE
ls runs/run_*/ampt.out                   # ROOT / text output per job
```

---

## Merging Output

If AMPT writes ROOT files, merge them with `hadd`:

```bash
# scripts/merge_root.sh
#!/usr/bin/env bash
hadd -f merged_ampt.root runs/run_*/ampt.out
```

Or merge plain-text files:

```bash
cat runs/run_*/ampt.dat > merged_ampt.dat
```

> ℹ️ The exact output filename (`ampt.out`, `ampt.dat`, …) depends on the AMPT
> version. Check inside a completed `runs/run_*/` directory to confirm.

---

## Scaling to HPC / SLURM

On a cluster, replace GNU Parallel with a SLURM array job. Template:

```bash
#!/usr/bin/env bash
#SBATCH --job-name=ampt
#SBATCH --array=1-100
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

cd runs/run_${SLURM_ARRAY_TASK_ID}
./ampt.x > ampt.log 2>&1
```

Submit with:

```bash
sbatch scripts/submit_slurm.sh
```

You can still use GNU Parallel **inside** each node for multi-core runs.

---

## Troubleshooting

| Problem                             | Fix                                                        |
|-------------------------------------|------------------------------------------------------------|
| `parallel: command not found`       | Install GNU Parallel (not moreutils)                       |
| All jobs produce identical events   | Ensure each `ampt.in` has a unique random seed             |
| `ampt.x: Permission denied`         | `chmod +x ampt.x`                                          |
| ROOT library not found              | Set `LD_LIBRARY_PATH=$ROOTSYS/lib`                         |
| Output files overwrite each other   | Run each job in its own directory (as shown above)         |
| Jobs stall                          | Reduce `-j` to match physical cores, not logical threads   |
| `sed` fails on macOS                | Use `sed -i '' "s/.../.../"` (add empty backup arg)        |

---

## License

- **AMPT source code** — governed by the original AMPT license; see `ampt.zip`.
- **Wrapper scripts & documentation** in this repository — 
  **GNU General Public License v3.0** (see [`LICENSE`](LICENSE)).
  
---

## Acknowledgements

Thanks to the AMPT authors (Z.-W. Lin, C. M. Ko, B.-A. Li, B. Zhang, S. Pal)
for making the code publicly available.

---

## 🧪 Tested With

| OS              | Compiler | ROOT  | GNU Parallel | AMPT       |
|-----------------|----------|-------|--------------|------------|
| Ubuntu 22.04    | gcc 11   | 6.28  | 20210822     | v2.26t9b   |
| Rocky Linux 9   | gcc 11   | 6.28  | 20210822     | v2.26t9b   |
