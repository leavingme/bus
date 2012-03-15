<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
kwd_stationid = HTMLEncode(Request("station"))
kwd_id = HTMLEncode(Request("keyword"))

url = "../?admin=station&station=" & kwd_stationid & "#keyword"

Set deleteKeyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT kwd_id FROM keyword WHERE kwd_id = " & kwd_id
deleteKeyword.Open sql,conn,3,3
deleteKeyword.Delete
deleteKeyword.Update
deleteKeyword.Close
Set deleteKeyword = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 删除车站(station_" & kwd_stationid & ")周边keyword_" & kwd_id
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
