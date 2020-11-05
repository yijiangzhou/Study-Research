function Istar = AE(N,func,modular)
% This function implements the AE1 and AE2 algorithm.

if N < 2 || floor(N) ~= N
    disp('Error! N must be an integer greater than 1.')
    Istar = NaN;
else
    output = zeros(1,N);
    output_after = zeros(1,N);
    output_after(output_after == 0) = 0.5;
    % output_after is the initial I, with all elements uncertain, i.e. all
    % elements equal to 0.5.
    iter = 0;
    
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
        
        iter = iter + 1;
    end
    
    if ~all(output_after - 0.5)
        disp(output_after)
        disp('Iteration failed!')
        disp(['iter = ',num2str(iter-1)])
    else
        Istar = output_after;
        disp('Iteration succeeded!')
        disp(['iter = ',num2str(iter-1)])
    end
    
end


