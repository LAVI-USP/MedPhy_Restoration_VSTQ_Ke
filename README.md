# Image Restoration in Digital Mammography Using VSTQ and Spatially Correlated Noise Modeling

MATLAB implementation of a framework for noise modeling, variance stabilization, image restoration, and human observer evaluation in digital mammography.

The repository contains the computational methods developed to investigate the effect of signal-dependent and spatially correlated noise on digital mammography images and to evaluate an image restoration approach based on the variance-stabilizing transform for quadratic noise (VSTQ) and BM3D.

The repository includes tools for:

* Quadratic noise model parameter estimation;
* Spatial noise correlation characterization;
* VSTQ transformation;
* Inverse VSTQ lookup table (LUT) estimation;
* Image restoration using VSTQ and BM3D;
* Human observer experiments, including pilot and final tests.

---

## Overview

Noise is an important factor affecting image quality and lesion detectability in digital mammography, particularly at reduced radiation doses.

The framework implemented in this repository models the main noise contributions in digital mammography using a quadratic noise model and explicitly accounts for spatial variations and spatial correlations in the detector noise.

The complete workflow can be summarized as:

```text
Noise parameter estimation
       │
       ▼
Quadratic noise model
       │
       ▼
VSTQ / inverse VSTQ LUT estimation
       │
       ▼
Mammography image restoration
       │
       ▼
Human observer evaluation
```

---

# 1. Noise Model

The restoration framework is based on a quadratic noise model:

```text
Var[y] = ξₛ² y² + ξq(i,j)y + ξₑ²
```

where:

* `y` is the detector signal after offset subtraction;
* `ξₛ` represents the structural noise component;
* `ξq(i,j)` is the spatially varying quantum noise coefficient;
* `ξₑ` represents the electronic noise component.

This formulation accounts for three main noise contributions:

1. Structural noise;
2. Quantum noise;
3. Electronic noise.

The quantum noise coefficient is allowed to vary spatially across the detector, providing a more realistic representation of detector nonuniformity.

---

# 2. Noise Parameter Estimation

The detector noise parameters used in this repository were estimated from repeated homogeneous calibration images. For further information on the estimation and analysis of detector noise parameters using uniform images, see the [CBEB 2026 Noise Estimation and Analysis repository](https://github.com/LAVI-USP/CBEB2026_Noise_Estimation_and_Analysis).

The estimation procedure includes:

1. Detector offset correction;
2. Detrending of the calibration images;
3. Local mean estimation;
4. Local variance estimation;
5. Estimation of the spatially varying quantum noise coefficient `ξq(i,j)`;
6. Estimation of the structural noise parameter `ξₛ`;
7. Estimation of the electronic noise parameter `ξₑ`.

The estimated parameters are stored in the `NoiseParameters/` directory and are subsequently used by the VSTQ transformation and image restoration procedures.

---

# 3. Spatial Noise Correlation

In addition to the signal-dependent variance, the framework accounts for spatial correlation in the detector noise.

The spatial correlation is characterized using homogeneous calibration images after removing the spatially varying signal component.

A spatial correlation kernel is estimated and normalized before being used in the restoration framework.

The corresponding noise power spectral density (PSD) can be obtained from the Fourier transform of the normalized correlation kernel.

The estimated kernel is stored in:

```text
NoiseParameters/Kernel_GE_Pristina.mat
```

and is used to characterize the correlation of the noise present in the detector images.

---

# 4. VSTQ Transformation

The variance-stabilizing transform for quadratic noise (VSTQ) is used to convert the signal-dependent noise into an approximately signal-independent representation.

The transformation uses the estimated quadratic noise model parameters:

* `ξₛ`;
* `ξₑ`;
* `ξq(i,j)`.

The spatially varying `ξq(i,j)` map is therefore incorporated directly into the transformation.

The VSTQ processing can be summarized as:

```text
Offset-corrected image
        │
        ▼
Quadratic noise model
        │
        ▼
Spatially varying ξq(i,j)
        │
        ▼
Forward VSTQ
        │
        ▼
Approximately signal-independent noise
```

The effectiveness of the transformation can be verified by comparing the noise standard deviation before and after the transformation over different signal levels.

---

# 5. Inverse VSTQ LUT Estimation

The inverse VSTQ transformation is implemented using a precomputed lookup table (LUT).

The LUT is generated numerically using Monte Carlo simulations of the quadratic noise model.

The LUT estimation procedure consists of:

1. Define a range of detector signal values;
2. Define a range of quantum noise coefficients `ξq`;
3. Generate realizations of the quadratic noise model;
4. Apply the forward VSTQ transformation;
5. Estimate the expected transformed signal;
6. Store the corresponding signal-to-VSTQ relationship;
7. Construct the inverse mapping;
8. Generate the final inverse VSTQ LUT.

The resulting LUT provides an efficient numerical approximation of the inverse transformation.

This approach avoids performing a computationally expensive numerical inversion independently for every pixel during image restoration.

The LUT files are stored in:

```text
NoiseParameters/LUT_IVSTQ.mat
```

### LUT Generation

The LUT estimation scripts are located in:

```text
est_LUT_IVSTQ.m
```

The main parameters controlling the LUT generation include:

* Signal range;
* `ξq` range;
* Number of Monte Carlo realizations;
* LUT sampling density.

The LUT resolution should be selected according to the desired trade-off between inversion accuracy, memory usage, and computational time.

---

# 6. Image Restoration

The image restoration pipeline combines VSTQ, BM3D, spatial noise correlation information, and inverse VSTQ.

The complete restoration procedure is:

```text
Input image
    │
    ▼
Offset subtraction
    │
    ▼
Forward VSTQ
    │
    ▼
Normalization
    │
    ▼
BM3D denoising
    │
    ▼
Denormalization
    │
    ▼
Inverse VSTQ LUT
    │
    ▼
Image Blending
    │
    ▼
Restored image
```

The main demonstration script is:

```text
Restoration_framework/Demo_VSTQ_BM3D_Restoration.m
```

The demo performs the complete restoration pipeline using phantom images and previously estimated detector parameters.

---

## BM3D Denoising

BM3D is applied in the VSTQ domain, where the noise is approximately signal-independent.

The transformed image is normalized before denoising, and the corresponding noise level is adjusted according to the normalization factor.

The spatial correlation information is characterized through the estimated noise correlation kernel and its corresponding frequency-domain representation.

After denoising, the image is returned to its original VSTQ scale before the inverse transformation.

The BM3D implementation used in this work is included in:

```text
BM3D_New/
```

---

# 7. Human Observer Study

The restoration method was evaluated using a human observer study designed to assess whether the proposed image restoration improves the detectability of simulated microcalcifications in digital mammography images.

The observer study consists of two stages:

```text
Pilot study
     │
     ▼
Observer-specific threshold estimation
     │
     ▼
Final 4AFC experiment
     │
     ▼
Detection performance
```

## 7.1 Pilot Test

The pilot experiment uses a staircase procedure to estimate an individual contrast threshold for each observer.

The purpose of the pilot test is to determine an appropriate difficulty level for the subsequent detection experiment while accounting for differences in observer performance.

The pilot-test code will be provided in:

```text
HumanObserver/Pilot/
```

**Status:** Coming soon.

---

## 7.2 Final Human Observer Test

The final experiment uses a four-alternative forced-choice (4AFC) paradigm.

Each observer evaluates images containing simulated microcalcification clusters under different image-processing conditions.

The final experiment includes:

* Individualized stimulus levels based on the pilot test;
* Restored and non-restored images;
* Multiple experimental cases;
* Two reading sessions;
* A minimum washout period between sessions;
* Observer detection accuracy as the primary performance measure.

The final-test code will be provided in:

```text
HumanObserver/FinalTest/
```

**Status:** Coming soon.

---

# 8. Requirements

The code was developed and tested using MATLAB.

Required components include:

* MATLAB 2025b;
* Image Processing Toolbox;
* DICOM image support.

The BM3D implementation required by the restoration demo is included in the repository.

The MATLAB version used for the final implementation will be specified in the corresponding scripts and documentation.

---

# 9. Detector-Specific Parameters

The provided restoration demonstration uses parameters estimated for a GE Senographe Pristina digital mammography system.

The parameter files include:

| Parameter | Description                                 |
| --------- | ------------------------------------------- |
| `τ`       | Detector offset                             |
| `ξₛ`      | Structural noise parameter                  |
| `ξq(i,j)` | Spatially varying quantum noise coefficient |
| `ξₑ`      | Electronic noise parameter                  |
| `Ke`      | Spatial noise correlation kernel            |
| `IVSTQ`   | Inverse VSTQ lookup table                   |

These parameters are detector-specific and should not be directly transferred to another mammography system.

For application to another detector, the corresponding calibration data should be acquired and the noise parameters, correlation kernel, and inverse VSTQ LUT should be re-estimated.

---

# 10. Data and Reproducibility

The repository is intended to provide reproducible implementations of the methods described in the associated research work.

The restoration pipeline depends on detector-specific calibration parameters. Therefore, reproducibility requires the use of the corresponding noise parameters, spatial correlation kernel, and inverse VSTQ LUT provided with the repository.

The human observer experiments additionally require the corresponding image databases and experimental configurations.

Data that cannot be publicly redistributed will not be included in the repository. In such cases, the repository will provide the scripts and instructions required to reproduce the corresponding processing steps using appropriately prepared data.

---

# 11. Applications

The methods implemented in this repository can be used for research involving:

* Digital mammography image restoration;
* Low-dose mammography;
* Signal-dependent noise modeling;
* Spatially correlated detector noise;
* Variance-stabilizing transformations;
* Noise parameter estimation;
* Image denoising;
* Image quality assessment;
* Mammography image simulation;
* Microcalcification detectability;
* Human observer studies.

The code is intended for research purposes and is not designed for clinical diagnosis or direct clinical deployment.

---

# 12. Citation

If you use this repository or the implemented methods in your research, please cite the associated publication:

```text
[Publication information will be added after publication.]
```

---

# 13. Contact

Renann F. Brandão
Laboratory for Advanced Vision and Imaging (LAVI)
University of São Paulo (USP)
São Carlos, SP, Brazil

For questions, suggestions, or issues related to the implementation, please open an issue in this repository.

---

## Acknowledgments

This work was developed at the Laboratory for Advanced Vision and Imaging (LAVI), University of São Paulo (USP).

The authors acknowledge the institutions and research programs that supported the development of this work.
