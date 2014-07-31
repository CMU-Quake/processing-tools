
function convert_station_coords(latlonfile,xyfile,N)

infp  = fopen(latlonfile, 'r');
outfp = fopen(xyfile, 'w');


loncorners = [ -119.288842 -118.354016 -116.846030 -117.780976 ];
latcorners = [   34.120549   35.061096   34.025873   33.096503 ];

csii  = [ -1 -1  1  1 ];
ethai = [ -1  1  1 -1 ];

for i=1:N
   
    longitude = fscanf(infp, '%f', 1);
    latitude  = fscanf(infp, '%f', 1);
    
    xycoords = ethaandcsi(csii, ethai, longitude, latitude, loncorners, latcorners);
    
    x = xycoords(1);
    y = xycoords(2);
    
    fprintf(outfp, '%f\t%f\n', x, y);
    
end

fclose(infp);
fclose(outfp);

