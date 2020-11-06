function [Istar,pistar] = AER(N,func,modular)
% This function implements the AE1 and AE2 algorithm.

if N < 2 || floor(N) ~= N
    disp('Error! N must be an integer greater than 1.')
    Istar = NaN;
else
    vector = zeros(1,N);
    vector(vector == 0) = 0.5;
    output = AE_alter(vector,func,modular);
%     output = vector; % This is used for testing.
    if isempty(output(output == 0.5)) % If the first AE attempt is successful...
        Istar = output;
        pistar = func(Istar);
    else
        output_after_1 = output;
        output_after_0 = output;
        
        while ~isempty(output_after_1(output_after_1 == 0.5)) ||...
                ~isempty(output_after_0(output_after_0 == 0.5))
        sub_1 = output_after_1; % The first "subset"
        sub_0 = output_after_0; % The second "subset"
        for i = 1:N
            if output(i) == 0.5
                sub_1(i) = 1;
                sub_0(i) = 0;
                break
            end
        end
        output_after_1 = AE_alter(sub_1,func,modular);
        output_after_0 = AE_alter(sub_0,func,modular);
        end
        
        pi_1 = func(output_after_1);
        pi_0 = func(output_after_0);
        if pi_1 >= pi_0
            Istar = output_after_1;
            pistar = pi_1;
        else
            Istar = output_after_0;
            pistar = pi_0;
        end
    end
end


