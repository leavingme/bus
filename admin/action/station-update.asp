<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../../inc/data.asp" -->
<!--#include file="admin.asp" -->
<%
stn_id = HTMLEncode(Request.Form("stationId"))
stn_cityid = HTMLEncode(Request.Form("stationCityid"))
stn_name = HTMLEncode(Request.Form("stationName"))
stn_letter = HTMLEncode(Request.Form("stationLetter"))
stn_map = HTMLEncode(Request.Form("stationMap"))
stn_coordinate = HTMLEncode(Request.Form("stationCoordinate"))
stn_master = HTMLEncode(Request.Form("stationMaster"))
stn_pic = HTMLEncode(Request.Form("stationPic"))
stn_count = HTMLEncode(Request.Form("stationCount"))

url = "../?admin=station&station=" & stn_id

If stn_name = "" Then
  Response.Redirect(url)
End If

Set updateStation = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station WHERE stn_id = " & stn_id
updateStation.Open sql,conn,3,3
updateStation("stn_cityid") = stn_cityid
updateStation("stn_name") = stn_name
updateStation("stn_letter") = stn_letter
updateStation("stn_map") = stn_map
updateStation("stn_coordinate") = stn_coordinate
updateStation("stn_master") = stn_master
updateStation("stn_pic") = stn_pic
updateStation("stn_count") = stn_count
updateStation.Update
updateStation.Close
Set updateStation = Nothing

Set newAction = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate"
newAction.Open sql,conn,3,3
newAction.AddNew
newAction("ort_content") = Session("member_name") & " 修改车站, " & stn_name
newAction.Update
newAction.Close
Set newAction = Nothing

Response.Redirect(url)
%>
