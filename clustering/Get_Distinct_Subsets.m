function subsets = Get_Distinct_Subsets(array, begin_subset_len, end_subset_len)
arguments
    array
    begin_subset_len
    end_subset_len = -1
end
    if end_subset_len < begin_subset_len
        end_subset_len = length(array);
    end
    len = length(array);
    subset_count = 2^len;
    subsets = dec2bin(0:subset_count-1) - '0';
    subsets = subsets.*array;
    subsets = num2cell(subsets,2);
    
    remove_subsets = [];
    for i = 1:subset_count
        subset = subsets{i};
        subset(subset==0) = [];
        if isempty(subset) || length(subset)<begin_subset_len || length(subset)>end_subset_len
            remove_subsets = [remove_subsets,i];
        end
        subsets{i} = subset;
    end
    
    subsets(remove_subsets) = [];
end

