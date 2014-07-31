function E = compute_energy(V,dt,N);

E(1,:) = V(1,:).^2;
for i = 2:N 
    E(i,1) = ((V(i-1,1)^2+V(i,1)^2)*dt/2)+E(i-1,1);
    E(i,2) = ((V(i-1,2)^2+V(i,2)^2)*dt/2)+E(i-1,2);
    E(i,3) = ((V(i-1,3)^2+V(i,3)^2)*dt/2)+E(i-1,3);
end
