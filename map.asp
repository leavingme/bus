<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="keywords" content="班车, 地图, 搜索" />
    <meta name="description" content="我爱坐班车 - 找地图的搜索：它适用于任何一位乘坐班车的同事，特别是新同事、下班不固定时间点的同事、近期租房的同事、临时乘坐陌生路线的同事，健忘的同事等等……" />
    <meta name="author" content="benjaminli" />
    <title>我爱坐班车</title>
    <link rel="stylesheet" type="text/css" href="style/basic.css" />
    <link rel="stylesheet" type="text/css" href="style/search.css" />
	<link rel="stylesheet" type="text/css" href="style/search_v2.css" />
	<link href="style/map.css" rel="stylesheet" type="text/css" />
    <!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="style/ie.css" /><![endif]-->
    <script src="scripts/jquery-1.4.2.min.js" type="text/javascript"></script>
</head>
<body>
    <div id="header" class="box">
        <ul class="nav">
            <li class="current">我爱坐班车</li>
        </ul>
        <ul id="BuildingSelector" class="nav">
            <li>正在加载Google地图，请稍候</li>
        </ul>
    </div>
    <div id="main" class="box">
        <form id="searchForm" class="box" action="javascript:doMapSearch('searchFormInput');">
        <h1>
            <a href="/">我爱坐班车</a></h1>
        <p>
            <input id="searchFormInput" title="搜索地图" />
            <button title="搜索地图" type="submit">
            </button>
        </p>
        </form>
        <div class="content">
            <div class="map">
                <div id="map_canvas">
                </div>
            </div>
        </div>
        <div class="sidebar">
            <h2>
                <a id="favourite" href="javascript:void(0)">我的班车</a>
            </h2>
            <ul class="results" id="div_result">
            </ul>
        </div>
    </div>
    <ul id="contextMenu">
        <li><a href="javascript:void(0)" onclick="getStationsNearby(true)">搜索附近的班车停靠站</a></li>
        <li class="separator"><a href="javascript:void(0)" onclick="javascript:centreMapHere()">
            在此居中放置地图</a></li>
    </ul>
    <script type="text/javascript" src="http://www.google.com/jsapi?key=ABQIAAAAVTvE_PpAn4MKNdgPxcAjsxT_-ekJylybY5mVHjVuGPvzg9xb6RSiyHPza8m_vVbRweVnkPyuJezn-g"></script>
    <script type="text/javascript" src="scripts/BusMapSDK.js"></script>
    <script type="text/javascript">
        var gMap = null;
        var gMarkerMgr = null;
        var gSearchMarkerMgr = null;
        var gContextMenu = null;
        var gLocalSearcher = null;

        //页面中立即执行的初始化代码
        window.setTimeout(Diagnose, 6000);
        FavouriteMgr.Load();
        FavouriteMgr.Show();
        $("#favourite").click(function () {
            FavouriteMgr.Show();
        });

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
            BuildingSelector.ParseCookie();
            //并设置默认地图中心
            gMap = new google.maps.Map(document.getElementById('map_canvas'), {
                center: BuildingSelector.GetMyLatLng(),
                zoom: 15,
                mapTypeId: google.maps.MapTypeId.ROADMAP,
                draggableCursor: 'default'
            });
            BusStation.Init(gMap);
            SearchResult.Init(gMap);
            gMarkerMgr = new MarkerManager(gMap);
            google.maps.event.addListener(gMarkerMgr, 'loaded', function () {
                BuildingSelector.Init(gMap, gMarkerMgr);
            });

            gSearchMarkerMgr = new MarkerManager(gMap);
            LoadContextMenu();
        });

        function Diagnose() {
            if (!(google.maps && google.maps.hasOwnProperty('Map'))) {
                $('#BuildingSelector').html('加载Google地图太久了。看看<a href="http://maps.google.com" target="_blank">maps.google.com</a>是否被GFW了？');
            }
        };

        /* Init Google Map Mouse Right ContextMenu Start */
        function LoadContextMenu() {
            gContextMenu = $('#contextMenu');
            // Disable the browser context menu on our context menu
            gContextMenu.bind('contextmenu', function () { return false; });

            // Append it to the map object
            $(gMap.getDiv()).append(gContextMenu);

            // Display and position the menu
            google.maps.event.addListener(gMap, 'rightclick', function (e) {
                // start by hiding the context menu if its open
                gContextMenu.hide();
                CloseInfoWindow();

                var mapDiv = $(gMap.getDiv()),
				x = e.pixel.x,
				y = e.pixel.y;

                // save the clicked location
                gClickedLatLng = e.latLng;

                // adjust if clicked to close to the edge of the map
                if (x > mapDiv.width() - gContextMenu.width())
                    x -= gContextMenu.width();

                if (y > mapDiv.height() - gContextMenu.height())
                    y -= gContextMenu.height();

                // Set the location and fade in the context menu
                gContextMenu.css({ top: y, left: x }).fadeIn(100);
            });

            // Hide context menu on some events
            $.each('click dragstart zoom_changed maptypeid_changed'.split(' '), function (i, name) {
                google.maps.event.addListener(gMap, name, function () { gContextMenu.hide(); CloseInfoWindow(); });
            });
        };

        function centreMapHere() {
            gContextMenu.fadeOut(75);
            gMap.panTo(gClickedLatLng);
        };

        function getStationsNearby(opt_FromContextMenu) {
            opt_FromContextMenu = opt_FromContextMenu | false;
            CloseInfoWindow();
            gMarkerMgr.clearMarkers();

            if (opt_FromContextMenu) {
                gContextMenu.fadeOut(75);
                var image = new google.maps.MarkerImage('/images/arrow.png',
                //这里是显示大小，也可控制点击范围
                new google.maps.Size(23, 34),
                //这个不知道干嘛的
                new google.maps.Point(0, 0),
                //锚点位置
                new google.maps.Point(11, 33)
                );
                var clickedMarker = new google.maps.Marker({
                    position: gClickedLatLng,
                    map: gMap,
                    icon: image,
                    title: '搜索中心'
                });
                gMarkerMgr.addMarker(clickedMarker, 0);
            }

            $.post('/action/Query.asp', {
                'id_cmd': escape(1),
                'c_lat': escape(gClickedLatLng.lat()),
                'c_lng': escape(gClickedLatLng.lng())
            }, function (data) {
                var allMarkers = [];
                var dataLines = data.split('#');
                var tempOptSet;
                var tempBusStation;
                for (var i = 0; i < dataLines.length; i++) {
                    tempOptSet = dataLines[i].split('|');
                    if (4 == tempOptSet.length) {
                        //查询附近的车站，从后台送来的参数必须是4个一组
                        tempBusStation = new BusStation(tempOptSet[0], tempOptSet[1], tempOptSet[2], tempOptSet[3]);
                        allMarkers.push(tempBusStation.GetMarker());
                    }
                }

                if (allMarkers.length) {
                    var bounds = new google.maps.LatLngBounds();
                    bounds.extend(gClickedLatLng);
                    for (i = 0; i < allMarkers.length; i++) {
                        bounds.extend(allMarkers[i].getPosition());
                    }
                    gMap.fitBounds(bounds);
                    if (gMap.getZoom() > 16) {
                        gMap.setZoom(16);
                    }

                    gMarkerMgr.addMarkers(allMarkers, 0);
                    gMarkerMgr.refresh();
                }
                else {
                    alert('对不起，在附近10KM以内没有班车停靠点');
                }
            });
        };
        /* Init Google Map Mouse Right ContextMenu End */

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
    <script type="text/javascript">
        var _gaq = _gaq || [];
        _gaq.push(['_setAccount', 'UA-2449263-10']);
        _gaq.push(['_trackPageview']);

        (function () {
            var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
            ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
            var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
        })();
    </script>
</body>
</html>
