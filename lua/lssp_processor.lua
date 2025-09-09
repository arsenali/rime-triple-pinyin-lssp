local kNoop = 2
local kAccepted = 1

-- 定义字符替换规则表
local CHAR_REPLACE = {
    q = 'y', w = 'y', e = 'y', r = 'y', t = 'y',
    a = 'h', s = 'h', d = 'h', f = 'h', g = 'h',
    z = 'n', x = 'n', c = 'n', v = 'n', b = 'n'
}

-- 检查快捷键是否被占用
local function is_shortcut_available(key_event, env)
    local keycode = key_event.keycode
    local ctrl = key_event:ctrl()
    local shift = key_event:shift()
    local alt = key_event:alt()
    
    -- 只处理纯Ctrl组合键（不包含Shift或Alt）
    if shift or alt then return false end
    
    -- 我们关心的快捷键
    local our_shortcuts = {
        [0x6C] = true,  -- Ctrl+L
        [0x6D] = true,  -- Ctrl+M
        [0x71] = true   -- Ctrl+Q
    }
    
    return ctrl and our_shortcuts[keycode]
end

local function processor(key_event, env)
    -- 首先检查是否是我们要处理的快捷键
    if not is_shortcut_available(key_event, env) then
        return kNoop
    end

    -- 快捷键配置
    local shortcut = {
        [0x6C] = ";",  -- Ctrl+L
        [0x6D] = "'",  -- Ctrl+M
        [0x71] = "q"   -- Ctrl+Q
    }
    
    -- 安全处理（保留原始输入）
    local old_input = env.engine.context and env.engine.context.input or ""
    local ok, result = pcall(function()
        local ctx = env.engine.context
        if not ctx then return old_input end

        local composition = ctx.composition
        if not composition or composition:empty() then return old_input end

        local seg = composition:back()
        if not seg then return old_input end

        local input = ctx.input:sub(seg._start + 1, seg._end)
        local raw = input:gsub("[';]", "")
        local prefix = ctx.input:sub(1, seg._start)

        -- 分离 [HSPNZ] 后缀
        local suffix = ""
        local raw_to_process = raw
        local suffix_match = raw:match("[HSPNZ]+$")
        if suffix_match then
            suffix = suffix_match
            raw_to_process = raw:sub(1, -#suffix - 1)
        end

        local sep = shortcut[key_event.keycode]
        
        -- 根据不同的快捷键执行不同操作
        if sep == "q" then  -- Ctrl+Q：三码分段+第三码替换为无声调
            local segments = {}
            for i = 1, #raw_to_process, 3 do
                local segment = raw_to_process:sub(i, math.min(i+2, #raw_to_process))
                if #segment == 3 then
                    local third = segment:sub(3, 3):lower()
                    segment = segment:sub(1, 2) .. (CHAR_REPLACE[third] or third)
                end
                table.insert(segments, segment)
            end
            
            -- 用分号连接
            local processed = table.concat(segments, ";")
            
            -- 直接拼接前缀、处理结果和后缀
            return prefix .. processed .. suffix
        elseif sep == ";" then  -- Ctrl+L：全码处理，三码分段
            local segmented = ""
            for i = 1, #raw_to_process, 3 do
                segmented = segmented .. raw_to_process:sub(i, math.min(i+2, #raw_to_process))
                if i+2 < #raw_to_process then
                    segmented = segmented .. ";"
                end
            end
            return prefix .. segmented .. suffix
        else  -- Ctrl+M：首码简拼处理
            local segmented = ""
            for i = 1, #raw_to_process do
                segmented = segmented .. raw_to_process:sub(i, i)
                if i < #raw_to_process then
                    segmented = segmented .. "'"
                end
            end
            return prefix .. segmented .. suffix
        end
    end)

    -- 错误恢复
    if not ok then
        print("处理出错:", result)
        if env.engine.context then
            env.engine.context.input = old_input
        end
        return kNoop
    end
    
    -- 应用结果
    if result and env.engine.context then
        env.engine.context.input = result
        return kAccepted
    end
    
    return kNoop
end

return {
    init = function(env) end,
    func = processor
}