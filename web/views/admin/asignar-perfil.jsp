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
%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;
    String ctx = request.getContextPath();
    String error   = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    @SuppressWarnings("unchecked")
    List<Empleado>      empleados   = (List<Empleado>) request.getAttribute("empleados");
    @SuppressWarnings("unchecked")
    Map<String,Usuario> usuariosMap = (Map<String,Usuario>) request.getAttribute("usuariosMap");
    String[][] perfiles             = (String[][]) request.getAttribute("perfiles");
    if (empleados   == null) empleados   = java.util.Collections.emptyList();
    if (usuariosMap == null) usuariosMap = java.util.Collections.emptyMap();
    if (perfiles == null) {
        try { perfiles = new ec.edu.monster.modelo.DAOPERFIL().listarComoArray(); }
        catch (java.sql.SQLException ex) { perfiles = ec.edu.monster.modelo.DAOUSUARIO.PERFILES_DISPONIBLES; }
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Asignación de Perfiles — Gestión de Proyectos Monster</title>
        <link rel="stylesheet" href="<%= ctx %>/estilos.css">
        <style>
            /* ── Instrucciones ──────────────────────────────────── */
            .how-it-works {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: 12px;
                margin-bottom: 20px;
            }
            .how-step {
                display: flex;
                gap: 12px;
                align-items: flex-start;
                padding: 14px 16px;
                border: 1px solid var(--line);
                border-radius: 10px;
                background: var(--surface-soft);
            }
            .how-step-num {
                display: grid;
                place-items: center;
                width: 32px; height: 32px;
                border-radius: 50%;
                background: var(--accent);
                color: #fff;
                font-size: 15px;
                font-weight: 900;
                flex: 0 0 auto;
            }
            .how-step-text strong {
                display: block;
                font-size: 13px;
                margin-bottom: 3px;
            }
            .how-step-text span {
                font-size: 12px;
                color: var(--muted);
            }

            /* ── Selector de perfil ─────────────────────────────── */
            .perfil-bar {
                display: flex;
                align-items: center;
                gap: 14px;
                flex-wrap: wrap;
                padding: 16px 18px;
                border: 2px solid var(--accent);
                border-radius: 10px;
                background: rgba(15,118,110,0.05);
                margin-bottom: 18px;
            }
            .perfil-bar label {
                font-size: 14px;
                font-weight: 900;
                white-space: nowrap;
            }
            .perfil-bar select { width: auto; min-width: 220px; }

            /* ── PickList ───────────────────────────────────────── */
            .picklist-wrapper {
                display: grid;
                grid-template-columns: minmax(0,1fr) 52px minmax(0,1fr);
                gap: 12px;
                align-items: start;
            }
            .picklist-panel {
                border: 1px solid var(--line);
                border-radius: 10px;
                background: var(--surface);
                box-shadow: var(--shadow-soft);
                overflow: hidden;
            }
            .picklist-panel.destino { border-color: var(--accent); }

            .picklist-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                padding: 12px 16px;
                border-bottom: 1px solid var(--line);
            }
            .destino .picklist-header { background: rgba(15,118,110,0.06); }

            .picklist-header h3 {
                margin: 0; font-size: 14px; font-weight: 900;
            }
            .picklist-header p {
                margin: 2px 0 0; font-size: 11px; color: var(--muted);
            }
            .picklist-count {
                display: inline-flex; align-items: center;
                padding: 2px 10px; border-radius: 999px;
                background: var(--accent); color: #fff;
                font-size: 11px; font-weight: 900;
            }
            .origen .picklist-count { background: #64748b; }

            .picklist-search {
                padding: 8px 10px;
                border-bottom: 1px solid var(--line);
            }
            .picklist-search input {
                width: 100%;
                min-height: 34px;
                padding: 7px 10px;
                border: 1px solid var(--line);
                border-radius: 7px;
                font: inherit;
                font-size: 13px;
            }
            .picklist-search input:focus {
                outline: none;
                border-color: var(--accent);
                box-shadow: 0 0 0 3px rgba(15,118,110,0.12);
            }

            .picklist-list {
                list-style: none; margin: 0; padding: 8px;
                min-height: 220px; max-height: 400px;
                overflow-y: auto; display: grid; gap: 5px;
            }
            .picklist-item {
                display: flex; align-items: center; gap: 10px;
                padding: 9px 11px;
                border: 1px solid transparent;
                border-radius: 8px;
                cursor: pointer;
                background: var(--surface-soft);
                transition: all 0.15s;
                user-select: none;
            }
            .picklist-item:hover { border-color: var(--accent); background: rgba(15,118,110,0.06); }
            .picklist-item.selected {
                border-color: var(--accent);
                background: rgba(15,118,110,0.13);
                box-shadow: 0 0 0 2px rgba(15,118,110,0.15);
            }
            .picklist-item .avatar-lg {
                width: 42px; height: 42px;
                border-radius: 50%; object-fit: cover;
                border: 2px solid var(--line);
                flex: 0 0 auto;
            }
            .item-info { min-width: 0; }
            .item-code  { display:block; font-size:10px; font-weight:900; color:var(--muted); text-transform:uppercase; }
            .item-name  { display:block; font-size:13px; font-weight:700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
            .item-role  { display:block; font-size:11px; color:var(--muted); }

            .picklist-empty {
                padding: 24px 16px;
                text-align: center;
                color: var(--muted);
                font-size: 13px;
            }

            /* ── Botones centrales ──────────────────────────────── */
            .picklist-controls {
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 8px;
                padding-top: 60px;
            }
            .picklist-btn {
                display: inline-flex; align-items: center; justify-content: center;
                width: 40px; height: 40px;
                border: 1px solid var(--line); border-radius: 8px;
                background: var(--surface); color: var(--ink);
                font-size: 18px; font-weight: 900;
                cursor: pointer; transition: all 0.2s;
            }
            .picklist-btn:hover { border-color: var(--accent); background: var(--accent); color: #fff; }
            .picklist-btn-lbl {
                font-size: 9px; font-weight: 800; color: var(--muted);
                text-align: center; margin-top: -4px; line-height: 1.2;
            }
            .picklist-sep { width: 100%; height: 1px; background: var(--line); margin: 4px 0; }

            /* ── Drag over ──────────────────────────────────────── */
            .picklist-list.drag-over {
                background: rgba(15,118,110,0.07);
                outline: 2px dashed var(--accent);
                border-radius: 8px;
            }

            @media (max-width: 900px) {
                .picklist-wrapper { grid-template-columns: 1fr; }
                .picklist-controls { flex-direction: row; padding-top: 0; }
                .how-it-works { grid-template-columns: 1fr; }
            }
        </style>
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Seguridad del Sistema</p>
                    <h1>Asignación de Perfiles</h1>
                    <p>Cambie el perfil de acceso (rol) de uno o varios colaboradores de forma masiva.</p>
                </section>

                <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                    <div class="alert success"><%= h(mensaje) %></div>
                <% } %>
                <% if (error != null && !error.trim().isEmpty()) { %>
                    <div class="alert error"><%= h(error) %></div>
                <% } %>

                <!-- Instrucciones visuales paso a paso -->
                <div class="how-it-works">
                    <div class="how-step">
                        <span class="how-step-num">1</span>
                        <div class="how-step-text">
                            <strong>Elige el perfil de destino</strong>
                            <span>Selecciona qué rol quieres asignar: Administrador, RR. HH., Jefe o Empleado.</span>
                        </div>
                    </div>
                    <div class="how-step">
                        <span class="how-step-num">2</span>
                        <div class="how-step-text">
                            <strong>Mueve colaboradores al panel derecho</strong>
                            <span>Haz clic en un colaborador y presiona › para moverlo, o arrástralo directamente.</span>
                        </div>
                    </div>
                    <div class="how-step">
                        <span class="how-step-num">3</span>
                        <div class="how-step-text">
                            <strong>Guarda la asignación</strong>
                            <span>Presiona «Guardar asignación». El cambio de rol se aplica de inmediato, sin necesidad de que el usuario cierre sesión.</span>
                        </div>
                    </div>
                </div>

                <section class="panel">
                    <form id="formAsignar" action="<%= ctx %>/admin/asignar-perfil" method="post" accept-charset="UTF-8">
                        <input type="hidden" name="accion" value="asignarPerfil">

                        <!-- Paso 1: selector de perfil -->
                        <div class="perfil-bar">
                            <label for="perfilDestino">Perfil a asignar a los colaboradores del panel derecho:</label>
                            <select id="perfilDestino" name="perfilDestino" required>
                                <option value="">— Seleccionar perfil —</option>
                                <% for (String[] p : perfiles) { %>
                                    <option value="<%= h(p[0]) %>"><%= h(p[1]) %></option>
                                <% } %>
                            </select>
                        </div>

                        <!-- Paso 2: PickList -->
                        <div class="picklist-wrapper">

                            <!-- Panel izquierdo: origen (sin este perfil o con otro) -->
                            <div class="picklist-panel origen">
                                <div class="picklist-header">
                                    <div>
                                        <h3>Todos los colaboradores</h3>
                                        <p>Selecciona los que quieres mover al panel derecho</p>
                                    </div>
                                    <span class="picklist-count" id="cntDisp">0</span>
                                </div>
                                <div class="picklist-search">
                                    <input type="text" placeholder=" Buscar por nombre o código..."
                                           oninput="filtrarLista('listaDisp', this.value)">
                                </div>
                                <ul class="picklist-list" id="listaDisp"
                                    ondragover="onDragOver(event)"
                                    ondragleave="onDragLeave(event)"
                                    ondrop="onDrop(event,'listaDisp')">
                                    <% for (Empleado e : empleados) {
                                        Usuario uEmp = usuariosMap.get(e.getCodigo());
                                        String rol = (uEmp != null) ? h(uEmp.getRolUsuario()) : "Sin usuario";
                                        String foto = (e.getFotoRuta() != null && !e.getFotoRuta().isEmpty())
                                                      ? ctx + e.getFotoRuta() : ctx + "/resources/foto.jpg";
                                    %>
                                    <li class="picklist-item"
                                        data-codigo="<%= h(e.getCodigo()) %>"
                                        data-nombre="<%= h((e.getNombre() + " " + e.getApellido()).toLowerCase()) %>"
                                        draggable="true"
                                        onclick="toggleSeleccion(this)"
                                        ondragstart="onDragStart(event)">
                                        <img class="avatar-lg"
                                             src="<%= h(foto) %>"
                                             alt="Foto"
                                             onerror="this.src='<%= ctx %>/resources/foto.jpg'">
                                        <div class="item-info">
                                            <span class="item-code"><%= h(e.getCodigo()) %></span>
                                            <span class="item-name"><%= h(e.getApellido() + ", " + e.getNombre()) %></span>
                                            <span class="item-role">Rol actual: <%= rol %></span>
                                        </div>
                                    </li>
                                    <% } if (empleados.isEmpty()) { %>
                                        <li class="picklist-empty">No hay colaboradores registrados.</li>
                                    <% } %>
                                </ul>
                            </div>

                            <!-- Controles centrales -->
                            <div class="picklist-controls">
                                <div style="text-align:center">
                                    <button type="button" class="picklist-btn" title="Mover seleccionados →"
                                            onclick="moverSeleccionados('listaDisp','listaAsig')">›</button>
                                    <div class="picklist-btn-lbl">Mover<br>seleccionados</div>
                                </div>
                                <div style="text-align:center">
                                    <button type="button" class="picklist-btn" title="Mover todos →"
                                            onclick="moverTodos('listaDisp','listaAsig')">»</button>
                                    <div class="picklist-btn-lbl">Mover<br>todos</div>
                                </div>
                                <div class="picklist-sep"></div>
                                <div style="text-align:center">
                                    <button type="button" class="picklist-btn" title="← Quitar seleccionados"
                                            onclick="moverSeleccionados('listaAsig','listaDisp')">‹</button>
                                    <div class="picklist-btn-lbl">Quitar<br>seleccionados</div>
                                </div>
                                <div style="text-align:center">
                                    <button type="button" class="picklist-btn" title="← Quitar todos"
                                            onclick="moverTodos('listaAsig','listaDisp')">«</button>
                                    <div class="picklist-btn-lbl">Quitar<br>todos</div>
                                </div>
                            </div>

                            <!-- Panel derecho: destino (recibirán el perfil seleccionado) -->
                            <div class="picklist-panel destino">
                                <div class="picklist-header">
                                    <div>
                                        <h3>Recibirán el perfil seleccionado</h3>
                                        <p>Al guardar, todos los colaboradores de este panel tendrán el rol elegido</p>
                                    </div>
                                    <span class="picklist-count" id="cntAsig">0</span>
                                </div>
                                <div class="picklist-search">
                                    <input type="text" placeholder=" Buscar..."
                                           oninput="filtrarLista('listaAsig', this.value)">
                                </div>
                                <ul class="picklist-list" id="listaAsig"
                                    ondragover="onDragOver(event)"
                                    ondragleave="onDragLeave(event)"
                                    ondrop="onDrop(event,'listaAsig')">
                                    <li class="picklist-empty" id="emptyAsig">
                                        Arrastra o mueve colaboradores aquí para asignarles el perfil.
                                    </li>
                                </ul>
                                <!-- Inputs ocultos para el submit (generados por JS) -->
                                <div id="hiddenInputs"></div>
                            </div>
                        </div>

                        <!-- Botones de acción -->
                        <div class="button-row form-actions" style="margin-top:18px">
                            <a class="btn ghost" href="<%= ctx %>/admin/seguridad">Cancelar</a>
                            <button type="submit" class="btn primary" style="min-width:200px"
                                    onclick="prepararEnvio()">
                                Guardar asignación
                            </button>
                        </div>
                    </form>
                </section>
            </main>
        </div>

        <script>
            /* ── Contadores ────────────────────────────────────────── */
            function actualizarContadores() {
                const visDisp = document.querySelectorAll('#listaDisp li.picklist-item:not([style*="display:none"])').length;
                const visAsig = document.querySelectorAll('#listaAsig li.picklist-item:not([style*="display:none"])').length;
                document.getElementById('cntDisp').textContent = visDisp;
                document.getElementById('cntAsig').textContent = visAsig;
                const emptyMsg = document.getElementById('emptyAsig');
                if (emptyMsg) {
                    emptyMsg.style.display = visAsig === 0 ? 'block' : 'none';
                }
            }

            /* ── Selección con clic ────────────────────────────────── */
            function toggleSeleccion(el) { el.classList.toggle('selected'); }

            /* ── Mover ítems ───────────────────────────────────────── */
            function moverSeleccionados(origenId, destinoId) {
                document.querySelectorAll('#' + origenId + ' li.selected').forEach(item => {
                    item.classList.remove('selected');
                    item.style.display = '';
                    document.getElementById(destinoId).appendChild(item);
                });
                actualizarContadores();
            }
            function moverTodos(origenId, destinoId) {
                document.querySelectorAll('#' + origenId + ' li.picklist-item').forEach(item => {
                    item.classList.remove('selected');
                    item.style.display = '';
                    document.getElementById(destinoId).appendChild(item);
                });
                actualizarContadores();
            }

            /* ── Búsqueda ──────────────────────────────────────────── */
            function filtrarLista(listaId, texto) {
                const q = texto.toLowerCase();
                document.querySelectorAll('#' + listaId + ' li.picklist-item').forEach(item => {
                    const match = item.dataset.nombre.includes(q) || item.dataset.codigo.includes(q);
                    item.style.display = match ? '' : 'none';
                });
                actualizarContadores();
            }

            /* ── Drag & Drop ───────────────────────────────────────── */
            let dragged = null;
            function onDragStart(e) {
                dragged = e.target.closest('li');
                if (dragged) dragged.style.opacity = '0.45';
            }
            function onDragOver(e) {
                e.preventDefault();
                e.currentTarget.classList.add('drag-over');
            }
            function onDragLeave(e) { e.currentTarget.classList.remove('drag-over'); }
            function onDrop(e, destinoId) {
                e.preventDefault();
                e.currentTarget.classList.remove('drag-over');
                if (dragged) {
                    dragged.style.opacity = '';
                    document.getElementById(destinoId).appendChild(dragged);
                    dragged = null;
                    actualizarContadores();
                }
            }
            document.addEventListener('dragend', () => { if (dragged) dragged.style.opacity = ''; });

            /* ── Preparar inputs ocultos antes del submit ──────────── */
            function prepararEnvio() {
                const cont = document.getElementById('hiddenInputs');
                cont.innerHTML = '';
                document.querySelectorAll('#listaAsig li.picklist-item').forEach(item => {
                    const inp = document.createElement('input');
                    inp.type = 'hidden'; inp.name = 'seleccionados'; inp.value = item.dataset.codigo;
                    cont.appendChild(inp);
                });
            }

            /* ── Init ──────────────────────────────────────────────── */
            actualizarContadores();
        </script>
    </body>
</html>
