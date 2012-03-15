//author: benjaminli
//email:  benjaminli@tencent.com

BusLine.prototype.GetKMLDoc = function () {
    var me = this;
    var xmlDoc = new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async = "false";
    xmlDoc.loadXML(['<?xml version="1.0"?>',
        '<kml xmlns="http://earth.google.com/kml/2.2"><Document>',
        '<name>', me._name, '</name>',
        '</Document></kml>'].join(''));
    var xmlRoot = xmlDoc.getElementsByTagName('Document')[0];
    gBusLineRenderer.AppendKMLPlacemark(xmlDoc, xmlRoot);
    //在用户端弹出保存文件对话框，保存到硬盘
    tempWindow = window.open();
    tempWindow.document.open('application/vnd.google-earth.kml+xml', 'replace');
    tempWindow.document.write(xmlDoc.xml);
    tempWindow.document.close();
    tempWindow.document.execCommand('saveas');
    tempWindow.window.close();
};

BusStation.prototype.GetConfirmMarker = function () {
    var me = this;
    if (!me._confirmMarker) {
        me._confirmMarker = new google.maps.Marker({
            title: me._name,
            position: new google.maps.LatLng(me._lat, me._lng),
            icon: BusStation.ICON_CONFIRM,
            clickable: true
        });
        google.maps.event.addListener(me._confirmMarker, 'click', function () {
            me._confirmMarker.setAnimation(null);
            me.ShowConfirmWindow();
        });
    }
    me._confirmMarker.setAnimation(google.maps.Animation.BOUNCE);
    window.setTimeout(function () {
        me._confirmMarker.setAnimation(null);
    }, 3000);
    return me._confirmMarker;
};
BusStation.prototype.ShowConfirmWindow = function () {
    var me = this;
    CloseInfoWindow();
    if (!me._busList) {
        me._busList = ['<h3>', me._name, '</h3>',
                    '<div class="loading">正在查询相关班车...</div>'].join('');
        $.post('/action/Query.asp', {
            'id_cmd': escape(2),
            'stn_id': escape(me._id)
        }, function (data) {
            data = data || '';
            var arr_Bus = BusLineCollection.ParseAttrString(data);
            me._busList = document.createElement('div');
            me._busList.style.overflow = 'auto';
            me._busList.innerHTML = ['<h3>', me._name, '</h3>',
                        '<div>箭头所指的是原先位置<br />',
                        '此修改将影响以下线路：</div>'].join('');
            if (arr_Bus.length > 0) {
                for (var i = 0; i < arr_Bus.length; i++) {
                    me._busList.appendChild(arr_Bus[i].GetHtmlNodeSimple(true));
                }
            }
            else {
                me._busList.innerHTML += '没有停靠此站点的班车。<br />这种事情不可能发生啊，有BUG……';
            }
            var divSubmit = document.createElement('div');
            me._busList.appendChild(divSubmit);
            divSubmit.innerHTML = '审阅完毕后，您可以：<br />'
            var button = document.createElement('button');
            divSubmit.appendChild(button);
            button.setAttribute('type', 'submit');
            button.innerHTML = '保存到数据库';
            $(button).click(function () {
                $.post('./action/CmdStation.asp', {
                    'id_cmd': escape(1),
                    'stn_id': escape(me._id),
                    'stn_lat': escape(me.NewLatLng.lat()),
                    'stn_lng': escape(me.NewLatLng.lng())
                }, function (data) {
                    if (isNaN(data)) {
                        alert(['出现了异常\n',
                                    '点击"确认"后为您跳转到登录页面\n',
                                    '服务器返回信息:\n', data].join(''));
                        window.location.href = './login.asp';
                    }
                    else {
                        var count = parseInt(data);
                        if (count > 0) {
                            alert(['保存成功\n', count, '行数据库记录已被更新'].join(''));
                            me._lat = me.NewLatLng.lat();
                            me._lng = me.NewLatLng.lng();
                            delete me.NewLatLng;
                            $(me).trigger('position_saved');
                        }
                        else {
                            alert(['保存失败\n', count, '行数据库记录已被更新'].join(''));
                        }
                    }
                });
            });

            me.ShowConfirmWindow();
        });
    }
    gInfoWindow.setContent(me._busList);
    gInfoWindow.open(BusStation.MAP, me._confirmMarker);
};


BusLineRenderer.prototype.LinkPagePrev = function (thisPageIndex) {
    var me = this;
    var thisPage = me._pages[thisPageIndex];
    if (thisPage._linked) {
        return;
    }
    var myMarkers = thisPage.GetMarkerDrawer().markers;
    if (myMarkers) {
        //让前一页的F跟着这一页的A一起移动
        var lastPageIndex = thisPageIndex - 1;
        var lastPage = me._pages[lastPageIndex];
        if (lastPage) {
            var lastMarkers = lastPage.GetMarkerDrawer().markers;
            var lastMarkerIndex = lastMarkers.length - 1;
            google.maps.event.addListener(thisPage.GetMarkerDragMgr(), 'dragstart', function (destIndex) {
                if (0 == destIndex) {
                    google.maps.event.trigger(lastPage.GetMarkerDragMgr(), 'dragstart', lastMarkerIndex);
                }
            });
            google.maps.event.addListener(thisPage.GetMarkerDragMgr(), 'drag', function (latLngNew) {
                google.maps.event.trigger(lastPage.GetMarkerDragMgr(), 'drag', latLngNew);
            });
            google.maps.event.addListener(thisPage.GetMarkerDragMgr(), 'dragend', function (latLngNew) {
                google.maps.event.trigger(lastPage.GetMarkerDragMgr(), 'dragend', latLngNew);
            });
        }
        thisPage._linked = true;
    }
};
BusLineRenderer.prototype.GetChangedStops = function () {
    var me = this;
    var _retList = new Array();
    var pageIndex, legIndex;
    var stopIndex = 0;
    var tempLeg, tempLatLng, tempStop, distance;
    for (pageIndex = 0; pageIndex < me._pages.length; pageIndex++) {
        var pLegs = me._pages[pageIndex].GetAllRouteLegs();
        for (legIndex = 0; legIndex < pLegs.length; legIndex++) {
            tempLeg = pLegs[legIndex];
            tempLatLng = tempLeg.start_location;
            tempStop = me._stops[stopIndex];
            stopIndex++;
            distance = GetDistance(tempLatLng.lat(), tempLatLng.lng(), tempStop.lat(), tempStop.lng());
            if (distance > 100) {
                //如果站点被调整了100米以上，则认为Changed
                tempStop.NewLatLng = tempLatLng;
                _retList.push(tempStop);
            }
        }
    }
    //循环结束以后的tempLeg必然是终点
    tempLatLng = tempLeg.end_location;
    tempStop = me._stops[stopIndex];
    distance = GetDistance(tempLatLng.lat(), tempLatLng.lng(), tempStop.lat(), tempStop.lng());
    if (distance > 100) {
        //如果站点被调整了100米以上，则认为Changed
        tempStop.NewLatLng = tempLatLng;
        _retList.push(tempStop);
    }
    return _retList;
};
BusLineRenderer.prototype.ShowChangedStops = function () {
    var me = this;
    var StopList = me.GetChangedStops();
    //开始绘制Confirm节点
    gMarkerMgr.clearMarkers();
    var bounds = new google.maps.LatLngBounds();
    for (var i = 0; i < StopList.length; i++) {
        var tempBusStation = StopList[i];
        $(tempBusStation).bind('position_saved', function (event) {
            me.ShowChangedStops();
            $(event.target).unbind('position_saved');
        });
        bounds.extend(tempBusStation.GetLatLng())
        var tempMarker = tempBusStation.GetConfirmMarker();
        gMarkerMgr.addMarker(tempMarker, 0);
    }
    if (StopList.length > 0) {
        me._map.fitBounds(bounds);
        if (me._map.getZoom() > 14) {
            me._map.setZoom(14);
        }
    }
    else {
        alert("现在所有的车站没有大的修改，建议导出为KML文件保存");
    }
};
BusLineRenderer.NameSpaceURI = 'http://earth.google.com/kml/2.2';
BusLineRenderer.prototype.AppendKMLPlacemark = function (xmlDoc, xmlRoot) {
    var me = this;
    var pageIndex, legIndex;
    //第一遍循环集中输出Markers
    for (pageIndex = 0; pageIndex < me._pages.length; pageIndex++) {
        var pLegs = me._pages[pageIndex].GetAllRouteLegs();
        for (legIndex = 0; legIndex < pLegs.length; legIndex++) {
            var tempLeg = pLegs[legIndex];
            me._appendKMLMarkerOnce(xmlDoc, xmlRoot, tempLeg.start_address, tempLeg.start_location);
        }
    }
    //循环结束以后的tempLeg必然是终点
    me._appendKMLMarkerOnce(xmlDoc, xmlRoot, tempLeg.end_address, tempLeg.end_location);
    //第二遍循环集中输出Route
    var strCoordinates = '';
    for (pageIndex = 0; pageIndex < me._pages.length; pageIndex++) {
        strCoordinates += me._pages[pageIndex].GetCoordinates();
    }
    var Placemark = this._appendKMLTagPlaceMark(xmlDoc, xmlRoot);
    //开始处理name节点
    var name = xmlDoc.createNode(1, 'name', BusLineRenderer.NameSpaceURI);
    Placemark.appendChild(name);
    var textName = xmlDoc.createTextNode('班车行驶路线');
    name.appendChild(textName);
    //开始处理LineString节点
    var LineString = xmlDoc.createNode(1, 'LineString', BusLineRenderer.NameSpaceURI);
    Placemark.appendChild(LineString);
    var coordinates = xmlDoc.createNode(1, 'coordinates', BusLineRenderer.NameSpaceURI);
    LineString.appendChild(coordinates);
    var textCoordinates = xmlDoc.createTextNode(strCoordinates);
    coordinates.appendChild(textCoordinates);
};
BusLineRenderer.prototype._appendKMLMarkerOnce = function (xmlDoc, xmlRoot, mName, mLatLng) {
    var Placemark = this._appendKMLTagPlaceMark(xmlDoc, xmlRoot);
    //开始处理name节点
    var name = xmlDoc.createNode(1, 'name', BusLineRenderer.NameSpaceURI);
    Placemark.appendChild(name);
    var textName = xmlDoc.createTextNode(mName);
    name.appendChild(textName);
    //开始处理Point节点
    var Point = xmlDoc.createNode(1, 'Point', BusLineRenderer.NameSpaceURI);
    Placemark.appendChild(Point);
    var coordinates = xmlDoc.createNode(1, 'coordinates', BusLineRenderer.NameSpaceURI);
    Point.appendChild(coordinates);
    var textCoordinates = xmlDoc.createTextNode([mLatLng.lng(), ',', mLatLng.lat(), ',0.000000'].join(''));
    coordinates.appendChild(textCoordinates);
};
BusLineRenderer.prototype._appendKMLTagPlaceMark = function (xmlDoc, xmlRoot) {
    xmlRoot.appendChild(xmlDoc.createTextNode('\n'));
    var Placemark = xmlDoc.createNode(1, 'Placemark', BusLineRenderer.NameSpaceURI);
    xmlRoot.appendChild(Placemark);
    return Placemark;
};
BusLineWaypointPager.prototype.GetMarkerDragMgr = function () {
    var me = this;
    if (!me._markersDragMgr) {
        var _members = FindMembersHasProperty(me._directionsRenderer, 'routeIndex');
        for (var i = 0; i < _members.length; i++) {
            var tempObj = _members[i];
            var _list = FindMembersHasProperty(tempObj, 'dragstart');
            if (_list.length > 0) {
                me._markersDragMgr = tempObj;
                break;
            }
        }
    }
    return me._markersDragMgr;
};
BusLineWaypointPager.prototype.GetCoordinates = function () {
    var strCoordinates = '';
    var path = this._directionsRenderer.getDirections().routes[0].overview_path;
    for (var i = 1; i < path.length; i++) {
        var tempLatLng = path[i];
        strCoordinates += ['\n', tempLatLng.lng(), ',', tempLatLng.lat(), ',0.000000'].join('');
    }
    return strCoordinates;
};
