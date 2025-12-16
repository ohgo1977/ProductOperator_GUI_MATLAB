function click_CS(src,event)
    fig = ancestor(src,"figure","toplevel");

    SpinLabel=fig.UserData.rho.spin_label;
    
    for i = 1:length(SpinLabel)
        tc = fig.UserData.CS_t_var.Value;
        freq = ['o' SpinLabel{i}];
        ang = [freq '*' tc]
        check_symbols(ang);
        spin = SpinLabel{i};

        cmd = sprintf('cs(fig.UserData.rho,{''%s''},{%s});',spin,ang);
        fig.UserData.rho = eval(cmd);
    end
    fig.UserData.rho_cell{end+1} = fig.UserData.rho;

    update_display(src);
end
