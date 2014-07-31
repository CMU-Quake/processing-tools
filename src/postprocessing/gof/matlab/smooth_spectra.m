
function [S] = smooth_spectra(s,n)

% S = zeros(N,1);
% 
% S(1) = 0.75*s(1)+0.25*s(2);
% S(N) = 0.25*s(N-1)+0.75*s(N);
% 
% for i=2:N-1
%     S(i) = 0.25*s(i-1)+0.5*s(i)+0.25*s(i+1);
% end

% n = 5;
dx = pi/n;
x = [0:dx:2*pi]';
x = 1-cos(x);
x = x/2;
X = sum(x);
x = x/n;

S = conv(s,x,'same');

return;


