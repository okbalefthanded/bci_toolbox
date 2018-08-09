function N = normalize_data(X, mas)
    N = bsxfun(@rdivide, bsxfun(@minus, X, mas.mea), mas.std);
end