-- Tic-Tac-Toe Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_pi = math.pi
local math_min = math.min
local math_floor = math.floor
local math_random = math.random
local table_insert = table.insert
local table_remove = table.remove

local Game = {}
Game.__index = Game

function Game.new()
    local instance = setmetatable({}, Game)

    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.boardSize = 3
    instance.cellSize = 100
    instance.board = {}
    instance.currentPlayer = "X"
    instance.gameOver = false
    instance.winner = nil
    instance.winningLine = nil
    instance.moves = 0
    instance.gameMode = "pvp" -- pvp or ai
    instance.animations = {}
    instance.cellParticles = {}

    instance:initBoard()

    return instance
end

function Game:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:calculateCellSize()
end

function Game:calculateCellSize()
    local maxSize = math_min(self.screenWidth, self.screenHeight) * 0.7
    self.cellSize = maxSize / self.boardSize
    self.boardX = (self.screenWidth - self.cellSize * self.boardSize) / 2
    self.boardY = (self.screenHeight - self.cellSize * self.boardSize) / 2
end

function Game:initBoard()
    self.board = {}
    for i = 1, self.boardSize do
        self.board[i] = {}
        for j = 1, self.boardSize do
            self.board[i][j] = ""
        end
    end
end

function Game:startNewGame(boardSize, gameMode)
    self.boardSize = boardSize or 3
    self.gameMode = gameMode or "pvp"
    self:calculateCellSize()
    self:initBoard()
    self.currentPlayer = "X"
    self.gameOver = false
    self.winner = nil
    self.winningLine = nil
    self.moves = 0
    self.animations = {}
    self.cellParticles = {}
end

function Game:resetGame()
    self:startNewGame(self.boardSize, self.gameMode)
end

function Game:update(dt)
    -- Update animations
    for i = #self.animations, 1, -1 do
        local anim = self.animations[i]
        anim.progress = anim.progress + dt / anim.duration

        if anim.progress >= 1 then
            table_remove(self.animations, i)
        end
    end

    -- Update particles
    for i = #self.cellParticles, 1, -1 do
        local particle = self.cellParticles[i]
        particle.life = particle.life - dt
        particle.x = particle.x + particle.dx * dt
        particle.y = particle.y + particle.dy * dt
        particle.rotation = particle.rotation + particle.dr * dt

        if particle.life <= 0 then
            table_remove(self.cellParticles, i)
        end
    end

    -- AI move
    if not self.gameOver and self.gameMode == "ai" and self.currentPlayer == "O" then
        self:makeAIMove()
    end
end

function Game:makeAIMove()
    -- Simple AI: find first empty cell
    for i = 1, self.boardSize do
        for j = 1, self.boardSize do
            if self.board[i][j] == "" then
                self:makeMove(i, j)
                return
            end
        end
    end
end

function Game:createParticles(x, y, player, count)
    local color = player == "X" and { 1, 0.3, 0.3 } or { 0.3, 0.6, 1 }
    for _ = 1, count or 8 do
        table_insert(self.cellParticles, {
            x = x,
            y = y,
            dx = (math_random() - 0.5) * 100,
            dy = (math_random() - 0.5) * 100,
            dr = (math_random() - 0.5) * 10,  -- rotation speed
            life = math_random(0.5, 1.5),
            color = color,
            size = math_random(2, 6),
            type = player,
            rotation = math_random() * math_pi * 2  -- initial rotation
        })
    end
end

function Game:makeMove(row, col)
    if self.gameOver or self.board[row][col] ~= "" then
        return false
    end

    self.board[row][col] = self.currentPlayer
    self.moves = self.moves + 1

    -- Create particle effect
    local cellX, cellY = self:getCellCenter(row, col)
    self:createParticles(cellX, cellY, self.currentPlayer, 12)

    -- Add placement animation
    table_insert(self.animations, {
        type = "place",
        row = row,
        col = col,
        player = self.currentPlayer,
        progress = 0,
        duration = 0.3
    })

    -- Check for win
    if self:checkWin(row, col) then
        self.gameOver = true
        self.winner = self.currentPlayer
        self:createWinParticles()
    elseif self.moves == self.boardSize * self.boardSize then
        self.gameOver = true
        self.winner = "Draw"
    else
        self.currentPlayer = self.currentPlayer == "X" and "O" or "X"
    end

    return true
end

function Game:checkWin(row, col)
    local player = self.board[row][col]

    -- Check row
    local win = true
    for i = 1, self.boardSize do
        if self.board[row][i] ~= player then
            win = false
            break
        end
    end
    if win then
        self.winningLine = { type = "row", index = row }
        return true
    end

    -- Check column
    win = true
    for i = 1, self.boardSize do
        if self.board[i][col] ~= player then
            win = false
            break
        end
    end
    if win then
        self.winningLine = { type = "col", index = col }
        return true
    end

    -- Check main diagonal
    if row == col then
        win = true
        for i = 1, self.boardSize do
            if self.board[i][i] ~= player then
                win = false
                break
            end
        end
        if win then
            self.winningLine = { type = "diag", index = 1 }
            return true
        end
    end

    -- Check anti-diagonal
    if row + col == self.boardSize + 1 then
        win = true
        for i = 1, self.boardSize do
            if self.board[i][self.boardSize - i + 1] ~= player then
                win = false
                break
            end
        end
        if win then
            self.winningLine = { type = "diag", index = 2 }
            return true
        end
    end

    return false
end

function Game:createWinParticles()
    if not self.winningLine then return end

    local particles = 30
    if self.winningLine.type == "row" then
        local row = self.winningLine.index
        for col = 1, self.boardSize do
            local x, y = self:getCellCenter(row, col)
            self:createParticles(x, y, self.winner, particles / self.boardSize)
        end
    elseif self.winningLine.type == "col" then
        local col = self.winningLine.index
        for row = 1, self.boardSize do
            local x, y = self:getCellCenter(row, col)
            self:createParticles(x, y, self.winner, particles / self.boardSize)
        end
    elseif self.winningLine.type == "diag" then
        if self.winningLine.index == 1 then
            for i = 1, self.boardSize do
                local x, y = self:getCellCenter(i, i)
                self:createParticles(x, y, self.winner, particles / self.boardSize)
            end
        else
            for i = 1, self.boardSize do
                local x, y = self:getCellCenter(i, self.boardSize - i + 1)
                self:createParticles(x, y, self.winner, particles / self.boardSize)
            end
        end
    end
end

function Game:getCellCenter(row, col)
    local x = self.boardX + (col - 0.5) * self.cellSize
    local y = self.boardY + (row - 0.5) * self.cellSize
    return x, y
end

function Game:getCellFromPos(x, y)
    local col = math_floor((x - self.boardX) / self.cellSize) + 1
    local row = math_floor((y - self.boardY) / self.cellSize) + 1

    if row >= 1 and row <= self.boardSize and col >= 1 and col <= self.boardSize then
        return row, col
    end
    return nil, nil
end

function Game:handleClick(x, y)
    if self.gameOver then
        return
    end

    if self.gameMode == "ai" and self.currentPlayer == "O" then
        return -- AI's turn
    end

    local row, col = self:getCellFromPos(x, y)
    if row and col then
        self:makeMove(row, col)
    end

    -- Check reset button
    if x >= self.screenWidth - 140 and x <= self.screenWidth - 20 and
        y >= 20 and y <= 60 then
        self:resetGame()
    end
end

function Game:draw()
    self:drawBoard()
    self:drawPieces()
    self:drawUI()
    self:drawParticles()

    if self.gameOver then
        self:drawGameOver()
    end
end

function Game:drawBoard()
    -- Draw board background
    love.graphics.setColor(0.1, 0.1, 0.2, 0.8)
    love.graphics.rectangle("fill", self.boardX - 10, self.boardY - 10,
        self.cellSize * self.boardSize + 20,
        self.cellSize * self.boardSize + 20, 5)

    -- Draw grid lines
    love.graphics.setColor(0.6, 0.7, 1)
    love.graphics.setLineWidth(3)

    for i = 0, self.boardSize do
        local x = self.boardX + i * self.cellSize
        love.graphics.line(x, self.boardY, x, self.boardY + self.cellSize * self.boardSize)
    end

    for i = 0, self.boardSize do
        local y = self.boardY + i * self.cellSize
        love.graphics.line(self.boardX, y, self.boardX + self.cellSize * self.boardSize, y)
    end

    love.graphics.setLineWidth(1)
end

function Game:drawPieces()
    local font = love.graphics.newFont(math_floor(self.cellSize * 0.6))

    for row = 1, self.boardSize do
        for col = 1, self.boardSize do
            local player = self.board[row][col]
            if player ~= "" then
                local x, y = self:getCellCenter(row, col)
                local scale = 1

                -- Check for animation
                for _, anim in ipairs(self.animations) do
                    if anim.type == "place" and anim.row == row and anim.col == col then
                        scale = anim.progress
                        break
                    end
                end

                if player == "X" then
                    love.graphics.setColor(1, 0.4, 0.4)
                else
                    love.graphics.setColor(0.4, 0.8, 1)
                end

                love.graphics.push()
                love.graphics.translate(x, y)
                love.graphics.scale(scale, scale)
                love.graphics.setFont(font)
                love.graphics.print(player, -font:getWidth(player) / 2, -font:getHeight() / 2)
                love.graphics.pop()
            end
        end
    end
end

function Game:drawUI()
    -- Current player indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))

    if not self.gameOver then
        local text = "Current Player: " .. self.currentPlayer
        if self.gameMode == "ai" and self.currentPlayer == "O" then
            text = "AI Thinking..."
        end

        if self.currentPlayer == "X" then
            love.graphics.setColor(1, 0.4, 0.4)
        else
            love.graphics.setColor(0.4, 0.8, 1)
        end
        love.graphics.print(text, 20, 20)
    end

    -- Reset button
    love.graphics.setColor(0.8, 0.6, 0.2)
    love.graphics.rectangle("line", self.screenWidth - 140, 20, 120, 40, 5)
    love.graphics.setColor(0.8, 0.6, 0.2, 0.3)
    love.graphics.rectangle("fill", self.screenWidth - 140, 20, 120, 40, 5)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.print("Reset", self.screenWidth - 130, 32)

    -- Game mode and board size
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Mode: " .. self.gameMode:upper(), 20, 60)
    love.graphics.print("Board: " .. self.boardSize .. "x" .. self.boardSize, 20, 90)

    love.graphics.print("Press R to reset", 20, self.screenHeight - 40)
    love.graphics.print("Press ESC for menu", 20, self.screenHeight - 70)
end

function Game:drawParticles()
    for _, particle in ipairs(self.cellParticles) do
        local alpha = math_min(1, particle.life * 2)
        love.graphics.setColor(particle.color[1], particle.color[2], particle.color[3], alpha)
        love.graphics.push()
        love.graphics.translate(particle.x, particle.y)
        love.graphics.rotate(particle.rotation)
        love.graphics.scale(particle.size / 10, particle.size / 10)
        love.graphics.print(particle.type, -4, -6)
        love.graphics.pop()
    end
end

function Game:drawGameOver()
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)

    local font = love.graphics.newFont(48)
    love.graphics.setFont(font)

    if self.winner == "Draw" then
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.printf("DRAW!", 0, self.screenHeight / 2 - 80, self.screenWidth, "center")
    else
        if self.winner == "X" then
            love.graphics.setColor(1, 0.4, 0.4)
        else
            love.graphics.setColor(0.4, 0.8, 1)
        end
        love.graphics.printf("PLAYER " .. self.winner .. " WINS!", 0, self.screenHeight / 2 - 80, self.screenWidth,
            "center")
    end

    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click anywhere to continue", 0, self.screenHeight / 2 + 20, self.screenWidth, "center")
end

function Game:isGameOver()
    return self.gameOver
end

return Game
