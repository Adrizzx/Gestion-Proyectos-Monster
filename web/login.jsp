<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String valor) {
        if (valor == null) {
            return "";
        }
        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    if (usuarioSesion != null) {
        response.sendRedirect(request.getContextPath() + SeguridadWeb.rutaDashboard(usuarioSesion));
        return;
    }
    String error = (String) request.getAttribute("error");
    String mensaje = request.getParameter("mensaje");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Inicio de sesi&oacute;n - Gesti&oacute;n de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    </head>
    <body class="login-body">
        <main class="login-shell">
            <section class="login-panel">
                <div class="brand-block">
                    <div class="login-logo-frame">
                        <img class="login-logo" src="<%= ctx %>/resources/LOGO%20EMPRESA/monster.png" alt="Logo Monster">
                    </div>
                    <div>
                        <h1>Gesti&oacute;n de Proyectos Monster</h1>
                        <p>Subsistema de seguridad</p>
                    </div>
                </div>

                <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <form action="<%= ctx %>/srvSeguridad" method="post" class="stack-form" accept-charset="UTF-8">
                    <label for="usuario">Usuario</label>
                    <input id="usuario" name="usuario" type="text" maxlength="6" placeholder="EMP001" required autofocus autocomplete="username">

                    <label for="clave">Contrase&ntilde;a</label>
                    <input id="clave" name="clave" type="password" required autocomplete="current-password">

                    <button type="submit" class="btn primary">Ingresar</button>
                </form>
            </section>
        </main>
    </body>
</html>
