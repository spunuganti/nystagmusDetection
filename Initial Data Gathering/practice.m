    for i = 2:numel(a1)
        idx2 = find(b1>=a1(i)-10 & b1<=a1(i)+10);
        if ~isempty(intersect(idx2,idx1))
            disp('yes')
            idx = setdiff(idx2,idx1);
            if isempty(idx)
               idx = intersect( idx1,idx2);
            end
            if numel(idx)>1 
                TR(i) = NaN;
                time(i) = NaN;
            elseif numel(idx) ==1
                TR(i) = torsionData.TR(idx);
                time(i) = b1(idx);
                count = count+1;           
            end       
        else
            disp('No')
            if numel(idx2)==1
                TR(i) = torsionData.TR(idx2);
                time(i) = b1(idx2);
                count = count+1;
            else
                TR(i) = NaN;
                time(i) = NaN;
            end
        end
        i
        if time(i-1)==time(i)
           TR(i) = NaN; 
           time(i) = NaN;
        end
        idx1 = idx2;
    end