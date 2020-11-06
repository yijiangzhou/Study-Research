function [Istar,pistar] = AER(vector,func,modular)
% This function implements the AE1 and AE2 algorithm.

if isempty(vector(vector == 0.5))
    Istar = vector;
    pistar = func(vector);
else
    output = AE_alter(vector,func,modular);
    if isempty(output(output == 0.5)) % If the first AE attempt is successful...
        Istar = output;
        pistar = func(Istar);
    else
        sub_1 = output;
        sub_0 = output;
        for i = 1:length(output)
            if output(i) == 0.5
                sub_1(i) = 1;
                sub_0(i) = 0;
                break
            end
        end
        % Implement AER recursively
        [output_after_1,pi_after_1] = AER(sub_1,func,modular);
        [output_after_0,pi_after_0] = AER(sub_0,func,modular);
        if pi_after_1 >= pi_after_0
            Istar = output_after_1;
            pistar = pi_after_1;
        else
            Istar = output_after_0;
            pistar = pi_after_0;
        end
    end
end


