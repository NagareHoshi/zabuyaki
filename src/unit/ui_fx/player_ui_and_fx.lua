-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Player = Player

-- Start of Lifebar elements
local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Player:drawTextInfo(l, t, transpBg, iconWidth)
    colors:set("white", nil, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    colors:set("playersColors", self.id, transpBg)
    printWithShadow(self.pid, l + self.shake.x + iconWidth + 2, t - 1,
        transpBg)
    colors:set("barNormColor", nil, transpBg)
    printWithShadow(string.format("%06d", self.score), l + self.shake.x + iconWidth + 34, t - 1,
        transpBg)
    if self.lives >= 1 then
        colors:set("white", nil, transpBg)
        printWithShadow("x", l + self.shake.x + iconWidth + 91, t + 9,
            transpBg)
        love.graphics.setFont(gfx.font.arcade3x2)
        if self.lives > 10 then
            printWithShadow("9+", l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        else
            printWithShadow(self.lives - 1, l + self.shake.x + iconWidth + 100, t + 1,
                transpBg)
        end
    end
end

function Player:drawBar(l,t,w,h, iconWidth)
    love.graphics.setFont(gfx.font.arcade3)
    local transpBg = 255 * calcBarTransparency(3)
    local playerSelectMode = self.source.playerSelectMode
    if self.source.lives > 0 then
        -- Default draw
        self:drawLifebar(l, t, transpBg)
        self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
        self:drawDeadCross(l, t, transpBg)
        self.source:drawTextInfo(l + self.x, t + self.y, transpBg, iconWidth)
    else
        colors:set("white", nil, transpBg)
        if playerSelectMode == 0 then
            -- wait press to use credit
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*2 + 17))
            printWithShadow(self.source.pid .. " PRESS ATTACK (".. math.floor(self.source.displayDelay) ..")", l + self.x + 2, t + self.y + 9 + 11,
                transpBg)
        elseif playerSelectMode == 1 then
            -- wait 1 sec before player select
            printWithShadow("CONTINUE x"..tonumber(credits), l + self.x + 2, t + self.y + 9,
                transpBg)
        elseif playerSelectMode == 2 then
            -- Select Player
            printWithShadow(self.source.name, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y + 9,
                transpBg)
            colors:set("playersColors", self.source.id, transpBg)
            printWithShadow(self.source.pid, l + self.x + self.source.shake.x + iconWidth + 2, t + self.y - 1,
                transpBg)
            --printWithShadow("<     " .. self.source.name .. "     >", l + self.x + 2 + math.floor(2 * math.sin(self.timer*4)), t + self.y + 9 + 11 )
            self:drawFaceIcon(l + self.source.shake.x, t, transpBg)
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*3 + 17))
            printWithShadow("SELECT PLAYER (".. math.floor(self.source.displayDelay) ..")", l + self.x + 2, t + self.y + 19,
                transpBg)
        elseif playerSelectMode == 3 then
            -- Spawn selected player
        elseif playerSelectMode == 4 then
            -- Replace this player with the new character
        elseif playerSelectMode == 5 then
            -- Game Over (too late)
            colors:set("white", nil, 200 + 55 * math.sin(self.timer*0.5 + 17))
            printWithShadow(self.source.pid .. " GAME OVER", l + self.x + 2, t + self.y + 9,
                transpBg)
        end
    end
end
-- End of Lifebar elements
