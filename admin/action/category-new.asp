<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
ctr_id = HTMLEncode(Request.Form("categoryId"))
ctr_cityid = HTMLEncode(Request.Form("categoryCityid"))
ctr_sort = HTMLEncode(Request.Form("categorySort"))
ctr_name = HTMLEncode(Request.Form("categoryName"))

url = "../?admin=category"

If ctr_name = "" Then
  Response.Redirect(url)
End If

Set newCategory = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category"
newCategory.Open sql,conn,3,3
newCategory.AddNew
newCategory("ctr_id") = ctr_id
newCategory("ctr_cityid") = ctr_cityid
newCategory("ctr_sort") = ctr_sort
newCategory("ctr_name") = ctr_name
newCategory.Update
newCategory.Close
Set newCategory = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 新增分类, " & ctr_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
