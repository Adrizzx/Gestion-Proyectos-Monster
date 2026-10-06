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
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_EMPLEADO)) {
        return;
    }
    request.setCharacterEncoding("UTF-8");
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx = request.getContextPath();
    List<Proyecto> proyectos = Collections.emptyList();
    String error = null;
    String mensaje = null;
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        mensaje = "Horas enviadas en estado pendiente.";
    }
    try {
        proyectos = new DAOPROYECTO().listarPorEmpleado(usuarioSesion.getCodigoEmpleado());
    } catch (SQLException ex) {
        error = ex.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registrar Horas Reales</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Hoja de tiempos</p>
                    <h1>Registrar Horas Reales</h1>
                    <p>Proyectos asignados y horas trabajadas en la semana.</p>
                </section>

                <% if (mensaje != null) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <section class="panel table-panel">
                    <form method="post" action="<%= ctx %>/views/tiempos/registrar.jsp" accept-charset="UTF-8">
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Proyecto</th>
                                        <th>Departamento</th>
                                        <th>Horas reales</th>
                                        <th>Estado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (proyectos == null || proyectos.isEmpty()) { %>
                                        <tr>
                                            <td colspan="4" class="empty">Sin proyectos asignados.</td>
                                        </tr>
                                    <% } else { %>
                                        <% for (Proyecto proyecto : proyectos) { %>
                                            <tr>
                                                <td><strong><%= h(proyecto.getCodigo()) %></strong> - <%= h(proyecto.getNombre()) %></td>
                                                <td><%= h(proyecto.getDepartamentoDescripcion()) %></td>
                                                <td><input name="horas_<%= h(proyecto.getCodigo()) %>" type="number" min="0" max="80" step="0.5" required></td>
                                                <td><span class="status pending">Pendiente</span></td>
                                            </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="button-row form-actions">
                            <button type="submit" class="btn primary" <%= proyectos == null || proyectos.isEmpty() ? "disabled" : "" %>>Guardar horas</button>
                        </div>
                    </form>
                </section>
            </main>
        </div>
    </body>
</html>
