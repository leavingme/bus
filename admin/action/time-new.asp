<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
tim_id = HTMLEncode(Request.Form("timeId"))
tim_name = HTMLEncode(Request.Form("timeName"))

url = "../?admin=time"

If tim_id = "" Or tim_name = "" Then
  Response.Redirect(url)
End If

Set newTime = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM tim"
newTime.Open sql,conn,3,3
newTime.AddNew
newTime("tim_id") = tim_id
newTime("tim_name") = tim_name
newTime.Update
newTime.Close
Set newTime = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增时间, " & tim_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
