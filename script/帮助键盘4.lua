require "import"
import "android.app.*"
import "android.os.*"

import "java.util.regex.Matcher"
import "java.util.regex.Pattern"
import "android.text.*"
import "android.text.method.LinkMovementMethod"
import "android.text.method.ScrollingMovementMethod"
import "android.text.Spannable"
import "android.text.SpannableString"
import "android.text.Layout"
import "android.text.style.ClickableSpan"
import "android.text.style.URLSpan"
import "android.text.style.StyleSpan"
import "android.text.style.ForegroundColorSpan"
import "android.text.style.AlignmentSpan"

import "android.util.Patterns"
import "android.net.Uri"
import "android.content.*"
import "android.content.Intent"
import "android.content.Context"
import "android.content.ClipboardManager"

import "android.widget.*"
import "android.view.*"

import "android.graphics.Color"
import "android.graphics.Typeface"
import "android.graphics.RectF"
import "android.graphics.drawable.StateListDrawable"

import "com.osfans.trime.*"

-- 键盘高度等基础配置
local height = "240dp"  --键盘高度
pcall(function()
  --键盘自适应高度，旧版中文不支持，放pcall里防报错
  height = service.getLastKeyboardHeight()
end)

-- 定义颜色表（类似 Android 的 colors.xml）
local Colors = {
    SELECTED = 0xffd7dddd,      -- 按钮选中状态色/说明文字背景色
    NORMAL = 0xffc4c9ca,        -- 按钮背景默认灰色
    TEXT_NORMAL = 0xff232323,   -- 默认文字色
    TEXT_SELECTED = 0xff0066cc  -- 选中文字色
}

-- 超时阈值等
local LONG_PRESS_THRESHOLD = 0.5 --长按时间
local startTime

-- 说明文字内容
local Intro = {
  {"返回"},
  {"编码方案", [[
三码输入一个带调音节，总键位数26个；
首码声母，次码韵母，第三码以“oeway”输入「ˉˊˇˋ˙」五声调；
可省略声调成为无声调双拼。

声母使用除“oeway”以外的21键，韵母使用26键，声调使用“oeway”五键，由于声母和声调不共键，所以省略声调不会造成重复音节，其原理类似于顶功。

编码基于自然码，做适当调整，详见后文。

  ]]},
  {"y、w和零声母", [[
[声母y]
声母y开头的音节分为两类：
 1: y和以aoe开头的韵母（除了ong）相拼时以j输入，包括：ya, yo, ye, yai, yao, yan, yang, you共8个音节；
 2: y和以i,u开头的韵母以及韵母ong相拼时以f输入，包括：yi, yin, ying, yu, yuan, yue, yun, yong共8个音节。

[声母w]
声母w以q输入。

[零声母]
零声母er以f引导，其他零声母以x引导。

  ]]},
  {"便捷输入", [[
[笔画筛选]
下滑QWEAS键输入五笔画“一丨丿丶フ”对候选字进行筛选，可连续输入笔画码进行连续筛选，直到筛选出想要打的字。

[反查]
可用拼音和笔画两种方案反查三拼编码。

[飞键]
有少数飞键。

  ]]},
  {"特色功能", [[
[四类编码]
除汉字外可输入四类汉字编码：
 - 全拼（无声调拼音）
   quan pin(wu sheng diao pin yin)
 - 带调拼音
   dài diào pīn yīn
 - 汉语注音符号
   ㄏㄢˋ ㄩˇ ㄓㄨˋ ㄧㄣˉ ㄈㄨˊ ㄏㄠˋ
 - 国语罗马字
   gwo yeu luo maa zyh(Gwoyeu Romatzyh)
点击Enter键输入汉字编码，在菜单栏中切换编码形式。

[尖音输入]
方言中有尖音的朋友可打尖音字以降低重码率，用“gi/ki/ki”输入“zi/ci/si”，用“b/p/m+ü类韵母”输入“z/c/s+ü类韵母”。

尖音字可打尖可打团，而团音字只能打团音，例如尖音字“尖”可打ziān或jiān，而团音字“间”只能打jiān才有。

  ]]},
  {"键盘操作", [[
空格(Space)：候选汉字
回车(Enter)：上屏码
左滑或右滑K键：提示码
左滑或右滑M键：输入码

上滑空格键：切换中英文
上滑退格键：清屏（重输）/收起键盘
左滑退格键：删音节
下滑退格键：Delete

左滑空格键/上滑Z键：撤销
右滑空格键/上滑Y键：重做

下滑Q键：删词
下滑A键：双手/单手模式
下滑Shift键：显示/隐藏助记

上滑K键：移动到文首
上滑L键：移动到文尾
上滑S键：移动到行首
上滑D键：移动到行尾
上滑F键：向左移动音节
上滑G键：向右移动音节

左滑Enter键/右滑中英键：Enter
左滑顿号键/右滑符号键：全选
左滑句号键/右滑逗号键：全选

上滑A键：全选
上滑X键：剪切
上滑C键：复制
上滑V键：粘贴

长按V键：打开功能键，例如剪切板和短语等

  ]]},
  {"更多介绍", [[
==== 更多介绍 ====
 [b站视频]
 [知乎专栏]
 [网盘下载]
 qq群：150478288

  ]]},
}

-- 链接规则
local links={
    {str = "b站视频", url = "https://www.bilibili.com/video/BV1eZ4y1B7d1/"},
    {str = "知乎专栏", url = "https://www.zhihu.com/column/c_1494708794508234752"},
    {str = "网盘下载", url = "http://lssp.ysepan.com"},
}

-- 匹配规则
local matchRules = {
    -- 规则1: 手机号（优先匹配）
    {
        pattern = "(?<!\\d)1[3-9]\\d{9}(?!\\d)", -- 严格匹配独立的11位手机号
        color = "#FF5722",
        underline = false,
        onClick = function(matchedText)
            print(matchedText)
            local intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:"..matchedText))
            this.startActivity(intent)
        end,
        onLongClick = function(matchedText)
            this.commitText(matchedText)
        end
    },
    -- 规则2: 网址
    {
        pattern = "http(s)?://(www\\.)?([a-zA-Z0-9\\-]+\\.)+[a-zA-Z]{2,}(:\\d+)?(/[a-zA-Z0-9_\\-\\.~:/?\\#\\[\\]@!$&'()*+,;=]*)?",
        color = "#409EFF",
        underline = true,
        onClick = function(matchedText)
            local intent = Intent(Intent.ACTION_VIEW, Uri.parse(matchedText))
            this.startActivity(intent)
        end,
        onLongClick = function(matchedText)
            this.commitText(matchedText)
        end
    },

    -- 规则3.1: 验证码
    {
        pattern = "(?<!\\d)\\d{6}(?!\\d)", -- 匹配独立的6位数字
        color = "#4CAF50",
        underline = true,
        view = true, 
        onClick = function(v)
            -- 获取当前视图文本
            local fullText = v.getText().toString()
            
            -- 重新匹配6位数字（确保精确）
            local pattern = Pattern.compile("(?<!\\d)\\d{6}(?!\\d)")
            local matcher = pattern.matcher(fullText)
            
            if matcher.find() then
                local code = matcher.group() -- 提取匹配到的验证码
                
                -- 复制到剪贴板
                local clipboard = this.getSystemService(Context.CLIPBOARD_SERVICE)
                clipboard.setPrimaryClip(ClipData.newPlainText("code", code))
                
                -- 显示Toast提示
                showToast("已复制验证码: " .. code)
            else
                showToast("未找到验证码")
            end
            
            -- 保持超链接功能
            v.setMovementMethod(LinkMovementMethod.getInstance())
        end,
        onLongClick = function(matchedText)
            print("[验证码规则] 长按事件，匹配文本:", matchedText)
        end
    },
    -- 规则4: QQ群
    {
        pattern = "150478288",
        color = "#ffAF50",
        underline = true,
        view = false, 
        onClick = function(matchedText)
            local qqUrl = "mqqapi://card/show_pslcard?src_type=internal&version=1&uin="..matchedText.."&card_type=group&source=qrcode&from=qrcode"
            local packageManager = service.getPackageManager()
            local intentQQ = Intent(Intent.ACTION_VIEW, Uri.parse(qqUrl))
                .setComponent(ComponentName("com.tencent.mobileqq", "com.tencent.mobileqq.activity.JumpActivity"))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if intentQQ.resolveActivity(packageManager) then
                service.startActivity(intentQQ)
            else
                showToast("未安装QQ，请先安装")
            end
        end,
        onLongClick = function(matchedText)
            print(matchedText)
        end
    }
}

-- 显示Toast提示
local function showToast(message)
    Toast.makeText(service, message, Toast.LENGTH_SHORT).show()
end

-- Back函数
local function Back(selected)
  return LuaDrawable(function(canvas, paint, drawable)
    local bounds = RectF(drawable.bounds)
    paint.setColor(selected and Colors.SELECTED or Colors.NORMAL)
    canvas.drawRoundRect(bounds, 0, 0, paint)  -- 圆角半径设为0
  end)
end

-- 超链接示例：高级版
function HyperlinkMatching(str, url, spannableString)
    local hyperlink = Pattern.compile(str)
    local hyper_matcher = hyperlink.matcher(spannableString)
    while (hyper_matcher.find()) do
        local s = hyper_matcher.start()
        local e = hyper_matcher.end()
        local group = hyper_matcher.group()
        local urlSpan = URLSpan(url)
        spannableString.setSpan(urlSpan, s, e, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
    end
end
-- 超链接示例：极简版
function HyperlinkMatchingFind(str, url, text, spannableString)
    local s, e = utf8.find(text, str)
    local urlSpan = URLSpan(url)
    spannableString.setSpan(urlSpan, s-1, e, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
end

-- 高亮按钮跟踪变量
local highlightedButton = nil

-- 文本处理函数/着色器函数，用于对文本应用颜色和样式
local function processStyledText(rawText)
    local spannableString = SpannableString(rawText)
    
    -- 1. 首先应用颜色和样式规则（原colorizeText的功能）
    local styleRules = {
        {
            pattern = "====.-====",
            color = Color.BLUE,  -- Android定义的基础颜色常量（共12种）
            style = Typeface.BOLD,
            alignment = true  -- 标记居中
        },  -- 标题
        {pattern = "%[.-%]", color = Color.parseColor("#AA00FF")},  -- 括号内容
        {pattern = "注意：.*", color = Color.parseColor("#FFD600")}  -- 警告
    }
    
    for _, rule in ipairs(styleRules) do
        local start = 1
        while true do
            local s, e = utf8.find(rawText, rule.pattern, start)
            if not s then break end
            
            -- 设置颜色
            spannableString.setSpan(ForegroundColorSpan(rule.color), s-1, e, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            
            -- 设置字体样式
            if rule.style then
                spannableString.setSpan(StyleSpan(rule.style), s-1, e, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
            end
            
            -- 对齐设置
            if rule.alignment then
                spannableString.setSpan(
                    AlignmentSpan.Standard(Layout.Alignment.ALIGN_CENTER),  -- ALIGN_CENTER 居中对齐 / ALIGN_NORMAL 左对齐 / ALIGN_OPPOSITE 右对齐
                    s-1, e,
                    Spannable.SPAN_EXCLUSIVE_EXCLUSIVE
                )
            end
            
            start = e + 1
        end
    end
    
    -- 2. 然后添加超链接（原processText的功能）
    for _, hy in pairs(links) do
        HyperlinkMatching(hy.str, hy.url, spannableString)
        -- HyperlinkMatchingFind(hy.str, hy.url, text, spannableString)
    end
    
    -- 3. 最后应用匹配规则（原processText的功能）
    for _, rule in ipairs(matchRules) do
        local pattern = Pattern.compile(rule.pattern)
        local matcher = pattern.matcher(spannableString)
        while (matcher.find()) do
            local s = matcher.start()
            local e = matcher.end()
            local group = matcher.group()
            
            local clickableSpan = ClickableSpan({
                onClick = function(v)
                    if (os.time() - startTime) > LONG_PRESS_THRESHOLD then
                        rule.onLongClick(group)
                    else
                        if rule.view then
                            rule.onClick(v)
                        else
                            rule.onClick(group)
                        end
                    end
                end,
                updateDrawState = function(ds)
                    ds.setColor(Color.parseColor(rule.color))
                    ds.setUnderlineText(rule.underline)
                end
            })
            spannableString.setSpan(clickableSpan, s, e, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
        end
    end
    
    return spannableString
end

-- 主布局定义
local ids, layout = {}, {LinearLayout,
  orientation = 1,
  layout_height = height,
  layout_width = -1,
  BackgroundColor = Colors.SELECTED,
  {TextView,
    layout_height = "1dp",
    layout_width = -1,
    BackgroundColor = 0xffdfdfdf},
  {LinearLayout,
    layout_height = -1,
    layout_width = -1,
    orientation = 0,  -- 改为水平方向
    {ScrollView,  -- 添加ScrollView包裹按钮容器
      layout_width = "80dp",  -- 固定宽度
      layout_height = -1,
      BackgroundColor = Colors.NORMAL,
      {LinearLayout,  -- 按钮容器
        id = "buttonBar",
        orientation = 1, -- 竖向排列按钮
        layout_width = "80dp", -- 固定宽度
        layout_height = "wrap_content", -- 高度自适应
        padding = 0}},
    {ScrollView,  -- 内容区域
      id = "scrollView",
      layout_width = -1,
      layout_height = -1,
      layout_weight = 1,  -- 占据剩余空间
      {TextView,
        id = "contentText",
        layout_width = -1,
        layout_height = "wrap_content",
        padding = "16dp",
        textColor = Colors.TEXT_NORMAL,
        textSize = "16dp",
        textIsSelectable = true,      -- 启用文本选择
        OnLongClickListener = {
          onLongClick = function(v)
            -- 获取系统剪贴板服务
            local clipboard = service.getSystemService(Context.CLIPBOARD_SERVICE)
            
            -- 设置剪贴板监听器
            clipboard.addPrimaryClipChangedListener({
              onPrimaryClipChanged = function()
                -- 当剪贴板内容变化时显示提示
                showToast("已复制到剪贴板")
                -- 移除监听器避免重复提示
                clipboard.removePrimaryClipChangedListener(this)
              end
            })
            
            -- 返回false让系统继续处理长按事件（显示复制菜单）
            return false
          end
        }
      }}
  }}

layout = loadlayout(layout, ids)

-- 刷新显示内容
local function fresh(content)
  content = content or ""  -- 处理nil和false
  ids.contentText.setText(processStyledText(tostring(content)))
end


-- 修改按钮点击处理函数
local function createButtonClickListener(index)
  return function(v)
    -- 重置之前高亮按钮
    if highlightedButton then
      highlightedButton.setBackground(Back(false))
      highlightedButton.setTextColor(Colors.TEXT_NORMAL) -- 默认文字色
    end
    
    -- 设置新高亮按钮
    v.setBackground(Back(true))
    v.setTextColor(Colors.TEXT_SELECTED) -- 选中文字色
    highlightedButton = v
    
    if Intro[index][1] == "返回" then
      service.sendEvent("Keyboard_last_lock")
    else
      fresh(Intro[index][2])
    end
  end
end

-- 初始状态设置
local function updateButtonStates()
  -- 只需要设置初始选中状态
  highlightedButton = ids.buttonBar.getChildAt(1) -- 第二个按钮
  if highlightedButton then
    highlightedButton.setBackground(Back(true))
    highlightedButton.setTextColor(Colors.TEXT_SELECTED)
  end
end

-- 初始显示内容
fresh(Intro[2][2])

-- Bus布局定义
local Bus = {LinearLayout,
  orientation = 1, -- 竖向排列
  layout_width = "80dp", -- 固定宽度
  layout_height = "wrap_content", -- 高度自适应
  padding = 0  -- 父容器无内边距
}

-- 按钮定义
for i, v in ipairs(Intro) do
  table.insert(Bus, {TextView,
    text = tostring(v[1]),
    layout_margin = 0,  -- 无外边距
    padding = "8dp",    -- 只保留文字内边距
    gravity = 17,
    layout_width = "80dp",
    layout_height = "wrap_content",
    Background = Back(false), -- 全部初始化为未选中状态
    onClick = createButtonClickListener(i),
    OnLongClickListener = {onLongClick = function() return true end},
    textColor = Colors.TEXT_NORMAL,
    textSize="14dp"})
end

-- 将按钮布局添加到ScrollView中的LinearLayout
ids.buttonBar.addView(loadlayout(Bus))

service.setKeyboard(layout)

ids.contentText.setOnTouchListener(function(view, event)
    if event.getAction() == MotionEvent.ACTION_DOWN then
        startTime = os.time()
    end
end
)

ids.contentText.setMovementMethod(LinkMovementMethod.getInstance())

function onWindowHidden()
    service.sendEvent("Keyboard_last_lock")
end
