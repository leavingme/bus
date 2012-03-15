<%
dim conn
db = "/data/data.mdb"
Set bus = Server.CreateObject("ADODB.Connection")
conn = "Provider = Microsoft.Jet.OLEDB.4.0;Data Source= " & Server.MapPath(""&db&"")
bus.Open conn
%>
<%
If Request.Cookies("cityId") = "" Or Request("city") <> "" Then
  If Request("city") = "sz" Then
    Response.Cookies("cityId") = 1
    Response.Cookies("cityName") = "深圳"
  ElseIf Request("city") = "bj" Then
	Response.Cookies("cityId") = 2
	Response.Cookies("cityName") = "北京"
  ElseIf Request("city") = "cd" Then
	Response.Cookies("cityId") = 3
	Response.Cookies("cityName") = "成都"
  ElseIf Request("city") = "sh" Then
	Response.Cookies("cityId") = 4
	Response.Cookies("cityName") = "上海"
  ElseIf Request("city") = "gz" Then
	Response.Cookies("cityId") = 5
	Response.Cookies("cityName") = "广州"
  Else
    Response.Cookies("cityId") = 1
    Response.Cookies("cityName") = "深圳"
  End If
  Response.Cookies("cityName").Expires=DateAdd("m",60,now())
End If
%>
<%
Function HTMLEncode(fString)
  If Not isNull(fString) Then
    fString = Replace(fString, "*", " ")
    fString = Replace(fString, "%", " ")
    fString = Replace(fString, "<", " ")
    fString = Replace(fString, ">", " ")
    fString = Replace(fString, "'", " ")
    fString = Replace(fString, "&", "&amp;")
    fString = Replace(fString, "and", " ")
    fString = Replace(fString, "char", " ")
    fString = Replace(fString, "chr", " ")
    fString = Replace(fString, "count", " ")
    fString = Replace(fString, "declare", " ")
    fString = Replace(fString, "delete", " ")
    fString = Replace(fString, "exec", " ")
    fString = Replace(fString, "insert", " ")
    fString = Replace(fString, "master", " ")
    fString = Replace(fString, "mid", " ")
    fString = Replace(fString, "select", " ")
    fString = Replace(fString, "truncate", " ")
    fString = Replace(fString, "update", " ")
    fString = Replace(fString, vbcrlf, "<br />")
    HTMLEncode = fString
  Else
    HTMLEncode = fString
  End If
End Function
%>
<%
Function HTMLEncode2(fString)
  If Not isNull(fString) Then
    fString = Replace(fString, "a", "A")
    fString = Replace(fString, "b", "B")
    fString = Replace(fString, "c", "C")
    fString = Replace(fString, "d", "D")
    fString = Replace(fString, "e", "E")
    fString = Replace(fString, "f", "F")
    fString = Replace(fString, "g", "G")
    fString = Replace(fString, "h", "H")
    fString = Replace(fString, "i", "I")
    fString = Replace(fString, "j", "J")
    fString = Replace(fString, "k", "K")
    fString = Replace(fString, "l", "L")
    fString = Replace(fString, "m", "M")
    fString = Replace(fString, "n", "N")
    fString = Replace(fString, "o", "O")
    fString = Replace(fString, "p", "P")
    fString = Replace(fString, "q", "Q")
    fString = Replace(fString, "r", "R")
    fString = Replace(fString, "s", "S")
    fString = Replace(fString, "t", "T")
    fString = Replace(fString, "u", "U")
    fString = Replace(fString, "v", "V")
    fString = Replace(fString, "w", "W")
    fString = Replace(fString, "x", "X")
    fString = Replace(fString, "y", "Y")
    fString = Replace(fString, "z", "Z")
    fString = Replace(fString, "*", " ")
    fString = Replace(fString, "%", " ")
    fString = Replace(fString, "<", " ")
    fString = Replace(fString, ">", " ")
    fString = Replace(fString, "'", " ")
    fString = Replace(fString, "&", "&amp;")
    fString = Replace(fString, "and", " ")
    fString = Replace(fString, "char", " ")
    fString = Replace(fString, "chr", " ")
    fString = Replace(fString, "count", " ")
    fString = Replace(fString, "declare", " ")
    fString = Replace(fString, "delete", " ")
    fString = Replace(fString, "exec", " ")
    fString = Replace(fString, "insert", " ")
    fString = Replace(fString, "master", " ")
    fString = Replace(fString, "mid", " ")
    fString = Replace(fString, "select", " ")
    fString = Replace(fString, "truncate", " ")
    fString = Replace(fString, "update", " ")
    fString = Replace(fString, vbcrlf, "<br />")
    HTMLEncode2 = fString
  Else
    HTMLEncode2 = fString
  End If
End Function
%>
