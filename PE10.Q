DimEnv PVZ
PVZ = Plugin.Window.MousePoint()

DimEnv scene
scene = "PE"

paoList = Array(Array(3,1), Array(4,1), Array(3,3), Array(4,3), Array(1,5), Array(2,5), Array(3,5), Array(4,5), Array(5,5), Array(6,5))
paoNum = UBound(paoList) + 1
nowPao = 0

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

Sub LetsRock()
    SaveMousePos
    Call Plugin.Bkgnd.MoveTo(PVZ, 234, 567)
    Delay 200
    Call Plugin.Bkgnd.LeftDown(PVZ, 234, 567)
    Delay 100
    Call Plugin.Bkgnd.LeftUp(PVZ, 234, 567)
    RestoreMousePos
End Sub

Sub Card(n)
    Call Left_Click(50 + 51 * n, 42)
End Sub

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

Sub CountDown(t)
    i = 600
    While (i - t > 0)
        Delay 4
        i = Plugin.Memory.Read32Bit(PVZ, &H6a9ec0)
        i = Plugin.Memory.Read32Bit(PVZ, i + &H768)
        i = Plugin.Memory.Read32Bit(PVZ, i + &H559c)
    Wend
End Sub
