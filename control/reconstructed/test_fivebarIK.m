function test_fivebarIK
% Run from MATLAB after adding control/reconstructed to the path.
h = fivebarIK_project(50,80,1,2);
assert(h.ok)
assert(max(abs([h.theta1 h.theta2 h.theta3 h.theta4]- ...
    [158.9940694755572 21.00593052444278 17.11898109759706 162.88101890240293])) < 1e-8)
q = fivebarIK_project(50,50,1,2);
assert(q.ok)
assert(max(abs([q.theta1 q.theta2 q.theta3 q.theta4]- ...
    [167.027760113815 12.972239886185 10.584224422916224 169.41577557708376])) < 1e-8)
for x = 25:50
    for y = 80:120
        s = fivebarIK_project(x,y,1,2);
        assert(s.ok)
        assert(max(abs([norm(s.A),norm(s.B-[100 0]), ...
            norm([x y]-s.A),norm([x y]-s.B)]-[100 100 150 150])) < 1e-8)
    end
end
bad = fivebarIK_project(50,500,1,2);
assert(~bad.ok)
disp('Kinematic tests passed.')
end
