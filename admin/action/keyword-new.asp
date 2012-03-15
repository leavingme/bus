<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
kwd_stationid = HTMLEncode(Request.Form("keywordStationid"))
kwd_name = HTMLEncode(Request.Form("keywordName"))

url = "../?admin=station&station=" & kwd_stationid

If kwd_name = "" Then
  Response.Redirect(url)
End If

Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword"
keyword.Open sql,conn,3,3
keyword.AddNew
keyword("kwd_name") = kwd_name
keyword("kwd_stationid") = kwd_stationid
keyword("kwd_ip") = Request.SerVerVariables("REMOTE_ADDR")
keyword.Update
keyword.Close
Set keyword = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增车站(station_" & kwd_stationid & ")周边, " & kwd_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
