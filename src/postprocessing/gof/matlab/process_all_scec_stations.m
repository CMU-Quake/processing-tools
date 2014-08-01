
function process_all_scec_stations(dirin,dirout,listfile, buftime, N)

fp = fopen(listfile,'r');
fe = fopen([dirout 'stations-with-problems.txt'],'w');

for i = 1:N
    display([num2str(i) ' of ' num2str(N)]);
    name = fscanf(fp,'%s',1);
    flag = extract_scec_station(dirin,dirout,name,0, buftime);
    if flag < 1
        display(name);
        fprintf(fe,'%s\n',name);
    end
end

fclose(fp);
fclose(fe);