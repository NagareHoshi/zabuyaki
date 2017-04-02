-- Display resolution settings

local disp320x240 = {
    inner = {
        resolution = { width = 320, height = 240 },
        min_scale = 1,
        max_scale = 0.75,
        y_divider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 2
    }
}

local disp640x480 = {
    inner = {
        resolution = { width = 640, height = 480 },
        min_scale = 2,
        max_scale = 1.5,
        y_divider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 1
    }
}

local disp1280x960 = {
    inner = {
        resolution = { width = 1280, height = 968 },
        min_scale = 4,
        max_scale = 3,
        y_divider = 2
    },
    final = {
        resolution = { width = 640, height = 480 },
        scale = 0.5
    }
}
--return disp320x240
--return disp640x480
return disp1280x960