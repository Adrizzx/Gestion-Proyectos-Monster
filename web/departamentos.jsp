<%@page import="java.util.List"%>
<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Departamento"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String valor) {
        if (valor == null) {
            return "";
        }
        return valor.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) {
        return;
    }
    if (request.getAttribute("departamentos") == null) {
        request.getRequestDispatcher("/admin/departamentos").forward(request, response);
        return;
    }
    String ctx = request.getContextPath();
    List<Departamento> departamentos = (List<Departamento>) request.getAttribute("departamentos");
    Departamento editar = (Departamento) request.getAttribute("departamentoEditar");
    boolean editando = editar != null;
    String proximoCodigo = (String) request.getAttribute("proximoCodigo");
    if (proximoCodigo == null) proximoCodigo = "...";
    String mensaje = (String) request.getAttribute("mensaje");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Departamentos - Gesti&oacute;n de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>M&oacute;dulo de Gesti&oacute;n</p>
                    <h1>Departamentos</h1>
                    <p>Gesti&oacute;n de departamentos</p>
                </section>

                <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <section class="content-grid">
                    <article class="panel">
                        <h2><%= editando ? "Editar departamento" : "Nuevo departamento" %></h2>
                        <form action="<%= ctx %>/admin/departamentos" method="post" class="stack-form" accept-charset="UTF-8">
                            <input type="hidden" name="codigoOriginal" value="<%= editando ? h(editar.getCodigo()) : "" %>">

                            <label>C&oacute;digo</label>
                            <% if (editando) { %>
                            <div class="readonly-badge"><%= h(editar.getCodigo()) %></div>
                            <% } else { %>
                            <div class="readonly-badge next-code">Se asignar&aacute; autom&aacute;ticamente: <strong><%= h(proximoCodigo) %></strong></div>
                            <% } %>

                            <label for="descripcion">Descripci&oacute;n</label>
                            <input id="descripcion" name="descripcion" type="text" maxlength="50"
                                   value="<%= editando ? h(editar.getDescripcion()) : "" %>" required
                                   placeholder="Nombre del departamento">

                            <div class="button-row">
                                <button type="submit" class="btn primary"><%= editando ? "Actualizar" : "Guardar" %></button>
                                <% if (editando) { %>
                                    <a class="btn ghost" href="<%= ctx %>/admin/departamentos">Cancelar</a>
                                <% } %>
                            </div>
                        </form>
                    </article>

                    <article class="panel table-panel">
                        <h2>Listado</h2>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>C&oacute;digo</th>
                                        <th>Descripci&oacute;n</th>
                                        <th>Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (departamentos == null || departamentos.isEmpty()) { %>
                                        <tr>
                                            <td colspan="3" class="empty">Sin departamentos registrados.</td>
                                        </tr>
                                    <% } else { %>
                                        <% for (Departamento departamento : departamentos) { %>
                                            <tr>
                                                <td><strong><%= h(departamento.getCodigo()) %></strong></td>
                                                <td><%= h(departamento.getDescripcion()) %></td>
                                                <td class="actions">
                                                    <a class="link-action" href="<%= ctx %>/admin/departamentos?accion=editar&codigo=<%= h(departamento.getCodigo()) %>">Editar</a>
                                                    <a class="link-danger" href="<%= ctx %>/admin/departamentos?accion=eliminar&codigo=<%= h(departamento.getCodigo()) %>" onclick="return confirm('&iquest;Eliminar este departamento?');">Eliminar</a>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </article>
                </section>
            </main>
        </div>
    </body>
</html>
