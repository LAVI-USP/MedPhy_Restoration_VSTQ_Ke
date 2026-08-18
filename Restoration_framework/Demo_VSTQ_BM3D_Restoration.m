%% DEMO - Image restoration using VSTQ and BM3D
% Quadratic noise model with spatially correlated noise
%
% Processing pipeline:
%   1. Load noise parameters and calibration data
%   2. Read repeated phantom images
%   3. Subtract detector offset
%   4. Apply the forward VSTQ
%   5. Verify noise stabilization
%   6. Denoise in the VSTQ domain using BM3D
%   7. Apply the inverse VSTQ
%   8. Blend the original and restored images
%   9. Reinsert the detector offset


close all
clear
clc


%% ------------------------------------------------------------------------
% Paths
% -------------------------------------------------------------------------

addpath("BM3D_New\bm3d")
addpath("Functions")

phantomFolder = "Phantom images";

noiseParametersFile = ...
    "NoiseParameters\Parameters_GE_DM.mat";

inverseLUTFile = ...
    "NoiseParameters\LUT_IVSTQ.mat";

kernelFile = ...
    "NoiseParameters\Kernel_GE_Pristina.mat";


%% ------------------------------------------------------------------------
% Load noise model parameters
% -------------------------------------------------------------------------

load(noiseParametersFile)
load(inverseLUTFile)
load(kernelFile)


%% ------------------------------------------------------------------------
% Read phantom images
% -------------------------------------------------------------------------

list_imgs = dir(phantomFolder);

% Remove "." and ".."
list_imgs = list_imgs(3:end);

N_images = min(20, numel(list_imgs));

for i = 1:N_images

    fileName = fullfile( ...
        list_imgs(i).folder, ...
        list_imgs(i).name);

    z(:, :, i) = double(dicomread(fileName));

end

fprintf('Number of images loaded: %d\n', N_images);


%% ------------------------------------------------------------------------
% Subtract detector offset
% -------------------------------------------------------------------------

z_minus_tau = z - tau;


%% ------------------------------------------------------------------------
% Forward VSTQ transformation
% -------------------------------------------------------------------------

% Spatially varying quantum noise parameter.
% The crop accounts for the detector geometry.

xi_qi_crop = xi_qi( ...
    556/2 + 1:end - 556/2, ...
    481:end);

%xi_qi_crop = xi_qi;


% VSTQ transformation

fz = log( ...
    abs( ...
        2 .* sqrt(xi_s^2) .* ...
        sqrt( ...
            xi_s^2 .* z_minus_tau.^2 + ...
            xi_qi_crop .* z_minus_tau + ...
            xi_e^2) ...
        + ...
        2 .* xi_s^2 .* z_minus_tau + ...
        xi_qi_crop) ...
    ) ./ sqrt(xi_s^2);


%% ------------------------------------------------------------------------
% Check noise stabilization
% -------------------------------------------------------------------------

[Bins_MEAN_z, Bins_STD_z, Bins_STD_fz] = ...
    plotVST_check( ...
        fz(900:1600, 1600:1900, :), ...
        z_minus_tau(900:1600, 1600:1900, :), ...
        20);

fprintf( ...
    'Mean STD after VSTQ: %.4f\n', ...
    mean2(Bins_STD_fz));


%% ------------------------------------------------------------------------
% Denoising in the VSTQ domain
% -------------------------------------------------------------------------

denoised = zeros(size(fz));

N_restore = 10;
Beta = 2;


for i = 1:N_restore

    fprintf( ...
        'Denoising image %d/%d...\n', ...
        i, N_restore);


    %% Select VSTQ image

    fz_n = fz(:, :, i);


    %% Normalize VSTQ image

    m = min(fz_n(:));
    M = max(fz_n(:));

    fz_norm = (fz_n - m) / (M - m);


    %% Estimate noise PSD

    sz = size(fz_norm);

    K_e = Ke ./ norm(Ke(:));

    PSD = ...
        abs( ...
            fft2( ...
                K_e ./ (M - m), ...
                sz(1), ...
                sz(2)) ...
        ).^2 ...
        .* sz(1) .* sz(2);


    %% BM3D denoising

    Profile = BM3DProfile('refilter');
    Profile.filter_strength = 0.8;

    [denoised_norm] = ...
        BM3D( ...
            fz_norm, ...
            PSD, ...
            Profile);


    %% Undo normalization

    D_fz = ...
        denoised_norm .* (M - m) + m;


    %% Apply inverse VSTQ transformation

    D(:, :, i) = ...
        F_inv( ...
            D_fz, ...
            xi_qi_crop);


    %% Blend original and restored images

    pho1 = sqrt( ...
        ( ...
            xi_s.^2 .* (Beta .* D(:, :, i)).^2 + ...
            xi_qi_crop .* (Beta .* D(:, :, i)) + ...
            xi_e^2 ...
        ) ...
        ./ ...
        ( ...
            xi_s^2 .* D(:, :, i).^2 + ...
            xi_qi_crop .* D(:, :, i) + ...
            xi_e^2 ...
        ));


    pho2 = Beta - pho1;


    Z_hat(:, :, i) = ...
        pho1 .* (z(:, :, i) - tau) + ...
        pho2 .* D(:, :, i);


    %% Reinsert detector offset

    Z_hat(:, :, i) = Z_hat(:, :, i) + tau;

end