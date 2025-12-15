function Undo_callback(src,event)
    fig = ancestor(src,"figure","toplevel");
    if length(fig.UserData.rho_cell) <= 1
        return;
    end
    fig.UserData.rho_cell(end) = [];
    fig.UserData.rho = fig.UserData.rho_cell{end};
    update_display(src);
end