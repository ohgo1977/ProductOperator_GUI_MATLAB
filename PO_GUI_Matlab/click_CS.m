function click_CS(src,event)
    fig = ancestor(src,"figure","toplevel");
    ang = fig.UserData.CS_var.Value;
    check_symbols(ang);
    spin = src.Text;

    cmd = sprintf('cs(fig.UserData.rho,{''%s''},{%s});',spin,ang);
    fig.UserData.rho = eval(cmd);
    fig.UserData.rho_cell{end+1} = fig.UserData.rho;

    update_display(src);
end
