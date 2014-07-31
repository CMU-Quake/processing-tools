function [dt,t,a,v,d,n,tt] = load_hfile(file)

fp = fopen(file,'r');
fgetl(fp);

temp = fscanf(fp, '%g %g %g %g %g %g %g %g %g %g\n', [10,inf]);
temp = temp';

t = temp(:,1);
d = temp(:,2:4);
v = temp(:,5:7);
a = temp(:,8:10);

dt = temp(2,1);
n  = size(t);
n  = n(1);
tt = t(n,1);

fclose(fp);
