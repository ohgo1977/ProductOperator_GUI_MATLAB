function Save_callback(src,event)
    fig = ancestor(src,"figure","toplevel");
    [file,path] = uiputfile('PO_Result.txt','Save Output');
    if file==0, return; end
    f = fopen(fullfile(path,file),'w');
    
    fprintf(f, '%s\n',fig.UserData.disp_logs);
    fclose(f);
end
