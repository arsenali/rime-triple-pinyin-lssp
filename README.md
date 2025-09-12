# 李氏三拼方案

## 简介

李氏三拼是为在触屏手机上方便、快速、准确的打字而设计的一种汉字输入方案，其特点包括：

1. 键数少，只使用15个按键，方便单手打字
2. 编码短，三码输入一个带调音节
3. 没有重复音节
4. 为准确输入，编码包括声调，但亦有无声调模式

李氏三拼是纯音码方案，但也可用笔画筛选。

## 安装

详见

[安卓版和windows版](https://github.com/arsenali/rime-triple-pinyin-lssp/wiki/安卓版和windows版)

[苹果版](https://github.com/arsenali/rime-triple-pinyin-lssp/wiki/苹果版)

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

键盘布局有3x5两类和4x4两种，3x5布局的第5列即4x4布局的第4行，4x4布局的第4行把2、3键合并，构成十六宫格键盘。4x4键盘较为顺手，平时可以使用4x4布局为主。

键盘显示中的´表示零声母。

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

主题文件中自带简单教程，可点击“帮助”查看。

点击“反查”可使用拼音或笔画进行编码反查。

默认只载入地球拼音词库，加载“八股文”语言模型，如需使用万象等词库需自行下载并在词库列表文件terra_pinyin.extended.dict.yaml中启用。

下载地址：http://www.lssp.ysepan.com/

QQ群：[150478288](https://jq.qq.com/?_wv=1027&k=5wf1uTQ)


<br>

## 收藏和克隆

### &#8627; Stargazers
[![Stargazers repo roster for @arsenali/rime-triple-pinyin-lssp](https://reporoster.com/stars/arsenali/rime-triple-pinyin-lssp)](https://github.com/arsenali/rime-triple-pinyin/stargazers)

### &#8627; Forkers
[![Forkers repo roster for @arsenali/rime-triple-pinyin-lssp](https://reporoster.com/forks/arsenali/rime-triple-pinyin-lssp)](https://github.com/arsenali/rime-triple-pinyin/network/members)
