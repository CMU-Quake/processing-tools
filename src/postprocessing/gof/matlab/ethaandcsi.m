function local0 = ethaandcsi(csii, ethai, x,y,xi,yi);

%%-------------------------------------------------------------------------
%  function to find a point in a bilinear element
%
%  Longitude and Latitude of the corners
%
% xi = [ -121.0 -118.951292 -113.943965 -116.032285 ]
% yi = [   34.5   36.621696   33.122341   31.082920 ]
%
% xi = [ -119.288842 -118.354016 -116.846030 -117.780976 ]
% yi = [   34.120549   35.061096   34.025873   33.096503 ]
% 
%                 2----------------3
%                 |       ^Y       |
%                 |       |    X   |
%                 |        ---->   |
%                 |                | 
%                 |                | 
%                 1----------------4
%
%
%    You may input the convention of nodal numeration it has to be given in csii
%    and ethai arrays. In the figure for example you have: 
%            csii  = [ -1 -1  1  1 ]
%            ethai = [ -1  1  1 -1 ]
%
%    and xi and yi are the lon and lat of the corners
%             xi = [  lon1     lon2     lon3     lon4 ]
%             yi = [  lat1     lat2     lat3     lat4 ]
%
%    it return lon lat in an array.
%% ------------------------------------------------------------------------


J1(1,1) = dot(xi,csii);
J1(1,2) = dot(xi,ethai);
J1(2,1) = dot(yi,csii);
J1(2,2) = dot(yi,ethai);

%Initial values for csi and etha

local0=[0 0]';
globalCoord=[x y]';

res=1e10;

% Matrix

while( res > 1e-6 )
    

    J2(1,1) = local0(2)*dot(xi.*csii,ethai);
    J2(1,2) = local0(1)*dot(xi.*csii,ethai);
    J2(2,1) = local0(2)*dot(yi.*csii,ethai);
    J2(2,2) = local0(1)*dot(yi.*csii,ethai);

    
    J = .25*(J1 + J2);
    
    Jinv= inv(J);
    
    % Compute x(csi0,etha0) and y(csi0,etha0)
    x_0(1) = 0;
    x_0(2) = 0;
        
    for iNode=1:4

            x_0(1) = x_0(1) +  xi(iNode)     * ...
                    ( .25*( 1 + csii ( iNode ) * local0(1) ) * ...
                          ( 1 + ethai( iNode ) * local0(2) )  );
             
            x_0(2) = x_0(2) +  yi(iNode)     * ...
                    ( .25*( 1 + csii ( iNode ) * local0(1) ) * ...
                          ( 1 + ethai( iNode ) * local0(2) )  );        
                      
    end
    
    delta=Jinv*(-x_0'+globalCoord);
    
    local0 = local0+delta;
    
    res=dot(delta,delta)^.5;
    
end

local0    = local0 + 1;
local0(1) = local0(1)*180000/2;
local0(2) = local0(2)*135000/2;
