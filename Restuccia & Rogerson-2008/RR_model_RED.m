% Computer code for "Policy Distortions and Aggregate Productivity with
% Heterogeneous Establishments" by Diego Restuccia and Richard Rogerson
% Review of Economic Dynamics 2008

clear all
close all
format compact
warning off MATLAB:divideByZero

% Parameters and grid specification

global alpha ce cf g gamma Kbe lambda mtauo mtauk mtaun N ns ntau p...
       r rho S s smatrix tau
global E kbar mu nbar xbar Y w 

alpha=.85/3;
gamma=.85/3*2;
beta=0.96;
delta=0.08;
S=1; % scale

r=1/beta-1+delta; % YJ: interest rate, paper p5
i=r-delta; % YJ: real interest rate R

% Productivity (s) and output/input tax/subsidy (tau) grids.

% Data from U.S. Census of Businesses
% From Rossi-Hansberg and Wright (AER, 2007) All industries for 2000
load establishment_dist.txt
datazupper=establishment_dist(:,1);  %(upper range of number of employees)
datahs=establishment_dist(:,2);%(fraction of establishment in each group)
dataHs=cumsum(datahs);

%% Simulate productivity s and h(s)
% Estimating Hs based on dataHs
% YJ: H(s) means prob. of drawing s from distribution

% Note: the estimation relies on more points in s than in dataz
ns=100; % YJ: 100 grid points
ndata=length(establishment_dist(:,1));
z_ns=datazupper(ndata)^(1-gamma-alpha); % YJ: z_ns = max model productivity = 10000^(1-gamma-alpha)
% YJ: see paper p7 middle
s=logspace(0,log(z_ns)/log(10),ns)'; % YJ: simulated productivity
% YJ: logspace() generate ns log-spaced numbers between 10^0 and 10^(log(z_ns)/log(10))
% YJ: note that 10^(log(z_ns)/log(10)) = exp(log(z_ns)) = z_ns
z=s.^(1/(1-gamma-alpha)); % YJ: simulated employment of each productivity
hs=zeros(ns,1);
datazupper2=[0;datazupper];
for i=2:length(datazupper2)
    I=find(z<=datazupper2(i) & z>datazupper2(i-1));
    % YJ: I is location of non-zeros elements in logical vector z<=datazupper2(i) & z>datazupper2(i-1)
    % YJ: e.g. when i = 1, z中有15个元素 <= 4 & >0, 因此I 15*1
    % YJ: vector指示出它们的位置，length(I) = 15
    hs(I)=datahs(i-1)/length(I);
    % YJ: z是从小到大排列的，因此hs一定能被从上到下一个不漏的填满
end
% YJ: h(s)的构造方法我在草稿纸上写了写，见手机相册

fig=1;
if fig==1
    figure
    semilogx(z,cumsum(hs),'-',datazupper,dataHs,'o','LineWidth',2)
    %title('Distribution of Plants by Employment')
    set(gca,'XTick',[1 10 100 1000 10000])
    set(gca,'XTickLabel',{'1','10','100','1,000','10,000'})
    xlabel('Number of Employees (log scale)')
    ylabel('Cummulative Distribution of Establishments')
    legend('Model','Data','Location','NorthWest')
    axis([0 14000 0 1.1])
end

%% Initialize result containers
ntau=3;

% Assume constant separation rates across plants: lambda (if separation
% rate depends on s need to create a matrix rho)
cf=0; % YJ: fixed cost of operating
ce=1; % YJ: fixed cost of entry
lambda=0.10; % YJ: exit (death) probability
rho=(1-lambda)/(1+i); % YJ: discount rate, paper p5 buttom

% Initialize matrices for printing

ntax=5; % Number of experiments: tau=0,0.1,0.2,0.3,0.4.
% YJ: below are containers of results
Yp=zeros(1,ntax);
Kp=zeros(1,ntax);
KYp=zeros(1,ntax);
Ap=zeros(1,ntax);
Ep=zeros(1,ntax);
Mp=zeros(1,ntax);
wp=zeros(1,ntax);
sgdpp=zeros(1,ntax);
tausp=zeros(1,ntax);
SYp=zeros(1,ntax);
relmup=zeros(ns,ntax*ntau);
relmusp=zeros(ns,ntax);
sKp=zeros(ns,ntax*ntau);
sNp=zeros(ns,ntax*ntau);
sYp=zeros(ns,ntax*ntau);
kbarp=zeros(ns,ntax*ntau);
nbarp=zeros(ns,ntax*ntau);
xbarp=zeros(ns,ntax*ntau);
modelnp=zeros(ns*ntau,ntax);
modelsNp=zeros(ns*ntau,ntax);
modelmup=zeros(ns*ntau,ntax);
AEPPp=zeros(1,ntax);
KsKp=zeros(1,ntax);

dis_plants=zeros(3,ntax);
dis_sN=zeros(3,ntax);

%% Benchmark case (no distortion)
% Solution to Benchmark Economy (Undistorted)
% For every s, p(.,tau) represents the probability of being in tau category
% For benchmark economy, p only has mass in the middle tau, i.e. tau=0.
p=[zeros(ns,1) ones(ns,1) zeros(ns,1)]; % YJ: probability distribution of tau
% YJ: in benchmark case, tau = 0 with probability 1
hsmatrix=hs*ones(1,ntau);
g=hsmatrix.*p; % Joint PDF = h(s) * p(s,tau)
taus=0.0;
tau=0.0;
tauv=[-taus,0,tau];
smatrix=S*s*ones(1,ntau);
mtau=ones(ns,1)*tauv;
mtauo=mtau; % YJ: output tau (wedge)
mtauk=zeros(ns,ntau); % YJ: capital tau (wedge)
mtaun=zeros(ns,ntau); % YJ: labor tau (wedge)

% Bisection on equilibrium wage
% YJ: the bisection relies on free-entry condition
% Initial guess
w0=1.0;
We0=Wefcn(w0); % YJ: Wefcn computes expected profit of entry given wage guess w
w1=1.5;
We1=Wefcn(w1);
while(We0*We1>0)
    if We0<0 
        w0=w0*0.5;
        We0=Wefcn(w0);
    end
    if We1>0
        w1=w1*1.5;
        We1=Wefcn(w1);
    end
end % YJ: 这个loop的意思是，如果不幸猜到的w0和w1对应的We0和We1同号，就不停地扩大
% YJ: w0和w1之间的距离，直到We0和We1分布在X轴的不同侧（这样才能做bisection）

iconv2=0;
tol2=0.0000001;
maxit2=100; % YJ: max amount of iteration
it2=1;
while(iconv2==0 && it2<=maxit2) % YJ: get wage using bisection
    w=(w0+w1)/2;
    We=Wefcn(w);
    if abs(We)<tol2
        iconv2=1;
        disp('wage has converged in')
        it2
    else
        if We*We1>0
            w1=w;
        else
            w0=w;
        end
        it2=it2+1;
    end
end
if it2>=maxit2
    disp('Warning: Zero profit condition not satisfied')
end

% Compute the normalized invariant distribution of plants.
muhat=1./lambda.*xbar.*g; % YJ: mu hat

% Find mass of entry that clears the labor market.
N=sum(sum(nbar.*muhat)); % YJ: nbar is optimal labor, calc'ed by Wefcn()
% YJ: 注意这个N与paper p6的大N定义不太一样，这里的N相当于1/E, 即section 3.5
% YJ: labor market clearing condition右侧除掉E的求和部分
E=1/N; % YJ: mass of entry, not mass of firms (M)!
mu=muhat.*E;
mu_s=sum(mu,2); % Note SUM(.,2) sums over rows

% Compute aggregate statistics.
Y=sum(sum(smatrix.*kbar.^alpha.*nbar.^gamma.*mu)); % YJ: total output = mu * individual firm's output
K=sum(sum(kbar.*mu)); % YJ: total capital
KY=K/Y;
Kbe=K;
Yp(1,1)=Y;
Kp(1,1)=K;
KYp(1,1)=KY;
A=Y/(N*E)./(K/(N*E))^alpha; % YJ: 接上面对N的注释，这里可知 N*E = 1 = total labor supply. 但A是什么？
M=sum(sum(mu)); % mass of plants producing
Mp(1,1)=M;
Ap(1,1)=A;
Ep(1,1)=E;
wp(1,1)=w;
sgdpp(1,1)=sum(-mtauo(:,1).*smatrix(:,1).*kbar(:,1).^alpha.*...
    nbar(:,1).^gamma.*mu(:,1)-mtauk(:,1).*r.*kbar(:,1).*mu(:,1)...
    -mtaun(:,1).*w.*nbar(:,1).*mu(:,1))/Y;
% YJ: sgdpp is S/Y in paper, total subsidies paid out as a fraction of output
% YJ: in baseline case, it is zero

% Average employment per plant
normalization_emp=nbar(1,2); % YJ: nbar(1,2) is optimal emp at baseline (when no distortion)
rnbar=nbar./normalization_emp; % YJ: 这一步的目的是normalize all nbar such that
% YJ: no. of workers with lowest s is normalized to 1, consistent with data
AEPP=1/(M*normalization_emp); % YJ: AEPP is avg employment; 1 = total labor supply
AEPPp(1,1)=AEPP;

% Distribution and plant statistics
relmus=sum(mu,2)/M;
relmusp(:,1)=relmus;
sK=(kbar.*mu)./K; % YJ: k distribution by productivity s
sN=(nbar.*mu)./(N*E); % YJ: n distribution by s
sY=(smatrix.*kbar.^alpha.*nbar.^gamma.*mu)./Y; % YJ: y distribution by s

modeln=rnbar(:,2);%(number of workers with lowest s in BE norm to 1)
[junk,I]=sort(rnbar(:));
modelnp(:,1)=rnbar(I); 
modelsNp(:,1)=sN(I);
modelmup(:,1)=mu(I)./sum(mu(:));

modelmu=mu(:,2)./sum(mu(:,2)); %(prob dist of plants)
modelsN=sN(:,2);

I5=find(modeln<5);%(plants with less than 5 workers)
I50=find(modeln>=5 & modeln<50);%(plants with 5 to less than 50 workers)
Irest=find(modeln>=50);%(plants with 50 workers or more)
dis_plants(1,1)=sum(modelmu(I5)); % YJ: 注意这里用到的是prob dist mu (normalized)
dis_plants(2,1)=sum(modelmu(I50));
dis_plants(3,1)=sum(modelmu(Irest));
dis_sN(1,1)=sum(modelsN(I5));
dis_sN(2,1)=sum(modelsN(I50));
dis_sN(3,1)=sum(modelsN(Irest));

% Average employment
%sum(modeln(I5).*modelmu(I5)./sum(modelmu(I5)))
%sum(modeln(I50).*modelmu(I50)./sum(modelmu(I50)))
%sum(modeln(Irest).*modelmu(Irest)./sum(modelmu(Irest)))

fig=1;
if fig==1
    figure
    subplot(2,1,1)
    bar(dis_plants(:,1),0.5)
    %axis([0 5 0 0.8])
    %title('Distribution of Establishments by Employment')
    title('Benchmark Economy')
    %xlabel('Plant Size (no. workers)')
    set(gca,'XTickLabel',{'<5';'5-50';'50 or more'})
    ylabel('Share of Establishments')
    %legend('Benchmark','Location','Best')
    subplot(2,1,2)
    bar(dis_sN(:,1),0.5)
    %axis([0 5 0 0.8])
    %title('Distribution of Establishments by Employment')
    xlabel('Establishment Size (by Number of Workers)')
    set(gca,'XTickLabel',{'<5';'5-50';'50 or more'})
    ylabel('Share of Employment')
    %legend('Benchmark','Location','Best')

    figure
    subplot(2,1,1)
    plot(log(z),cumsum(sY(:,2)),'-','LineWidth',2.5)
    title('Cumulative Share of Output')
    subplot(2,1,2)
    plot(log(z),cumsum(sN(:,2)),'LineWidth',2.5)
    title('Cumulative Share of Employment')
    xlabel('log(employment)')
end

disp('Table for Benchmark Economy:')
Y % YJ: total output
A % YJ: ?
KY % YJ: capital share in total output
E % YJ: mass of entrants
M % YJ: mass of firms
w % YJ: equilibrium wage
AEPP % YJ: average employment
dis_plants(:,1) % YJ: dist. of plants
dis_sN(:,1) % YJ: dist. of labor
disp('End of Benchmark Economy')
% End of Benchmark Economy

%% Distortion case
%stop

% Compute distorted economies:

% Type of economy to be computed indexed by type:
% 1 - if iid plant-specific tax/subsidy
% 2 - if negative corr of tax/subsidy and productivity (tax high s)
% 3 - if positive corr of tax/subsidy and productivity  (tax low s)

type=2;
indtaus=1; % Set to 0 if tax only experiments (NOTE: also set sub=0)

% Mass of distorted and undistorted plants. Note: nosub=sub=1/3 is the
% uniform case and must have nsub+sub<=1.
nosub=0.0;
sub=0.5;

taup=[0.0 0.1 0.2 0.3 0.4];

for tax=2:ntax

tau=taup(tax);

p=ones(ns,1)*[sub nosub (1-nosub-sub)];
hsmatrix=hs*ones(1,ntau);

if type==1
  % iid case
  g=hsmatrix.*p;
  taus0=0.0;
  taus1=0.9;
  
elseif type==2
  % correlated case: subsidize a fraction sub of lowest prod plants
  g=zeros(ns,ntau);
  cumgs=cumsum(hs);
  I=find(cumgs<=sub);
  g(I,1)=hs(I);
  if nosub>0
      I=find(cumgs>sub & cumgs<=sub+nosub);
      g(I,2)=hs(I);
  end
  J=find(cumgs>nosub+sub);
  g(J,3)=hs(J);
  
  taus0=0.0;
  taus1=.99;

else
  % correlated case: subsidize a fraction sub of high prod plants
  g=zeros(ns,ntau);
  cumgs=cumsum(hs);
  I=find(cumgs<=1-sub-nosub);
  g(I,3)=hs(I);
  if nosub>0
      I=find(cumgs>1-sub-nosub & cumgs<=1-sub);
      g(I,2)=hs(I);
  end
  J=find(cumgs>1-sub);
  g(J,1)=hs(J);
  
  taus0=0.0;
  taus1=0.9;
end

if indtaus==0
        % Tax only computations and experiments
        disp('Computing case of tax only (no subsidy)')
        tau=taup(tax);
        taus0=0.5;
        sub=0;
        resid=Sub_fcn(taus0);
else
    resid0=Sub_fcn(taus0);
    resid1=Sub_fcn(taus1);

    if resid0*resid1>0 
        disp('WARNING: No equilibrium tau exists')
        break
    else
        iconv4=0;
        tol4=0.0000001;
        maxit4=100;
        it4=1;

    while (iconv4==0 && it4<=maxit4)
        taus=(taus0+taus1)/2;
        resid=Sub_fcn(taus);
        if abs(resid)<tol4
            iconv4=1;
            disp('taus has converged in')
            it4
            tau
            taus
        else
            if resid1*resid>0
                taus1=taus;
            else
                taus0=taus;
            end
            it4=it4+1;
            if it4>maxit4
                disp('taus has not converged in')
                maxit4
            end
        end
    end
    end
end

% Compute aggregate statistics
Y=sum(sum(smatrix.*kbar.^alpha.*nbar.^gamma.*mu));
K=sum(sum(kbar.*mu));
Yp(1,tax)=Y;
Kp(1,tax)=K;
KYp(1,tax)=K/Y;
A=Y/(N*E)./(K/(N*E))^alpha;
Ap(1,tax)=A;
Ep(1,tax)=E;
M=sum(sum(mu));
Mp(1,tax)=M;
wp(1,tax)=w;
sgdpp(1,tax)=sum(-mtauo(:,1).*smatrix(:,1).*kbar(:,1).^alpha.*...
    nbar(:,1).^gamma.*mu(:,1)-mtauk(:,1).*r.*kbar(:,1).*mu(:,1)...
    -mtaun(:,1).*w.*nbar(:,1).*mu(:,1))/Y;
tausp(1,tax)=taus;
Ytau=sum(smatrix.*kbar.^alpha.*nbar.^gamma.*mu);
sYtau=Ytau./Y;
SYp(1,tax)=sYtau(1);
sKtau=sum(kbar.*mu)./K;
KsKp(1,tax)=sKtau(1);

% Distribution statistics
relmup(:,ntau*(tax-1)+1:ntau*tax)=mu./sum(sum(mu));
relmus=sum(mu,2)./sum(sum(mu));
relmusp(:,tax)=relmus;
sK=(kbar.*mu)./K;
sKp(:,ntau*(tax-1)+1:ntau*tax)=sK;
sN=(nbar.*mu)./(N*E);
sNp(:,ntau*(tax-1)+1:ntau*tax)=sN;
sY=(smatrix.*kbar.^alpha.*nbar.^gamma.*mu)./Y;
sYp(:,ntau*(tax-1)+1:ntau*tax)=sY;

% Plant statistics
kbarp(:,ntau*(tax-1)+1:ntau*tax)=kbar;
nbarp(:,ntau*(tax-1)+1:ntau*tax)=nbar;
xbarp(:,ntau*(tax-1)+1:ntau*tax)=xbar;

rnbar=nbar./normalization_emp;
[junk,I]=sort(rnbar(:));
modelnp(:,tax)=rnbar(I);
modelsNp(:,tax)=sN(I);
modelmup(:,tax)=mu(I)./sum(mu(:));

% Average employment per plant
AEPP=1/(M*normalization_emp);
AEPPp(1,tax)=AEPP;

end

% File for latex editing

fid=fopen('RR_tables.tex','w');
fprintf(fid,'\n \\documentclass[12pt]{article}');
fprintf(fid,'\n \\begin{document}');

fprintf(fid,'\n \\begin{table}[h]');
fprintf(fid,'\n \\caption{Aggregate Variables}');
fprintf(fid,'\n \\begin{center}');
fprintf(fid,'\n \\label{results}');
fprintf(fid,'\n \\begin{tabular}{lcccc}');
fprintf(fid,'\n  & \\multicolumn{4}{c}{$\\tau_t$} \\\\');
fprintf(fid,'\n   Variable & 0.1 & 0.2 & 0.3 & 0.4 \\\\ \\hline');
fprintf(fid,'\n  Relative Y &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',Yp(2:ntax)./Yp(1));
fprintf(fid,'\n  Relative TFP &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',Ap(2:ntax)./Ap(1));
fprintf(fid,'\n  Relative E &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',Ep(2:ntax)./Ep(1));
fprintf(fid,'\n  Relative M &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',Mp(2:ntax)./Mp(1));
fprintf(fid,'\n  Relative $w$ &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',wp(2:ntax)./wp(1));
fprintf(fid,'\n  $Y_s/Y$ &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',SYp(2:ntax));
fprintf(fid,'\n  $S/Y$ &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',sgdpp(2:ntax));
fprintf(fid,'\n  $\\tau_s$ &  $%5.2f$ & $%5.2f$ & $%5.2f$ & $%5.2f$ \\\\ ',tausp(2:ntax));
fprintf(fid,'\n \\hline');
fprintf(fid,'\n \\end{tabular}');
fprintf(fid,'\n \\end{center}');
fprintf(fid,'\n \\end{table}');

fprintf(fid,'\n \\end{document}');
fclose(fid);
