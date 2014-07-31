
function times = find_arrivals(v,refMax,dt)

N = max(size(v));

value = 0;

v = abs(v);
pRef = 0.005 * abs(refMax)
sRef = 0.4 * abs(refMax)

shift = 0;

i = 1;

flag = 1;

while flag > 0
    
    if v(i) > pRef
        if v(i+1) < v(i)
            if v(i-1) < v(i)
                times(1) = dt*(i-1);
                flag = 0;
            end
        end
    end

    i = i+1;
end

i = i + shift;

flag = 1;

while flag > 0
    
    if v(i) > sRef
        if v(i+1) < v(i)
            if v(i-1) < v(i)
                times(2) = dt*(i-1);
                flag = 0;
            end
        end
    end

    i = i+1;
end

return