function Clear_callback(src,event)
    fig = ancestor(src,"figure","toplevel");
    fig.UserData.rho = fig.UserData.rho_cell{1};
    fig.UserData.rho_cell = {fig.UserData.rho};
    update_display(src);
end