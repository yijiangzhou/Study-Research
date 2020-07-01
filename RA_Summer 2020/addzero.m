% Adding "Zero" to Commodity Codes
% Produced by Yijiang
clear;clc

%% Read codes and convert them to strings

[data,header] = xlsread('commodity.xlsx','B:B');
comcodes = array2table(data,'VariableNames',header);
clear data

comcodes.HS2012_Codes = string(comcodes.HS2012_Codes);

%% Add "zeros" to codes whose length < 6

% "strlength" measures the length of a given string
for i = 1:length(comcodes.HS2012_Codes)
    if strlength(comcodes.HS2012_Codes(i)) < 6
        comcodes.HS2012_Codes(i) = strcat('0',comcodes.HS2012_Codes(i));
    end
end

% Use xlsx as the export form to avoid missing "zeros"
writetable(comcodes,'codes_withzero.xlsx');

