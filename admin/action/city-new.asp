<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
cty_id = HTMLEncode(Request.Form("cityId"))
cty_name = HTMLEncode(Request.Form("cityName"))

url = "../?admin=city"

If cty_id = "" Or cty_name = "" Then
  Response.Redirect(url)
End If

Set newCity = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city"
newCity.Open sql,conn,3,3
newCity.AddNew
newCity("cty_id") = cty_id
newCity("cty_name") = cty_name
newCity.Update
newCity.Close
Set newCity = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增城市, " & cty_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
