% Code Generation
% Produced by Yijiang
clear;clc

%% Import .csv files
start = 1962; terminal = 2014;
for i = start:terminal
    disp(['import delimited dynamic_',num2str(i),',clear'])
    disp(['save ',num2str(i),'.dta,replace'])
end

%% Append all datasets
clear;clc
start = 1962; terminal = 2014;
vector = start + 1:terminal;
disp(['append using ',num2str(vector)])

