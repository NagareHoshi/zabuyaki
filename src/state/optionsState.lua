optionsState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menu_yOffset = 80 -- menuItem_h
local menu_xOffset = 0
local hint_yOffset = 80
local title_yOffset = 24
local leftItemOffset  = 6
local topItemOffset  = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "OPTIONS" )
local txtItems = {"DIFFICULTY", "VIDEO", "SOUND", "DEFAULTS", "SPRITE EDITOR", "LOCKED", "BACK"}

local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, old_mouse_y = 0, 0, 0

function optionsState:enter()
    mouse_x, mouse_y = 0,0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth( 2 )
    self:wheelmoved(0, 0)   --pick 1st sprite to draw
end

function optionsState:resume()
    mouse_x, mouse_y = 0,0
end

--Only P1 can use menu / options
function optionsState:player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1)then
        self:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1)then
        self:wheelmoved(0, 1)
    elseif controls.vertical:pressed(-1) then
        menuState = menuState - 1
    elseif controls.vertical:pressed(1) then
        menuState = menuState + 1
    end
    if menuState < 1 then
        menuState = #menu
    end
    if menuState > #menu then
        menuState = 1
    end
end

function optionsState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx","menuMove")
        oldMenuState = menuState
    end
    self:player_input(Control1)
end

function optionsState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == 1 then
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                m.item = "DIFFICULTY NORMAL"
            else
                m.item = "DIFFICULTY HARD"
            end
            m.hint = ""
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin )
        then
            old_mouse_y = mouse_y
            menuState = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_options_logo, (screenWidth - txt_options_logo:getWidth()) / 2, title_yOffset)
    showDebug_indicator()
    push:finish()
end

function optionsState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menuState == 1 then
            sfx.play("sfx","menuSelect")
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                configuration:set("DIFFICULTY", 2)
            else
                configuration:set("DIFFICULTY", 1)
            end
            configuration:save(true)
        elseif menuState == 2 then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(videoModeState)

        elseif menuState == 3 then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(soundState)

        elseif menuState == 4 then
            sfx.play("sfx","menuSelect")
            configuration:reset()
            configuration:save(true)
            TEsound.stop("music")
            TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
            TEsound.playLooping(bgm.title, "music")

        elseif menuState == 5 then
            sfx.play("sfx","menuSelect")
            return Gamestate.push(spriteSelectState)

        elseif menuState == #menu then
            sfx.play("sfx","menuCancel")
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx","menuCancel")
        return Gamestate.pop()
    end
end

function optionsState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm( x, y, button, istouch )
end

function optionsState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function optionsState:wheelmoved(x, y)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    else
        return
    end
    menu[menuState].n = menu[menuState].n + i
    if menuState == 1 then
        return self:confirm( mouse_x, mouse_y, 1)
    end
    if menuState ~= #menu then
        sfx.play("sfx","menuMove")
    end
end