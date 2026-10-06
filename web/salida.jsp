<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    if (usuarioSesion == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    response.sendRedirect(request.getContextPath() + SeguridadWeb.rutaDashboard(usuarioSesion));
%>
