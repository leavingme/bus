<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin2.asp" -->
<%
mbr_id = HTMLEncode(Request.Form("memberId"))
mbr_name = HTMLEncode(Request.Form("memberName"))
mbr_blog = HTMLEncode(Request.Form("memberBlog"))
mbr_face = HTMLEncode(Request.Form("memberFace"))
mbr_flower = HTMLEncode(Request.Form("memberFlower"))
mbr_admin = HTMLEncode(Request.Form("memberAdmin"))
mbr_password = HTMLEncode(Request.Form("memberPassword"))

url = "../?admin=member&member=" & mbr_id

If mbr_name = "" Then
  Response.Redirect(url)
End If

Set updateMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM member WHERE mbr_id = " & mbr_id
updateMember.Open sql,conn,3,3
updateMember("mbr_name") = mbr_name
updateMember("mbr_blog") = mbr_blog
updateMember("mbr_face") = mbr_face
If mbr_flower <> "" Then
updateMember("mbr_flower") = mbr_flower
End If
If mbr_admin <> "" Then
updateMember("mbr_admin") = mbr_admin
End If
If mbr_password <> "" Then
updateMember("mbr_password") = mbr_password
End If
updateMember.Update
updateMember.Close
Set updateMember = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 修改用户, " & mbr_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
