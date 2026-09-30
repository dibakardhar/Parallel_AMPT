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
