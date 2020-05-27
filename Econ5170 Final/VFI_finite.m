% Code File for Dynamic Labor Supply
clear
clc

x = (100:100:10000);
y = zeros(1,100);
for i = 1:100
y(i) = log(sqrt(x(i)));
end
polyfit(x,y,5);
warn = warning('query','last');
id = warn.identifier;
warning('off',id)
clc
% This is used to suppress warning messages related to polynomial
% approximation, as they do not affect execution but create unnecessary
% confusion.
clear x y warn i ans


%% Tauchen Method
clc
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
% clc
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
A = (0:40000:20000000);
% A = (0:200000:20000000);
% Less grids can significantly reduce time of execution.
polyn = 2;
% We use 2nd order polynomial approximation in the following sections.

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
    else
        coef = zeros(length(epsi),polyn+1);
        bpi = zeros(length(epsi),polyn+1);
        for j = 1:length(epsi)
            for i = 1:length(epsi)
                coef(j,:) = polyfit(A,1./policyf_c{t+1}(j,:),polyn);
                coef(j,:) = fliplr(coef(j,:));
                for n = 1:polyn+1
                    bpi(i,n) = sum(coef(:,n) .* pi_epsi(j,i));
                end
            end
        end
        for i = 1:length(epsi)
            for j = 1:length(A)
                policyf_c{t}(i,j) = solveforc2(bpi(i,1),bpi(i,2),bpi(i,3),...
                    w{t}(i),A(j),beta,r,policyf_c{t+1}(i,j));
                % If polyn is changed, we need to adjust the function
                % 'solveforc2' and the expression of policyf_c{t}(i,j) since
                % they are only designed for polyn=2 case.
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
                if isnan(policyf_c{t}(i,j))
                    [policyf_c{t}(i,j),policyf_h{t}(i,j),valuef{t}(i,j)] = ...
                        cornersolution(A,A(j),w{t}(i),beta,r,t,epsi,valuef);
                end
                % If there is no positive real solution of c^*, we use the
                % corner solution.
                % It turns out that solving for corner solutions is
                % extremely time-consuming.
            end
        end
    end
end
toc
warning('on',id)

% save Q1ab.mat
% save Q1c.mat
% save Q1d.mat

%% Simulation
% load Q1ab.mat
% load Q1c.mat
% load Q1d.mat

N = 1000;
A0 = 0;
simu_wage = zeros(T-1,N);
weights = zeros(1,length(epsi));
for i = 1:length(epsi)
    if i == 1
        weights(i) = normcdf(epsi(i));
    else
        weights(i) = normcdf(epsi(i)) - normcdf(epsi(i-1));
    end
end
for t = 1:T-1
    simu_wage(t,:) = randsample(w{t}',N,true,weights);
end % Simulate wage paths for 1000 workers.

simu_h = zeros(T-1,N);
simu_c = zeros(T-1,N);
for i = 1:N
    for t = 1:T-1
        if t == 1
            row = find(w{t}==simu_wage(t,i));
            column = find(A==A0);
            simu_h(t,i) = policyf_h{t}(row,column);
            simu_c(t,i) = policyf_c{t}(row,column);
            previousA = A0;
        else
            nowA = (1 + r) * (previousA + simu_wage(t-1,i) * simu_h(t-1,i)...
                - simu_c(t-1,i));
            [~,closestIndex] = min(abs(A - nowA));
            row = find(w{t}==simu_wage(t,i));
            simu_h(t,i) = policyf_h{t}(row,closestIndex);
            simu_c(t,i) = policyf_c{t}(row,closestIndex);
            previousA = A(closestIndex);
        end
    end
end
clear nowA previousA closestIndex row column

fig = figure;

% Mean of simulated wages
msimu_w = zeros(T-1,2);
for t = 1:T-1
    msimu_w(t,1) = t;
    msimu_w(t,2) = mean(simu_wage(t));
end
subplot(2,1,1)
plot(msimu_w(:,1),msimu_w(:,2))
title('\fontsize{12}Simulated Wages by T with Tax')
xlabel('T = (+ 16 = Age)')
ylabel('Wage')

% Mean of simulated working hours
msimu_h = zeros(T-1,2);
for t = 1:T-1
    msimu_h(t,1) = t;
    msimu_h(t,2) = mean(simu_h(t));
end
subplot(2,1,2)
plot(msimu_h(:,1),msimu_h(:,2))
title('\fontsize{12}Simulated Working Hours by T with Tax')
xlabel('T = (+ 16 = Age)')
ylabel('Working Hours')

% fig.PaperPositionMode = 'manual';
% orient(fig,'landscape')
% print(fig,'LandscapePage.pdf','-dpdf')



