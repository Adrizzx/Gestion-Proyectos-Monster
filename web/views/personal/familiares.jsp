<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_RRHH)) return;
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestionar Familiares</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Recursos Humanos</p>
            <h1>Gestionar Familiares</h1>
            <p>Registro de nombre, parentesco y datos de contacto para beneficios y seguros m&eacute;dicos.</p>
        </section>

        <div class="wip-panel">
            <div class="wip-icon-wrap">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none"
                     stroke="#d97706" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                </svg>
            </div>
            <span class="wip-badge">Pr&oacute;ximamente</span>
            <h2 class="wip-title">Gesti&oacute;n de Familiares</h2>
            <p class="wip-desc">
                Registro de c&oacute;nyuge e hijos de cada colaborador para la
                gesti&oacute;n de beneficios, seguros m&eacute;dicos y cargas familiares.
                Incluir&aacute; parentesco, fecha de nacimiento y documento de identidad.
            </p>
            <div class="wip-track">
                <div class="wip-fill" style="width: 25%"></div>
            </div>
            <span class="wip-pct">Progreso de desarrollo: 25 %</span>
            <div class="wip-roles">
                <span class="wip-role-chip">RR. HH.</span>
            </div>
        </div>
    </main>
</div>
</body>
</html>
