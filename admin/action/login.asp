<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<%
Session.Contents.Remove("member_name")
Session.Contents.Remove("member_admin")
%>
<%
mbr_name = HTMLEncode(Request.Form("loginName"))
mbr_password = HTMLEncode(Request.Form("loginPassword"))

Response.Cookies("loginName") = mbr_name
Response.Cookies("loginPassword") = mbr_password

Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, mbr_admin, mbr_password FROM member WHERE mbr_name = '" & mbr_name & "'" & " AND mbr_password = '" & mbr_password & "'"
member.Open sql,conn,1,1
If member.EOF AND member.BOF Then
  Response.Redirect("../")
Else
  Session("member_name") = member("mbr_name")
  Session("member_admin") = member("mbr_admin")
End If
member.Close
Set member = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 登录, IP: " & Request.SerVerVariables("REMOTE_ADDR")
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect("../?admin=bus")
%>
