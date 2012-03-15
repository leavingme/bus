<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
lne_id = HTMLEncode(Request("line"))
bus_id = HTMLEncode(Request("bus"))

url = "../?admin=bus&bus=" & bus_id & "#line"

Set deleteLine = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT lne_id FROM line WHERE lne_id = " & lne_id
deleteLine.Open sql,conn,3,3
deleteLine.Delete
deleteLine.Update
deleteLine.Close
Set deleteLine = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 删除班车(bus_" & bus_id & ")停靠line_" & lne_id
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
