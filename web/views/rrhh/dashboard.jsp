<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
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
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_RRHH)) return;
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

    // Contadores
    int cntEmp = 0, cntDep = 0;
    java.sql.Connection _cn = null;
    try {
        _cn = ec.edu.monster.modelo.Conexion.getConexion();
        try (java.sql.Statement _st = _cn.createStatement()) {
            java.sql.ResultSet _rs;
            _rs = _st.executeQuery("SELECT COUNT(*) FROM PEEMP_EMPLE");
            if (_rs.next()) cntEmp = _rs.getInt(1); _rs.close();
            _rs = _st.executeQuery("SELECT COUNT(*) FROM PEDEP_DEPAR");
            if (_rs.next()) cntDep = _rs.getInt(1); _rs.close();
        }
    } catch (Exception _e) { /* silencioso */ }
    finally { if (_cn != null) try { _cn.close(); } catch (Exception _e2) {} }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recursos Humanos &mdash; Gesti&oacute;n de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">

        <!-- ── Hero ──────────────────────────────────────────────────── -->
        <section class="dash-hero">
            <div class="dash-avatar av-rrhh"><%= _initials %></div>
            <div class="dash-meta">
                <div class="dash-eyebrow">Talento humano</div>
                <h1 class="dash-name"><%= h(_fullName) %></h1>
                <div class="dash-meta-row">
                    <span class="role-pill rp-rrhh">Recursos Humanos</span>
                    <span class="dash-date"><%= h(_fecha) %></span>
                </div>
            </div>
        </section>

        <!-- ── Estadísticas ───────────────────────────────────────────── -->
        <section class="dash-stats two">
            <article class="stat-card sc-amber">
                <div class="sc-icon amber">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <span class="sc-label">Total empleados</span>
                <strong class="sc-value"><%= cntEmp %></strong>
            </article>
            <article class="stat-card sc-accent">
                <div class="sc-icon accent">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2"/>
                        <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                    </svg>
                </div>
                <span class="sc-label">Departamentos</span>
                <strong class="sc-value"><%= cntDep %></strong>
            </article>
        </section>

        <!-- ── Módulos ────────────────────────────────────────────────── -->
        <p class="dash-section-title">M&oacute;dulos de gesti&oacute;n de personal</p>
        <section class="module-grid three">

            <article class="module-card">
                <div class="mod-icon amber">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <h2>Gesti&oacute;n de Empleados</h2>
                <p>Registra y actualiza datos personales, salario, g&eacute;nero y estado laboral de cada empleado.</p>
                <a class="btn primary" href="<%= ctx %>/srvEmpleado">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon rose">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>
                    </svg>
                </div>
                <h2>Gestionar Familiares</h2>
                <p>Administra las cargas familiares y parentescos del personal para seguros y beneficios.</p>
                <a class="btn primary" href="<%= ctx %>/views/personal/familiares.jsp">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon accent">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                        <polyline points="14 2 14 8 20 8"/>
                        <line x1="16" y1="13" x2="8" y2="13"/>
                        <line x1="16" y1="17" x2="8" y2="17"/>
                        <polyline points="10 9 9 9 8 9"/>
                    </svg>
                </div>
                <h2>Reporte de Personal</h2>
                <p>Consulta la distribuci&oacute;n de empleados agrupados por departamento y cargo.</p>
                <a class="btn secondary" href="<%= ctx %>/admin/reporte">Abrir m&oacute;dulo</a>
            </article>

        </section>

        <!-- ── Acceso rápido ───────────────────────────────────────────── -->
        <div class="dash-quick">
            <span class="quick-label">Acceso r&aacute;pido</span>
            <a class="btn tiny" href="<%= ctx %>/seguridad/cambiar-clave">&#8594;&nbsp; Cambiar mi contrase&ntilde;a</a>
            <a class="btn tiny" href="<%= ctx %>/admin/organigrama">&#8594;&nbsp; Ver organigrama</a>
        </div>

    </main>
</div>
</body>
</html>
