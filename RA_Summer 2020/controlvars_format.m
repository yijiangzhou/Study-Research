% Formating Raw Control Variables Data
% Produced by Yijiang
clear;clc
tic

%% FDI_inflow
clear;clc

[data,txt] = xlsread('FDI_inflow.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1});
end

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','fdi_inflow'});
writetable(table,'ed_FDI_inflow.csv');

%% FDI_outflow
clear;clc

[data,txt] = xlsread('FDI_outflow.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1});
end

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','fdi_outflow'});
writetable(table,'ed_FDI_outflow.csv');

%% GDPpercapita
clear;clc

[data,txt] = xlsread('GDPpercapita.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1});
end

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','gdp_per'});
writetable(table,'ed_GDPpercapita.csv');

%% industryshare_GDP
clear;clc

[data,txt] = xlsread('industryshare_GDP.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1});
end

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','indshare'});
writetable(table,'ed_industryshare_GDP.csv');

%% population_15-64
clear;clc

[data,txt] = xlsread('population_15-64.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1});
end

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','popul_1564'});
writetable(table,'ed_population_15-64.csv');

%% serviceshare_GDP
clear;clc

[data,txt] = xlsread('serviceshare_GDP.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1}(1:4));
end % We only want to keep the first 4 digits

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','servshare'});
writetable(table,'ed_serviceshare_GDP.csv');

%% broadmoney_GDP
clear;clc

[data,txt] = xlsread('broadmoney_GDP.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1}(1:4));
end % We only want to keep the first 4 digits

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','m3'});
writetable(table,'ed_broadmoney_GDP.csv');

%% govshare_GDP
clear;clc

[data,txt] = xlsread('govshare_GDP.xlsx');
[length,~] = size(txt);
[~,width] = size(txt);
 
 % Write all years into a string array
year = string.empty(width-1,0);
for i = 1:width-1
    year(i) = string(txt{1,i+1}(1:4));
end % We only want to keep the first 4 digits

 % Write all country (3-digit codes) into a string array
country = string.empty(0,length-1);
for i = 1:length-1
    country(i) = string(txt{i+1,1});
end
country = country';
clear length width txt

% Initialize the container of formatted data
data = array2table(data,'VariableNames',year,'RowNames',country);
[rows,columns] = size(data);
tempcell = cell(rows * columns,3);

% Write data into the container
for i = 1:rows * columns
    factor = fix(i/columns);
    residual = rem(i,columns);
    if residual == 0
        factor = factor - 1;
        residual = columns;
    end
    tempcell{i,1} = country(factor + 1);
    tempcell{i,2} = year(residual);
    tempcell{i,3} = data{factor + 1,residual};
end

table = cell2table(tempcell,'VariableNames',{'country','year','govshare'});
writetable(table,'ed_govshare_GDP.csv');

toc
