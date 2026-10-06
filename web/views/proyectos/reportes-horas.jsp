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
    <title>Reportes de Horas</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Proyectos</p>
            <h1>Reportes de Horas</h1>
            <p>Comparativo de horas estimadas vs. reales por proyecto y colaborador.</p>
        </section>

        <div class="wip-panel">
            <div class="wip-icon-wrap">
                <svg width="42" height="42" viewBox="0 0 24 24" fill="none"
                     stroke="#d97706" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="18" y1="20" x2="18" y2="10"/>
                    <line x1="12" y1="20" x2="12" y2="4"/>
                    <line x1="6"  y1="20" x2="6"  y2="14"/>
                    <line x1="2"  y1="20" x2="22" y2="20"/>
                </svg>
            </div>
            <span class="wip-badge">Pr&oacute;ximamente</span>
            <h2 class="wip-title">Reportes de Horas</h2>
            <p class="wip-desc">
                Visualizaci&oacute;n gr&aacute;fica y tabular del comparativo entre horas
                planificadas y horas reales registradas, agrupado por proyecto,
                departamento y colaborador.
            </p>
            <div class="wip-track">
                <div class="wip-fill" style="width: 20%"></div>
            </div>
            <span class="wip-pct">Progreso de desarrollo: 20 %</span>
            <div class="wip-roles">
                <span class="wip-role-chip">Jefe de Departamento</span>
            </div>
        </div>
    </main>
</div>
</body>
</html>
