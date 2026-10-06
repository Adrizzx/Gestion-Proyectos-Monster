<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (!SeguridadWeb.requiereSesion(request, response)) {
        return;
    }
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Acceso bloqueado - Gesti&oacute;n de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Acceso restringido</p>
                    <h1>M&oacute;dulo no autorizado</h1>
                    <p>Tu rol actual no tiene permisos para abrir esta secci&oacute;n.</p>
                </section>
                <a class="btn primary" href="<%= ctx + SeguridadWeb.rutaDashboard(usuarioSesion) %>">Volver al inicio</a>
            </main>
        </div>
    </body>
</html>
