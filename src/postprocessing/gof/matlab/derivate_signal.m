function A = derivate_signal(V,dt);

N = max(size(V));

A(1,1) = V(1,1)/dt;
for i=1:N-1
    A(i+1,1) = (V(i+1,1)-V(i,1))/dt;
end
