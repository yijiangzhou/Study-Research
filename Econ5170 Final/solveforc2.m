function cstar = solveforc2(bpi0,bpi1,bpi2,bpi3,w,A,beta,r)
syms c
y = (1/c) - beta * (1+r) * (bpi0 + bpi1 * ((1+r) * (A + (w^3)/(c^2) -c))...
    + bpi2 * ((1+r) * (A + (w^3)/(c^2) -c))^2 ...
    + bpi3 * ((1+r) * (A + (w^3)/(c^2) -c))^3);

temp = double(vpasolve(y,c));
temp = temp(temp>0 & imag(temp)==0); % Extract all positive real roots

if isempty(temp) == 0
    cstar = temp(1); % We only want one positive real root
else
    cstar = NaN;
end
