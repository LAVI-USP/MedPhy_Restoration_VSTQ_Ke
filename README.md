# Image Restoration in Digital Mammography Using VSTQ and Spatially Correlated Noise Modeling

MATLAB implementation of an image restoration framework for digital mammography (DM) based on a quadratic noise model, the variance-stabilizing transform for quadratic noise (VSTQ), and BM3D denoising with spatially correlated noise information.

This repository contains the implementation developed for research on noise modeling and image restoration in digital mammography, with particular emphasis on signal-dependent and spatially correlated detector noise.

---

## Overview

Noise is an important factor affecting image quality and lesion detectability in digital mammography, particularly at reduced radiation dose.

The implemented restoration framework addresses the signal dependence and spatial correlation of detector noise by combining:

* A quadratic noise model;
* A spatially varying quantum noise coefficient;
* The variance-stabilizing transform for quadratic noise (VSTQ);
* Noise correlation information estimated from calibration images;
* BM3D denoising in the VSTQ domain;
* An inverse VSTQ transformation for image reconstruction.

The VSTQ transforms the signal-dependent noise into an approximately signal-independent representation, allowing conventional image denoising techniques to be applied more effectively.

The complete processing pipeline is:

```text
Input mammography images
        │
        ▼
Offset subtraction
        │
        ▼
Forward VSTQ
        │
        ▼
Noise stabilization
        │
        ▼
BM3D denoising
        │
        ▼
Inverse VSTQ
        │
        ▼
Restored mammography image
```

---

## Noise Model

The restoration framework is based on the quadratic noise model

```text
Var[y] = ξₛ² y² + ξq(i,j) y + ξₑ²
```

where:

* `y` is the offset-corrected detector signal;
* `ξₛ` is the structural noise parameter;
* `ξq(i,j)` is the spatially varying quantum noise coefficient;
* `ξₑ` is the electronic noise parameter.

The spatially varying coefficient `ξq(i,j)` accounts for local variations in the detector response and is incorporated directly into the VSTQ transformation.

The model therefore describes three main noise contributions:

1. Structural noise;
2. Quantum noise;
3. Electronic noise.

The spatial correlation of the detector noise is characterized using a normalized correlation kernel estimated from homogeneous calibration images.

---

## Processing Workflow

The restoration demo is implemented as a MATLAB script that performs the following steps:

1. Load the estimated detector noise parameters.
2. Load the inverse VSTQ lookup table.
3. Load the spatial noise correlation kernel.
4. Read repeated phantom images.
5. Subtract the detector offset.
6. Apply the forward VSTQ transformation.
7. Verify the effectiveness of the variance stabilization.
8. Normalize the transformed images.
9. Estimate the noise power spectrum associated with the spatial correlation kernel.
10. Apply BM3D denoising in the VSTQ domain.
11. Undo the normalization.
12. Apply the inverse VSTQ transformation.
13. Generate the restored mammography images.

The main demonstration script is intended to provide a compact example of the complete restoration pipeline.

---

## Repository Structure

The repository is organized as follows:

```text
.
├── BM3D_New/
│   └── bm3d/
│       └── ...
│
├── Functions/
│   ├── ...
│   └── ...
│
├── NoiseParameters/
│   ├── Parameters/
│   │   └── ...
│   ├── LUT/
│   │   └── ...
│   └── Kernel/
│       └── ...
│
├── Phantom images/
│   └── ...
│
├── Demo_Restoration.m
│
└── README.md
```

### `BM3D_New/`

Contains the BM3D implementation used for denoising in the VSTQ domain.

### `Functions/`

Contains auxiliary MATLAB functions required by the restoration pipeline, including VSTQ validation and image-processing routines.

### `NoiseParameters/`

Contains the detector-specific parameters required by the restoration method.

These include:

* Estimated quadratic noise-model parameters;
* Spatially varying quantum noise coefficient `ξq(i,j)`;
* Inverse VSTQ lookup table;
* Spatial noise correlation kernel.

### `Phantom images/`

Contains the repeated homogeneous or phantom mammography images used in the demonstration.

---

## Detector Parameters

The restoration framework requires previously estimated detector parameters.

For the GE Senographe Pristina system, the parameter files include:

| Parameter | Description                                 |
| --------- | ------------------------------------------- |
| `τ`       | Detector offset                             |
| `ξₛ`      | Structural noise parameter                  |
| `ξq(i,j)` | Spatially varying quantum noise coefficient |
| `ξₑ`      | Electronic noise parameter                  |
| `Ke`      | Spatial noise correlation kernel            |
| `IVSTQ`   | Inverse VSTQ lookup table                   |

These parameters should be estimated from calibration data acquired using the same detector system before applying the restoration framework to clinical or phantom images.

---

## VSTQ Transformation

The forward VSTQ transformation is applied after detector-offset subtraction.

The transformation incorporates the estimated parameters of the quadratic noise model and the spatially varying quantum noise coefficient `ξq(i,j)`.

The purpose of the transformation is to convert the signal-dependent noise into an approximately signal-independent representation.

This allows the denoising stage to operate in a domain in which the noise statistics are substantially more homogeneous across different signal levels.

The effectiveness of the transformation can be evaluated by comparing the standard deviation of the noise before and after the VSTQ transformation as a function of the local image signal.

---

## Spatially Correlated Noise

Unlike approaches that assume spatially independent noise, this implementation explicitly considers spatial correlation in the detector noise.

The normalized spatial correlation kernel is incorporated into the characterization of the noise spectrum.

For an image of size `M × N`, the corresponding noise power spectral density can be obtained from the Fourier transform of the normalized correlation kernel.

This information is used in the denoising framework to account for the non-white characteristics of the detector noise.

---

## BM3D Denoising

BM3D is applied to the images after the forward VSTQ transformation.

Before denoising, the transformed image is normalized according to its minimum and maximum values. The corresponding noise level is adjusted consistently with this normalization.

The processing can be summarized as:

```text
VSTQ image
    │
    ▼
Normalization
    │
    ▼
Noise statistics / PSD
    │
    ▼
BM3D
    │
    ▼
Denormalization
```

The denoised image remains in the VSTQ domain until the inverse transformation is applied.

---

## Inverse VSTQ

After BM3D denoising, the inverse VSTQ transformation is applied using the precomputed inverse lookup table.

The spatially varying `ξq(i,j)` map is provided to the inverse transformation so that the local noise characteristics of the detector are preserved during reconstruction.

The output is an estimate of the restored image in the original detector-signal domain.

---

## Requirements

The code was developed and tested using MATLAB.

The following MATLAB components may be required depending on the functions included in the repository:

* MATLAB;
* Image Processing Toolbox.

The BM3D implementation is included in the repository.

The reference MATLAB version used during development should be specified here once the final repository version is defined.

---

## Usage

### 1. Clone the repository

Clone or download the repository to your local machine.

### 2. Prepare the data

Place the phantom or mammography images in:

```text
Phantom images/
```

The images should be compatible with MATLAB's `dicomread` function.

### 3. Check the detector parameters

Ensure that the corresponding files in:

```text
NoiseParameters/
```

are available and correspond to the detector system used for the images.

### 4. Run the demonstration

Open the main restoration script:

```text
Demo_Restoration.m
```

and run it in MATLAB.

The script will:

* Load the detector parameters;
* Read the input images;
* Apply the forward VSTQ;
* Perform BM3D denoising;
* Apply the inverse VSTQ;
* Generate the restored images.

---

## Data and Reproducibility

The restoration method requires detector-specific calibration parameters.

Therefore, the provided parameter files should be considered part of the experimental configuration of the demonstration and should not be assumed to be directly transferable to other mammography systems.

For application to another detector, the corresponding noise parameters, spatial correlation kernel, and inverse VSTQ lookup table should be estimated using calibration data acquired from that system.

---

## Applications

The framework can be used for research involving:

* Digital mammography image restoration;
* Low-dose mammography;
* Noise reduction;
* Variance-stabilizing transformations;
* Signal-dependent noise;
* Spatially correlated detector noise;
* Image quality assessment;
* Mammography image simulation;
* Evaluation of lesion detectability.

The framework is intended primarily for research and image-processing studies.

---

## Citation

If you use this repository or the implemented restoration framework in your research, please cite the corresponding publication:

```text
[Publication information will be added after publication.]
```

---

## Contact

Renann F. Brandão
Laboratory for Advanced Vision and Imaging (LAVI)
University of São Paulo (USP)
São Carlos, SP, Brazil

For questions regarding the implementation or the methodology, please open an issue in this repository or contact the authors.

---
