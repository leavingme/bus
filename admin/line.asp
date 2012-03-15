<%@  language="VBSCRIPT" codepage="65001" %>
<!--#include file="action/admin.asp" -->
<%
Dim bus_id
Set bus_id = request("bus_id")
If IsEmpty(bus_id) Then
    Response.Redirect("default.asp")
End If
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>我爱坐班车</title>
    <script src="/scripts/jquery-1.4.2.min.js" type="text/javascript"></script>
</head>
<body>
    <div id="map_canvas" style="width: 70%; float: left; height: 500px; background-color: gray">
    </div>
    <input id="Button2" type="button" value="检查修改过的车站" onclick="javascript:gBusLineRenderer.ShowChangedStops()" /><br />
    <input id="Button1" type="button" value="生成KML文件" onclick="javascript:gLine.GetKMLDoc()" /><br />
    <a href="default.asp?admin=bus&amp;bus=<% =bus_id %>" target="_blank">修改此线路的信息</a>
    <div style="text-align: left; width: 30%; float: right; padding-top: 20px" id="div_result">
        重要提示：当你看见路线非常混乱时，请勿慌张，很多时候<span style="color: red;">只需把车站移到马路对面</span>即可。
    </div>
    <script src="http://www.google.com/jsapi?key=ABQIAAAAVTvE_PpAn4MKNdgPxcAjsxT_-ekJylybY5mVHjVuGPvzg9xb6RSiyHPza8m_vVbRweVnkPyuJezn-g"
        type="text/javascript"></script>
    <script src="/scripts/BusMapSDK.js" type="text/javascript"></script>
    <script src="/scripts/BusMapSDKAdmin.js" type="text/javascript"></script>
    <script type="text/javascript">
        var gLine = null;
        var gMap = null;
        var gMarkerMgr = null;
        var gSearchMarkerMgr = null;
        var gLocalSearcher = null;
        $(window).one('BusMapSDK_onBegin', function () {
            //首先就去异步加载search API，提高并发性能
            google.load('search', '1', { 'callback': function () {
                //在search API加载结束以后，才可以创建LocalSearch对象
                gLocalSearcher = new google.search.LocalSearch();
                gLocalSearcher.setSearchCompleteCallback(null, OnLocalSearch);
            }
            });
        });
        $(window).one('BusMapSDK_onEnd', function () {
            gMap = new google.maps.Map(document.getElementById('map_canvas'), {
                center: new google.maps.LatLng(22.54155, 113.935328),
                zoom: 15,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                draggableCursor: 'default'
            });
            gMarkerMgr = new MarkerManager(gMap);
            BusStation.Init(gMap);
            gLine = new BusLine(<% =bus_id %>);
            $(gLine).bind('stops_got', function () {
                if (!gBusLineRenderer) {
                    gBusLineRenderer = new BusLineRenderer(gMap);
                }
                gBusLineRenderer.SetStops(gLine.GetStops(), { 'draggable': true });
            });
            gLine.QueryForStops();
        });
        function doMapSearch(_id) {
            SideBarMgr.ShowText('正在搜索，请稍候。');
            var query = document.getElementById(_id).value;
            if (0 != query.indexOf(BuildingSelector.MyCity)) {
                query = BuildingSelector.MyCity + query;
            }
            gLocalSearcher.setCenterPoint(gMap.getCenter());
            gLocalSearcher.execute(query);
        };
        function OnLocalSearch() {
            SideBarMgr.ClearAll();
            CloseInfoWindow();
            gCurrentResults = [];

            if (!gLocalSearcher.results | 0 == gLocalSearcher.results.length) {
                SideBarMgr.ShowText('对不起，从谷歌地图中没有检索到有效的结果。请尝试更换关键词之后重新搜索。');
                return;
            }
            //只有在查询到有效的结果时，清除原来的Marker
            gSearchMarkerMgr.clearMarkers()
            var bounds = new google.maps.LatLngBounds();
            for (var i = 0; i < gLocalSearcher.results.length; i++) {
                var tempResult = new SearchResult(gLocalSearcher.results[i]);
                gCurrentResults.push(tempResult);
                gSearchMarkerMgr.addMarker(tempResult.GetMarker(), 0);
                bounds.extend(tempResult.GetMarker().getPosition());
            }
            gMap.fitBounds(bounds);
            if (gMap.getZoom() > 16) {
                gMap.setZoom(16);
            }

            var attribution = gLocalSearcher.getAttribution();
            if (attribution) {
                SideBarMgr.AppendNode(attribution);
            }
        };
    </script>
</body>
</html>
