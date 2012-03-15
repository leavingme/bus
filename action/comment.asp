<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../inc/data.asp" -->
<%
cmt_keyword = HTMLEncode(Request.Form("commentKeyword"))
cmt_busid = HTMLEncode(Request.Form("commentBusid"))
cmt_stationid = HTMLEncode(Request.Form("commentStationid"))
cmt_volunteer = HTMLEncode(Request.Form("commentVolunteer"))
If HTMLEncode(Request.Form("commentFlower")) = "1" Then
  cmt_flower = 1
End If
cmt_commentid = HTMLEncode(Request.Form("commentCommentid"))

mbr_name = HTMLEncode(Request.Form("commentName"))
mbr_blog = HTMLEncode(Request.Form("commentBlog"))
mbr_face = HTMLEncode(Request.Form("commentFace"))
If Len(Request.Form("commentMessage")) < 200 Then
  cmt_message = HTMLEncode(Request.Form("commentMessage"))
Else
  cmt_message = HTMLEncode(Left(Request.Form("commentMessage"),200)) & "..."
End If
rnd_code = HTMLEncode(Request.Form("rndCode"))
rc_a = HTMLEncode(Request.Form("rndCodeA"))
rc_b = HTMLEncode(Request.Form("rndCodeB"))
rc_c = HTMLEncode(Request.Form("rndCodeC"))

url = "../search.asp?q=" & cmt_keyword

Response.Cookies("commentName") = mbr_name
Response.Cookies("commentName").Expires=DateAdd("m",60,now())
Response.Cookies("commentBlog") = mbr_blog
Response.Cookies("commentFace") = mbr_face
If cmt_busid <> "" Then
Response.Cookies("commentMessage" & cmt_busid) = cmt_message
ElseIf cmt_stationid <> "" Then
Response.Cookies("commentMessage" & cmt_stationid) = cmt_message
End If

If Session("comment" & cmt_busid) = 3 Or Session("comment" & cmt_stationid) = 3 Then
  Response.Redirect(url & "&comment=" & cmt_commentid & "&error=repeat#comment")
End If
If cmt_flower = 1 And Session("commentFlower" & cmt_busid) = 1 Then
  Response.Redirect(url & "&flower=" & cmt_flower & "&error=flowerrepeat#comment")
End If

If Len(mbr_name) < 3 Then
  error_name = "name_"
ElseIf Len(mbr_name) > 16 Then
  error_name = "namelong_"
End If
If Len(mbr_blog) <> 0 And Len(mbr_blog) < 6 Or Len(mbr_blog) > 50 Then
  error_blog = "blog_"
End If
If Len(mbr_face) <> 0 And Len(mbr_face) < 6 Or Len(mbr_face) > 100 Then
  error_face = "face_"
End If
If Len(cmt_message) < 1 Then
  error_message = "message_"
ElseIf Instr((cmt_message),"http") Or Instr((cmt_message),"www.") Or Instr((cmt_message),".com") Then
  error_message = "http"
End If
If rnd_code <> rc_c Then
  error_code = "code_"
End If
error_msg = error_name & error_blog & error_face & error_message & error_code
If error_msg <> "" Then
  Response.Redirect(url & "&flower=" & cmt_flower & "&comment=" & cmt_commentid & "&error=" & error_msg & "#comment")
End If

Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name FROM member WHERE mbr_name = '" & mbr_name & "'"
member.Open sql,conn,1,1

If Not member.EOF Then

cmt_memberid = member("mbr_id")
Set updateMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_blog, mbr_face FROM member WHERE mbr_id = " & cmt_memberid
updateMember.Open sql,conn,3,3
If mbr_blog <> "" Then
updateMember("mbr_blog") = mbr_blog
End If
If mbr_face <> "" Then
updateMember("mbr_face") = mbr_face
End If
updateMember.Update
updateMember.Close
Set updateMember = Nothing

Else

Set newMember = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, mbr_blog, mbr_face FROM member"
newMember.Open sql,conn,3,3
newMember.AddNew
newMember("mbr_name") = mbr_name
newMember("mbr_blog") = mbr_blog
newMember("mbr_face") = mbr_face
newMember.Update
cmt_memberid = newMember("mbr_id")
newMember.Close
Set newMember = Nothing

End If

member.Close
Set member = Nothing

Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM comment"
comment.Open sql,conn,3,3
comment.AddNew
comment("cmt_memberid") = cmt_memberid
If cmt_busid <> "" Then
comment("cmt_busid") = cmt_busid
ElseIf cmt_stationid <> "" Then
comment("cmt_stationid") = cmt_stationid
End If
If cmt_commentid <> 0 Then
comment("cmt_commentid") = cmt_commentid
End If
comment("cmt_message") = cmt_message
If cmt_flower = 1 Then
comment("cmt_flower") = 1
End If
comment("cmt_ip") = Request.SerVerVariables("REMOTE_ADDR")
comment.Update
comment.Close
Set comment = Nothing

If cmt_flower = 1 Then
Set flower = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_flower FROM member WHERE mbr_id = " & cmt_volunteer
flower.Open sql,conn,3,3
flower("mbr_flower") = flower("mbr_flower") + 1
flower.Update
flower.Close
Set flower = Nothing
End If

If cmt_busid <> "" Then
Session("comment" & cmt_busid) = Session("comment" & cmt_busid) + 1
If cmt_flower = 1 Then
  Session("commentFlower" & cmt_busid) = 1
End If
ElseIf cmt_stationid <> "" Then
Session("comment" & cmt_stationid) = Session("comment" & cmt_stationid) + 1
End If
Response.Cookies("commentBlog") = ""
Response.Cookies("commentFace") = ""
Response.Cookies("commentMessage" & cmt_busid) = ""
Response.Cookies("commentMessage" & cmt_stationid) = ""
Response.Redirect(url) & "&#commentList"
%>
