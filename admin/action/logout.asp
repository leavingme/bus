<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<%
Session.Contents.Remove("member_name")
Session.Contents.Remove("member_admin")
Response.Redirect "/"
%>
