% Formating Raw BIS Data
% Produced by Yijiang
clear;clc

%% hh_ls, as a percent of GDP

[data,txt] = xlsread('hhls_pgdp.xlsx');

 % Write all quarters into a string array
quarter = string.empty(length(txt)-1,0);
for i = 1:length(txt)-1
    quarter(i) = string(txt{1,i+1});
end

 % Write all country (codes) into a string array
[vertical,~] = size(txt);
country = string.empty(0,vertical-1);
for i = 1:vertical-1
    country(i) = string(txt{i+1,1}(1:2));
end % Extract country codes from the first 2 characters
country = country';
clear vertical txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',quarter,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container (the most demanding and innovative part)
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = quarter(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','time','hh_ls_pgdp'});
writetable(table,'hh_ls_pdgp.csv');

%% hh_ls, US dollar
% The algorithm is exactly the same
% All comments are therefore omitted

clear;clc
[data,txt] = xlsread('hhls_usd.xlsx');

quarter = string.empty(length(txt)-1,0);
for i = 1:length(txt)-1
    quarter(i) = string(txt{1,i+1});
end

[vertical,~] = size(txt);
country = string.empty(0,vertical-1);
for i = 1:vertical-1
    country(i) = string(txt{i+1,1}(1:2));
end
country = country';
clear vertical txt

data = array2table(data,'VariableNames',quarter,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = quarter(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','time','hh_ls_usd'});
writetable(table,'hh_ls_usd.csv');

%% hh_ls, domestic currency
% The algorithm is exactly the same
% All comments are therefore omitted

clear;clc
[data,txt] = xlsread('hhls_dc.xlsx');

quarter = string.empty(length(txt)-1,0);
for i = 1:length(txt)-1
    quarter(i) = string(txt{1,i+1});
end

[vertical,~] = size(txt);
country = string.empty(0,vertical-1);
for i = 1:vertical-1
    country(i) = string(txt{i+1,1}(1:2));
end
country = country';
clear vertical txt

data = array2table(data,'VariableNames',quarter,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = quarter(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','time','hh_ls_dc'});
writetable(table,'hh_ls_dc.csv');

