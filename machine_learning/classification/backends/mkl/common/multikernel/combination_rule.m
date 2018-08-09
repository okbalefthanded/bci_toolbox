function res = combination_rule(Km, nam)
    switch(nam)
        case 'mean'
            res = mean(Km, 3);
        case 'product'
            res = prod(Km, 3);
    end
end