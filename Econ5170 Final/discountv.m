function v = discountv(t,epsi,valuef)
tempmatrix = zeros(length(epsi),1);
for i = 1:length(epsi)
    if i == 1
        tempmatrix(i) = mean(valuef{t+1}(i,:),'all') * normcdf(epsi(i));
    else
        tempmatrix(i) = mean(valuef{t+1}(i,:),'all')...
            * (normcdf(epsi(i)) - normcdf(epsi(i-1)));
    end
end
v = sum(tempmatrix);
    