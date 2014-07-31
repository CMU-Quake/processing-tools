
function [dur, t1, t2] = compute_duration(E,V,dt,N);

for i = 1:3
    E1(i) = 0.05*E(N,i);
    E2(i) = 0.95*E(N,i);
end

found1 = zeros(3,1);
found2 = zeros(3,1);

for e = 1:N
    for i = 1:3
        if found1(i) == 0
            if E(e,i) > E1(i)
               t1(i) = e*dt;
               found1(i) = 1;
            end
        end
        if found2(i) == 0
            if E(e,i) > E2(i)
                t2(i) = e*dt;
                found2(i) = 1;
            end
        end
    end
end

dur = t2 - t1;

return;
