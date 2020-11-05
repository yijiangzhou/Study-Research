function bool = boolmatrix(N)
% This function creates Boolean vectors as rows of a matrix.

% e.g. Let N = 3 and the function creates a 2^3 * 3 matrix, whose rows are
% distinct Boolean vectors like [1 0 0] or [0 1 0].

matrix = zeros(2^N,N);
matrix(1,:) = zeros(1,N);
matrix(2,:) = [zeros(1,N-1) 1];

for i = 3:2^N
    for j = 1:N-1
        if 1 + 2^j <= i && i <= 2^(j+1)
            vector = zeros(1,N);
            vector(N-j) = 1;
            matrix(i,:) = matrix(i-2^j,:) + vector;
        end
    end
end

bool = matrix;

