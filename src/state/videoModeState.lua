videoModeState = {}

local time = 0
local screenWidth = 640
local screenHeight = 480
local menuItem_h = 40
local menuOffset_y = 80 -- menuItem_h
local menuOffset_x = 0
local hintOffset_y = 80
local titleOffset_y = 24
local leftItemOffset = 6
local topItemOffset = 6
local itemWidthMargin = leftItemOffset * 2
local itemHeightMargin = topItemOffset * 2 - 2

local videoLogoText = love.graphics.newText(gfx.font.kimberley, "VIDEO OPTIONS")
local txtItems = { "FULL SCREEN", "FULL SCREEN MODES", "VIDEO FILTER", "BACK" }
local fullScreenFillText = { "KEEP RATIO", "PIXEL PERFECT", "FILL STRETCHED" }

local menu = fillMenu(txtItems)

local menuState, oldMenuState = 1, 1
local mouse_x, mouse_y, oldMouse_y = 0, 0, 0

function videoModeState:enter()
    mouse_x, mouse_y = 0, 0
    --TEsound.stop("music")
    -- Prevent double press at start (e.g. auto confirmation)
    Control1.attack:update()
    Control1.jump:update()
    Control1.start:update()
    Control1.back:update()
    love.graphics.setLineWidth(2)
    self:wheelmoved(0, 0) --pick 1st sprite to draw
end

function videoModeState:resume()
    mouse_x, mouse_y = 0, 0
end

--Only P1 can use menu / options
function videoModeState:playerInput(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx", "menuCancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return self:confirm(mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) then
        self:wheelmoved(0, -1)
    elseif controls.horizontal:pressed(1) then
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

function videoModeState:update(dt)
    time = time + dt
    if menuState ~= oldMenuState then
        sfx.play("sfx", "menuMove")
        oldMenuState = menuState
    end
    self:playerInput(Control1)
end

function videoModeState:draw()
    push:start()
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1, #menu do
        local m = menu[i]
        if i == 1 then
            if GLOBAL_SETTING.FULL_SCREEN then
                m.item = "FULL SCREEN"
            else
                m.item = "WINDOWED MODE"
            end
            m.hint = "USE F11 TO TOGGLE SCREEN MODE"
        elseif i == 2 then
            m.item = fullScreenFillText[GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE]
            if GLOBAL_SETTING.FULL_SCREEN then
                m.hint = "FULL SCREEN FILLING MODES"
            else
                m.hint = "FOR WINDOWED MODE ONLY"
            end
        elseif i == 3 then
            if GLOBAL_SETTING.FILTER_N > 0 then
                local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
                m.item = "VIDEO FILTER " .. sh.name
            else
                m.item = "VIDEO FILTER OFF"
            end
            m.hint = ""
        end
        calcMenuItem(menu, i)
        if i == oldMenuState then
            colors:set("white")
            love.graphics.print(m.hint, m.wx, m.wy)
            colors:set("black", nil, 80)
            love.graphics.rectangle("fill", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4, 4, 1)
            colors:set("menuOutline")
            love.graphics.rectangle("line", m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin, 4, 4, 1)
        end
        colors:set("white")
        love.graphics.print(m.item, m.x, m.y)

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= oldMouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - leftItemOffset, m.y - topItemOffset, m.w + itemWidthMargin, m.h + itemHeightMargin) then
            oldMouse_y = mouse_y
            menuState = i
        end
    end
    --header
    colors:set("white")
    love.graphics.draw(videoLogoText, (screenWidth - videoLogoText:getWidth()) / 2, titleOffset_y)
    showDebugIndicator()
    push:finish()
end

function videoModeState:confirm(x, y, button, istouch)
    local i = 0
    if y > 0 then
        i = 1
    elseif y < 0 then
        i = -1
    end
    if button == 1 then
        --mouse_x, mouse_y = x, y
        if menuState == 1 then
            sfx.play("sfx", "menuSelect")
            switchFullScreen()
        elseif menuState == 2 then
            sfx.play("sfx", "menuSelect")
            GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE + i
            if GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE > #fullScreenFillText then
                GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = 1
            elseif GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE < 1 then
                GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE = #fullScreenFillText
            end
            push._pixelperfect = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 2 --for Pixel Perfect mode
            push._stretched = GLOBAL_SETTING.FULL_SCREEN_FILLING_MODE == 3 --stretched fill
            push:initValues()
            configuration:save(true)
        elseif menuState == 3 then
            sfx.play("sfx", "menuSelect")
            GLOBAL_SETTING.FILTER_N = GLOBAL_SETTING.FILTER_N + i
            if GLOBAL_SETTING.FILTER_N > #shaders.screen then
                GLOBAL_SETTING.FILTER_N = 0
            elseif GLOBAL_SETTING.FILTER_N < 0 then
                GLOBAL_SETTING.FILTER_N = #shaders.screen
            end
            local sh = shaders.screen[GLOBAL_SETTING.FILTER_N]
            if sh then
                if sh.func then
                    sh.func(sh.shader)
                end
                push:setShader(sh.shader)
                GLOBAL_SETTING.FILTER = shaders.screen[GLOBAL_SETTING.FILTER_N].name
            else
                push:setShader()
                GLOBAL_SETTING.FILTER = "none"
            end
            configuration:save(true)
        elseif menuState == #menu then
            sfx.play("sfx", "menuCancel")
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx", "menuCancel")
        return Gamestate.pop()
    end
end

function videoModeState:mousepressed(x, y, button, istouch)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    self:confirm(x, y, button, istouch)
end

function videoModeState:mousemoved(x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end

function videoModeState:wheelmoved(x, y)
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
        return self:confirm(mouse_x, y, 1)
    elseif menuState == 2 then
        return self:confirm(mouse_x, y, 1)
    elseif menuState == 3 then
        return self:confirm(mouse_x, y, 1)
    end
    if menuState ~= #menu then
        sfx.play("sfx", "menuMove")
    end
end
