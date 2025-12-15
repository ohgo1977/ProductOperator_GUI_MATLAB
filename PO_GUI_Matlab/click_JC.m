function click_JC(src,event)
    fig = ancestor(src,"figure","toplevel");
    ang = fig.UserData.JC_var.Value;
    check_symbols(ang);
    pair = src.Text;

    cmd = sprintf('jc(fig.UserData.rho,{''%s''},{%s});',pair,ang);
    fig.UserData.rho = eval(cmd);
    fig.UserData.rho_cell{end+1} = fig.UserData.rho;

    update_display(src);
end
