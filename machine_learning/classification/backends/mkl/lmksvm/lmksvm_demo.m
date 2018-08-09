seed = 1606;
randn('seed', seed); %#ok<RAND>

N1 = 50; mu1 = [-3.00, +1.00]; sigma1 = [+0.80, +0.00; +0.00, +2.00];
N2 = 50; mu2 = [-1.00, -2.20]; sigma2 = [+0.80, -0.00; -0.00, +4.00];
N3 = 50; mu3 = [+1.00, +1.00]; sigma3 = [+0.80, -0.00; -0.00, +2.00];
N4 = 50; mu4 = [+3.00, -2.20]; sigma4 = [+0.80, -0.00; -0.00, +4.00];

training.ind = (1:N1 + N2 + N3 + N4)';
training.X = [mvnrnd(mu1, sigma1, N1);
              mvnrnd(mu2, sigma2, N2);
              mvnrnd(mu3, sigma3, N3);
              mvnrnd(mu4, sigma4, N4)];
training.y = [+1 * ones(N1, 1);
              +2 * ones(N2, 1);
              +1 * ones(N3, 1);
              +2 * ones(N4, 1)];

config = read_config();
[X1, X2] = meshgrid(config.x_min:config.x_step:config.x_max, ...
                    config.y_min:config.y_step:config.y_max);
grid.X = [reshape(X1, numel(X1), 1), reshape(X2, numel(X2), 1)];

training_data = cell(1, 3);            grid_data = cell(1, 3);
training_data{1} = binarize(training); grid_data{1} = grid;
training_data{2} = binarize(training); grid_data{2} = grid;
training_data{3} = binarize(training); grid_data{3} = grid;

parameters = lmksvm_parameter();
parameters.C = 10;
parameters.gat.typ = 'linear_softmax';
parameters.ker = {'l', 'p2'};
parameters.nor.dat = {'true', 'true'};
parameters.nor.ker = {'true', 'true'};
% parameters.opt = 'smo'; %set to "libsvm" or "mosek" to change the optimizer
parameters.opt = 'libsvm';
model = lmksvm_train(training_data, parameters);
output = lmksvm_test(grid_data, model);

draw_data(training, 'binary', config);
draw_support_vectors(training, model, 'binary', config);
draw_gating_boundaries(output, 'binary', config);
draw_decision_function(output, 'binary', config);