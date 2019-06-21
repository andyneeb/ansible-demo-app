<%@ page import="java.util.*"%>
<%
    java.io.InputStream in = getServletContext().getResourceAsStream("META-INF/maven/com.aneeb/demoapp/pom.properties");
    Properties mProps = new Properties();
    mProps.load(in);
    String mainVer = (String) mProps.get("version");
%>
<html>
<body>
<h2>Hallo Welt!</h2>
<h6>App Version: <%= mainVer %></h6>
<!-- <img src="munich.jpg" alt="Image of Munich" width=100% ></img> -->
<img src="logo.png" alt="Ansible Logo" height=60% ></img>
</body>
</html>
