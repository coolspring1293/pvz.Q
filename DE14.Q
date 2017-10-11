DimEnv PVZ
PVZ = Plugin.Window.MousePoint()

DimEnv scene
scene = "DE"

paoList = Array(_
    Array(1,1), Array(2,1), Array(4,1), Array(5,1), _
    Array(1,5), Array(2,5), Array(3,5), Array(4,5), Array(5,5), _
    Array(1,7), Array(2,7), Array(3,7), Array(4,7), Array(5,7))
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
    Delay 200
    Call Left_Click(320, 400)
    Delay 4000
    Call Wave()
End Sub

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

Sub PreJudge(wave)
    If wave = 20 Then
        Call CountDown(4)
        Delay 7200 + 40 - 550
    Elseif wave = 10 Then
        Call CountDown(4)
        Delay 7200 + 40 - 550
    Else
        Call CountDown(95)
    End If
End Sub

Sub A(r, c)
    Call Card(4)
    Call Pnt(r, c)
End Sub

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
