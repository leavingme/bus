<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../inc/data.asp" -->
<%
kwd_stationid = HTMLEncode(Request.Form("keywordStationid"))
If Len(Request.Form("keywordName")) < 11 Then
  kwd_name = HTMLEncode(Request.Form("keywordName"))
Else
  kwd_name = HTMLEncode(Left(Request.Form("keywordName"),10))
End If
If Request("page") <> "" Then
  page = "&page=" & Request("page")
End If
If Request("station") <> "" Then
  station = "&station=" & Request("station")
End If

url = "../list.asp?list=house"

If kwd_name = "" Then
  Response.Redirect(url) & page & station
End If

Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword"
keyword.Open sql,conn,3,3
keyword.AddNew
keyword("kwd_name") = kwd_name
keyword("kwd_stationid") = kwd_stationid
keyword("kwd_ip") = Request.SerVerVariables("REMOTE_ADDR")
keyword.Update
kwd_id = keyword("kwd_id")
keyword.Close
Set keyword = Nothing

Response.Redirect(url) & "&keyword=" & kwd_id & page & station
%>
