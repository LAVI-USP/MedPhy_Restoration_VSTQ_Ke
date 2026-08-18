close all
clear
clc

load('NoiseParameters\Parameters_GE_DM_2.mat')

% Define parameters
val_max_lambda = ceil(max(xi_qi(:))*100)/100;
val_min_lambda = floor(min(xi_qi(:))*100)/100;
num_lambdas = 1200;
xi_qs = linspace(val_max_lambda, val_min_lambda, num_lambdas);

y_values = linspace(0, 16500, 10^5);
num_extra_realizations = 10^5;
batch_size = 100;
num_batches = num_extra_realizations / batch_size;

Ez = y_values(:); % Expected y values
y_matrix = repmat(y_values, batch_size, 1); % 1000 rows x 50000 columns

% Preallocate result matrix
Efzmatrix = zeros(length(y_values), num_lambdas);

disp('Starting Monte Carlo simulation for LUT generation...');

if 1
    for idx_lambda = 578:num_lambdas
        xi_q_val = xi_qs(idx_lambda);
        efz_accum = zeros(size(y_values));
        aux = 0;
        %disp([num2str(idx_lambda) 'alpha de ' num2str(num_lambdas) 'totais'])
        tic
        %parfor b = 1:num_batches
        for b = 1:num_batches
            % Generate noise realization
            noise_std = sqrt(xi_s.^2 .* y_matrix.^2 + xi_q_val .* y_matrix + xi_e^2);
            z = y_matrix + noise_std .* randn(size(y_matrix));

            % Apply VSQ transformation
            fz = log(abs(2 .* sqrt(xi_s^2) .* sqrt(xi_s^2 .* z.^2 + xi_q_val .* z + xi_e^2) + ...
                2 .* xi_s^2 .* z + xi_q_val)) ./ sqrt(xi_s^2);

            efz_accum = efz_accum + mean(fz, 1);
            %aux = aux + sum(fz);
        end
        toc
        Efzmatrix(:, idx_lambda) = efz_accum' / num_batches;
        %Efzmatrix = (aux/(10000*b))';

        % Optional: Save progress
        fprintf('Progress: %.2f%%\n', (idx_lambda / num_lambdas) * 100);
    end
end
save('Efzmatrix_2.mat','Efzmatrix')
%load('LookUpTable_Optimized_Clinical_EXPANDED.mat');
%% Combinar Efz anterior e novo
% N1 = 2*10^5;
% N2 = num_extra_realizations;
% Efzmatrix_combined = (N1 * Efzmatrix + N2 * Efzmatrix_extra) / (N1 + N2);
%
% %% Salvar nova LUT
% save('LookUpTable_Optimized_Clinical_EXPANDED_2.mat', 'Efzmatrix_combined', 'xi_qs', 'Ez', 'xi_e','xi_s', 'Tau', '-v7.3');
% disp('Nova LUT expandida com mais realizações foi salva!');

%% Create teh LUT_IVSTQ
if 1
    load('NoiseParameters\Efzmatrix_2.mat')
    Efzmatrix= Efzmatrix(:,end:-1:1);
    xi_qs = xi_qs(end:-1:1);
    min(xi_qs(:))


    %% 2. Construção da LUT invertida: Efzmatrix → z
    % Cada coluna de Efzmatrix representa fz = f(Ez, xi_q)
    % Vamos inverter Efzmatrix para ter: fz como eixo, Ez como saída
    fprintf('Construindo LUT invertida...\n');

    num_q = length(xi_qs);
    fz_uniform = linspace(min(Efzmatrix(:)), max(Efzmatrix(:)), size(Efzmatrix,1));  % eixo fz uniforme

    Ez_inv_mat = zeros(length(fz_uniform), num_q);

    for k = 1:num_q
        fz_col = Efzmatrix(:,k);
        ez_col = y_values;%Ez;

        %Remove repetições
        [fz_unique, ia] = unique(fz_col);
        ez_unique = ez_col(ia);

        % Interpola Ez como função de fz (inversão)
        Ez_interp = interp1(fz_unique, ez_unique, fz_uniform, 'linear', 'extrap');
        Ez_inv_mat(:,k) = Ez_interp;
    end

    %% 3. Criando interpolador inverso: (fz, xi_q) → z
    F_inv = griddedInterpolant({fz_uniform, xi_qs}, Ez_inv_mat, 'linear', 'nearest');

end
