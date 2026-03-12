Option Explicit
Sub ActualizarAno()
    Dim nuevoAno As Integer
    Dim hojaMensual As Worksheet
    Dim meses() As String

    nuevoAno = InputBox("Introduce el año para el cuadrante:", "Actualizar Año", Year(Date))
    If nuevoAno = 0 Then Exit Sub

    meses = Split("ENE,FEB,MAR,ABR,MAY,JUN,JUL,AGO,SEP,OCT,NOV,DIC", ",")

    Dim i As Integer
    For i = 0 To UBound(meses)
        On Error Resume Next
        Set hojaMensual = ThisWorkbook.Sheets(meses(i))
        On Error GoTo 0
        If Not hojaMensual Is Nothing Then
            hojaMensual.Range("AF6").Value = nuevoAno
        End If
        Set hojaMensual = Nothing
    Next i

    On Error Resume Next
    ThisWorkbook.Sheets("Días trabajados").Range("AB1").Value = nuevoAno
    On Error GoTo 0

    MsgBox "Año actualizado a " & nuevoAno & " correctamente.", vbInformation, "Listo"
End Sub
Sub ResaltarFestivos()
    Dim ws As Worksheet
    Dim wsFestivos As Worksheet
    Dim fechaFestivo As Date
    Dim colFecha As Integer
    Dim ultimaCol As Integer
    Dim meses() As String
    Dim i As Integer

    Application.ScreenUpdating = False
    Application.Calculation = xlCalculationManual

    Set wsFestivos = ThisWorkbook.Sheets("Festivos")
    meses = Split("ENE,FEB,MAR,ABR,MAY,JUN,JUL,AGO,SEP,OCT,NOV,DIC", ",")

    For i = 0 To UBound(meses)
        On Error Resume Next
        Set ws = ThisWorkbook.Sheets(meses(i))
        On Error GoTo 0
        If ws Is Nothing Then GoTo SiguienteMes

        ultimaCol = 33

        For colFecha = 3 To ultimaCol
            Dim celdaFecha As Range
            Set celdaFecha = ws.Cells(11, colFecha)

            If IsDate(celdaFecha.Value) Then
                fechaFestivo = CDate(celdaFecha.Value)

                Dim esFestivo As Boolean
                esFestivo = False

                Dim filaF As Integer
                For filaF = 2 To 18
                    If IsDate(wsFestivos.Cells(filaF, 2).Value) Then
                        If CDate(wsFestivos.Cells(filaF, 2).Value) = fechaFestivo Then
                            esFestivo = True
                            Exit For
                        End If
                    End If
                Next filaF

                If esFestivo Then
                    ws.Range(ws.Cells(10, colFecha), ws.Cells(52, colFecha)) _
                        .Interior.Color = RGB(255, 199, 206)
                Else
                    ws.Range(ws.Cells(10, colFecha), ws.Cells(52, colFecha)) _
                        .Interior.ColorIndex = xlNone
                End If
            End If
        Next colFecha

SiguienteMes:
        Set ws = Nothing
    Next i

    Application.Calculation = xlCalculationAutomatic
    Application.ScreenUpdating = True

    MsgBox "Festivos resaltados correctamente.", vbInformation, "Listo"
End Sub
Sub ExportarInformeMensual()
    Dim nombreMes As String
    Dim ws As Worksheet
    Dim rutaGuardado As String
    Dim nombreArchivo As String

    nombreMes = InputBox("Escribe el mes a exportar (ENE, FEB, MAR...):", "Exportar Informe", "ENE")
    If nombreMes = "" Then Exit Sub

    nombreMes = UCase(Trim(nombreMes))

    On Error Resume Next
    Set ws = ThisWorkbook.Sheets(nombreMes)
    On Error GoTo 0

    If ws Is Nothing Then
        MsgBox "No existe la hoja '" & nombreMes & "'.", vbExclamation, "Error"
        Exit Sub
    End If

    Dim anoActual As Integer
    anoActual = ThisWorkbook.Sheets("ENE").Range("AF6").Value
    nombreArchivo = "Cuadrante_" & nombreMes & "_" & anoActual & ".pdf"
    rutaGuardado = ThisWorkbook.Path & "\" & nombreArchivo

    ws.ExportAsFixedFormat _
        Type:=xlTypePDF, _
        Filename:=rutaGuardado, _
        Quality:=xlQualityStandard, _
        IncludeDocProperties:=False, _
        IgnorePrintAreas:=False, _
        OpenAfterPublish:=True

    MsgBox "PDF guardado en:" & Chr(10) & rutaGuardado, vbInformation, "Exportación completada"
End Sub
Sub GenerarResumenHoras()
    Dim wsEmpleados As Worksheet
    Dim wsResumen As Worksheet
    Dim ultimaFila As Integer
    Dim fila As Integer
    Dim filaResumen As Integer

    Application.ScreenUpdating = False

    Set wsEmpleados = ThisWorkbook.Sheets("Empleados")

    On Error Resume Next
    Application.DisplayAlerts = False
    ThisWorkbook.Sheets("RESUMEN_HORAS").Delete
    Application.DisplayAlerts = True
    On Error GoTo 0

    Set wsResumen = ThisWorkbook.Sheets.Add(After:=ThisWorkbook.Sheets(ThisWorkbook.Sheets.Count))
    wsResumen.Name = "RESUMEN_HORAS"

    With wsResumen
        .Range("A1").Value = "RESUMEN DE HORAS POR EMPLEADO"
        .Range("A1").Font.Bold = True
        .Range("A1").Font.Size = 14
        .Range("A1").Font.Color = RGB(31, 73, 125)

        .Range("A3").Value = "EMPLEADO"
        .Range("B3").Value = "H. CONTRATO ANUAL"
        .Range("C3").Value = "H. CUADRANTE TOTAL"
        .Range("D3").Value = "DIFERENCIA"
        .Range("E3").Value = "ESTADO"

        With .Range("A3:E3")
            .Font.Bold = True
            .Font.Color = RGB(255, 255, 255)
            .Interior.Color = RGB(46, 117, 182)
        End With
    End With

    ultimaFila = wsEmpleados.Cells(wsEmpleados.Rows.Count, "A").End(xlUp).Row
    filaResumen = 4

    For fila = 2 To ultimaFila
        If wsEmpleados.Cells(fila, 1).Value <> "" Then

            Dim nombreEmpleado As String
            Dim hContrato As Double
            Dim hCuadrante As Double
            Dim diferencia As Double

            nombreEmpleado = wsEmpleados.Cells(fila, 1).Value
            hContrato = 0
            If IsNumeric(wsEmpleados.Cells(fila, 14).Value) Then
                hContrato = wsEmpleados.Cells(fila, 14).Value
            End If
            hCuadrante = 0
            If IsNumeric(wsEmpleados.Cells(fila, 65).Value) Then
                hCuadrante = wsEmpleados.Cells(fila, 65).Value
            End If

            diferencia = hCuadrante - hContrato

            With wsResumen
                .Cells(filaResumen, 1).Value = nombreEmpleado
                .Cells(filaResumen, 2).Value = hContrato
                .Cells(filaResumen, 3).Value = hCuadrante
                .Cells(filaResumen, 4).Value = diferencia

                If Abs(diferencia) <= 5 Then
                    .Cells(filaResumen, 5).Value = "OK"
                    .Cells(filaResumen, 4).Font.Color = RGB(0, 128, 0)
                ElseIf diferencia > 5 Then
                    .Cells(filaResumen, 5).Value = "EXCESO HORAS"
                    .Cells(filaResumen, 4).Font.Color = RGB(192, 0, 0)
                    .Rows(filaResumen).Interior.Color = RGB(255, 235, 235)
                Else
                    .Cells(filaResumen, 5).Value = "HORAS PENDIENTES"
                    .Cells(filaResumen, 4).Font.Color = RGB(197, 90, 17)
                    .Rows(filaResumen).Interior.Color = RGB(255, 245, 230)
                End If
            End With

            filaResumen = filaResumen + 1
        End If
    Next fila

    wsResumen.Columns("A:E").AutoFit
    wsResumen.Activate

    Application.ScreenUpdating = True
    MsgBox "Resumen generado en la hoja 'RESUMEN_HORAS'.", vbInformation, "Listo"
End Sub
Sub MenuPrincipal()
    Dim opcion As Integer
    Dim mensaje As String

    mensaje = "CUADRANTE PARKING - MENU DE ACCIONES" & Chr(10) & Chr(10)
    mensaje = mensaje & "1. Actualizar año en todas las hojas" & Chr(10)
    mensaje = mensaje & "2. Resaltar días festivos" & Chr(10)
    mensaje = mensaje & "3. Exportar mes a PDF" & Chr(10)
    mensaje = mensaje & "4. Generar resumen de horas" & Chr(10)
    mensaje = mensaje & Chr(10) & "Escribe el número de la acción:"

    opcion = InputBox(mensaje, "Menú Principal", "1")

    Select Case opcion
        Case 1: Call ActualizarAno
        Case 2: Call ResaltarFestivos
        Case 3: Call ExportarInformeMensual
        Case 4: Call GenerarResumenHoras
        Case Else
            If opcion <> 0 Then
                MsgBox "Opción no válida. Elige un número del 1 al 4.", vbExclamation
            End If
    End Select
End Sub
