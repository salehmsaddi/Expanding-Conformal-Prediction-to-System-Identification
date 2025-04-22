# Expanding-Conformal-Prediction-to-System-Identification
MATLAB implementation of the following paper:

```text
TO BE ADDED
```

We kindly ask that you cite the above-mentioned paper if you use **Conformal System Identification (C-SysID)** in your research or publish work based on these codes.

## Overview

This repository provides a MATLAB implementation of **C-SysID**, an approach that integrates *Conformal Prediction* with *System Identification* to quantify uncertainty in dynamic models.

We provide:
- An example for **single-output C-SysID** on the *Heat Exchanger* dataset.
- An example for **multi-output C-SysID** on the *CD Arm Player* dataset.

Each example includes:
- A `simulate_*.m` script to run experiments and save results into a structure.
- A `getResults_*.m` script to post-process the results and generate the tables and figures used in the paper.

If you prefer not to re-run the simulations, you can directly use the saved `resultsFile_*.mat` files and proceed with `getResults_*.m`.

---

> *Feel free to explore, experiment, and build on top of this work. Contributions, feedback, and extensions are always welcome.*

---

## Contact

For questions, feedback, or collaborations, feel free to open an issue or contact the authors directly.
