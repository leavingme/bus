<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../inc/data.asp" -->
<%
stn_id = HTMLEncode(Request.Form("mapStationid"))
stn_name = HTMLEncode(Request.Form("mapStationName"))
If Len(Request.Form("mapUrl")) < 51 Then
  stn_mapurl = HTMLEncode(Request.Form("mapUrl"))
Else
  stn_mapurl = HTMLEncode(Left(Request.Form("mapUrl"),50))
End If

mbr_name = HTMLEncode(Request.Form("mapMember"))

url = "../search.asp?q=" & stn_name

If mbr_name <> "" Then
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name FROM member WHERE mbr_name = '" & mbr_name & "'"
member.Open sql,conn,1,1

If Not member.EOF Then

stn_memberid = member("mbr_id")

Else

Set newMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name FROM member"
newMember.Open sql,conn,3,3
newMember.AddNew
newMember("mbr_name") = mbr_name
newMember.Update
stn_memberid = newMember("mbr_id")
newMember.Close
Set newMember = Nothing

End If

member.Close
Set member = Nothing

End If

Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_mapurl, stn_master FROM station WHERE stn_id = " & stn_id
station.Open sql,conn,3,3
station("stn_mapurl") = stn_mapurl
If mbr_name <> "" Then
station("stn_master") = stn_memberid
End If
station.Update
station.Close
Set station = Nothing

Response.Redirect(url) & "&#sosomap"
%>
