# Control implementation notes

This document summarizes the archived MATLAB App Designer v2 application and Arduino sketch. It is a source inspection, not a new hardware test.

## Command path

The GUI holds Px at 50 mm and rounds the requested Py to an integer, clamping it to 80–120 mm. It calls the external inverse-kinematics function with left/right modes 1 and 2. A successful result updates the visualization and four displayed joint angles. If serial communication is active, the Move callback sends a newline-terminated vertical position command.

The Arduino accepts a vertical coordinate, interpolates the two servo command angles from four calibration points, rounds them to integer degrees, applies angle limits, and increments the two software-tracked angles by one degree per 20 ms loop iteration until the commands are reached.

The physical end-effector position is not measured by this firmware. Servo commands and status messages must not be interpreted as measured joint angles or verified Cartesian positions.

## Worked command example

For a requested Py of 110 mm, the adjacent calibration points are 105 mm (95°, 85°) and 115 mm (100°, 80°). The interpolation fraction is 0.5. Applying the sketch's rounding yields 98° and 83°, respectively. This is a calculation from the stored table, not a measured result.

## Interface compatibility

| Feature | Earlier GUI | GUI v2 and archived Arduino sketch |
| --- | --- | --- |
| Vertical target | 30–140 mm configured | 80–120 mm |
| Home command | Raw angle pair | HOME |
| Position command | Incomplete Move callback | Y followed by target coordinate |
| Serial configuration | COM7 / 9600 | COM7 / 9600 in GUI; 9600 on Arduino |

The earlier GUI is retained as development history, not a drop-in replacement.

## Reproduction requirements

- MATLAB with App Designer and the separately reconstructed inverse-kinematics and visualization functions (original implementations not recovered).
- Arduino IDE with the Servo library.
- Arduino Uno and two MG995 servos, with an appropriately rated external servo power supply and common ground.
- A serial port matching the local machine; the archived GUI uses COM7.
- A mechanically verified assembly and calibrated home position before applying motion commands.

## Static review findings

1. The GUI's Send button has no assigned callback in the supplied v2 source; the Move callback actually sends the position command.
2. The sketch initializes its software-tracked angles to the home values. Consequently, its initial smooth-home call may perform no explicit servo write. A deliberate initialization write should be considered before retesting.
3. Numeric parsing should explicitly reject malformed commands; the current conversion can interpret invalid numeric input as zero before clamping.
4. Software angle limits do not establish collision-free operation or measured positioning accuracy. Manual angle commands in particular require mechanical verification.
5. The original hardware has not been retested for this documentation. No PID loop, measured Cartesian accuracy, or hardware validation is claimed.

These notes distinguish the implemented command path from the intended project workflow described in the team report.

## Reconstructed simulation (portfolio addition)

The geometric solver in `control/reconstructed/fivebarIK_project.m` uses the law of cosines for each two-link chain, with a positive-down y coordinate and the outward-elbow branch selection (1,2). The equivalent Python calculation was verified against the archived MATLAB home and target angles and joint coordinates; all 1,066 integer Cartesian targets in the 25–50 mm by 80–120 mm design rectangle satisfied the four link-length constraints within 1e-9 mm. This is geometric verification only, not a collision, actuator or accuracy test.

A MATLAB regression test and a simulation-only UI are included in the same directory. MATLAB/Octave was not available for executing the MATLAB code itself. The original GUI v2 automatically attempts a serial connection and sends HOME on startup; disconnect physical hardware before inspecting it. The new offline UI never sends hardware commands.

Original Arduino firmware is preserved in `software/sketch_may1a/`. No firmware compilation or live robot test has been performed. The original App Designer archives and CAD models are now available in `control/archive/` and `cad/`. Their original filenames are retained where needed for class and assembly dependencies.
