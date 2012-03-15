<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
lne_busid = HTMLEncode(Request.Form("lineBus"))
lne_time = HTMLEncode(Request.Form("lineTime"))

stn_name = HTMLEncode(Request.Form("lineStation"))

url = "../?admin=bus&bus=" & lne_busid & "#line"

If stn_name = "" Then
  Response.Redirect(url)
End If

Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_name FROM station WHERE stn_name = '" & stn_name & "'"
station.Open sql,conn,1,1

If Not station.EOF Then

lne_stationid = station("stn_id")

Else

Set newStation = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_name FROM station"
newStation.Open sql,conn,3,3
newStation.AddNew
newStation("stn_name") = stn_name
newStation.Update
lne_stationid = newStation("stn_id")
newStation.Close
Set newStation = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增车站, " & stn_name
newAction.Update
newAction.Close
Set newAction = Nothing

End If

Set newLine = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM line"
newLine.Open sql,conn,3,3
newLine.AddNew
newLine("lne_busid") = lne_busid
newLine("lne_stationid") = lne_stationid
newLine("lne_time") = lne_time
newLine.Update
newLine.Close
Set newLine = Nothing

station.Close
Set station = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增停靠(bus_" & lne_busid & "), " & stn_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
