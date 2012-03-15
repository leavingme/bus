<!--#include file="admin.asp" -->
<!--#include file="../../inc/data.asp" -->
<%
Dim id_cmd
Set id_cmd = request("id_cmd")

Sub UpdateStnLatLng(p_stn_id, p_stn_lat, p_stn_lng)
    Dim cmd
    Set cmd = Server.CreateObject("ADODB.Command") 
    With cmd 
    .ActiveConnection = conn 
    .CommandType = 4 '代号4表示使用Access的存储过程 
    .CommandText = "UpdateStnLatLng"
    .Parameters.Append .CreateParameter("@p_stn_id", 3, 1)
    .Parameters.Append .CreateParameter("@p_stn_lat", 5, 1)
    .Parameters.Append .CreateParameter("@p_stn_lng", 5, 1)
    End With
    cmd("@p_stn_id") = p_stn_id
    cmd("@p_stn_lat") = p_stn_lat
    cmd("@p_stn_lng") = p_stn_lng
    cmd.Execute RecordsAffected
    response.write(RecordsAffected)
    Set cmd.ActiveConnection = nothing
    Set cmd = nothing
End Sub

'前面的Sub定义结束了，下面开始正式逻辑
If 1=id_cmd Then
    '1号指令：保存某个班车站的停靠位置
    Dim p_stn_id, p_stn_lat, p_stn_lng
    Set p_stn_id = request("stn_id")
    Set p_stn_lat = request("stn_lat")
    Set p_stn_lng = request("stn_lng")
    If IsEmpty(p_stn_id) or IsEmpty(p_stn_lat) or IsEmpty(p_stn_lng) Then
        response.Write("Error param!!!")
    Else
        Call UpdateStnLatLng(p_stn_id, p_stn_lat, p_stn_lng)
    End If
Else
    '没有传命令号过来，无效请求
    response.Write("Error POST!!")
End If
%>
