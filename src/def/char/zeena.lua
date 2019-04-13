local spriteSheet = "res/img/char/zeena.png"
local imageWidth, imageHeight = loadSpriteSheet(spriteSheet)

local function q(x,y,w,h)
    return love.graphics.newQuad(x, y, w, h, imageWidth, imageHeight)
end
local jumpAttack = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, y = 17, width = 25, height = 45, damage = 13, type = "knockDown", repel_x = slf.dashFallSpeed },
        cont
) end
local comboSlap = function(slf, cont)
    slf:checkAndAttack(
        { x = 25, y = 32, width = 26, damage = 5, sfx = "air" },
        cont
    )
end
local comboKick = function(slf, cont)
    slf:checkAndAttack(
        { x = 21, y = 10, width = 25, damage = 8, type = "knockDown", repel_x = slf.dashFallSpeed, sfx = (slf.sprite.elapsedTime <= 0) and "air" },
        cont
    )
    -- move Zeena forward
    if slf.sprite.elapsedTime <= 0 then
        slf:initSlide(slf.slideSpeed_x, slf.slideDiagonalSpeed_x, slf.slideDiagonalSpeed_y, slf.slideSpeed_x * 2.5)
    end
end

return {
    serializationVersion = 0.42, -- The version of this serialization process

    spriteSheet = spriteSheet, -- The path to the spritesheet
    spriteName = "zeena", -- The name of the sprite

    delay = 0.2,	--default delay for all animations

    --The list with all the frames mapped to their respective animations
    --  each one can be accessed like this:
    --  mySprite.animations["idle"][1], or even
    animations = {
        icon = {
            { q = q(45, 74, 33, 17) }
        },
        intro = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 5
        },
        stand = {
            { q = q(2,2,39,59), ox = 22, oy = 58 }, --stand 1
            { q = q(43,3,40,58), ox = 23, oy = 57, delay = 0.18 }, --stand 2
            { q = q(85,4,40,57), ox = 23, oy = 56 }, --stand 3
            { q = q(43,3,40,58), ox = 23, oy = 57, delay = 0.16 }, --stand 2
            loop = true,
            delay = 0.2
        },
        walk = {
            { q = q(2,63,39,58), ox = 22, oy = 58, delay = 0.16 }, --walk 1
            { q = q(43,64,40,58), ox = 23, oy = 57 }, --walk 2
            { q = q(85,63,40,59), ox = 23, oy = 58, delay = 0.16 }, --walk 3
            { q = q(43,3,40,58), ox = 23, oy = 57 }, --stand 2
            loop = true,
            delay = 0.2
        },
        duck = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.06
        },
        sideStepUp = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        sideStepDown = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
        },
        jump = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            delay = 5
        },
        jumpAttackStraight = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 61, funcCont = jumpAttack, delay = 5 }, --jump attack 2
            delay = 0.06
        },
        jumpAttackStraightEnd = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            delay = 5
        },
        jumpAttackForward = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 61, funcCont = jumpAttack, delay = 5 }, --jump attack 2
            delay = 0.06
        },
        jumpAttackForwardEnd = {
            { q = q(42,297,43,57), ox = 25, oy = 61 }, --jump attack 1
            delay = 5
        },
        dropDown = {
            { q = q(2,297,38,61), ox = 22, oy = 60 }, --jump
            delay = 5
        },
        respawn = {
            { q = q(2,297,38,61), ox = 22, oy = 60, delay = 5 }, --jump
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.6
        },
        pickUp = {
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.28
        },
        combo1 = {
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo2 = {
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            delay = 0.067
        },
        combo3 = {
            { q = q(116,360,40,58), ox = 20, oy = 57 }, --slap 3
            { q = q(59,360,55,58), ox = 17, oy = 57, func = comboSlap }, --slap 2
            { q = q(2,360,55,58), ox = 35, oy = 57 }, --slap 1
            delay = 0.067
        },
        combo4 = {
            { q = q(42,297,43,57), ox = 25, oy = 56 }, --jump attack 1
            { q = q(87,297,66,53), ox = 32, oy = 52, funcCont = comboKick, delay = 0.167 }, --jump attack 2
            { q = q(42,297,43,57), ox = 25, oy = 56, delay = 0.117 }, --jump attack 1
            delay = 0.067
        },
        hurtHighWeak = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.2 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighMedium = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.33 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtHighStrong = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58, delay = 0.47 }, --hurt high 2
            { q = q(2,124,43,60), ox = 25, oy = 59, delay = 0.05 }, --hurt high 1
            delay = 0.02
        },
        hurtLowWeak = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.2 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowMedium = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.33 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        hurtLowStrong = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55, delay = 0.47 }, --hurt low 2
            { q = q(2,186,36,58), ox = 21, oy = 57, delay = 0.05 }, --hurt low 1
            delay = 0.02
        },
        fall = {
            { q = q(2,246,65,49), ox = 39, oy = 48 }, --fall
            delay = 5
        },
        fallBounce = {
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --fallen
            delay = 65
        },
        fallen = {
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --fallen
            delay = 65
        },
        fallenDead = {
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --fallen
            delay = 65
        },
        getUp = {
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --fallen
            { q = q(138,249,53,46), ox = 30, oy = 45 }, --get up
            { q = q(81,193,40,51), ox = 22, oy = 50 }, --duck
            delay = 0.2
        },
        grabbedFront = {
            { q = q(2,124,43,60), ox = 25, oy = 59 }, --hurt high 1
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            delay = 0.02
        },
        grabbedBack = {
            { q = q(2,186,36,58), ox = 21, oy = 57 }, --hurt low 1
            { q = q(40,188,39,56), ox = 21, oy = 55 }, --hurt low 2
            delay = 0.02
        },
        grabbedFrames = {
            --default order should be kept: hurtLow2, hurtHigh2, \, /, upsideDown, fallen
            { q = q(40,188,39,56), ox = 21, oy = 55 }, --hurt low 2
            { q = q(47,125,48,59), ox = 29, oy = 58 }, --hurt high 2
            { q = q(2,246,65,49), ox = 39, oy = 48 }, --fall
            { q = q(2,246,65,49), ox = 42, oy = 45, rotate = -1.57, rx = 32, ry = -48 }, --fall
            { q = q(40,188,39,56), ox = 21, oy = 55, flipV = -1 }, --hurt low 2
            { q = q(69,267,67,28), ox = 41, oy = 27 }, --fallen
            delay = 100
        },
        thrown = {
            --rx = oy / 2, ry = -ox for this rotation
            { q = q(2,246,65,49), ox = 39, oy = 48, rotate = -1.57, rx = 29, ry = -30 }, --fall
            delay = 5
        },
    }
}
