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
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_JEFE_DEPARTAMENTO)) return;
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
    int cntPro = 0, cntEmp = 0;
    java.sql.Connection _cn = null;
    try {
        _cn = ec.edu.monster.modelo.Conexion.getConexion();
        try (java.sql.Statement _st = _cn.createStatement()) {
            java.sql.ResultSet _rs;
            _rs = _st.executeQuery("SELECT COUNT(*) FROM GEPRO_PROYECT");
            if (_rs.next()) cntPro = _rs.getInt(1); _rs.close();
            _rs = _st.executeQuery("SELECT COUNT(*) FROM PEEMP_EMPLE");
            if (_rs.next()) cntEmp = _rs.getInt(1); _rs.close();
        }
    } catch (Exception _e) { /* silencioso */ }
    finally { if (_cn != null) try { _cn.close(); } catch (Exception _e2) {} }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Jefe de Departamento &mdash; Gesti&oacute;n de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">

        <!-- ── Hero ──────────────────────────────────────────────────── -->
        <section class="dash-hero">
            <div class="dash-avatar av-jefe"><%= _initials %></div>
            <div class="dash-meta">
                <div class="dash-eyebrow">Control operativo</div>
                <h1 class="dash-name"><%= h(_fullName) %></h1>
                <div class="dash-meta-row">
                    <span class="role-pill rp-jefe">Jefe de Departamento</span>
                    <span class="dash-date"><%= h(_fecha) %></span>
                </div>
            </div>
        </section>

        <!-- ── Estadísticas ───────────────────────────────────────────── -->
        <section class="dash-stats two">
            <article class="stat-card sc-blue">
                <div class="sc-icon blue">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="3" width="20" height="14" rx="2"/>
                        <path d="M8 21h8M12 17v4"/>
                        <circle cx="12" cy="10" r="3"/>
                    </svg>
                </div>
                <span class="sc-label">Total proyectos</span>
                <strong class="sc-value"><%= cntPro %></strong>
            </article>
            <article class="stat-card sc-indigo">
                <div class="sc-icon indigo">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <span class="sc-label">Empleados disponibles</span>
                <strong class="sc-value"><%= cntEmp %></strong>
            </article>
        </section>

        <!-- ── Módulos ────────────────────────────────────────────────── -->
        <p class="dash-section-title">Herramientas de gesti&oacute;n</p>
        <section class="module-grid">

            <article class="module-card">
                <div class="mod-icon blue">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="3" width="20" height="14" rx="2"/>
                        <path d="M8 21h8M12 17v4"/>
                        <circle cx="12" cy="10" r="3"/>
                    </svg>
                </div>
                <h2>Gesti&oacute;n de Proyectos</h2>
                <p>Crea, modifica y consulta proyectos de la organizaci&oacute;n con toda su informaci&oacute;n.</p>
                <a class="btn primary" href="<%= ctx %>/views/proyectos/gestion.jsp">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon indigo">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                        <polyline points="17 11 19 13 23 9"/>
                    </svg>
                </div>
                <h2>Asignaci&oacute;n de Personal</h2>
                <p>Vincula empleados a proyectos activos, define roles y horas estimadas de trabajo.</p>
                <a class="btn primary" href="<%= ctx %>/views/proyectos/asignar.jsp">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon amber">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="9 11 12 14 22 4"/>
                        <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/>
                    </svg>
                </div>
                <h2>Aprobaci&oacute;n de Horas</h2>
                <p>Revisa y aprueba las horas reales registradas por los empleados en cada proyecto.</p>
                <a class="btn secondary" href="<%= ctx %>/views/proyectos/aprobar-horas.jsp">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon accent">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
                    </svg>
                </div>
                <h2>Reportes de Horas</h2>
                <p>Compara horas estimadas versus reales por proyecto para un control preciso del avance.</p>
                <a class="btn secondary" href="<%= ctx %>/views/proyectos/reportes-horas.jsp">Abrir m&oacute;dulo</a>
            </article>

        </section>

        <!-- ── Acceso rápido ───────────────────────────────────────────── -->
        <div class="dash-quick">
            <span class="quick-label">Acceso r&aacute;pido</span>
            <a class="btn tiny" href="<%= ctx %>/seguridad/cambiar-clave">&#8594;&nbsp; Cambiar mi contrase&ntilde;a</a>
        </div>

    </main>
</div>
</body>
</html>
