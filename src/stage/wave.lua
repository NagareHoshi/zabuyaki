-- enemy wave / spawning que

local class = require "lib/middleclass"
local Wave = class('Wave')

function Wave:ps(t)
    dp("WAVE #"..self.n.." State:"..self.state.." "..(t or ""))
end

function Wave:initialize(stage, waves)
    self.stage = stage
    self.n = 0 -- to get 1st wave
    self.waves = waves
    dp("Stage has #",#waves,"waves of enemy")
    self.startTimer = false
    self.state = "next"
end

function Wave:load()
    local n = self.n
    if n > #self.waves then
        return false
    end
    dp("load Wave #",n)
    local b = self.waves[n]
    self.leftStopper_x = b.leftStopper_x or 0
    self.rightStopper_x = b.rightStopper_x or 320
    for i = 1, #b.units do
        local u = b.units[i]
        u.isSpawned = false
    end
    self.startTimer = false
    Event.startByName(_, b.onStart)
    return true
end

function Wave:startPlayingMusic(n)
    local b = self.waves[n or self.n]
    if b.music and previousStageMusic ~= b.music then
        TEsound.stop("music")
        TEsound.playLooping(bgm[b.music], "music")
        previousStageMusic = b.music
    end
end

function Wave:spawn(dt)
    local b = self.waves[self.n]
    local center_x, playerGroupDistance, min_x, max_x = self.stage.center_x, self.stage.playerGroupDistance, self.stage.min_x, self.stage.max_x
    local lx, rx = self.stage.leftStopper:getX(), self.stage.rightStopper:getX()    --current in the stage
    if lx < self.leftStopper_x
        and min_x > self.leftStopper_x + 320
    then
        lx = self.leftStopper_x
    end
    if rx < self.rightStopper_x then
        rx = rx + dt * 300 -- speed of the right Stopper movement > char's run
    end
    if lx ~= self.stage.leftStopper:getX() or rx ~= self.stage.rightStopper:getX() then
        self.stage:moveStoppers(lx, rx)
    end
    if max_x < self.leftStopper_x - 320 / 2 and not self.startTimer then
        return false  -- the left stopper's x is out of the current screen
    end
    self.startTimer = true
    self.time = self.time + dt
    if self.n > 1 then
        local bPrev = self.waves[self.n - 1]
        if not bPrev.onLeaveStarted and min_x > bPrev.rightStopper_x then -- Last player passed the left bound of the wave
            Event.startByName(_, bPrev.onLeave)
            bPrev.onLeaveStarted = true
        end
    end
    if not b.onEnterStarted and max_x > b.leftStopper_x then -- The first player passed the left bound of the wave
        Event.startByName(_, b.onEnter)
        b.onEnterStarted = true
        self:startPlayingMusic()
    end
    if self.time < b.spawnDelay then -- delay before the spawn of whole wave
        return false
    end
    local allSpawned = true
    local allDead = true
    for i = 1, #b.units do
        local waveUnit = b.units[i]
        if not waveUnit.isSpawned then
            if self.time - b.spawnDelay >= waveUnit.spawnDelay then -- delay before the unit's spawn
                dp("spawn ", waveUnit.unit.name, waveUnit.unit.type, waveUnit.unit.hp, self.time)
                waveUnit.unit:setOnStage(stage)
                waveUnit.isSpawned = true
                if waveUnit.state == "intro" then  -- idling, show intro animation by default
                    waveUnit.unit:setState(waveUnit.unit.intro)
                    waveUnit.unit:setSprite("intro")
                end
                if waveUnit.target then    -- pick the target to attack on spawn
                    waveUnit.unit:pickAttackTarget(waveUnit.target) --"close" "far" "weak" "healthy" "slow" "fast"
                end
                if waveUnit.animation then    -- set the custom sprite animation
                    waveUnit.unit:setSprite(waveUnit.animation)
                end
            end
            allSpawned = false
            allDead = false --not yet spawned = alive
        end
        if not waveUnit.isActive and b.onEnterStarted then
            waveUnit.isActive = true -- the wave unit spawn data
            waveUnit.unit.isActive = true -- actual spawned enemy unit
            dp("Activate enemy:", waveUnit.unit.name)
        end
        if not waveUnit.unit.isDisabled and waveUnit.unit.type == "enemy" then --alive enemy
            allDead = false
        end
    end
    if allSpawned then
    end
    if allDead then
        self.state = "next"
        Event.startByName(_, b.onComplete)
    end
    return true
end

function Wave:isDone()
    return self.state == "finish" and self.time > 0.1
end

function Wave:finish()
    self.state = "finish"
    self.time = 0
end

function Wave:killCurrentWave()
    local b = self.waves[self.n]
    for i = 1, #b.units do
        local waveUnit = b.units[i]
        waveUnit.isActive = true -- the wave unit spawn data
        waveUnit.unit.isActive = true -- actual spawned enemy unit
        waveUnit.unit:applyDamage(1000, "fell")
    end
end

function Wave:update(dt)
    if self.state == "spawn" then
        return not self:spawn(dt)
    elseif self.state == "next" then
        self.n = self.n + 1
        self.time = 0
        if self:load() then
            local b = self.waves[self.n]
            self.state = "spawn"
        else
            self.state = "done"
        end
        self:ps()
        return false
    elseif self.state == "done" then    -- the latest's wave enemies are dead ('nextmap' is not called yet)
        self.time = self.time + dt
        return false
    elseif self.state == "finish" then  -- 'nextmap' event is called
        self.time = self.time + dt
        return false
    end
end

return Wave
