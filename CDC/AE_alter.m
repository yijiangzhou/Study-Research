function Istar = AE_alter(vector,func,modular)
% This function is the alternative AE1 and AE2, with input equaling to a
% specific vector.

N = length(vector);
output = zeros(1,N);
output_after = vector;
% The input vector may or may not contain some uncertain elements, which
% are represented by 0.5.

if isempty(vector(vector == 0.5))
    Istar = vector;
else    
    while any((output ~= output_after))
        output = output_after;
        supr = output_after;
        infi = output_after;
        supr(supr == 0.5) = 1;
        infi(infi == 0.5) = 0;
        
        if strcmp(modular,'super') == 1 % The supermodular case
            for i = 1:N
                if booldiff(func,i,supr) < 0 && booldiff(func,i,infi) < 0
                    output_after(i) = 0;
                elseif booldiff(func,i,supr) >= 0 && booldiff(func,i,infi) >= 0
                    output_after(i) = 1;
                end
            end
        elseif strcmp(modular,'sub') == 1 % The submodular case
            for i = 1:N
                if booldiff(func,i,supr) > 0 && booldiff(func,i,infi) > 0
                    output_after(i) = 1;
                elseif booldiff(func,i,supr) <= 0 && booldiff(func,i,infi) <= 0
                    output_after(i) = 0;
                end
            end
        end
        
    end
    Istar = output_after;
end


