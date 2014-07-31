
function [a,v,d] = lowpass_filter(al,bl,a,v,d)

a(:,1) = filter(bl,al,a(:,1));
a(:,2) = filter(bl,al,a(:,2));
a(:,3) = filter(bl,al,a(:,3));

v(:,1) = filter(bl,al,v(:,1));
v(:,2) = filter(bl,al,v(:,2));
v(:,3) = filter(bl,al,v(:,3));

d(:,1) = filter(bl,al,v(:,1));
d(:,2) = filter(bl,al,v(:,2));
d(:,3) = filter(bl,al,v(:,3));


