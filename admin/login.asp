<%@LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>我爱坐班车 后台管理</title>
<link rel="stylesheet" type="text/css" href="../style/basic.css" />
<link rel="stylesheet" type="text/css" href="../style/admin.css" />
<!--[if lte IE 8]><link rel="stylesheet" type="text/css" href="../style/ie.css" /><![endif]-->
</head>
<body>
<div id="header">
  <div class="top">
    <h1>我爱坐班车 后台管理</h1>
    <p><a href="/">返回首页</a></p>
  </div>
</div>
<form id="login" class="login" method="post" action="action/login.asp">
  <fieldset>
    <legend>后台登录</legend>
    <p>
      <label for="loginName">昵称：</label>
      <input id="loginName" name="loginName" value="<%=(Request.Cookies("loginName"))%>" />
    </p>
    <p>
      <label for="loginPassword">密码：</label>
      <input id="loginPassword" name="loginPassword" type="password" value="<%=(Request.Cookies("loginPassword"))%>" />
    </p>
    <p>
      <button>提交</button>
    </p>
  </fieldset>
</form>
</body>
</html>
