% Generating SITC1 aggregation commands to be used in Stata
% Produced by Yijiang
clear;clc

%% Extracting sitc1d4 and SNA

[data,txt] = xlsread('sitc1d4.xlsx');

% Write all sitc1d4 codes into a string array
sitc1d4 = strings([length(txt)-1,1]);
for i = 1:length(txt)-1
    sitc1d4(i) = string(txt{i+1,1});
end

% Write all SNA codes into a string array
sna = strings([length(txt)-1,1]);
for i = 1:length(txt)-1
    sna(i) = string(txt{i+1,2});
end

% Format all imported data into a table
table = array2table(data,'VariableNames',txt(1,4));
table.sitc1d4 = cell(length(txt)-1,1);
table.sna = cell(length(txt)-1,1);
for i = 1:length(txt) - 1
    table.sitc1d4(i) = {txt(i+1,1)};
    table.sna(i) = {txt(i+1,2)};
end
clear data txt

%% Generating commands for Stata

clc
diary('commands.txt');
diary on
for i = 1:height(table)
    if table.isdup(i) == 0
        switch string(table.sna{i})
            case 'Capital'
                fprintf('rename sitc0_%s kap_sitc0_%s\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Consumption'
                fprintf('rename sitc0_%s con_sitc0_%s\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Intermediate'
                fprintf('rename sitc0_%s med_sitc0_%s\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
        end
    elseif table.isdup(i) == 1
        switch string(table.sna{i})
            case 'Capital'
                fprintf('gen kap_sitc0_%s = sitc0_%s/2\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Consumption'
                fprintf('gen con_sitc0_%s = sitc0_%s/2\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Intermediate'
                fprintf('gen med_sitc0_%s = sitc0_%s/2\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
        end
    elseif table.isdup(i) == 2
        switch string(table.sna{i})
            case 'Capital'
                fprintf('gen kap_sitc0_%s = sitc0_%s/3\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Consumption'
                fprintf('gen con_sitc0_%s = sitc0_%s/3\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
            case 'Intermediate'
                fprintf('gen med_sitc0_%s = sitc0_%s/3\n',...
                    string(table.sitc1d4{i}),string(table.sitc1d4{i}))
        end
    end
end

% Drop all original sitc0_xxxx variables
disp('drop sitc0_*')

diary off

