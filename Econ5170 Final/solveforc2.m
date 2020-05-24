function cstar = solveforc2(bpi0,bpi1,bpi2,bpi3,bpi4,w,A,beta,r,lastc)
syms c
y = (1/c) - beta * (1+r) * (bpi0 + bpi1 * ((1+r) * (A + (w^3)/(c^2) -c))...
    + bpi2 * ((1+r) * (A + (w^3)/(c^2) -c))^2 ...
    + bpi3 * ((1+r) * (A + (w^3)/(c^2) -c))^3 ...
    + bpi4 * ((1+r) * (A + (w^3)/(c^2) -c))^4);

temp = double(vpasolve(y,c));
temp = temp(temp>0 & imag(temp)==0); % Extract all positive real roots.

if isempty(temp) == 0
    [~,closestIndex] = min(abs(temp-lastc));
    cstar = temp(closestIndex);
    % If there are multiple real roots, we choose the one that is closest
    % to the optimal c in t+1 period under the same A and w.
else
    cstar = NaN;
end
