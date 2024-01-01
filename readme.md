# Racer Acceleration Visualisation

Imagine a racing machine that has a top speed (acceleration drops off as you start to push into it).
For any arbitrary acceleration from its engine and any arbitrary velocity it is moving at, what acceleration would it experience?

Origin is in centre of screen.
Black circle is max speed.
Black line is attempted acceleration vector.
XY pos of pixel around origin is velocity of machine.
R and G colour channels of pixel correspond to X and Y of damped acceleration (acceleration multiplied by a number in [0, 1] in direction of velocity).

WASD to move acceleration vector.
