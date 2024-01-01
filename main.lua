local vec2 = require("lib.mathsies").vec2

local tau = math.pi * 2

local dummy = love.graphics.newImage(love.image.newImageData(1, 1))
local shader = love.graphics.newShader("shader.glsl")

local maxSpeed = 100
local maxAccel = 50
local accelCurveShaper = 1.5
local acceleration = vec2(maxAccel, 0)

local dotVelocity = vec2(0, 0)
local speedRegulationHarshness = 10e-10
local speedRegulationMultiplier = 1 - speedRegulationHarshness

local function normaliseOrZero(v)
	local l = #v
	if l == 0 then
		return vec2.clone(v)
	end
	return vec2.normalise(v)
end

local function setVectorLength(v, l)
	return normaliseOrZero(v) * l
end

local function sign(x)
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	end
	return 0
end

local function getAccelerationMultiplier(velocity, accelerationDirection, maxSpeed, accelCurveShaper)
	if accelerationDirection == 0 then
		return 0
	end
	local function getAccelerationMultiplierCore(speed, accelerationDirection)
		-- Speed can't be negative, and accelerationDirection should be negated (whether that's positive or negative) if velocity was too
		if accelerationDirection <= 0 then
			return 1
		end
		return ((maxSpeed - speed) / maxSpeed) ^ (1 / accelCurveShaper)
	end
	if velocity > -maxSpeed and velocity <= 0 then
		return getAccelerationMultiplierCore(-velocity, -accelerationDirection)
	elseif velocity >= 0 and velocity < maxSpeed then
		return getAccelerationMultiplierCore(velocity, accelerationDirection)
	elseif sign(velocity) * sign(accelerationDirection) == 1 then
		-- If you're trying to accelerate in the same direction you're moving and abs(vel) >= maxSpeed then no movement
		return 0
	else
		return 1
	end
end

local function multiplyVectorInDirection(v, a, m)
	local vRotated = vec2.rotate(v, -a)
	vRotated.x = vRotated.x * m
	return vec2.rotate(vRotated, a)
end

local function shortestAngleDifference(a, b)
	return (a - b + tau / 2) % tau - tau / 2
end

function love.update(dt)
	local accelerationChangeRate = 100
	local accelerationChange = vec2()
	if love.keyboard.isDown("w") then
		accelerationChange.y = accelerationChange.y - 1
	end
	if love.keyboard.isDown("s") then
		accelerationChange.y = accelerationChange.y + 1
	end
	if love.keyboard.isDown("a") then
		accelerationChange.x = accelerationChange.x - 1
	end
	if love.keyboard.isDown("d") then
		accelerationChange.x = accelerationChange.x + 1
	end
	if #accelerationChange > 0 then
		acceleration = acceleration + vec2.normalise(accelerationChange) * accelerationChangeRate * dt
	end

	-- Accelerate dot
	if love.keyboard.isDown("1") then
		dotVelocity = vec2(0, 0)
	elseif love.keyboard.isDown("2") then
		dotVelocity = vec2(maxSpeed * 2, 0)
	end
	local accelerationVector
	if #dotVelocity > 0 then
		local velocityAngle = vec2.toAngle(dotVelocity)
		local accelRotated = vec2.rotate(acceleration, -velocityAngle)
		local multiplier = getAccelerationMultiplier(#dotVelocity, accelRotated.x, maxSpeed, accelCurveShaper)
		accelerationVector = multiplyVectorInDirection(acceleration, velocityAngle, multiplier)
	else
		accelerationVector = acceleration
	end
	-- If acceleration would increase speed while being over max speed, cap it to previous speed or max speed, whichever is higher. Preserves direction
	local attemptedDelta = accelerationVector * dt
	local attemptedNewVelocity = dotVelocity + attemptedDelta
	local finalDelta, finalNewVelocity
	if #attemptedNewVelocity > maxSpeed and #attemptedNewVelocity > #dotVelocity then
		finalNewVelocity = setVectorLength(attemptedNewVelocity, math.max(maxSpeed, #dotVelocity) * speedRegulationMultiplier)
		finalDelta = finalNewVelocity - dotVelocity
		-- #finalDelta may be larger than #attemptedDelta
		assert(#finalNewVelocity <= #attemptedNewVelocity, "Attempting to reduce speed below a speed the dot shouldn't go above resulted in an increase in its speed")
	else
		finalDelta = attemptedDelta
		finalNewVelocity = attemptedNewVelocity
	end
	-- Divide finalDelta by dt to get final acceleration
	dotVelocity = finalNewVelocity
end

function love.draw()
	love.graphics.setShader(shader)
	shader:send("maxSpeed", maxSpeed)
	shader:send("accelCurveShaper", accelCurveShaper)
	shader:send("acceleration", {vec2.components(acceleration)})
	love.graphics.draw(dummy, 0, 0, 0, love.graphics.getDimensions())
	love.graphics.setShader()
	love.graphics.setLineWidth(3)
	love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, maxSpeed)
	-- love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, maxAccel)
	love.graphics.line(
		love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,
		love.graphics.getWidth() / 2 + acceleration.x, love.graphics.getHeight() / 2 + acceleration.y
	)
	love.graphics.setPointSize(6)
	love.graphics.points(vec2.components(vec2(love.graphics.getDimensions()) / 2 + dotVelocity))
	love.graphics.print(
		"Point speed: " .. #dotVelocity .. "\n" ..
		"Angle diff of accel and point vel: " .. shortestAngleDifference(vec2.toAngle(dotVelocity), vec2.toAngle(acceleration))
	)
end
