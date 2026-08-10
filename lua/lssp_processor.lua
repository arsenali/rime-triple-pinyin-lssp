local kNoop    = 2
local kAccepted = 1

-----------------------------------------------------------
-- 配置区（以后改规则只改这里）
-----------------------------------------------------------

-- 第三码 → 无声调映射
local TONE_REPLACE = {
    q = 'y', w = 'y', e = 'y', r = 'y', t = 'y',
    a = 'h', s = 'h', d = 'h', f = 'h', g = 'h',
    z = 'n', x = 'n', c = 'n', v = 'n', b = 'n',
}

-- Ctrl 快捷键定义
local SHORTCUTS = {
    [0x75] = { id = "u", step = 1 }, -- Ctrl+u
    [0x6A] = { id = "j", step = 2 }, -- Ctrl+j
    [0x6D] = { id = "m", step = 3 }, -- Ctrl+m
    [0x71] = { id = "q", special = true }, -- Ctrl+q
}

-- 合法快捷键键码集合
local SHORTCUT_KEYS = {
    [0x75] = true,
    [0x6A] = true,
    [0x6D] = true,
    [0x71] = true,
}

-----------------------------------------------------------
-- 工具函数
-----------------------------------------------------------

-- 判断是否是我们关心的纯 Ctrl 快捷键
local function is_shortcut_available(key_event)
    return key_event:ctrl()
       and not key_event:shift()
       and not key_event:alt()
       and SHORTCUT_KEYS[key_event.keycode]
end

-- 通用分段函数
local function segment_input(input, step)
    local parts = {}
    for i = 1, #input, step do
        parts[#parts + 1] = input:sub(i, math.min(i + step - 1, #input))
    end
    return table.concat(parts, ";")
end

-----------------------------------------------------------
-- 主处理器
-----------------------------------------------------------

local function processor(key_event, env)
    if not is_shortcut_available(key_event) then
        return kNoop
    end

    local cfg = SHORTCUTS[key_event.keycode]
    local ctx = env.engine.context
    -- 只在编辑（composing）状态生效；非编辑态不拦截
    if not ctx or not ctx:is_composing() then
        return kNoop
    end
    local old_input = ctx and ctx.input or ""

    local ok, result = pcall(function()
        if not ctx then return old_input end

        local comp = ctx.composition
        if not comp or comp:empty() then return old_input end

        local seg = comp:back()
        if not seg then return old_input end

        local full_input = ctx.input
        local current = full_input:sub(seg._start + 1, seg._end)
        local raw = current:gsub("[';]", "")

        -- 提取 [HSPNZ] 后缀
        local suffix = raw:match("[HSPNZ]+$") or ""
        local body = raw:sub(1, -#suffix - 1)

        local prefix = full_input:sub(1, seg._start)

        ---------------------------------------------------
        -- Ctrl+q：每三码分段，第三码替换为无声调
        ---------------------------------------------------
        if cfg.special then
            local parts = {}
            for i = 1, #body, 3 do
                local seg3 = body:sub(i, math.min(i + 2, #body))
                if #seg3 == 3 then
                    local third = seg3:sub(3, 3):lower()
                    seg3 = seg3:sub(1, 2) .. (TONE_REPLACE[third] or third)
                end
                parts[#parts + 1] = seg3
            end
            return prefix .. table.concat(parts, ";") .. suffix
        end

        ---------------------------------------------------
        -- 普通分段快捷键（u / j / m）
        ---------------------------------------------------
        return prefix .. segment_input(body, cfg.step) .. suffix
    end)

    if not ok then
        print("lssp_processor error:", result)
        if ctx then ctx.input = old_input end
        return kNoop
    end

    if result and ctx then
        ctx.input = result
        return kAccepted
    end

    return kNoop
end

-----------------------------------------------------------
return {
    init = function(env) end,
    func = processor,
}