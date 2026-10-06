<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_JEFE_DEPARTAMENTO)) return;
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aprobaci&oacute;n de Horas</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Proyectos</p>
            <h1>Aprobaci&oacute;n de Horas</h1>
            <p>Revisi&oacute;n y aprobaci&oacute;n de registros de horas enviados por empleados.</p>
        </section>

        <div class="wip-panel">
            <div class="wip-icon-wrap">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none"
                     stroke="#d97706" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    <polyline points="9 12 11 14 15 10"/>
                </svg>
            </div>
            <span class="wip-badge">Pr&oacute;ximamente</span>
            <h2 class="wip-title">Aprobaci&oacute;n de Horas</h2>
            <p class="wip-desc">
                Este m&oacute;dulo permitir&aacute; al Jefe de Departamento revisar,
                aprobar o rechazar los registros de horas enviados por los colaboradores
                del equipo, con trazabilidad completa de cambios.
            </p>
            <div class="wip-track">
                <div class="wip-fill" style="width: 30%"></div>
            </div>
            <span class="wip-pct">Progreso de desarrollo: 30 %</span>
            <div class="wip-roles">
                <span class="wip-role-chip">Jefe de Departamento</span>
            </div>
        </div>
    </main>
</div>
</body>
</html>
