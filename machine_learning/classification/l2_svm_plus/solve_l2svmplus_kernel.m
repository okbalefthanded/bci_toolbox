function model = solve_l2svmplus_kernel(labels, K, tK, C, gamma)

n       = length(labels);
uy      = unique(labels);
assert(size(K, 1) == n);
assert(size(K, 2) == n);
assert(size(tK, 1) == n);
assert(size(tK, 2) == n);

K   = K + 1;    % append bias
tK  = tK + 1;   % append bias

H   = eye(n) - inv(eye(n) + C/gamma*tK);
H   = 1/C * H;
opt = ['-s 2 -t 4 -n ', num2str(1/n)];
if length(uy) == 2
    if uy(1)== -1 && uy(2) == 1
        uy(1) = 1;
        uy(2) = -1;    
    end
    y = -ones(n, 1);
    y(labels==uy(1)) = 1;
    Q = K.*(y*y') + H;
    model = svmtrain(ones(n, 1), [(1:n)' Q], opt);
else
    model = cell(0);
    for i = 1:length(uy)
        y = -ones(n, 1);
        y(labels==uy(i)) = 1;
        Q = K.*(y*y') + H;
        model{i} = svmtrain(ones(n, 1), [(1:n)' Q], opt);
    end
end

end