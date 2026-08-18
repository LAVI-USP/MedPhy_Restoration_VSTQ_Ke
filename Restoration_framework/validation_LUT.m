%% 1. Carregando dados
clear
clc
rng('default')

load('NoiseParameters\Parameters_GE_DM_2.mat')
load('NoiseParameters\LUT_IVSTQ_2.mat')
%% 4. Gerando imagem teste com ruído
num_q = numel(xi_qs);
y_GT = double(imread('y_piecewise.tif'));
y_GT = imresize(y_GT,[1500 1500]);
y_GT = mat2gray(y_GT);
y_GT = y_GT.*(16000 - 200) + 200;
xi_q_map = imresize(xi_qs(round(linspace(1, num_q, numel(y_GT)))), size(y_GT));  % mapeando xi_qs
xi_q_map = reshape(xi_q_map, size(y_GT));

for i =1:20

    z = y_GT + sqrt(xi_s^2 .* y_GT.^2 + xi_q_map .* y_GT + xi_e^2) .* randn(size(y_GT));

    fz_img= log(abs(2 .* sqrt(xi_s^2) .* sqrt(xi_s^2 .* z.^2 + xi_q_map .* z + xi_e^2) + ...
        2 .* xi_s^2 .* z + xi_q_map)) ./ sqrt(xi_s^2);

    z_hat(:,:,i) = F_inv(fz_img, xi_q_map);

end

%% 6. Avaliando desempenho

GT_z_hat = mean(z_hat,3);
rmse = sqrt(mean((GT_z_hat(:) - y_GT(:)).^2));
fprintf('RMSE da LUT invertida vetorizada: %.4f\n', rmse);
