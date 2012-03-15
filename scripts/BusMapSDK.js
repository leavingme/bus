//author: benjaminli
//email:  benjaminli@tencent.com

//从这里开始定义全局变量//////////////////////////////////////
window.google = window.google || {};
google.load = google.load || function () { return false; };
google.load('maps', '3', { other_params: 'sensor=false', callback: BusMapSDK });
// Keep track of where you clicked
var gClickedLatLng = null;
// Keep a Visible InfoWindow
var gInfoWindow = null;
var gBusLineRenderer = null;
// Keep temp search results
var gCurrentResults = [];
//全局变量定义结束////////////////////////////////////////////

//从这里开始定义全局函数//////////////////////////////////////
function CloseInfoWindow() {
    if (gInfoWindow) {
        gInfoWindow.close();
    }
};
function unselectMarkers() {
    for (var i = 0; i < gCurrentResults.length; i++) {
        gCurrentResults[i].unselect();
    }
};
function FindMembersHasProperty(theObj, thePropertyName) {
    //对于theObj的每一个成员，如果该成员具备thePropertyName属性，则该成员就是我们要找的
    var _ret = [];
    for (var tempMemName in theObj) {
        var tempMem = theObj[tempMemName];
        if (tempMem && tempMem.hasOwnProperty(thePropertyName)) {
            _ret.push(tempMem);
        }
    }
    return _ret;
};
function GetDistance(lat1, lon1, lat2, lon2) {
    //根据经纬度，求地表上的直线距离，单位：米
    var R = 6371; // km (change this constant to get miles)
    var dLat = (lat2 - lat1) * Math.PI / 180;
    var dLon = (lon2 - lon1) * Math.PI / 180;
    var a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
		Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
		Math.sin(dLon / 2) * Math.sin(dLon / 2);
    var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    var d = R * c;
    return Math.round(d * 1000); //km-->m
};
function BusMapSDK() {
    $(window).trigger('BusMapSDK_onBegin');
    //各种必须在Google Map API加载完毕以后才能初始化的组件
    ProjectedOverlay.Init();
    ProjectionHelperOverlay.Init();
    gInfoWindow = new google.maps.InfoWindow;
    $(window).trigger('BusMapSDK_onEnd');
};
//全局函数定义结束//////////////////////////////////////
/* Array extend Start */
Array.prototype.ToAttrString = function () {
    var me = this;
    var tempStrList = [];
    for (var i = 0; i < me.length; i++) {
        tempStrList.push(me[i].ToAttrString());
    }
    return tempStrList.join('#');
};
/* Array extend End */

/* BuildingSelector Data Model Start */
// BuildingSelector是一个全局唯一的对象，其方法都是静态方法
var BuildingSelector = {};
BuildingSelector.MyBuilding = null;
BuildingSelector.MyCity = null;
BuildingSelector.Map = null;
BuildingSelector.MarkerMgr = null;
BuildingSelector.Init = function (_map, _markerMgr) {
    BuildingSelector.Map = _map;
    BuildingSelector.MarkerMgr = _markerMgr;
    //设置导航栏的效果
    var Selector = document.getElementById('BuildingSelector');
    Selector.innerHTML = '';
    for (var tempBuidingName in BuildingSelector.BUILDINGS) {
        var tempLi = document.createElement('li');
        Selector.appendChild(tempLi);
        var tempA = document.createElement('a');
        tempLi.appendChild(tempA);
        tempA.href = 'javascript:void(0)';
        tempA.innerHTML = tempBuidingName;
        $(tempA).click(function () {
            BuildingSelector.SwitchTo(this.innerHTML);
        });
    };
    BuildingSelector.SwitchTo(BuildingSelector.MyBuilding);
};
BuildingSelector.BUILDINGS = {
    '腾讯大厦': [1, 22.54155, 113.935328, '深圳'],
    '飞亚达大厦': [2, 22.538959, 113.95569, '深圳'],
    '北京银科大厦': [0, 39.982256, 116.306106, '北京'],
    '腾讯成都分公司': [422, 30.5432857, 104.0694003, '成都'],
    '上海腾讯大厦': [403, 31.167701, 121.397284, '上海'],
    '腾讯广州研发中心': [0, 23.135079, 113.357524, '广州']
};
BuildingSelector.GetDefaultBuilding = function (theCityName) {
    for (var _buidingName in BuildingSelector.BUILDINGS) {
        if (theCityName == BuildingSelector.BUILDINGS[_buidingName][3]) {
            return _buidingName;
        }
    }
    //如果没找到，就默认腾讯大厦
    return '腾讯大厦';
};
BuildingSelector.GetDefaultCity = function (theBuildingName) {
    var tempBuilding = BuildingSelector.BUILDINGS[theBuildingName];
    if (tempBuilding) {
        return tempBuilding[3];
    }
    else {
        return '深圳';
    }
};
BuildingSelector.ParseCookie = function () {
    var myCityName = $.cookie('cityName');
    var myBuildingName = $.cookie('myBuilding');
    if (myBuildingName && BuildingSelector.BUILDINGS.hasOwnProperty(myBuildingName)) {
        //如果cookie中保存了myBuilding
        //则优先处理，以myBuilding为准
        BuildingSelector.MyBuilding = myBuildingName;
        BuildingSelector.MyCity = BuildingSelector.GetDefaultCity(myBuildingName);
    }
    else {
        //否则根据保存的城市来处理
        BuildingSelector.MyCity = myCityName;
        BuildingSelector.MyBuilding = BuildingSelector.GetDefaultBuilding(myCityName);
    }
};
BuildingSelector.GetMyLatLng = function () {
    return new google.maps.LatLng(BuildingSelector.BUILDINGS[BuildingSelector.MyBuilding][1],
             BuildingSelector.BUILDINGS[BuildingSelector.MyBuilding][2])
};
BuildingSelector.SwitchTo = function (_building) {
    if (!BuildingSelector.BUILDINGS.hasOwnProperty(_building)) {
        return;
    }
    BuildingSelector.MyBuilding = _building;
    BuildingSelector.MyCity = BuildingSelector.GetDefaultCity(_building)
    $.cookie('myBuilding', BuildingSelector.MyBuilding, { expires: 100 });
    $.cookie('cityName', BuildingSelector.MyCity, { expires: 100 });
    BuildingSelector.Refresh();

    //下面设置地图图标
    BuildingSelector.Map.panTo(BuildingSelector.GetMyLatLng());
    BuildingSelector.Map.setZoom(15);
    BuildingSelector.MarkerMgr.clearMarkers();
    var tempMarker = (new BusStation(
                BuildingSelector.BUILDINGS[_building][0],
                _building,
                BuildingSelector.BUILDINGS[_building][1],
                BuildingSelector.BUILDINGS[_building][2])
            ).GetMarker();
    BuildingSelector.MarkerMgr.addMarker(tempMarker, 0);
};
BuildingSelector.Refresh = function () {
    var list = document.getElementById('BuildingSelector').getElementsByTagName('a');
    for (var i = 0; i < list.length; i++) {
        if (list[i].innerHTML == BuildingSelector.MyBuilding) {
            list[i].className = 'city';
        }
        else {
            list[i].className = '';
        }
    }
};
/* BuildingSelector Data Model End */

/* SideBarMgr Data Model Start */
var SideBarMgr = {};
//SideBarMgr是一个静态的方法集合，全局唯一
SideBarMgr.DIV_ID = 'div_result';
SideBarMgr.ShowText = function (strText) {
    var divNode = document.getElementById(SideBarMgr.DIV_ID);
    SideBarMgr.ClearAll();
    divNode.innerHTML = strText;
};
SideBarMgr.ShowOneNode = function (theNode) {
    var divNode = document.getElementById(SideBarMgr.DIV_ID);
    SideBarMgr.ClearAll();
    divNode.appendChild(theNode);
};
SideBarMgr.AppendNode = function (theNode) {
    var divNode = document.getElementById(SideBarMgr.DIV_ID);
    divNode.appendChild(theNode);
};
SideBarMgr.ClearAll = function () {
    var divNode = document.getElementById(SideBarMgr.DIV_ID);
    while (divNode.hasChildNodes()) {
        divNode.removeChild(divNode.firstChild);
    }
};
/* SideBarMgr Data Model End */

/* BusLineCollection Data Model Begin */
var BusLineCollection = {};
BusLineCollection.ParseAttrString = function (data) {
    data = data || '';
    var _ret = new Array();
    var tempStrList = data.split('#');
    for (var i = 0; i < tempStrList.length; i++) {
        var theBusLine = BusLine.ParseAttrString(tempStrList[i]);
        if (theBusLine) {
            _ret.push(theBusLine);
        }
    }
    return _ret;
};
/* BusLineCollection Data Model End */

/* FavouriteMgr Data Model Start */
var FavouriteMgr = [];
//FavouriteMgr是一个数组实例，全局唯一
FavouriteMgr.Show = function () {
    var me = this;
    if (me.length > 0) {
        SideBarMgr.ClearAll();
        for (var i = 0; i < me.length; i++) {
            SideBarMgr.AppendNode(me[i].GetHtmlNodeDetail());
        }
    }
    else {
        SideBarMgr.ShowText('您的收藏夹中还没有添加班车<br />请从搜索开始或者尝试"右键菜单"吧 :)');
    }
};
FavouriteMgr.Load = function () {
    var me = this;
    me.length = 0;
    var tempList = BusLineCollection.ParseAttrString($.cookie('FavBus'));
    for (var i = 0; i < tempList.length; i++) {
        var theBusLine = tempList[i]
        me.push(theBusLine);
        $(theBusLine).trigger('fav_changed', 'FavTrue');
    }
};
FavouriteMgr.Save = function () {
    $.cookie('FavBus', this.ToAttrString(), { expires: 300 });
};
FavouriteMgr.Find = function (theBusLine) {
    var me = this;
    for (var i = 0; i < this.length; i++) {
        if (me[i]._id == theBusLine._id) return i;
    }
    return -1;
};
FavouriteMgr.GetExist = function (theBusLine) {
    var me = this;
    var i = me.Find(theBusLine);
    if (i >= 0) {
        return me[i];
    }
    else {
        return theBusLine;
    }
};
FavouriteMgr.Add = function (theBusLine) {
    var me = this;
    if (me.Find(theBusLine) < 0) {
        me.unshift(theBusLine);
        me.Save();
        $(theBusLine).trigger('fav_changed', 'FavTrue');
        me.Show();
    }
};
FavouriteMgr.Del = function (theBusLine) {
    var me = this;
    var i = me.Find(theBusLine);
    if (i >= 0) {
        me.splice(i, 1);
        me.Save();
        $(theBusLine).trigger('fav_changed', 'FavFalse');
    }
};
/* FavouriteMgr Data Model End */

/* BusLine Data Model Start */
function BusLine(bus_id, bus_name, bus_subtitle, bus_time) {
    var me = this;
    me._id = bus_id;
    me._name = bus_name;
    me._subtitle = bus_subtitle;
    me._time = bus_time;
    $(me).bind('fav_changed', me.SetFavNodeStatus);
};
BusLine.ParseAttrString = function (data) {
    data = data || '';
    var tempOptSet = data.split('|');
    if (4 == tempOptSet.length) {
        //送来的参数必须4个一组
        return new BusLine(tempOptSet[0], tempOptSet[1], tempOptSet[2], tempOptSet[3]);
    }
};
BusLine.prototype.ToAttrString = function () {
    var me = this;
    return [me._id, me._name, me._subtitle, me._time].join('|');
};
BusLine.prototype.GetHtmlNodeSimple = function (_fromConfirm) {
    var me = this;
    if (!me._htmlNodeSimple) {
        me._htmlNodeSimple = document.createElement('div');
        if (!_fromConfirm) {
            me._htmlNodeSimple.appendChild(me.GetFavNodeSimple());
        }
        var a = document.createElement('a');
        me._htmlNodeSimple.appendChild(a);
        a.setAttribute('href', 'javascript:void(0)');
        a.innerHTML = me._name;
        if (me._time) {
            a.innerHTML += ['(', me._time, ')'].join('');
        }
        if (_fromConfirm) {
            $(a).click(function () {
                window.open('/search.asp?q=' + me._name);
            });
        }
        else {
            $(a).click(function () {
                SideBarMgr.ShowOneNode(me.GetHtmlNodeDetail());
            });
        }
    }
    return me._htmlNodeSimple;
};
BusLine.prototype.GetHtmlNodeDetail = function () {
    var me = this;
    if (!me._htmlNodeDetail) {
        me._htmlNodeDetail = document.createElement('li');
        me._htmlNodeDetail.appendChild(me.GetFavNodeDetail());
        var header = document.createElement('b');
        me._htmlNodeDetail.appendChild(header);
        header.innerHTML = me._name;
        me._htmlNodeDetail.appendChild(me._getHtmlNodeDetailBody());
    }
    return me._htmlNodeDetail;
};
BusLine.prototype._getHtmlNodeDetailBody = function () {
    var me = this;
    if (!me._htmlNodeDetailBody) {
        me._htmlNodeDetailBody = document.createElement('div');
        me._htmlNodeDetailBody.innerHTML += '正在查询班车路线...';
        me._htmlNodeDetailBody.className = 'loading';
        $(me).bind('stops_got', function () {
            $(me).trigger('stops_available');
            me._htmlNodeDetailBody.className = '';
            while (me._htmlNodeDetailBody.hasChildNodes()) {
                me._htmlNodeDetailBody.removeChild(me._htmlNodeDetailBody.firstChild);
            }
            me._htmlNodeDetailBody.appendChild(me.GetRenderNode());
            me._htmlNodeDetailBody.appendChild(BusStationCollection.GetDescription(me._stops));
        });
        me.QueryForStops();
    }
    return me._htmlNodeDetailBody;
};
BusLine.prototype.SetFavNodeStatus = function (e, _newClassName) {
    var me = this;
    me.GetFavNodeDetail().className = _newClassName;
    me.GetFavNodeSimple().className = _newClassName;
};
BusLine.prototype._createFavNode = function () {
    var me = this;
    var _favNode = document.createElement('img');
    _favNode.setAttribute('src', '/images/transparent.png');
    if (FavouriteMgr.Find(me) < 0) {
        _favNode.className = 'FavFalse';
    }
    else {
        _favNode.className = 'FavTrue';
    }
    $(_favNode).click(function () {
        if (_favNode.className == 'FavFalse') {
            FavouriteMgr.Add(me);
        }
        else {
            FavouriteMgr.Del(me);
        }
    });
    return _favNode;
};
BusLine.prototype.GetFavNodeSimple = function () {
    var me = this;
    if (!me._favNodeSimple) {
        me._favNodeSimple = me._createFavNode();
    }
    return me._favNodeSimple;
};
BusLine.prototype.GetFavNodeDetail = function () {
    var me = this;
    if (!me._favNodeDetail) {
        me._favNodeDetail = me._createFavNode();
    }
    return me._favNodeDetail;
};
BusLine.prototype.GetRenderNode = function () {
    var me = this;
    if (!me._renderNode) {
        me._renderNode = document.createElement('div');
        var a = document.createElement('a');
        me._renderNode.appendChild(a);
        a.setAttribute('href', 'javascript:void(0)');
        a.innerHTML = '在地图中展示路线';
        $(a).click(function () {
            $(me).bind('stops_available', function () {
                if (!gBusLineRenderer) {
                    gBusLineRenderer = new BusLineRenderer(gMap);
                }
                gBusLineRenderer.SetStops(me._stops, { 'draggable': false });
                gMarkerMgr.clearMarkers();
            });
            me.QueryForStops();
        });
    }
    return me._renderNode;
};
BusLine.prototype.QueryForStops = function () {
    var me = this;
    if (me._stops) {
        $(me).trigger('stops_available');
    }
    else {
        $.post('/action/Query.asp', {
            'id_cmd': escape(3),
            'bus_id': escape(me._id)
        }, function (data) {
            data = data || '';
            me._stops = BusStationCollection.ParseAttrString(data);
            $(me).trigger('stops_got');
        });
    }
};
BusLine.prototype.GetStops = function () {
    return this._stops;
};
/* BusLine Data Model End */

/* BusLineRenderer Data Model Start */
function BusLineRenderer(map) {
    var me = this;
    me._map = map;
    me._directionsService = new google.maps.DirectionsService();
};
BusLineRenderer.prototype.SetStops = function (stops, opt_opts) {
    var me = this;
    opt_opts = opt_opts || {};
    me.ClearAll();
    me._stops = stops;
    //改变视角
    var bounds = new google.maps.LatLngBounds();
    for (i = 0; i < stops.length; i++) {
        bounds.extend(stops[i].GetLatLng());
    }
    me._map.fitBounds(bounds);
    //开始分页，突破Google地图最多10个节点的限制
    me._pages = [];
    var tempPage = new BusLineWaypointPager(me._map, opt_opts);
    for (var i = 0; i < me._stops.length; i++) {
        var tempBusStop = me._stops[i];
        if (!tempPage.Append(tempBusStop)) {
            //没添加成功，说明此页已加满，换页
            var lastPageDest = tempPage.GetDestination();
            me._pages.push(tempPage);
            tempPage = new BusLineWaypointPager(me._map, opt_opts);
            tempPage.Append(lastPageDest); //把上一页的终点设置为新页的起点
            tempPage.Append(tempBusStop); //把刚才失败的再加上
        }
    }
    me._pages.push(tempPage); //保存最后一页
    if (opt_opts.draggable) {
        //如果是拖拽模式，才去做API crack
        //重新遍历一次，给每个page增加页码，方便寻址
        for (i = 0; i < me._pages.length; i++) {
            tempPage = me._pages[i];
            tempPage.Index = i;
            $(tempPage).bind('markers_changed', function (event) {
                var thePage = event.target;
                var theIndex = thePage.Index;
                var tempMarkers = null;
                //看看上一页能否替换
                var lastPage = me._pages[theIndex - 1];
                if (lastPage) {
                    tempMarkers = lastPage.GetMarkerDrawer().markers;
                    if (tempMarkers) {
                        //删掉上一页的F
                        tempMarkers[tempMarkers.length - 1].setMap(null);
                        me.LinkPagePrev(theIndex);
                    }
                }
                //看看下一页能否替换
                var nextPage = me._pages[theIndex + 1];
                if (nextPage) {
                    tempMarkers = nextPage.GetMarkerDrawer().markers;
                    if (tempMarkers) {
                        //删掉这一页的F
                        var theMarkers = thePage.GetMarkerDrawer().markers;
                        theMarkers[theMarkers.length - 1].setMap(null);
                        me.LinkPagePrev(theIndex + 1);
                    }
                }
            });
        }
    }
    //所有的页面添加完毕，开始发送路线请求
    for (i = 0; i < me._pages.length; i++) {
        me._pages[i].ShowDirections(me._directionsService);
    }
};
BusLineRenderer.prototype.ClearAll = function () {
    var me = this;
    if (me._pages) {
        for (var i = 0; i < me._pages.length; i++) {
            me._pages[i].Clear();
        }
    }
    me._stops = null;
};
/* BusLineRenderer Data Model End */

/* BusLineWaypointPager Data Model Start */
function BusLineWaypointPager(map, opt_opts) {
    var me = this;
    opt_opts = opt_opts || {};
    me._draggable = opt_opts.draggable || false;

    me._directionsRenderer = new google.maps.DirectionsRenderer({
        'map': map,
        'hideRouteList': true,
        'preserveViewport': true,
        'draggable': me._draggable
    });

    me._waypoints = new Array();
    me._dirResult = null;
    me._initialize();
};
BusLineWaypointPager.prototype._initialize = function () {
    var me = this;
    google.maps.event.addListener(me._directionsRenderer, 'directions_changed', function () {
        //将被载入InfoWindow的内容，是每个节点的start_address和最后一个节点的end_address
        //修改这些内容，保证InfoWindow中显示我们的Description
        var tempResult = me._directionsRenderer.getDirections();
        var pLegs = tempResult.routes[0].legs;
        for (var i = 0; i < pLegs.length; i++) {
            var tempLeg = pLegs[i];
            tempLeg.start_address = me._waypoints[i].GetDescription();
        }
        //循环结束以后的tempLeg必然是终点
        tempLeg.end_address = me._waypoints[i].GetDescription();
        me._dirResult = tempResult;
        //一般在这个时候，_directionsRenderer内部的MarkerDrawer应该创建好了
        //寻找它，并监听marker_changed事件
        me.GetMarkerDrawer();
    });
};
BusLineWaypointPager.prototype.GetMarkerDrawer = function () {
    var me = this;
    if (!me._markerDrawer) {
        var _members = FindMembersHasProperty(me._directionsRenderer, 'routeIndex');
        for (var i = 0; i < _members.length; i++) {
            var tempObj = _members[i];
            var _list = FindMembersHasProperty(tempObj, 'markers_changed');
            if (_list.length > 0) {
                me._markerDrawer = tempObj;
                google.maps.event.addListener(me._markerDrawer, 'markers_changed', function () {
                    $(me).trigger('markers_changed');
                });
                break;
            }
        }
    }
    return me._markerDrawer;
};
BusLineWaypointPager.prototype.Clear = function () {
    var me = this;
    me._directionsRenderer.setMap(null);
    me._waypoints = new Array();
    me._dirResult = null;
};
BusLineWaypointPager.prototype.Append = function (busStation) {
    var me = this;
    if (!me.IsFull()) {
        me._waypoints.push(busStation);
        return true;
    }
    return false;
};
BusLineWaypointPager.prototype.IsFull = function () {
    var me = this;
    if (me._draggable) {
        return me._waypoints.length >= 6;
    }
    else {
        return me._waypoints.length >= 10;
    }
};
BusLineWaypointPager.prototype.GetOrigin = function () {
    return this._waypoints[0];
};
BusLineWaypointPager.prototype.GetDestination = function () {
    var array = this._waypoints;
    return array[array.length - 1];
};
BusLineWaypointPager.prototype._getDirectionsRequest = function () {
    var me = this;
    var tempWaypnts = [];
    for (var i = 1; i < me._waypoints.length - 1; i++) {
        tempWaypnts.push(me._waypoints[i].GetWaypoint());
    }
    var request = {
        origin: me.GetOrigin().GetLatLng(),
        destination: me.GetDestination().GetLatLng(),
        waypoints: tempWaypnts,
        provideRouteAlternatives: false,
        travelMode: google.maps.DirectionsTravelMode.DRIVING
    };
    return request;
};
BusLineWaypointPager.prototype.ShowDirections = function (directionsService) {
    var me = this;
    if (me._dirResult) {
        me._directionsRenderer.setDirections(me._dirResult);
    }
    else {
        directionsService.route(me._getDirectionsRequest(), function (response, status) {
            if (status == google.maps.DirectionsStatus.OK) {
                me._directionsRenderer.setDirections(response);
            }
        });
    }
};
BusLineWaypointPager.prototype.GetAllRouteLegs = function () {
    return this._directionsRenderer.getDirections().routes[0].legs;
};
/* BusLineWaypointPager Data Model End */

/* BusStationCollection Data Model Start */
var BusStationCollection = {};
BusStationCollection.ParseAttrString = function (data) {
    data = data || '';
    var _ret = new Array();
    var tempStrList = data.split('#');
    for (var i = 0; i < tempStrList.length; i++) {
        var theBusStation = BusStation.ParseAttrString(tempStrList[i]);
        if (theBusStation) {
            _ret.push(theBusStation);
        }
    }
    return _ret;
};
BusStationCollection.GetDescription = function (_array) {
    var me = _array;
    var div = document.createElement('div');
    for (var i = 0; i < me.length; i++) {
        var tempBusStation = me[i];
        var nobr = document.createElement('nobr');
        div.appendChild(nobr);
        nobr.innerHTML += tempBusStation._name;
        if (tempBusStation._lne_time) {
            nobr.innerHTML += ['(', tempBusStation._lne_time, ')'].join('');
        }
        div.innerHTML += ' ';
    }
    return div;
};
/* BusStationCollection Data Model End */

/* BusStation Data Model Start */
function BusStation(stn_id, stn_name, stn_lat, stn_lng, stn_map, lne_order, lne_time) {
    var me = this;
    me._id = stn_id;
    me._name = stn_name;
    me._lat = stn_lat;
    me._lng = stn_lng;
    me._stn_map = stn_map;
    me._lne_order = lne_order;
    me._lne_time = lne_time;
};
BusStation.Init = function (map) {
    //    BusStation.ICON = new google.maps.MarkerImage(
    //          '/images/marker.png',
    //          new google.maps.Size(32, 32),
    //          new google.maps.Point(0, 0),
    //          new google.maps.Point(6, 31)
    //          );
    //    BusStation.ICON = new google.maps.MarkerImage(
    //      '/images/marker1.png',
    //      new google.maps.Size(32, 32),
    //      new google.maps.Point(0, 0),
    //      new google.maps.Point(16, 31)
    //      );
    BusStation.MAP = map;
    BusStation.ICON = new google.maps.MarkerImage(
          '/images/marker3.png',
          new google.maps.Size(32, 32),
          new google.maps.Point(0, 0),
          new google.maps.Point(15, 29)
          );
    BusStation.ICON_CONFIRM = new google.maps.MarkerImage(
          '/images/icon_confirm.png',
          new google.maps.Size(52, 57),
          new google.maps.Point(0, 0),
          new google.maps.Point(44, 55)
          );
};
BusStation.ParseAttrString = function (data) {
    data = data || '';
    var tempOptSet = data.split('|');
    if (7 == tempOptSet.length) {
        //从后台送来的参数必须是7个一组
        return new BusStation(
            tempOptSet[0],
            tempOptSet[1],
            tempOptSet[2],
            tempOptSet[3],
            tempOptSet[4],
            tempOptSet[5],
            tempOptSet[6]
            );
    }
};
BusStation.prototype.ToAttrString = function () {
    var me = this;
    return [me._id, me._name, me._lat, me._lng, me._stn_map, me._lne_order, me._lne_time].join('|');
};
BusStation.prototype.SetLatLng = function (latLng) {
    var me = this;
    me._lat = latLng.lat();
    me._lng = latLng.lng();
};
BusStation.prototype.GetLatLng = function () {
    return new google.maps.LatLng(this._lat, this._lng);
};
BusStation.prototype.lat = function () {
    return this._lat;
};
BusStation.prototype.lng = function () {
    return this._lng;
};
BusStation.prototype.GetWaypoint = function () {
    var me = this;
    var _ret = {
        location: me.GetLatLng(),
        stopover: true
    };
    return _ret;
};
BusStation.prototype.GetDescription = function () {
    var me = this;
    var _ret = '<h3>' + me._name;
    if (me._lne_time) {
        _ret += ['(', me._lne_time, ')'].join('');
    }
    _ret += '</h3>';
    return _ret;
};
BusStation.prototype.GetMarker = function () {
    var me = this;
    if (!me._marker) {
        me._marker = new google.maps.Marker({
            title: me._name,
            position: new google.maps.LatLng(me._lat, me._lng),
            icon: BusStation.ICON,
            clickable: true,
            animation: google.maps.Animation.DROP
        });
        // Add marker click event listener.
        google.maps.event.addListener(me._marker, 'click', function () {
            me.ShowInfoWindow();
        });
    }
    return me._marker;
};
BusStation.prototype.ShowInfoWindow = function () {
    var me = this;
    if (!me._busList) {
        me._busList = document.createElement('div');
        me._busList.style.overflow = 'auto';
        me._busList.innerHTML = ['<h3>', me._name, '</h3>',
            '<div class="loading">正在查询相关班车...</div>'].join('');

        google.maps.event.addListenerOnce(gInfoWindow, 'domready', function () {
            me.QueryBusList();
        });
    }
    CloseInfoWindow();
    gInfoWindow.setContent(me._busList);
    gInfoWindow.open(BusStation.MAP, me._marker);
};
BusStation.prototype.QueryBusList = function () {
    var me = this;
    $.post('/action/Query.asp', {
        'id_cmd': escape(2),
        'stn_id': escape(me._id)
    }, function (data) {
        data = data || '';
        var result = BusLineCollection.ParseAttrString(data);
        var arr_Bus = new Array();
        for (var i = 0; i < result.length; i++) {
            var tempBusLine = result[i];
            arr_Bus.push(FavouriteMgr.GetExist(tempBusLine));
        }
        delete me._busList;
        me._busList = document.createElement('div');
        me._busList.style.overflow = 'auto';
        me._busList.innerHTML = ['<h3>', me._name, '</h3>'].join('');
        if (arr_Bus.length > 0) {
            for (var i = 0; i < arr_Bus.length; i++) {
                me._busList.appendChild(arr_Bus[i].GetHtmlNodeSimple());
            }
        }
        else {
            me._busList.innerHTML += '对不起，没有停靠此站点的班车。';
        }
        me.ShowInfoWindow();
    });
};
/* BusStation Data Model End */

/* SearchResult Data Model Begin */
function SearchResult(result) {
    var me = this;
    me.result_ = result;
    me.initialize();
};
SearchResult.prototype.initialize = function () {
    var me = this;
    me.GetMarker();
    $(me.GetHtmlNode()).mouseover(function () {
        // Highlight the marker and result icon when the result is
        // mouseovered.  Do not remove any other highlighting at this time.
        me.highlight(true);
    });
    $(me.GetHtmlNode()).mouseout(function () {
        // Remove highlighting unless this marker is selected (the info
        // window is open).
        if (!me.selected_) me.highlight(false);
    });
    $(me.GetHtmlNode()).click(function () {
        me.select();
    });
    SideBarMgr.AppendNode(me.GetHtmlNode());
};
SearchResult.Init = function (map) {
    SearchResult.MAP = map;
    SearchResult.ICON_YELLOW = new google.maps.MarkerImage(
      '/images/mm_20_yellow.png',
      new google.maps.Size(12, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));
    SearchResult.ICON_RED = new google.maps.MarkerImage(
      '/images/mm_20_red.png',
      new google.maps.Size(12, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));
    SearchResult.SMALL_SHADOW = new google.maps.MarkerImage(
      '/images/mm_20_shadow.png',
      new google.maps.Size(22, 20),
      new google.maps.Point(0, 0),
      new google.maps.Point(6, 20));
};
SearchResult.prototype.GetHtmlNode = function () {
    var me = this;
    if (!me.htmlNode_) {
        var container = document.createElement('li');
        container.className = 'unselected';
        //这里先复用InfoWindow 的内容，未来可能改成自己特有的
        container.innerHTML = me.GetInfoWindowHtml();
        me.htmlNode_ = container;
    }
    return me.htmlNode_;
};
SearchResult.prototype.GetInfoWindowHtml = function () {
    var me = this;
    if (!me.htmlString_) {
        var strHtml = '';
        strHtml += ['<h3>', me.result_.titleNoFormatting, '</h3>'].join('');
        if (me.result_.addressLines && me.result_.addressLines.length > 0) {
            for (var i = 0; i < me.result_.addressLines.length; i++) {
                strHtml += ['<div>', me.result_.addressLines[i], '</div>'].join('');
            }
        }
        if (me.result_.phoneNumbers && me.result_.phoneNumbers.length > 0) {
            var typeMap = {
                'main': '电话',
                'fax': '传真',
                'mobile': '移动电话',
                '': '电话'
            };
            for (i = 0; i < me.result_.phoneNumbers.length; i++) {
                var typeText = typeMap[me.result_.phoneNumbers[i].type];
                if (!typeText) {
                    typeText = me.result_.phoneNumbers[i].type;
                };
                strHtml += ['<div>', typeText, '：', me.result_.phoneNumbers[i].number, '</div>'].join('');
            }
        }
        strHtml += ['<a href="', me.result_.url, '" target="_blank">在谷歌地图中查看</a><br />'].join('');
        strHtml += '<a href="javascript:void (0)" onclick="getStationsNearby()">搜索附近的班车停靠站</a>';
        me.htmlString_ = strHtml;
    }
    return me.htmlString_;
};
SearchResult.prototype.GetMarker = function () {
    var me = this;
    if (!me.marker_) {
        me.marker_ = new google.maps.Marker({
            position: new google.maps.LatLng(parseFloat(me.result_.lat),
                                         parseFloat(me.result_.lng)),
            icon: SearchResult.ICON_YELLOW,
            shadow: SearchResult.SMALL_SHADOW
        });
        google.maps.event.addListener(me.marker_, 'click', function () {
            me.select();
        });
    }
    return me.marker_;
};
// Unselect any selected markers and then highlight this result and
// display the info window on it.
SearchResult.prototype.select = function () {
    var me = this;
    unselectMarkers();
    me.selected_ = true;
    this.highlight(true);
    gInfoWindow.setContent(this.GetInfoWindowHtml());
    gInfoWindow.open(SearchResult.MAP, this.GetMarker());
};
SearchResult.prototype.isSelected = function () {
    return this.selected_;
};
// Remove any highlighting on this result.
SearchResult.prototype.unselect = function () {
    this.selected_ = false;
    this.highlight(false);
};
SearchResult.prototype.highlight = function (highlight) {
    gClickedLatLng = this.GetMarker().getPosition();
    this.GetMarker().setOptions({
        icon: highlight ? SearchResult.ICON_RED : SearchResult.ICON_YELLOW
    });
    this.GetHtmlNode().className = 'unselected' + (highlight ? ' red' : '');
}
/* SearchResult Data Model End */

/**
* @name MarkerManager v3
* @version 1.0
* @copyright (c) 2007 Google Inc.
* @author Doug Ricket, Bjorn Brala (port to v3), others,
*
* @fileoverview Marker manager is an interface between the map and the user,
* designed to manage adding and removing many points when the viewport changes.
* <br /><br />
* <b>How it Works</b>:<br/> 
* The MarkerManager places its markers onto a grid, similar to the map tiles.
* When the user moves the viewport, it computes which grid cells have
* entered or left the viewport, and shows or hides all the markers in those
* cells.
* (If the users scrolls the viewport beyond the markers that are loaded,
* no markers will be visible until the <code>EVENT_moveend</code> 
* triggers an update.)
* In practical consequences, this allows 10,000 markers to be distributed over
* a large area, and as long as only 100-200 are visible in any given viewport,
* the user will see good performance corresponding to the 100 visible markers,
* rather than poor performance corresponding to the total 10,000 markers.
* Note that some code is optimized for speed over space,
* with the goal of accommodating thousands of markers.
*/

/*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License. 
*/

/**
* @name MarkerManagerOptions
* @class This class represents optional arguments to the {@link MarkerManager}
*     constructor.
* @property {Number} maxZoom Sets the maximum zoom level monitored by a
*     marker manager. If not given, the manager assumes the maximum map zoom
*     level. This value is also used when markers are added to the manager
*     without the optional {@link maxZoom} parameter.
* @property {Number} borderPadding Specifies, in pixels, the extra padding
*     outside the map's current viewport monitored by a manager. Markers that
*     fall within this padding are added to the map, even if they are not fully
*     visible.
* @property {Boolean} trackMarkers=false Indicates whether or not a marker
*     manager should track markers' movements. If you wish to move managed
*     markers using the {@link setPoint}/{@link setLatLng} methods, 
*     this option should be set to {@link true}.
*/

/**
* Creates a new MarkerManager that will show/hide markers on a map.
*
* Events:
* @event changed (Parameters: shown bounds, shown markers) Notify listeners when the state of what is displayed changes.
* @event loaded MarkerManager has succesfully been initialized.
*
* @constructor
* @param {Map} map The map to manage.
* @param {Object} opt_opts A container for optional arguments:
*   {Number} maxZoom The maximum zoom level for which to create tiles.
*   {Number} borderPadding The width in pixels beyond the map border,
*                   where markers should be display.
*   {Boolean} trackMarkers Whether or not this manager should track marker
*                   movements.
*/
function MarkerManager(map, opt_opts) {
    var me = this;
    me.map_ = map;
    me.mapZoom_ = map.getZoom();

    me.projectionHelper_ = new ProjectionHelperOverlay(map);
    google.maps.event.addListener(me.projectionHelper_, 'ready', function () {
        me.projection_ = this.getProjection();
        me.initialize(map, opt_opts);
    });
}


MarkerManager.prototype.initialize = function (map, opt_opts) {
    var me = this;

    opt_opts = opt_opts || {};
    me.tileSize_ = MarkerManager.DEFAULT_TILE_SIZE_;

    var mapTypes = map.mapTypes;

    // Find max zoom level
    var mapMaxZoom = 1;
    for (var sType in mapTypes) {
        if (typeof map.mapTypes.get(sType) === 'object' && typeof map.mapTypes.get(sType).maxZoom === 'number') {
            var mapTypeMaxZoom = map.mapTypes.get(sType).maxZoom;
            if (mapTypeMaxZoom > mapMaxZoom) {
                mapMaxZoom = mapTypeMaxZoom;
            }
        }
    }

    me.maxZoom_ = opt_opts.maxZoom || 19;

    me.trackMarkers_ = opt_opts.trackMarkers;
    me.show_ = opt_opts.show || true;

    var padding;
    if (typeof opt_opts.borderPadding === 'number') {
        padding = opt_opts.borderPadding;
    } else {
        padding = MarkerManager.DEFAULT_BORDER_PADDING_;
    }
    // The padding in pixels beyond the viewport, where we will pre-load markers.
    me.swPadding_ = new google.maps.Size(-padding, padding);
    me.nePadding_ = new google.maps.Size(padding, -padding);
    me.borderPadding_ = padding;

    me.gridWidth_ = {};

    me.grid_ = {};
    me.grid_[me.maxZoom_] = {};
    me.numMarkers_ = {};
    me.numMarkers_[me.maxZoom_] = 0;


    google.maps.event.addListener(map, 'dragend', function () {
        me.onMapMoveEnd_();
    });
    google.maps.event.addListener(map, 'zoom_changed', function () {
        me.onMapMoveEnd_();
    });



    /**
    * This closure provide easy access to the map.
    * They are used as callbacks, not as methods.
    * @param GMarker marker Marker to be removed from the map
    * @private
    */
    me.removeOverlay_ = function (marker) {
        marker.setMap(null);
        me.shownMarkers_--;
    };

    /**
    * This closure provide easy access to the map.
    * They are used as callbacks, not as methods.
    * @param GMarker marker Marker to be added to the map
    * @private
    */
    me.addOverlay_ = function (marker) {
        if (me.show_) {
            marker.setMap(me.map_);
            me.shownMarkers_++;
        }
    };

    me.resetManager_();
    me.shownMarkers_ = 0;

    me.shownBounds_ = me.getMapGridBounds_();

    google.maps.event.trigger(me, 'loaded');

};

/**
*  Default tile size used for deviding the map into a grid.
*/
MarkerManager.DEFAULT_TILE_SIZE_ = 1024;

/*
*  How much extra space to show around the map border so
*  dragging doesn't result in an empty place.
*/
MarkerManager.DEFAULT_BORDER_PADDING_ = 100;

/**
*  Default tilesize of single tile world.
*/
MarkerManager.MERCATOR_ZOOM_LEVEL_ZERO_RANGE = 256;


/**
* Initializes MarkerManager arrays for all zoom levels
* Called by constructor and by clearAllMarkers
*/
MarkerManager.prototype.resetManager_ = function () {
    var mapWidth = MarkerManager.MERCATOR_ZOOM_LEVEL_ZERO_RANGE;
    for (var zoom = 0; zoom <= this.maxZoom_; ++zoom) {
        this.grid_[zoom] = {};
        this.numMarkers_[zoom] = 0;
        this.gridWidth_[zoom] = Math.ceil(mapWidth / this.tileSize_);
        mapWidth <<= 1;
    }

};

/**
* Removes all markers in the manager, and
* removes any visible markers from the map.
*/
MarkerManager.prototype.clearMarkers = function () {
    this.processAll_(this.shownBounds_, this.removeOverlay_);
    this.resetManager_();
};


/**
* Gets the tile coordinate for a given latlng point.
*
* @param {LatLng} latlng The geographical point.
* @param {Number} zoom The zoom level.
* @param {google.maps.Size} padding The padding used to shift the pixel coordinate.
*               Used for expanding a bounds to include an extra padding
*               of pixels surrounding the bounds.
* @return {GPoint} The point in tile coordinates.
*
*/
MarkerManager.prototype.getTilePoint_ = function (latlng, zoom, padding) {

    var pixelPoint = this.projectionHelper_.LatLngToPixel(latlng, zoom);

    var point = new google.maps.Point(
    Math.floor((pixelPoint.x + padding.width) / this.tileSize_),
    Math.floor((pixelPoint.y + padding.height) / this.tileSize_)
  );

    return point;
};


/**
* Finds the appropriate place to add the marker to the grid.
* Optimized for speed; does not actually add the marker to the map.
* Designed for batch-processing thousands of markers.
*
* @param {Marker} marker The marker to add.
* @param {Number} minZoom The minimum zoom for displaying the marker.
* @param {Number} maxZoom The maximum zoom for displaying the marker.
*/
MarkerManager.prototype.addMarkerBatch_ = function (marker, minZoom, maxZoom) {
    var me = this;

    var mPoint = marker.getPosition();
    marker.MarkerManager_minZoom = minZoom;


    // Tracking markers is expensive, so we do this only if the
    // user explicitly requested it when creating marker manager.
    if (this.trackMarkers_) {
        google.maps.event.addListener(marker, 'changed', function (a, b, c) {
            me.onMarkerMoved_(a, b, c);
        });
    }

    var gridPoint = this.getTilePoint_(mPoint, maxZoom, new google.maps.Size(0, 0, 0, 0));

    for (var zoom = maxZoom; zoom >= minZoom; zoom--) {
        var cell = this.getGridCellCreate_(gridPoint.x, gridPoint.y, zoom);
        cell.push(marker);

        gridPoint.x = gridPoint.x >> 1;
        gridPoint.y = gridPoint.y >> 1;
    }
};


/**
* Returns whether or not the given point is visible in the shown bounds. This
* is a helper method that takes care of the corner case, when shownBounds have
* negative minX value.
*
* @param {Point} point a point on a grid.
* @return {Boolean} Whether or not the given point is visible in the currently
* shown bounds.
*/
MarkerManager.prototype.isGridPointVisible_ = function (point) {
    var vertical = this.shownBounds_.minY <= point.y &&
      point.y <= this.shownBounds_.maxY;
    var minX = this.shownBounds_.minX;
    var horizontal = minX <= point.x && point.x <= this.shownBounds_.maxX;
    if (!horizontal && minX < 0) {
        // Shifts the negative part of the rectangle. As point.x is always less
        // than grid width, only test shifted minX .. 0 part of the shown bounds.
        var width = this.gridWidth_[this.shownBounds_.z];
        horizontal = minX + width <= point.x && point.x <= width - 1;
    }
    return vertical && horizontal;
};


/**
* Reacts to a notification from a marker that it has moved to a new location.
* It scans the grid all all zoom levels and moves the marker from the old grid
* location to a new grid location.
*
* @param {Marker} marker The marker that moved.
* @param {LatLng} oldPoint The old position of the marker.
* @param {LatLng} newPoint The new position of the marker.
*/
MarkerManager.prototype.onMarkerMoved_ = function (marker, oldPoint, newPoint) {
    // NOTE: We do not know the minimum or maximum zoom the marker was
    // added at, so we start at the absolute maximum. Whenever we successfully
    // remove a marker at a given zoom, we add it at the new grid coordinates.
    var zoom = this.maxZoom_;
    var changed = false;
    var oldGrid = this.getTilePoint_(oldPoint, zoom, new google.maps.Size(0, 0, 0, 0));
    var newGrid = this.getTilePoint_(newPoint, zoom, new google.maps.Size(0, 0, 0, 0));
    while (zoom >= 0 && (oldGrid.x !== newGrid.x || oldGrid.y !== newGrid.y)) {
        var cell = this.getGridCellNoCreate_(oldGrid.x, oldGrid.y, zoom);
        if (cell) {
            if (this.removeFromArray_(cell, marker)) {
                this.getGridCellCreate_(newGrid.x, newGrid.y, zoom).push(marker);
            }
        }
        // For the current zoom we also need to update the map. Markers that no
        // longer are visible are removed from the map. Markers that moved into
        // the shown bounds are added to the map. This also lets us keep the count
        // of visible markers up to date.
        if (zoom === this.mapZoom_) {
            if (this.isGridPointVisible_(oldGrid)) {
                if (!this.isGridPointVisible_(newGrid)) {
                    this.removeOverlay_(marker);
                    changed = true;
                }
            } else {
                if (this.isGridPointVisible_(newGrid)) {
                    this.addOverlay_(marker);
                    changed = true;
                }
            }
        }
        oldGrid.x = oldGrid.x >> 1;
        oldGrid.y = oldGrid.y >> 1;
        newGrid.x = newGrid.x >> 1;
        newGrid.y = newGrid.y >> 1;
        --zoom;
    }
    if (changed) {
        this.notifyListeners_();
    }
};


/**
* Removes marker from the manager and from the map
* (if it's currently visible).
* @param {GMarker} marker The marker to delete.
*/
MarkerManager.prototype.removeMarker = function (marker) {
    var zoom = this.maxZoom_;
    var changed = false;
    var point = marker.getPosition();
    var grid = this.getTilePoint_(point, zoom, new google.maps.Size(0, 0, 0, 0));
    while (zoom >= 0) {
        var cell = this.getGridCellNoCreate_(grid.x, grid.y, zoom);

        if (cell) {
            this.removeFromArray_(cell, marker);
        }
        // For the current zoom we also need to update the map. Markers that no
        // longer are visible are removed from the map. This also lets us keep the count
        // of visible markers up to date.
        if (zoom === this.mapZoom_) {
            if (this.isGridPointVisible_(grid)) {
                this.removeOverlay_(marker);
                changed = true;
            }
        }
        grid.x = grid.x >> 1;
        grid.y = grid.y >> 1;
        --zoom;
    }
    if (changed) {
        this.notifyListeners_();
    }
    this.numMarkers_[marker.MarkerManager_minZoom]--;
};


/**
* Add many markers at once.
* Does not actually update the map, just the internal grid.
*
* @param {Array of Marker} markers The markers to add.
* @param {Number} minZoom The minimum zoom level to display the markers.
* @param {Number} opt_maxZoom The maximum zoom level to display the markers.
*/
MarkerManager.prototype.addMarkers = function (markers, minZoom, opt_maxZoom) {
    var maxZoom = this.getOptMaxZoom_(opt_maxZoom);
    for (var i = markers.length - 1; i >= 0; i--) {
        this.addMarkerBatch_(markers[i], minZoom, maxZoom);
    }

    this.numMarkers_[minZoom] += markers.length;
};


/**
* Returns the value of the optional maximum zoom. This method is defined so
* that we have just one place where optional maximum zoom is calculated.
*
* @param {Number} opt_maxZoom The optinal maximum zoom.
* @return The maximum zoom.
*/
MarkerManager.prototype.getOptMaxZoom_ = function (opt_maxZoom) {
    return opt_maxZoom || this.maxZoom_;
};


/**
* Calculates the total number of markers potentially visible at a given
* zoom level.
*
* @param {Number} zoom The zoom level to check.
*/
MarkerManager.prototype.getMarkerCount = function (zoom) {
    var total = 0;
    for (var z = 0; z <= zoom; z++) {
        total += this.numMarkers_[z];
    }
    return total;
};

/** 
* Returns a marker given latitude, longitude and zoom. If the marker does not 
* exist, the method will return a new marker. If a new marker is created, 
* it will NOT be added to the manager. 
* 
* @param {Number} lat - the latitude of a marker. 
* @param {Number} lng - the longitude of a marker. 
* @param {Number} zoom - the zoom level 
* @return {GMarker} marker - the marker found at lat and lng 
*/
MarkerManager.prototype.getMarker = function (lat, lng, zoom) {
    var mPoint = new google.maps.LatLng(lat, lng);
    var gridPoint = this.getTilePoint_(mPoint, zoom, new google.maps.Size(0, 0, 0, 0));

    var marker = new google.maps.Marker({ position: mPoint });

    var cellArray = this.getGridCellNoCreate_(gridPoint.x, gridPoint.y, zoom);
    if (cellArray !== undefined) {
        for (var i = 0; i < cellArray.length; i++) {
            if (lat === cellArray[i].getLatLng().lat() && lng === cellArray[i].getLatLng().lng()) {
                marker = cellArray[i];
            }
        }
    }
    return marker;
};

/**
* Add a single marker to the map.
*
* @param {Marker} marker The marker to add.
* @param {Number} minZoom The minimum zoom level to display the marker.
* @param {Number} opt_maxZoom The maximum zoom level to display the marker.
*/
MarkerManager.prototype.addMarker = function (marker, minZoom, opt_maxZoom) {
    var maxZoom = this.getOptMaxZoom_(opt_maxZoom);
    this.addMarkerBatch_(marker, minZoom, maxZoom);
    var gridPoint = this.getTilePoint_(marker.getPosition(), this.mapZoom_, new google.maps.Size(0, 0, 0, 0));
    if (this.isGridPointVisible_(gridPoint) &&
      minZoom <= this.shownBounds_.z &&
      this.shownBounds_.z <= maxZoom) {
        this.addOverlay_(marker);
        this.notifyListeners_();
    }
    this.numMarkers_[minZoom]++;
};


/**
* Helper class to create a bounds of INT ranges.
* @param bounds Array.<Object.<string, number>> Bounds object.
* @constructor
*/
function GridBounds(bounds) {
    // [sw, ne]

    this.minX = Math.min(bounds[0].x, bounds[1].x);
    this.maxX = Math.max(bounds[0].x, bounds[1].x);
    this.minY = Math.min(bounds[0].y, bounds[1].y);
    this.maxY = Math.max(bounds[0].y, bounds[1].y);
}

/**
* Returns true if this bounds equal the given bounds.
* @param {GridBounds} gridBounds GridBounds The bounds to test.
* @return {Boolean} This Bounds equals the given GridBounds.
*/
GridBounds.prototype.equals = function (gridBounds) {
    if (this.maxX === gridBounds.maxX && this.maxY === gridBounds.maxY && this.minX === gridBounds.minX && this.minY === gridBounds.minY) {
        return true;
    } else {
        return false;
    }
};

/**
* Returns true if this bounds (inclusively) contains the given point.
* @param {Point} point  The point to test.
* @return {Boolean} This Bounds contains the given Point.
*/
GridBounds.prototype.containsPoint = function (point) {
    var outer = this;
    return (outer.minX <= point.x && outer.maxX >= point.x && outer.minY <= point.y && outer.maxY >= point.y);
};

/**
* Get a cell in the grid, creating it first if necessary.
*
* Optimization candidate
*
* @param {Number} x The x coordinate of the cell.
* @param {Number} y The y coordinate of the cell.
* @param {Number} z The z coordinate of the cell.
* @return {Array} The cell in the array.
*/
MarkerManager.prototype.getGridCellCreate_ = function (x, y, z) {
    var grid = this.grid_[z];
    if (x < 0) {
        x += this.gridWidth_[z];
    }
    var gridCol = grid[x];
    if (!gridCol) {
        gridCol = grid[x] = [];
        return (gridCol[y] = []);
    }
    var gridCell = gridCol[y];
    if (!gridCell) {
        return (gridCol[y] = []);
    }
    return gridCell;
};


/**
* Get a cell in the grid, returning undefined if it does not exist.
*
* NOTE: Optimized for speed -- otherwise could combine with getGridCellCreate_.
*
* @param {Number} x The x coordinate of the cell.
* @param {Number} y The y coordinate of the cell.
* @param {Number} z The z coordinate of the cell.
* @return {Array} The cell in the array.
*/
MarkerManager.prototype.getGridCellNoCreate_ = function (x, y, z) {
    var grid = this.grid_[z];

    if (x < 0) {
        x += this.gridWidth_[z];
    }
    var gridCol = grid[x];
    return gridCol ? gridCol[y] : undefined;
};


/**
* Turns at geographical bounds into a grid-space bounds.
*
* @param {LatLngBounds} bounds The geographical bounds.
* @param {Number} zoom The zoom level of the bounds.
* @param {google.maps.Size} swPadding The padding in pixels to extend beyond the
* given bounds.
* @param {google.maps.Size} nePadding The padding in pixels to extend beyond the
* given bounds.
* @return {GridBounds} The bounds in grid space.
*/
MarkerManager.prototype.getGridBounds_ = function (bounds, zoom, swPadding, nePadding) {
    zoom = Math.min(zoom, this.maxZoom_);

    var bl = bounds.getSouthWest();
    var tr = bounds.getNorthEast();
    var sw = this.getTilePoint_(bl, zoom, swPadding);

    var ne = this.getTilePoint_(tr, zoom, nePadding);
    var gw = this.gridWidth_[zoom];

    // Crossing the prime meridian requires correction of bounds.
    if (tr.lng() < bl.lng() || ne.x < sw.x) {
        sw.x -= gw;
    }
    if (ne.x - sw.x + 1 >= gw) {
        // Computed grid bounds are larger than the world; truncate.
        sw.x = 0;
        ne.x = gw - 1;
    }

    var gridBounds = new GridBounds([sw, ne]);
    gridBounds.z = zoom;

    return gridBounds;
};

/**
* Gets the grid-space bounds for the current map viewport.
*
* @return {Bounds} The bounds in grid space.
*/
MarkerManager.prototype.getMapGridBounds_ = function () {
    return this.getGridBounds_(this.map_.getBounds(), this.mapZoom_, this.swPadding_, this.nePadding_);
};

/**
* Event listener for map:movend.
* NOTE: Use a timeout so that the user is not blocked
* from moving the map.
*
* Removed this because a a lack of a scopy override/callback function on events. 
*/
MarkerManager.prototype.onMapMoveEnd_ = function () {
    this.objectSetTimeout_(this, this.updateMarkers_, 0);
};

/**
* Call a function or evaluate an expression after a specified number of
* milliseconds.
*
* Equivalent to the standard window.setTimeout function, but the given
* function executes as a method of this instance. So the function passed to
* objectSetTimeout can contain references to this.
*    objectSetTimeout(this, function () { alert(this.x) }, 1000);
*
* @param {Object} object  The target object.
* @param {Function} command  The command to run.
* @param {Number} milliseconds  The delay.
* @return {Boolean}  Success.
*/
MarkerManager.prototype.objectSetTimeout_ = function (object, command, milliseconds) {
    return window.setTimeout(function () {
        command.call(object);
    }, milliseconds);
};


/**
* Is this layer visible?
*
* Returns visibility setting
*
* @return {Boolean} Visible
*/
MarkerManager.prototype.visible = function () {
    return this.show_ ? true : false;
};


/**
* Returns true if the manager is hidden.
* Otherwise returns false.
* @return {Boolean} Hidden
*/
MarkerManager.prototype.isHidden = function () {
    return !this.show_;
};


/**
* Shows the manager if it's currently hidden.
*/
MarkerManager.prototype.show = function () {
    this.show_ = true;
    this.refresh();
};


/**
* Hides the manager if it's currently visible
*/
MarkerManager.prototype.hide = function () {
    this.show_ = false;
    this.refresh();
};


/**
* Toggles the visibility of the manager.
*/
MarkerManager.prototype.toggle = function () {
    this.show_ = !this.show_;
    this.refresh();
};

/**
* Refresh forces the marker-manager into a good state.
* <ol>
*   <li>If never before initialized, shows all the markers.</li>
*   <li>If previously initialized, removes and re-adds all markers.</li>
* </ol>
*/
MarkerManager.prototype.refresh = function () {
    if (this.shownMarkers_ > 0) {
        this.processAll_(this.shownBounds_, this.removeOverlay_);
    }
    // An extra check on this.show_ to increase performance (no need to processAll_)
    if (this.show_) {
        this.processAll_(this.shownBounds_, this.addOverlay_);
    }
    this.notifyListeners_();
};

/**
* After the viewport may have changed, add or remove markers as needed.
*/
MarkerManager.prototype.updateMarkers_ = function () {
    this.mapZoom_ = this.map_.getZoom();
    var newBounds = this.getMapGridBounds_();

    // If the move does not include new grid sections,
    // we have no work to do:
    if (newBounds.equals(this.shownBounds_) && newBounds.z === this.shownBounds_.z) {
        return;
    }

    if (newBounds.z !== this.shownBounds_.z) {
        this.processAll_(this.shownBounds_, this.removeOverlay_);
        if (this.show_) { // performance
            this.processAll_(newBounds, this.addOverlay_);
        }
    } else {
        // Remove markers:
        this.rectangleDiff_(this.shownBounds_, newBounds, this.removeCellMarkers_);

        // Add markers:
        if (this.show_) { // performance
            this.rectangleDiff_(newBounds, this.shownBounds_, this.addCellMarkers_);
        }
    }
    this.shownBounds_ = newBounds;

    this.notifyListeners_();
};

/**
* Notify listeners when the state of what is displayed changes.
*/
MarkerManager.prototype.notifyListeners_ = function () {
    google.maps.event.trigger(this, 'changed', this.shownBounds_, this.shownMarkers_);
};

/**
* Process all markers in the bounds provided, using a callback.
*
* @param {Bounds} bounds The bounds in grid space.
* @param {Function} callback The function to call for each marker.
*/
MarkerManager.prototype.processAll_ = function (bounds, callback) {
    for (var x = bounds.minX; x <= bounds.maxX; x++) {
        for (var y = bounds.minY; y <= bounds.maxY; y++) {
            this.processCellMarkers_(x, y, bounds.z, callback);
        }
    }
};

/**
* Process all markers in the grid cell, using a callback.
*
* @param {Number} x The x coordinate of the cell.
* @param {Number} y The y coordinate of the cell.
* @param {Number} z The z coordinate of the cell.
* @param {Function} callback The function to call for each marker.
*/
MarkerManager.prototype.processCellMarkers_ = function (x, y, z, callback) {
    var cell = this.getGridCellNoCreate_(x, y, z);
    if (cell) {
        for (var i = cell.length - 1; i >= 0; i--) {
            callback(cell[i]);
        }
    }
};

/**
* Remove all markers in a grid cell.
*
* @param {Number} x The x coordinate of the cell.
* @param {Number} y The y coordinate of the cell.
* @param {Number} z The z coordinate of the cell.
*/
MarkerManager.prototype.removeCellMarkers_ = function (x, y, z) {
    this.processCellMarkers_(x, y, z, this.removeOverlay_);
};

/**
* Add all markers in a grid cell.
*
* @param {Number} x The x coordinate of the cell.
* @param {Number} y The y coordinate of the cell.
* @param {Number} z The z coordinate of the cell.
*/
MarkerManager.prototype.addCellMarkers_ = function (x, y, z) {
    this.processCellMarkers_(x, y, z, this.addOverlay_);
};

/**
* Use the rectangleDiffCoords_ function to process all grid cells
* that are in bounds1 but not bounds2, using a callback, and using
* the current MarkerManager object as the instance.
*
* Pass the z parameter to the callback in addition to x and y.
*
* @param {Bounds} bounds1 The bounds of all points we may process.
* @param {Bounds} bounds2 The bounds of points to exclude.
* @param {Function} callback The callback function to call
*                   for each grid coordinate (x, y, z).
*/
MarkerManager.prototype.rectangleDiff_ = function (bounds1, bounds2, callback) {
    var me = this;
    me.rectangleDiffCoords_(bounds1, bounds2, function (x, y) {
        callback.apply(me, [x, y, bounds1.z]);
    });
};

/**
* Calls the function for all points in bounds1, not in bounds2
*
* @param {Bounds} bounds1 The bounds of all points we may process.
* @param {Bounds} bounds2 The bounds of points to exclude.
* @param {Function} callback The callback function to call
*                   for each grid coordinate.
*/
MarkerManager.prototype.rectangleDiffCoords_ = function (bounds1, bounds2, callback) {
    var minX1 = bounds1.minX;
    var minY1 = bounds1.minY;
    var maxX1 = bounds1.maxX;
    var maxY1 = bounds1.maxY;
    var minX2 = bounds2.minX;
    var minY2 = bounds2.minY;
    var maxX2 = bounds2.maxX;
    var maxY2 = bounds2.maxY;

    var x, y;
    for (x = minX1; x <= maxX1; x++) {  // All x in R1
        // All above:
        for (y = minY1; y <= maxY1 && y < minY2; y++) {  // y in R1 above R2
            callback(x, y);
        }
        // All below:
        for (y = Math.max(maxY2 + 1, minY1);  // y in R1 below R2
         y <= maxY1; y++) {
            callback(x, y);
        }
    }

    for (y = Math.max(minY1, minY2);
       y <= Math.min(maxY1, maxY2); y++) {  // All y in R2 and in R1
        // Strictly left:
        for (x = Math.min(maxX1 + 1, minX2) - 1;
         x >= minX1; x--) {  // x in R1 left of R2
            callback(x, y);
        }
        // Strictly right:
        for (x = Math.max(minX1, maxX2 + 1);  // x in R1 right of R2
         x <= maxX1; x++) {
            callback(x, y);
        }
    }
};

/**
* Removes value from array. O(N).
*
* @param {Array} array  The array to modify.
* @param {any} value  The value to remove.
* @param {Boolean} opt_notype  Flag to disable type checking in equality.
* @return {Number}  The number of instances of value that were removed.
*/
MarkerManager.prototype.removeFromArray_ = function (array, value, opt_notype) {
    var shift = 0;
    for (var i = 0; i < array.length; ++i) {
        if (array[i] === value || (opt_notype && array[i] === value)) {
            array.splice(i--, 1);
            shift++;
        }
    }
    return shift;
};

/**
*   Projection overlay helper. Helps in calculating
*   that markers get into the right grid.
*   @constructor
*   @param {Map} map The map to manage.
**/
function ProjectionHelperOverlay(map) {
    this.setMap(map);

    var TILEFACTOR = 8;
    var TILESIDE = 1 << TILEFACTOR;
    var RADIUS = 7;

    this._map = map;
    this._zoom = -1;
    this._X0 =
  this._Y0 =
  this._X1 =
  this._Y1 = -1;
}

ProjectionHelperOverlay.Init = function () {
    ProjectionHelperOverlay.prototype = new google.maps.OverlayView();
    /**
    *  Helper function to convert Lng to X
    *  @private
    *  @param {float} lng
    **/
    ProjectionHelperOverlay.prototype.LngToX_ = function (lng) {
        return (1 + lng / 180);
    };

    /**
    *  Helper function to convert Lat to Y
    *  @private
    *  @param {float} lat
    **/
    ProjectionHelperOverlay.prototype.LatToY_ = function (lat) {
        var sinofphi = Math.sin(lat * Math.PI / 180);
        return (1 - 0.5 / Math.PI * Math.log((1 + sinofphi) / (1 - sinofphi)));
    };

    /**
    *   Old school LatLngToPixel
    *   @param {LatLng} latlng google.maps.LatLng object
    *   @param {Number} zoom Zoom level
    *   @return {position} {x: pixelPositionX, y: pixelPositionY}
    **/
    ProjectionHelperOverlay.prototype.LatLngToPixel = function (latlng, zoom) {
        var map = this._map;
        var div = this.getProjection().fromLatLngToDivPixel(latlng);
        var abs = { x: ~ ~(0.5 + this.LngToX_(latlng.lng()) * (2 << (zoom + 6))), y: ~ ~(0.5 + this.LatToY_(latlng.lat()) * (2 << (zoom + 6))) };
        return abs;
    };

    /**
    * Draw function only triggers a ready event for
    * MarkerManager to know projection can proceed to
    * initialize.
    */
    ProjectionHelperOverlay.prototype.draw = function () {
        if (!this.ready) {
            this.ready = true;
            google.maps.event.trigger(this, 'ready');
        }
    };
};
// Create an overlay on the map from a projected image - Maps v3... 
// Author. John D. Coryat 05/2009 
// USNaviguide LLC - http://www.usnaviguide.com 
// Thanks go to Mile Williams EInsert: http://econym.googlepages.com/einsert.js, Google's GOverlay Example and Bratliff's suggestion... 
// Opacity code from TPhoto: http://gmaps.tommangan.us/addtphoto.html 
// This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA. 
// 
// Parameters: 
// map: This Map 
// imageUrl: URL of the image (Mandatory) 
// bounds: Bounds object of image destination (Mandatory) 
// Options: 
// addZoom: Added Zoom factor as a parameter to the imageUrl (include complete parameter, including separater like '?zoom=' 
// percentOpacity: Default 50, percent opacity to use when the image is loaded 0-100. 
// id: Default imageUrl, ID of the div 
// 

function ProjectedOverlay(map, imageUrl, bounds, opts) {
    google.maps.OverlayView.call(this);

    this.map_ = map;
    this.url_ = imageUrl;
    this.bounds_ = bounds;
    this.addZ_ = opts.addZoom || ''; // Add the zoom to the image as a parameter 
    this.id_ = opts.id || this.url_; // Added to allow for multiple images 
    this.percentOpacity_ = opts.percentOpacity || 50;

    this.setMap(map);
}

ProjectedOverlay.Init = function () {
    ProjectedOverlay.prototype = new google.maps.OverlayView();

    ProjectedOverlay.prototype.createElement = function () {
        var panes = this.getPanes();
        var div = this.div_;

        if (!div) {
            div = this.div_ = document.createElement("div");
            div.style.position = "absolute";
            div.setAttribute('id', this.id_);
            this.div_ = div;
            this.lastZoom_ = -1;
            if (this.percentOpacity_) {
                this.setOpacity(this.percentOpacity_);
            }
            panes.overlayLayer.appendChild(div);
        }
    }

    // Remove the main DIV from the map pane 

    ProjectedOverlay.prototype.remove = function () {
        if (this.div_) {
            this.div_.parentNode.removeChild(this.div_);
            this.div_ = null;
        }
    }

    // Redraw based on the current projection and zoom level... 

    ProjectedOverlay.prototype.draw = function (firstTime) {
        // Creates the element if it doesn't exist already. 

        this.createElement();

        if (!this.div_) {
            return;
        }

        var c1 = this.get('projection').fromLatLngToDivPixel(this.bounds_.getSouthWest());
        var c2 = this.get('projection').fromLatLngToDivPixel(this.bounds_.getNorthEast());

        if (!c1 || !c2) return;

        // Now position our DIV based on the DIV coordinates of our bounds 

        this.div_.style.width = Math.abs(c2.x - c1.x) + "px";
        this.div_.style.height = Math.abs(c2.y - c1.y) + "px";
        this.div_.style.left = Math.min(c2.x, c1.x) + "px";
        this.div_.style.top = Math.min(c2.y, c1.y) + "px";

        // Do the rest only if the zoom has changed... 

        if (this.lastZoom_ == this.map_.getZoom()) {
            return;
        }

        this.lastZoom_ = this.map_.getZoom();

        var url = this.url_;

        if (this.addZ_) {
            url += this.addZ_ + this.map_.getZoom();
        }

        this.div_.innerHTML = '<img src="' + url + '" width=' + this.div_.style.width + ' height=' + this.div_.style.height + ' >';
    }

    ProjectedOverlay.prototype.setOpacity = function (opacity) {
        if (opacity < 0) {
            opacity = 0;
        }
        if (opacity > 100) {
            opacity = 100;
        }
        var c = opacity / 100;

        if (typeof (this.div_.style.filter) == 'string') {
            this.div_.style.filter = 'alpha(opacity:' + opacity + ')';
        }
        if (typeof (this.div_.style.KHTMLOpacity) == 'string') {
            this.div_.style.KHTMLOpacity = c;
        }
        if (typeof (this.div_.style.MozOpacity) == 'string') {
            this.div_.style.MozOpacity = c;
        }
        if (typeof (this.div_.style.opacity) == 'string') {
            this.div_.style.opacity = c;
        }
    }
};
/* 
geoXML3.js 
 
Renders KML on the Google Maps JavaScript API Version 3  
http://code.google.com/p/geoxml3/ 
 
Copyright 2009 Sterling Udell 
 
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 
You may obtain a copy of the License at 
 
http://www.apache.org/licenses/LICENSE-2.0 
 
Unless required by applicable law or agreed to in writing, software 
distributed under the License is distributed on an "AS IS" BASIS, 
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
See the License for the specific language governing permissions and 
limitations under the License. 
 
*/

// Extend the global String with a method to remove leading and trailing whitespace 
if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\s+|\s+$/g, '');
    };
}

// Declare namespace 
geoXML3 = window.geoXML3 || {};

// Constructor for the root KML parser object 
geoXML3.parser = function (options) {
    // Private variables 
    var parserOptions = geoXML3.combineOptions(options, {
        singleInfoWindow: false,
        processStyles: true,
        zoom: true
    });
    var docs = []; // Individual KML documents 
    var lastMarker;

    // Private methods 

    var parse = function (urls) {
        // Process one or more KML documents 

        if (typeof urls === 'string') {
            // Single KML document 
            urls = [urls];
        }

        // Internal values for the set of documents as a whole 
        var internals = {
            docSet: [],
            remaining: urls.length,
            parserOnly: !parserOptions.afterParse
        };

        var thisDoc;
        for (var i = 0; i < urls.length; i++) {
            thisDoc = {
                url: urls[i],
                internals: internals
            };
            internals.docSet.push(thisDoc);
            geoXML3.fetchXML(thisDoc.url, function (responseXML) { render(responseXML, thisDoc); });
        }
    };

    var hideDocument = function (doc) {
        // Hide the map objects associated with a document  
        var i;
        for (i = 0; i < doc.markers.length; i++) {
            this.markers[i].set_visible(false);
        }
        for (i = 0; i < doc.overlays.length; i++) {
            doc.overlays[i].setOpacity(0);
        }
    };

    var showDocument = function (doc) {
        // Show the map objects associated with a document  
        var i;
        for (i = 0; i < doc.markers.length; i++) {
            doc.markers[i].set_visible(true);
        }
        for (i = 0; i < doc.overlays.length; i++) {
            doc.overlays[i].setOpacity(doc.overlays[i].percentOpacity_);
        }
    };

    var render = function (responseXML, doc) {
        // Callback for retrieving a KML document: parse the KML and display it on the map 

        if (!responseXML) {
            // Error retrieving the data 
            geoXML3.log('Unable to retrieve ' + doc.url);
            if (parserOptions.failedParse) {
                parserOptions.failedParse(doc);
            }
        } else if (!doc) {
            throw 'geoXML3 internal error: render called with null document';
        } else {
            doc.styles = {};
            doc.placemarks = [];
            doc.groundOverlays = [];
            if (parserOptions.zoom && !!parserOptions.map)
                doc.bounds = new google.maps.LatLngBounds();

            // Parse styles 
            var styleID, iconNodes, i;
            var styleNodes = responseXML.getElementsByTagName('Style');
            for (i = 0; i < styleNodes.length; i++) {
                styleID = styleNodes[i].getAttribute('id');
                iconNodes = styleNodes[i].getElementsByTagName('Icon');
                if (!!iconNodes.length) {
                    doc.styles['#' + styleID] = {
                        href: geoXML3.nodeValue(iconNodes[0].getElementsByTagName('href')[0])
                    };
                }
            }
            if (!!parserOptions.processStyles || !parserOptions.createMarker) {
                // Convert parsed styles into GMaps equivalents 
                processStyles(doc);
            }

            // Parse placemarks 
            var placemark, node, coords, path;
            var placemarkNodes = responseXML.getElementsByTagName('Placemark');
            for (i = 0; i < placemarkNodes.length; i++) {
                // Init the placemark object 
                node = placemarkNodes[i];
                placemark = {
                    name: geoXML3.nodeValue(node.getElementsByTagName('name')[0]),
                    description: geoXML3.nodeValue(node.getElementsByTagName('description')[0]),
                    styleUrl: geoXML3.nodeValue(node.getElementsByTagName('styleUrl')[0])
                };
                placemark.style = doc.styles[placemark.styleUrl] || {};
                if (/^https?:\/\//.test(placemark.description)) {
                    placemark.description = '<a href="' + placemark.description + '">' + placemark.description + '</a>';
                }

                // Extract the coordinates 
                coords = geoXML3.nodeValue(node.getElementsByTagName('coordinates')[0]).trim();
                coords = coords.replace(/\s+/g, ' ').replace(/, /g, ',');
                path = coords.split(' ');

                // What sort of placemark? 
                if (path.length === 1) {
                    // Polygons/lines not supported in v3, so only plot markers 
                    coords = path[0].split(',');
                    placemark.point = {
                        lat: parseFloat(coords[1]),
                        lng: parseFloat(coords[0]),
                        alt: parseFloat(coords[2])
                    };
                    if (!!doc.bounds) {
                        doc.bounds.extend(new google.maps.LatLng(placemark.point.lat, placemark.point.lng));
                    }

                    // Call the appropriate function to create the marker 
                    if (!!parserOptions.createMarker) {
                        parserOptions.createMarker(placemark, doc);
                    } else {
                        createMarker(placemark, doc);
                    }
                }
            }

            // Parse ground overlays 
            var groundOverlay, color, transparency;
            var groundNodes = responseXML.getElementsByTagName('GroundOverlay');
            for (i = 0; i < groundNodes.length; i++) {
                node = groundNodes[i];

                // Init the ground overlay object 
                groundOverlay = {
                    name: geoXML3.nodeValue(node.getElementsByTagName('name')[0]),
                    description: geoXML3.nodeValue(node.getElementsByTagName('description')[0]),
                    icon: { href: geoXML3.nodeValue(node.getElementsByTagName('href')[0]) },
                    latLonBox: {
                        north: parseFloat(geoXML3.nodeValue(node.getElementsByTagName('north')[0])),
                        east: parseFloat(geoXML3.nodeValue(node.getElementsByTagName('east')[0])),
                        south: parseFloat(geoXML3.nodeValue(node.getElementsByTagName('south')[0])),
                        west: parseFloat(geoXML3.nodeValue(node.getElementsByTagName('west')[0]))
                    }
                };
                if (!!doc.bounds) {
                    doc.bounds.union(new google.maps.LatLngBounds(
            new google.maps.LatLng(groundOverlay.latLonBox.south, groundOverlay.latLonBox.west),
            new google.maps.LatLng(groundOverlay.latLonBox.north, groundOverlay.latLonBox.east)
          ));
                }

                // Opacity is encoded in the color node 
                color = geoXML3.nodeValue(node.getElementsByTagName('color')[0]);
                if ((color !== '') && (color.length == 8)) {
                    transparency = parseInt(color.substring(0, 2), 16);
                    groundOverlay.opacity = Math.round((255 - transparency) / 2.55);
                } else {
                    groundOverlay.opacity = 100;
                }

                // Call the appropriate function to create the overlay 
                if (!!parserOptions.createOverlay) {
                    parserOptions.createOverlay(groundOverlay, doc);
                } else {
                    createOverlay(groundOverlay, doc);
                }
            }

            if (!!doc.bounds) {
                doc.internals.bounds = doc.internals.bounds || new google.maps.LatLngBounds();
                doc.internals.bounds.union(doc.bounds);
            }
            if (!!doc.styles || !!doc.markers || !!doc.overlays) {
                doc.internals.parserOnly = false;
            }

            doc.internals.remaining -= 1;
            if (doc.internals.remaining === 0) {
                // We're done processing this set of KML documents 

                // Options that get invoked after parsing completes 
                if (!!doc.internals.bounds) {
                    parserOptions.map.fitBounds(doc.internals.bounds);
                }
                if (parserOptions.afterParse) {
                    parserOptions.afterParse(doc.internals.docSet);
                }

                if (!doc.internals.parserOnly) {
                    // geoXML3 is not being used only as a real-time parser, so keep the parsed documents around 
                    docs.concat(doc.internals.docSet);
                }
            }
        }
    };

    var processStyles = function (doc) {
        var stdRegEx = /\/(red|blue|green|yellow|lightblue|purple|pink|orange)(-dot)?\.png/;
        for (var styleID in doc.styles) {
            if (!!doc.styles[styleID].href) {
                // Init the style object with a standard KML icon 
                doc.styles[styleID].icon = new google.maps.MarkerImage(
                  doc.styles[styleID].href,
                  new google.maps.Size(32, 32),
                  new google.maps.Point(0, 0),
                  new google.maps.Point(16, 12)
                );
                // Look for a predictable shadow 
                if (stdRegEx.test(doc.styles[styleID].href)) {
                    // A standard GMap-style marker icon 
                    doc.styles[styleID].shadow = new google.maps.MarkerImage(
              'http://maps.google.com/mapfiles/ms/micons/msmarker.shadow.png',
              new google.maps.Size(59, 32),
              new google.maps.Point(0, 0),
              new google.maps.Point(16, 12));
                } else if (doc.styles[styleID].href.indexOf('-pushpin.png') > -1) {
                    // Pushpin marker icon 
                    doc.styles[styleID].shadow = new google.maps.MarkerImage(
            'http://maps.google.com/mapfiles/ms/micons/pushpin_shadow.png',
            new google.maps.Size(59, 32),
            new google.maps.Point(0, 0),
            new google.maps.Point(16, 12));
                } else {
                    // Other MyMaps KML standard icon 
                    doc.styles[styleID].shadow = new google.maps.MarkerImage(
            doc.styles[styleID].href.replace('.png', '.shadow.png'),
            new google.maps.Size(59, 32),
            new google.maps.Point(0, 0),
            new google.maps.Point(16, 12));
                }
            }
        }
    };

    var createMarker = function (placemark, doc) {
        // create a Marker to the map from a placemark KML object 

        // Load basic marker properties 
        var markerOptions = geoXML3.combineOptions(parserOptions.markerOptions, {
            map: parserOptions.map,
            position: new google.maps.LatLng(placemark.point.lat, placemark.point.lng),
            title: placemark.name,
            zIndex: Math.round(-placemark.point.lat * 100000),
            icon: placemark.style.icon,
            shadow: placemark.style.shadow
        });

        // Create the marker on the map 
        var marker = new google.maps.Marker(markerOptions);

        // Set up and create the infowindow 
        var infoWindowOptions = geoXML3.combineOptions(parserOptions.infoWindowOptions, {
            content: '<div class="infowindow"><h3>' + placemark.name +
               '</h3><div>' + placemark.description + '</div></div>',
            pixelOffset: new google.maps.Size(0, 2)
        });
        marker.infoWindow = new google.maps.InfoWindow(infoWindowOptions);

        // Infowindow-opening event handler 
        google.maps.event.addListener(marker, 'click', function () {
            if (!!parserOptions.singleInfoWindow) {
                if (!!lastMarker && !!lastMarker.infoWindow) {
                    lastMarker.infoWindow.close();
                }
                lastMarker = this;
            }
            this.infoWindow.open(this.map, this);
        });

        if (!!doc) {
            doc.markers = doc.markers || [];
            doc.markers.push(marker);
        }

        return marker;
    };

    var createOverlay = function (groundOverlay, doc) {
        // Add a ProjectedOverlay to the map from a groundOverlay KML object 

        if (!window.ProjectedOverlay) {
            throw 'geoXML3 error: ProjectedOverlay not found while rendering GroundOverlay from KML';
        }

        var bounds = new google.maps.LatLngBounds(
        new google.maps.LatLng(groundOverlay.latLonBox.south, groundOverlay.latLonBox.west),
        new google.maps.LatLng(groundOverlay.latLonBox.north, groundOverlay.latLonBox.east)
    );
        var overlayOptions = geoXML3.combineOptions(parserOptions.overlayOptions, { percentOpacity: groundOverlay.opacity });
        var overlay = new ProjectedOverlay(parserOptions.map, groundOverlay.icon.href, bounds, overlayOptions);

        if (!!doc) {
            doc.overlays = doc.overlays || [];
            doc.overlays.push(overlay);
        }

        return
    };

    return {
        // Expose some properties and methods 

        options: parserOptions,
        docs: docs,

        parse: parse,
        hideDocument: hideDocument,
        showDocument: showDocument,
        processStyles: processStyles,
        createMarker: createMarker,
        createOverlay: createOverlay
    };
};
// End of KML Parser 

// Helper objects and functions 

// Log a message to the debugging console, if one exists 
geoXML3.log = function (msg) {
    if (!!window.console) {
        console.log(msg);
    }
};

// Combine two options objects, a set of default values and a set of override values  
geoXML3.combineOptions = function (overrides, defaults) {
    var result = {};
    if (!!overrides) {
        for (var prop in overrides) {
            if (overrides.hasOwnProperty(prop)) {
                result[prop] = overrides[prop];
            }
        }
    }
    if (!!defaults) {
        for (prop in defaults) {
            if (defaults.hasOwnProperty(prop) && (result[prop] === undefined)) {
                result[prop] = defaults[prop];
            }
        }
    }
    return result;
};

// Retrieve a text document from url and pass it to callback as a string 
geoXML3.fetchers = [];
geoXML3.fetchXML = function (url, callback) {
    function timeoutHandler() {
        callback();
    };

    var xhrFetcher;
    if (!!geoXML3.fetchers.length) {
        xhrFetcher = geoXML3.fetchers.pop();
    } else {
        if (!!window.XMLHttpRequest) {
            xhrFetcher = new window.XMLHttpRequest(); // Most browsers 
        } else if (!!window.ActiveXObject) {
            xhrFetcher = new window.ActiveXObject('Microsoft.XMLHTTP'); // Some IE 
        }
    }

    if (!xhrFetcher) {
        geoXML3.log('Unable to create XHR object');
        callback(null);
    } else {
        xhrFetcher.open('GET', url, true);
        xhrFetcher.onreadystatechange = function () {
            if (xhrFetcher.readyState === 4) {
                // Retrieval complete 
                if (!!xhrFetcher.timeout)
                    clearTimeout(xhrFetcher.timeout);
                if (xhrFetcher.status >= 400) {
                    geoXML3.log('HTTP error ' + xhrFetcher.status + ' retrieving ' + url);
                    callback();
                } else {
                    // Returned successfully 
                    callback(xhrFetcher.responseXML);
                }
                // We're done with this fetcher object 
                geoXML3.fetchers.push(xhrFetcher);
            }
        };
        xhrFetcher.timeout = setTimeout(timeoutHandler, 60000);
        xhrFetcher.send(null);
    }
};

//nodeValue: Extract the text value of a DOM node, with leading and trailing whitespace trimmed 
geoXML3.nodeValue = function (node) {
    if (!node) {
        return '';
    } else {
        return (node.innerText || node.text || node.textContent).trim();
    }
}; 
