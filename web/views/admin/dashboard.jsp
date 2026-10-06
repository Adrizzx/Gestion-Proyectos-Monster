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
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx = request.getContextPath();

    // Iniciales del nombre para el avatar
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

    // Contadores desde BD
    int cntEmp = 0, cntUsu = 0, cntDep = 0, cntPro = 0;
    java.sql.Connection _cn = null;
    try {
        _cn = ec.edu.monster.modelo.Conexion.getConexion();
        try (java.sql.Statement _st = _cn.createStatement()) {
            java.sql.ResultSet _rs;
            _rs = _st.executeQuery("SELECT COUNT(*) FROM PEEMP_EMPLE");
            if (_rs.next()) cntEmp = _rs.getInt(1); _rs.close();
            _rs = _st.executeQuery("SELECT COUNT(*) FROM XEUSU_USUAR WHERE XEEST_CODIGO='A'");
            if (_rs.next()) cntUsu = _rs.getInt(1); _rs.close();
            _rs = _st.executeQuery("SELECT COUNT(*) FROM PEDEP_DEPAR");
            if (_rs.next()) cntDep = _rs.getInt(1); _rs.close();
            _rs = _st.executeQuery("SELECT COUNT(*) FROM GEPRO_PROYECT");
            if (_rs.next()) cntPro = _rs.getInt(1); _rs.close();
        }
    } catch (Exception _e) { /* silencioso */ }
    finally { if (_cn != null) try { _cn.close(); } catch (Exception _e2) {} }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrador &mdash; Gesti&oacute;n de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">

        <!-- ── Hero ──────────────────────────────────────────────────── -->
        <section class="dash-hero">
            <div class="dash-avatar av-admin"><%= _initials %></div>
            <div class="dash-meta">
                <div class="dash-eyebrow">Bienvenido de vuelta</div>
                <h1 class="dash-name"><%= h(_fullName) %></h1>
                <div class="dash-meta-row">
                    <span class="role-pill rp-admin">Administrador</span>
                    <span class="dash-date"><%= h(_fecha) %></span>
                </div>
            </div>
        </section>

        <!-- ── Estadísticas ───────────────────────────────────────────── -->
        <section class="dash-stats">
            <article class="stat-card sc-brand">
                <div class="sc-icon brand">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <span class="sc-label">Empleados</span>
                <strong class="sc-value"><%= cntEmp %></strong>
            </article>
            <article class="stat-card sc-accent">
                <div class="sc-icon accent">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                </div>
                <span class="sc-label">Usuarios activos</span>
                <strong class="sc-value"><%= cntUsu %></strong>
            </article>
            <article class="stat-card sc-blue">
                <div class="sc-icon blue">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2"/>
                        <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                    </svg>
                </div>
                <span class="sc-label">Departamentos</span>
                <strong class="sc-value"><%= cntDep %></strong>
            </article>
            <article class="stat-card sc-amber">
                <div class="sc-icon amber">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="3" width="20" height="14" rx="2"/>
                        <path d="M8 21h8M12 17v4"/>
                        <circle cx="12" cy="10" r="3"/>
                    </svg>
                </div>
                <span class="sc-label">Proyectos</span>
                <strong class="sc-value"><%= cntPro %></strong>
            </article>
        </section>

        <!-- ── Módulos ────────────────────────────────────────────────── -->
        <p class="dash-section-title">M&oacute;dulos del sistema</p>
        <section class="module-grid three">

            <article class="module-card">
                <div class="mod-icon brand">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                </div>
                <h2>Seguridad del Sistema</h2>
                <p>Gesti&oacute;n de usuarios, estados de cuenta y configuraci&oacute;n de perfiles de acceso.</p>
                <a class="btn primary" href="<%= ctx %>/admin/seguridad">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon blue">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2"/>
                        <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2"/>
                    </svg>
                </div>
                <h2>Departamentos</h2>
                <p>Crear, editar y eliminar departamentos de la estructura organizacional de la empresa.</p>
                <a class="btn primary" href="<%= ctx %>/admin/departamentos">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon accent">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <h2>Gesti&oacute;n de Empleados</h2>
                <p>Datos personales, salario, g&eacute;nero y estado laboral de toda la plantilla.</p>
                <a class="btn secondary" href="<%= ctx %>/srvEmpleado">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon amber">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="3" width="20" height="14" rx="2"/>
                        <path d="M8 21h8M12 17v4"/>
                        <circle cx="12" cy="10" r="3"/>
                    </svg>
                </div>
                <h2>Gesti&oacute;n de Proyectos</h2>
                <p>Portafolio de proyectos de la organizaci&oacute;n, asignaci&oacute;n de personal y control de horas.</p>
                <a class="btn secondary" href="<%= ctx %>/views/proyectos/gestion.jsp">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon purple">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </div>
                <h2>Asignar Opciones al Perfil</h2>
                <p>Control de acceso fino: define qu&eacute; m&oacute;dulos puede ver y usar cada perfil de usuario.</p>
                <a class="btn ghost" href="<%= ctx %>/admin/asignar-opciones">Abrir m&oacute;dulo</a>
            </article>

            <article class="module-card">
                <div class="mod-icon slate">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                        <polyline points="9 22 9 12 15 12 15 22"/>
                    </svg>
                </div>
                <h2>Organigrama</h2>
                <p>Vista jer&aacute;rquica interactiva de departamentos, cargos y empleados de la empresa.</p>
                <a class="btn ghost" href="<%= ctx %>/admin/organigrama">Abrir m&oacute;dulo</a>
            </article>

        </section>

        <!-- ── Accesos rápidos ─────────────────────────────────────────── -->
        <div class="dash-quick">
            <span class="quick-label">Accesos r&aacute;pidos</span>
            <a class="btn tiny" href="<%= ctx %>/admin/asignar-perfil">&#8594;&nbsp; Asignar usuarios al perfil</a>
            <a class="btn tiny" href="<%= ctx %>/admin/asignar-opciones">&#8594;&nbsp; Asignar opciones al perfil</a>
            <a class="btn tiny" href="<%= ctx %>/admin/gestionar-clave">&#8594;&nbsp; Gestionar contrase&ntilde;as</a>
            <a class="btn tiny" href="<%= ctx %>/seguridad/cambiar-clave">&#8594;&nbsp; Cambiar mi contrase&ntilde;a</a>
            <a class="btn tiny" href="<%= ctx %>/admin/reporte">&#8594;&nbsp; Reporte de personal</a>
        </div>

    </main>
</div>
</body>
</html>
