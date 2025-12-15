function update_display(src)
    fig = ancestor(src,"figure","toplevel");
    logs = fig.UserData.rho.logs;
    LF_vec = [];
    for ii = 1:size(logs,1)
        LF_vec = [LF_vec;newline];
    end
    logs_mat = [logs LF_vec];
    logs_vec = reshape(logs_mat',1,numel(logs_mat));

    fig.UserData.disp_logs = ['Initial Density Operator: ' logs_vec];
    fig.UserData.prev_logs = fig.UserData.rho.logs;

    fig.UserData.DispText.Value = {[fig.UserData.disp_logs]};
end
