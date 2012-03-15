<!--#include file="../inc/data.asp" -->
<%
Dim id_cmd
Set id_cmd = request("id_cmd")

Sub GetStationsNearby(c_lat, c_lng)
    Dim cmd,resultRS
    Set cmd = Server.CreateObject("ADODB.Command") 
    With cmd 
    .ActiveConnection = conn 
    .CommandType = 4 '代号4表示使用Access的存储过程 
    .CommandText = "StationsNearby" 
    .Parameters.Append .CreateParameter("@c_lat", 5, 1)
    .Parameters.Append .CreateParameter("@c_lng", 5, 1)
    End With
    cmd("@c_lat") = c_lat
    cmd("@c_lng") = c_lng
    Set resultRS = cmd.Execute()

    Dim stn_name, stn_lat, stn_lng, stn_id
    While not resultRS.EOF
        Set stn_id = resultRS("stn_id")
        Set stn_name = resultRS("stn_name")
        Set stn_lat = resultRS("stn_lat")
        Set stn_lng = resultRS("stn_lng")
        response.write(stn_id&"|"&stn_name&"|"&stn_lat&"|"&stn_lng&"#")
        resultRS.MoveNext()
    WEnd

    resultRS.Close()
    Set resultRS = nothing
    Set cmd.ActiveConnection = nothing
    Set cmd = nothing
End Sub

Sub GetBusOfStnID(p_stn_id, proc_name)
    Dim cmd,resultRS
    Set cmd = Server.CreateObject("ADODB.Command") 
    With cmd 
    .ActiveConnection = conn 
    .CommandType = 4 '代号4表示使用Access的存储过程 
    .CommandText = proc_name
    .Parameters.Append .CreateParameter("@p_stnid", 3, 1)
    End With
    cmd("@p_stnid") = p_stn_id
    Set resultRS = cmd.Execute()

    Dim bus_id, bus_name, bus_subtitle, bus_time
    While not resultRS.EOF
        Set bus_id = resultRS("bus_id")
        Set bus_name = resultRS("bus_name")
        Set bus_subtitle = resultRS("bus_subtitle")
        Set bus_time = resultRS("bus_time")
        response.write(bus_id&"|"&bus_name&"|"&bus_subtitle&"|"&bus_time&"#")
        resultRS.MoveNext()
    WEnd

    resultRS.Close()
    Set resultRS = nothing
    Set cmd.ActiveConnection = nothing
    Set cmd = nothing
End Sub

Sub GetLineOfBusID(p_busid)
    Dim cmd,resultRS
    Set cmd = Server.CreateObject("ADODB.Command") 
    With cmd 
    .ActiveConnection = conn 
    .CommandType = 4 '代号4表示使用Access的存储过程 
    .CommandText = "LineOfBusId"
    .Parameters.Append .CreateParameter("@p_busid", 3, 1)
    End With
    cmd("@p_busid") = p_busid
    Set resultRS = cmd.Execute()

    Dim stn_name, stn_map, stn_lat, stn_lng, lne_order, lne_time
    While not resultRS.EOF
        Set stn_id = resultRS("stn_id")
        Set stn_name = resultRS("stn_name")
        Set stn_map = resultRS("stn_map")
        Set stn_lat = resultRS("stn_lat")
        Set stn_lng = resultRS("stn_lng")
        Set lne_order = resultRS("lne_order")
        Set lne_time = resultRS("lne_time")
        response.write(stn_id&"|"&stn_name&"|"&stn_lat&"|"&stn_lng&"|"&stn_map&"|"&lne_order&"|"&lne_time&"#")
        resultRS.MoveNext()
    WEnd

    resultRS.Close()
    Set resultRS = nothing
    Set cmd.ActiveConnection = nothing
    Set cmd = nothing
End Sub

'前面的Sub定义结束了，下面开始正式逻辑
If 1=id_cmd Then
    '1号指令：取得最近的班车停靠点
    Dim c_lat, c_lng
    Set c_lat = request("c_lat")
    Set c_lng = request("c_lng")
    If IsEmpty(c_lat) or IsEmpty(c_lng) Then
        response.Write("Error Input Params!!!")
    Else
        Call GetStationsNearby(c_lat, c_lng)
    End If
ElseIf 2=id_cmd Then
    '2号指令：查询某个站点的上班班车、下班班车
    Dim p_stn_id
    Set p_stn_id = request("stn_id")
    If IsEmpty(p_stn_id) Then
        response.Write("Error Input p_stn_id!!!")
    Else
        Call GetBusOfStnID(p_stn_id, "BusToWork")
        Call GetBusOfStnID(p_stn_id, "BusOffDuty")
    End If
ElseIf 3=id_cmd Then
    '3号指令：查询某个班车的行驶路线
    Dim p_busid
    Set p_busid = request("bus_id")
    If IsEmpty(p_busid) Then
        response.Write("Error Input p_busid!!!")
    Else
        Call GetLineOfBusID(p_busid)
    End If
Else
    '没有传命令号过来，无效请求
    response.Write("Error POST!!")
End If
%>
