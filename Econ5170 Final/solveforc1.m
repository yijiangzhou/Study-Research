function cstar = solveforc1(w,A,beta,r)
syms c
y = (1/c) - (beta/(r * (A + (w^3)/(c^2) -c)));

temp = double(vpasolve(y,c));
temp = temp(temp>0 & imag(temp)==0); % Extract all positive real roots

if isempty(temp) == 0
    cstar = temp(1); % We only want one positive real root
else
    cstar = NaN;
end