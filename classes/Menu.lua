-- Tic-Tac-Toe Game - Love2D
-- License: MIT
-- Copyright (c) 2025 Jericho Crosby (Chalwk)

local ipairs = ipairs
local math_sin = math.sin

local helpText = {
    "Tic-Tac-Toe with advanced boards!",
    "",
    "How to Play:",
    "• Click on empty cells to place your mark",
    "• Get " .. (menu and menu.boardSize or 3) .. " in a row to win",
    "• Rows, columns, and diagonals count",
    "",
    "Game Modes:",
    "• PvP: Two players on same device",
    "• AI: Play against computer",
    "",
    "Board Sizes:",
    "• 3x3: Classic Tic-Tac-Toe",
    "• 4x4: More strategic gameplay",
    "• 5x5: Advanced challenge",
    "",
    "Click anywhere to close"
}

local Menu = {}
Menu.__index = Menu

function Menu.new()
    local instance = setmetatable({}, Menu)

    instance.screenWidth = 800
    instance.screenHeight = 600
    instance.boardSize = 3
    instance.gameMode = "pvp"
    instance.title = {
        text = "TIC-TAC-TOE",
        scale = 1,
        scaleDirection = 1,
        scaleSpeed = 0.3,
        minScale = 0.95,
        maxScale = 1.05,
        rotation = 0,
        rotationSpeed = 0.2
    }
    instance.showHelp = false

    instance.smallFont = love.graphics.newFont(16)
    instance.mediumFont = love.graphics.newFont(22)
    instance.largeFont = love.graphics.newFont(42)
    instance.sectionFont = love.graphics.newFont(18)

    instance:createMenuButtons()
    instance:createOptionsButtons()

    return instance
end

function Menu:setScreenSize(width, height)
    self.screenWidth = width
    self.screenHeight = height
    self:updateButtonPositions()
    self:updateOptionsButtonPositions()
end

function Menu:createMenuButtons()
    self.menuButtons = {
        {
            text = "Start Game",
            action = "start",
            width = 200,
            height = 45,
            x = 0,
            y = 0
        },
        {
            text = "Options",
            action = "options",
            width = 200,
            height = 45,
            x = 0,
            y = 0
        },
        {
            text = "Quit",
            action = "quit",
            width = 200,
            height = 45,
            x = 0,
            y = 0
        }
    }

    -- Help button (question mark)
    self.helpButton = {
        text = "?",
        action = "help",
        width = 40,
        height = 40,
        x = 30,
        y = self.screenHeight - 50
    }

    self:updateButtonPositions()
end

function Menu:createOptionsButtons()
    self.optionsButtons = {
        -- Board Size Section
        {
            text = "3x3",
            action = "size 3",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },
        {
            text = "4x4",
            action = "size 4",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },
        {
            text = "5x5",
            action = "size 5",
            width = 80,
            height = 35,
            x = 0,
            y = 0,
            section = "size"
        },

        -- Game Mode Section
        {
            text = "PvP",
            action = "mode pvp",
            width = 100,
            height = 35,
            x = 0,
            y = 0,
            section = "mode"
        },
        {
            text = "AI",
            action = "mode ai",
            width = 100,
            height = 35,
            x = 0,
            y = 0,
            section = "mode"
        },

        -- Navigation
        {
            text = "Back to Menu",
            action = "back",
            width = 160,
            height = 40,
            x = 0,
            y = 0,
            section = "navigation"
        }
    }
    self:updateOptionsButtonPositions()
end

function Menu:updateButtonPositions()
    local startY = self.screenHeight / 2
    for i, button in ipairs(self.menuButtons) do
        button.x = (self.screenWidth - button.width) / 2
        button.y = startY + (i - 1) * 60
    end

    -- Update help button position
    self.helpButton.y = self.screenHeight - 50
end

function Menu:updateOptionsButtonPositions()
    local centerX = self.screenWidth / 2
    local totalSectionsHeight = 200
    local startY = (self.screenHeight - totalSectionsHeight) / 2

    -- Size buttons
    local sizeButtonW, sizeButtonH, sizeSpacing = 80, 35, 15
    local sizeTotalW = 3 * sizeButtonW + 2 * sizeSpacing
    local sizeStartX = centerX - sizeTotalW / 2
    local sizeY = startY + 30

    -- Mode buttons
    local modeButtonW, modeButtonH, modeSpacing = 100, 35, 20
    local modeTotalW = 2 * modeButtonW + modeSpacing
    local modeStartX = centerX - modeTotalW / 2
    local modeY = startY + 100

    -- Navigation
    local navY = startY + 170

    local sizeIndex, modeIndex = 0, 0
    for _, button in ipairs(self.optionsButtons) do
        if button.section == "size" then
            button.x = sizeStartX + sizeIndex * (sizeButtonW + sizeSpacing)
            button.y = sizeY
            sizeIndex = sizeIndex + 1
        elseif button.section == "mode" then
            button.x = modeStartX + modeIndex * (modeButtonW + modeSpacing)
            button.y = modeY
            modeIndex = modeIndex + 1
        elseif button.section == "navigation" then
            button.x = centerX - button.width / 2
            button.y = navY
        end
    end
end

function Menu:update(dt, screenWidth, screenHeight)
    if screenWidth ~= self.screenWidth or screenHeight ~= self.screenHeight then
        self.screenWidth = screenWidth
        self.screenHeight = screenHeight
        self:updateButtonPositions()
        self:updateOptionsButtonPositions()
    end

    -- Update title animation
    self.title.scale = self.title.scale + self.title.scaleDirection * self.title.scaleSpeed * dt

    if self.title.scale > self.title.maxScale then
        self.title.scale = self.title.maxScale
        self.title.scaleDirection = -1
    elseif self.title.scale < self.title.minScale then
        self.title.scale = self.title.minScale
        self.title.scaleDirection = 1
    end

    self.title.rotation = self.title.rotation + self.title.rotationSpeed * dt
end

function Menu:draw(screenWidth, screenHeight, state)
    -- Draw animated title
    love.graphics.setColor(0.4, 0.8, 1)
    love.graphics.setFont(self.largeFont)

    love.graphics.push()
    love.graphics.translate(screenWidth / 2, screenHeight / 6)
    love.graphics.rotate(math_sin(self.title.rotation) * 0.05)
    love.graphics.scale(self.title.scale, self.title.scale)
    love.graphics.printf(self.title.text, -screenWidth / 2, -self.largeFont:getHeight() / 2, screenWidth, "center")
    love.graphics.pop()

    if state == "menu" then
        if self.showHelp then
            self:drawHelpOverlay(screenWidth, screenHeight)
        else
            self:drawMenuButtons()
            -- Draw instructions
            love.graphics.setColor(0.9, 0.9, 0.9)
            love.graphics.setFont(self.smallFont)
            love.graphics.printf("Classic Tic-Tac-Toe with advanced boards!\nClick cells to place X or O.",
                0, screenHeight / 4 + 50, screenWidth, "center")

            -- Draw help button
            self:drawHelpButton()
        end
    elseif state == "options" then
        self:drawOptionsInterface()
    end

    -- Draw copyright
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setFont(self.smallFont)
    love.graphics.printf("© 2025 Jericho Crosby – Tic-Tac-Toe", 10, screenHeight - 25, screenWidth - 20, "right")
end

function Menu:drawHelpButton()
    local button = self.helpButton

    -- Button background
    love.graphics.setColor(0.3, 0.5, 0.8, 0.8)
    love.graphics.circle("fill", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Button border
    love.graphics.setColor(0.6, 0.7, 1)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", button.x + button.width / 2, button.y + button.height / 2, button.width / 2)

    -- Question mark
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    love.graphics.print(button.text,
        button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    love.graphics.setLineWidth(1)
end

function Menu:drawHelpOverlay(screenWidth, screenHeight)
    -- Update help text with current board size
    helpText[5] = "• Get " .. self.boardSize .. " in a row to win"

    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Help box
    local boxWidth = 600
    local boxHeight = 500
    local boxX = (screenWidth - boxWidth) / 2
    local boxY = (screenHeight - boxHeight) / 2

    -- Box background
    love.graphics.setColor(0.1, 0.1, 0.2, 0.95)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10)

    -- Box border
    love.graphics.setColor(0.3, 0.5, 0.8)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10)

    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.largeFont)
    love.graphics.printf("How to Play", boxX, boxY + 20, boxWidth, "center")

    -- Help text
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(self.smallFont)

    local lineHeight = 22
    for i, line in ipairs(helpText) do
        local y = boxY + 80 + (i - 1) * lineHeight
        love.graphics.printf(line, boxX + 30, y, boxWidth - 60, "left")
    end

    love.graphics.setLineWidth(1)
end

function Menu:drawOptionsInterface()
    local totalSectionsHeight = 200
    local startY = (self.screenHeight - totalSectionsHeight) / 2

    -- Draw section headers
    love.graphics.setFont(self.sectionFont)
    love.graphics.setColor(0.8, 0.8, 1)
    love.graphics.printf("Board Size", 0, startY + 5, self.screenWidth, "center")
    love.graphics.printf("Game Mode", 0, startY + 75, self.screenWidth, "center")

    self:updateOptionsButtonPositions()
    self:drawOptionSection("size")
    self:drawOptionSection("mode")
    self:drawOptionSection("navigation")
end

function Menu:drawOptionSection(section)
    for _, button in ipairs(self.optionsButtons) do
        if button.section == section then
            self:drawButton(button)

            -- Draw selection highlight
            if button.action:sub(1, 4) == "size" then
                local size = tonumber(button.action:sub(6))
                if size == self.boardSize then
                    love.graphics.setColor(0.2, 0.8, 0.2, 0.4)
                    love.graphics.rectangle("fill", button.x - 3, button.y - 3, button.width + 6, button.height + 6, 5)
                end
            elseif button.action:sub(1, 4) == "mode" then
                local mode = button.action:sub(6)
                if mode == self.gameMode then
                    love.graphics.setColor(0.2, 0.8, 0.2, 0.4)
                    love.graphics.rectangle("fill", button.x - 3, button.y - 3, button.width + 6, button.height + 6, 5)
                end
            end
        end
    end
end

function Menu:drawMenuButtons()
    for _, button in ipairs(self.menuButtons) do
        self:drawButton(button)
    end
end

function Menu:drawButton(button)
    love.graphics.setColor(0.25, 0.25, 0.4, 0.9)
    love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8, 8)

    love.graphics.setColor(0.6, 0.6, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8, 8)

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.mediumFont)
    local textWidth = self.mediumFont:getWidth(button.text)
    local textHeight = self.mediumFont:getHeight()
    love.graphics.print(button.text, button.x + (button.width - textWidth) / 2,
        button.y + (button.height - textHeight) / 2)

    love.graphics.setLineWidth(1)
end

function Menu:handleClick(x, y, state)
    local buttons = state == "menu" and self.menuButtons or self.optionsButtons

    for _, button in ipairs(buttons) do
        if x >= button.x and x <= button.x + button.width and
            y >= button.y and y <= button.y + button.height then
            return button.action
        end
    end

    -- Check help button in menu state
    if state == "menu" then
        if self.helpButton and x >= self.helpButton.x and x <= self.helpButton.x + self.helpButton.width and
            y >= self.helpButton.y and y <= self.helpButton.y + self.helpButton.height then
            self.showHelp = true
            return "help"
        end

        -- If help is showing, any click closes it
        if self.showHelp then
            self.showHelp = false
            return "help_close"
        end
    end

    return nil
end

function Menu:setBoardSize(size)
    self.boardSize = size
end

function Menu:getBoardSize()
    return self.boardSize
end

function Menu:setGameMode(mode)
    self.gameMode = mode
end

function Menu:getGameMode()
    return self.gameMode
end

return Menu
