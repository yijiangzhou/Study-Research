function y = antras(vector)
% A payoff function in Antras et al.(2014)'s style.

phi = 3; % Firm's productivity, exogenously given in this example.
sigma_antras = 3.85;
gamma = 1.8;
theta = 1.789;

m1 = 0.007;
v1 = 0.002;
mu = log((m1^2)/sqrt(v1+m1^2));
sigma = sqrt(log(v1/(m1^2)+1));
seed = 1997;
rng(seed,'twister');
sourcepot = lognrnd(mu,sigma,size(vector)); % Sourcing potential of each country
% I do not consider for home market in this example.

Bk = 3;
wk = 5;
wi = normrnd(5,1,size(vector));
m2 = 0.006;
v2 = 0.001;
mu2 = log((m2^2)/sqrt(v2+m2^2));
sigma2 = sqrt(log(v2/(m2^2)+1));
rng(seed,'twister');
fi = lognrnd(mu2,sigma2,size(vector));

container1 = zeros(1,length(vector));
container2 = zeros(1,length(vector));

for i = 1:length(vector)
    container1(i) = vector(i) * sourcepot(i);
    container2(i) = vector(i) * wi(i) * fi(i);
end

y = phi^(sigma_antras - 1) * (gamma * sum(container1))^((sigma_antras - 1)/theta)...
    * Bk - wk * sum(container2);


