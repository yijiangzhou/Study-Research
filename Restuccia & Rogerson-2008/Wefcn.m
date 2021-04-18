function We= Wefcn(w)
global alpha ce cf g gamma mtauo mtauk mtaun ns ntau r rho smatrix
global kbar nbar xbar 

% Compute decision rules for plants: kbar, nbar, ebar.
% Compute demand for capital
kbar=(alpha./(r.*(1+mtauk))).^((1-gamma)/(1-gamma-alpha))...
        .*(gamma./(w.*(1+mtaun))).^(gamma/(1-gamma-alpha))...
        .*(smatrix.*(1-mtauo)).^(1/(1-alpha-gamma)); % YJ: factor-specific tau?

% Demand of labor 
nbar=(1+mtauk)*r*gamma./((1+mtaun)*w*alpha).*kbar; % YJ: from FOC of firm's problem
 
% Substitute kbar, nbar in pi and compute W(s,kbar(s,theta))
pibar=(1-mtauo).*smatrix.*kbar.^alpha.*nbar.^gamma ...
    -(1+mtaun).*w.*nbar-(1+mtauk).*r.*kbar-cf;

% Calculate W(s,tau)
% Initial guess of W(s,tau) value function
W=pibar./(1-rho); % YJ: present value of an incumbent firm
xbar=zeros(ns,ntau); % xbar is optimal entry decision, paper p6
for i=1:ns
    for j=1:ntau
        if W(i,j)>=0
            xbar(i,j)=1;
        end
    end
end

% Compute expected value of making a draw (s,theta) from G(s,theta).
We=sum(sum((W.*g.*xbar)))-ce; % YJ: expected profit of entry (which equals to entry cost)
