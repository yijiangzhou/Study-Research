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
while d>toler
    muexit=muinitial.*exit;                 %exit decision
    % YJ: exit decision is associated with equilibrium price calculated above
    mustay=muexit*p;                        %update for the incumbents stay
    muentry=mustay+inidis;                   %entry YJ: 此处设entry mass M = 1
    murevised=muentry./sum(muentry); % 我们需要计算的mu^*是概率分布，而上一行算出的muentry是
    % 企业的“数量”，因此需要除以“数量”总和才能得到概率
    d=norm(murevised-muinitial)/norm(murevised);
    muinitial=murevised;
end
% YJ: 这里求出的mu^*, 就是entry mass M = 1时的mu^*. 参见Edmond slide p23

%% Calculating the entry mass M 
% Using equilibrium condition in goods market
y=D-price;  
Xstar=z(Z-sum(exit));
% YJ: Xstar是exit threshold (cutoff productivity)
% YJ: 注意z中的productivity是从小到大排列的，因此作者这里很聪明的用z(Z-sum(exit))来表示
% 满足continue的最小productivity
Pstar=price;
Size = (decrule)*murevised'; 
Y=(decrule.^theta.*z)*murevised';
Mstar=y/[Y+(decrule.^theta.*z)*inidis']; % YJ: 分母是后面每一期假设entry mass M = 1的Y加上
% 第一期的Y（第一期假设productivity dist.为inidis）
Exrate=sum(murevised(1:Z-sum(exit)))*100;

disp('Results ');
disp('');
disp('    Price     Firms    Avg.size       ');
disp([ Pstar  Mstar    Size   ]);
 