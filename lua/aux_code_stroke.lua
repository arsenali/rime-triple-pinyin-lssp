-- 调试打印函数
local debug_log_path = rime_api.get_user_data_dir() .. "/lua/aux_code_stroke_debug.log"
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

local REPLACE_MAP = {h="H", s="S", p="P", n="N", z="Z"}

local AuxFilter = {}

----------------
-- 回调函数
----------------
function AuxFilter.init(env)
    -- debug_print(1, "初始化开始")
    
    -- debug_print(1, "开始调用readAuxTxt函数阅读辅码文件")
    AuxFilter.aux_code = AuxFilter.readAuxTxt(env.name_space)
    -- debug_print(1, "调用完成，阅读完毕")

    -- local count = 0
    -- if not AuxFilter.aux_code then
        -- debug_print(1, "错误: 辅助码表不存在，无法加载")
    -- elseif next(AuxFilter.aux_code) == nil then
        -- debug_print(1, "错误: 辅助码表存在，但为空")
    -- else
        -- for char, code in pairs(AuxFilter.aux_code) do
            -- debug_print(1, "辅助码示例:", char, "=>", code)
            -- count = count + 1
            -- if count >= 2 then break end
        -- end
    -- end

    local engine = env.engine
    local config = engine.schema.config

    -- debug_print(1, "初始化完成")
    
    env.notifier = engine.context.select_notifier:connect(function(ctx)
        -- debug_print(1, "notifier 回调触发", "input:", ctx.input)

        local input = ctx.input  -- 获取当前输入（可能包含笔画辅助码）
        local preedit = ctx:get_preedit()
        local preedit_text = ctx:get_preedit().text  -- 获取上屏的候选词（可能是单字或词组）

        -- debug_print(1, "input:", input, "ctx.input:", ctx.input)
        -- debug_print(1, "上屏的候选词:", preedit_text, "其中第一个剩余的原始输入码:", preedit_text:match("[qwertyasdfghzxcvbn]"))

        if not preedit_text or preedit_text == "" then  -- 如果 preedit_text 为空（可能未选中候选词），直接返回
            return
        end

        local stroke_str = input:match("[HSPNZ]+$") or ""
        -- debug_print(1, "stroke_str:", stroke_str)

        if stroke_str == "" then  -- 如果没有辅助码，直接返回
            return
        end

        local new_input = string.sub(input, 1, #input - #stroke_str)
        -- debug_print(1, "new_input", new_input)

        ctx.input = new_input

        if preedit_text and preedit_text:match("[qwertyasdfghzxcvbn]") then
            -- debug_print(1, "不是最后一字暂不上屏")  -- 不是最后一字暂不上屏
        else
            ctx:commit()
            -- debug_print(1, "最后一字直接上屏")  -- 最后一字直接上屏
        end
    end)
end

----------------
-- 閱讀輔碼文件 --
----------------
function AuxFilter.readAuxTxt(txtpath)
    -- debug_print(1, "当前工作目录:", debug.traceback())
    -- debug_print(1, "共享数据目录:", rime_api.get_shared_data_dir())
    -- debug_print(1, "用户数据目录:", rime_api.get_user_data_dir())

    -- debug_print(1, "开始读取辅助码文件")
    local defaultFile = "/stroke.dict.yaml"
    local sharedPath = rime_api.get_shared_data_dir()
    local userPath = rime_api.get_user_data_dir()
    -- debug_print(1, "尝试读取文件:", defaultFile)
    local file, err = io.open(sharedPath .. defaultFile, "r") or io.open(userPath .. defaultFile, "r")
    if not file then
        -- debug_print(1, "打开文件失败:", err)
        return nil, err
    end
    -- debug_print(1, "成功打开文件")

    local auxCodes = {}
    -- local count = 0
    local inDataSection = false  -- 标记是否进入数据部分（跳过注释和头部）
    for line in file:lines() do

        if line:match("^%.%.%.") then  -- ...（转义写为%.%.%.）标志着注释行结束，下一行进入数据部分
            -- debug_print(2, "进入数据部分")
            inDataSection = true
            goto continue
        end

        if not inDataSection then  -- 未进入数据部分时跳过
            -- debug_print(2, "未进入数据部分")
            goto continue
        end

        if line:match("^#") or line:match("^%s*$") then  -- 跳过注释和空行
            -- debug_print(2, "跳过注释和空行")
            goto continue
        end

        if inDataSection then
            line = line:match("[^\r\n]+") -- 去掉换行符
            local char, code = line:match("^([^\t]+)\t([^\t]+)$")  -- 仅匹配单字行（格式：单字\t编码）
            if char and code then
                if auxCodes[char] then
                    auxCodes[char] = auxCodes[char] .. " " .. code
                    -- count = count + 1
                else
                    auxCodes[char] = code
                    -- count = count + 1
                end
            end
            -- debug_print(2, "去掉换行符，拆分单字和笔画码", char, code)  -- 注意，启用这句会打印词库中的所有单字，使日志文件aux_code_stroke_debug.log体积剧增
        end

        ::continue::

    end

    file:close()
    -- debug_print(1, "读取完成，共加载", count, "个辅助码")

    return auxCodes
end

------------------
-- filter 主函數 --
------------------
function AuxFilter.func(input, env)
    local context = env.engine.context

    -- debug_print(2, "过滤器输入:", env.engine.context.input)
    -- debug_print(2, "辅助码表状态:", AuxFilter.aux_code and "已加载" or "未加载")
    
    local inputCode = context.input

    if not context.input:find("[HSPNZ]") then  -- 输入笔画编码时才进行filter处理，否则不予处理
        -- debug_print(1, "context.input", context.input, "不含笔画码，filter不予处理")
        for cand in input:iter() do
            yield(cand)
        end
        return
    end

    local firstStrokePos = inputCode:find("[HSPNZ]")  -- 笔画码起始位置

    local pinyinsPart = inputCode:sub(1, firstStrokePos-1)  -- 拼音码部分
    local strokesPart = inputCode:sub(firstStrokePos)  -- 笔画码部分

    -- debug_print(1, "过滤器函数处理开始，inputCode:", inputCode)
    -- debug_print(1, "笔画码起始位置:", firstStrokePos, "，拼音码部分:", pinyinsPart, "，笔画码部分:", strokesPart)

    -- debug_print(1, "开始遍历候选词")  -- 遍历候选词
    local candidates = {}
    for cand in input:iter() do  -- 遍历候选词进行过滤
        -- debug_print(3, "过滤候选词:", cand.text)

        local firstChar = utf8.len(cand.text) == 1 and cand.text or cand.text:sub(1, 3)  -- 获取第一个字符
        local auxCodes = AuxFilter.aux_code[firstChar]
        if auxCodes then
            -- debug_print(1, "候选词:", cand.text, "首字:", firstChar, "笔画码:", auxCodes)
            local auxCodesUpper = auxCodes:gsub("[hspnz]", REPLACE_MAP)
            -- debug_print(1, "转换为 auxCodesUpper:", auxCodesUpper)
            local matched = false
            for code in auxCodesUpper:gmatch("%S+") do
                if code:sub(1, #strokesPart) == strokesPart then
                    matched = true
                    break
                end
            end
            
            if matched then
                -- debug_print(2, "笔画码部分:", strokesPart, "匹配结果:", tostring(matched or "nil"), "存入缓存表")
                table.insert(candidates, cand)
            end
        end
    end
    -- debug_print(1, "所有候选词过滤完毕")
    
    for _, cand in ipairs(candidates) do  -- 返回候选词
        yield(cand)
    end
    
    -- debug_print(1, "过滤器函数执行完毕", "context:get_preedit().text:", context:get_preedit().text, "笔画码部分:", strokesPart)
end

function AuxFilter.fini(env)
    if env.notifier then
        env.notifier:disconnect()
        env.notifier = nil -- 显式释放引用
        -- debug_print(1, "过滤器结束")
    end
end

return AuxFilter
