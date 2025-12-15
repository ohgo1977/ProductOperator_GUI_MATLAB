function cmd_typein(src,event)
    fig = ancestor(src,"figure","toplevel");
    cmd_ini=fig.UserData.CmdText.Value{1};
    set(fig.UserData.CmdText,'Value','')

    f1=strfind(cmd_ini,'{');
    f2=strfind(cmd_ini,'{''');
    % fv=intersect(f1,f2);
    fp=setxor(f1,f2);

    r1=strfind(cmd_ini,'}');
    r2=strfind(cmd_ini,'''}')+1;
    % rv=intersect(r1,r2);
    rp=setxor(r1,r2);

    for i = 1:length(fp)
        coef_str=cmd_ini(fp(i)+1:rp(i)-1);
        check_symbols(coef_str);
    end

    cmd = sprintf('fig.UserData.rho.%s;',cmd_ini);

    fig.UserData.rho = eval(cmd);
    fig.UserData.rho_cell{end+1} = fig.UserData.rho;
    update_display(src);
end
