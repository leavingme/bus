<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="inc/data.asp" -->
<%
Set stationMaster = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_name, stn_master, mbr_id, mbr_name, mbr_blog, mbr_face FROM station, member WHERE stn_master = mbr_id ORDER BY stn_id DESC"
stationMaster.Open sql,conn,1,1
%>
<!DOCTYPE HTML>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta name="keywords" content="班车, 地图, 搜索" />
<meta name="description" content="我爱坐班车 - 有地图的班车搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
<meta name="author" content="Huang Hong - design-hong.com huanghong@hotmail.com" />
<title>为班车站拍照 - 我爱坐班车</title>
<link rel="stylesheet" type="text/css" href="style/basic.css" />
<link rel="stylesheet" type="text/css" href="style/about.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
</head>
<body>
<div id="header" class="box">
	<ul class="nav">
		<li><a class="sitename" href="/">我爱坐班车</a><a class="city" href="javascript:void(0);" onclick="show('city');">[深圳]</a>
			<ul id="city" class="city">
				<li><a href="/?city=sz">深圳</a></li>
				<li><a href="/?city=bj">北京</a></li>
				<li><a href="/?city=cd">成都</a></li>
				<li><a href="/?city=sh">上海</a></li>
				<li><a href="/?city=gz">广州</a></li>
			</ul>
		</li>
		<li><a href="list.asp?list=time">按时间</a></li>
		<li><a href="list.asp?list=bus">按路线</a></li>
		<li><a href="list.asp?list=station">按站点</a></li>
		<li><a href="list.asp?list=hot">按热门</a></li>
		<li><a href="list.asp?list=flower">小红花</a></li>
		<li class="new"><a href="list.asp?list=house">班车进小区</a></li>
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
	<div class="content content_weibo">
		<h1><a href="http://t.qq.com/k/%E4%B8%BA%E7%8F%AD%E8%BD%A6%E7%AB%99%E6%8B%8D%E7%85%A7" target="_blank">我爱坐班车 - 为班车站拍照</a></h1>
		<div class="weibo box">
			<ul class="intro">
				<li class="title">随手<a href="http://t.qq.com/k/%E4%B8%BA%E7%8F%AD%E8%BD%A6%E7%AB%99%E6%8B%8D%E7%85%A7" target="_blank">#为班车站拍照#</a></li>
				<li>你的举手之劳方便了他人，不经意间，他人也在帮助自己…</li>
				<li>作为象征性的奖励，你将成为本班车站的地主 —— 圈地行动正在进行，快来和左边的美女抢地主吧！</li>
				<li>世界因你而更美好。</li>
				<li class="data">* “我爱坐班车”自从2010年7月低调上线后（<a href="about.html">查看详细</a>），已经平稳地提供了6万次访问人数，30万次浏览量，6万6千次搜索查询。</li>
			</ul>
			<p class="pic"><img src="pic/station/weibo.jpg" title="为班车站拍照" alt="为班车站拍照" /></p>
		</div>
		<div class="list">
			<h2>地主榜</h2>
			<ol class="box">
				<%
While (NOT stationMaster.EOF)
%>
				<li>
					<p class="master"><a href="search.asp?q=<%=Server.URLEncode(stationMaster("stn_name"))%>"><img src="<%=(stationMaster("mbr_face"))%>" title="<%=(stationMaster("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>" alt="<%=(stationMaster("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>" /></a> <a class="name" href="search.asp?q=<%=Server.URLEncode(stationMaster("stn_name"))%>" title="<%=(stationMaster("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>">地主 - <%=(stationMaster("mbr_name"))%></a></p>
				</li>
				<%
stationMaster.MoveNext()
Wend
%>
			</ol>
		</div>
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
stationMaster.Close
Set stationMaster = Nothing
%>
