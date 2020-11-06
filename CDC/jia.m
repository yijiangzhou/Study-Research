function y = jia(vector)
% A payoff function in Jia (2008)'s style.
% Note that the number 5 needs to be a factor of length(vector) in this
% example. This is due to how I calculate the "distance" between locations.

n = length(vector);
matrix = zeros(5,n/5);
for i = 1:n
    matrix(i) = vector(i);
end

sigma = 0.5; % sigma > (<) 0: jia() is supermodular (submodular).
seed = 1212;
rng(seed,'twister')
X = 10 * randn(5,n/5); % The normally distributed independent payoff
% The seed and rng() function ensures X is consistent, instead of being
% different every time jia() function is called in AE or AER loops.

dep_payoff = zeros(5,n/5); % The dependent payoff
for i = 1:n
    container = zeros(5,n/5);
    for j = 1:n
        if i == j
            container(j) = 0;
        else
            [rowj,colj] = ind2sub(size(container),j);
            [rowi,coli] = ind2sub(size(container),i);
            tau_ij = sqrt((rowi - rowj)^2 + (coli - colj)^2);
            container(j) = matrix(j) / tau_ij;
        end
    end
    dep_payoff(i) = sigma * sum(container,'all');
end

container2 = zeros(1,n);
for i = 1:n
    container2(i) = matrix(i) * (X(i) + dep_payoff(i));
end

y = sum(container2,'all');


