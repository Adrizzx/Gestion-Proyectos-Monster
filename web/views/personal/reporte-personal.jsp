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
    <title>Reporte de Personal</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Recursos Humanos</p>
            <h1>Reporte de Personal</h1>
            <p>Consulta y exportaci&oacute;n de n&uacute;mero de colaboradores por departamento y cargo.</p>
        </section>

        <div class="wip-panel">
            <div class="wip-icon-wrap">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none"
                     stroke="#d97706" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                    <line x1="16" y1="13" x2="8" y2="13"/>
                    <line x1="16" y1="17" x2="8" y2="17"/>
                    <polyline points="10 9 9 9 8 9"/>
                </svg>
            </div>
            <span class="wip-badge">Pr&oacute;ximamente</span>
            <h2 class="wip-title">Reporte de Personal por Departamento</h2>
            <p class="wip-desc">
                Consulta consolidada de colaboradores activos e inactivos agrupados
                por departamento y cargo, con totales y exportaci&oacute;n a PDF o Excel.
            </p>
            <div class="wip-track">
                <div class="wip-fill" style="width: 15%"></div>
            </div>
            <span class="wip-pct">Progreso de desarrollo: 15 %</span>
            <div class="wip-roles">
                <span class="wip-role-chip">RR. HH.</span>
            </div>
        </div>
    </main>
</div>
</body>
</html>
