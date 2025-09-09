-- 调试打印函数
local debug_log_path = rime_api.get_user_data_dir() .. "/lua/limited_debug.log"
local DEBUG_LEVEL = 3  -- 调试级别(3=最高)
local function debug_print(level, ...)
    if level <= DEBUG_LEVEL then
        local file = io.open(debug_log_path, "a")
        if file then
            local args = {...}
            local message = os.date("%Y-%m-%d %H:%M:%S") .. " - " .. table.concat(args, " ") .. "\n"
            file:write(message)
            file:close()
        end
    end
end

local kNoop, kAccepted = 2, 1

local function target_keys(keycode)
    return (keycode >= 0x61 and keycode <= 0x7A)                          -- a-z
        or (keycode >= 0x41 and keycode <= 0x5A                          -- A-Z
            and not ({[0x48]=true, [0x53]=true, [0x50]=true, [0x4E]=true, [0x5A]=true})[keycode])  -- 排除HSPNZ
        or (keycode == 0x3B or keycode == 0x27)                           -- ;'
end

local function processor(key_event, env)
    local ctx = env.engine.context
    local is_valid = ctx and ctx.input ~= ""
    if is_valid and ctx.input:match("[HSPNZ]") then  -- 输入内容包括笔画码[HSPNZ]
        -- debug_print(1, "输入内容包括笔画码")
        local is_shortcut = key_event:ctrl()  -- 按下Ctrl
                           and (key_event.keycode == 0x71  -- q
                             or key_event.keycode == 0x6C  -- l
                             or key_event.keycode == 0x6D) -- m
        if not is_shortcut and target_keys(key_event.keycode) then  -- 输入内容不是快捷键且包括拼音码[qwertyasdfghzxcvbn]
            -- debug_print(1, "输入内容包括拼音码:", string.char(key_event.keycode))
            return kAccepted  -- 实际效果是：笔画码后不允许输入拼音码。但语法逻辑似乎是相反的：当输入内容包括拼音码时，接受当前按键事件，允许输入法引擎处理该按键，否则忽略当前按键事件，不进行任何处理。为什么用相反逻辑的语句才能得到想要的效果？不知道是为什么
        end
    end
    return kNoop
end

return { init = function() end, func = processor }