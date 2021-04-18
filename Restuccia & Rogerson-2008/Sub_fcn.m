function resid = Sub_fcn(taus)
global alpha gamma g Kbe lambda mtau mtauo mtauk mtaun ns ntau ...
            S s smatrix tau 
global kbar nbar xbar E N mu w Y 
tauv=[-taus,0,tau];

% The state space of plants
% is described by (s,tau). Construct auxiliary matrices
% for s and tau grid.

smatrix=S*s*ones(1,ntau);
mtau=ones(ns,1)*tauv;

% type2 index describes the type of subsidy policy the government
% implements: 1 - output, 2 - capital, 3 - labor.

type2=1;

if type2==1
    mtauo=mtau;
    mtauk=zeros(ns,ntau);
    mtaun=zeros(ns,ntau);
elseif type2==2
    mtauo=zeros(ns,ntau);
    mtauk=mtau;
    mtaun=zeros(ns,ntau);
else
    mtauo=zeros(ns,ntau);
    mtauk=zeros(ns,ntau);
    mtaun=mtau;
end

% Compute equilibrium wage that makes net expected profits equal
% to 0 for potential entering plants We=0.

% Bisection on equilibrium wage

% Initial guess
w0=1;
We0=Wefcn(w0);
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
end

iconv2=0;
tol2=0.0000001;
maxit2=100;
it2=1;

while(iconv2==0 && it2<=maxit2)
    w=(w0+w1)/2;
    We=Wefcn(w);
    if abs(We)<tol2
        iconv2=1;
        %disp('Zero profit condition satisfied in')
        %it2
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
muhat=1./lambda.*xbar.*g;

% Find mass of entry that clears the labor market.
N=sum(sum(nbar.*muhat));
E=1/N;
mu=muhat.*E;

% Compute aggregate capital and capital-to-output ratio
K=sum(sum(kbar.*mu));
Y=sum(sum(smatrix.*kbar.^alpha.*nbar.^gamma.*mu));

% Compute resid as difference between the actual and target revenue to 
% output ratio.
resid=K/Kbe-1;
