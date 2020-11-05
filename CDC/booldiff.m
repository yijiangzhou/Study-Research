function D_i = booldiff(f,i,vector)
% This function calculates the derivative of f on the Boolean domain with
% respect to the ith coordinate.

vector(i) = 1;
high = vector;

vector(i) = 0;
low = vector;

D_i = f(high) - f(low);