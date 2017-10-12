
# 如何为植物大战僵尸编写按键精灵脚本

这是一份入门级的按键精灵半自动化脚本编写教程. 

地址 https://github.com/lmintlcx/pvz.Q

游戏以窗口化运行, 分辨率为800x600. 

以鼠标位置来获取游戏句柄, 所以开启脚本的时候鼠标要放在游戏窗口上. 

变量类型为环境变量(DimEnv), 以便在子线程中使用. 

```
DimEnv PVZ
PVZ = Plugin.Window.MousePoint()
```

定义`CountDown(t)`函数, 指定操作在刷新前多久进行, 时间单位cs. 

通过读取内存地址`[[[6A9EC0] +768] +559C]`来获得"下一波僵尸刷新时间". 

```
Sub CountDown(t)
    i = 600
    While (i - t > 0)
        Delay 4
        i = Plugin.Memory.Read32Bit(PVZ, &H6a9ec0)
        i = Plugin.Memory.Read32Bit(PVZ, i + &H768)
        i = Plugin.Memory.Read32Bit(PVZ, i + &H559c)
    Wend
End Sub
```

定义几个基础的鼠标点击函数. 

以下参数中, PVZ为已获得的游戏窗口句柄, x为横坐标, y为纵坐标, 坐标单位像素(px). 左上角坐标(0, 0), 右下角(799, 599). 

`Left_Click(x, y)` 左键单击点(x, y)

`Right_Click(x, y)` 右键单击点(x, y)

`Move_Left_Click(x, y)` 鼠标先移动到坐标(x, y), 左键单击完毕后再移回原位

`Safe_Click()` 右键单击点(60, 50), 安全右键, 用来消除手控键控冲突

```
Sub Left_Click(x, y)
    Call Plugin.Bkgnd.LeftClick(PVZ, x, y)
End Sub

Sub Right_Click(x, y)
    Call Plugin.Bkgnd.RightClick(PVZ, x, y)
End Sub

Sub Move_Left_Click(x, y)
    SaveMousePos
    Call Plugin.Bkgnd.MoveTo(PVZ, x, y)
    Delay 20
    Call Plugin.Bkgnd.LeftClick(PVZ, x, y)
    RestoreMousePos
End Sub

Sub Safe_Click()
    Call Plugin.Bkgnd.RightClick(PVZ, 60, 50)
End Sub
```

在选卡界面选择卡片. 

`ChooseCard(r, c)` 选择r行c列的卡片

`ChooseImitaterCard(r, c)` 选择r行c列的模仿者卡片

以下参数中, (22, 123)为第一张卡片的左上角坐标, (190, 125)为模仿者选卡界面第一张卡片的左上角坐标, 单张卡片宽度约50px高度约70px. 

模仿者需要把鼠标移动到卡片上面才能选中, 延迟0.2s等待界面出现. 

每次选完卡均等待0.2s. (没有为什么)

```
Sub ChooseCard(r, c)
    x = 22 + 50/2 + (c - 1) * 53
    y = 123 + 70/2 + (r - 1) * 70
    Call Left_Click(x, y)
    Delay 200
End Sub

Sub ChooseImitaterCard(r, c)
    Call Move_Left_Click(490, 550)
    x = 190 + 50/2 + (c - 1) * 51
    y = 125 + 70/2 + (r - 1) * 71
    Delay 200
    Call Left_Click(x, y)
    Delay 200
End Sub
```

点击`Let's Rock`按钮. 

```
Sub LetsRock()
    SaveMousePos
    Call Plugin.Bkgnd.MoveTo(PVZ, 234, 567)
    Delay 200
    Call Plugin.Bkgnd.LeftDown(PVZ, 234, 567)
    Delay 100
    Call Plugin.Bkgnd.LeftUp(PVZ, 234, 567)
    RestoreMousePos
End Sub
```

定义函数`Card(n)`, (在10格卡槽的情况下)点击卡槽中的第n张卡片. 点铲子可以用`Card(12)`. 

```
Sub Card(n)
    Call Left_Click(50 + 51 * n, 42)
End Sub
```

定义函数`Pnt(r, c)`, 点击地图上的r路c列. 

需要事先声明场地`scene`, 可选值"DE""NE""PE""FE""RE""ME". 

```
DimEnv scene
scene = "PE"

Sub Pnt(r, c)
    If scene = "DE" Or scene = "NE" Then
        Call Left_Click(80 * c, 30 + 100 * r)
    Elseif scene = "PE" Or scene = "FE" Then
        Call Left_Click(80 * c, 30 + 85 * r)
    Elseif scene = "RE" Or scene = "ME" Then
        If c > 5 Then
            Call Left_Click(80 * c, 85 * r)
        Else
            Call Left_Click(80 * c, 85 * r + (120 - 20 * c))
        End If
    End If
End Sub
```

定义函数`Pao(r, c)`, 按顺序选择一门炮发射, 落点为地图上的r路c列. 

使用Array函数来合成数组`paoList`, 记录场地上每门炮的位置, 其中每个数组元素又是一个数组, 分别为该门炮所在的行数和列数. 

`paoNum` 的值为场地上的玉米炮数量. `UBound(paoList)`获取的是数组最大下标, 由于数组下标是从0开始计数的, 玉米炮总数等于该值加上一. 

`nowPao` 变量用来记录当前执行`Pao(r, c)`的时候使用的炮位序号, 从0开始计数(即第一门炮), 每次发炮后该值加一, 为避免溢出每次发炮前该值对玉米炮总数取模. 

`paoList` `paoNum` `nowPao` 变量类型均为脚本全局变量. 

每次发炮时, 从当前炮位序号`nowPao`获取该门炮的位置`Point = paoList(nowPao)`, 点击炮的位置`Pnt(Point(0), Point(1))`, 再点击落点`Pnt(r, c)`. 

为了避免点炮时被阳光钱币挡住可以多点几次(这里是3次)炮身再发射, 极短的时间(300ms)内多次点击炮身不会原地发射. 

落点与炮的位置太近的话可能造成射不出去的现象(比如坐标(5,7)的炮落点(5,7)), 调整一下`paoList`的顺序就好了. 

以PE经典十炮为例. 

```
paoList = Array(Array(3,1), Array(4,1), Array(3,3), Array(4,3), Array(1,5), Array(2,5), Array(3,5), Array(4,5), Array(5,5), Array(6,5))
paoNum = UBound(paoList) + 1
nowPao = 0

Sub Pao(r, c)
    nowPao = nowPao Mod paoNum
    Point = paoList(nowPao)
    For 3
        Call Pnt(Point(0), Point(1))
    Next
    Call Pnt(r, c)
    Call Safe_Click()
    nowPao = nowPao + 1
End Sub
```

用按键来正式启动脚本("键控"嘛). 

等待按键操作, 获取`key`值, 如果等于49(键盘上数字1的按键码), 就执行`Main()`函数. 

`Main()`函数内容为: 选卡`ChoosingCard()`, 点击`Let's Rock`, 大概4s后进入游戏场景, 执行`Wave()`函数. 

某些情况下选完卡点`Let's Rock`后会出现警告窗口需要再点击一到多次OK. 

```
key = WaitKey()

If key = 49 Then
    Call Main()
End If

Sub Main()
    Delay 1000
    Call ChoosingCard()
    Delay 500
    Call LetsRock()
    ' Delay 200
    ' Call Left_Click(320, 400)
    Delay 4000
    Call Wave()
End Sub
```

定义`Wave()`函数, 变量`wave`的值循环遍历1-20, 编写针对每一波僵尸的操作. 

分三个部分, 设定预判时间, 主要操作, 设置延时. 

除第20波外每一波的脚本都要运行到本波刷新以后, 通常用的是0.95s和0.55s预判, 所以要延迟0.95s来保证本次脚本执行到本波刷新以后再执行下一个波次的脚本. 

```
Sub Wave()
For wave = 1 To 20 Step 1
    PreJudge(wave)
    ......
    Delay 1000
Next
End Sub
```

`PreJudge(wave)`, 第wave波的预判时间. 

通常使用0.95s, 第10/20波僵尸出生点靠右预判时间延迟到0.55s, 第20波预判1.5s可以炮炸珊瑚. 

大波僵尸(10/20)倒计时规则不同, 不能简单使用`CountDown(t)`来设置预判时间. 

```
Sub PreJudge(wave)
    If wave = 20 Then
        Call CountDown(4)
        Delay 7200 + 40 - 1500
    Elseif wave = 10 Then
        Call CountDown(4)
        Delay 7200 + 40 - 550
    Else
        Call CountDown(95)
    End If
End Sub
```


定义一些可能会用到的子过程, 比如
"在选卡界面选十张卡"
"释放樱桃"
"释放核蘑菇"
"在某行某列释放原版冰"
"在某行某列释放复制冰"
"补坚果/南瓜"
"每50.1s存两个冰"
"点冰"
"中三路种垫材垫MJ"
"铲垫材"
"吹风扇"
"吃墓碑"
等等等等......

这里用到的有:

`ChoosingCard()` 选十张卡

`A(r, c)` 在r路c列释放樱桃

`N(r, c)` 在r路c列释放核蘑菇

```
Sub ChoosingCard()
    Call ChooseCard(2, 7)
    Call ChooseCard(2, 8)
    Call ChooseCard(3, 1)
    Call ChooseCard(5, 4)
    Call ChooseCard(1, 3)
    Call ChooseCard(3, 2)
    Call ChooseCard(4, 4)
    Call ChooseCard(2, 6)
    Call ChooseCard(2, 2)
    Call ChooseCard(2, 1)
End Sub

Sub A(r, c)
    Call Card(5)
    Call Pnt(r, c)
End Sub

Sub N(r, c)
    Call Card(3)
    Call Pnt(r, c)
    Call Card(2)
    Call Pnt(r, c)
    Call Card(4)
    Call Pnt(r, c)
End Sub
```

根据wave值编写针对每一波的操作, 也就是上面`Wave()`中省略的部分. 

在这个例子中, 使用的阵型为PE经典十炮, 节奏为核代P6. 

每一波的操作如下: 

```
1~9 PP PP PP PP PP N PP PP PP
10~19 PPA PP PP PP PP N PP PP PP PP
20 P-PP
```

具体描述一下: 

第1/2/3/4/5/7/8/9/11/12/13/14/16/17/18/19波的操作为预判0.95s往前场射两门炮, 落点(2,9)(5,9). 

第10波的操作为预判0.55s往前场射两门炮, 落点(2,9)(5,9). 并且在(2,9)加个樱桃以消除刷怪延迟. 炮飞行时间3.73s, 樱桃释放后0.98s爆炸, 在(3.73-0.98)s后释放樱桃让樱桃与玉米炮同时生效. 

第20波的操作为预判1.5s炮炸珊瑚, 等待0.95s(等效0.55预判)后再炸前场, 落点(2,9)(5,9). 

第6/15波使用核武代奏. 核弹与玉米炮生效时间相同, 同样在预判过后3.73s. 嗑下咖啡豆到唤醒1.98s, 唤醒到生效1s, 所以要在(3.73-1.98-1)s后释放核蘑菇. 第6波弹坑3-9, 第15波弹坑4-9. 

第9/19波打完炮后还需要额外用炮收尾, 所以要在对应波次的地方把nowPao变量加上额外需要的炮数, 让第10/20波自动选择的炮位相应地延后. 一般第9波打完两炮后还需要至少4门炮(加上冰瓜IO), 第9波打完两炮后还需要2门炮(自然出怪下). 

综上所述, 完整的`Wave()`函数如下: 

```
Sub Wave()
For wave = 1 To 20 Step 1
    PreJudge(wave)
    If wave = 20 Then
        Call Pao(4, 7)
        Delay 950
        Call Pao(2, 9)
        Call Pao(5, 9)
    Elseif wave = 10 Then
        Call Pao(2, 9)
        Call Pao(5, 9)
        Delay 3730 - 980
        Call A(2, 9)
    Elseif wave = 6 Or wave = 15 Then
        Delay 3730 - 1980 - 1000
        If wave = 6 Then
            Call N(3, 9)
        End If
        If wave = 15 Then
            Call N(4, 9)
        End If
    Else
        Call Pao(2, 9)
        Call Pao(5, 9)
        If wave = 9 Then
            nowPao = nowPao + 4
        End If
        If wave = 19 Then
            nowPao = nowPao + 2
        End If
    End If
    Delay 1000
Next
End Sub
```

完整代码 https://github.com/lmintlcx/pvz.Q/blob/master/PE10.Q

示范视频(视频里的代码并不完善)

https://www.bilibili.com/video/av14935767/


再举一个例子. 阵型为DE无冰瓜十四炮. 

声明场地和炮的位置, 代码一行太长写不下的话可以用分行符`_`. 

```
DimEnv scene
scene = "DE"

paoList = Array(_
    Array(1,1), Array(2,1), Array(4,1), Array(5,1), _
    Array(1,5), Array(2,5), Array(3,5), Array(4,5), Array(5,5), _
    Array(1,7), Array(2,7), Array(3,7), Array(4,7), Array(5,7))
```

定义几个会用到的函数. 

`ChoosingCard()` 选十张卡

`A(r, c)` 在r路c列释放樱桃

`DC()` 种垫材

`DelDC()` 铲垫材

```
Sub ChoosingCard()
    Call ChooseCard(5, 4)
    Call ChooseCard(2, 7)
    Call ChooseImitaterCard(2, 7)
    Call ChooseCard(1, 3)
    Call ChooseCard(3, 2)
    Call ChooseCard(4, 7)
    Call ChooseCard(5, 2)
    Call ChooseCard(2, 6)
    Call ChooseCard(2, 2)
    Call ChooseCard(2, 1)
End Sub

Sub A(r, c)
    Call Card(4)
    Call Pnt(r, c)
End Sub

Sub DC()
    Call Card(9)
    Call Pnt(1, 9)
    Call Card(10)
    Call Pnt(2, 9)
End Sub

Sub DelDC()
    Call Card(12)
    Call Pnt(1, 9)
    Call Card(12)
    Call Pnt(2, 9)
End Sub
```

关于存冰的写法. 

存冰过程在单独的子线程里执行, 需要用到函数`Card(n)` `Pnt(r, c)`, 而这两个函数又需要用到变量`PVZ` `scene`, 所以事先将这两个变量声明为环境变量以便在子线程里调用. 

在有足够多的(至少四个)存冰位置的情况下, 每隔50+秒往可用的位置存两个冰, 优先用掉永久位. 

以 [av14880401](https://www.bilibili.com/video/av14880401/) 中的PE前置八炮为例, 

卡槽1为复制冰, 2为原版冰. 永久存冰位3-5 4-5, 临时存冰位1-7 2-7, 存冰函数共有五次循环, 每次存两冰, 优先存原版冰, 优先存放在永久位. 

点冰则是选咖啡豆后往所有的存冰位点一次, 优先用掉临时位. 

存冰线程在进入游戏场景(开场红字消失)后启动. 

```
Sub FillIce()
    For 5
        Delay 100
        Call Card(2)
        Call Pnt(4, 5)
        Call Pnt(3, 5)
        Call Pnt(2, 7)
        Call Pnt(1, 7)
        Call Card(1)
        Call Pnt(4, 5)
        Call Pnt(3, 5)
        Call Pnt(2, 7)
        Call Pnt(1, 7)
        Delay 50000
    Next
End Sub

Sub Ice()
    Call Card(3)
    Call Pnt(1, 7)
    Call Pnt(2, 7)
    Call Pnt(3, 5)
    Call Pnt(4, 5)
End Sub

Sub Main()
    ...
    Call ChoosingCard()
    ...
    Call LetsRock()
    ...
    Call BeginThread(FillIce)
    Call Wave()
End Sub
```

回到某个DE十四炮, 可用的存冰位只有两个. 第一次存冰在第一次点冰2.98s后, 第二次则在18s(半个循环)后. 

所以选择在第一次点冰后执行存冰线程, 内容为"至少2.98s后存原版冰, 18s后存复制冰, (51-18)s后存原版冰, 18s后存复制冰, 重复此过程"

(注意如果用这种方法的话中场第9波需要拖僵尸拖一段时间但是也不要太长)

关键代码如下:

```
Sub FillIce()
    Delay 3500
    Call Card(3)
    Call Pnt(3, 1)
    Delay 18000
    Call Card(2)
    Call Pnt(3, 1)
    For 4
        Delay 51000 - 18000
        Call Card(3)
        Call Pnt(3, 1)
        Call Pnt(3, 2)
        Delay 18000
        Call Card(2)
        Call Pnt(3, 1)
        Call Pnt(3, 2)
    Next
End Sub

Sub Ice()
    Call Card(1)
    Call Pnt(3, 1)
    Call Pnt(3, 2)
End Sub

Sub Wave()
For wave = 1 To 20 Step 1
    PreJudge(wave)
    If wave = 1 Then
        ...
        Call Ice()
        If wave = 1 Then
            Call BeginThread(FillIce)
        End If
    Elseif ... Then
        ...
    End If
    Delay 1000
Next
End Sub
```


运行节奏为ch6 |PPDC|IPP-PP|PPDC|IPP-PP|


第1波PPDC, 刷新前0.95s两门预判炮PP, 之后接延迟炮D炸下半场, 作用是收撑杆并补刀红眼. 

根据撸炮帖数据在刷新前0.15s之后发炮可全收撑杆, 即预判之后0.8s. 

由于从点下咖啡豆到寒冰菇生效的时间较长, 第2波的预判冰点冰的操作放在第1波进行. 同样垫本波撑杆的操作写在下一波. 

本波波长6s, 本波操作在刷新前0.95s进行, D操作之前中途累计延时0.8s, 寒冰菇从点下咖啡豆到生效2.98s(唤醒1.98s+生效1s). 

采用0.3s预判冰, 即下一波在刷新后0.3s被冻住. 计算可知在D操作之后(6+0.95-0.8-2.98+0.3)s点下咖啡豆即可实现. 

注意到第10波的预判时间是55cs而不是95cs, 对应第10波的代码`Delay 6000+950-800-2980+300`要改成`Delay 6000+550-800-2980+300`. 

以及上面提到的, 在第一次点冰操作后启动存冰线程`Call BeginThread(FillIce)`. 

第2波僵尸刷新即被冻住, 首先是两门热过渡炮处理掉矿工冰车. 落点可以左移. 放置垫材垫撑杆然后铲掉. 

垫撑杆要在炮发射至少0.81s之后, 以免撑杆啃超前置炮. 

另外为了避免放置垫材时间太晚撑杆跳炮, 热过渡炮时机可以适当提前, 这里为了方便仍然使用0.95s预判. 

本波波长是由激活炮的时机决定的, 波长12s, 预判0.95s, 铲垫材操作之前累计延时(0.82+1)s, 玉米炮发射后3.73s生效, 激活到下一波刷出2s. 

计算得知在铲垫材操作之后(12+0.95-0.82-1-3.73-2)s发射激活炮PP即可. 

第20波八炮齐发秒杀红眼, 视情况炮炸珊瑚/冰消珊瑚/冰杀小偷/炮炸小偷, 留下一只普僵拖时间. 

第9/19波额外留出一定的炮数手动收尾并给nowPao变量加上对应的炮数(也可以算好时间自动发炮来收尾). 

另外就是给每一波加个延时保证能运行到本波刷新时间点以后, 这里仍然为了方便统一用+①s. 

综上所述, 完整的`Wave()`函数如下: 

```
Sub Wave()
For wave = 1 To 20 Step 1
    PreJudge(wave)
    If wave = 1 Or wave = 3 Or wave = 5 Or wave = 7 Or wave = 9 Or wave = 10 Or wave = 12 Or wave = 14 Or wave = 16 Or wave = 18 Then
        Call Pao(2, 9)
        Call Pao(4, 9)
        Delay 800
        Call Pao(4, 9)
        If wave = 10 Then
            Delay 6000 + 550 - 800 - 2980 + 300
        Else
            Delay 6000 + 950 - 800 - 2980 + 300
        End If
        Call Ice()
        If wave = 1 Then
            Call BeginThread(FillIce)
        End If
        If wave = 9 Then
            Delay 2980 - 300 - 950
            Call Pao(2, 8.4)
            Delay 820
            Call DC()
            Delay 1000
            Call DelDC()
            nowPao = nowPao + 6
        End If
    Elseif wave = 2 Or wave = 4 Or wave = 6 Or wave = 8 Or wave = 11 Or wave = 13 Or wave = 15 Or wave = 17 Or wave = 19 Then
        Call Pao(2, 8.4)
        Call Pao(4, 8.4)
        Delay 820
        Call DC()
        Delay 1000
        Call DelDC()
        Delay 12000 + 950 - 1000 - 820 - 3730 - 2000
        Call Pao(2, 9)
        Call Pao(4, 9)
        If wave = 19 Then
            nowPao = nowPao + 6
        End If
    Elseif wave = 20 Then
        Call Pao(2, 9)
        Call Pao(4, 9)
        Delay 300
        Call Pao(2, 9)
        Call Pao(4, 9)
        Delay 300
        Call Pao(2, 9)
        Call Pao(4, 9)
        Delay 300
        Call Pao(2, 9)
        Call Pao(4, 9)
        Delay 1500
        Call Ice()
    End If
    Delay 1000
Next
End Sub
```

完整代码 https://github.com/lmintlcx/pvz.Q/blob/master/DE14.Q

示范视频 https://www.bilibili.com/video/av15267003/
