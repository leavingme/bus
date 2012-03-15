<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="inc/data.asp" -->
<%
Set search = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT Top 3 * FROM search ORDER BY src_id DESC"
search.Open sql,conn,1,1
%>
<%
Set record = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT Top 3 * FROM search WHERE	src_ip LIKE '%" & Request.SerVerVariables("REMOTE_ADDR") & "%'" & " ORDER BY src_id DESC"
record.Open sql,conn,1,1
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="keywords" content="班车, 地图, 搜索" />
<meta name="description" content="我爱坐班车 - 有地图的班车搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
<meta name="author" content="Huang Hong - design-hong.com huanghong@hotmail.com" />
<title>我爱坐班车 有地图的班车搜索</title>
<link rel="stylesheet" type="text/css" href="style/basic.css" />
<link rel="stylesheet" type="text/css" href="style/default.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
</head>
<body>
<div id="header" class="box">
  <ul class="nav">
    <li class="current"><a class="sitename" href="/">我爱坐班车</a><a class="city" href="javascript:void(0);" onclick="show('city');">[<%=(Request.Cookies("cityName"))%>]</a>
      <ul id="city" class="city">
        <li><a href="/?city=sz">深圳</a></li>
        <li><a href="/?city=bj">北京</a></li>
        <li><a href="/?city=cd">成都</a></li>
        <li><a href="/?city=sh">上海</a></li>
        <li><a href="/?city=gz">广州</a></li>
      </ul>
    </li>
  <% If Request.Cookies("cityId") = 1 Then %>
    <li><a href="list.asp?list=time">按时间</a></li>
    <li><a href="list.asp?list=bus">按路线</a></li>
    <li><a href="list.asp?list=station">按站点</a></li>
    <li><a href="list.asp?list=hot">按热门</a></li>
    <li><a href="list.asp?list=flower">小红花</a></li>
	<li class="new"><a href="list.asp?list=house">班车进小区</a></li>
	<li class="new"><a href="map.asp">V2(demo)</a></li>
  </ul>
  <p class="notice"><a href="javascript:void(0);" onclick="show('pop');">招志愿者</a></p>
  <p class="magazine"><a href="doc/eMagazine_3.exe">《热腾》第三期</a></p>
  <!--<p class="android"><a href="doc/bus.oa.com.apk">Android</a></p>
  <p class="iphone"><a href="iphone.html" target="_blank">iPhone</a></p>-->
  <p class="photo"><a href="photo.asp">为班车站拍照</a></p>
  <p class="soso"><a href="sosomap.html">班车街景</a></p>
  <p class="cloud"><a href="cloud.asp" target="_blank">云班车手册</a></p>
  <% ElseIf Request.Cookies("cityId") = 2 Then %>
    <li><a href="search.asp?q=S1">东三环线</a></li>
    <li><a href="search.asp?q=S2">朝阳北路线</a></li>
    <li><a href="search.asp?q=S3">通州线</a></li>
    <li><a href="search.asp?q=S4">西三环线</a></li>
    <li><a href="search.asp?q=S5">大兴线</a></li>
    <li><a href="search.asp?q=S6">石景山线</a></li>
    <li><a href="search.asp?q=S7">西三旗线</a></li>
    <li><a href="search.asp?q=S8">天通苑线</a></li>
    <li><a href="search.asp?q=S9">回龙观线</a></li>
    <li><a href="search.asp?q=S10">北苑线</a></li>
  </ul>
  <p class="doc"><a href="doc/bj_20100820.doc">班车手册</a></p>
  <% ElseIf Request.Cookies("cityId") = 3 Then %>
    <li><a href="search.asp?q=S">上班班车</a> <a href="search.asp?q=K">上班班车(K)</a></li>
    <li><a href="search.asp?q=X">下班班车</a></li>
    <li><a href="search.asp?q=Y">夜间班车</a></li>
  </ul>
  <p class="doc"><a href="doc/cd_20100823.doc">班车手册</a></p>
  <% ElseIf Request.Cookies("cityId") = 4 Then %>
    <li><a href="search.asp?q=S">上班班车</a></li>
    <li><a href="search.asp?q=X">下班班车</a></li>
  </ul>
  <p class="doc"><a href="doc/sh_20100603.doc">班车手册</a></p>
  <% ElseIf Request.Cookies("cityId") = 5 Then %>
    <li>暂无班车</li>
  </ul>
  <% End If %>
</div>
<div id="main" class="default">
  <form id="searchForm" method="get" action="search.asp">
    <h1>我爱坐班车</h1>
    <p>
      <input id="q" name="q" title="输入班车、车站或周边..." />
      <input name="search" type="hidden" value="1" />
      <button title="搜索" type="submit">搜索</button>
    </p>
	<% If NOT record.EOF Then %>
	<dl>
      <dt>我的搜索 -</dt>
      <%
While (NOT record.EOF)
%>
      <dd><a href="search.asp?q=<%=Server.URLEncode(record("src_keyword"))%>"><%=(record("src_keyword"))%></a></dd>
      <%
record.MoveNext()
Wend
%>
    </dl>
	<% Else %>
    <dl>
      <dt>最新搜索 -</dt>
      <%
While (NOT search.EOF)
%>
      <dd><a href="search.asp?q=<%=Server.URLEncode(search("src_keyword"))%>"><%=(search("src_keyword"))%></a></dd>
      <%
search.MoveNext()
Wend
%>
    </dl>
	<% End If %>
	<p class="update">2012-01-17更新数据</p>
  </form>
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
search.Close
Set search = Nothing
%>
<%
record.Close
Set record = Nothing
%>
