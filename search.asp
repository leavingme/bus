<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!--#include file="inc/data.asp" -->
<%
q = HTMLEncode2(Request("q"))
If q = "" Then
  Response.Redirect("/")
ElseIf Len(q) > 10 Then
  q = Left(q,10) & ".."
End If

If Request("search") = 1 AND Session(q) = 0 Then
Set search = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM search"
search.Open sql,conn,3,3
search.AddNew
search("src_keyword") = q
search("src_ip") = Request.SerVerVariables("REMOTE_ADDR")
search.Update
search.Close
Set search = Nothing
Session(q) = 1
End If

If Instr(q,"S") Or Instr(q,"N") Or Instr(q,"Q") Or Instr(q,"T") Or Instr(q,"F") Or Instr(q,"B") Or Instr(q,"X") Or Instr(q,"K") Or Instr(q,"Y") Or q >= "0" And q <= "9" Then
condition = "SELECT bus_id, bus_categoryid, bus_timeid, bus_name, bus_subtitle, bus_num, bus_count, ctr_id, ctr_sort FROM bus, category WHERE bus_name LIKE '%" & q & "%' And bus_categoryid = ctr_id And ctr_cityid = " & Request.Cookies("cityId")
search_bus = true
pgsize = 3
Else
If Request("station") Then
  stn_condition = " And stn_id = " & Request("station")
  kwd_condition = " And kwd_stationid = " & Request("station")
End If
condition = "SELECT stn_id, stn_cityid, stn_name, stn_map, stn_mapurl, stn_master, stn_pic, stn_count, stn_lat, stn_lng FROM station WHERE stn_name LIKE '%" & q & "%'" & " And stn_cityid = " & Request.Cookies("cityId") & stn_condition & " UNION ALL SELECT stn_id, stn_cityid, kwd_stationid, kwd_name, stn_mapurl, stn_master, stn_pic, stn_coordinate, stn_lat, stn_lng FROM station, keyword WHERE kwd_name LIKE '%" & q & "%'" & " And kwd_stationid = stn_id And stn_cityid = " & Request.Cookies("cityId") & kwd_condition
search_stn = true
pgsize = 10
End If

Set results = Server.CreateObject("ADODB.RECORDSET")
sql = condition
results.Open sql,conn,1,1
page = Request("page")
results.Pagesize = pgsize
pgnm = results.pageCount
If page = "" Or Clng(page) < 1 Then page = 1
If CLng(page) > pgnm Then page = pgnm
If pgnm > 0 Then results.AbsolutePage = page
Count = 0
%>
<%
If Not results.EOF Then

If search_bus Then

condition = "cmt_busid = " & results("bus_id")

Set volunteer = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_memberid, mbr_id, mbr_name, mbr_blog, mbr_face, mbr_time FROM bus, member WHERE bus_id = " & results("bus_id") & " And bus_memberid = mbr_id"
volunteer.Open sql,conn,1,1

Else

condition = "cmt_stationid = " & results("stn_id")

If IsNumeric(results("stn_name")) Then
Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station WHERE stn_id = " & results("stn_name")
keyword.Open sql,conn,1,1
stn_name = keyword("stn_name")
stn_map = keyword("stn_map")
stn_count = keyword("stn_count")
keyword.Close
Set keyword = Nothing
Else
stn_name = results("stn_name")
stn_map = results("stn_map")
stn_count = results("stn_count")
End If

End If

Set comment = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM comment, member WHERE " & condition & " And cmt_memberid = mbr_id ORDER BY cmt_id DESC"
comment.Open sql,conn,1,1

End If
%>
<%
Set list = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category"
list.Open sql,conn,1,1
%>
<%
If search_bus And Not results.EOF Then

If Session("countBus" & results("bus_id")) <> 1 Then
Set busCount = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_count FROM bus WHERE bus_id = " & results("bus_id")
busCount.Open sql,conn,3,3
busCount("bus_count") = busCount("bus_count") + 1
busCount.Update
Session("countBus" & results("bus_id")) = 1
busCount.Close
Set busCount = Nothing
End If

ElseIf search_stn And Not results.EOF Then

If Session("countStation" & results("stn_id")) <> 1 Then
Set stationCount = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_count FROM station WHERE stn_id = " & results("stn_id")
stationCount.Open sql,conn,3,3
stationCount("stn_count") = stationCount("stn_count") + 1
stationCount.Update
Session("countStation" & results("stn_id")) = 1
stationCount.Close
Set stationCount = Nothing
End If

End If
%>
<%
Randomize()
rc_a = Int(Rnd * 9)
rc_b = Int(Rnd * 9)
rc_c = rc_a + rc_b
%>
<%
Set record = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT Top 10 * FROM search WHERE src_ip LIKE '%" & Request.SerVerVariables("REMOTE_ADDR") & "%'" & " ORDER BY src_id DESC"
record.Open sql,conn,1,1
%>
<script runat="server" language="vbscript">
function DoWhiteSpace(str)
  DoWhiteSpace = Replace(str, vbCrlf, "<br />")
End Function
</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="keywords" content="班车, 地图, 搜索" />
<meta name="description" content="我爱坐班车 - 有地图的班车搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
<meta name="author" content="Huang Hong - design-hong.com huanghong@hotmail.com" />
<title><%=(q)%> - 我爱坐班车</title>
<link rel="stylesheet" type="text/css" href="style/basic.css" />
<link rel="stylesheet" type="text/css" href="style/search.css" />
<link rel="canonical" href="http://bus.oa.com/search.asp"/>
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
<script type="text/javascript" src="scripts/mootools.js"></script>
<script type="text/javascript" src="scripts/basic.js"></script>
<script type="text/javascript">
window.onload = function() {
	//手风琴
	var elements = document.getElements(".accordion");
	for (var element, accordion, i = 0; i < elements.length; i++) {
		element = $(elements[i]);
		accordion = new Accordion(element, element.getChildren(".toggler"), element.getChildren(".element"), {duration: 1000});
	}
	//Google Map API
	<% If Not results.EOF Then %>
	if (GBrowserIsCompatible()) {
		var map = new GMap2(document.getElementById("map_canvas"));
		map.addControl(new GSmallMapControl());    //左上角十字
		map.addControl(new GMapTypeControl());     //右上角图层
		map.addControl(new GOverviewMapControl()); //右下角缩小图
		map.enableScrollWheelZoom();               //滚轮缩放
		map.enableContinuousZoom();                //平滑缩放
		map.enableGoogleBar();                     //搜索窗
		<% If search_bus Then %>
		var directions = new GDirections(map);
		<%
Set stationCoordinate = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT stn_id, stn_coordinate, lne_id, lne_busid, lne_stationid, lne_order FROM station, line WHERE lne_busid = " & results("bus_id") & " And lne_stationid = stn_id ORDER By lne_order, lne_id"
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
		<% Else %>
		var geocoder = new GClientGeocoder();
		<% End If %>
	}
	<% If search_stn Then %>
	if (geocoder) {
		geocoder.getLatLng(
			address = "<%=(Request.Cookies("cityName"))%><% If stn_map <> "" Then %><%=(stn_map)%><% Else %><%=(stn_name)%>站<% End If %>",
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
	}
	<% End If %>
<% End If %>
}

<% If Not results.EOF Then %>
<% If search_stn And results("stn_mapurl") <> "" Then %>
<% Else %>
var lat = <%=(results("stn_lat"))%>;
var lng = <%=(results("stn_lng"))%>;
var x = lngFrom4326ToProjection(lng);
var y = latFrom4326ToProjection(lat);
streetViewLoader(x, y);
<% End If %>
<% End If %>

//表情
function faceTag(id, str){
	document.getElementById(id).commentMessage.focus();
	if((document.selection) && (document.selection.type == "Text")){
		var oStr = document.selection.createRange();
		oStr.text = str+oStr
	} else {
	document.getElementById(id).commentMessage.value += str
	}
}
</script>
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
<div id="main" class="box">
  <form id="searchForm" class="box" method="get" action="search.asp">
    <h1><a href="/">我爱坐班车</a></h1>
    <p>
      <input id="q" name="q" value="<%=(q)%>" title="输入班车、车站或周边..." />
      <input name="search" type="hidden" value="1" />
      <button title="搜索" type="submit">搜索</button>
    </p>
  </form>
  <% If Not results.EOF Then %>
  <div class="content">
    <div class="map">
      <div id="map_canvas"></div>
      <p class="msg">班车街景行动，期待你的加入！<a href="sosomap.html">详情</a></p>
    </div>
    <div class="detail<% If search_stn Then %> detail_bus<% End If %>">
      <% If search_bus Then %>
      <%
If results("bus_timeid") <> "" Then
Set busTime = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT tim_id, tim_name FROM tim WHERE tim_id = " & results("bus_timeid")
busTime.Open sql,conn,1,1
End If
%>
      <h1><%=(results("bus_name"))%><% If results("bus_subtitle") <> "" Then %> - <%=(results("bus_subtitle"))%><% End If %><% If results("bus_num") Then %> - 共<%=(results("bus_num"))%>车<% End If %></h1>
      <p class="count">关注<%=(results("bus_count"))%>次</p>
      <%
If results("bus_timeid") <> "" Then
busTime.Close
Set busTime = Nothing
End If
%>
      <%
Set stationList = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station, line WHERE lne_busid = " & results("bus_id") & " And lne_stationid = stn_id ORDER By lne_order, lne_id"
stationList.Open sql,conn,1,1
%>
      <ul class="info box">
        <%
While (NOT stationList.EOF)
%>
        <li><a href="?q=<%=Server.URLEncode(stationList("stn_name"))%>"><%=(stationList("stn_name"))%></a><% If stationList("lne_time") <> "" Then %><span>(<%=(stationList("lne_time"))%>)</span><% End If %></li>
        <%
stationList.MoveNext()
Wend
%>
      </ul>
<%
stationList.Close
Set stationList = Nothing
%>
      <% Else %>
      <h1><%=(stn_name)%></h1>
      <p class="count">关注<%=(stn_count)%>次</p>
      <div class="info">
        <%
str = "上班班车|下班班车|夜间班车"
str = Split(str,"|")
str2 = "全部S线、N线|全部Q线|全部T线"
str2 = Split(str2,"|")
str3 = "全部S线、N线|全部F线|全部T线"
str3 = Split(str3,"|")
For i = 0 To Ubound(str)
%>
        <%
If results("stn_id") = "1" Then
Response.Write("<p>" & str(i) & "- " & str2(i) & "</p>")
ElseIf results("stn_id") = "2" Then
Response.Write("<p>" & str(i) & "- " & str3(i) & "</p>")
Else
Set busList = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus, line, category, tim WHERE lne_stationid = " & results("stn_id") & " And lne_busid = bus_id And bus_categoryid = ctr_id And ctr_sort = " & i + 1 & " And bus_timeid = tim_id ORDER BY bus_timeid, bus_id"
busList.Open sql,conn,1,1
%>
        <% If Not busList.EOF Then %>
        <p><%=(str(i))%> - 
        <%
While (NOT busList.EOF)
%>
        <a href="?q=<%=Server.URLEncode(busList("bus_name"))%>"><%=(busList("bus_name"))%></a><span>(<% If busList("lne_time") <> "" Then %><%=(busList("lne_time"))%><% Else %><% If busList("tim_name") <> "0" Then %><%=(busList("tim_name"))%>发<% Else %><%=(busList("bus_subtitle"))%><% End If %><% End If %>)</span>
        <%
busList.MoveNext()
Wend
%>
        <% If Request.Cookies("cityId") = 1 And i = 1 Then %>
        <em>Q为腾讯大厦发车, 不到飞亚达大厦; F为飞亚达大厦发车, 不到腾讯大厦.</em>
        <% End If %>
        </p>
        <% End If %>
        <%
busList.Close
Set busList = Nothing
End If
%>
        <%
Next
%>
        <%
Set stationKeyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword WHERE kwd_stationid = " & results("stn_id")
stationKeyword.Open sql,conn,1,1
%>
        <p>周边信息 -
          <%
While (NOT stationKeyword.EOF)
%>
          <a href="?q=<%=Server.URLEncode(stationKeyword("kwd_name"))%>"><%=(stationKeyword("kwd_name"))%></a>
          <%
stationKeyword.MoveNext()
Wend
%>
          <% If stationKeyword.EOF And stationKeyword.BOF Then %>暂时没有<% End If %>
          <a class="new" href="list.asp?list=house&amp;station=<%=Server.URLEncode(stn_name)%>">修改/新增</a>
        </p>
        <%
stationKeyword.Close
Set stationKeyword = Nothing
%>
      </div>
      <%
If results("stn_id") > 2 Then
%>
      <div class="pic box">
        <h2><span>抢地主（福利申请中，占坑先！） - <a href="sosomap.html">班车街景</a> <a href="photo.asp">为班车站拍照</a></span></h2>
        <%
If results("stn_master") <> "" Then
Set stationMaster = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, mbr_blog, mbr_face FROM member WHERE mbr_id = " & results("stn_master")
stationMaster.Open sql,conn,1,1
%>
        <p class="master"><a href="<%=(stationMaster("mbr_blog"))%>" target="_blank"><img src="<% If stationMaster("mbr_face") <> "" Then %><%=(stationMaster("mbr_face"))%><% Else %>http://imgcache.oa.com/avatar/<%=(stationMaster("mbr_name"))%>.jpg<% End If %>" title="<%=(results("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>" alt="<%=(results("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>" /></a> <a class="name" href="<%=(stationMaster("mbr_blog"))%>" title="<%=(results("stn_name"))%>地主 - <%=(stationMaster("mbr_name"))%>" target="_blank">地主 - <%=(stationMaster("mbr_name"))%></a></p>
        <ol class="box">
          <%
For i = 1 To results("stn_pic")
%>
          <li><a href="pic/station/s_<%=(results("stn_id"))%>_<%=(i)%>.jpg" target="_blank"><img src="pic/station/s_<%=(results("stn_id"))%>_<%=(i)%>.jpg" title="<%=(results("stn_name"))%>站[图<%=(i)%>]" alt="<%=(results("stn_name"))%>站[图<%=(i)%>]" /></a></li>
          <%
Next
i = i + 1
%>
        </ol>
        <% Else %>
        <p class="master"><a href="sosomap.html"><img src="pic/station/s_0.png" title="无主领地" alt="无主领地" /></a> <a class="name" href="sosomap.html" title="无主领地">无主领地</a></p>
        <% End If %>
      </div>
      <%
End If
%>
      <% End If %>
    </div>
	<% If search_stn Then %>
    <div id="sosomap" class="sosomap">
      <h2>上班班车站街景<% If results("stn_mapurl") <> "" And results("stn_master") <> "" Then %> - 已由<%=(stationMaster("mbr_name"))%>手工校对<% End If %></h2>
      <p class="edit"><a href="javascript:void(0);" onclick="show('pop_sosomap');">修改</a></p>
      <div class="iframe">
        <iframe id="sosomap_iframe" src="<%=(results("stn_mapurl"))%>"></iframe>
      </div>
    </div>
    <div id="pop_sosomap" class="pop">
      <div class="popBg"></div>
      <div class="popNotice">
        <p class="close"><a href="javascript:void(0);" onclick="hide('pop_sosomap');">关闭</a></p>
        <form id="sosomap_form" class="sosomap_form" method="post" action="action/sosomap.asp">
          <h3>上班班车站街景修改</h3>
          <ul>
            <li>
              <label for="mapUrl">街景网址</label>
              <input id="mapUrl" name="mapUrl" type="text" value="<%=(results("stn_mapurl"))%>" />
            </li>
            <li>
              <label for="mapMember">RTX昵称</label>
              <% If results("stn_master") <> "" Then %>
              <input id="mapMember" name="mapMember" type="text" value="<%=(stationMaster("mbr_name"))%>" disabled="disabled" />
              <span>地主已被抢占</span>
              <% Else %>
              <input id="mapMember" name="mapMember" type="text" value="" />
              <% End If %>
            </li>
          </ul>
          <p class="btn">
            <input name="mapStationid" type="hidden" value="<%=(results("stn_id"))%>" />
            <input name="mapStationname" type="hidden" value="<%=(results("stn_name"))%>" />
            <button type="submit">修改</button>
          </p>
          <ol>
            <li>打开<a id="sosomap_form_text" href="<%=(results("stn_mapurl"))%>" target="_blank">街景网址</a>；</li>
            <li>拖、拉、拽、扯，将班车停靠点摆放在视线正中；</li>
            <li>点击右侧“分享”按钮并复制网址，粘贴在上面表单中，提交。</li>
          </ol>
        </form>
      </div>
    </div>
    <%
If results("stn_master") <> "" Then
stationMaster.Close
Set stationMaster = Nothing
End If
%>
	<% End If %>
    <div id="commentList" class="comment">
      <h2><% If comment.recordcount = 0 Then %>没有<% ElseIf comment.recordcount > 1 Then %>已有<%=(comment.recordcount)%><% Else %>只有<%=(comment.recordcount)%><% End If %>人留言</h2>
      <ul>
        <%
While (NOT comment.EOF)
%>
        <li id="c<%=(comment("cmt_id"))%>" class="<% If comment("mbr_face") <> "" Then %>upload <% End If %><% If comment("cmt_id") = Int(Request("select")) Or comment("cmt_id") = Int(Request("comment")) Then %>current <% End If %>box">
          <p class="icon"><img src="<% If comment("mbr_face") <> "" Then %><%=(comment("mbr_face"))%><% Else %>http://imgcache.oa.com/avatar/<%=(comment("mbr_name"))%>.jpg<% End If %>" title="<%=(comment("mbr_name"))%>" alt="<%=(comment("mbr_name"))%>" /> <% If comment("mbr_blog") <> "" Then %><a href="<% If Left(comment("mbr_blog"),7) <> "http://" Then %>http://<% End If %><%=(comment("mbr_blog"))%>" rel="nofollow"><%=(comment("mbr_name"))%></a><% Else %><%=(comment("mbr_name"))%><% End If %></p>
          <% If comment("cmt_flower") = 1 Then %>
          <p class="flower"><span>“</span>赠送一朵小红花<span>”</span></p>
          <% End If %>
          <%
If comment("cmt_commentid") Then
Set reply = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT mbr_id, mbr_name, cmt_id, cmt_memberid FROM member, comment WHERE cmt_id = " & comment("cmt_commentid") & " And mbr_id = cmt_memberid"
reply.Open sql,conn,1,1
%>
          <p class="to">回复 <span>“</span><a href="?q=<%=Server.URLEncode(q)%>&amp;select=<%=(comment("cmt_commentid"))%>#c<%=(comment("cmt_commentid"))%>"><%=(reply("mbr_name"))%></a><span>”</span></p>
<%
reply.Close
Set reply = Nothing
End If
%>
          <p class="message"><%=DoWhiteSpace(comment("cmt_message"))%> <a class="reply" href="?q=<%=Server.URLEncode(q)%>&amp;comment=<%=(comment("cmt_id"))%>#comment">[回复]</a></p>
          <p class="time"><%=(comment("cmt_time"))%></p>
        </li>
        <%
comment.MoveNext()
Wend
%>
        <% If search_bus Then %>
        <% If Not volunteer.EOF Then %>
        <li class="upload box">
          <p class="icon"><img src="<% If volunteer("mbr_face") <> "" Then %><%=(volunteer("mbr_face"))%><% Else %>images/face.png<% End If %>"<% If volunteer("mbr_face") <> "" Then %> class="upload"<% End If %> title="<%=(volunteer("mbr_name"))%>" alt="<%=(volunteer("mbr_name"))%>" /> <% If volunteer("mbr_blog") <> "" Then %><a href="<% If Left(volunteer("mbr_blog"),7) <> "http://" Then %>http://<% End If %><%=(volunteer("mbr_blog"))%>" rel="nofollow"><%=(volunteer("mbr_name"))%></a><% Else %><%=(volunteer("mbr_name"))%><% End If %></p>
          <p class="message"><%=(results("bus_name"))%>志愿者<%=(volunteer("mbr_name"))%>, 如有此条路线的疑问, 欢迎留言~</p>
          <p class="time"><%=(volunteer("mbr_time"))%></p>
        </li>
        <% ElseIf comment.EOF And comment.BOF Then %>
        <li class="upload box">
          <p class="icon"><img src="pic/fishhuang.jpg" class="upload" title="hong" alt="hong" /> <a href="http://design-hong.com" rel="nofollow">fishhuang</a></p>
          <p class="message">欢迎大家留言~</p>
          <p class="time">2010/6/9 12:00:00</p>
        </li>
        <% End If %>
        <% ElseIf comment.EOF And comment.BOF Then %>
        <li class="upload box">
          <p class="icon"><img src="pic/fishhuang.jpg" class="upload" title="hong" alt="hong" /> <a href="http://design-hong.com" rel="nofollow">fishhuang</a></p>
          <p class="message">欢迎大家留言~</p>
          <p class="time">2010/6/9 12:00:00</p>
        </li>
        <% End If %>
      </ul>
      <form id="comment" method="post" action="action/comment.asp">
        <p>
          <label for="commentName"><% If Instr(Request("error"),"namelong") Then %><span>RTX昵称在16个字以内</span><% ElseIf Instr(Request("error"),"name") Then %><span>请输入正确的RTX昵称</span><% ElseIf Request.Cookies("commentName") <> "" Then %><strong>RTX昵称<%=(Request.Cookies("commentName"))%></strong><% Else %>RTX昵称<% End If %></label>
          <a id="open" class="<% If Instr(Request("error"),"blog") Or Instr(Request("error"),"face") Then %>current <% End If %>open" href="javascript:void(0);" title="更多" onclick="show('more');hide('open')"><span><span>更多</span></span></a>
          <input id="commentName" name="commentName"<% If Len(Request.Cookies("commentName")) >= 3 And Len(Request.Cookies("commentName")) <= 16 Then %>type="hidden" <% End If %> value="<%=(Request.Cookies("commentName"))%>" />
        </p>
        <fieldset id="more"<% If Instr(Request("error"),"blog") Or Instr(Request("error"),"face") Then %> class="current"<% End If %>>
          <legend>选填项 - 如果之前填写过, 若不修改则留空</legend>
          <p>
            <label for="commentBlog"><% If Instr(Request("error"),"blog") Then %><span>请输入正确的博客</span><% Else %>博客<% End If %></label>
            <input id="commentBlog" name="commentBlog" value="<%=(Request.Cookies("commentBlog"))%>" />
          </p>
          <p>
            <label for="commentFace"><% If Instr(Request("error"),"face") Then %><span>请输入正确的头像</span><% Else %>头像(建议复制微博的头像图片地址)<% End If %></label>
            <input id="commentFace" name="commentFace" value="<%=(Request.Cookies("commentFace"))%>" />
          </p>
        </fieldset>
        <div class="textarea">
          <label for="commentMessage"><% If Instr(Request("error"),"message") Then %><span>请输入留言内容</span><% ElseIf Instr(Request("error"),"http") Then %><span>留言中含有非法字符</span><% Else %><% If Request("comment") <> 0 Then %>您的回复<% Else %>您的留言<% End If %><% End If %></label>
          <textarea id="commentMessage" name="commentMessage" rows="5" cols="100%"><% If search_bus Then %><%=(Request.Cookies("commentMessage" & results("bus_id")))%><% Else %><%=(Request.Cookies("commentMessage" & results("stn_id")))%><% End If %></textarea>
          <p class="face">
            <button onclick="faceTag(this.form.id,' ^_^ ')" type="button">^_^</button>
            <button onclick="faceTag(this.form.id,' :-P ')" type="button">:-P</button>
            <button onclick="faceTag(this.form.id,' @_@ ')" type="button">@_@</button>
            <button onclick="faceTag(this.form.id,' T_T ')" type="button">T_T</button>
            <button onclick="faceTag(this.form.id,' -_-b ')" type="button">-_-b</button>
            <button onclick="faceTag(this.form.id,' -_-&#43; ')" type="button">-_-&#43;</button>
            <button onclick="faceTag(this.form.id,' =_=&quot; ')" type="button">=_=&quot;</button>
            <button onclick="faceTag(this.form.id,' -O- ')" type="button">-O-</button>
            <button onclick="faceTag(this.form.id,' -w- ')" type="button">-w-</button>
            <button onclick="faceTag(this.form.id,' \\(^o^)/ ')" type="button">\(^o^)/</button>
            <button onclick="faceTag(this.form.id,' Orz ')" type="button">Orz</button>
            <button onclick="faceTag(this.form.id,' 囧rz ')" type="button">囧rz</button>
          </p>
        </div>
        <% If search_bus Then %>
        <% If Not volunteer.EOF AND Not Session("commentFlower" & results("bus_id")) = 1 Then %>
		<p class="flower">
          <input id="commentFlower" name="commentFlower" type="checkbox" checked="checked" value="1" />
          <label for="commentFlower">赠送志愿者小红花</label>
        </p>
        <% End If %>
        <% End If %>
        <p>
          <label for="rndCode"><% If Instr(Request("error"),"code") Then %><span><%=(rc_a)%> + <%=(rc_b)%> = <%=(rc_c)%></span><% Else %><%=(rc_a)%> + <%=(rc_b)%> = ?<% End If %></label>
          <input id="rndCode" name="rndCode" />
        </p>
        <p>
          <input name="commentKeyword" type="hidden" value="<%=(q)%>" />
          <% If search_bus Then %>
          <input name="commentBusid" type="hidden" value="<%=(results("bus_id"))%>" />
          <% If Not volunteer.EOF Then %>
          <input name="commentVolunteer" type="hidden" value="<%=(volunteer("mbr_id"))%>" />
          <% End If %>
          <% Else %>
          <input name="commentStationid" type="hidden" value="<%=(results("stn_id"))%>" />
          <% End If %>
          <input name="commentCommentid" type="hidden" value="<% If Request("comment") Then %><%=(Request("comment"))%><% Else %>0<% End If %>" />
          <input name="rndCodeA" type="hidden" value="<%=(rc_a)%>" />
          <input name="rndCodeB" type="hidden" value="<%=(rc_b)%>" />
          <input name="rndCodeC" type="hidden" value="<%=(rc_c)%>" />
          <% If Request("error") = "repeat" Then %>
          <button type="submit" disabled="disabled">提交留言</button> 已经留了很多句了, 先休息一下吧~
          <% ElseIf Request("error") = "flowerrepeat" Then %>
          <button type="submit" disabled="disabled">提交留言</button> 请不要重复送小红花
          <% Else %>
          <button type="submit">提交留言</button>
          <% End If %>
        </p>
      </form>
    </div>
  </div>
  <div class="sidebar">
    <% If Not results.EOF Then %>
    <div class="results box">
      <h2>搜索<% If Len(q) < 10 Then %><%=(q)%><% Else %><%=Left(q,10) & ".." %><% End If %> - 共<%=(results.recordcount)%>条</h2>
      <ul>
        <%
While (NOT results.EOF) And (results_count < results.PageSize)
%>
        <% If search_bus Then %>
        <li>
          <dl class="box">
            <dt><a href="?q=<%=Server.URLEncode(results("bus_name"))%>"><%=(results("bus_name"))%><% If results("bus_subtitle") <> "" Then %> - <%=(results("bus_subtitle"))%><% End If %><% If results("bus_num") Then %> - 共<%=(results("bus_num"))%>车<% End If %></a></dt>
            <dd>
			  <%
Set busResults = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station, line WHERE lne_busid = " & results("bus_id") & " And lne_stationid = stn_id ORDER By lne_order, lne_id"
busResults.Open sql,conn,1,1

While (NOT busResults.EOF)
%>
              <a href="?q=<%=Server.URLEncode(busResults("stn_name"))%>"><%=(busResults("stn_name"))%></a><% If busResults("lne_time") <> "" Then %>(<%=(busResults("lne_time"))%>)<% End If %>
              <%
busResults.MoveNext()
Wend

busResults.Close
Set busResults = Nothing
%>          </dd>
          </dl>
        </li>
        <% Else %>
        <%
If IsNumeric(results("stn_name")) Then
Set keyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM station WHERE stn_id = " & results("stn_name")
keyword.Open sql,conn,1,1
stn_name = keyword("stn_name")
keyword.Close
Set keyword = Nothing
Else
stn_name = results("stn_name")
End If
%>
        <li>
          <dl class="box">
            <dt><a href="?q=<%=Server.URLEncode(stn_name)%>&amp;station=<%=(results("stn_id"))%>"><%=(stn_name)%> 站</a></dt>
            <dd>
			  <%
If results("stn_id") = "1" Then
Response.Write("全部S线、N线、Q线、T线")
ElseIf results("stn_id") = "2" Then
Response.Write("全部S线、N线、F线、T线")
Else
Set stationResults = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM bus, line, tim WHERE lne_stationid = " & results("stn_id") & " And lne_busid = bus_id And bus_timeid = tim_id ORDER BY bus_timeid, bus_id"
stationResults.Open sql,conn,1,1

While (NOT stationResults.EOF)
%>
              <a href="?q=<%=Server.URLEncode(stationResults("bus_name"))%>"><%=(stationResults("bus_name"))%></a>(<% If stationResults("lne_time") <> "" Then %><%=(stationResults("lne_time"))%><% Else %><% If stationResults("tim_name") <> "0" Then %><%=(stationResults("tim_name"))%>发<% Else %><%=(stationResults("bus_subtitle"))%><% End If %><% End If %>)
              <%
stationResults.MoveNext()
Wend

stationResults.Close
Set stationResults = Nothing
End If
%>          </dd>
          </dl>
		  <%
Set stationKeyword = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM keyword WHERE kwd_stationid = " & results("stn_id")
stationKeyword.Open sql,conn,1,1

If Not stationKeyword.EOF Then
%>
          <dl class="box">
            <dt>周边 - </dt>
            <dd>
              <%
While (NOT stationKeyword.EOF)
%>
              <a href="?q=<%=Server.URLEncode(stationKeyword("kwd_name"))%>"><%=(stationKeyword("kwd_name"))%></a>
              <%
stationKeyword.MoveNext()
Wend
%>
            </dd>
          </dl>
          <%
End If

stationKeyword.Close
Set stationKeyword = Nothing
%>
        </li>
        <% End If %>
        <%
results_count = results_count + 1
results.MoveNext()
Wend
%>
      </ul>
      <% If results.pageCount > 1 Then %>
      <p>
	  <% If Int(page) <> 1 Then %><a href="?q=<%=q%>&amp;page=<%=(page - 1)%>">上一页</a> <% End If %>
      <% If Int(page) <> results.pageCount Then %><a href="?q=<%=q%>&amp;page=<%=(page + 1)%>">下一页</a><% End If %>
      </p>
      <% End If %>
    </div>
    <% End If %>
    <% If Request.Cookies("cityId") = 1 Then %>
    <div class="list box">
      <h2>班车列表</h2>
      <div class="accordion">
        <h3 class="toggler"><a href="javascript:void(0);">上班班车</a></h3>
        <div class="element">
          <div class="bd">
            <p><strong>市区</strong></p>
            <p><a href="?q=S1">S1</a> <a href="?q=S2">S2</a> <a href="?q=S3">S3</a> <a href="?q=S4">S4</a> <a href="?q=S5">S5</a> <a href="?q=S6">S6</a> <a href="?q=S7">S7</a> <a href="?q=S8">S8</a> <a href="?q=S9">S9</a> <a href="?q=S10">S10</a> <a href="?q=S11">S11</a> <a href="?q=S12">S12</a> <a href="?q=S13">S13</a> <a href="?q=S14">S14</a> <a href="?q=S15">S15</a> <a href="?q=S16">S16</a> <a href="?q=S17">S17</a> <a href="?q=S18">S18</a> <a href="?q=S19">S19</a> <a href="?q=S20">S20</a> <a href="?q=S21">S21</a> <a href="?q=S22">S22</a> <a href="?q=S23">S23</a> <a href="?q=S24">S24</a> <a href="?q=S25">S25</a> <a href="?q=S26">S26</a> <a href="?q=S27">S27</a> <a href="?q=S28">S28</a> <a href="?q=S29">S29</a> <a href="?q=S30">S30</a> <a href="?q=S31">S31</a> <a href="?q=S32">S32</a> <a href="?q=S33">S33</a> <a href="?q=S34">S34</a></p>
            <p><strong>南山</strong></p>
            <p><a href="?q=N1">N1</a> <a href="?q=N2">N2</a> <a href="?q=N3">N3</a> <a href="?q=N4">N4</a> <a href="?q=N5">N5</a> <a href="?q=N7">N7</a> <a href="?q=N8">N8</a> <a href="?q=N9">N9</a> <a href="?q=N10">N10</a> <a href="?q=N11">N11</a> <a href="?q=N12">N12</a> <a href="?q=N13">N13</a> <a href="?q=N14">N14</a> <a href="?q=N15">N15</a> <a href="?q=N16">N16</a> <a href="?q=N17">N17</a> <a href="?q=N18">N18</a> <a href="?q=N19">N19</a> <a href="?q=N20">N20</a> <a href="?q=N21">N21</a> <a href="?q=N22">N22</a> <a href="?q=N23">N23</a> <a href="?q=N24">N24</a> <a href="?q=N25">N25</a> <a href="?q=N26">N26</a> <a href="?q=N27">N27</a> <a href="?q=N28">N28</a> <a href="?q=N29">N29</a> <a href="?q=N30">N30</a> <a href="?q=N31">N31</a> <a href="?q=N32">N32</a> <a href="?q=N33">N33</a> <a href="?q=N34">N34</a> <a href="?q=N35">N35</a> <a href="?q=N36">N36</a> <a href="?q=N37">N37</a> <a href="?q=N38">N38</a> <a href="?q=N39A">N39A</a> <a href="?q=N39B">N39B</a> <a href="?q=N40">N40</a> <a href="?q=N41">N41</a> <a href="?q=N42">N42</a></p>
          </div>
        </div>
        <h3 class="toggler"><a href="javascript:void(0);">下班班车</a></h3>
        <div class="element">
          <h4>腾讯大厦</h4>
          <div class="bd">
            <p><strong>18:00</strong></p>
            <p><a href="?q=Q1">Q1</a> <a href="?q=Q2">Q2</a> <a href="?q=Q3">Q3</a> <a href="?q=Q8">Q8</a> <a href="?q=Q9A">Q9A</a> <a href="?q=Q23">Q23</a></p>
            <p><strong>18:10</strong></p>
            <p><a href="?q=Q4">Q4</a> <a href="?q=Q5">Q5</a> <a href="?q=Q7">Q7</a> <a href="?q=Q9B">Q9B</a> <a href="?q=Q10">Q10</a> <a href="?q=Q11">Q11</a> <a href="?q=Q11A">Q11A</a></p>
            <p><strong>18:20</strong></p>
            <p><a href="?q=Q6">Q6</a> <a href="?q=Q12">Q12</a> <a href="?q=Q17">Q17</a> <a href="?q=Q19">Q19</a></p>
            <p><strong>18:30</strong></p>
            <p><a href="?q=Q13">Q13</a> <a href="?q=Q14">Q14</a> <a href="?q=Q15">Q15</a> <a href="?q=Q16">Q16</a> <a href="?q=Q18">Q18</a> <a href="?q=Q20">Q20</a> <a href="?q=Q22">Q22</a></p>
            <p><strong>18:40</strong></p>
            <p><a href="?q=Q21">Q21</a></p>
          </div>
          <h4>飞亚达大厦</h4>
          <div class="bd">
            <p><strong>17:50</strong></p>
            <p><a href="?q=F1">F1</a> <a href="?q=F2">F2</a> <a href="?q=F3">F3</a> <a href="?q=F4">F4</a> <a href="?q=F5">F5</a></p>
            <p><strong>18:00</strong></p>
            <p><a href="?q=F10">F10</a> <a href="?q=F11">F11</a></p>
            <p><strong>18:10</strong></p>
            <p><a href="?q=F6">F6</a> <a href="?q=F7">F7</a> <a href="?q=F8">F8</a> <a href="?q=F9">F9</a></p>
          </div>
        </div>
        <h3 class="toggler"><a href="javascript:void(0);">夜间班车</a></h3>
        <div class="element">
          <div class="bd">
            <p><strong>18:50</strong></p>
            <p><a href="?q=T11C">T11C</a></p>
            <p><strong>19:05</strong></p>
            <p><a href="?q=T1">T1</a> <a href="?q=T9A">T9A</a> <a href="?q=T9A">T9B</a> <a href="?q=T9C">T9C</a> <a href="?q=T10">T10</a> <a href="?q=T11A">T11A</a> <a href="?q=T16">T16</a> <a href="?q=T20">T20</a> <a href="?q=T21">T21</a> <a href="?q=T23">T23</a></p>
            <p><strong>19:20</strong></p>
            <p><a href="?q=T31">T31</a></p>
            <p><strong>19:35</strong></p>
            <p><a href="?q=T2A">T2A</a> <a href="?q=T2B">T2B</a> <a href="?q=T11B">T11B</a></p>
            <p><strong>19:50</strong></p>
            <p><a href="?q=T3">T3</a> <a href="?q=T17">T17</a> <a href="?q=T27">T27</a> <a href="?q=T28">T28</a></p>
            <p><strong>20:50</strong></p>
            <p><a href="?q=T4A">T4A</a> <a href="?q=T4B">T4B</a> <a href="?q=T4C">T4C</a> <a href="?q=T12">T12</a> <a href="?q=T25A">T25A</a> <a href="?q=T25B">T25B</a> <a href="?q=T25C">T25C</a> <a href="?q=T26">T26</a></p>
            <p><strong>21:05</strong></p>
            <p><a href="?q=T5A">T5A</a> <a href="?q=T5B">T5B</a> <a href="?q=T13">T13</a> <a href="?q=T18">T18</a> <a href="?q=T19">T19</a> <a href="?q=T22">T22</a> <a href="?q=T24">T24</a> <a href="?q=T29A">T29A</a> <a href="?q=T29B">T29B</a></p>
            <p><strong>21:35</strong></p>
            <p><a href="?q=T6">T6</a> <a href="?q=T14">T14</a></p>
            <p><strong>22:05</strong></p>
            <p><a href="?q=T7">T7</a></p>
            <p><strong>23:15</strong></p>
            <p><a href="?q=T8">T8</a> <a href="?q=T15">T15</a></p>
          </div>
        </div>
      </div>
    </div>
    <% ElseIf Request.Cookies("cityId") <> 1 Then %>
    <div class="list box">
      <h2>班车列表</h2>
      <div class="bd2">
        <%
Set category = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT * FROM category WHERE ctr_cityid = " & Request.Cookies("cityId")
category.Open sql,conn,1,1

While (NOT category.EOF)

Set busList = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT bus_id, bus_categoryid, bus_timeid, bus_name, tim_id, tim_name FROM bus, tim WHERE bus_categoryid = " & category("ctr_id") & " And bus_timeid = tim_id"
busList.Open sql,conn,1,1
%>
        <p><strong><%=(category("ctr_name"))%></strong></p>
        <p>
          <%
While (NOT busList.EOF)
%>
          <a href="?q=<%=Server.URLEncode(busList("bus_name"))%>"><%=(busList("bus_name"))%><% If busList("bus_timeid") <> "0" Then %>(<%=(busList("tim_name"))%>)<% End If %></a>
          <%
busList.MoveNext()
Wend
%>
        </p>
        <%
category.MoveNext()
Wend
%>
      </div>
    </div>
    <% End If %>
	<% If NOT record.EOF Then %>
	<div class="record">
	  <p><strong>我的搜索</strong> - <%
While (NOT record.EOF)
%>
      <a href="?q=<%=Server.URLEncode(record("src_keyword"))%>"><%=(record("src_keyword"))%></a>
      <%
record.MoveNext()
Wend
%> ..</p>
	</div>
	<% End If %>
  </div>
  <% Else %>
  <div class="sorry">
    <h2>抱歉, <strong>[<%=(Request.Cookies("cityName"))%>]</strong>站没有找到 <%=(q)%> 哦~ 请尝试切换城市</h2>
    <ul class="box">
      <li><a href="search.asp?city=sz&amp;q=<%=(q)%>">深圳</a></li>
      <li><a href="search.asp?city=bj&amp;q=<%=(q)%>">北京</a></li>
      <li><a href="search.asp?city=cd&amp;q=<%=(q)%>">成都</a></li>
      <li><a href="search.asp?city=sh&amp;q=<%=(q)%>">上海</a></li>
      <li><a href="search.asp?city=gz&amp;q=<%=(q)%>">广州</a></li>
    </ul>
    <p>试试更换关键词? 或者在下面的热门搜索中选择..</p>
    <%
Randomize()
dim i,DispRecord
i = 0
DispRecord = 20

Set hot = Server.CreateObject("ADODB.RECORDSET")
sql = "SELECT Top 50 stn_id, stn_name, stn_count FROM station ORDER BY stn_count DESC UNION ALL SELECT bus_id, bus_name, bus_count FROM bus WHERE bus_count > 100"
hot.Open sql,conn,1,1
%>
    <ul class="box">
      <%
lngCount = hot.RecordCount
Redim idHot(lngCount)
While i < DispRecord
lngRnd = Int((lngCount * Rnd) + 1)
hot.AbsolutePosition = lngRnd
If isEmpty(idHot(lngRnd)) Then
%>
      <li><a href="search.asp?q=<%=Server.URLEncode(hot("stn_name"))%>"><%=(hot("stn_name"))%></a></li>
      <%
idHot(lngRnd) = 1
i = i + 1
End If
Wend
%>
    </ul>
    <%
hot.Close
Set hot = Nothing
%>
  </div>
  <% End If %>
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
<script src="http://maps.google.cn/maps?file=api&amp;v=2.x&amp;key=ABQIAAAADZXjIBRa_7cEg6jFjsBs3hS9WAeoFsB_nJrUiU1D02YqrSAv2hRrgmprNZTtcsnMxYN4c0p88RVZaQ" type="text/javascript"></script>
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
If Not results.EOF Then
comment.Close
Set comment = Nothing
If search_bus Then
volunteer.Close
Set volunteer = Nothing
End If
End If
%>
<%
results.Close
Set results = Nothing
%>
<%
list.Close
Set list = Nothing
%>
<%
record.Close
Set record = Nothing
%>
