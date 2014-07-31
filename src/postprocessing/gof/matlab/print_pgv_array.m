function print_pgv_array(dataset)

load(['mats/' dataset '-peak-vel.mat']);

xn = max(size(x));
yn = max(size(y));

fp = fopen(['../data-plain/' dataset '-pgv.txt'],'w');

for i = 1:xn;
    for j = 1:yn;
        fprintf(fp,'%12.4f %12.4f %12.4e\n',x(i),y(j),thePeakVel(i,j));
    end
end

fclose(fp);
