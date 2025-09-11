# 三码拼音方案

配方： ℞ arsenali/rime-triple-pinyin

[Rime](https://rime.im/) 大致按“声、韵、调”的顺序三码输入一个带调音节，15键内无重音

## 安装

[东风破](https://github.com/rime/plum) 安装口令： <code> bash rime-install arsenali/rime-triple-pinyin-lssp </code>

本方案词库依赖于 [地球拼音](https://github.com/rime/rime-terra-pinyin) ℞ rime-terra-pinyin，方案已内置。

皮肤（主题）文件依赖于 [同文安卓輸入法平臺](https://github.com/osfans/trime) ℞ trime，方案已内置。


## 简介

三码拼音是为方便在触屏手机上快速、准确地打字而设计的，方案设计原则包括：
1. 键数要少（只使用15个按键），方便单手打字；
2. 避免像九宫键一样的重复音节，以实现准确输入；
3. 为准确输入，编码包括声调（也可使用无声调模式）；
4. 易学易用。


### 键位图

![3x5键盘布局](https://github.com/user-attachments/assets/8851417a-2aaf-4af4-a77a-d3faa268a03c)
*△3x5键盘布局*

![4x4键盘布局](https://github.com/user-attachments/assets/f0a97141-0cdc-4b90-99a4-1ef14d917595)
*△4x4键盘布局*

_截图使用的是 光明·黑暗 乱主题 艳彩配色_

键盘布局有3x5两类和4x4两种，3x5布局的第5列即4x4布局的第4行，4x4布局的第4行把2、3键合并，以使用4x4布局为主。键盘显示中的´表示零声母。

<br>

### 编码规则

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


39个韵母合并在15键上，分布规律是：

1. aoe开头的韵母（除了er）（第1类）在第1行，
2. i开头的韵母（第2类）在第2行，
3. u开头的韵母（第3类）在第3行，
4. ü开头的韵母（以及er）（第4类）在第4行。

通过前两码声韵组合消除共键声母，规则包括：
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

在第二码中，把相似的韵母安排在同一个键位上，每个键位上都有3个韵母，共键韵母将在第三码中进行去重。

- **第三码：去重码&声调**

以3x5键盘为例，第三码分布规律是：
1. 韵母去重：第二码中的三个共键韵母按照韵尾的不同分布在1-3行上，以消除重复音节；
2. 声调：用1-5列分别输入1-4声和轻声。

以第一组韵母为例，第三码键位是：

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

如果不想区分声调，可长按或上滑T键切换为无声调模式，此时可用第三码的第5列输入无声调拼音。

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

### &#8627; Stargazers
[![Stargazers repo roster for @arsenali/rime-triple-pinyin-lssp](https://reporoster.com/stars/arsenali/rime-triple-pinyin-lssp)](https://github.com/arsenali/rime-triple-pinyin/stargazers)

### &#8627; Forkers
[![Forkers repo roster for @arsenali/rime-triple-pinyin-lssp](https://reporoster.com/forks/arsenali/rime-triple-pinyin-lssp)](https://github.com/arsenali/rime-triple-pinyin/network/members)
