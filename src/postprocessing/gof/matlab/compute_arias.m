function Ar = compute_arias(A,dt,N);

Ar(1,:) = A(1,:).^2;
for i = 2:N 
    Ar(i,1) = ((A(i-1,1)^2+A(i,1)^2)*dt/2)+Ar(i-1,1);
    Ar(i,2) = ((A(i-1,2)^2+A(i,2)^2)*dt/2)+Ar(i-1,2);
    Ar(i,3) = ((A(i-1,3)^2+A(i,3)^2)*dt/2)+Ar(i-1,3);
end

Ar(:,1) = Ar(:,1) * pi / 2 / 981;
Ar(:,2) = Ar(:,2) * pi / 2 / 981;
Ar(:,3) = Ar(:,3) * pi / 2 / 981;