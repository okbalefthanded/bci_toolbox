% Localized Multiple Kernel Support Vector Machine (LMKSVM)

% Summary
%   creates a default parameter set for LMKSVM

% Output(s)
%   par: constructed parameter set

% Mehmet Gonen (gonen@boun.edu.tr)
% Bogazici University
% Department of Computer Engineering

function par = lmksvm_parameter()
    par.C = 1; % regularization parameter
    par.eps = 1e-3; % threshold parameter
    par.gat.typ = 'linear_softmax'; % gating model function [linear_softmax, linear_sigmoid, rbf_softmax]
    par.ker = {'l', 'p2'}; % kernel functions [l: linear, p:polynomial, g:gaussian]
    par.loc.typ = 'linear'; % gating model complexity [linear, quadratic]
    par.nor.dat = {'true', 'true'}; % if true, apply z-normalization to data
    par.nor.ker = {'true', 'true'}; % if true, make kernel unit diagonal
    par.nor.loc = 'true'; % if true, apply z-normalization to gating model data
%     par.opt = 'smo'; % optimizer [libsvm, mosek, quadprog, smo]
    par.opt = 'libsvm';
    par.see = 7332; % seed
    par.tau = 1e-3; % tau parameter for SMO algorithm
end