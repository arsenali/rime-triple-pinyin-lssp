-- 定义模块：多方案切换处理器
-- 功能：根据用户选择的上屏方案，调用对应的翻译器进行转换
local M = {}

-- 初始化函数 - 在输入法启动时执行
-- @param env 环境变量对象，用于存储组件和状态
function M.init(env)
    -- 初始化四个上屏方案翻译器
    
    -- 全拼翻译器
    env.translator1 = Component.Translator(
        env.engine,                 -- Rime引擎实例
        "",                         -- 空命名空间
        "script_translator@quanpin" -- 全拼翻译器标识
    )
    
    -- 拼音翻译器
    env.translator2 = Component.Translator(
        env.engine,
        "",
        "script_translator@ddpy"    -- 拼音翻译器标识
    )
    
    -- 注音翻译器
    env.translator3 = Component.Translator(
        env.engine,
        "",
        "script_translator@zhuyin"  -- 注音翻译器标识
    )
    
    -- 国罗翻译器
    env.translator4 = Component.Translator(
        env.engine,
        "",
        "script_translator@guoluo"  -- 国罗翻译器标识
    )
    -- 主翻译器，不转换
    env.translator5 = Component.Translator(
        env.engine,
        "",
        "script_translator@translator"  -- 主翻译器标识
    )
end

-- 清理函数 - 在输入法关闭时执行
-- @param env 环境变量对象
function M.fini(env)
    -- 释放所有翻译器资源
    env.translator1 = nil  -- 释放全拼翻译器
    env.translator2 = nil  -- 释放拼音翻译器
    env.translator3 = nil  -- 释放注音翻译器
    env.translator4 = nil  -- 释放国罗翻译器
    env.translator5 = nil  -- 释放主翻译器
end

-- 核心处理函数 - 对每个方案进行转换处理
-- @param input 用户输入的字符串
-- @param seg 分段信息对象
-- @param env 环境变量对象
function M.func(input, seg, env)
    -- 定义结果变量
    local result = nil
    
    -- 根据当前激活的上屏方案选择对应的翻译器
    if env.engine.context:get_option("bopomofo_quanpin") then
        -- 全拼方案激活
        result = env.translator1:query(input, seg)
    elseif env.engine.context:get_option("bopomofo_ddpy") then
        -- 拼音方案激活
        result = env.translator2:query(input, seg)
    elseif env.engine.context:get_option("bopomofo_zhuyin") then
        -- 注音方案激活
        result = env.translator3:query(input, seg)
    elseif env.engine.context:get_option("bopomofo_guoluo") then
        -- 国罗方案激活
        result = env.translator4:query(input, seg)
    elseif env.engine.context:get_option("bopomofo_translator") then
        -- 主翻译器激活
        result = env.translator5:query(input, seg)
    else
        -- 默认使用注音方案
        result = env.translator3:query(input, seg)
    end
    
    -- 输出转换结果
    if result ~= nil then
        -- 遍历所有候选词
        for candidate in result:iter() do
            -- 返回每个候选词
            yield(candidate)
        end
    end
end

-- 返回模块
return M