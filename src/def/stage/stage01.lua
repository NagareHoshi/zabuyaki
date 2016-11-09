-- stage 1
local class = require "lib/middleclass"
local Stage01 = class('Stage01', Stage)

function Stage01:initialize(players)
    Stage.initialize(self, "Stage 01", {231, 207, 157})
    stage = self
    self.scrolling = {commonY = 430, chunksX = {} }
    self.scrolling.chunks = {
--        {startX = 0, endX = 320, startY = 430, endY = 430},
--        {startX = 320, endX = 640, startY = 430, endY = 430-40},
--        {startX = 640, endX = 900, startY = 430-40, endY = 430},
--        {startX = 1400, endX = 1600, startY = 430, endY = 430+20},
--        {startX = 1600, endX = 1800, startY = 430+20, endY = 430+20},
--        {startX = 1800, endX = 2000, startY = 430+20, endY = 430}
    }
    self.objects = Entity:new()

    player1 = nil
    player2 = nil
    player3 = nil

    local top_floor_y = 454

    GLOBAL_UNIT_ID = 1  --recalc players IDs for proper life bar coords
    -- create players
    if players[1] then
        --    player1 = Rick:new("RICK", GetSpriteInstance("src/def/char/rick.lua"), Control1, 190, 180, shader, {255,255,255, 255})
        player1 = players[1].hero:new(players[1].name,
            GetSpriteInstance(players[1].sprite_instance),
            Control1,
            60, top_floor_y + 65,
            players[1].shader,
            {255,255,255, 255})
    end
    GLOBAL_UNIT_ID = 2  --recalc players IDs for proper life bar coords
    if players[2] then
        --     player2 = Chai:new("CHAI", GetSpriteInstance("src/def/char/chai.lua"), Control2, 240, 200, shader )
        player2 = players[2].hero:new(players[2].name,
            GetSpriteInstance(players[2].sprite_instance),
            Control2,
            90, top_floor_y + 35,
            players[2].shader)
        --player2.horizontal = -1
        --player2.face = -1
    end
    GLOBAL_UNIT_ID = 3  --recalc players IDs for proper life bar coords
    if players[3] then
        --        player3 = Kisa:new("KISA", GetSpriteInstance("src/def/char/rick.lua"), Control3, 220, 200-30, shader, {255,255,255, 255})
        player3 = players[3].hero:new(players[3].name,
            GetSpriteInstance(players[3].sprite_instance),
            Control3,
            120, top_floor_y + 5,
            players[3].shader,
            {255,255,255, 255})
    end

    --define sprites
    local bgRoad = love.graphics.newImage("res/img/stages/stage1/road.png")
    local bgBuilding1 = love.graphics.newImage("res/img/stages/stage1/building1.png")
    local bgBuilding2 = love.graphics.newImage("res/img/stages/stage1/building2.png")
    local bgSky = love.graphics.newImage("res/img/stages/stage1/sky.png")

    local qRoad = love.graphics.newQuad(2, 0, 360, 121, bgRoad:getDimensions())
    local qBuilding1 = love.graphics.newQuad(0, 0, 525, 385, bgBuilding1:getDimensions())
    local qBuilding2 = love.graphics.newQuad(0, 0, 525, 385, bgBuilding2:getDimensions())
    local qSky = love.graphics.newQuad(1, 0, 33, 130, bgSky:getDimensions())

    --bg as a big picture
    print(self.name .. " Background", self.worldWidth, self.worldHeight)
    self.background = CompoundPicture:new(self.name .. " Background", self.worldWidth, self.worldHeight)
    --arrange sprites along the big picture

    for i = 0, 33 do
        --(bgSky, qSky, x, y, slow_down_parallaxX, slow_down_parallaxY, auto_scroll_x, scroll_y
        self.background:add(bgSky, qSky, i * 32 - 2 , 302,
            0.75, 0) --keep still vertically despite of the scrolling
    end

    for i = 0, 7 do
        self.background:add(bgRoad, qRoad, i * 360, 432)
    end
    self.background:add(bgBuilding1, qBuilding1, -20 + 0 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding2, qBuilding2, -20 + 1 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding1, qBuilding1, -20 + 2 * (10 + (525 - 90)), 67)
    self.background:add(bgBuilding2, qBuilding2, -20 + 3 * (10 + (525 - 90)), 67)

    -- Walls around the level
--    local wall1 = HC.rectangle(-20, 0, 40, self.worldHeight) --left
--    wall1.obj = {type = "wall", shape = wall1}
--    local wall2 = HC.rectangle(self.worldWidth - 20, 0, 40, self.worldHeight) --right
--    wall2.obj = {type = "wall", shape = wall2}
--    local wall3 = HC.rectangle(0, 420, self.worldWidth, 40) --top
--    wall3.obj = {type = "wall", shape = wall3}
--    local wall4 = HC.rectangle(0, 546, self.worldWidth, 40) --bottom
--    wall4.obj = {type = "wall", shape = wall4 }

    GLOBAL_UNIT_ID = GLOBAL_SETTING.MAX_PLAYERS + 1  --enemy IDs go after the max player ID

    local wall1 = Wall:new("wall1", -20, 0, 40, self.worldHeight) --left
    local wall2 = Wall:new("wall2", self.worldWidth - 20, 0, 40, self.worldHeight) --right
    local wall3 = Wall:new("wall3", 0, 420, self.worldWidth, 40) --top
    local wall4 = Wall:new("wall4", 0, 546, self.worldWidth, 40) --bottom

    local gopper1 = Gopper:new("GOPPER", GetSpriteInstance("src/def/char/gopper.lua"), button3, 500, top_floor_y + 20, shaders.gopper[4], {255,255,255, 255})
    local gopper2 = Gopper:new("GOPPER2", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1510, top_floor_y + 20, shaders.gopper[2], {255,255,255, 255})
    gopper2:setToughness(1)
    local gopper3 = Gopper:new("GOPPER3", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1560, top_floor_y + 40, shaders.gopper[3], {255,255,255, 255})
    gopper3:setToughness(2)
    local gopper4 = Gopper:new("GOPPER4", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1520, top_floor_y + 30, shaders.gopper[4], {255,255,255, 255})
    gopper4:setToughness(3)
    local gopper5 = Gopper:new("GOPPER5", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1540, top_floor_y + 25, nil, {255,255,255, 255})
    gopper5:setToughness(4)
    local gopper6 = Gopper:new("GOPPER6", GetSpriteInstance("src/def/char/gopper.lua"), button3, 1525, top_floor_y + 35, nil, {255,255,255, 255})
    gopper6:setToughness(5)

    local dummy4 = Rick:new("Dummie4", GetSpriteInstance("src/def/char/rick.lua"), button3, 260, top_floor_y + 20, shaders.rick[4], {255,255,255, 255})
    dummy4:setToughness(5)
    dummy4.horizontal = -1
    dummy4.face = -1
    local dummy5 = Chai:new("Dummie5", GetSpriteInstance("src/def/char/chai.lua"), button3, 220, top_floor_y + 20, shaders.chai[3], {255,255,255, 255})
    dummy5:setToughness(5)
    dummy5.horizontal = -1
    dummy5.face = -1

    local niko1 = Niko:new("niko", GetSpriteInstance("src/def/char/niko.lua"), button3, 550 + love.math.random(-20,20), top_floor_y + 0, shaders.niko[2], {255,255,255, 255})
    local niko2 = Niko:new("niko2", GetSpriteInstance("src/def/char/niko.lua"), button3, 1510 + love.math.random(-20,20), top_floor_y + 10, nil, {255,255,255, 255})
    niko2:setToughness(1)
    local niko3 = Niko:new("niko3", GetSpriteInstance("src/def/char/niko.lua"), button3, 1560 + love.math.random(-20,20), top_floor_y + 20, shaders.niko[2], {255,255,255, 255})
    niko3:setToughness(2)
    local niko4 = Niko:new("niko4", GetSpriteInstance("src/def/char/niko.lua"), button3, 1520 + love.math.random(-20,20), top_floor_y + 30, shaders.niko[2], {255,255,255, 255})
    niko4:setToughness(3)
    local niko5 = Niko:new("niko5", GetSpriteInstance("src/def/char/niko.lua"), button3, 1540 + love.math.random(-20,20), top_floor_y + 40, nil, {255,255,255, 255})
    niko5:setToughness(4)
    local niko6 = Niko:new("niko6", GetSpriteInstance("src/def/char/niko.lua"), button3, 1525 + love.math.random(-20,20), top_floor_y + 50, nil, {255,255,255, 255})
    niko6:setToughness(5)

    --Loot:initialize(name, sprite, hp, money, func, x, y, shader, color)
    local loot1 = Loot:new("Apple", "+15 HP", gfx.loot.apple, 15, 0, nil, 130,top_floor_y + 30)
    local loot2 = Loot:new("Chicken", "+50 HP", gfx.loot.chicken, 50, 0, nil, 660,top_floor_y + 50)
    --    loot2 = Loot:new("Custom func sample", "+20 Pts.", gfx.loot.apple, 20, 0, function(s, t) dp(t.name .. " called custom loot ("..s.name..") func") end, 460,180)
    local loot3 = Loot:new("Beef", "+100 HP", gfx.loot.beef, 100, 0, nil, 750,top_floor_y + 40 )

    local temper1 = Temper:new("TEMPER", GetSpriteInstance("src/def/char/rick.lua"), button3, 567, top_floor_y + 40, shaders.rick[5], {255,255,255, 255})
    -- 3 lives: 100hp+100hp+50hp sample
    temper1.max_hp = 100
    temper1.hp = 50
    temper1.infoBar = InfoBar:new(temper1)

    local gop_x = 300
    local new_gopper1 = Gopper:new("N.GOP1", GetSpriteInstance("src/def/char/gopper.lua"), button3, gop_x + 157, top_floor_y + 40, shaders.gopper[2], {255,255,255, 255})
    local new_gopper2 = Gopper:new("N.GOP2", GetSpriteInstance("src/def/char/gopper.lua"), button3, gop_x + 177, top_floor_y + 43, shaders.gopper[1], {255,255,255, 255})
    local new_gopper3 = Gopper:new("N.GOP3", GetSpriteInstance("src/def/char/gopper.lua"), button3, gop_x + 199, top_floor_y + 47, shaders.gopper[3], {255,255,255, 255})
    local new_gopper4 = Gopper:new("N.GOP4", GetSpriteInstance("src/def/char/gopper.lua"), button3, gop_x + 210, top_floor_y + 40, shaders.gopper[4], {255,255,255, 255})
    local new_niko1 = Niko:new("N.NIK1", GetSpriteInstance("src/def/char/niko.lua"), button3, gop_x + 220, top_floor_y + 40, shaders.niko[1], {255,255,255, 255})
    local new_niko2 = Niko:new("N.NIK2", GetSpriteInstance("src/def/char/niko.lua"), button3, gop_x + 240, top_floor_y + 43, shaders.niko[2], {255,255,255, 255})
    local new_niko3 = Niko:new("N.NIK3", GetSpriteInstance("src/def/char/niko.lua"), button3, gop_x + 260, top_floor_y + 47, shaders.niko[1], {255,255,255, 255})
    local new_niko4 = Niko:new("N.NIK4", GetSpriteInstance("src/def/char/niko.lua"), button3, gop_x + 280, top_floor_y + 40, shaders.niko[2], {255,255,255, 255})

    local canColor = {118,109,100, 255}
    local canColor2 = {87, 116, 130, 255}
    local can1 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        76, top_floor_y + 40, {hp = 49, score = 100, shader = nil, color = nil, colorParticle = canColor,
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can2 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        109, top_floor_y + 20, {hp = 49, score = 100, shader = nil, color = nil, colorParticle = canColor,
            isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can3 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        310, top_floor_y + 10, {hp = 49, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
    local can4 = Obstacle:new("TRASH CAN", GetSpriteInstance("src/def/stage/objects/can.lua"),
        320, top_floor_y + 65, {hp = 49, score = 100, shader = shaders.trashcan[2], color = nil, colorParticle = canColor2,
            isMovable = true, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )

    self.objects:addArray({
--        new_gopper1, new_gopper2, new_gopper3, new_gopper4,
        new_niko1, new_niko2, new_niko3, new_niko4,
        gopper1, gopper2, gopper3, gopper4, gopper5, gopper6,
        niko1, niko2, niko3, niko4, niko5, niko6,
        dummy4, dummy5,
        temper1,
        loot1, loot2, loot3,
        can1, can2, can3, can4,
        wall1,wall2,wall3,wall4
    })

    local a, sx  = {}, 0
    for i = 0, 6 do
        a[#a+1] = Obstacle:new("TRASH CAN"..i, GetSpriteInstance("src/def/stage/objects/can.lua"),
            180 + sx , top_floor_y + 11 + i * 13, {hp = 49, score = 100, shader = nil, color = nil, colorParticle = canColor,
                isMovable = false, sfxDead = nil, func = nil, sfxOnHit = "metal_hit", sfxOnBreak = "metal_break", sfxGrab = "metal_grab"} )
        if sx == 0 then
            sx = 6
        else
            sx = 0
        end
    end
    self.objects:addArray(a)

    if player1 then
        self.objects:add(player1)
    end
    if player2 then
        self.objects:add(player2)
    end
    if player3 then
        self.objects:add(player3)
    end

    --adding players into collision world 15x7
    self.objects:addToWorld(self)
end

return Stage01