% Sorting SITC1 codes
% Produced by Yijiang
% Sorting的具体含义是，只保留BEC-SITC1中在bilarteral trade data中出现过的
% SITC1以及它们对应的BEC和SNA
clear;clc

%% Extracting SITC1 from BEC-SITC1 and bilateral trade data

[data,txt] = xlsread('bec_sitc.xlsx');

% Write all SNA codes into a string array
sna = strings([length(txt)-1,1]);
for i = 1:length(txt)-1
    sna(i) = string(txt{i+1,3});
end

% Format the imported data into a table
sitc1_sna = array2table(data,'VariableNames',txt(1,1:2));
sitc1_sna.sna = cell(length(txt)-1,1);
for i = 1:length(txt) - 1
    sitc1_sna.sna(i) = {txt(i+1,3)};
end
clear data txt

[data,txt] = xlsread('bilateral_trade_vars.xlsx');

bitrade = array2table(data,'VariableNames',txt);
clear data txt

%% Sorting SITC1

% Initialize the container for sorted SITC1
sz = [length(sitc1_sna.sitc1) 3];
varTypes = {'double','double','cell'};
varNames = {'sitc1','bec','sna'};
container = table('Size',sz,'VariableNames',varNames,'VariableTypes',varTypes);
clear sz varTypes varNames

for i = 1:length(sitc1_sna.sitc1)
    if ismember(sitc1_sna.sitc1(i),bitrade.bilateral_sitc1)
        container.sitc1(i) = sitc1_sna.sitc1(i);
        container.bec(i) = sitc1_sna.bec(i);
        container.sna(i) = sitc1_sna.sna(i);
    end
end

% Extracting non-zero rows from the container
container = container((container.sitc1 ~= 0),:);

% Convert SITC1 in container into strings and "add zero"
container.sitc1 = string(container.sitc1);
for i = 1:length(container.sitc1)
    if strlength(container.sitc1(i)) == 2
        container.sitc1(i) = strcat('00',container.sitc1(i));
    elseif strlength(container.sitc1(i)) == 3
        container.sitc1(i) = strcat('0',container.sitc1(i));
    end
end

% Use xlsx as the export form to avoid missing "zeros"
writetable(container,'sitc1_sorted.xlsx');


