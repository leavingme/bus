<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../inc/data.asp" -->
<%
kwd_id = Request("keyword")
If Request("page") <> "" Then
  page = "&page=" & Request("page")
End If
If Request("station") <> "" Then
  station = "&station=" & Request("station")
End If

url = "../list.asp?list=house"

Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT kwd_id FROM keyword WHERE kwd_id = " & kwd_id
keyword.Open sql,conn,3,3
keyword.Delete
keyword.Update
keyword.Close
Set keyword = Nothing

Response.Redirect(url) & page & station
%>
