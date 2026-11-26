function result = fivebarIK_project(Px, Py, modeLeft, modeRight)
% Reconstructed helper, not recovered original. Coordinates in mm; y down.
% Modes 1 and 2 select + and - angular branches respectively.
result = struct('ok',false,'theta1',NaN,'theta2',NaN,'theta3',NaN, ...
    'theta4',NaN,'A',[NaN NaN],'B',[NaN NaN],'message','');
if ~isscalar(Px) || ~isscalar(Py) || ~isreal(Px) || ~isreal(Py) || ...
        ~isfinite(Px) || ~isfinite(Py) || ~ismember(modeLeft,[1 2]) || ...
        ~ismember(modeRight,[1 2])
    result.message = 'Invalid input'; return
end
P = [Px Py];
[ok1,A,t1] = solveChain([0 0],P,modeLeft);
[ok2,B,t2] = solveChain([100 0],P,modeRight);
if ~(ok1 && ok2)
    result.message = 'Unreachable or degenerate target'; return
end
result.ok = true;
result.A = A; result.B = B;
result.theta1 = t1; result.theta2 = t2;
result.theta3 = atan2d(P(2)-A(2),P(1)-A(1));
result.theta4 = atan2d(P(2)-B(2),P(1)-B(1));
result.message = 'Geometric solution only; collision clearance not checked';
end

function [ok,J,t] = solveChain(O,P,mode)
a = 100; b = 150;
v = P-O; d = norm(v);
ok = false; J = [NaN NaN]; t = NaN;
if d < abs(a-b) || d > a+b || d == 0, return; end
c = (a*a+d*d-b*b)/(2*a*d);
alpha = acosd(max(-1,min(1,c)));
t = atan2d(v(2),v(1)) + (3-2*mode)*alpha;
J = O+a*[cosd(t) sind(t)];
ok = true;
end
