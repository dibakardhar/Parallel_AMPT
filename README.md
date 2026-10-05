# Parallel_AMPT

A parallelized workflow for running the **A Multi-Phase Transport (AMPT) Model**
across multiple CPU cores using [GNU Parallel](https://www.gnu.org/software/parallel/).

This repository provides:
- The AMPT source code (`ampt.zip`) — unmodified original distribution.
- A ready-to-use workflow to run many AMPT jobs in parallel on a single machine
  or HPC node.
- Instructions for reproducing results, merging outputs, and scaling to large
  event samples.

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
├── ampt.zip                # Original AMPT source code
├── README.md               # This file
├── run_parallel.sh         # GNU Parallel wrapper script
├── config/                 # Example ampt.in config files
│   └── ampt.in
├── scripts/
│   ├── merge_root.sh       # Merge multiple ROOT outputs
│   └── submit_slurm.sh     # SLURM batch submission template
└── output/                 # Output directory (created at runtime)
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

AMPT is controlled by the input file `ampt.in`. A typical example:

```fortran
'input.ampt'            ! input filename
3                       ! frame: 3 = lab
2                       ! collision system flag (2 = AA)
197                     ! mass number A
197                     ! mass number B
200.0                   ! beam energy (GeV)
0                       ! impact parameter mode (0 = fixed)
8.0                     ! impact parameter (fm)
0                       ! npart mode
0                       ! string melting (0 = default)
0                       ! ...
1000                    ! number of events  <-- change per job
.true.                  ! write ROOT output
```

Each parallel job should have:
- Its own **working directory** (`run_001`, `run_002`, …)
- Its own **random seed** (to avoid identical events)
- A unique **output filename**

---

## Running AMPT in Parallel with GNU Parallel

### Step 1 — Prepare N independent run directories
```bash
mkdir -p runs
N=100    # number of parallel jobs

for i in $(seq 1 $N); do
    mkdir -p runs/run_$i
    cp ampt/ampt.x         runs/run_$i/
    cp config/ampt.in      runs/run_$i/
    # inject a unique seed per run
    sed -i "s/^[0-9]*\( *! seed\)/$i\1/" runs/run_$i/ampt.in
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

---

## License

- **AMPT source code** — governed by the original AMPT license; see `ampt.zip`.
- **Wrapper scripts & README** in this repository — MIT License.

---

## Acknowledgements

Thanks to the AMPT authors (Z.-W. Lin, C. M. Ko, B.-A. Li, B. Zhang, S. Pal)
for making the code publicly available.
