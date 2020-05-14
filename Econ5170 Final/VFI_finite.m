% Code File for Dynamic Labor Supply
clear
clc
%% Tauchen Method
mu = 0;
rho = 0;
sigmasq = 1;
q = 3;
epsi_num = 10;
[epsi_grid,pi_epsi] = TauchenMethod(mu,sigmasq,rho,epsi_num,q);
% The MATLAB package Value-Function-Iteration is needed to perform Tauchen
% method. See https://github.com/vfitoolkit/VFIToolkit-matlab for details.

%% Initialize Parameters
a0 = 5;
a1 = 0.1;
a2 = 0.002;
beta = 0.95;
r = 0.05;
T = 40;
A = (100:100:10000);
epsi = (gather(epsi_grid))';
% epsi_grid is an array stored in GPU.The 'gather' function is used to
% extract epsi_grid from GPU and store it in local workspace.
valuef{T-1,1} = zeros(length(epsi),length(A));
policyf_c{T-1,1} = zeros(length(epsi),length(A));
policyf_h{T-1,1} = zeros(length(epsi),length(A));
for i = T-2:-1:1
    valuef{i,1} = zeros(length(epsi),length(A));
    policyf_c{i,1} = zeros(length(epsi),length(A));
    policyf_h{i,1} = zeros(length(epsi),length(A));
end % Initialize the value function and the policy function.
wage_d = zeros(1,T-1);
for t = T-1:-1:1
    wage_d(t) = exp(a0 + a1 * t + a2 * t^2);
end

%% Test: t=T-1=39
for t = T-1:-1:1
    if t == T-1
        for i = 1:length(epsi)
            for j = 1:length(A)
                w = wage_d(t) * exp(epsi(i));
                policyf_c{t}(i,j) = (r * A(j))/(beta+0.5 * r);
                policyf_h{t}(i,j) = (policyf_c{t}(i,j))/(2 * w);
                valuef{t}(i,j) = log(policyf_c{t}(i,j)) - 0.5 * log(policyf_h{t}(i,j))...
                    + (beta/r) * log(r * (1+r) * (A(j) + w * policyf_h{t}(i,j)...
                    - policyf_c{t}(i,j)));
            end
        end
    else
        break
    end
end




































































































