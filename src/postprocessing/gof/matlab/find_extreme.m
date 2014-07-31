
function [time,value] = find_extreme(S,DT,N)

value = 0;

for i = 1:N
    val = abs(S(i,1));
    ref = abs(value);
    if val > ref
        value = S(i,1);
        time = DT*(i-1);
    end
end

return