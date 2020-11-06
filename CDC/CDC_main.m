% AE and AER algorithm to solve combinatorial discrete choice problem
% Based on Arkolakis and Eckert (2017)
% MATLAB codes produced by Yijiang Zhou
clear;clc

%% Testing main functions

% Calculating derivative of a Boolean-domain function
vec1 = [1 1 1];
vec2 = [1 1];
test1 = booldiff(@booldiff_test,2,vec1);
test2 = booldiff(@jia_test,2,vec1);
test3 = booldiff(@aeeg2_test,1,vec2);
clear vec1 vec2

% The AE iteration
Istar = AE(3,@jia_test,'super');
Istar2 = AE(2,@aeeg2_test,'super');

% The alternative AE iteration
Istar3 = AE_alter([0.5 1],@aeeg2_test,'super');
Istar4 = AE_alter([1 0],@aeeg2_test,'super');
Istar5 = AE_alter([0.5 0.5 0.5],@jia_test,'super');

% The AER iteration
[Istar6,pistar6] = AER(3,@jia_test,'super');
[Istar7,pistar7] = AER(2,@aeeg2_test,'super');






































