% Code File for Dynamic Labor Supply
clear
clc

%% Tauchen Method
mu = 0;
rho = 0;
sigmasq = 1;
epsi_num = 10;
q = 3;
[epsi_grid,pi_epsi] = TauchenMethod(mu,sigmasq,rho,epsi_num,q);
% The MATLAB package Value-Function-Iteration and NVIDIA CUDA toolkit are
% needed to perform Tauchen method.See for details at
% https://github.com/vfitoolkit/VFIToolkit-matlab
% https://developer.nvidia.com/cuda-downloads
%% Initialize Parameters
a0 = 5;
a1 = 0.1;
a2 = 0.002;
beta = 0.95;
r = 0.05;
T = 40;
A = (1000:1000:100000);
polyn = 4; 
% We use 4th order polynomial approximation in the following sections. 

epsi = (gather(epsi_grid))';
pi_epsi = gather(pi_epsi);
% epsi_grid and pi_epsi are arrays stored in GPU.The 'gather' function is
% used to extract them from GPU and store them in local workspace.

valuef{T-1,1} = zeros(length(epsi),length(A));
policyf_c{T-1,1} = zeros(length(epsi),length(A));
policyf_h{T-1,1} = zeros(length(epsi),length(A));
for i = T-2:-1:1
    valuef{i,1} = zeros(length(epsi),length(A));
    policyf_c{i,1} = zeros(length(epsi),length(A));
    policyf_h{i,1} = zeros(length(epsi),length(A));
end % Initialize the value function and the policy function.

lnwage_d = zeros(1,T-1);
for t = T-1:-1:1
    lnwage_d(t) = a0 + a1 * t + a2 * (t^2);
end % This is the deterministic part of wage at each period. 


%% Test: t=T-1=39
for t = T-1:-1:1
    if t == T-1
        for i = 1:length(epsi)
            for j = 1:length(A)
                w = exp(lnwage_d(t) + epsi(i));
                policyf_c{t}(i,j) = (r * A(j))/(beta+0.5 * r);
                policyf_h{t}(i,j) = (policyf_c{t}(i,j))/(2 * w);
                valuef{t}(i,j) = log(policyf_c{t}(i,j)) - 0.5 * log(policyf_h{t}(i,j))...
                    + (beta/r) * log(r * (1+r) * (A(j) + w * policyf_h{t}(i,j)...
                    - policyf_c{t}(i,j)));
            end
        end
    elseif t == T-2
        coef = zeros(length(epsi),polyn+1);
        bpi = zeros(length(epsi),polyn+1);
        for j = 1:length(epsi)
            for i = 1:length(epsi)
                coef(j,:) = polyfit(A,1./policyf_c{T-1}(j,:),polyn);
                coef(j,:) = fliplr(coef(j,:));
                % Some warining signs will pop up but they don't affect the
                % calculation. Please kindly ignore them.
                clc
                for n = 1:polyn+1
                    bpi(i,n) = sum(coef(:,n).*pi_epsi(j,i));
                end
            end
        end
        tic
        for i = 1:length(epsi)
            for j = 1:length(A)
                w = exp(lnwage_d(t) + epsi(i));
                policyf_c{t}(i,j) = solveforc(bpi(i,1),bpi(i,2),bpi(i,3),...
                    bpi(i,4),bpi(i,5),A(j),beta,r);
                % If polyn is changed, we need to adjust the function
                % 'solveforc' and the expression of policyf_c{t}(i,j) since
                % they are only designed for polyn==4 case. 
                policyf_h{t}(i,j) = (policyf_c{t}(i,j))/(2 * w);
            end
        end
        toc
%     else
%         break
    end
end






































































































