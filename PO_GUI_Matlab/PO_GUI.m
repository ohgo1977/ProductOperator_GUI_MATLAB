% ------------------------------------------------------------------------
% File Name   : PO_GUI.m
% Description : Graphical User Interface for Product Operator Formalism of spin-1/2
% Requirement : MATLAB Symbolic Math Toolbox
% Developer   : Dr. Kosuke Ohgo
% ULR         : https://github.com/ohgo1977/ProductOperator_GUI_MATLAB
% Version     : 1.0.0
%
% Please read the manual (PO_GUI_Matlab_Manual.pdf) for details.
%
% ------------------------------------------------------------------------
%
% MIT License
%
% Copyright (c) 2025 Kosuke Ohgo
%
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.
%
% Revision Information
% Version 1.0.0
% December 15, 2025

function PO_GUI
    % Version
    ver_str = 'version 1.0.0';
    fprintf('PO_GUI %s\n', ver_str);

    % === USER INPUT ===
    val = input('Enter Spin Labels Separated by Commas (Default: I,S): ', 's');
    if isempty(val), val='I,S'; end
    val = strrep(val,' ','');
    SpinLabel = strsplit(val,',');
    fprintf('Spin Labels: %s\n', val);

    % Construct default rho string
    rho_str_ini = strjoin(strcat(SpinLabel,'z'), ' + ');
    rho_str = input(sprintf('Enter Initial Density Operator (Default: %s): ', rho_str_ini), 's');
    if isempty(rho_str), rho_str=rho_str_ini; end

    % === Initialize PO and rho ===
    PO.create(SpinLabel,{},'off');
    PO.symcoef(SpinLabel,{});

    % Generating coeffcients for the initla sate
    % Use script lines instead of the function check_symbols(). 
    % The function exist() used in check_symobls() can't search parameters in the workspace of the caller.
    % As a result, PO class parameters, such as Ix, will be replaced to sym class parameters.
    val = rho_str;
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
                eval(sprintf('%s = sym(''%s'');',v,v));
            end
        end
    end

    rho = eval(rho_str);    % dynamic evaluation
    disp('Initial Density Operator:');
    disp(rho.txt);

    % ============================
    % BUILD GUI
    % ============================
    fig = uifigure('Name',['PO_GUI ' ver_str], 'Position',[50 50 1400 700]);

    % Global storage: fig.UserData
    fig.UserData.rho = rho;
    fig.UserData.rho_cell = {rho};
    fig.UserData.prev_logs = rho.logs;
    fig.UserData.disp_logs = fig.UserData.prev_logs;

    % Panels
    fig.UserData.PulsePanel = uipanel(fig,'Title','Pulse','Position',[10 350 720 330]);
    fig.UserData.CSPanel    = uipanel(fig,'Title','Chemical Shift','Position',[10 120 720 220]);
    fig.UserData.EditPanel  = uipanel(fig,'Title','Edit','Position',[10 10 720 90]);
   
    fig.UserData.JCPanel    = uipanel(fig,'Title','J-Coupling','Position',[740 350 650 330]);
    fig.UserData.CmdPanel   = uipanel(fig,'Title','Command','Position',[740 260 650 80]);
    fig.UserData.DispPanel  = uipanel(fig,'Title','Spin Dynamics','Position',[740 10 650 240]);

    % ===============================================
    %       PULSE SECTION
    % ===============================================
    fig.UserData.FA = {'pi/4','pi/2','pi*3/4','pi','b'};
    fig.UserData.PH = {'x','y','-x','-y','f'};

    uilabel(fig.UserData.PulsePanel,'Text','Phase','Position',[10 260 60 20]);
    y = 230;
    fig.UserData.PH_var = uieditfield(fig.UserData.PulsePanel,'text','Position',[400 y 80 30],'Value','x');
    for k = 1:length(fig.UserData.PH)
        uibutton(fig.UserData.PulsePanel,'Text',fig.UserData.PH{k},'Position',[10+70*(k-1) y 60 30], ...
            'ButtonPushedFcn',@(btn,event) set(fig.UserData.PH_var,'Value',btn.Text));
    end

    uilabel(fig.UserData.PulsePanel,'Text','Flip Angle','Position',[10 190 80 20]);
    y = 160;
    fig.UserData.FA_var = uieditfield(fig.UserData.PulsePanel,'text','Position',[400 y 80 30],'Value','pi/2');
    for k = 1:length(fig.UserData.FA)
        uibutton(fig.UserData.PulsePanel,'Text',fig.UserData.FA{k},'Position',[10+70*(k-1) y 60 30], ...
            'ButtonPushedFcn',@(btn,event) set(fig.UserData.FA_var,'Value',btn.Text));
    end

    % Pulse Buttons (apply pulse to spin)
    y = 70;
    uilabel(fig.UserData.PulsePanel,'Text','Apply Pulse to','Position',[10 y+40 120 20]);
    for k = 1:length(SpinLabel)
        uibutton(fig.UserData.PulsePanel,'Text',SpinLabel{k},'Position',[10+120*(k-1) y 100 30],...
            'ButtonPushedFcn',@click_PULSE);
    end

    uibutton(fig.UserData.PulsePanel,'Text','All Spins','Position',[10+120*k y 100 30],...
    'ButtonPushedFcn',@click_PULSE);


    % ===============================================
    %      CHEMICAL SHIFT SECTION
    % ===============================================
    fig.UserData.CS = {'pi/2','pi','q'};
    for k=1:length(SpinLabel)
        fig.UserData.CS{end+1} = ['o' SpinLabel{k} '*t'];
    end

    uilabel(fig.UserData.CSPanel,'Text','Angle','Position',[10 150 60 20]);
    y = 120;
    for k = 1:length(fig.UserData.CS)
        uibutton(fig.UserData.CSPanel,'Text',fig.UserData.CS{k},'Position',[10+70*(k-1) y 60 30],...
            'ButtonPushedFcn',@(btn,event) set(fig.UserData.CS_var,'Value',btn.Text));
    end
    fig.UserData.CS_var = uieditfield(fig.UserData.CSPanel,'text','Position',[10+70*k y 80 30],'Value','q');

    uilabel(fig.UserData.CSPanel,'Text','Apply CS to','Position',[10 60 120 20]);
    y = 20;
    for k = 1:length(SpinLabel)
        uibutton(fig.UserData.CSPanel,'Text',SpinLabel{k},'Position',[10+120*(k-1) y 100 30],...
            'ButtonPushedFcn',@click_CS);
    end

    % ===============================================
    %      J-COUPLING SECTION
    % ===============================================
    JC_pair = {};
    for i = 1:length(SpinLabel)
        for j = i+1:length(SpinLabel)
            JC_pair{end+1} = [SpinLabel{i} SpinLabel{j}];
        end
    end
    fig.UserData.JC = {'pi/8','pi/4','pi/2','pi'};
    for i = 1:length(SpinLabel)
        for j = i+1:length(SpinLabel)
            fig.UserData.JC{end+1} = ['pi*J' SpinLabel{i}(end) SpinLabel{j}(end) '*t'];
        end
    end

    y = 260;
    uilabel(fig.UserData.JCPanel,'Text','Angle (pi*J*t)','Position',[10 y+20 100 20]);
    fig.UserData.JClabel = {'t=1/(8J)','t=1/(4J)','t=1/(2J)','t=1/(J)'};
    for j = 1:length(fig.UserData.JClabel)
        uilabel(fig.UserData.JCPanel,'Text',fig.UserData.JClabel{j},'Position',[10+70*(j-1) y 60 20]);
    end

    y = 230;
    fig.UserData.JC_var = uieditfield(fig.UserData.JCPanel,'text','Position',[550 y 80 30],'Value','pi/2');
    for k = 1:length(fig.UserData.JC)
        if k <= 7
            uibutton(fig.UserData.JCPanel,'Text',fig.UserData.JC{k},'Position',[10+70*(k-1) y 60 30],...
                'ButtonPushedFcn',@(btn,event) set(fig.UserData.JC_var,'Value',btn.Text));
        elseif (k > 7) && (k <= 14)
            uibutton(fig.UserData.JCPanel,'Text',fig.UserData.JC{k},'Position',[10+70*(k-1-7) y-40 60 30],...
                'ButtonPushedFcn',@(btn,event) set(fig.UserData.JC_var,'Value',btn.Text));
        end
    end

    % JC apply
    y = 70;
    uilabel(fig.UserData.JCPanel,'Text','Apply JC to','Position',[10 y+40 120 20]);
    for k = 1:length(JC_pair)
        if k <= 5
            uibutton(fig.UserData.JCPanel,'Text',JC_pair{k},'Position',[10+120*(k-1) y 100 30],...
                'ButtonPushedFcn',@click_JC);
        elseif (k > 5) && (k <=10)
            uibutton(fig.UserData.JCPanel,'Text',JC_pair{k},'Position',[10+120*(k-1-5) y-40 100 30],...
                'ButtonPushedFcn',@click_JC);
        end
    end

    % ===============================================
    %     DISPLAY PANEL
    % ===============================================
    fig.UserData.DispText = uitextarea(fig.UserData.DispPanel,...
        'Position',[10 10 600 200],...
        'Value',['Initial Density Operator: ' fig.UserData.disp_logs],...
        'Editable','off');

    % ===============================================
    %     COMMAND PANEL
    % ===============================================
 
    fig.UserData.CmdText = uitextarea(fig.UserData.CmdPanel,...
        'Position',[10 10 550 30],...
        'Value','',...
        'Editable','on');
    
    
    uibutton(fig.UserData.CmdPanel,'Text','Apply','Position',[570 10 50 30],...
            'ButtonPushedFcn',@cmd_typein);
            
    % ===============================================
    %      EDIT PANEL
    % ===============================================
    uibutton(fig.UserData.EditPanel,'Text','Undo','Position',[10 10 80 30],...
        'ButtonPushedFcn',@Undo_callback);

    uibutton(fig.UserData.EditPanel,'Text','Clear','Position',[110 10 80 30],...
        'ButtonPushedFcn',@Clear_callback);

    uibutton(fig.UserData.EditPanel,'Text','Save','Position',[210 10 80 30],...
        'ButtonPushedFcn',@Save_callback);

end