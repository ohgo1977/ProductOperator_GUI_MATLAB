function check_symbols(val)
    ops = {'*','/','+','-','.','(',')',' '};
    for k = 1:length(ops)
        val = strrep(val, ops{k}, ',');
    end
    parts = strsplit(val,',');

    for i = 1:length(parts)
        v = parts{i};
        if isempty(v), continue; end
        if strcmp(v,'pi'), continue; end
        if isnan(str2double(v))
            if ~exist(v,'var')
                evalin('caller',sprintf('%s = sym(''%s'');',v,v));% Should be caller
            end
        end
    end
end
