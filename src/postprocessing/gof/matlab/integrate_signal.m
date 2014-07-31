function D = integrate_signal(V,dt);

N = max(size(V));

D(1,1) = V(1,1)*dt/2;
for i=2:N
    D(i,1) = (V(i,1)+V(i-1,1))*dt/2+D(i-1,1);
end