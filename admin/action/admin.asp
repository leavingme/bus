<%
If Session("member_admin") = "" Then
  Response.Redirect("login.asp")
End If
%>
