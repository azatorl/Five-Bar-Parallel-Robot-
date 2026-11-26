function fivebar_demo
% New offline demonstration. No serial connection or hardware commands.
f = uifigure('Name','Five-Bar Robot | Simulation','Position',[100 100 800 510]);
g = uigridlayout(f,[1 2]); g.ColumnWidth = {'1x',230};
ax = uiaxes(g);
p = uigridlayout(g,[8 1]); p.RowHeight = {32,22,32,22,32,36,36,'1x'};
uilabel(p,'Text','Kinematic simulation','FontWeight','bold');
uilabel(p,'Text','Px (mm) | 25–50');
x = uieditfield(p,'numeric','Value',50,'Limits',[25 50]);
uilabel(p,'Text','Py (mm) | 80–120');
y = uieditfield(p,'numeric','Value',80,'Limits',[80 120]);
uibutton(p,'Text','Preview target','ButtonPushedFcn',@(~,~) refresh());
uibutton(p,'Text','Home','ButtonPushedFcn',@(~,~) home());
out = uitextarea(p,'Editable','off');
refresh();
    function home
        x.Value=50; y.Value=80; refresh();
    end
    function refresh
        r=fivebarIK_project(x.Value,y.Value,1,2);
        if ~r.ok, out.Value={r.message}; return; end
        drawFivebarOnAxes(ax,x.Value,y.Value,r.A,r.B);
        title(ax,'Five-bar linkage | offline preview');
        out.Value={sprintf('Theta 1: %.2f deg',r.theta1), ...
            sprintf('Theta 2: %.2f deg',r.theta2), ...
            sprintf('Theta 3: %.2f deg',r.theta3), ...
            sprintf('Theta 4: %.2f deg',r.theta4),'','Simulation only'};
    end
end
