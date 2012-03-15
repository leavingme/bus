<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="inc/data.asp" -->
<%
If Request("list") = "time" Then
  condition = "SELECT * FROM tim"
ElseIf Request("list") = "bus" Then
  If Request("q") = "" Then
    condition = "SELECT * FROM category"
  Else
    condition = "SELECT bus_id, bus_name, bus_count FROM bus WHERE bus_name LIKE '%" & Request("q") & "%'"
  End If
ElseIf Request("list") = "station" Then
  condition = "SELECT stn_id, stn_name, stn_letter, stn_count FROM station WHERE stn_letter LIKE '%" & Request("q") & "%'" & " ORDER BY stn_count DESC"
ElseIf Request("list") = "hot" Then

Randomize()
dim i,DispRecord
i = 0
DispRecord = 200
condition = "SELECT stn_id, stn_cityid, stn_name, stn_count FROM station WHERE stn_cityid = 1 And stn_name <> '0' UNION ALL SELECT bus_id, bus_categoryid, bus_name, bus_count FROM bus WHERE bus_categoryid = 1"

ElseIf Request("list") = "flower" Then
  condition = "SELECT mbr_id, mbr_name, mbr_flower From member WHERE mbr_flower is not null ORDER BY mbr_flower DESC"
ElseIf Request("list") = "house" Then
  condition = "SELECT stn_id, stn_name, stn_count FROM station ORDER BY stn_count DESC"
End If

Set list = Server.CreateObject("ADODB.RECORDSET")
sql = condition
list.Open sql,conn,1,1
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="keywords" content="班车, 地图, 搜索" />
<meta name="description" content="我爱坐班车 - 有地图的班车搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
<meta name="author" content="Huang Hong - design-hong.com huanghong@hotmail.com" />
<title><% If Request("list") = "time" Then %>按时间排序<% ElseIf Request("list") = "bus" Then %>按路线排序<% ElseIf Request("list") = "station" Then %>按站点排序<% ElseIf Request("list") = "hot" Then %>按热门随机<% ElseIf Request("list") = "flower" Then %>小红花榜单<% ElseIf Request("list") = "house" Then %>班车进小区<% End If %> - 我爱坐班车</title>
<link rel="stylesheet" type="text/css" href="style/basic.css" />
<link rel="stylesheet" type="text/css" href="style/list.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
</head>
<body>
<div id="header" class="box">
  <ul class="nav">
    <li><a class="sitename" href="/">我爱坐班车</a><a class="city" href="javascript:void(0);" onclick="show('city');">[<%=(Request.Cookies("cityName"))%>]</a>
      <ul id="city" class="city">
        <li><a href="/?city=sz">深圳</a></li>
        <li><a href="/?city=bj">北京</a></li>
        <li><a href="/?city=cd">成都</a></li>
        <li><a href="/?city=sh">上海</a></li>
        <li><a href="/?city=gz">广州</a></li>
      </ul>
    </li>
    <li<% If Request("list") = "time" Then %> class="current">按时间<% Else %>><a href="?list=time">按时间</a><% End If %></li>
    <li<% If Request("list") = "bus" Then %> class="current">按路线<% Else %>><a href="?list=bus">按路线</a><% End If %></li>
    <li<% If Request("list") = "station" Then %> class="current">按站点<% Else %>><a href="?list=station">按站点</a><% End If %></li>
    <li<% If Request("list") = "hot" Then %> class="current">按热门<% Else %>><a href="?list=hot">按热门</a><% End If %></li>
    <li<% If Request("list") = "flower" Then %> class="current">小红花<% Else %>><a href="?list=flower">小红花</a><% End If %></li>
	<li class="new<% If Request("list") = "house" Then %> current">班车进小区<% Else %>"><a href="?list=house">班车进小区</a><% End If %></li>
  </ul>
  <p class="notice"><a href="javascript:void(0);" onclick="show('pop');">招志愿者</a></p>
  <p class="magazine"><a href="doc/eMagazine_3.exe">《热腾》第三期</a></p>
  <!--<p class="android"><a href="doc/bus.oa.com.apk">Android</a></p>
  <p class="iphone"><a href="iphone.html" target="_blank">iPhone</a></p>-->
  <p class="photo"><a href="photo.asp">为班车站拍照</a></p>
  <p class="soso"><a href="sosomap.html">班车街景</a></p>
  <p class="cloud"><a href="cloud.asp" target="_blank">云班车手册</a></p>
</div>
<div id="main" class="box">
  <form id="searchForm" class="box" method="get" action="search.asp">
    <h1><a href="/">我爱坐班车</a></h1>
    <p>
      <input id="q" name="q" title="输入班车、车站或周边..." />
      <input name="search" type="hidden" value="1" />
      <button title="搜索" type="submit">搜索</button>
    </p>
  </form>
  <div class="content <%=(Request("list"))%>">
    <% If Request("list") = "bus" Or Request("list") = "station" Or Request("list") = "hot" Then %>
    <dl class="stationLetter box">
      <dt><a<% If (Request("list") = "station" And Request("q") = "") Or Request("list") = "hot" Then %> class="current"<% End If %> href="?list=station">站点</a></dt>
      <dd>
	    <%
str = "A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
str = Split(str,"|")
For i = 0 To Ubound(str)
%>
        <a<% If Request("list") = "station" And Request("q") = str(i) Then %> class="current"<% End If %> href="?list=station&amp;q=<%=(str(i))%>"><%=(str(i))%></a>
        <%
Next
%>
      </dd>
    </dl>
    <dl class="busLetter box">
      <dt><a<% If Request("list") = "time" Or (Request("list") = "bus" And Request("q") = "") Or Request("list") = "hot" Then %> class="current"<% End If %> href="?list=bus">路线</a></dt>
      <dd>
        <%
str = "S|N|Q|F|T"
str = Split(str,"|")
For i = 0 to Ubound(str)
%>
        <a<% If Request("list") = "bus" And Request("q") = str(i) Then %> class="current"<% End If %> href="?list=bus&amp;q=<%=(str(i))%>"><%=(str(i))%></a>
        <%
Next
%>
      </dd>
    </dl>
    <% End If %>
    <% If Not list.EOF Then %>
    <div class="list">
      <% If Request("list") = "time" Then %>
      <h2>按时间排序只有下班、夜间班车</h2>
      <table>
        <thead>
          <tr>
            <th colspan="5" class="t1">腾讯大厦下班班车</th>
            <th colspan="3">飞亚达大厦下班班车</th>
            <th colspan="10">夜间班车</th>
          </tr>
          <tr class="t">
            <th class="t1">18:00</th>
            <th>18:10</th>
            <th>18:20</th>
            <th>18:30</th>
            <th>18:40</th>
            <th>17:50</th>
            <th>18:00</th>
            <th>18:10</th>
			<th>18:50</th>
            <th>19:05</th>
			<th>19:20</th>
            <th>19:35</th>
            <th>19:50</th>
            <th>20:50</th>
            <th>21:05</th>
            <th>21:35</th>
            <th>22:05</th>
            <th>23:15</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="t1"><p><a href="search.asp?q=Q1">Q1</a></p>
              <p><a href="search.asp?q=Q2">Q2</a></p>
              <p><a href="search.asp?q=Q3">Q3</a></p>
              <p><a href="search.asp?q=Q8">Q8</a></p>
			  <p><a href="search.asp?q=Q9A">Q9A</a></p>
			  <p><a href="search.asp?q=Q23">Q23</a></p></td>
            <td><p><a href="search.asp?q=Q4">Q4</a></p>
              <p><a href="search.asp?q=Q5">Q5</a></p>
              <p><a href="search.asp?q=Q7">Q7</a></p>
              <p><a href="search.asp?q=Q9B">Q9B</a></p>
			  <p><a href="search.asp?q=Q10">Q10</a></p>
              <p><a href="search.asp?q=Q11">Q11</a></p>
			  <p><a href="search.asp?q=Q11A">Q11A</a></p></td>
            <td><p><a href="search.asp?q=Q6">Q6</a></p>
              <p><a href="search.asp?q=Q12">Q12</a></p>
              <p><a href="search.asp?q=Q17">Q17</a></p>
              <p><a href="search.asp?q=Q19">Q19</a></p></td>
            <td><p><a href="search.asp?q=Q13">Q13</a></p>
              <p><a href="search.asp?q=Q14">Q14</a></p>
              <p><a href="search.asp?q=Q15">Q15</a></p>
              <p><a href="search.asp?q=Q16">Q16</a></p>
              <p><a href="search.asp?q=Q18">Q18</a></p>
              <p><a href="search.asp?q=Q20">Q20</a></p>
              <p><a href="search.asp?q=Q22">Q22</a></td>
            <td><p><a href="search.asp?q=Q21">Q21</a></p></td>
            <td><p><a href="search.asp?q=F1">F1</a></p>
              <p><a href="search.asp?q=F2">F2</a></p>
              <p><a href="search.asp?q=F3">F3</a></p>
              <p><a href="search.asp?q=F4">F4</a></p>
              <p><a href="search.asp?q=F5">F5</a></p></td>
            <td><p><a href="search.asp?q=F10">F10</a></p>
              <p><a href="search.asp?q=F11">F11</a></p></td>
            <td><p><a href="search.asp?q=F6">F6</a></p>
              <p><a href="search.asp?q=F7">F7</a></p>
              <p><a href="search.asp?q=F8">F8</a></p>
              <p><a href="search.asp?q=F9">F9</a></p></td>
			<td><p><a href="search.asp?q=T11C">T11C</a></p></td>
            <td><p><a href="search.asp?q=T1">T1</a></p>
              <p><a href="search.asp?q=T9A">T9A</a></p>
			  <p><a href="search.asp?q=T9B">T9B</a></p>
			  <p><a href="search.asp?q=T9C">T9C</a></p>
              <p><a href="search.asp?q=T10">T10</a></p>
              <p><a href="search.asp?q=T11A">T11A</a></p>
              <p><a href="search.asp?q=T16">T16</a></p>
              <p><a href="search.asp?q=T20">T20</a></p>
              <p><a href="search.asp?q=T21">T21</a></p>
              <p><a href="search.asp?q=T23">T23</a></p></td>
			<td><p><a href="search.asp?q=T31">T31</a></p></td>
            <td><p><a href="search.asp?q=T2A">T2A</a></p>
			  <p><a href="search.asp?q=T2B">T2B</a></p>
              <p><a href="search.asp?q=T11B">T11B</a></p></td>
            <td><p><a href="search.asp?q=T3">T3</a></p>
              <p><a href="search.asp?q=T17">T17</a></p>
              <p><a href="search.asp?q=T27">T27</a></p>
              <p><a href="search.asp?q=T28">T28</a></p></td>
            <td><p><a href="search.asp?q=T4A">T4A</a></p>
			  <p><a href="search.asp?q=T4B">T4B</a></p>
			  <p><a href="search.asp?q=T4C">T4C</a></p>
              <p><a href="search.asp?q=T12">T12</a></p>
              <p><a href="search.asp?q=T25A">T25A</a></p>
			  <p><a href="search.asp?q=T25B">T25B</a></p>
			  <p><a href="search.asp?q=T25C">T25C</a></p>
              <p><a href="search.asp?q=T26">T26</a></p></td>
            <td><p><a href="search.asp?q=T5A">T5A</a></p>
			  <p><a href="search.asp?q=T5B">T5B</a></p>
              <p><a href="search.asp?q=T13">T13</a></p>
              <p><a href="search.asp?q=T18">T18</a></p>
              <p><a href="search.asp?q=T19">T19</a></p>
              <p><a href="search.asp?q=T22">T22</a></p>
              <p><a href="search.asp?q=T24">T24</a></p>
              <p><a href="search.asp?q=T29A">T29A</a></p>
			  <p><a href="search.asp?q=T29B">T29B</a></p></td>
            <td><p><a href="search.asp?q=T6">T6</a></p>
              <p><a href="search.asp?q=T14">T14</a></p></td>
            <td><p><a href="search.asp?q=T7">T7</a></p></td>
            <td><p><a href="search.asp?q=T8">T8</a></p>
              <p><a href="search.asp?q=T15">T15</a></p></td>
          </tr>
        </tbody>
      </table>
      <% End If %>
      <% If Request("list") = "bus" Then %>
      <table>
        <thead>
          <tr>
            <th colspan="2" class="cate">上班班车</th>
            <th>腾讯大厦下班班车</th>
            <th>飞亚达大厦下班班车</th>
            <th>夜间班车</th>
          </tr>
          <tr class="b">
            <th class="cate">S</th>
            <th>N</th>
            <th>Q</th>
            <th>F</th>
            <th>T</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td class="cate<% If Request("q") = "S" Then %> current<% End If %>"><p><a href="search.asp?q=S1">S1</a> <a href="search.asp?q=S2">S2</a> <a href="search.asp?q=S3">S3</a> <a href="search.asp?q=S4">S4</a> <a href="search.asp?q=S5">S5</a> <a href="search.asp?q=S6">S6</a> <a href="search.asp?q=S7">S7</a> <a href="search.asp?q=S8">S8</a> <a href="search.asp?q=S9">S9</a> <a href="search.asp?q=S10">S10</a></p>
              <p><a href="search.asp?q=S11">S11</a> <a href="search.asp?q=S12">S12</a> <a href="search.asp?q=S13">S13</a> <a href="search.asp?q=S14">S14</a> <a href="search.asp?q=S15">S15</a> <a href="search.asp?q=S16">S16</a> <a href="search.asp?q=S17">S17</a> <a href="search.asp?q=S18">S18</a> <a href="search.asp?q=S19">S19</a> <a href="search.asp?q=S20">S20</a></p>
              <p><a href="search.asp?q=S21">S21</a> <a href="search.asp?q=S22">S22</a> <a href="search.asp?q=S23">S23</a> <a href="search.asp?q=S24">S24</a> <a href="search.asp?q=S25">S25</a> <a href="search.asp?q=S26">S26</a> <a href="search.asp?q=S27">S27</a> <a href="search.asp?q=S28">S28</a> <a href="search.asp?q=S29">S29</a> <a href="search.asp?q=S30">S30</a></p>
			  <p><a href="search.asp?q=S31">S31</a> <a href="search.asp?q=S32">S32</a> <a href="search.asp?q=S33">S33</a> <a href="search.asp?q=S34">S34</a></p></td>
            <td<% If Request("q") = "N" Then %> class="current"<% End If %>><p><a href="search.asp?q=N1">N1</a> <a href="search.asp?q=N2">N2</a> <a href="search.asp?q=N3">N3</a> <a href="search.asp?q=N4">N4</a> <a href="search.asp?q=N5">N5</a> <a href="search.asp?q=N7">N7</a> <a href="search.asp?q=N8">N8</a> <a href="search.asp?q=N9">N9</a> <a href="search.asp?q=N10">N10</a></p>
              <p><a href="search.asp?q=N11">N11</a> <a href="search.asp?q=N12">N12</a> <a href="search.asp?q=N13">N13</a> <a href="search.asp?q=N14">N14</a> <a href="search.asp?q=N15">N15</a> <a href="search.asp?q=N16">N16</a> <a href="search.asp?q=N17">N17</a> <a href="search.asp?q=N18">N18</a> <a href="search.asp?q=N19">N19</a> <a href="search.asp?q=N20">N20</a></p>
              <p><a href="search.asp?q=N21">N21</a> <a href="search.asp?q=N22">N22</a> <a href="search.asp?q=N23">N23</a> <a href="search.asp?q=N24">N24</a> <a href="search.asp?q=N25">N25</a> <a href="search.asp?q=N26">N26</a> <a href="search.asp?q=N27">N27</a> <a href="search.asp?q=N28">N28</a> <a href="search.asp?q=N29">N29</a> <a href="search.asp?q=N30">N30</a></p>
              <p><a href="search.asp?q=N31">N31</a> <a href="search.asp?q=N32">N32</a> <a href="search.asp?q=N33">N33</a> <a href="search.asp?q=N34">N34</a> <a href="search.asp?q=N35">N35</a> <a href="search.asp?q=N36">N36</a> <a href="search.asp?q=N37">N37</a> <a href="search.asp?q=N38">N38</a> <a href="search.asp?q=N39">N39</a> <a href="search.asp?q=N40">N40</a></p>
			  <p><a href="search.asp?q=N41">N41</a> <a href="search.asp?q=N42">N42</a></p></td>
            <td<% If Request("q") = "Q" Then %> class="current"<% End If %>><p><a href="search.asp?q=Q1">Q1</a> <a href="search.asp?q=Q2">Q2</a> <a href="search.asp?q=Q3">Q3</a> <a href="search.asp?q=Q4">Q4</a> <a href="search.asp?q=Q5">Q5</a> <a href="search.asp?q=Q6">Q6</a> <a href="search.asp?q=Q7">Q7</a> <a href="search.asp?q=Q8">Q8</a> <a href="search.asp?q=Q9">Q9</a> <a href="search.asp?q=Q10">Q10</a></p>
              <p><a href="search.asp?q=Q11">Q11</a> <a href="search.asp?q=Q12">Q12</a> <a href="search.asp?q=Q13">Q13</a> <a href="search.asp?q=Q14">Q14</a> <a href="search.asp?q=Q15">Q15</a> <a href="search.asp?q=Q16">Q16</a> <a href="search.asp?q=Q17">Q17</a> <a href="search.asp?q=Q18">Q18</a> <a href="search.asp?q=Q19">Q19</a> <a href="search.asp?q=Q20">Q20</a></p>
              <p><a href="search.asp?q=Q21">Q21</a> <a href="search.asp?q=Q22">Q22</a></p></td>
            <td<% If Request("q") = "F" Then %> class="current"<% End If %>><p>市区 - <a href="search.asp?q=F1">F1</a> <a href="search.asp?q=F2">F2</a> <a href="search.asp?q=F3">F3</a> <a href="search.asp?q=F4">F4</a> <a href="search.asp?q=F5">F5</a></p>
              <p>南山 - <a href="search.asp?q=F6">F6</a> <a href="search.asp?q=F7">F7</a> <a href="search.asp?q=F8">F8</a> <a href="search.asp?q=F9">F9</a></p>
              <p>宝安 - <a href="search.asp?q=F10">F10</a> <a href="search.asp?q=F11">F11</a></p></td>
            <td<% If Request("q") = "T" Then %> class="current"<% End If %>><p><a href="search.asp?q=T1">T1</a> <a href="search.asp?q=T2">T2</a> <a href="search.asp?q=T3">T3</a> <a href="search.asp?q=T4">T4</a> <a href="search.asp?q=T5">T5</a> <a href="search.asp?q=T6">T6</a> <a href="search.asp?q=T7">T7</a> <a href="search.asp?q=T8">T8</a> <a href="search.asp?q=T9">T9</a> <a href="search.asp?q=T10">T10</a></p>
              <p><a href="search.asp?q=T11">T11</a> <a href="search.asp?q=T12">T12</a> <a href="search.asp?q=T13">T13</a> <a href="search.asp?q=T14">T14</a> <a href="search.asp?q=T15">T15</a> <a href="search.asp?q=T16">T16</a> <a href="search.asp?q=T17">T17</a> <a href="search.asp?q=T18">T18</a> <a href="search.asp?q=T19">T19</a> <a href="search.asp?q=T20">T20</a></p>
              <p><a href="search.asp?q=T21">T21</a> <a href="search.asp?q=T22">T22</a> <a href="search.asp?q=T23">T23</a> <a href="search.asp?q=T24">T24</a> <a href="search.asp?q=T25">T25</a> <a href="search.asp?q=T26">T26</a> <a href="search.asp?q=T27">T27</a> <a href="search.asp?q=T27">T27</a> <a href="search.asp?q=T28">T28</a> <a href="search.asp?q=T29">T29</a> <a href="search.asp?q=T29">T31</a></p></td>
          </tr>
        </tbody>
      </table>
      <% End If %>
      <% If Request("list") = "station" Then %>
      <ul>
      <%
While (NOT list.EOF)
%>
        <li<% If list("stn_count") >= 20 And list("stn_count") < 50 Then %> class="h1"<% ElseIf list("stn_count") >= 50 And list("stn_count") < 100 Then %> class="h2"<% ElseIf list("stn_count") >= 100 Then %> class="h3"<% End If %>><a href="search.asp?q=<%=Server.URLEncode(list("stn_name"))%>"><%=(list("stn_name"))%></a></li>
        <%
list.MoveNext()
Wend
%>
      </ul>
      <% End If %>
      <% If Request("list") = "hot" Then %>
      <ul>
      <%
lngCount = list.RecordCount
Redim idList(lngCount)
While i<DispRecord
lngRnd = Int((lngCount * Rnd) + 1)
list.AbsolutePosition = lngRnd
If isEmpty(idList(lngRnd)) Then
%>
        <li<% If list("stn_count") >= 20 And list("stn_count") < 50 Then %> class="h1"<% ElseIf list("stn_count") >= 50 And list("stn_count") < 100 Then %> class="h2"<% ElseIf list("stn_count") >= 100 Then %> class="h3"<% End If %>><a href="search.asp?q=<%=Server.URLEncode(list("stn_name"))%>"><%=(list("stn_name"))%></a></li>
        <%
idList(lngRnd) = 1
i = i + 1
End If
Wend
%>
      </ul>
      <% End If %>
      <% If Request("list") = "flower" Then %>
	  <h2>我爱坐班车兴趣小组</h2>
      <ul>
        <li>
          <h3><strong>我爱坐班车兴趣小组</strong> - fishhuang benjaminli robbieouyang sunnyliu milochen</h3>
		  <p>各种好玩的新功能。</p>
        </li>
        <li>
		  <h3><strong>bus 1.0 (2011.05 - 2011.02)</strong> - fishhuang 基于Google Map API v2</h3>
		  <p>已经实现：风格与标识、班车搜索、周边搜索、路线描绘、数据列表、社交评论、关键词维护、多城市，<a href="about.html" target="_blank">《内测汇报_20110712》</a></p>
		</li>
      </ul>
      <h2>向各位无私奉献的班车志愿者表示感谢！下面公布获得的小红花榜单..</h2>
      <table>
        <thead>
          <tr>
            <th class="rank">排名</th>
            <th>昵称</th>
            <th class="num"><span>小红花</span></th>
            <th>负责路线</th>
          </tr>
        </thead>
        <tbody>
          <%
While (NOT list.EOF)
%>
          <tr>
            <td class="rank"><% If list_count + 1 < 4 Then %><span class="r<%=(list_count + 1)%>"><%=(list_count + 1)%></span><% End If %></td>
            <td><%=(list("mbr_name"))%></td>
            <td class="num"><%=(list("mbr_flower"))%></td>
            <td>
            <%
Set bus = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_name, bus_memberid FROM bus WHERE bus_memberid = " & list("mbr_id")
bus.Open sql,conn,1,1
While (NOT bus.EOF)
%>
              <a href="search.asp?q=<%=(bus("bus_name"))%>"><%=(bus("bus_name"))%></a>
              <%
bus.MoveNext()
Wend
bus.Close
Set bus = Nothing
%>
            </td>
          </tr>
          <%
list_count = list_count + 1
list.MoveNext()
Wend
%>
        </tbody>
      </table>
      <% End If %>
      <% If Request("list") = "house" Then %>
      <h2>搬入新家的Ta，也许不知道准确的班车站名 —— 我们共同参与，完善车站周边关键字，给人方便就是给己方便。</h2>
      <div class="stationList">
        <%
q = HTMLEncode2(Request("station"))
If Len(q) > 10 Then
  q = Left(q,10) & ".."
End If

Set station = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_cityid, stn_name, stn_count FROM station WHERE stn_cityid = 1 And stn_name LIKE '%" & q & "%'" & " ORDER BY stn_count DESC"
station.Open sql,conn,1,1
pgsize = 50
page = Request("page")
station.Pagesize = pgsize
pgnm = station.pageCount
If page = "" Or Clng(page) < 1 Then page = 1
If CLng(page) > pgnm Then page = pgnm
If pgnm > 0 Then station.AbsolutePage = page
Count = 0
%>
        <form id="searchStation" method="get" action="">
          <p>
            <input id="list" name="list" type="hidden" value="house" />
            <input id="station" name="station" value="<%=(q)%>" />
            <button type="submit">搜索</button>
          </p>
        </form>
        <% If Not station.EOF Then %>
        <p class="page"><% If Int(page) <> 1 Then %><a href="?list=house&amp;page=<%=(page - 1)%>">上一页</a> <% End If %> <% If Int(page) <> station.pageCount Then %><a href="?list=house&amp;page=<%=(page + 1)%>">下一页</a><% End If %></p>
        <ul>
        <%
While (NOT station.EOF) And (station_count < station.PageSize)
%>
          <li class="box">
            <h3><%=(station("stn_name"))%></h3>
            <p id="houseList<%=(station("stn_id"))%>" class="houseList">
              <%
Set house = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT kwd_id, kwd_name, kwd_stationid, stn_id, stn_name FROM keyword, station WHERE kwd_stationid = " & station("stn_id") & " And kwd_stationid = stn_id"
house.Open sql,conn,1,1

While (NOT house.EOF)
%>
              <% If house("kwd_id") = Int(Request("keyword")) Then %>
              <a class="current" href="search.asp?q=<%=Server.URLEncode(house("kwd_name"))%>" target="_new"><%=(house("kwd_name"))%></a>
              <% Else %>
              <span><%=(house("kwd_name"))%></span> -
              <% End If %>
              <%
house.MoveNext()
Wend

house.Close
Set house = Nothing
%>
              <a href="javascript:void(0);" onclick="hide('houseList<%=(station("stn_id"))%>'); show('houseEdit<%=(station("stn_id"))%>');">修改</a>
            </p>
            <form id="houseEdit<%=(station("stn_id"))%>" class="houseEdit" method="post" action="action/keyword-new.asp?page=<%=(Request("page"))%>&amp;station=<%=(Request("station"))%>">
              <%
Set house = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT kwd_id, kwd_name, kwd_stationid, stn_id, stn_name FROM keyword, station WHERE kwd_stationid = " & station("stn_id") & " And kwd_stationid = stn_id"
house.Open sql,conn,1,1

If Not house.EOF Then
%>
              <p>
			    <%
While (NOT house.EOF)
%>
                <span><%=(house("kwd_name"))%><a class="delete" href="action/keyword-delete.asp?keyword=<%=(house("kwd_id"))%>&amp;page=<%=(Request("page"))%>&amp;station=<%=(Request("station"))%>" onclick="return confirm('确定要删除吗?');">(删除)</a></span> -
                <%
house.MoveNext()
Wend
%>
              </p>
              <%
End If

house.Close
Set house = Nothing
%>
              <p class="new">
                <input id="keywordStationid<%=(station("stn_id"))%>" name="keywordStationid" type="hidden" value="<%=(station("stn_id"))%>" />
                <input id="keywordName<%=(station("stn_id"))%>" name="keywordName" />
                <button type="submit">新增</button>
              </p>
            </form>
          </li>
          <%
station_count = station_count + 1
station.MoveNext()
Wend
%>
	    </ul>
        <p class="page"><% If Int(page) <> 1 Then %><a href="?list=house&amp;page=<%=(page - 1)%>">上一页</a> <% End If %> <% If Int(page) <> station.pageCount Then %><a href="?list=house&amp;page=<%=(page + 1)%>">下一页</a><% End If %></p>
        <% Else %>
        <p>抱歉, [深圳]站没有找到 <%=(q)%> 哦~</p>
		<% End If %>
        <%
station.Close
Set station = Nothing
%>
	  </div>
      <% If Request("keyword") Then %>
      <script type="text/javascript">
      alert("新增成功！红色加粗所示。");
      </script>
      <% End If %>
      <% End If %>
    </div>
    <% Else %>
    <p class="noResults">抱歉, 没有找到哦~</p>
    <% End If %>
  </div>
  <div class="sidebar">
    <ul class="category">
      <li><% If Request("list") = "time" Then %>按时间排序<% Else %><a href="?list=time">按时间排序</a><% End If %></li>
      <li><% If Request("list") = "bus" Then %>按路线排序<% Else %><a href="?list=bus">按路线排序</a><% End If %></li>
      <li><% If Request("list") = "station" Then %>按站点排序<% Else %><a href="?list=station">按站点排序</a><% End If %></li>
      <li><% If Request("list") = "hot" Then %>按热门随机<% Else %><a href="?list=hot">按热门随机</a><% End If %></li>
      <li><% If Request("list") = "flower" Then %>小红花榜单<% Else %><a href="?list=flower">小红花榜单</a><% End If %></li>
	  <li><% If Request("list") = "house" Then %>班车进小区<% Else %><a href="?list=house">班车进小区</a><% End If %></li>
    </ul>
  </div>
</div>
<div id="footer">
  <p>&copy; 2010-2012 <a href="http://isd.tencent.com/">ISD webTeam</a> <a class="go" href="http://isd.tencent.com/?p=32" title="彪叔说，这将是一场革命。">@ 网站重构一组</a></p>
</div>
<div id="pop" class="pop">
  <div class="popBg"></div>
  <div class="popNotice">
    <p class="close"><a href="javascript:void(0);" onclick="hide('pop');">关闭</a></p>
    <div class="info">
      <p>每条路线需一位志愿者——</p>
      <p>志愿者需配备相机、纸笔或同等功能的手机，主要有以下几点工作：</p>
      <ol>
        <li>校对路线/站点</li>
        <li>拍照取景</li>
        <li>记录途经站点周边信息等等……</li>
      </ol>
      <p>欢迎乐于奉献的同学联系 <em>fishhuang</em> 谢谢~</p>
    </div>
  </div>
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
list.Close
Set list = Nothing
%>
