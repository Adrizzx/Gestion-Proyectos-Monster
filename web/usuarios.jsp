<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.DAOUSUARIO"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String v) {
        if (v == null) return "";
        return v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;
    if (request.getAttribute("usuarios") == null) {
        request.getRequestDispatcher("/admin/seguridad").forward(request, response);
        return;
    }
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    @SuppressWarnings("unchecked")
    Map<String, List<Usuario>> porPerfil =
        (Map<String, List<Usuario>>) request.getAttribute("usuariosPorPerfil");
    String mensaje = (String) request.getAttribute("mensaje");
    String error   = (String) request.getAttribute("error");
    // Perfiles reales (incluye los creados dinámicamente); fallback a los fijos.
    String[][] perfiles = (String[][]) request.getAttribute("perfiles");
    if (perfiles == null) perfiles = DAOUSUARIO.PERFILES_DISPONIBLES;
    if (usuarios  == null) usuarios  = java.util.Collections.emptyList();
    if (porPerfil == null) porPerfil = java.util.Collections.emptyMap();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Seguridad del Sistema — Gestión de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
        <style>
            .security-layout {
                display: grid;
                grid-template-columns: 280px minmax(0, 1fr);
                gap: 18px;
                align-items: start;
            }
            /* Colores de perfil en el TreeView */
            .tree-pill {
                display: inline-flex; align-items: center;
                padding: 2px 9px; border-radius: 999px;
                font-size: 10px; font-weight: 900;
                margin-left: auto; white-space: nowrap;
            }
            .tree-pill.admin   { background:#fde8eb; color:#b42334; }
            .tree-pill.rrhh    { background:#fff2c2; color:#704a05; }
            .tree-pill.jefe    { background:#e0f2fe; color:#0369a1; }
            .tree-pill.emp     { background:#e7f6ed; color:#0f5132; }
            .tree-pill.default { background:#f1f5f9; color:#475569; }

            .tree-user-leaf {
                display: flex; align-items: center; gap: 8px;
                padding: 6px 10px; border-radius: 7px;
                font-size: 13px; transition: background 0.15s;
            }
            .tree-user-leaf:hover { background: var(--surface-soft); }
            .tree-user-leaf .u-code {
                font-size: 10px; font-weight: 900;
                color: var(--muted); min-width: 52px;
            }
            .tree-user-leaf .u-name { flex: 1; }
            .tree-empty-node {
                padding: 8px 10px; font-size: 12px;
                color: var(--muted); font-style: italic;
            }

            @media (max-width: 900px) {
                .security-layout { grid-template-columns: 1fr; }
            }
        </style>
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Módulo de Seguridad</p>
                    <h1>Seguridad del Sistema</h1>
                    <p>Administración de usuarios, estados de cuenta y roles. Para crear empleados ve a <a href="<%= ctx %>/admin/gestion-personal" style="color:var(--accent);font-weight:700">Gestión de Personal</a>.</p>
                </section>

                <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <div class="security-layout">

                    <!-- ── TreeView: Usuarios por perfil ─────────────────── -->
                    <section class="panel">
                        <h2 style="margin-bottom:14px">TreeView &mdash; Usuarios por perfil</h2>
                        <div class="tree-container" style="padding:0" id="arbolPerfiles">
                            <ul class="tree-node">
                                <%
                                String[] pilClases = {"admin","rrhh","jefe","emp"};
                                int pIdx = 0;
                                for (Map.Entry<String, List<Usuario>> entrada : porPerfil.entrySet()) {
                                    String rolNombre = entrada.getKey();
                                    List<Usuario> usrs = entrada.getValue();
                                    String pillCls = pIdx < pilClases.length ? pilClases[pIdx] : "default";
                                    pIdx++;
                                %>
                                <li class="tree-dept">
                                    <button type="button" class="tree-toggle" onclick="toggle(this)">
                                        <span class="tree-icon">▼</span>
                                        <span><%= h(rolNombre) %></span>
                                        <span class="tree-pill <%= pillCls %>"><%= usrs.size() %></span>
                                    </button>
                                    <ul class="tree-children tree-node">
                                        <% if (usrs.isEmpty()) { %>
                                            <li><div class="tree-empty-node">Sin usuarios con este perfil</div></li>
                                        <% } else {
                                            for (Usuario u : usrs) {
                                                boolean activo = "A".equals(u.getEstadoCodigo());
                                        %>
                                        <li>
                                            <div class="tree-user-leaf">
                                                <span class="u-code"><%= h(u.getCodigoEmpleado()) %></span>
                                                <span class="u-name"><%= h(u.getNombreEmpleado()) %></span>
                                                <span class="status <%= activo ? "" : "inactive" %>"
                                                      style="font-size:10px;padding:2px 8px">
                                                    <%= activo ? "Activo" : "Inactivo" %>
                                                </span>
                                            </div>
                                        </li>
                                        <% } } %>
                                    </ul>
                                </li>
                                <% } %>
                            </ul>
                        </div>

                        <div style="margin-top:14px;padding-top:12px;border-top:1px solid var(--line)">
                            <a class="btn ghost" style="width:100%;justify-content:center"
                               href="<%= ctx %>/admin/asignar-perfil">
                                Asignación masiva de perfiles →
                            </a>
                        </div>
                    </section>

                    <!-- ── Tabla de gestión ──────────────────────────────── -->
                    <section class="panel table-panel">
                        <div class="panel-heading-row">
                            <h2>Usuarios registrados</h2>
                            <div style="display:flex;gap:8px">
                                <a class="btn ghost" href="<%= ctx %>/admin/gestionar-clave">Gestionar contraseñas</a>
                                <a class="btn secondary" href="<%= ctx %>/admin/gestion-personal?accion=nuevo">+ Nuevo colaborador</a>
                            </div>
                        </div>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Código</th>
                                        <th>Colaborador</th>
                                        <th>Rol</th>
                                        <th>Estado</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (usuarios.isEmpty()) { %>
                                        <tr>
                                            <td colspan="5" class="empty">Sin usuarios registrados.</td>
                                        </tr>
                                    <% } else {
                                        for (Usuario usuario : usuarios) {
                                            boolean activo = "A".equals(usuario.getEstadoCodigo());
                                    %>
                                        <tr>
                                            <td><strong><%= h(usuario.getCodigoEmpleado()) %></strong></td>
                                            <td><%= h(usuario.getNombreEmpleado()) %></td>
                                            <td>
                                                <form action="<%= ctx %>/admin/seguridad" method="post"
                                                      class="inline-form" accept-charset="UTF-8">
                                                    <input type="hidden" name="accion" value="cambiarRol">
                                                    <input type="hidden" name="codigoEmpleado"
                                                           value="<%= h(usuario.getCodigoEmpleado()) %>">
                                                    <select name="perfil"
                                                            aria-label="Rol de <%= h(usuario.getCodigoEmpleado()) %>">
                                                        <% for (String[] perfil : perfiles) { %>
                                                            <option value="<%= h(perfil[0]) %>"
                                                                    <%= perfil[0].equals(usuario.getPerfilCodigo()) ? "selected" : "" %>>
                                                                <%= h(perfil[1]) %>
                                                            </option>
                                                        <% } %>
                                                    </select>
                                                    <button type="submit" class="btn tiny">Aplicar</button>
                                                </form>
                                            </td>
                                            <td>
                                                <span class="status <%= activo ? "" : "inactive" %>">
                                                    <%= h(usuario.getEstadoDescripcion()) %>
                                                </span>
                                            </td>
                                            <td class="actions">
                                                <% if (activo) { %>
                                                    <form action="<%= ctx %>/admin/seguridad" method="post">
                                                        <input type="hidden" name="accion" value="cambiarEstado">
                                                        <input type="hidden" name="codigoEmpleado"
                                                               value="<%= h(usuario.getCodigoEmpleado()) %>">
                                                        <input type="hidden" name="estado" value="I">
                                                        <button type="submit" class="link-danger">Desactivar</button>
                                                    </form>
                                                <% } else { %>
                                                    <form action="<%= ctx %>/admin/seguridad" method="post">
                                                        <input type="hidden" name="accion" value="cambiarEstado">
                                                        <input type="hidden" name="codigoEmpleado"
                                                               value="<%= h(usuario.getCodigoEmpleado()) %>">
                                                        <input type="hidden" name="estado" value="A">
                                                        <button type="submit" class="link-action">Activar</button>
                                                    </form>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% } } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </main>
        </div>

        <script>
            function toggle(btn) {
                const children = btn.nextElementSibling;
                if (children) children.classList.toggle('collapsed');
                btn.classList.toggle('collapsed');
            }
        </script>
    </body>
</html>
