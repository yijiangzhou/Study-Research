%      Hopenhayn (1992) Firm Dynamics Market Model - VFI                  %
%          Program written by: Alessandro Ruggieri - UAB and BGSE         %
%                          Version 11/02/2016                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
close all
fprintf('\nSolve Firm Dynamics Model as in Hopenhayn (1992)\n');

 
%% Parameters
compute_parameters;

%% State Space
compute_statespace;

%% Iterate over price of goods
d=1;
% Boundaries for price
pmin=0.01; 
pmax=100;

while d>toler

    % Guess prices    
    price=(pmin+pmax)/2;

    % Solve firm value function iteration
    % YJ: 对上述price, 使用VFI解出v^*(price)
    [vinitial,dr,exit] = solve_vfi(price,z,Z,n,N,theta,beta,cf,p);

    %Compute the decision rule for labor
    decrule=zeros(1,Z);
    for i=1:Z
        decrule(i)=n(dr(i));
    end
    % YJ: decrule(i) is optimal employment when z = z_i

    %Define expected value of entrant
    value=inidis*vinitial';

    % Update price till EV=ce
    if value<ce
     pmin=price;
    else
     pmax=price;
    end

    % Check convergence
    d=abs(value-ce)/ce;
end


%Given the value function and policy function, iterate on the industry structure
%until it converges
d=1; 
muinitial=inidis;

% Method 1: iteration
% mistake-free
while d>toler
    muexit=muinitial.*exit;                 %exit decision
    mustay=muexit*p;                        %update for the incumbents stay
    muentry=mustay+inidis;                   %entry YJ: 此处设entry mass M = 1
    murevised=muentry;
    d=norm(murevised-muinitial)/norm(murevised);
    muinitial=murevised;
end
murevised_sc = murevised ./ sum(murevised);

% Method 2: matrix inversion
Psi = zeros(Z,Z);
ptr = p';
for i = 1:Z
    Psi(:,i) = ptr(:,i) .* exit(i);
end
muedmond = (inv(eye(Z) - Psi) * inidis')';
muedmond_sc = muedmond ./ sum(muedmond);


%% Calculating the entry mass M 
% Using equilibrium condition in goods market
% mistake-free
murevised_sc = murevised ./ sum(murevised);
y=D-price;  
Xstar=z(Z-sum(exit));
Pstar=price;
Size = (decrule)*murevised_sc'; 
Y=(decrule.^theta.*z)*murevised';
Mstar=y/[Y+(decrule.^theta.*z)*inidis'];
Exrate=sum(murevised_sc(1:Z-sum(exit)))*100;

disp('Results ');
disp('');
disp('    Price     Firms    Avg.size       ');
disp([ Pstar  Mstar    Size   ]);

% save baseline.mat
 