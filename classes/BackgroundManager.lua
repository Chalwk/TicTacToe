-- Tic-Tac-Toe Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local math_pi = math.pi
local math_sin = math.sin
local math_cos = math.cos
local math_random = math.random
local table_insert = table.insert

local BackgroundManager = {}
BackgroundManager.__index = BackgroundManager

function BackgroundManager.new()
    local instance = setmetatable({}, BackgroundManager)
    instance.menuParticles = {}
    instance.gameParticles = {}
    instance.time = 0
    instance:initMenuParticles()
    instance:initGameParticles()
    return instance
end

function BackgroundManager:initMenuParticles()
    self.menuParticles = {}
    for _ = 1, 50 do
        table_insert(self.menuParticles, {
            x = math_random() * 1000,
            y = math_random() * 1000,
            size = math_random(3, 8),
            speed = math_random(10, 40),
            angle = math_random() * math_pi * 2,
            pulseSpeed = math_random(0.5, 2),
            pulsePhase = math_random() * math_pi * 2,
            type = math_random() > 0.5 and "X" or "O",
            rotation = math_random() * math_pi * 2,
            rotationSpeed = (math_random() - 0.5) * 4
        })
    end
end

function BackgroundManager:initGameParticles()
    self.gameParticles = {}
    for _ = 1, 30 do
        table_insert(self.gameParticles, {
            x = math_random() * 1000,
            y = math_random() * 1000,
            size = math_random(2, 6),
            speed = math_random(5, 25),
            angle = math_random() * math_pi * 2,
            type = math_random() > 0.5 and "X" or "O",
            rotation = math_random() * math_pi * 2,
            rotationSpeed = (math_random() - 0.5) * 3,
            isGlowing = math_random() > 0.8,
            glowPhase = math_random() * math_pi * 2
        })
    end
end

function BackgroundManager:update(dt)
    self.time = self.time + dt

    -- Update menu particles
    for _, particle in ipairs(self.menuParticles) do
        particle.x = particle.x + math_cos(particle.angle) * particle.speed * dt
        particle.y = particle.y + math_sin(particle.angle) * particle.speed * dt
        particle.rotation = particle.rotation + particle.rotationSpeed * dt

        if particle.x < -50 then particle.x = 1000 + 50 end
        if particle.x > 1000 + 50 then particle.x = -50 end
        if particle.y < -50 then particle.y = 1000 + 50 end
        if particle.y > 1000 + 50 then particle.y = -50 end
    end

    -- Update game particles
    for _, particle in ipairs(self.gameParticles) do
        particle.x = particle.x + math_cos(particle.angle) * particle.speed * dt
        particle.y = particle.y + math_sin(particle.angle) * particle.speed * dt
        particle.rotation = particle.rotation + particle.rotationSpeed * dt
        particle.glowPhase = particle.glowPhase + dt * 2

        if particle.x < -50 then particle.x = 1000 + 50 end
        if particle.x > 1000 + 50 then particle.x = -50 end
        if particle.y < -50 then particle.y = 1000 + 50 end
        if particle.y > 1000 + 50 then particle.y = -50 end
    end
end

function BackgroundManager:drawMenuBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Circuit board gradient background
    for y = 0, screenHeight, 4 do
        local progress = y / screenHeight
        local pulse = (math_sin(time * 2 + progress * 4) + 1) * 0.05

        local r = 0.1 + progress * 0.1 + pulse
        local g = 0.15 + progress * 0.2 + pulse
        local b = 0.25 + progress * 0.3 + pulse

        love.graphics.setColor(r, g, b, 0.8)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Floating X and O particles
    for _, particle in ipairs(self.menuParticles) do
        local pulse = (math_sin(particle.pulsePhase + time * particle.pulseSpeed) + 1) * 0.3
        local alpha = 0.4 + pulse * 0.3

        if particle.type == "X" then
            love.graphics.setColor(0.8, 0.3, 0.3, alpha)
        else
            love.graphics.setColor(0.3, 0.6, 0.8, alpha)
        end

        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        love.graphics.rotate(particle.rotation)
        love.graphics.scale(particle.size / 15, particle.size / 15)
        love.graphics.print(particle.type, -4, -6)
        love.graphics.pop()
    end

    -- Grid pattern in background
    love.graphics.setColor(0.3, 0.4, 0.6, 0.1)
    local gridSize = 80
    for x = 0, screenWidth, gridSize do
        for y = 0, screenHeight, gridSize do
            love.graphics.rectangle("line", x, y, gridSize, gridSize)
        end
    end
end

function BackgroundManager:drawGameBackground(screenWidth, screenHeight)
    local time = love.timer.getTime()

    -- Deep blue grid background
    for y = 0, screenHeight, 3 do
        local progress = y / screenHeight
        local wave = math_sin(progress * 8 + time) * 0.03
        local r = 0.05 + wave
        local g = 0.08 + progress * 0.1 + wave
        local b = 0.15 + progress * 0.2 + wave

        love.graphics.setColor(r, g, b, 0.9)
        love.graphics.line(0, y, screenWidth, y)
    end

    -- Game particles
    for _, particle in ipairs(self.gameParticles) do
        local alpha = 0.3
        if particle.isGlowing then
            local glow = (math_sin(particle.glowPhase) + 1) * 0.2
            alpha = 0.2 + glow
        end

        if particle.type == "X" then
            love.graphics.setColor(1, 0.4, 0.4, alpha)
        else
            love.graphics.setColor(0.4, 0.8, 1, alpha)
        end

        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        love.graphics.rotate(particle.rotation)
        love.graphics.scale(particle.size / 12, particle.size / 12)
        love.graphics.print(particle.type, -4, -6)
        love.graphics.pop()
    end

    -- Subtle grid lines
    love.graphics.setColor(0.2, 0.3, 0.5, 0.15)
    local cellSize = 40
    for x = 0, screenWidth, cellSize do
        love.graphics.line(x, 0, x, screenHeight)
    end
    for y = 0, screenHeight, cellSize do
        love.graphics.line(0, y, screenWidth, y)
    end
end

return BackgroundManager
