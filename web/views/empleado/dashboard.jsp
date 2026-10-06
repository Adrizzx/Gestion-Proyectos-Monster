<%@page import="java.sql.SQLException"%>
<%@page import="java.util.Collections"%>
<%@page import="java.util.List"%>
<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.DAOPROYECTO"%>
<%@page import="ec.edu.monster.modelo.Proyecto"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String valor) {
        if (valor == null) return "";
        return valor.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                    .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_EMPLEADO)) return;
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx = request.getContextPath();

    // Iniciales para avatar
    String _fullName = usuarioSesion.getNombreEmpleado();
    String _initials = "?";
    if (_fullName != null && !_fullName.trim().isEmpty()) {
        String[] _parts = _fullName.trim().toUpperCase().split("\\s+");
        _initials = String.valueOf(_parts[0].charAt(0));
        if (_parts.length > 1) _initials += String.valueOf(_parts[_parts.length - 1].charAt(0));
    }

    // Fecha en español
    String _fecha = java.time.LocalDate.now().format(
        java.time.format.DateTimeFormatter.ofPattern("EEEE, d 'de' MMMM 'de' yyyy",
        new java.util.Locale("es")));
    _fecha = Character.toUpperCase(_fecha.charAt(0)) + _fecha.substring(1);

    // Proyectos asignados (con todos los campos de control)
    List<Proyecto> proyectos = Collections.emptyList();
    String error = null;
    try {
        proyectos = new DAOPROYECTO().listarDetalladoPorEmpleado(usuarioSesion.getCodigoEmpleado());
    } catch (SQLException ex) {
        error = ex.getMessage();
    }
    int cntPro = proyectos == null ? 0 : proyectos.size();

    java.text.DecimalFormatSymbols _sym = new java.text.DecimalFormatSymbols(new java.util.Locale("es","EC"));
    _sym.setGroupingSeparator('.'); _sym.setDecimalSeparator(',');
    java.text.DecimalFormat _money = new java.text.DecimalFormat("#,##0.00", _sym);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal del Empleado &mdash; Gesti&oacute;n de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        .mp-grid { display: grid; gap: 14px; }
        .mp-card {
            border: 1px solid var(--line); border-left: 4px solid var(--accent);
            border-radius: 12px; background: var(--surface); box-shadow: var(--shadow-soft);
            padding: 18px 20px;
        }
        .mp-card.excedido { border-left-color: var(--brand); }
        .mp-card.atrasado { border-left-color: var(--warning); }
        .mp-head { display:flex; align-items:center; gap:10px; flex-wrap:wrap; margin-bottom:6px; }
        .mp-code { display:inline-block; padding:3px 10px; border-radius:999px; background:var(--surface-soft);
            border:1px solid var(--line); font-size:11px; font-weight:900; color:var(--muted); }
        .mp-name { font-size:16px; font-weight:900; color:var(--ink); margin:0; flex:1; }
        .mp-estado { display:inline-flex; padding:3px 10px; border-radius:999px; font-size:11px; font-weight:800; }
        .mp-estado.PLANIFICADO { background:#f1f5f9; color:#475569; }
        .mp-estado.EN_PROGRESO { background:#e7f6ed; color:#0f5132; }
        .mp-estado.COMPLETADO  { background:#dbeafe; color:#1e40af; }
        .mp-estado.CANCELADO   { background:#fde8eb; color:#b42334; }
        .mp-desc { font-size:13px; color:var(--muted); margin:0 0 12px; }
        .mp-metrics { display:grid; grid-template-columns:repeat(4,minmax(0,1fr)); gap:12px; margin-bottom:10px; }
        .mp-metric .l { font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:0.04em; color:var(--muted); }
        .mp-metric .v { font-size:14px; font-weight:900; color:var(--ink); }
        .mp-metric .v.over { color:var(--brand); }
        .mp-track { height:8px; border-radius:999px; background:var(--line); overflow:hidden; margin:4px 0; }
        .mp-fill { height:100%; background:var(--accent); border-radius:999px; }
        .mp-extra { font-size:12px; color:var(--muted); margin-top:8px; padding-top:8px; border-top:1px solid var(--line); }
        .mp-extra b { color:var(--ink); }
        @media (max-width:800px){ .mp-metrics { grid-template-columns:1fr 1fr; } }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">

        <!-- ── Hero ──────────────────────────────────────────────────── -->
        <section class="dash-hero">
            <div class="dash-avatar av-empleado"><%= _initials %></div>
            <div class="dash-meta">
                <div class="dash-eyebrow">Portal del empleado</div>
                <h1 class="dash-name"><%= h(_fullName) %></h1>
                <div class="dash-meta-row">
                    <span class="role-pill rp-empleado">Empleado</span>
                    <span class="dash-date"><%= h(_fecha) %></span>
                </div>
            </div>
        </section>

        <!-- ── Estadística rápida ─────────────────────────────────────── -->
        <section class="dash-stats two" style="max-width:480px">
            <article class="stat-card sc-accent">
                <div class="sc-icon accent">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="3" width="20" height="14" rx="2"/>
                        <path d="M8 21h8M12 17v4"/>
                        <circle cx="12" cy="10" r="3"/>
                    </svg>
                </div>
                <span class="sc-label">Proyectos asignados</span>
                <strong class="sc-value"><%= cntPro %></strong>
            </article>
            <article class="stat-card sc-blue">
                <div class="sc-icon blue">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <polyline points="12 6 12 12 16 14"/>
                    </svg>
                </div>
                <span class="sc-label">Registro de horas</span>
                <a class="btn secondary" style="margin-top:10px;width:fit-content;padding:7px 14px;font-size:13px"
                   href="<%= ctx %>/views/tiempos/registrar.jsp">Registrar</a>
            </article>
        </section>

        <!-- ── Tabla de proyectos ──────────────────────────────────────── -->
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert error" style="margin-bottom:16px"><%= h(error) %></div>
        <% } %>

        <section class="panel">
            <div class="panel-heading-row">
                <div>
                    <h2 style="margin-bottom:2px">Mis proyectos</h2>
                    <p style="font-size:13px;margin:0">Detalle de los proyectos en los que colaboras actualmente</p>
                </div>
                <a class="btn primary" href="<%= ctx %>/views/tiempos/registrar.jsp">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                         stroke-width="2.5" stroke-linecap="round" style="margin-right:6px">
                        <circle cx="12" cy="12" r="10"/>
                        <polyline points="12 6 12 12 16 14"/>
                    </svg>
                    Registrar horas
                </a>
            </div>

            <% if (proyectos == null || proyectos.isEmpty()) { %>
                <div class="empty" style="text-align:center;padding:30px;color:var(--muted)">
                    No tienes proyectos asignados en este momento.
                </div>
            <% } else { %>
            <div class="mp-grid">
                <% for (Proyecto p : proyectos) {
                    String clase = p.isExcedido() ? "excedido" : (p.isAtrasado() ? "atrasado" : "");
                    Long dias = p.getDiasRestantes();
                    String tiempo;
                    if (dias == null) tiempo = "Sin fecha fin";
                    else if (dias < 0) tiempo = Math.abs(dias) + " días de atraso";
                    else tiempo = dias + " días restantes";
                    String rango = (p.getFechaInicio()==null?"—":p.getFechaInicio().toString())
                                 + " → " + (p.getFechaFin()==null?"—":p.getFechaFin().toString());
                %>
                <div class="mp-card <%= clase %>">
                    <div class="mp-head">
                        <span class="mp-code"><%= h(p.getCodigo()) %></span>
                        <h3 class="mp-name"><%= h(p.getNombre()) %></h3>
                        <span class="mp-estado <%= h(p.getEstado()) %>"><%= h(p.getEstadoLabel()) %></span>
                    </div>
                    <% if (p.getDescripcion() != null && !p.getDescripcion().isEmpty()) { %>
                        <p class="mp-desc"><%= h(p.getDescripcion()) %></p>
                    <% } %>
                    <div class="mp-metrics">
                        <div class="mp-metric"><div class="l">Presupuesto</div><div class="v">USD <%= _money.format(p.getPresupuesto()) %></div></div>
                        <div class="mp-metric"><div class="l">Gasto</div><div class="v <%= p.isExcedido()?"over":"" %>">USD <%= _money.format(p.getGasto()) %></div></div>
                        <div class="mp-metric"><div class="l">Disponible</div><div class="v <%= p.isExcedido()?"over":"" %>">USD <%= _money.format(p.getDisponible()) %></div></div>
                        <div class="mp-metric"><div class="l">Departamento</div><div class="v"><%= h(p.getDepartamentoDescripcion()==null?"—":p.getDepartamentoDescripcion()) %></div></div>
                    </div>
                    <div class="mp-metric">
                        <div class="l">Avance: <%= p.getAvance() %>%</div>
                        <div class="mp-track"><div class="mp-fill" style="width:<%= p.getAvance() %>%<%= p.isExcedido()?";background:var(--brand)":"" %>"></div></div>
                    </div>
                    <div class="mp-extra">
                        <b>Tiempo:</b> <%= h(rango) %> &nbsp;·&nbsp; <%= h(tiempo) %><br>
                        <b>Personas involucradas:</b> <%= p.getTotalEmpleados() %>
                        <% if (p.getRecursos() != null && !p.getRecursos().isEmpty()) { %>
                            <br><b>Recursos:</b> <%= h(p.getRecursos()) %>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>
        </section>

        <!-- ── Acceso rápido ───────────────────────────────────────────── -->
        <div class="dash-quick">
            <span class="quick-label">Acceso r&aacute;pido</span>
            <a class="btn tiny" href="<%= ctx %>/views/tiempos/registrar.jsp">&#8594;&nbsp; Registrar horas reales</a>
            <a class="btn tiny" href="<%= ctx %>/seguridad/cambiar-clave">&#8594;&nbsp; Cambiar mi contrase&ntilde;a</a>
        </div>

    </main>
</div>
</body>
</html>
