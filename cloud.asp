<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="inc/data.asp" -->
<%
If Request("bus") = "S" Then
	condition = 1
ElseIf Request("bus") = "N" Then
	condition = 2
ElseIf Request("bus") = "Q" Then
	condition = 3
ElseIf Request("bus") = "F" Then
	condition = 5
ElseIf Request("bus") = "T" Then
	condition = 4
Else
	condition = 1
End If
If Request("order") <> "" Then
	order = Request("order") & ", "
End If
Set bus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus WHERE bus_categoryid = " & condition & " ORDER BY " & order & "bus_name ASC"
bus.Open sql,conn,1,1
%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="keywords" content="班车, 地图, 搜索" />
<meta name="description" content="我爱坐班车 - 有地图的班车搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
<meta name="author" content="Huang Hong - design-hong.com huanghong@hotmail.com" />
<title>云班车手册 - 我爱坐班车</title>
<link rel="stylesheet" type="text/css" href="style/basic.css" />
<link rel="stylesheet" type="text/css" href="style/cloud.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
</head>

<body>
<div class="content">
	<h1>我爱坐班车 - 云班车手册</h1>
	<ul class="tab box">
		<li<% If Request("bus") = "" Or Request("bus") = "S" Then %> class="current"<% End If %>><a href="?bus=S">市区上班班车[S]</a></li>
		<li<% If Request("bus") = "N" Then %> class="current"<% End If %>><a href="?bus=N">南山&amp;宝安上班班车[N]</a></li>
		<li<% If Request("bus") = "Q" Then %> class="current"<% End If %>><a href="?bus=Q">腾讯大厦下班班车[Q]</a></li>
		<li<% If Request("bus") = "F" Then %> class="current"<% End If %>><a href="?bus=F">飞亚达大厦下班班车[F]</a></li>
		<li<% If Request("bus") = "T" Then %> class="current"<% End If %>><a href="?bus=T">夜间班车[T]</a></li>
	</ul>
	<p class="download">下载至本地（敬请期待）</p>
	<div class="table">
		<table>
			<thead>
				<tr>
					<th class="time"><a href="?bus=<%=(Request("bus"))%>&amp;order=bus_timeid%20<% If Request("order") = "bus_timeid ASC" Then %>DESC<% Else %>ASC<% End If %>">时间<% If Request("order") = "bus_timeid ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_timeid DESC" Then %><span>↓</span><% End If %></a></th>
					<th class="bus"><a href="?bus=<%=(Request("bus"))%>&amp;order=bus_name%20<% If Request("order") = "bus_name ASC" Then %>DESC<% Else %>ASC<% End If %>">班车<% If Request("order") = "bus_name ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_name DESC" Then %><span>↓</span><% End If %></a></th>
					<th class="line"><% If Request("bus") = "" Or Request("bus") = "S" Then %>市区上班班车[S]<% ElseIf Request("bus") = "N" Then %>南山&amp;宝安上班班车[N]<% ElseIf Request("bus") = "Q" Then %>腾讯大厦下班班车[Q]<% ElseIf Request("bus") = "F" Then %>飞亚达大厦下班班车[F]<% ElseIf Request("bus") = "T" Then %>夜间班车[T]<% End If %> - 具体路线</th>
				</tr>
			</thead>
			<tbody>
				<%
While (NOT bus.EOF)
%>
				<tr>
					<td class="time">
						<%
If bus("bus_timeid") = "0" Then
Response.Write("-")
Else
Set tim = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM tim WHERE tim_id = " & bus("bus_timeid")
tim.Open sql,conn,1,1
%>
		    <%=(tim("tim_name"))%>
            <%
tim.Close
Set tim = Nothing
End If
%></td>
					<td class="bus"><a href="search.asp?q=<%=(bus("bus_name"))%>" target="_blank"><%=(bus("bus_name"))%></a></td>
					<td class="line"><%
Set line = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT lne_id, lne_busid, lne_stationid, lne_time, stn_id, stn_name FROM line, station WHERE lne_busid = " & bus("bus_id") & " AND lne_stationid = stn_id ORDER By lne_order, lne_id"
line.Open sql,conn,1,1

While (NOT line.EOF)
%>
						<% If line_count > 0 Then %> - <% End If %><a href="search.asp?q=<%=Server.URLEncode(line("stn_name"))%>" target="_blank"><%=(line("stn_name"))%></a><% If line("lne_time") <> "" Then %><span>(<%=(line("lne_time"))%>)</span><% End If %>
						<%
line_count = line_count + 1
line.MoveNext()
Wend
line_count = 0

line.Close
Set line = Nothing
%></td>
				</tr>
				<%
bus.MoveNext()
Wend
%>
			</tbody>
		</table>
	</div>
	<ul class="tab box">
		<li<% If Request("bus") = "" Or Request("bus") = "S" Then %> class="current"<% End If %>><a href="?bus=S">市区上班班车[S]</a></li>
		<li<% If Request("bus") = "N" Then %> class="current"<% End If %>><a href="?bus=N">南山&amp;宝安上班班车[N]</a></li>
		<li<% If Request("bus") = "Q" Then %> class="current"<% End If %>><a href="?bus=Q">腾讯大厦下班班车[Q]</a></li>
		<li<% If Request("bus") = "F" Then %> class="current"<% End If %>><a href="?bus=F">飞亚达大厦下班班车[F]</a></li>
		<li<% If Request("bus") = "T" Then %> class="current"<% End If %>><a href="?bus=T">夜间班车[T]</a></li>
	</ul>
</div>
<script type="text/javascript" src="scripts/basic.js"></script>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-2449263-10']);
  _gaq.push(['_trackPageview']);

  (function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
  })();

</script>
</body>
</html>
<%
bus.Close
Set bus = Nothing
%>
