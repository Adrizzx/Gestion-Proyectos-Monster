<%@page import="java.util.List"%>
<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Perfil"%>
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
    if (request.getAttribute("perfiles") == null) {
        request.getRequestDispatcher("/admin/perfiles").forward(request, response);
        return;
    }
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Perfil> perfiles = (List<Perfil>) request.getAttribute("perfiles");
    Perfil editar = (Perfil) request.getAttribute("perfilEditar");
    boolean editando = editar != null;
    String proximoCodigo = (String) request.getAttribute("proximoCodigo");
    if (proximoCodigo == null) proximoCodigo = "...";
    String mensaje = (String) request.getAttribute("mensaje");
    String error   = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gesti&oacute;n de Perfiles - Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        .perf-code-badge {
            display: inline-block;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            font-weight: 700;
            background: rgba(180,35,52,0.08);
            color: var(--brand);
            border: 1px solid rgba(180,35,52,0.20);
            border-radius: 6px;
            padding: 5px 12px;
            letter-spacing: 1px;
        }
        .perf-next {
            font-size: 12px;
            color: var(--muted);
            margin-top: 4px;
        }
        .perf-next strong {
            font-family: 'Courier New', monospace;
            color: var(--brand);
        }
        .assign-links {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }
        .assign-links a {
            font-size: 12px;
            padding: 3px 10px;
            border-radius: 6px;
            border: 1px solid var(--border);
            color: var(--muted);
            text-decoration: none;
            transition: all .15s;
        }
        .assign-links a:hover {
            background: var(--brand);
            border-color: var(--brand);
            color: #fff;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Seguridad</p>
            <h1>Gesti&oacute;n de Perfiles</h1>
            <p>Crea y administra los perfiles de seguridad del sistema</p>
        </section>

        <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
        <div class="alert success"><%= h(mensaje) %></div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
        <div class="alert error"><%= h(error) %></div>
        <% } %>

        <section class="content-grid">

            <!-- ── Formulario ────────────────────────────────────── -->
            <article class="panel">
                <h2><%= editando ? "Editar perfil" : "Nuevo perfil" %></h2>
                <form action="<%= ctx %>/admin/perfiles" method="post"
                      class="stack-form" accept-charset="UTF-8">
                    <input type="hidden" name="codigoOriginal"
                           value="<%= editando ? h(editar.getCodigo()) : "" %>">

                    <label>C&oacute;digo</label>
                    <% if (editando) { %>
                    <span class="perf-code-badge"><%= h(editar.getCodigo()) %></span>
                    <% } else { %>
                    <p class="perf-next">
                        Se asignar&aacute; autom&aacute;ticamente:
                        <strong><%= h(proximoCodigo) %></strong>
                    </p>
                    <% } %>

                    <label for="descripcion">Descripci&oacute;n</label>
                    <input id="descripcion" name="descripcion" type="text" maxlength="100"
                           value="<%= editando ? h(editar.getDescripcion()) : "" %>"
                           placeholder="Ej. Analista de Sistemas" required>

                    <div class="button-row">
                        <button type="submit" class="btn primary">
                            <%= editando ? "Actualizar" : "Crear Perfil" %>
                        </button>
                        <% if (editando) { %>
                        <a class="btn ghost" href="<%= ctx %>/admin/perfiles">Cancelar</a>
                        <% } %>
                    </div>
                </form>
            </article>

            <!-- ── Listado ───────────────────────────────────────── -->
            <article class="panel table-panel">
                <h2>Perfiles registrados</h2>
                <div class="table-wrap">
                    <table>
                        <thead>
                            <tr>
                                <th>C&oacute;digo</th>
                                <th>Descripci&oacute;n</th>
                                <th>Acciones</th>
                                <th>Asignar</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (perfiles == null || perfiles.isEmpty()) { %>
                            <tr>
                                <td colspan="4" class="empty">Sin perfiles registrados.</td>
                            </tr>
                        <% } else {
                               for (Perfil p : perfiles) { %>
                            <tr>
                                <td>
                                    <span class="perf-code-badge"><%= h(p.getCodigo()) %></span>
                                </td>
                                <td><%= h(p.getDescripcion()) %></td>
                                <td class="actions">
                                    <a class="link-action"
                                       href="<%= ctx %>/admin/perfiles?accion=editar&codigo=<%= h(p.getCodigo()) %>">
                                        Editar
                                    </a>
                                    <a class="link-danger"
                                       href="<%= ctx %>/admin/perfiles?accion=eliminar&codigo=<%= h(p.getCodigo()) %>"
                                       onclick="return confirm('¿Eliminar el perfil <%= h(p.getCodigo()) %>?');">
                                        Eliminar
                                    </a>
                                </td>
                                <td>
                                    <div class="assign-links">
                                        <a href="<%= ctx %>/admin/asignar-perfil"
                                           title="Asignar usuarios a este perfil">
                                            Usuarios
                                        </a>
                                        <a href="<%= ctx %>/admin/asignar-opciones?perfilCodigo=<%= h(p.getCodigo()) %>"
                                           title="Asignar opciones de men&uacute; a este perfil">
                                            Opciones
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        <%     }
                           } %>
                        </tbody>
                    </table>
                </div>

                <% if (perfiles != null && !perfiles.isEmpty()) { %>
                <p style="margin-top:12px;font-size:12px;color:var(--muted);">
                    Haz clic en <strong>Opciones</strong> para asignar las pantallas visibles
                    a cada perfil. Haz clic en <strong>Usuarios</strong> para asignar
                    colaboradores.
                </p>
                <% } %>
            </article>

        </section>
    </main>
</div>
</body>
</html>
