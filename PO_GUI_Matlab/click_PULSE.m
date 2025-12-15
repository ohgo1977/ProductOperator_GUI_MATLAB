function click_PULSE(src,event)
    fig = ancestor(src,"figure","toplevel");
    FA = fig.UserData.FA_var.Value;
    PH = fig.UserData.PH_var.Value;
    spin = src.Text;
    if strcmp(spin, 'All Spins')
        spin = '*';
    end

    check_symbols(FA);
    check_symbols(PH);

    if any(strcmp(PH,{'x','y','-x','-y'}))
        cmd = sprintf('pulse(fig.UserData.rho,{''%s''},{''%s''},{%s});',spin,PH,FA);
    else
        cmd = sprintf('pulse_phshift(fig.UserData.rho,{''%s''},{%s},{%s});',spin,PH,FA);
    end

    fig.UserData.rho = eval(cmd);
    fig.UserData.rho_cell{end+1} = fig.UserData.rho;
    update_display(src);
end
