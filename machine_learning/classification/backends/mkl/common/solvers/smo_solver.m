function alphas = smo_solver(alphas, Cs, epsilon, labels, linears, quadratics, tau)
    gradients = linears;
    while 1
        [i, j] = working_set_selection(alphas, Cs, epsilon, gradients, labels, quadratics, tau);
        if (j == -1)
           break;
        end
        a = quadratics(i, i) + quadratics(j, j) - 2 * labels(i) * labels(j) * quadratics(i, j);
        if a <= 0
            a = tau;
        end
        b = -labels(i) * gradients(i) + labels(j) * gradients(j);
        alphai = alphas(i);
		alphaj = alphas(j);
		alphas(i) = alphas(i) + labels(i) * b / a;
		alphas(j) = alphas(j) - labels(j) * b / a;
    	sum = labels(i) * alphai + labels(j) * alphaj;
        if alphas(i) > Cs(i)
            alphas(i) = Cs(i);
        end
        if alphas(i) < 0
            alphas(i) = 0;
        end
		alphas(j) = labels(j) * (sum - labels(i) * alphas(i));
        if alphas(j) > Cs(j)
            alphas(j) = Cs(j);
        end
        if alphas(j) < 0
			alphas(j) = 0;
        end
		alphas(i) = labels(i) * (sum - labels(j) * alphas(j));
        deltaAlphai = alphas(i) - alphai;
		deltaAlphaj = alphas(j) - alphaj;
    	gradients = gradients + quadratics(:, i) * deltaAlphai + quadratics(:, j) * deltaAlphaj;
    end
end

function [i, j] = working_set_selection(alphas, Cs, epsilon, gradients, labels, quadratics, tau)
    N = size(alphas, 1);
    i = -1;
    maxGradient = -Inf;
    minGradient = +Inf;
    for k = 1:N
        if (labels(k) == +1 && alphas(k) < Cs(k)) || (labels(k) == -1 && alphas(k) > 0)
            if -labels(k) * gradients(k) >= maxGradient
     			i = k;
                maxGradient = -labels(k) * gradients(k);
            end
        end
    end
    j = -1;
    minObjective = +Inf;
    for k = 1:N
        if (labels(k) == +1 && alphas(k) > 0) || (labels(k) == -1 && alphas(k) < Cs(k))
            b = maxGradient + labels(k) * gradients(k);
            if -labels(k) * gradients(k) <= minGradient
                minGradient = -labels(k) * gradients(k);
            end
            if b > 0
                a = quadratics(i, i) + quadratics(k, k) - 2 * labels(i) * labels(k) * quadratics(i, k);
                if a <= 0
                    a = tau;
                end
                if -(b * b) / a <= minObjective
                    j = k;
                    minObjective = -(b * b) / a;
                end
            end
        end
    end
    if maxGradient - minGradient < epsilon
        i = -1;
        j = -1;
    end
end