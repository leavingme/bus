<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
bus_id = HTMLEncode(Request.Form("busId"))
bus_name = HTMLEncode(Request.Form("busName"))
bus_subtitle = HTMLEncode(Request.Form("busSubtitle"))
bus_categoryid = HTMLEncode(Request.Form("busCategoryid"))
bus_timeid = HTMLEncode(Request.Form("busTimeid"))
bus_member = HTMLEncode(Request.Form("busMember"))
bus_num = HTMLEncode(Request.Form("busNum"))
bus_count = HTMLEncode(Request.Form("busCount"))

url = "../?admin=bus&bus=" & bus_id

If bus_name = "" Then
  Response.Redirect(url)
End If

If bus_member <> "" Then

Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, mbr_flower FROM member WHERE mbr_name = '" & bus_member & "'"
member.Open sql,conn,1,1

If Not member.EOF Then

bus_memberid = member("mbr_id")
bus_memberflower = "0" & member("mbr_flower")

Set updateMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_flower FROM member WHERE mbr_id = " & bus_memberid
updateMember.Open sql,conn,3,3
updateMember("mbr_flower") = bus_memberflower
updateMember.Update
updateMember.Close
Set updateMember = Nothing

Else

Set newMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, mbr_flower FROM member"
newMember.Open sql,conn,3,3
newMember.AddNew
newMember("mbr_name") = bus_member
newMember("mbr_flower") = 0
newMember.Update
bus_memberid = newMember("mbr_id")
newMember.Close
Set newMember = Nothing

End If

End If

Set updateBus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus WHERE bus_id = " & bus_id
updateBus.Open sql,conn,3,3
updateBus("bus_name") = bus_name
updateBus("bus_subtitle") = bus_subtitle
updateBus("bus_categoryid") = bus_categoryid
updateBus("bus_timeid") = bus_timeid
updateBus("bus_memberid") = bus_memberid
If bus_num <> "" Then
updateBus("bus_num") = bus_num
End If
updateBus("bus_count") = bus_count
updateBus.Update
updateBus.Close
Set updateBus = Nothing

If bus_member <> "" Then

member.Close
Set member = Nothing

End If

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 修改班车, " & bus_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
