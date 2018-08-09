function eta = etas(X, gat, eps, typ)
    N = size(X, 1); 
    switch typ
        case {'linear_sigmoid', 'sigmoid'}
            val = -[ones(N, 1), X] * gat';
            eta = 1 ./ (1 + exp(val));
        case {'linear_softmax', 'softmax'}
            val = [ones(N, 1), X] * gat';
            eta = exp(bsxfun(@minus, val, max(val, [], 2)));
            eta = bsxfun(@rdivide, eta, sum(eta, 2));
        case {'rbf_softmax', 'rbf'}
            P = size(gat, 1);
            val = zeros(N, P);
            for m = 1:P
                val(:, m) = -sum(bsxfun(@minus, X, gat(m, 2:end)).^2, 2) / gat(m, 1)^2;
            end
            eta = exp(bsxfun(@minus, val, max(val, [], 2)));
            eta = bsxfun(@rdivide, eta, sum(eta, 2));
    end
    eta(eta < eps) = 0;
    eta(eta > 1 - eps) = 1;
end