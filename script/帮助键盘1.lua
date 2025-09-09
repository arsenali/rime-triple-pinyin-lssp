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
  {"基本原理", [[
通过“声母+韵母+去重码&声调”，三码输入一个带调音节，任意两个音节编码不重复（即没有重复音节）。针对手机打字设计，只使用15键，按键大，适合单手打字。

键盘有3x5和4x4两种布局，3x5布局的第5列即4x4布局的第4行。

  ]]},
  {"编码方案", [[
前两码分别输入声母和韵母，类似于普通双拼，但是声母和韵母都合并在15个按键上，部分声母、韵母共键。共键声母在第二码去重，共键韵母在第三码去重。

初学者可使用动态键盘主题，方便熟悉键位，但只能打三码全码；熟练后可使用静态键盘主题，静态键盘可使用首码简拼和前两码简拼，打前两码简拼类似于普通的有重音的双拼，第三码相当于直接辅助码。

另外，还可使用笔画码筛选去重，类似于搜狗拼音，笔画码相当于间接辅助码。

  ]]},
  {"第1码", [[
[第1码：声母]
23个声母合并在15个按键上，大致按照声母表顺序排列，方便记忆。其中部分声母共键，包括：
 1. g/j, k/q, h/x；
 2. 零声母/y/w；
 3. zh/z, ch/c, sh/s, r/f。
共键声母将在第2码去重。

说明：零声母也是声母的一种，键盘上用´表示，打零声母音节需要先输入´，例如“西安”的拼音写做：xi´an。

  ]]},
  {"第2码", [[
[第2码：韵母]
24个韵母合并在15个按键上，分布规律是：
 1. aoe开头的韵母（第1类）分布在第1行，包括a,o,e,ai,ei,an,en,ang,eng等，第1类韵母是基础韵母；
 2. i开头的韵母（第2类）分布在第2行，第2类韵母包括单韵母i及i与第1类基础韵母结合而成的复韵母，例如i,ia,ian,iang等；
 3. u开头的韵母（第3类）分布在第3行，第3类韵母包括单韵母u及u与第1类基础韵母结合而成的复韵母，例如u,ua,uan,uang等；
 4. ü开头的韵母（第4类）分布在第4行，第4类韵母包括单韵母ü及ü与第1类基础韵母结合而成的复韵母，例如ü,üe,ün等。

在第2码中，通过声韵组合消除第1码中的共键声母，任意前两码组合都只产生3个重复音节，这3个重复音节将在第3码去重。

  ]]},
  {"去重原理", [[
[声母去重原理]
第2码是去重的关键，也是本方案记忆的难点，但理解规则不难掌握。在第2码中通过声韵组合消除第1码中的共键声母，3类共键声母的去重原理分别是：

 1. g/j, k/q, h/x：
 因为gkh只和1、3类韵母相拼，jqx只和2、4类韵母相拼，所以共键声母被自然区分，
 例如只有ga而没有ja，所以g/j+a=ga，只有ji而没有gi，所以g/j+i=ji；

 2. “零声母/y/w”：
 因为零声母只和第1类韵母相拼，声母y只和第2、4类韵母相拼，声母w只和第3类韵母相拼，所以三个声母被自然区分，
 例如“零/y/w”+a=´a, “零/y/w”+ia=ya, “零/y/w”+ua=wa, “零/y/w”+ue=yue。
 注：声母y、w也是零声母的一种形式，例如ya=´ia, wa=´ua, yue=´ue。

 3. zh/z, ch/c, sh/s, r/f：
 由于这8个声母后面都只跟第1、3类韵母而不跟第2、4类韵母，例如只有zhan、zan而没有zhian、zian，只有zhuan、zuan而没有zhüan、züan，所以把zh,ch,sh,r所跟韵母放在第1、3行，把z,c,s,f所跟韵母放在第2、4行。
 注：7个整体认读音节“zhi,chi,shi,ri,zi,ci,si”的韵母虽然写作i，但其实和单音节韵母i不同韵，因此归为第1类韵母，安排在第1、2行的第3键上。

通过前两码组合，共键声母全部得以区分。

在第2码中，把相似的韵母安排在同一个键位上，每个键位上都有3个韵母，共键韵母将在第3码去重。

  ]]},
  {"第3码", [[
[第3码：去重码&声调]
第3码同时输入韵母去重码和声调：
 1. 韵母去重：第2码中的三个共键韵母在第3码中按照韵尾的不同分布在1-3行上，以区分重复音节，例如第一组韵母a,an,ang依次分布在第1-3行；
 2. 声调：用1-5列分别输入1-4声和轻声。

如此，在输入第3码之后便得到了唯一的一个带调拼音音节，不会有重复音节。

  ]]},
  {"便捷输入", [[
[无声调模式]
如果不想区分声调，可长按或上滑T键切换到无声调模式，此时在第3码中可用TGB三键输入无声调音节。
打字过程中也可随时把已输入的带调音节转换为无声调音节，左滑或右滑T键进行转换，而不必切换到无声调模式重新输入。

[单字键、全码键]
打首码简拼时，按单字键进行检索。
打全码字时，如果第一候选项不是想要的全码字，可点击全码键，检索全码单字及词组。

[笔画筛选]
下滑QWEAS键输入五笔画“一丨丿丶フ”对候选字进行筛选，可连续输入笔画码进行连续筛选，直到筛选出想要打的字。

[反查]
可用拼音和笔画两种方案反查三拼编码。

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
方言中有尖音的朋友可打尖音字以降低重码率，
例如，z开头的尖音音节以“b+第3、4类韵母”（bu除外）输入，例如：尖zian=buan，绝züe=büe；
同理，c开头的尖音音节以“p+第3、4类韵母”（pu除外）输入，s开头的尖音音节以“m+第3、4类韵母”（mu除外）输入。

尖音字可打尖可打团，而团音字只能打团音，例如尖音字“尖”可打ziān或jiān，而团音字“间”只能打jiān才有。

  ]]},
  {"键盘操作", [[
空格(Space)：候选汉字
回车(Enter)：上屏码
上滑G键：提示码
上滑B键：输入码

上滑空格键：切换中英文
上滑退格键：清屏（重输）/收起键盘
左滑退格键：删音节
下滑退格键：Delete

左滑空格键：撤销
右滑空格键：重做

下滑反查键：删词
下滑帮助键：双手/单手模式
下滑问号键：显示/隐藏助记

上滑E键：移动到文首
上滑R键：移动到文尾
上滑D键：移动到行首
上滑F键：移动到行尾
上滑向左键：向左移动音节
上滑向右键：向右移动音节

左滑Enter键/右滑中英键：Enter
左滑逗号键/右滑符号键：全选

上滑Z键：全选
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
