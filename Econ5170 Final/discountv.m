function v = discountv(w,A,r,c,h,t,epsi,valuef)
tempmatrix = zeros(length(epsi),1);

lastA = (1 + r) * (A + w * h - c);
[~,closestIndex] = min(abs(A - lastA));
for i = 1:length(epsi)
    if i == 1
        tempmatrix(i) = valuef{t+1}(i,closestIndex) * normcdf(epsi(i));
    else
        tempmatrix(i) = valuef{t+1}(i,closestIndex)...
            * (normcdf(epsi(i)) - normcdf(epsi(i-1)));
    end
end
v = sum(tempmatrix(isfinite(tempmatrix)));
