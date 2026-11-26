function drawFivebarOnAxes(ax,Px,Py,A,B)
% Reconstructed plotting helper. Geometry only, no hardware commands.
cla(ax); hold(ax,'on'); grid(ax,'on'); axis(ax,'equal');
O1=[0 0]; O2=[100 0]; P=[Px Py];
plot(ax,[O1(1) O2(1)],[0 0],'-','Color',[.4 .4 .4],'LineWidth',3);
plot(ax,[O1(1) A(1)],[O1(2) A(2)],'b-','LineWidth',3);
plot(ax,[O2(1) B(1)],[O2(2) B(2)],'b-','LineWidth',3);
plot(ax,[A(1) P(1) B(1)],[A(2) P(2) B(2)],'-','Color',[.85 .4 .1],'LineWidth',3);
j=[O1;O2;A;B]; plot(ax,j(:,1),j(:,2),'ko','MarkerFaceColor','k');
plot(ax,Px,Py,'ro','MarkerFaceColor','r');
set(ax,'YDir','reverse'); xlabel(ax,'Px (mm)'); ylabel(ax,'Py (mm)');
xlim(ax,[-115 215]); ylim(ax,[-20 180]); hold(ax,'off');
end
