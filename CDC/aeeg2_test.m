function y = aeeg2_test(vector)
% The simple supermodular payoff function in example 2
% of Arkolakis and Eckert (2017)

if vector(1) == 0 && vector(2) == 0
    y = 0;
elseif vector(1) == 0 && vector(2) == 1
    y = 9;
elseif vector(1) == 1 && vector(2) == 0
    y = -2;
elseif vector(1) == 1 && vector(2) == 1
    y = 11;
end

