<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
lne_id = HTMLEncode(Request.Form("lineId"))
lne_busid = HTMLEncode(Request.Form("lineBus"))
lne_time = HTMLEncode(Request.Form("lineTime"))
lne_order = HTMLEncode(Request.Form("lineOrder"))

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

End If

Set updateLine = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM line WHERE lne_id = " & lne_id
updateLine.Open sql,conn,3,3
updateLine("lne_busid") = lne_busid
updateLine("lne_stationid") = lne_stationid
If lne_order <> "" Then
updateLine("lne_order") = lne_order
End If
updateLine("lne_time") = lne_time
updateLine.Update
updateLine.Close
Set updateLine = Nothing

station.Close
Set station = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 修改停靠(bus_" & lne_busid & "), " & stn_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
