
function pt = p_time(mx,VS,DT,N)

ref = 0.01*mx;

m = 4;
% m = 5;

for i = 1:3
    for t = (m+1):(N-m-1)

        s = VS(t-m:t+m,i);
        v = VS(t,i);

        if v > 0
            suma = sum(s > 0);
            peak = max(s);
            if ( suma == m*2+1 ) && ( v == peak ) && ( v > ref(i) )
                pt(i) = (t-1)*DT;
                break;
            end
        end
        
        if v < 0
            suma = sum(s < 0);
            peak = min(s);
            if ( suma == m*2+1 ) && ( v == peak ) && ( v < -ref(i) )
                pt(i) = (t-1)*DT;
                break;
            end
        end

%         if ( VS(t,i) > ref(i) ) && ...
%            ( VS(t,i) > VS(t-1,i) ) && ...
%            ( VS(t,i) > VS(t+1,i) )
%             pt(i) = (t-1)*DT;
%             break;
%         end
    end
end

return;
