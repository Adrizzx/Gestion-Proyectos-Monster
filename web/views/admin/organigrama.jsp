<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page import="ec.edu.monster.modelo.Empleado"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String v) {
        if (v == null) return "";
        return v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private String safe(String v, String def) {
        return (v == null || v.trim().isEmpty()) ? def : v.trim();
    }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response,
            Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH)) return;
    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    @SuppressWarnings("unchecked")
    Map<String, Map<String, List<Empleado>>> organigrama =
        (Map<String, Map<String, List<Empleado>>>) request.getAttribute("organigrama");
    Integer total = (Integer) request.getAttribute("totalEmpleados");
    if (organigrama == null) organigrama = java.util.Collections.emptyMap();
    if (total == null) total = 0;
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Organigrama — Gesti&oacute;n de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
        <style>
            .org-toolbar {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 14px;
                flex-wrap: wrap;
            }
            .org-toolbar input {
                width: auto;
                min-width: 240px;
                max-width: 340px;
            }
            .tree-node { padding-left: 0; }
        </style>
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Recursos Humanos</p>
                    <h1>Organigrama de la Empresa</h1>
                    <p>Estructura jer&aacute;rquica: Departamento &rarr; Cargo &rarr; Colaboradores. Total: <strong><%= total %></strong> colaboradores.</p>
                </section>

                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <section class="panel">
                    <h2 style="margin-bottom:14px">TreeView — Organigrama</h2>

                    <div class="org-toolbar">
                        <input type="text" id="orgBuscar" placeholder="Buscar colaborador o cargo..."
                               oninput="filtrarArbol(this.value)">
                        <button class="btn ghost" onclick="expandirTodo()">Expandir todo</button>
                        <button class="btn ghost" onclick="contraerTodo()">Contraer todo</button>
                    </div>

                    <% if (organigrama.isEmpty()) { %>
                        <div style="padding:24px;text-align:center;color:var(--muted)">
                            No hay datos del organigrama. Registre empleados en Gesti&oacute;n de Personal.
                        </div>
                    <% } else { %>
                    <div class="tree-container" id="arbolOrg">
                        <ul class="tree-node">
                            <%
                            for (Map.Entry<String, Map<String, List<Empleado>>> entryDept : organigrama.entrySet()) {
                                String dept = h(entryDept.getKey());
                                Map<String, List<Empleado>> cargos = entryDept.getValue();
                                // Calcular total con bucle simple (sin stream)
                                int totalDept = 0;
                                for (List<Empleado> lista : cargos.values()) {
                                    totalDept += (lista != null ? lista.size() : 0);
                                }
                            %>
                            <li class="tree-dept">
                                <button type="button" class="tree-toggle" onclick="toggle(this)">
                                    <span class="tree-icon">&#9660;</span>
                                    <span><%= dept %></span>
                                    <span class="tree-badge"><%= totalDept %> colaboradores</span>
                                </button>
                                <ul class="tree-children tree-node">
                                    <%
                                    for (Map.Entry<String, List<Empleado>> entryCargo : cargos.entrySet()) {
                                        String cargo = h(entryCargo.getKey());
                                        List<Empleado> emps = entryCargo.getValue();
                                        if (emps == null) emps = java.util.Collections.emptyList();
                                    %>
                                    <li class="tree-cargo">
                                        <button type="button" class="tree-toggle" onclick="toggle(this)">
                                            <span class="tree-icon">&#9660;</span>
                                            <span><%= cargo %></span>
                                            <span class="tree-badge"><%= emps.size() %></span>
                                        </button>
                                        <ul class="tree-children tree-node">
                                            <%
                                            for (Empleado emp : emps) {
                                                if (emp == null) continue;
                                                String fotoUrl = (emp.getFotoRuta() != null && !emp.getFotoRuta().isEmpty())
                                                              ? ctx + emp.getFotoRuta() : ctx + "/resources/foto.jpg";
                                                String apellido = safe(emp.getApellido(), "");
                                                String nombre   = safe(emp.getNombre(), "");
                                                String codigo   = safe(emp.getCodigo(), "");
                                                String sexo     = safe(emp.getSexoDescripcion(), "");
                                            %>
                                            <li class="tree-leaf-item"
                                                data-nombre="<%= h((nombre + " " + apellido).toLowerCase()) %>"
                                                data-codigo="<%= h(codigo.toLowerCase()) %>">
                                                <div class="tree-leaf">
                                                    <img class="employee-thumb"
                                                         src="<%= h(fotoUrl) %>"
                                                         alt="Foto <%= h(nombre) %>"
                                                         onerror="this.src='<%= ctx %>/resources/foto.jpg'">
                                                    <div>
                                                        <strong><%= h(apellido) %>, <%= h(nombre) %></strong>
                                                        <span style="font-size:12px;color:var(--muted);display:block"><%= h(codigo) %></span>
                                                    </div>
                                                    <% if (!sexo.isEmpty()) { %>
                                                        <span class="tree-badge" style="margin-left:auto"><%= h(sexo) %></span>
                                                    <% } %>
                                                </div>
                                            </li>
                                            <% } %>
                                        </ul>
                                    </li>
                                    <% } %>
                                </ul>
                            </li>
                            <% } %>
                        </ul>
                    </div>
                    <% } %>
                </section>
            </main>
        </div>

        <script>
            function toggle(btn) {
                var children = btn.nextElementSibling;
                if (!children) return;
                var collapsed = children.classList.toggle('collapsed');
                btn.classList.toggle('collapsed', collapsed);
            }

            function expandirTodo() {
                document.querySelectorAll('.tree-children').forEach(function(ul) {
                    ul.classList.remove('collapsed');
                });
                document.querySelectorAll('.tree-toggle').forEach(function(btn) {
                    btn.classList.remove('collapsed');
                });
            }

            function contraerTodo() {
                document.querySelectorAll('.tree-children').forEach(function(ul) {
                    ul.classList.add('collapsed');
                });
                document.querySelectorAll('.tree-toggle').forEach(function(btn) {
                    btn.classList.add('collapsed');
                });
            }

            function filtrarArbol(texto) {
                var q = texto.trim().toLowerCase();
                if (!q) {
                    document.querySelectorAll('.tree-leaf-item').forEach(function(li) {
                        li.style.display = '';
                    });
                    expandirTodo();
                    return;
                }
                document.querySelectorAll('.tree-leaf-item').forEach(function(li) {
                    var nombre = li.dataset.nombre || '';
                    var codigo = li.dataset.codigo || '';
                    li.style.display = (nombre.indexOf(q) !== -1 || codigo.indexOf(q) !== -1) ? '' : 'none';
                });
                expandirTodo();
            }
        </script>
    </body>
</html>
