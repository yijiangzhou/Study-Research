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

% Alternative Settings
% mu = 0;
% rho = 0.8;
% sigmasq = 0.36;
% epsi_num = 10;
% q = 3;
% [epsi_grid,pi_epsi] = TauchenMethod(mu,sigmasq,rho,epsi_num,q);

%% Initialize Parameters
a0 = 5;
a1 = 0.1;
a2 = -0.002;
beta = 0.95;
r = 0.05;
T = 40;
A = (0:10000:1000000);
polyn = 4;
% We use 4th order polynomial approximation in the following sections.

epsi = (gather(epsi_grid))';
pi_epsi = gather(pi_epsi);
% epsi_grid and pi_epsi are arrays stored in GPU.The 'gather' function is
% used to extract them from GPU and store them in local workspace.

for t = T-1:-1:1
    valuef{t,1} = zeros(length(epsi),length(A));
    policyf_c{t,1} = zeros(length(epsi),length(A));
    policyf_h{t,1} = zeros(length(epsi),length(A));
end % Initialize the value function and the policy function.

for t = T-1:-1:1
    w{t,1} = zeros(length(epsi),1);
end
for t = T-1:-1:1
    for j = 1:length(epsi)
        w{t,1}(j) = exp(a0 + a1 * t + a2 * (t^2) + epsi(j));
%         if w{t,1}(j) >= 300
%             w{t,1}(j) = 0.7 * w{t,1}(j);
%         end % This imposes wage tax.
    end
end %This is the container of wages in each period.

%% Backward Induction
tic
for t = T-1:-1:1
    if t == T-1
        for i = 1:length(epsi)
            for j = 1:length(A)
                policyf_c{t}(i,j) = solveforc1(w{t}(i),A(j),beta,r);
                policyf_h{t}(i,j) = (w{t}(i)^2)/policyf_c{t}(i,j)^2;
                valuef{t}(i,j) = log(policyf_c{t}(i,j)) - (1/1.5) * policyf_h{t}(i,j)^(1.5)...
                    + (beta/r) * log(r * (1+r) * (A(j) + w{t}(i) * policyf_h{t}(i,j)...
                    - policyf_c{t}(i,j)));
            end
        end
    elseif t >= T-3
        coef = zeros(length(epsi),polyn+1);
        bpi = zeros(length(epsi),polyn+1);
        for j = 1:length(epsi)
            for i = 1:length(epsi)
                coef(j,:) = polyfit(A,1./policyf_c{t+1}(j,:),polyn);
                coef(j,:) = fliplr(coef(j,:));
                % Some warining signs will pop up but they don't affect the
                % calculation. Please kindly ignore them.
                clc
                for n = 1:polyn+1
                    bpi(i,n) = sum(coef(:,n) .* pi_epsi(j,i));
                end
            end
        end
        for i = 1:length(epsi)
            for j = 1:length(A)
                policyf_c{t}(i,j) = solveforc2(bpi(i,1),bpi(i,2),bpi(i,3),...
                    bpi(i,4),bpi(i,5),w{t}(i),A(j),beta,r);
                % If polyn is changed, we need to adjust the function
                % 'solveforc' and the expression of policyf_c{t}(i,j) since
                % they are only designed for polyn=4 case.
                policyf_h{t}(i,j) = (w{t}(i)^2)/policyf_c{t}(i,j)^2;
                upperh = (3/4) * 24 * 365;
                % Set a upper bound on h. This is realistic because one
                % cannot devote all time to work. The upper bound is 3/4 of
                % a year.
                if policyf_h{t}(i,j) >= upperh
                    policyf_h{t}(i,j) = upperh;
                    policyf_c{t}(i,j) = w{t}(i)/sqrt(policyf_h{t}(i,j));
                end
                valuef{t}(i,j) = log(policyf_c{t}(i,j))...
                    -  (1/1.5) * policyf_h{t}(i,j)^(1.5)...
                   + beta * discountv(w{t}(i),A(j),r,policyf_c{t}(i,j),...
                   policyf_h{t}(i,j),t,epsi,valuef);
                % The 'weight' is the difference of normal CDF, see the
                % 'discountv' function.
            end
        end
    end
end
toc





































































































