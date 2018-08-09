function K = kernel(data1, data2, nam, nor)
if nam(1) ~= 'f'
    X1 = data1.X;
    X2 = data2.X;
    ker = get_kernel(nam);
    K = ker(X1, X2);
    if strcmp(nor, 'true') == 1 && size(K, 1) ~= 0 && size(K, 2) ~= 0 %normalize kernel
        if isequal(X1, X2) == 1
            K = K ./ sqrt(diag(K) * diag(K)');
        else
            N = size(X1, 1);
            siz = 2000;
            if N <= siz
                K = K ./ sqrt(diag(ker(X1, X1)) * diag(ker(X2, X2))');
            else
                dia = zeros(N, 1);
                blo = ceil(N / siz);
                for m = 1:blo - 1
                    sta = (m - 1) * siz + 1;
                    fin = m * siz;
                    dia(sta:fin) = diag(ker(X1(sta:fin, :), X1(sta:fin, :)));
                end
                sta = (blo - 1) * siz + 1;
                dia(sta:end) = diag(ker(X1(sta:end, :), X1(sta:end, :)));
                K = K ./ sqrt(dia * diag(ker(X2, X2))');
            end
        end
    end
else
    X1 = data1.ind;
    X2 = data2.ind;
    pat = nam(2:end);
    global memory_kernels; %#ok<TLEV>
    uni = strrep(strrep(strrep(strrep(strrep(strrep(pat, '.', '_'), '/', '_'), ';', '_'), '=', '_'), ',', '_'), '-', '_');
    if isfield(memory_kernels, uni) == 0
        D = importdata(pat, ' ', 1);
        fprintf(1, '%s\n', pat);
        if isfield(D, 'data') == 1
            memory_kernels.(uni) = D.data;
        else
            memory_kernels.(uni) = D;
        end
        ind = find(diag(memory_kernels.(uni)) == 0);
        memory_kernels.(uni)(ind, ind) = 1e-6;
    end
    K = memory_kernels.(uni)(X1, X2);
    if strcmp(nor, 'true') == 1 && size(K, 1) ~= 0 && size(K, 2) ~= 0
        if isequal(X1, X2) == 1
            K = K ./ sqrt(diag(K) * diag(K)');
        else
            K = K ./ sqrt(diag(memory_kernels.(uni)(X1, X1)) * diag(memory_kernels.(uni)(X2, X2))');
        end
    end
end
end