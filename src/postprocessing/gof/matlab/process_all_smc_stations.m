
function process_all_smc_stations(dirin,dirout,listfile,N)

fp = fopen(listfile,'r');
fe = fopen([dirout 'stations-with-problems.txt'],'w');

for i = 1:N
    display([num2str(i) ' of ' num2str(N)]);
    name = fscanf(fp,'%s',1);
    flag = extract_smc_station(dirin,dirout,name,0);
    if flag < 1
        display(name);
        fprintf(fe,'%s\n',name);
    end
end

fclose(fp);
fclose(fe);