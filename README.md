# 李氏三拼方案

## 简介

李氏三拼是为在触屏手机上方便、快速、准确的打字而设计的一种汉字输入方案，其特点包括：

1. 键数少，按键大，只使用15个按键，方便单手打字
2. 编码短，三码输入一个带调音节
3. 没有重复音节
4. 为准确输入，编码包括声调，但亦有无声调模式

李氏三拼是纯音码方案，但也可用笔画筛选。

QQ群：[150478288](https://jq.qq.com/?_wv=1027&k=5wf1uTQ)

## 下载与安装

方案所需全部文件已打包，可在[网盘](http://www.lssp.ysepan.com/)下载补丁包直接导入。

安装方法详见：

[安卓版和windows版](https://github.com/arsenali/rime-triple-pinyin-lssp/wiki/安卓版和windows版)

[苹果版](https://github.com/arsenali/rime-triple-pinyin-lssp/wiki/苹果版)

本仓库未列出依赖方案和文件，包括：

- 词库文件和语言模型，详见：【[说明](https://github.com/arsenali/rime-triple-pinyin-lssp#说明)】
- 反查依赖方案：[袖珍简化字拼音](https://github.com/rime/rime-pinyin-simp)，[五笔画](https://github.com/rime/rime-stroke)
- [简化字八股文](https://github.com/rime/rime-essay-simp)
- [尖音字库](https://github.com/arsenali/zianyinzi)
- 其他：grammar.yaml: [小狼毫](https://github.com/rime/weasel)输入法内置；trime.yaml: [同文](https://github.com/osfans/trime)/[中文](https://github.com/nirenr/trime2)输入法内置

<br>

## 键位图

<div align="normal">
  <img src="https://github.com/user-attachments/assets/8851417a-2aaf-4af4-a77a-d3faa268a03c" 
       alt="3x5键盘布局" 
       width="50%"
       style="border: 1px solid #eee; 
              border-radius: 12px;
              box-shadow: 0 4px 12px rgba(0,0,0,0.15);
              margin: 20px 0;">
 <i> <p style="color: #666; font-style: italic; margin-top: 12px;">
    △3x5键盘布局
  </p></i>
</div>

<div align="normal">
  <img src="https://github.com/user-attachments/assets/f0a97141-0cdc-4b90-99a4-1ef14d917595" 
       alt="4x4键盘布局" 
       width="50%"
       style="border: 1px solid #eee; 
              border-radius: 12px;
              box-shadow: 0 4px 12px rgba(0,0,0,0.15);
              margin: 20px 0;">
 <i> <p style="color: #666; font-style: italic; margin-top: 12px;">
    △4x4键盘布局
  </p></i>
</div>

_截图使用的是“光明·黑暗 乱”主题，“艳彩”配色_

键盘布局有3x5和4x4两种，3x5布局的第5列即4x4布局的第4行，4x4布局的第4行把2、3键合并，构成十六宫格键盘。4x4键盘较为顺手，平时在手机上可以使用4x4布局为主，3x5布局主要是为兼容实体键盘，在windows电脑的实体键盘上可用左手15键（q-b）使用本方案，不过没必要，实体键盘上几乎不会使用单手输入，本方案主要还是用于手机打字。

键盘显示中用´表示零声母。

<br>

## 编码规则

编码方式为“声母+韵母+去重码&声调”，编码规则是：

- **第一码：声母**

<table>
   <tr>
    <td></td>
    <td align="center"><strong>1列</strong></td>
    <td align="center"><strong>2列</strong></td>
    <td align="center"><strong>3列</strong></td>
    <td align="center"><strong>4列</strong></td>
  </tr>
   <tr>
    <td align="center"><strong>1行</strong></td>
    <td align="center">b</td>
    <td align="center">p</td>
    <td align="center">m</td>
    <td align="center">r f</td>
  </tr>
  <tr>
    <td align="center"><strong>2行</strong></td>
    <td align="center">d</td>
    <td align="center">t</td>
    <td align="center">n</td>
    <td align="center">l</td>
  </tr>
  <tr>
    <td align="center"><strong>3行</strong></td>
    <td align="center">g j</td>
    <td align="center">k q</td>
    <td align="center">h x</td>
    <td align="center">零yw</td>
  </tr>
 <tr>
    <td align="center"><strong>4行</strong></td>
    <td align="center">zh z</td>
    <td align="center" colspan="2">ch c</td>
    <td align="center">sh s</td>
 </tr>
</table>

23个声母合并在15键上，基本按照声母表顺序排列，方便记忆。其中部分声母共键，共键声母将在第二码去重。

- **第二码：韵母**

<table>
   <tr>
    <td></td>
    <td align="center"><strong>1列</strong></td>
    <td align="center"><strong>2列</strong></td>
    <td align="center"><strong>3列</strong></td>
    <td align="center"><strong>4列</strong></td>
  </tr>
   <tr>
    <td align="center"><strong>1行</strong></td>
    <td align="center">a,an,ang</td>
    <td align="center">ai,ei,ao</td>
    <td align="center">o,ou,ong</td>
    <td align="center">e,en,eng</td>
  </tr>
  <tr>
    <td align="center"><strong>2行</strong></td>
    <td align="center">ia,ian,iang</td>
    <td align="center">iai,i,iao</td>
    <td align="center">io,iu,iong</td>
    <td align="center">ie,in,ing</td>
  </tr>
  <tr>
    <td align="center"><strong>3行</strong></td>
    <td align="center">ua,uan,uang</td>
    <td align="center">uai,ui,_</td>
    <td align="center">uo,_,u</td>
    <td align="center">_,un,ueng</td>
  </tr>
 <tr>
    <td align="center"><strong>4行</strong></td>
    <td align="center">er,üan,_</td>
    <td align="center" colspan="2">_,_,ü</td>
    <td align="center">üe,ün,_</td>
 </tr>
</table>

39个韵母合并在15键上，一是根据汉语拼音韵母表顺序先后排列，二是按照韵头及韵尾进行同类合并，具体为：

1. aoe开头的韵母（除了er）（第1类）在第1行
2. i开头的韵母（第2类）在第2行
3. u开头的韵母（第3类）在第3行
4. ü开头的韵母（以及er）（第4类）在第4行

通过前两码声韵组合消除共键声母，去重原理见[声母去重原理](https://github.com/arsenali/rime-triple-pinyin-lssp/wiki#声母去重原理)。

通过前两码组合，共键声母全部得以区分。

在第二码中，把相似的韵母安排在同一个键位上，每个键位上都有3个韵母，共键韵母将在第三码中进行去重。

- **第三码：去重码&声调**

以第一组韵母为例，3x5键盘上第三码键位（4x4键盘做相应变化）是：

<table>
   <tr>
    <td></td>
    <td align="center"><strong>1列</strong></td>
    <td align="center"><strong>2列</strong></td>
    <td align="center"><strong>3列</strong></td>
    <td align="center"><strong>4列</strong></td>
    <td align="center"><strong>5列</strong></td>
  </tr>
   <tr>
    <td align="center"><strong>1行</strong></td>
    <td align="center">ā</td>
    <td align="center">á</td>
    <td align="center">ǎ</td>
    <td align="center">à</td>
    <td align="center">ȧ</td>
  </tr>
  <tr>
    <td align="center"><strong>2行</strong></td>
    <td align="center">ān</td>
    <td align="center">án</td>
    <td align="center">ǎn</td>
    <td align="center">àn</td>
    <td align="center">ȧn</td>
  </tr>
  <tr>
    <td align="center"><strong>3行</strong></td>
    <td align="center">āng</td>
    <td align="center">áng</td>
    <td align="center">ǎng</td>
    <td align="center">àng</td>
    <td align="center">ȧng</td>
  </tr>
</table>

在输入第三码之后便得到了唯一的一个带调拼音音节，不会有重复音节。

如果不想区分声调，可使用无声调模式，此时可用第5列输入无声调拼音。

<br>

初学者可使用动态键盘主题，方便熟悉键位，但只能打三码全码；熟练后可使用静态键盘主题，静态键盘可使用首码简拼和前两码简拼，打前两码简拼类似于普通的有重音的双拼，第三码相当于直接辅助码。

另外，还可使用笔画码筛选去重，类似于搜狗拼音，笔画码相当于间接辅助码。


---

## 说明

主题文件中自带简单教程，可点击“帮助”查看。

点击“反查”可使用拼音或笔画进行编码反查。

### 词库

本方案使用带调拼音词库，默认加载[万象词库](https://github.com/amzxyz/rime-wanxiang)，其他带调拼音词库还有：
  - [薄荷拼音词库](https://github.com/Mintimate/oh-my-rime)，基于[万象拼音词库](https://github.com/amzxyz/rime-wanxiang)，略有调整
  - [冰雪拼音词库](https://github.com/rimeinn/rime-snow-pinyin)，基于[雾凇拼音词库](https://github.com/iDvel/rime-ice)，添加声调
  - [地球拼音词库](https://github.com/rime/rime-terra-pinyin)，繁体词库，台湾发音标准

可自行选用，在triple_pinyin.dict.yaml中调整词库。

### 语言模型

默认加载[万象语言模型](https://github.com/amzxyz/RIME-LMDG)，其他可用的语言模型还有：
- [墨奇语言模型](https://github.com/gaboolic/rime-build-grammar)，[白霜拼音词库](https://github.com/gaboolic/rime-frost)配套语言模型
- [八股文语言模型](https://github.com/lotem/rime-octagram-data)，Rime预设词汇表（[八股文](https://github.com/rime/rime-essay)、[朙月拼音](https://github.com/rime/rime-luna-pinyin)、[地球拼音](https://github.com/rime/rime-terra-pinyin)等）配套语言模型，繁体模型

可自行选用，在grammar.custom.yaml中选用模型。

另外可参考[Rime Octagram 語言模型](https://github.com/rimeinn/octagram-data)。

### 语流音变（连读变调现象）

带调方案涉及到汉语语流音变现象，包括：
1. “一”、“不”二字，各词库设定为：
   - 万象/薄荷/地球拼音词库：“一”变调，如：一个`yí gè`，一起`yì qǐ`；“不”变调，如：不要`bú yào`，不行`bù xíng`
   - 冰雪词库：“一”统一用一声，如：一个`yī gè`，一起`yī qǐ`；“不”统一用四声，如：不要`bù yào`，不行`bù xíng`
 
   为简单起见，本方案建议“一”、“不”二字统一都用一声，如：一个`yī gè`，一起`yī qǐ`；不要`bū yào`，不行`bū xíng`。
2. 普通话中两个三声字连读时，前一个字变为二声，例如：你好`ní hǎo`，水果`shuí guǒ`，但在输入时仍打三声，即：你好`nǐ hǎo`，水果`shuǐ guǒ`。
3. 部分方言的音变现象，例如：地上一`yí`个猴，树上七`qí`个猴，一共八`bá`个猴，输入时仍按原声调输入，即：地上一`yī`个猴，树上七`qī`个猴，一共八`bā`个猴；再如：别说话`biè shuō huà`，输入时应打`bié shuō huà`。

<br>



## 扩展方案

“李氏三拼”不是一个方案，而是一类方案的集合，它的关键在于三拼原理和逻辑，而三拼的首码、次码键位都可以任意排列，根据三拼原理可以设计数量众多的扩展方案，例如按照大千注音键位排列可变化出[李氏注音方案](https://github.com/arsenali/rime-triple-pinyin-bopomofo)。

李氏三拼因其键位少、码长短、输入准的特点，恰当的满足了移动互联网时代的打字需求，非常适合于作为移动设备的输入方案。

本方案配置文件和所用到的lua插件均已做模块化处理，逻辑清晰，语法规范，方便理解和修改调试，欢迎魔改。
