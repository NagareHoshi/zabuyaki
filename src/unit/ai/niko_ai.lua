-- Copyright (c) .2017 SineDie
-- Niko's AI

local class = require "lib/middleclass"
local eAI = class('eAI', AI)

local _speedReaction = {
    thinkIntervalMin = 0.02,
    thinkIntervalMax = 0.25,
    hesitateMin = 0.1,
    hesitateMax = 0.3,
    waitChance = 0.5,
    jumpAttackChance = 0.5,
    grabChance = 0.5 -- 1 == 100%, 0 == 0%
}

function eAI:initialize(unit, speedReaction)
    AI.initialize(self, unit, speedReaction or _speedReaction)
    -- new or overridden AI schedules
    self.SCHEDULE_JUMP_ATTACK = Schedule:new({ self.initJumpAttack, self.onJumpAttack, self.waitUntilStand },
        { "cannotAct", "inAir", "grabbed", "noTarget", "noPlayers" },
        unit.name)
end

function eAI:_update(dt)
    --    if self.thinkInterval - dt <= 0 then
    --print(inspect(self.conditions, {depth = 1, newline ="", ident=""}))
    --    end
    AI.update(self, dt)
end

function eAI:selectNewSchedule(conditions)
    if not self.currentSchedule or conditions.init then
        --        print("NIKO INTRO", self.unit.name, self.unit.id )
        self.currentSchedule = self.SCHEDULE_INTRO
        return
    end
    if conditions.noPlayers then
        self.currentSchedule = self.SCHEDULE_WALK_OFF_THE_SCREEN
        return
    end
    if not conditions.cannotAct then
        if conditions.faceNotToPlayer then
            self.currentSchedule = self.SCHEDULE_FACE_TO_PLAYER
            return
        end
        if self.currentSchedule ~= self.SCHEDULE_WAIT and love.math.random() < self.waitChance then
            self.currentSchedule = self.SCHEDULE_WAIT
            return
        end
        if conditions.canJumpAttack and love.math.random() < self.jumpAttackChance then
            self.currentSchedule = self.SCHEDULE_JUMP_ATTACK
            return
        end
        if conditions.canCombo then
            if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
                self.currentSchedule = self.SCHEDULE_BACKOFF
                return
            end
            self.currentSchedule = self.SCHEDULE_COMBO
            return
        end
        if conditions.canMove and conditions.canGrab then
            if love.math.random() < self.grabChance then
                self.currentSchedule = self.SCHEDULE_GRAB
            else
                self.currentSchedule = self.SCHEDULE_BACKOFF
            end
            return
        end
        if conditions.canMove and conditions.tooCloseToPlayer then --and love.math.random() < 0.5
            self.currentSchedule = self.SCHEDULE_BACKOFF
            return
        end
        if conditions.canMove and (conditions.seePlayer or conditions.wokeUp) or not conditions.noTarget then
            if love.math.random() < self.grabChance then
                self.currentSchedule = self.SCHEDULE_WALK_TO_GRAB
            else
                if love.math.random() < 0.5 then
                    self.currentSchedule = self.SCHEDULE_CHASE
                else
                    self.currentSchedule = self.SCHEDULE_CHASE2
                end
            end
            return
        end
        if not conditions.dead and not conditions.cannotAct
                and (conditions.wokeUp or conditions.seePlayer) then
            if self.currentSchedule ~= self.SCHEDULE_STAND then
                self.currentSchedule = self.SCHEDULE_STAND
            else
                self.currentSchedule = self.SCHEDULE_WAIT
            end
            return
        end
    else
        -- cannot control body
        self.currentSchedule = self.SCHEDULE_RECOVER
        return
    end
    self.currentSchedule = self.SCHEDULE_STAND
end

function eAI:initJumpAttack(dt)
    --    dp("AI:onDash() ".. self.unit.name)
    local u = self.unit
    self.doneAttack = false
    if self:canActAndMove() and ( u.state == "stand" or u.state == "walk" ) then
        u.horizontal = u.face
        u.z = u.z + 1
        u.bounced = 0
        if self.conditions.tooCloseToPlayer then
            u.speed_x = 0
        else
            u.speed_x = u.walkSpeed_x
        end
        u:setState(u.jump)
    end
    return true
end

function eAI:onJumpAttack(dt)
    --    dp("AI:onDash() ".. self.unit.name)
    local u = self.unit
    if not self.doneAttack then
        self.doneAttack = true
        if u.state == "jump" and self:canAct() then
            u:setState(u.jumpAttackForward)
        end
        return true
    end
    return false
end

return eAI
