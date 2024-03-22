# Racer Acceleration Visualisation

Imagine a racing machine that has a top speed (acceleration drops off as you start to push into it).
For any arbitrary attempted acceleration from its engine and any arbitrary velocity it is moving at, what acceleration would it experience?

Origin is in centre of screen.
Circle is max speed.
Line is attempted acceleration vector.
XY pos of pixel around origin is velocity of machine.
R and G colour channels of pixel correspond to X and Y of damped acceleration (acceleration multiplied by a number in [0, 1] in direction of velocity).

Grey dot is an object's velocity, following the damped accelerations.
Notice how the dot tends to move along the max speed circle when accelerating in a new direction while the dot is at max speed, unless it's a large enough change in direction to pull the dot off the circle.

The code to accelerate the dot's velocity gets the acceleration from the function, but it also disables accelerating beyond max speed, or if it is already beyond max speed, any further than current speed (considering the function in a purer mathematical sense without the precision limitations of computers, it may not actually have the problem of accelerating (slowly) over max speed. It might just be due to how it's calculated).
The way limiting the speed is achieved is by checking that the attempted new velocity (`currentVelocity + accelerationFromFunction * deltaTime`) this frame is above max speed, and if it is, trimming the new velocity's length to `max(maxSpeed, lengthOfCurrentVelocity) * speedRegulationMultiplier`.
(`lengthOfCurrentVelocity` is not to be confused with the length of the attempted new velocity.)
Without the multiplier, precision problems cause continued increase in speed.
`speedRegulationMultiplier` is a number a very small amount below 1, which drags above-max-speed velocities backwards a bit, so that if your velocity's magnitude does change, it's decreasing.
If the `max` function is replaced with just the length of the current velocity, the speed is less static at max speed.
This is all for a racing machine without considering any other slowdown forces.

There are two acceleration multiplier calculation modes.
One rotates velocity and position by the same rotation which puts velocity on the x axis and then does some calculations with the resultant numbers, the other uses the dot product.
They both have a different character and create different shapes, and you can see the different shapes by uncommenting in a different return statement from `effect` in `shader.glsl`. Don't forget to comment out the return statements above that you are no longer using.
The dot product mode doesn't seem to step over max speed so easily.

WASD to move acceleration vector.
1 to reset dot velocity to origin.
2 to set dot velocity to twice max speed in the +x direction.
M to switch acceleration multiplier modes.
