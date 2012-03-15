<%
If Session("member_admin") <> 2 Then
  Response.Redirect("login.asp")
End If
%>
