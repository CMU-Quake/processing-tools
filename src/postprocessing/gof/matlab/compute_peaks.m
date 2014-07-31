function [td,tv,ta,md,mv,ma,xd,xv,xa] = compute_peaks(D,V,A,DT,N)

td = zeros(1,3);
tv = zeros(1,3);
ta = zeros(1,3);
xd = zeros(1,3);
xv = zeros(1,3);
xa = zeros(1,3);

for i = 1:3
    [td(i),xd(i)] = find_extreme(D(:,i),DT,N);
    [tv(i),xv(i)] = find_extreme(V(:,i),DT,N);
    [ta(i),xa(i)] = find_extreme(A(:,i),DT,N);
end

md = abs(xd);
mv = abs(xv);
ma = abs(xa);

return;