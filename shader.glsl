const float tau = 6.28318530718;

uniform float maxSpeed;
uniform float accelCurveShaper;
uniform vec2 acceleration;
uniform bool useOriginalAccelerationMultiplierMode;

vec2 rotate(vec2 v, float a) {
	float s = sin(a);
	float c = cos(a);
	mat2 m = mat2(c, s, -s, c);
	return m * v;
}

vec2 multiplyInDirection(vec2 v, float a, float m) {
	v = rotate(v, -a);
	v.x *= m;
	return rotate(v, a);
}

float getAccelerationMultiplierOriginalCore(float speed, float acceleration, float maxSpeed, float accelCurveShaper) {
	if (acceleration <= 0.0) {
		return 1.0;
	}
	return pow((maxSpeed - speed) / maxSpeed, 1.0 / accelCurveShaper);
}

float getAccelerationMultiplierOriginal(float velocity, float acceleration, float maxSpeed, float accelCurveShaper) {
	if (acceleration == 0.0) {
		return 0.0;
	} else if (velocity > -maxSpeed && velocity <= 0.0) {
		return getAccelerationMultiplierOriginalCore(-velocity, -acceleration, maxSpeed, accelCurveShaper);
	} else if (velocity >= 0.0 && velocity < maxSpeed) {
		return getAccelerationMultiplierOriginalCore(velocity, acceleration, maxSpeed, accelCurveShaper);
	} else if (sign(velocity) * sign(acceleration) == 1.0) {
		return 0.0;
	} else {
		return 1.0;
	}
}

float getAccelerationMultiplierDot(vec2 velocity, vec2 acceleration, float maxSpeed, float accelCurveShaper) {
	return 1.0 - pow(max(0.0, dot(velocity, normalize(acceleration))) / maxSpeed, 1.0 / accelCurveShaper);
}

vec4 effect(vec4 colour, sampler2D image, vec2 textureCoords, vec2 screenCoords) {
	vec2 coord = screenCoords - love_ScreenSize.xy * 0.5;

	vec2 velocity = coord;
	float velocityAngle = atan(velocity.y, velocity.x);
	vec2 accelInVelocityRotationSpace = rotate(acceleration, -velocityAngle);

	float multiplierInVelocityDirection;
	if (useOriginalAccelerationMultiplierMode) {
		multiplierInVelocityDirection = getAccelerationMultiplierOriginal(length(velocity), accelInVelocityRotationSpace.x, maxSpeed, accelCurveShaper);
	} else {
		multiplierInVelocityDirection = getAccelerationMultiplierDot(velocity, acceleration, maxSpeed, accelCurveShaper);
	}

	vec2 newAccel = multiplyInDirection(acceleration, velocityAngle, multiplierInVelocityDirection);

	return vec4((newAccel * 0.05 * 0.5 + 0.5), 0.0, 1.0);
	// return vec4(vec3(multiplierInVelocityDirection), 1.0);
	// return vec4( 
	// 	// mod(newAccel.x, 10.0) < 1.5 ? 1.0 : 0.0,
	// 	// mod(newAccel.y, 10.0) < 1.5 ? 1.0 : 0.0,
	// 	// 0.0,
	// 	vec3(
	// 		mod(length(newAccel), 12.5) < 1.0 ? 1.0 : 0.0
	// 	),
	// 	1.0
	// ); // Contours (flashing lights warning)
}
