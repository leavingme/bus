<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="../inc/data.asp" -->
<!--#include file="action/admin.asp" -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>我爱坐班车 后台管理</title>
<link rel="stylesheet" type="text/css" href="../style/basic.css" />
<link rel="stylesheet" type="text/css" href="../style/admin.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="../style/ie.css" /><![endif]-->
<script type="text/javascript">
function faceTag(id, str){
	document.getElementById(id).lineStation.focus();
	if((document.selection) && (document.selection.type == "Text")){
		var oStr = document.selection.createRange();
		oStr.text = str+oStr
	} else {
	document.getElementById(id).lineStation.value = str
	}
}
</script>
</head>
<body>
<div id="header">
  <div class="top">
    <h1>我爱坐班车 后台管理</h1>
    <p><%=(Session("member_name"))%><% If Session("member_admin") = 2 Then %> 管理员<% Else %> 志愿者<% End If %> - <a href="/">返回首页</a></p>
  </div>
</div>
<div id="main">
  <ul class="sidebar">
    <li<% If Request("admin") = "bus" Then %> class="current"<% End If %>><a href="?admin=bus">班车列表</a></li>
    <li<% If Request("admin") = "station" Then %> class="current"<% End If %>><a href="?admin=station">车站列表</a></li>
    <li<% If Request("admin") = "city" Then %> class="current"<% End If %>><a href="?admin=city">城市列表</a></li>
    <li<% If Request("admin") = "category" Then %> class="current"<% End If %>><a href="?admin=category">分类列表</a></li>
    <li<% If Request("admin") = "time" Then %> class="current"<% End If %>><a href="?admin=time">时间列表</a></li>
    <li<% If Request("admin") = "member" Then %> class="current"<% End If %>><a href="?admin=member">用户列表</a></li>
    <li<% If Request("admin") = "comment" Then %> class="current"<% End If %>><a href="?admin=comment">评论列表</a></li>
    <li<% If Request("admin") = "search" Then %> class="current"<% End If %>><a href="?admin=search">搜索列表</a></li>
    <li<% If Request("admin") = "operate" Then %> class="current"<% End If %>><a href="?admin=operate">操作记录</a></li>
    <li><a href="action/logout.asp">安全退出</a></li>
  </ul>
  <div class="content <%=(Request("admin"))%>">
    <% If Request("admin") = "bus" Then %>
    <ul class="tab">
      <li<% If Request("bus") = "" Then %> class="current"<% End If %>><a href="?admin=bus">班车列表</a></li>
      <li<% If Request("bus") = "0" Then %> class="current"<% End If %>><a href="?admin=bus&amp;bus=0">新增班车</a></li>
    </ul>
    <% End If %>
    <% If Request("admin") = "bus" AND Request("bus") = "" Then %>
    <%
If Request("order") <> "" Then
  condition = "ORDER BY " & Request("order")
End If
Set bus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus " & condition
bus.Open sql,conn,1,1
%>
    <table>
      <thead>
        <tr>
          <th><a href="?admin=bus&amp;order=bus_id%20<% If Request("order") = "bus_id DESC" Then %>ASC<% Else %>DESC<% End If %>">编号<% If Request("order") = "" Or Request("order") = "bus_id ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_id DESC" Then %><span>↓</span><% End If %></a></th>
          <th><a href="?admin=bus&amp;order=bus_name%20<% If Request("order") = "bus_name ASC" Then %>DESC<% Else %>ASC<% End If %>">班车<% If Request("order") = "bus_name ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_name DESC" Then %><span>↓</span><% End If %></a></th>
          <th><a href="?admin=bus&amp;order=bus_categoryid%20<% If Request("order") = "bus_categoryid ASC" Then %>DESC<% Else %>ASC<% End If %>">类别<% If Request("order") = "bus_categoryid ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_categoryid DESC" Then %><span>↓</span><% End If %></a></th>
          <th><a href="?admin=bus&amp;order=bus_timeid%20<% If Request("order") = "bus_timeid ASC" Then %>DESC<% Else %>ASC<% End If %>">时间<% If Request("order") = "bus_timeid ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_timeid DESC" Then %><span>↓</span><% End If %></a></th>
          <th><a href="?admin=bus&amp;order=bus_memberid%20<% If Request("order") = "bus_memberid DESC" Then %>ASC<% Else %>DESC<% End If %>">志愿者<% If Request("order") = "bus_memberid ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_memberid DESC" Then %><span>↓</span><% End If %></a></th>
          <th>路线</th>
          <th><a href="?admin=bus&amp;order=bus_num%20<% If Request("order") = "bus_num DESC" Then %>ASC<% Else %>DESC<% End If %>">车数<% If Request("order") = "bus_num ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_num DESC" Then %><span>↓</span><% End If %></a></th>
          <th><a href="?admin=bus&amp;order=bus_count%20<% If Request("order") = "bus_count DESC" Then %>ASC<% Else %>DESC<% End If %>">点击<% If Request("order") = "bus_count ASC" Then %><span>↑</span><% ElseIf Request("order") = "bus_count DESC" Then %><span>↓</span><% End If %></a></th>
          <th>评论</th>
          <th>删除</th>
          <th>修改</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT bus.EOF)
%>
        <tr>
          <td><%=(bus("bus_id"))%></td>
          <td><a href="line.asp?bus_id=<%=(bus("bus_id"))%>" target="_blank"><%=(bus("bus_name"))%></a></td>
          <td>
            <%
Set category = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category WHERE ctr_id = " & bus("bus_categoryid")
category.Open sql,conn,1,1
%>
		    <%=(category("ctr_name"))%>
            <%
category.Close
Set category = Nothing
%>
          </td>
          <td>
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
%>
          </td>
          <td>
            <%
If bus("bus_memberid") <> "" Then
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name FROM member WHERE mbr_id = " & bus("bus_memberid")
member.Open sql,conn,1,1
%>
		    <a href="?admin=member&amp;member=<%=(member("mbr_id"))%>" target="_blank"><%=(member("mbr_name"))%></a>
            <%
member.Close
Set member = Nothing
End If
%>
          </td>
          <td class="station">
            <%
Set line = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT lne_id, lne_busid, lne_stationid, lne_time, stn_id, stn_name FROM line, station WHERE lne_busid = " & bus("bus_id") & " AND lne_stationid = stn_id ORDER By lne_order, lne_id"
line.Open sql,conn,1,1

While (NOT line.EOF)
%>
            <% If line_count > 0 Then %>- <% End If %><a href="?admin=station&amp;station=<%=(line("stn_id"))%>" target="_blank"><%=(line("stn_name"))%></a>
            <%
line_count = line_count + 1
line.MoveNext()
Wend
line_count = 0

line.Close
Set line = Nothing
%>
          </td>
          <td><%=(bus("bus_num"))%></td>
          <td><%=(bus("bus_count"))%></td>
          <td>
            <%
Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT cmt_id, cmt_busid FROM comment WHERE cmt_busid = " & bus("bus_id")
comment.Open sql,conn,1,1
%>
		    <%=(comment.recordcount)%>
            <%
comment.Close
Set comment = Nothing
%>
          </td>
          <td><a href="#">删除</a></td>
          <td><a href="?admin=bus&amp;bus=<%=(bus("bus_id"))%>" target="_blank">修改</a></td>
        </tr>
        <%
bus.MoveNext()
Wend
%>
      </tbody>
    </table>
    <%
bus.Close
Set bus = Nothing
%>
    <% ElseIf Request("bus") <> "" Then %>
    <% If Request("bus") = "0" Then %>
    <form id="bus" method="post" action="action/bus-new.asp">
      <fieldset>
        <legend>新增班车</legend>
        <p>
          <label for="busName">班车:</label>
          <input id="busName" name="busName" />
        </p>
        <p>
          <label for="busSubtitle">副标:</label>
          <input id="busSubtitle" name="busSubtitle" />
        </p>
        <p>
          <label for="busCategoryid">类别:</label>
          <select id="busCategoryid" name="busCategoryid">
            <%
Set category = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category"
category.Open sql,conn,1,1

While (NOT category.EOF)
%>
            <option value="<%=(category("ctr_id"))%>"><%=(category("ctr_name"))%></option>
            <%
category.MoveNext()
Wend

category.Close
Set category = Nothing
%>
          </select>
        </p>
        <p>
          <label for="busTimeid">时间:</label>
          <select id="busTimeid" name="busTimeid">
            <%
Set tim = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM tim ORDER BY tim_name"
tim.Open sql,conn,1,1

While (NOT tim.EOF)
%>
            <option value="<%=(tim("tim_id"))%>"><% If tim("tim_name") = "0" Then %>-<% Else %><%=(tim("tim_name"))%><% End If %></option>
            <%
tim.MoveNext()
Wend

tim.Close
Set tim = Nothing
%>
          </select>
        </p>
        <p>
          <label for="busMember">志愿者:</label>
          <input id="busMember" name="busMember" />
        </p>
        <p>
          <label for="busNum">车数:</label>
          <input id="busNum" name="busNum" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>班车名称大写；</li>
          <li>目前只有北分班车有中文副标题；</li>
          <li>如果是上班班车，时间请选择"-"，表示没有；</li>
          <li>志愿者中请填写RTX英文昵称。</li>
        </ol>
      </fieldset>
    </form>
    <% Else %>
    <%
Set bus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus WHERE bus_id = " & Request("bus")
bus.Open sql,conn,1,1
%>
    <form id="bus" method="post" action="action/bus-update.asp">
      <fieldset>
        <legend>班车 - <%=(bus("bus_name"))%> <a href="../search.asp?q=<%=(bus("bus_name"))%>">[查看]</a></legend>
        <p>
          <label for="busId">编号:</label>
          <input id="busId" name="busId" readonly="readonly" value="<%=(bus("bus_id"))%>" />
        </p>
        <p>
          <label for="busName">班车:</label>
          <input id="busName" name="busName" value="<%=(bus("bus_name"))%>" />
        </p>
        <p>
          <label for="busSubtitle">副标:</label>
          <input id="busSubtitle" name="busSubtitle" value="<%=(bus("bus_subtitle"))%>" />
        </p>
        <p>
          <label for="busCategoryid">类别:</label>
          <select id="busCategoryid" name="busCategoryid">
            <%
Set category = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category"
category.Open sql,conn,1,1

While (NOT category.EOF)
%>
            <option value="<%=(category("ctr_id"))%>"<% If category("ctr_id") = bus("bus_categoryid") Then %> selected="selected"<% End If %>><%=(category("ctr_name"))%></option>
            <%
category.MoveNext()
Wend

category.Close
Set category = Nothing
%>
          </select>
        </p>
        <p>
          <label for="busTimeid">时间:</label>
          <select id="busTimeid" name="busTimeid">
            <%
Set tim = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM tim ORDER BY tim_name"
tim.Open sql,conn,1,1

While (NOT tim.EOF)
%>
            <option value="<%=(tim("tim_id"))%>"<% If tim("tim_id") = bus("bus_timeid") Then %> selected="selected"<% End If %>><% If tim("tim_name") = "0" Then %>-<% Else %><%=(tim("tim_name"))%><% End If %></option>
            <%
tim.MoveNext()
Wend

tim.Close
Set tim = Nothing
%>
          </select>
        </p>
        <p>
          <label for="busMember">志愿者:</label>
          <%
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_memberid, mbr_id, mbr_name FROM bus, member WHERE bus_id = " & bus("bus_id") & " And bus_memberid = mbr_id"
member.Open sql,conn,1,1

If Not member.EOF Then
%>
          <input id="busMember" name="busMember" value="<%=(member("mbr_name"))%>" />
          <% Else %>
          <input id="busMember" name="busMember" />
          <%
End If

member.Close
Set member = Nothing
%>
        </p>
        <p>
          <label for="busNum">车数:</label>
          <input id="busNum" name="busNum" value="<%=(bus("bus_num"))%>" />
        </p>
        <p>
          <label for="busCount">点击:</label>
          <input id="busCount" name="busCount" value="<%=(bus("bus_count"))%>" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>类别与时间下拉框中，以灰色背景标识出修改前的选项；</li>
          <li>如果是上班班车，时间请选择“-”，表示没有；</li>
          <li>志愿者中请填写RTX英文昵称。</li>
        </ol>
      </fieldset>
    </form>
<script type="text/javascript">
window.onload = function() {
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("map_canvas"));
		map.enableScrollWheelZoom();               //滚轮缩放
		map.enableContinuousZoom();                //平滑缩放
		
		var directions = new GDirections(map);
		<%
Set stationCoordinate = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_coordinate, lne_id, lne_busid, lne_stationid, lne_order FROM station, line WHERE lne_busid = " & bus("bus_id") & " And lne_stationid = stn_id ORDER By lne_order, lne_id"
stationCoordinate.Open sql,conn,1,1
%>
		directions.load("from: <%
While (NOT stationCoordinate.EOF)
%><% If coordinate_count > 0 Then %> to: <% End If %><%=(stationCoordinate("stn_coordinate"))%><%
coordinate_count = coordinate_count + 1
stationCoordinate.MoveNext()
Wend
%>");
		<%
stationCoordinate.Close
Set stationCoordinate = Nothing
%>
	}
}
</script>
    <div id="map_canvas"></div>
    <%
Set line = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT lne_id, lne_busid, lne_stationid, lne_order, lne_time, stn_id, stn_name FROM line, station WHERE lne_busid = " & bus("bus_id") & " AND lne_stationid = stn_id ORDER By lne_order, lne_id"
line.Open sql,conn,1,1

If Not line.EOF Then 
%>
    <div class="lineList">
      <h2>行车路线</h2>
      <table>
        <thead>
          <tr>
            <th>编号</th>
            <th>车站</th>
            <th>时间</th>
            <th>顺序</th>
            <th>删除</th>
            <th>修改</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT line.EOF)
%>
          <tr>
            <td><%=(line("lne_id"))%></td>
            <td class="station"><a href="?admin=station&amp;station=<%=(line("stn_id"))%>"><%=(line("stn_name"))%></a></td>
            <td><%=(line("lne_time"))%></td>
            <td><%=(line("lne_order"))%></td>
            <td><a href="action/line-delete.asp?bus=<%=(bus("bus_id"))%>&amp;line=<%=(line("lne_id"))%>" onclick="return confirm('确定要删除吗?');">删除</a></td>
            <td><a href="?admin=bus&amp;bus=<%=(bus("bus_id"))%>&amp;line=<%=(line("lne_id"))%>#line">修改</a></td>
          </tr>
          <%
line.MoveNext()
Wend
%>
        </tbody>
      </table>
    </div>
    <%
End If

line.Close
Set line = Nothing
%>
    <div class="lineList">
      <% If Request("line") Then %>
      <%
Set line = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT lne_id, lne_busid, lne_stationid, lne_order, lne_time, stn_id, stn_name FROM line, station WHERE lne_id = " & Request("line") & " AND lne_stationid = stn_id"
line.Open sql,conn,1,1
%>
      <h2>修改停靠</h2>
      <form id="line" method="post" action="action/line-update.asp">
        <p>
          <label for="lineStation">车站:</label>
          <input id="lineStation" name="lineStation" value="<%=(line("stn_name"))%>" />
        </p>
        <p>
          <label for="lineOrder">顺序:</label>
          <input id="lineOrder" name="lineOrder" class="short" value="<%=(line("lne_order"))%>" />
        </p>
        <p>
          <label for="lineTime">时间:</label>
          <input id="lineTime" name="lineTime" class="short" value="<%=(line("lne_time"))%>" />
        </p>
        <p>
          <input name="lineId" type="hidden" value="<%=(line("lne_id"))%>" />
          <input name="lineBus" type="hidden" value="<%=(bus("bus_id"))%>" />
          <button>提交</button>
        </p>
      <%
line.Close
Set line = Nothing
%>
      <% Else %>
      <h2>新增停靠</h2>
      <form id="line" method="post" action="action/line-new.asp">
        <p>
          <label for="lineStation">车站:</label>
          <input id="lineStation" name="lineStation" />
          常用 -
          <button onclick="faceTag(this.form.id,'腾讯大厦')" type="button">腾讯大厦</button>
          <button onclick="faceTag(this.form.id,'飞亚达大厦')" type="button">飞亚达大厦</button>
        </p>
        <p>
          <label for="lineTime">时间:</label>
          <input id="lineTime" name="lineTime" class="short" />
        </p>
        <p>
          <input name="lineBus" type="hidden" value="<%=(bus("bus_id"))%>" />
          <button>提交</button>
        </p>
      <% End If %>
        <ol>
          <li>站名中不需要包含“站”字；</li>
          <li>点击“修改”可调整行车线路停靠数据；</li>
          <li>顺序可以调整行车路径先后（非必需，一般用于修改路线，如果不填则按添加的先后排序）；</li>
          <li>新增的停靠如果不是已有的车站（上面的地图无法显示），请务必点击“车站”名上链接完善信息。</li>
        </ol>
      </form>
    </div>
    <%
bus.Close
Set bus = Nothing
%>
    <% End If %>
    <% ElseIf Request("admin") = "station" AND Request("station") = "" Then %>
    <%
If Request("order") <> "" Then
  condition = "ORDER BY " & Request("order")
End If
Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station " & condition
station.Open sql,conn,1,1
%>
    <table>
      <thead>
        <tr>
          <th><a href="?admin=station&amp;order=stn_id%20<% If Request("order") = "stn_id DESC" Then %>ASC<% Else %>DESC<% End If %>">编号<% If Request("order") = "" Or Request("order") = "stn_id ASC" Then %><span>↑</span><% ElseIf Request("order") = "stn_id DESC" Then %><span>↓</span><% End If %></a></th>
          <th>车站</th>
          <th><a href="?admin=station&amp;order=stn_letter%20<% If Request("order") = "stn_letter ASC" Then %>DESC<% Else %>ASC<% End If %>">首字母<% If Request("order") = "stn_letter ASC" Then %><span>↑</span><% ElseIf Request("order") = "stn_letter DESC" Then %><span>↓</span><% End If %></a></th>
          <th>班车</th>
          <th>周边</th>
          <th>定位</th>
          <th><a href="?admin=station&amp;order=stn_count%20<% If Request("order") = "stn_count DESC" Then %>ASC<% Else %>DESC<% End If %>">点击<% If Request("order") = "stn_count ASC" Then %><span>↑</span><% ElseIf Request("order") = "stn_count DESC" Then %><span>↓</span><% End If %></a></th>
          <th>评论</th>
          <th>删除</th>
          <th>修改</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT station.EOF)
%>
        <tr>
          <td><%=(station("stn_id"))%></td>
          <td class="station"><a href="?admin=station&amp;station=<%=(station("stn_id"))%>" target="_blank"><%=(station("stn_name"))%></a></td>
          <td><%=(station("stn_letter"))%></td>
          <td class="bus">
            <%
If station("stn_id") = "1" Or station("stn_id") = "2" Then
Response.Write("略")
Else
Set line = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM line, bus WHERE lne_stationid = " & station("stn_id") & " AND lne_busid = bus_id"
line.Open sql,conn,1,1

While (NOT line.EOF)
%>
            <a href="line.asp?bus_id=<%=(line("bus_id"))%>" target="_blank"><%=(line("bus_name"))%></a>
            <%
line.MoveNext()
Wend

line.Close
Set line = Nothing
End If
%>
          </td>
          <td class="keyword">
            <%
Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword WHERE kwd_stationid = " & station("stn_id")
keyword.Open sql,conn,1,1

While (NOT keyword.EOF)
%>
            <%=(keyword("kwd_name"))%><br />
            <%
keyword.MoveNext()
Wend

keyword.Close
Set keyword = Nothing
%>
          </td>
          <td class="map"><%=(station("stn_map"))%></td>
          <td><%=(station("stn_count"))%></td>
          <td>
            <%
Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT cmt_id, cmt_stationid FROM comment WHERE cmt_stationid = " & station("stn_id")
comment.Open sql,conn,1,1
%>
		    <%=(comment.recordcount)%>
            <%
comment.Close
Set comment = Nothing
%>
          </td>
          <td><a href="#">删除</a></td>
          <td><a href="?admin=station&amp;station=<%=(station("stn_id"))%>">修改</a></td>
        </tr>
        <%
station.MoveNext()
Wend
%>
      </tbody>
    </table>
    <%
station.Close
Set station = Nothing
%>
    <% ElseIf Request("station") <> "" Then %>
    <%
Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station WHERE stn_id = " & Request("station")
station.Open sql,conn,1,1
%>
    <form id="station" method="post" action="action/station-update.asp">
      <fieldset>
        <legend>车站 - <%=(station("stn_name"))%> <a href="../search.asp?q=<%=Server.URLEncode(station("stn_name"))%>">[查看]</a></legend>
        <p>
          <label for="stationId">编号:</label>
          <input id="stationId" name="stationId" readonly="readonly" value="<%=(station("stn_id"))%>" />
        </p>
        <p>
          <label for="stationCityid">城市:</label>
          <select id="stationCityid" name="stationCityid">
            <%
Set city = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city"
city.Open sql,conn,1,1

While (NOT city.EOF)
%>
            <option value="<%=(city("cty_id"))%>"<% If city("cty_id") = station("stn_cityid") Then %> selected="selected"<% End If %>><%=(city("cty_name"))%></option>
            <%
city.MoveNext()
Wend

city.Close
Set city = Nothing
%>
            <option value="0">-</option>
          </select>
        </p>
        <p>
          <label for="stationName">车站:</label>
          <input id="stationName" name="stationName" value="<%=(station("stn_name"))%>" />
        </p>
        <p>
          <label for="stationLetter">首字母:</label>
          <input id="stationLetter" name="stationLetter" value="<%=(station("stn_letter"))%>" />
        </p>
        <p>
          <label for="stationMap">定位:</label>
          <input id="stationMap" name="stationMap" value="<%=(station("stn_map"))%>" />
        </p>
        <p>
          <label for="stationCoordinate">坐标:</label>
          <input id="stationCoordinate" name="stationCoordinate" value="<%=(station("stn_coordinate"))%>" />
          <span id="getLatLng" title="Google地理解析"></span>
        </p>
        <p>
          <label for="stationMaster">地主:</label>
          <input id="stationMaster" name="stationMaster" value="<%=(station("stn_Master"))%>" />
        </p>
		<p>
          <label for="stationPic">图片:</label>
          <input id="stationPic" name="stationPic" value="<%=(station("stn_pic"))%>" />
        </p>
        <p>
          <label for="stationCount">点击:</label>
          <input id="stationCount" name="stationCount" value="<%=(station("stn_count"))%>" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>请填写大写字母；</li>
          <li>如果Google API地理解析不能得出坐标或地图指示位置有误，请填写定位信息，如“南山区飞亚达大厦”；</li>
          <li>请确保红色的坐标与输入框中的一致，如果不同请复制（不要括号）重新提交。</li>
        </ol>
      </fieldset>
    </form>
<%
If station("stn_cityid") <> "" Then
Set city = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city WHERE cty_id = " & station("stn_cityid")
city.Open sql,conn,1,1
%>
<script type="text/javascript">
window.onload = function() {
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("map_canvas"));
		map.enableScrollWheelZoom();               //滚轮缩放
		map.enableContinuousZoom();                //平滑缩放
		
		var geocoder = new GClientGeocoder();
		
	}
	if (geocoder) {
		geocoder.getLatLng(
			address = "<%=(city("cty_name"))%><% If station("stn_map") <> "" Then %><%=(station("stn_map"))%><% Else %><%=(station("stn_name"))%>站<% End If %>",
			function(point) {
				if (!point) {
				//alert(address + " not found");
				} else {
					map.setCenter(point, 15);
					var marker = new GMarker(point);
					map.addOverlay(marker);
					marker.openInfoWindowHtml(address);
				}
			}
		);
		geocoder.getLatLng('<%=(city("cty_name"))%><% If station("stn_map") <> "" Then %><%=(station("stn_map"))%><% Else %><%=(station("stn_name"))%>站<% End If %>', function(response) {
			document.getElementById("getLatLng").innerHTML += response;
		});
	}
}
</script>
<%
city.Close
Set city = Nothing
End If
%>
    <div id="map_canvas"></div>
    <%
Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword WHERE kwd_stationid = " & station("stn_id")
keyword.Open sql,conn,1,1

If Not keyword.EOF Then 
%>
    <div class="keywordList">
      <h2>车站周边</h2>
      <table>
        <thead>
          <tr>
            <th>编号</th>
            <th>类别</th>
            <th>名称</th>
            <th>删除</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT keyword.EOF)
%>
          <tr>
            <td><%=(keyword("kwd_id"))%></td>
            <td>-</td>
            <td class="keyword"><%=(keyword("kwd_name"))%></td>
            <td><a href="action/keyword-delete.asp?station=<%=(station("stn_id"))%>&amp;keyword=<%=(keyword("kwd_id"))%>" onclick="return confirm('确定要删除吗?');">删除</a></td>
          </tr>
          <%
keyword.MoveNext()
Wend
%>
        </tbody>
      </table>
    </div>
    <%
End If

keyword.Close
Set keyword = Nothing
%>
    <div class="keywordList">
      <h2>新增周边</h2>
      <form id="keyword" method="post" action="action/keyword-new.asp">
        <p>
          <label for="keywordCategory">类别:</label>
          <select id="keywordCategory" disabled="disabled">
            <option>暂不提供</option>
          </select>
        </p>
        <p>
          <label for="keywordName">周边:</label>
          <input id="keywordName" name="keywordName" />
        </p>
        <p>
          <input name="keywordStationid" type="hidden" value="<%=(station("stn_id"))%>" />
          <button>提交</button>
        </p>
        <ol>
          <li>周边的作用是，在用户不能准确输入车站名称时，可以通过搜索例如小区名等车站周边信息而准确定位到附近车站；</li>
          <li>最常见且易被搜索到的周边信息，如：小区名、商场、超市、地标等。</li>
        </ol>
      </form>
    </div>
    <%
station.Close
Set station = Nothing
%>
    <% ElseIf Request("admin") = "city" Then %>
    <%
Set city = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city"
city.Open sql,conn,1,1
%>
    <div class="cityList">
      <h2>城市列表</h2>
      <table>
        <thead>
          <tr>
            <th>编号</th>
            <th>城市</th>
            <th>删除</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT city.EOF)
%>
          <tr>
            <td><%=(city("cty_id"))%></td>
            <td><%=(city("cty_name"))%></td>
            <td><a href="#">删除</a></td>
          </tr>
          <%
city.MoveNext()
Wend
%>
        </tbody>
      </table>
    </div>
    <%
city.Close
Set city = Nothing
%>
    <div class="cityList">
      <h2>新增城市</h2>
      <form id="city" method="post" action="action/city-new.asp">
        <p>
          <label for="cityId">编号:</label>
          <input id="cityId" name="cityId" />
        </p>
        <p>
          <label for="cityName">城市:</label>
          <input id="cityName" name="cityName" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>编号不能与左侧已有编号相同，请手动输入（建议递增）。</li>
        </ol>
      </form>
    </div>
    <% ElseIf Request("admin") = "category" Then %>
    <%
Set category = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category"
category.Open sql,conn,1,1
%>
    <div class="categoryList">
      <h2>分类列表</h2>
      <table>
        <thead>
          <tr>
            <th>编号</th>
            <th>城市</th>
            <th>时段</th>
            <th>分类</th>
            <th>删除</th>
            <th>修改</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT category.EOF)
%>
          <tr>
            <td><%=(category("ctr_id"))%></td>
            <td>
              <%
Set city = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city WHERE cty_id = " & category("ctr_cityid")
city.Open sql,conn,1,1
%>
              <%=(city("cty_name"))%>
              <%
city.Close
Set city = Nothing
%>
            </td>
            <td><% If category("ctr_sort") = 1 Then %>上班班车<% ElseIf category("ctr_sort") = 2 Then %>下班班车<% Else %>夜间班车<% End If %></td>
            <td><%=(category("ctr_name"))%></td>
            <td><a href="#">删除</a></td>
            <td><a href="#">修改</a></td>
          </tr>
          <%
category.MoveNext()
Wend
%>
        </tbody>
      </table>
    </div>
    <%
category.Close
Set category = Nothing
%>
    <div class="categoryList">
      <h2>新增分类</h2>
      <form id="city" method="post" action="action/category-new.asp">
        <p>
          <label for="categoryId">编号:</label>
          <input id="categoryId" name="categoryId" class="short" />
        </p>
        <p>
          <label for="categoryCityid">城市:</label>
          <select id="categoryCityid" name="categoryCityid">
            <%
Set city = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM city"
city.Open sql,conn,1,1

While (NOT city.EOF)
%>
            <option value="<%=(city("cty_id"))%>"><%=(city("cty_name"))%></option>
            <%
city.MoveNext()
Wend

city.Close
Set city = Nothing
%>
          </select>
        </p>
         <p>
          <label for="categorySort">时段:</label>
          <select id="categorySort" name="categorySort">
            <option value="1">上班班车</option>
            <option value="2">下班班车</option>
            <option value="3">夜间班车</option>
          </select>
        </p>
        <p>
          <label for="categoryName">分类:</label>
          <input id="categoryName" name="categoryName" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>编号不能与左侧已有编号相同，请手动输入（建议递增）。</li>
        </ol>
      </form>
    </div>
    <% ElseIf Request("admin") = "time" Then %>
    <%
Set tim = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM tim"
tim.Open sql,conn,1,1
%>
    <div class="timeList">
      <h2>时间列表</h2>
      <table>
        <thead>
          <tr>
            <th>编号</th>
            <th>时间</th>
            <th>删除</th>
            <th>修改</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT tim.EOF)
%>
          <tr>
            <td><%=(tim("tim_id"))%></td>
            <td><% If tim("tim_name") = "0" Then %>没有<% Else %><%=(tim("tim_name"))%><% End If %></td>
            <td><% If tim("tim_name") <> "0" Then %><a href="#">删除</a><% End If %></td>
            <td><% If tim("tim_name") <> "0" Then %><a href="#">修改</a><% End If %></td>
          </tr>
          <%
tim.MoveNext()
Wend
%>
        </tbody>
      </table>
      <%
tim.Close
Set tim = Nothing
%>
    </div>
    <div class="timeList">
      <h2>新增时间</h2>
      <form id="city" method="post" action="action/time-new.asp">
        <p>
          <label for="timeId">编号:</label>
          <input id="timeId" name="timeId" />
        </p>
        <p>
          <label for="timeName">时间:</label>
          <input id="timeName" name="timeName" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>编号不能与左侧已有编号相同，请手动输入（建议递增）。</li>
        </ol>
      </form>
    </div>
    <% ElseIf Request("admin") = "member" AND Request("member") = "" Then %>
    <%
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM member"
member.Open sql,conn,1,1
%>
    <table>
      <thead>
        <tr>
          <th>编号</th>
          <th>RTX昵称</th>
          <th>博客</th>
          <th>头像</th>
          <th>评论数</th>
          <th>志愿者</th>
          <th>小红花</th>
          <th>权限</th>
          <th>时间</th>
          <th>修改</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT member.EOF)
%>
        <tr>
          <td><%=(member("mbr_id"))%></td>
          <td class="member"><%=(member("mbr_name"))%></td>
          <td class="blog"><%=(member("mbr_blog"))%></td>
          <td class="face"><%=(member("mbr_face"))%></td>
          <td>
            <%
Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT cmt_id, cmt_memberid FROM comment WHERE cmt_memberid = " & member("mbr_id")
comment.Open sql,conn,1,1
%>
		    <%=(comment.recordcount)%>
            <%
comment.Close
Set comment = Nothing
%>
          </td>
          <td class="volunteer">
            <%
If member("mbr_flower") <> "" Then
Set volunteer = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_memberid, bus_name FROM bus WHERE bus_memberid = " & member("mbr_id")
volunteer.Open sql,conn,1,1

While (NOT volunteer.EOF)
%>
            <a href="?admin=bus&amp;bus=<%=(volunteer("bus_id"))%>"><%=(volunteer("bus_name"))%></a>
            <%
volunteer.MoveNext()
Wend

volunteer.Close
Set volunteer = Nothing
End If
%>
          </td>
          <td><%=(member("mbr_flower"))%></td>
          <td><%=(member("mbr_admin"))%></td>
          <td class="time"><%=(member("mbr_time"))%></td>
          <td><a href="?admin=member&amp;member=<%=(member("mbr_id"))%>">修改</a></td>
        </tr>
        <%
member.MoveNext()
Wend
%>
      </tbody>
    </table>
    <%
member.Close
Set member = Nothing
%>
    <% ElseIf Request("member") Then %>
    <% If Session("member_admin") = "2" Then %>
    <%
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM member WHERE mbr_id = " & Request("member")
member.Open sql,conn,1,1
%>
    <form id="member" method="post" action="action/member-update.asp">
      <fieldset>
        <legend>用户 - <%=(member("mbr_name"))%></legend>
        <p>
          <label for="memberId">编号:</label>
          <input id="memberId" name="memberId" readonly="readonly" value="<%=(member("mbr_id"))%>" />
        </p>
        <p>
          <label for="memberName">昵称:</label>
          <input id="memberName" name="memberName" value="<%=(member("mbr_name"))%>" />
        </p>
        <p>
          <label for="memberBlog">博客:</label>
          <input id="memberBlog" name="memberBlog" value="<%=(member("mbr_blog"))%>" />
        </p>
        <p>
          <label for="memberFace">头像:</label>
          <input id="memberFace" name="memberFace" value="<%=(member("mbr_face"))%>" />
        </p>
        <p>
          <label for="memberFlower">小红花:</label>
          <input id="memberFlower" name="memberFlower" value="<%=(member("mbr_flower"))%>" />
        </p>
        <p>
          <label for="memberAdmin">权限:</label>
          <input id="memberAdmin" name="memberAdmin" value="<%=(member("mbr_admin"))%>" />
        </p>
        <p>
          <label for="memberPassword">密码:</label>
          <input id="memberPassword" name="memberPassword" type="password" />
        </p>
        <p>
          <button>提交</button>
        </p>
        <ol>
          <li>权限中1为志愿者、2为管理员；</li>
          <li>密码若不修改则留空。</li>
        </ol>
      </fieldset>
    </form>
<%
member.Close
Set member = Nothing
%>
    <% Else %>
    很遗憾，没有权限，如需操作请联系fishhuang。
    <% End If %>
    <% ElseIf Request("admin") = "comment" Then %>
    <%
Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM comment ORDER BY cmt_id DESC"
comment.Open sql,conn,1,1
pgsize = 50
page = Request("page")
comment.Pagesize = pgsize
pgnm = comment.pageCount
If page = "" Or Clng(page) < 1 Then page = 1
If CLng(page) > pgnm Then page = pgnm
If pgnm > 0 Then comment.AbsolutePage = page
Count = 0
%>
    <ul class="tab">
      <% If Int(page) <> 1 Then %><li><a href="?admin=comment&amp;page=<%=(page - 1)%>">上一页</a></li><% End If %>
      <% If Int(page) <> comment.pageCount Then %><li><a href="?admin=comment<%=q%>&amp;page=<%=(page + 1)%>">下一页</a></li><% End If %>
    </ul>
    <table>
      <thead>
        <tr>
          <th>编号</th>
          <th>RTX昵称</th>
          <th>班车/车站</th>
          <th>回复</th>
          <th>评论</th>
          <th>小红花</th>
          <th>IP</th>
          <th>时间</th>
          <th>删除</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT comment.EOF) And (comment_count < comment.PageSize)
%>
        <tr>
          <td><%=(comment("cmt_id"))%></td>
          <td class="member">
		    <%
Set member = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name FROM member WHERE mbr_id = " & comment("cmt_memberid")
member.Open sql,conn,1,1
%>
            <%=(member("mbr_name"))%>
            <%
member.Close
Set member = Nothing
%>
          </td>
          <td class="busStation">
            <%
If comment("cmt_busid") <> "" Then
Set bus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_name FROM bus WHERE bus_id = " & comment("cmt_busid")
bus.Open sql,conn,1,1
%>
            <a href="../search.asp?q=<%=(bus("bus_name"))%>"><%=(bus("bus_name"))%></a>
            <%
bus.Close
Set bus = Nothing
%>
            <% Else %>
            <%
Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_name FROM station WHERE stn_id = " & comment("cmt_stationid")
station.Open sql,conn,1,1
%>
            <a href="../search.asp?q=<%=Server.URLEncode(station("stn_name"))%>"><%=(station("stn_name"))%></a>
            <%
station.Close
Set station = Nothing
%>
            <% End If %>
          </td>
          <td><%=(comment("cmt_commentid"))%></td>
          <td class="message"><%=(comment("cmt_message"))%></td>
          <td><%=(comment("cmt_flower"))%></td>
          <td class="ip"><%=(comment("cmt_ip"))%></td>
          <td class="time"><%=(comment("cmt_time"))%></td>
          <td><a href="#">删除</a></td>
        </tr>
        <%
comment_count = comment_count + 1
comment.MoveNext()
Wend
%>
      </tbody>
    </table>
    <ul class="tab">
      <% If Int(page) <> 1 Then %><li><a href="?admin=comment&amp;page=<%=(page - 1)%>">上一页</a></li><% End If %>
      <% If Int(page) <> comment.pageCount Then %><li><a href="?admin=comment<%=q%>&amp;page=<%=(page + 1)%>">下一页</a></li><% End If %>
    </ul>
    <%
comment.Close
Set comment = Nothing
%>
    <% ElseIf Request("admin") = "search" Then %>
    <%
Set search = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM search ORDER BY src_id DESC"
search.Open sql,conn,1,1
pgsize = 50
page = Request("page")
search.Pagesize = pgsize
pgnm = search.pageCount
If page = "" Or Clng(page) < 1 Then page = 1
If CLng(page) > pgnm Then page = pgnm
If pgnm > 0 Then search.AbsolutePage = page
Count = 0
%>
    <ul class="tab">
      <% If Int(page) <> 1 Then %><li><a href="?admin=search&amp;page=<%=(page - 1)%>">上一页</a></li><% End If %>
      <% If Int(page) <> search.pageCount Then %><li><a href="?admin=search<%=q%>&amp;page=<%=(page + 1)%>">下一页</a></li><% End If %>
    </ul>
    <table>
      <thead>
        <tr>
          <th>编号</th>
          <th>关键字</th>
          <th>时间</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT search.EOF) And (search_count < search.PageSize)
%>
        <tr>
          <td><%=(search("src_id"))%></td>
          <td class="keyword"><%=(search("src_keyword"))%></td>
          <td class="time"><%=(search("src_time"))%></td>
        </tr>
        <%
search_count = search_count + 1
search.MoveNext()
Wend
%>
      </tbody>
    </table>
    <ul class="tab">
      <% If Int(page) <> 1 Then %><li><a href="?admin=search&amp;page=<%=(page - 1)%>">上一页</a></li><% End If %>
      <% If Int(page) <> search.pageCount Then %><li><a href="?admin=search<%=q%>&amp;page=<%=(page + 1)%>">下一页</a></li><% End If %>
    </ul>
    <%
search.Close
Set search = Nothing
%>
    <% ElseIf Request("admin") = "operate" Then %>
    <% If Session("member_admin") = "2" Then %>
    <%
Set operate = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM operate ORDER BY ort_id DESC"
operate.Open sql,conn,1,1
%>
    <table>
      <thead>
        <tr>
          <th>编号</th>
          <th>操作</th>
          <th>时间</th>
        </tr>
      </thead>
      <tbody>
        <%
While (NOT operate.EOF)
%>
        <tr>
          <td><%=(operate("ort_id"))%></td>
          <td class="operate"><%=(operate("ort_content"))%></td>
          <td class="time"><%=(operate("ort_time"))%></td>
        </tr>
        <%
operate.MoveNext()
Wend
%>
      </tbody>
    </table>
    <%
operate.Close
Set operate = Nothing
%>
    <% Else %>
    很遗憾，没有权限，如需操作请联系fishhuang。
    <% End If %>
    <% End If %>
  </div>
</div>
<script src="http://maps.google.cn/maps?file=api&amp;v=2.x&amp;key=ABQIAAAADZXjIBRa_7cEg6jFjsBs3hS9WAeoFsB_nJrUiU1D02YqrSAv2hRrgmprNZTtcsnMxYN4c0p88RVZaQ" type="text/javascript"></script>
</body>
</html>
