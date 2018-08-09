function dat = binarize(dat)
    dat.y(dat.y ~= 1) = -1;
end