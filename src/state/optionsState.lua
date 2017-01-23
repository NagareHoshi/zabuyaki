optionsState = {}

local time = 0
local screen_width = 640
local screen_height = 480
local menu_item_h = 40
local menu_y_offset = 200 - menu_item_h
local menu_x_offset = 0
local hint_y_offset = 80
local title_y_offset = 24
local left_item_offset  = 6
local top_item_offset  = 6
local item_width_margin = left_item_offset * 2
local item_height_margin = top_item_offset * 2 - 2

local txt_options_logo = love.graphics.newText( gfx.font.kimberley, "OPTIONS" )
local txt_option1 = "BG MUSIC ON"
local txt_option1a = "BG MUSIC OFF"
local txt_option2 = "DIFFICULTY NORMAL"
local txt_option2a = "DIFFICULTY HARD"
local txt_option3 = "SOUND TEST"
local txt_option4 = "DEFAULTS"
local txt_option5 = "SPRITE EDITOR"
local txt_quit = "BACK"

local txt_items = {txt_option1, txt_option2, txt_option3, txt_option4, txt_option5, txt_quit}

local function set_items_according_the_options()
    if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
        txt_items[1] = txt_option1
    else
        txt_items[1] = txt_option1a
    end
    if GLOBAL_SETTING.DIFFICULTY == 1 then
        txt_items[2] = txt_option2
    else
        txt_items[2] = txt_option2a
    end
    TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
end
set_items_according_the_options()

local function fillMenu(txt_items, txt_hints)
    local m = {}
    local max_item_width, max_item_x = 8, 0
    if not txt_hints then
        txt_hints = {}
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        if w > max_item_width then
            max_item_x = menu_x_offset + screen_width / 2 - w / 2
            max_item_width = w
        end
    end
    for i = 1, #txt_items do
        local w = gfx.font.arcade4:getWidth(txt_items[i])
        m[#m + 1] = {
            item = txt_items[i],
            hint = txt_hints[i] or "",
            x = menu_x_offset + screen_width / 2 - w / 2,
            y = menu_y_offset + i * menu_item_h,
            rect_x = max_item_x,
            w = max_item_width,
            h = gfx.font.arcade4:getHeight(txt_items[i]),
            wx = (screen_width - gfx.font.arcade4:getWidth(txt_hints[i] or "")) / 2,
            wy = screen_height - hint_y_offset,
            n = 1
        }
    end
    return m
end

local menu = fillMenu(txt_items, txt_hints)

local menu_state, old_menu_state = 1, 1
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
end

function optionsState:resume()
    mouse_x, mouse_y = 0,0
end

--Only P1 can use menu / options
local function player_input(controls)
    if controls.jump:pressed() or controls.back:pressed() then
        sfx.play("sfx","menu_cancel")
        return Gamestate.pop()
    elseif controls.attack:pressed() or controls.start:pressed() then
        return optionsState:confirm( mouse_x, mouse_y, 1)
    end
    if controls.horizontal:pressed(-1) or controls.vertical:pressed(-1) then
        menu_state = menu_state - 1
    elseif controls.horizontal:pressed(1) or controls.vertical:pressed(1) then
        menu_state = menu_state + 1
    end
    if menu_state < 1 then
        menu_state = #menu
    end
    if menu_state > #menu then
        menu_state = 1
    end
end

function optionsState:update(dt)
    time = time + dt
    if menu_state ~= old_menu_state then
        sfx.play("sfx","menu_move")
        old_menu_state = menu_state
    end
    player_input(Control1)
end

function optionsState:draw()
    push:apply("start")
    love.graphics.setFont(gfx.font.arcade3x2)
    for i = 1,#menu do
        local m = menu[i]
        if i == old_menu_state then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.print(m.hint, m.wx, m.wy)
            love.graphics.setColor(0, 0, 0, 80)
            love.graphics.rectangle("fill", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
            love.graphics.setColor(255,200,40, 255)
            love.graphics.rectangle("line", m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin, 4,4,1)
        end
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print(m.item, m.x, m.y )

        if GLOBAL_SETTING.MOUSE_ENABLED and mouse_y ~= old_mouse_y and
                CheckPointCollision(mouse_x, mouse_y, m.rect_x - left_item_offset, m.y - top_item_offset, m.w + item_width_margin, m.h + item_height_margin )
        then
            old_mouse_y = mouse_y
            menu_state = i
        end
    end
    --header
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.draw(txt_options_logo, (screen_width - txt_options_logo:getWidth()) / 2, title_y_offset)
    show_debug_indicator()
    push:apply("end")
end

function optionsState:confirm( x, y, button, istouch )
    if button == 1 then
        mouse_x, mouse_y = x, y
        if menu_state == 1 then
            sfx.play("sfx","menu_select")
            if GLOBAL_SETTING.BGM_VOLUME ~= 0 then
                configuration:set("BGM_VOLUME", 0)
                txt_items[1] = txt_option1a
            else
                configuration:set("BGM_VOLUME", 0.75)
                txt_items[1] = txt_option1
            end
            TEsound.volume("music", GLOBAL_SETTING.BGM_VOLUME)
            menu = fillMenu(txt_items, txt_hints)

        elseif menu_state == 2 then
            sfx.play("sfx","menu_select")
            if GLOBAL_SETTING.DIFFICULTY == 1 then
                configuration:set("DIFFICULTY", 2)
                txt_items[2] = txt_option2a
            else
                configuration:set("DIFFICULTY", 1)
                txt_items[2] = txt_option2
            end
            menu = fillMenu(txt_items, txt_hints)

        elseif menu_state == 3 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(soundState)

        elseif menu_state == 4 then
            sfx.play("sfx","menu_select")
            configuration:reset()
            configuration.dirty = true
            set_items_according_the_options()
            menu = fillMenu(txt_items, txt_hints)

        elseif menu_state == 5 then
            sfx.play("sfx","menu_select")
            return Gamestate.push(spriteSelectState)

        elseif menu_state == #menu then
            sfx.play("sfx","menu_cancel")
            configuration:save()
            return Gamestate.pop()
        end
    elseif button == 2 then
        sfx.play("sfx","menu_cancel")
        configuration:save()
        return Gamestate.pop()
    end
end

function optionsState:mousepressed( x, y, button, istouch )
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    optionsState:confirm( x, y, button, istouch )
end

function optionsState:mousemoved( x, y, dx, dy)
    if not GLOBAL_SETTING.MOUSE_ENABLED then
        return
    end
    mouse_x, mouse_y = x, y
end