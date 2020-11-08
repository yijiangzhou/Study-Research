% AE and AER algorithm to solve combinatorial discrete choice problem
% Based on Arkolakis and Eckert (2017)
% MATLAB codes produced by Yijiang Zhou
clear;clc

%% Testing the main functions

% Calculating derivative of a Boolean-domain function
vec1 = [1 1 1];
vec2 = [1 1];
test1 = booldiff(@booldiff_test,2,vec1);
test2 = booldiff(@jia_test,2,vec1);
test3 = booldiff(@aeeg2_test,1,vec2);
clear vec1 vec2

% The AE iteration
Istar_te = AE(3,@jia_test,'super');
Istar_te2 = AE(2,@aeeg2_test,'super');

% The alternative AE iteration
Istar_te3 = AE_alter([0.5 1],@aeeg2_test,'super');
Istar_te4 = AE_alter([1 0],@aeeg2_test,'super');
Istar_te5 = AE_alter([0.5 0.5 0.5],@jia_test,'super');

% % The AER iteration
[Istar_te6,pistar_te6] = AER(repmat(0.5,1,3),@jia_test,'super');
[Istar_te7,pistar_te7] = AER(repmat(0.5,1,2),@aeeg2_test,'super');

% The Jia (2008) payoff function
A = [1 1 0 1 0 1 1 0 0 1 0 1 0 0 0 1 1 1 0 1];
y = jia(A);

%% AE and AER algorithm: examples

clear;clc

% To test Jia(), the input N (of AE and AER) must be equal to (5 * n),
% where n is a positive integer.
Istar1 = AE(20,@jia,'super');
tic
[Istar2,pistar2] = AER(repmat(0.5,1,20),@jia,'super');
toc
tic
[Istar3,pistar3] = AER(repmat(0.5,1,25),@jia,'super');
toc

% Same problem with brutal force
tic
A = boolmatrix(25);
container = zeros(length(A),1);
for i = 1:length(A)
    container(i) = jia(A(i,:));
end
pistar_force = max(container);
Istar_force = A(container == pistar_force,:);
toc























