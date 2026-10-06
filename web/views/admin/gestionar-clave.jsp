<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page import="java.util.List"%>
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
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx = request.getContextPath();
    String error   = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    @SuppressWarnings("unchecked")
    List<Usuario> usuarios = (List<Usuario>) request.getAttribute("usuarios");
    if (usuarios == null) usuarios = java.util.Collections.emptyList();
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gestión de Contraseñas - Gestión de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
        <style>
            .clave-grid {
                display: grid;
                grid-template-columns: 380px minmax(0, 1fr);
                gap: 18px;
                align-items: start;
            }
            .strength-bar {
                height: 6px;
                border-radius: 4px;
                background: #e2e8f0;
                margin-top: 6px;
                overflow: hidden;
            }
            .strength-fill {
                height: 100%;
                border-radius: 4px;
                transition: width 0.3s, background-color 0.3s;
            }
            .strength-label {
                font-size: 12px;
                font-weight: 700;
                margin-top: 4px;
            }
            .badge-temp {
                display: inline-flex;
                align-items: center;
                padding: 3px 10px;
                border-radius: 999px;
                background: #fff2c2;
                color: #704a05;
                font-size: 11px;
                font-weight: 800;
            }
            @media (max-width: 900px) {
                .clave-grid { grid-template-columns: 1fr; }
            }
        </style>
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Seguridad del Sistema</p>
                    <h1>Gestión de Contraseñas</h1>
                    <p>Asignar o restablecer credenciales de acceso. El usuario afectado será expulsado y deberá iniciar sesión con la nueva contraseña.</p>
                </section>

                <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <div class="clave-grid">
                    <!-- Formulario de reset -->
                    <section class="panel">
                        <h2>Restablecer contraseña</h2>
                        <form action="<%= ctx %>/admin/gestionar-clave" method="post" class="stack-form" accept-charset="UTF-8">
                            <input type="hidden" name="accion" value="resetearClave">

                            <label for="codigoEmpleado">Usuario</label>
                            <select id="codigoEmpleado" name="codigoEmpleado" required>
                                <option value="">-- Seleccionar usuario --</option>
                                <% for (Usuario u : usuarios) { %>
                                    <option value="<%= h(u.getCodigoEmpleado()) %>">
                                        <%= h(u.getCodigoEmpleado()) %> — <%= h(u.getNombreEmpleado()) %>
                                        (<%= h(u.getRolUsuario()) %>)
                                    </option>
                                <% } %>
                            </select>

                            <label for="nuevaClave">Nueva contraseña</label>
                            <input id="nuevaClave" name="nuevaClave" type="password"
                                   minlength="9" required autocomplete="new-password"
                                   placeholder="Mín. 9 chars, 1 mayúscula, 1 número"
                                   oninput="evaluarFuerza(this.value)">
                            <div class="strength-bar"><div id="strengthFill" class="strength-fill" style="width:0"></div></div>
                            <span id="strengthLabel" class="strength-label muted">Ingrese una contraseña</span>

                            <label for="confirmarClave">Confirmar contraseña</label>
                            <input id="confirmarClave" name="confirmarClave" type="password"
                                   minlength="9" required autocomplete="new-password">

                            <p class="field-help">
                                Política: mínimo 9 caracteres, al menos una mayúscula y un número.<br>
                                El usuario será desconectado automáticamente al guardar.
                            </p>

                            <div class="button-row form-actions">
                                <button type="submit" class="btn primary">Guardar contraseña</button>
                            </div>
                        </form>
                    </section>

                    <!-- Tabla de usuarios registrados -->
                    <section class="panel table-panel">
                        <div class="panel-heading-row">
                            <h2>Usuarios del sistema</h2>
                            <a class="btn ghost" href="<%= ctx %>/admin/seguridad">Ver seguridad completa</a>
                        </div>
                        <div class="table-wrap">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Código</th>
                                        <th>Colaborador</th>
                                        <th>Rol</th>
                                        <th>Estado</th>
                                        <th>Acción rápida</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (usuarios.isEmpty()) { %>
                                        <tr><td colspan="5" class="empty">Sin usuarios registrados.</td></tr>
                                    <% } else { %>
                                        <% for (Usuario u : usuarios) { %>
                                            <tr>
                                                <td><strong><%= h(u.getCodigoEmpleado()) %></strong></td>
                                                <td><%= h(u.getNombreEmpleado()) %></td>
                                                <td>
                                                    <span class="badge-temp"><%= h(u.getRolUsuario()) %></span>
                                                </td>
                                                <td>
                                                    <span class="status <%= "A".equals(u.getEstadoCodigo()) ? "" : "inactive" %>">
                                                        <%= h(u.getEstadoDescripcion()) %>
                                                    </span>
                                                </td>
                                                <td>
                                                    <button type="button" class="btn tiny"
                                                            onclick="seleccionarUsuario('<%= h(u.getCodigoEmpleado()) %>')">
                                                        Seleccionar
                                                    </button>
                                                </td>
                                            </tr>
                                        <% } %>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </main>
        </div>

        <script>
            function seleccionarUsuario(codigo) {
                const sel = document.getElementById('codigoEmpleado');
                if (!sel) return;
                for (let i = 0; i < sel.options.length; i++) {
                    if (sel.options[i].value === codigo) {
                        sel.selectedIndex = i;
                        sel.focus();
                        break;
                    }
                }
                document.getElementById('nuevaClave').focus();
            }

            function evaluarFuerza(val) {
                const fill  = document.getElementById('strengthFill');
                const label = document.getElementById('strengthLabel');
                if (!fill || !label) return;
                let score = 0;
                if (val.length >= 9)           score++;
                if (val.length >= 14)          score++;
                if (/[A-Z]/.test(val))         score++;
                if (/[0-9]/.test(val))         score++;
                if (/[^A-Za-z0-9]/.test(val)) score++;
                const niveles = [
                    { pct: '0%',   color: '#e2e8f0', txt: 'Ingrese una contraseña' },
                    { pct: '20%',  color: '#ef4444', txt: 'Muy débil' },
                    { pct: '40%',  color: '#f97316', txt: 'Débil' },
                    { pct: '60%',  color: '#eab308', txt: 'Aceptable' },
                    { pct: '80%',  color: '#22c55e', txt: 'Fuerte' },
                    { pct: '100%', color: '#10b981', txt: 'Muy fuerte' }
                ];
                const n = niveles[val.length === 0 ? 0 : Math.min(score, 5)];
                fill.style.width = n.pct;
                fill.style.backgroundColor = n.color;
                label.textContent = n.txt;
                label.style.color = n.color === '#e2e8f0' ? '' : n.color;
            }
        </script>
    </body>
</html>
