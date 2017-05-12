local class = require "lib/middleclass"
local Sveta = class('Sveta', Gopper)

local function nop() end
local sign = sign
local clamp = clamp
local dist = dist
local rand1 = rand1
local CheckCollision = CheckCollision

function Sveta:initialize(name, sprite, input, x, y, f)
    self.hp = self.hp or 60
    self.score_bonus = self.score_bonus or 350
    self.tx, self.ty = x, y
    Gopper.initialize(self, name, sprite, input, x, y, f)
    self.subtype = "gopnitsa"
    self.whichPlayerAttack = "weak" -- random far close weak healthy fast slow
    self.sfx.dead = sfx.sveta_death
    self.sfx.dash_attack = sfx.sveta_attack
    self.sfx.step = "kisa_step"
    self:setState(self.intro)
end

Sveta.onFriendlyAttack = Enemy.onFriendlyAttack

function Sveta:updateAI(dt)
    Enemy.updateAI(self, dt)

    self.cool_down = self.cool_down - dt --when <=0 u can move

    --local complete_movement = self.move:update(dt)
    self.ai_poll_1 = self.ai_poll_1 - dt
    self.ai_poll_2 = self.ai_poll_2 - dt
    self.ai_poll_3 = self.ai_poll_3 - dt
    if self.ai_poll_1 < 0 then
        self.ai_poll_1 = self.max_ai_poll_1 + math.random()
        -- Intro -> Stand
        if self.state == "intro" then
            -- see near players?
            local dist = self:getDistanceToClosestPlayer()
            if dist < self.wakeup_range
                    or (dist < self.delayed_wakeup_range and self.time > self.wakeup_delay )
            then
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                self.face = -self.target.face --face to player
                self:setState(self.stand)
            end
        elseif self.state == "stand" then
            if self.cool_down <= 0 then
                --can move
                if not self.target then
                    self:pickAttackTarget()
                    if not self.target then
                        self:setState(self.intro)
                        return
                    end
                end
                --local t = dist(self.target.x, self.target.y, self.x, self.y)
--                if t < 400 and t >= 100 and
--                        math.floor(self.y / 4) == math.floor(self.target.y / 4) then
--                    self:setState(self.run)
--                    return
--                end
                --if t < 300 then
                    self:setState(self.walk)
                 --   return
                --end
            end
        elseif self.state == "walk" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
            if not self.target then
                self:pickAttackTarget()
                if not self.target then
                    self:setState(self.intro)
                    return
                end
            end
            local t = dist(self.target.x, self.target.y, self.x, self.y)
            if t < 100 and t >= 30
                    and math.floor(self.y / 4) == math.floor(self.target.y / 4)
            then
                if math.random() < 0.5 then
                    self:faceToTarget()
                end
                self:setState(self.dashAttack)
                return
            end
            if self.cool_down <= 0 then
                if math.abs(self.x - self.target.x) <= 50
                        and math.abs(self.y - self.target.y) <= 6
                then
                    self:setState(self.combo)
                    return
                end
            end
        elseif self.state == "run" then
            --self:pickAttackTarget()
            --self:setState(self.stand)
            --return
        end
        -- Facing towards the target
        self:faceToTarget()
    end
    if self.ai_poll_2 < 0 then
        self.ai_poll_2 = self.max_ai_poll_2 + math.random()
    end
    if self.ai_poll_3 < 0 then
        self.ai_poll_3 = self.max_ai_poll_3 + math.random()

        if self.state == "walk" then
        elseif self.state == "run" then
        end

        self:pickAttackTarget()

--        local t = dist(self.target.x, self.target.y, self.x, self.y)
--        if t < 600 and self.state == "walk" then
--            --set dest
--        end
    end
end

function Sveta:dashAttack_start()
    self.isHittable = true
    self:remove_tween_move()
    dpo(self, self.state)
    self.cool_down = 0.25
    self:setSprite("duck")
    self.vely = 0
    self.velz = 0
    local psystem = PA_DASH:clone()
    psystem:setSpin(0, -3 * self.face)
    self.pa_dash = psystem
    self.pa_dash_x = self.x
    self.pa_dash_y = self.y
    stage.objects:add(Effect:new(psystem, self.x, self.y + 2))
end

function Sveta:dashAttack_update(dt)
    self.cool_down = self.cool_down - dt
    if self.sprite.cur_anim == "duck" and self.cool_down <= 0 then
        self.isHittable = false
        self:setSprite("dashAttack")
        self.velx = self.velocity_dash
        sfx.play("voice"..self.id, self.sfx.dash_attack)
        return
    else
        if self.sprite.cur_anim == "dashAttack" and self.sprite.isFinished then
            self:setState(self.stand)
            return
        end
        if math.random() < 0.2 and self.velx >= self.velocity_dash * 0.5 then
            self.pa_dash:moveTo( self.x - self.pa_dash_x - self.face * 10, self.y - self.pa_dash_y - 5 )
            self.pa_dash:emit(1)
        end
    end
    self:calcMovement(dt, true, self.friction_dash)
end

Sveta.dashAttack = { name = "dashAttack", start = Sveta.dashAttack_start, exit = nop, update = Sveta.dashAttack_update, draw = Character.default_draw }

return Sveta