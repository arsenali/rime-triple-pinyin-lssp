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
透過“聲母+介韻+去重碼&聲調”，三碼輸入一個帶調音節，任意兩個音節編碼不重複（即沒有重複音節）。針對手機打字設計，只使用15鍵，按鍵大，適合單手打字。

鍵位排列基於大千式，鍵盤有3x5、4x4和4x4豎版三種佈局，4x4豎版佈局和大千式佈局鍵位排列一致，推薦使用4x4豎版佈局。

  ]]},
  {"編碼方案", [[
前兩碼分別輸入聲母和韻母，類似於普通雙拼，但是聲母和韻母都合併在15個按鍵上，部分聲母、韻母共鍵。共鍵聲母在第二碼去重，共鍵韻母在第三碼去重。

初學者可使用動態鍵盤主題，方便熟悉鍵位，但只能打三碼全碼；熟練後可使用靜態鍵盤主題，靜態鍵盤可使用首碼簡拼和前兩碼簡拼，打前兩碼簡拼類似於普通的有重音的雙拼，第三碼相當於直接輔助碼。

另外，還可使用筆畫碼篩選去重，類似於搜狗拼音，筆畫碼相當於間接輔助碼。

  ]]},
  {"第1碼", [[
[第1碼：聲母]
聲母合併在15個按鍵上，其中部分聲母共鍵，包括：
 1. ㄍ/ㄐ, ㄎ/ㄑ, ㄏ/ㄒ；
 2. 零聲母音節；
 3. ㄓ/ㄗ, ㄔ/ㄘ, ㄕ/ㄙ, ㄖ/ㄈ。
共鍵聲母將在第2碼去重。

說明：零聲母也是聲母的一種，鍵盤上用´表示，打零聲母音節需要先輸入´，例如“西安”的拼音寫做：xi´an。

  ]]},
  {"第2碼", [[
[第2碼：介韻]
介韻組合分佈在15個按鍵上，分佈規律是：
 1. 空介韻母分佈在第1排（第1區），
 2. ㄧ+韻母分佈在第2排（第2區），
 3. ㄨ+韻母分佈在第3排（第3區），
 4. ㄩ+韻母分佈在第4排（第4區）。

在第2碼中，透過聲介韻組合消除第1碼中的共鍵聲母，任意前兩碼組合都只產生3個重複音節，這3個重複音節將在第3碼去重。

  ]]},
  {"去重原理", [[
[聲母去重原理]
第2碼是去重的關鍵，也是本方案記憶的難點，但理解規則不難掌握。在第2碼中透過聲介韻組合消除第1碼中的共鍵聲母，3類共鍵聲母的去重原理分別是：

 1. ㄍ/ㄐ, ㄎ/ㄑ, ㄏ/ㄒ：
 因為ㄍㄎㄏ只跟空介及介母ㄨ，ㄐㄑㄒ只跟介母ㄧ、ㄩ，所以共鍵聲母被自然區分，
 例如只有ㄍㄚ而沒有ㄐㄚ，所以ㄍ/ㄐ+ㄚ=ㄍㄚ，只有ㄐㄧ而沒有ㄍㄧ，所以ㄍ/ㄐ+ㄧ=ㄐㄧ；

 2. 零聲母音節：
 根據介母的不同分別分佈在4個區域；

 3. ㄓ/ㄗ, ㄔ/ㄘ, ㄕ/ㄙ, ㄖ/ㄈ：
 由於這8個聲母都不跟介母ㄧ、ㄩ，所以把ㄓㄔㄕㄖ類音節放在第1、3區，把ㄗㄘㄙㄈ類音節放在第2、4區。
 注：7個空韻音節“ㄓㄔㄕㄖㄗㄘㄙ”也需輸入一個韻母“ㄭ”（和韻母ㄛ共鍵）。

透過前兩碼組合，共鍵聲母全部得以區分。

在第2碼中，相鄰的3個韻母位於同一個鍵位，將在第3碼進行區分。

  ]]},
  {"第3碼", [[
[第3碼：去重碼&聲調]
第3碼同時輸入韻母去重碼和聲調：
 1. 韻母去重：第2碼中的三個共鍵韻母依序分佈在1-3排上，以區分重複音節，例如第一組韻母ㄚㄞㄢ依序分佈在第1-3排；
 2. 聲調：用1-4列和第4排分別輸入1-4聲和輕聲。

如此，在輸入第3碼之後便得到了唯一的一個帶調音節，不會有重複音節。

  ]]},
  {"便捷輸入", [[
[無聲調模式]
如果不想區分聲調，可長按或上滑T鍵切換到無聲調模式，此時在第3碼中可用TGB三鍵輸入無聲調音節。
打字過程中也可隨時把已輸入的帶調音節轉換為無聲調音節，左滑或右滑T鍵進行轉換，而不必切換到無聲調模式重新輸入。

[單字鍵、全碼鍵]
打首碼簡拼時，按單字鍵進行檢索。
打全碼字時，如果第一候選項不是想要的全碼字，可點選全碼鍵，檢索全碼單字及片語。

[筆畫篩選]
下滑QWEAS鍵輸入五筆畫“一丨丿丶フ”對候選字進行篩選，可連續輸入筆畫碼進行連續篩選，直到篩選出想要打的字。

[反查]
可用拼音和筆畫兩種方案反查三拼編碼。

  ]]},
  {"特色功能", [[
[四類編碼]
除漢字外可輸入四類漢字編碼：
 - 全拼（無聲調拼音）
   quan pin(wu sheng diao pin yin)
 - 帶調拼音
   dài diào pīn yīn
 - 漢語注音符號
   ㄏㄢˋ ㄩˇ ㄓㄨˋ ㄧㄣˉ ㄈㄨˊ ㄏㄠˋ
 - 國語羅馬字
   gwo yeu luo maa zyh(Gwoyeu Romatzyh)
點選Enter鍵輸入漢字編碼，在選單欄中切換編碼形式。

[尖音輸入]
方言中有尖音的朋友可打尖音字以降低重碼率，
例如，ㄗ開頭的尖音音節以“ㄅ+第3、4區韻母”（ㄅㄨ除外）輸入，例如：尖ㄗㄧㄢˉ=ㄅㄨㄢˉ，絕ㄗㄩㄝˊ=ㄅㄩㄝˊ；
同理，ㄘ開頭的尖音音節以“ㄆ+第3、4區韻母”（ㄆㄨ除外）輸入，ㄙ開頭的尖音音節以“ㄇ+第3、4區韻母”（ㄇㄨ除外）輸入。

尖音字可打尖可打團，而團音字只能打團音，例如尖音字“尖”可打ㄗㄧㄢˉ或ㄐㄧㄢˉ，而團音字“間”只能打ㄐㄧㄢˉ才有。

  ]]},
  {"鍵盤操作", [[
空格(Space)：候選漢字
回車(Enter)：上屏碼
上滑G鍵：提示碼
上滑B鍵：輸入碼

上滑空格鍵：切換中英文
上滑退格鍵：清屏（重輸）/收起鍵盤
左滑退格鍵：刪音節
下滑退格鍵：Delete

左滑空格鍵：撤銷
右滑空格鍵：重做

下滑反查鍵：刪詞
下滑幫助鍵：雙手/單手模式
下滑問號鍵：顯示/隱藏助記

上滑E鍵：移動到文首
上滑R鍵：移動到文尾
上滑D鍵：移動到行首
上滑F鍵：移動到行尾
上滑向左鍵：向左移動音節
上滑向右鍵：向右移動音節

左滑Enter鍵/右滑中英鍵：Enter
左滑逗號鍵/右滑符號鍵：全選

上滑Z鍵：全選
上滑X鍵：剪下
上滑C鍵：複製
上滑V鍵：貼上

長按V鍵：開啟功能鍵，例如剪下板和短語等

  ]]},
  {"更多介紹", [[
==== 更多介紹 ====
 [b站影片]
 [知乎專欄]
 [網盤下載]
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
