local vec2 = require("lib.mathsies").vec2

local dummy = love.graphics.newImage(love.image.newImageData(1, 1))
local shader = love.graphics.newShader("shader.glsl")

local maxSpeed = 100
local maxAccel = 50
local accelCurveShaper = 1.5
local acceleration = vec2(maxAccel, 0)

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
end

function love.draw()
	love.graphics.setShader(shader)
	shader:send("maxSpeed", maxSpeed)
	shader:send("accelCurveShaper", accelCurveShaper)
	shader:send("acceleration", {vec2.components(acceleration)})
	love.graphics.draw(dummy, 0, 0, 0, love.graphics.getDimensions())
	love.graphics.setShader()
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, maxSpeed)
	-- love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, maxAccel)
	love.graphics.line(
		love.graphics.getWidth() / 2, love.graphics.getHeight() / 2,
		love.graphics.getWidth() / 2 + acceleration.x, love.graphics.getHeight() / 2 + acceleration.y
	)
	love.graphics.setColor(1, 1, 1)
end
