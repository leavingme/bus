// JavaScript Document

//显示隐藏元素
function show(objectid){
   var objdiv = document.getElementById(objectid);
   objdiv.style.display = "block";
}
function hide(objectid){
	var objdiv = document.getElementById(objectid);
	objdiv.style.display = "none";
}

//SOSOMAP
lngFrom4326ToProjection = function (a) {
    return a * 111319.49077777778
};
latFrom4326ToProjection = function (a) {
    a = Math.log(Math.tan((90 + a) * 0.008726646259971648)) / 0.017453292519943295;
    a *= 111319.49077777778;
    return a
};
lngFromProjectionTo4326 = function (a) {
    return a / 111319.49077777778
};
latFromProjectionTo4326 = function (a) {
    a = a / 111319.49077777778;
    return a = Math.atan(Math.exp(a * 0.017453292519943295)) * 114.59155902616465 - 90
};

function streetViewLoader(x, y) {
    var el = document.createElement('script'); el.type = 'text/javascript'; el.async = true;
    el.src = 'http://sv.map.soso.com/xf?x=' + x + '&y=' + y + '&r=500&output=jsonp&cb=streetXF';
    var s = document.getElementsByTagName('head')[0]; s.parentNode.insertBefore(el, s);
}

function streetXF(data) {
	if (data.info && data.info.errno === 0) {
		var svid = data.detail.svid;
		var url = 'http://map.soso.com/?pano=' + svid + '&heading=280&zoom=1&pitch=0';
		console.log(url);
		streetView(url);
	}
}

function streetView(url) {
	var iframe = document.getElementById('sosomap_iframe');
	if (iframe) {
		iframe.src = url;
	}
	var a = document.getElementById('sosomap_form_text');
	if (a) {
		a.href = url;
	}
}
