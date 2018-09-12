-- Copyright (c) .2017 SineDie
-- Visuals and SFX go here

local Enemy = Enemy

local iconWidth = 40
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1

local printWithShadow = printWithShadow
local calcBarTransparency = calcBarTransparency
function Enemy:drawTextInfo(l, t, transpBg, normColor)
    colors:set("white", nil, transpBg)
    printWithShadow(self.name, l + self.shake.x + iconWidth + 2, t + 9,
        transpBg)
    if self.lives > 1 then
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
