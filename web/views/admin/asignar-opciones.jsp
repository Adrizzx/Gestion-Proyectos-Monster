<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page import="ec.edu.monster.modelo.Opcion"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Set"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.LinkedHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String v) {
        if (v == null) return "";
        return v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }

    private String getSubcategoria(String codigo) {
        if (codigo == null) return "GENERAL";
        switch (codigo.trim()) {
            // Tablas Básicas: maestros de datos
            case "002": case "003": case "008": case "012": case "017":
                return "TABLAS_BASICAS";
            // Procesos: operaciones y flujos
            case "004": case "005": case "006": case "007":
            case "009": case "010": case "013": case "014": case "016":
                return "PROCESOS";
            // Reportes
            case "011": case "015": case "018":
                return "REPORTES";
            // General (ej. Inicio 001)
            default:
                return "GENERAL";
        }
    }

    private String safeId(String v) {
        if (v == null) return "mod";
        return v.replaceAll("[^a-zA-Z0-9]", "_");
    }

    private String getNombreModulo(String cod, String desc) {
        if ("H".equals(cod)) return "Personal";
        if (desc != null && desc.equalsIgnoreCase("Proyectos")) return "Gestión de Proyectos";
        if (desc != null && desc.equalsIgnoreCase("Recursos Humanos")) return "Personal";
        return desc != null ? desc : cod;
    }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;
    String ctx = request.getContextPath();
    String error   = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
    String perfilSeleccionado = (String) request.getAttribute("perfilSeleccionado");
    if (perfilSeleccionado == null) perfilSeleccionado = "";

    @SuppressWarnings("unchecked")
    List<Opcion> todasOpciones = (List<Opcion>) request.getAttribute("todasOpciones");
    @SuppressWarnings("unchecked")
    Set<String> codigosAsignados = (Set<String>) request.getAttribute("codigosAsignados");
    String[][] perfiles = (String[][]) request.getAttribute("perfiles");

    if (todasOpciones  == null) todasOpciones  = java.util.Collections.emptyList();
    if (codigosAsignados == null) codigosAsignados = java.util.Collections.emptySet();
    if (perfiles == null) {
        try { perfiles = new ec.edu.monster.modelo.DAOPERFIL().listarComoArray(); }
        catch (java.sql.SQLException ex) { perfiles = ec.edu.monster.modelo.DAOUSUARIO.PERFILES_DISPONIBLES; }
    }

    boolean perfilCargado = !perfilSeleccionado.isEmpty() && !todasOpciones.isEmpty();

    // Pre-agrupar: módulo → subcategoría → lista de opciones
    LinkedHashMap<String, LinkedHashMap<String, List<Opcion>>> grouped = new LinkedHashMap<String, LinkedHashMap<String, List<Opcion>>>();
    LinkedHashMap<String, String> moduloNombres = new LinkedHashMap<String, String>();

    for (Opcion opc : todasOpciones) {
        String modKey = opc.getSistemaCodigo();
        if (!moduloNombres.containsKey(modKey)) {
            moduloNombres.put(modKey, opc.getSistemaDescripcion());
            grouped.put(modKey, new LinkedHashMap<String, List<Opcion>>());
        }
        String subKey = getSubcategoria(opc.getCodigo());
        LinkedHashMap<String, List<Opcion>> subMap = grouped.get(modKey);
        if (!subMap.containsKey(subKey)) {
            subMap.put(subKey, new ArrayList<Opcion>());
        }
        subMap.get(subKey).add(opc);
    }

    final String[] SUB_ORDER  = {"GENERAL", "TABLAS_BASICAS", "PROCESOS", "REPORTES"};
    final String[] SUB_LABELS = {"General", "Tablas Básicas", "Procesos", "Reportes"};
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asignar Opciones al Perfil — Gestión de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        /* ── Selector de perfil ──────────────────────────────────────── */
        .perfil-selector {
            display: flex;
            align-items: center;
            gap: 14px;
            flex-wrap: wrap;
            padding: 16px 18px;
            border: 2px solid var(--accent);
            border-radius: 10px;
            background: rgba(15,118,110,0.05);
            margin-bottom: 20px;
        }
        .perfil-selector label { font-size: 14px; font-weight: 900; white-space: nowrap; }
        .perfil-selector select { width: auto; min-width: 240px; }

        /* ── Cabecera de panel ────────────────────────────────────────── */
        .panel-heading-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 18px;
        }
        .panel-heading-row h2 { margin-bottom: 0; }
        .select-all-row {
            display: flex; gap: 8px; align-items: center; flex-wrap: wrap;
        }
        .select-all-row button { min-height: 32px; padding: 5px 12px; font-size: 12px; }

        /* ── Módulo colapsable ────────────────────────────────────────── */
        .mod-block {
            border: 1px solid var(--line);
            border-radius: 10px;
            overflow: hidden;
            background: var(--surface);
            box-shadow: var(--shadow-soft);
            margin-bottom: 10px;
        }
        .mod-block-header {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 18px;
            background: var(--surface-soft);
            cursor: pointer;
            user-select: none;
            border-bottom: 1px solid var(--line);
            transition: background 0.18s;
        }
        .mod-block-header:hover { background: rgba(15,118,110,0.06); }
        .mod-block-num {
            display: grid;
            place-items: center;
            width: 28px; height: 28px;
            border-radius: 50%;
            background: var(--ink);
            color: #fff;
            font-size: 13px;
            font-weight: 900;
            flex: 0 0 auto;
        }
        .mod-block-name {
            flex: 1;
            font-size: 15px;
            font-weight: 900;
            color: var(--ink);
        }
        .mod-block-counter {
            display: inline-flex;
            align-items: center;
            padding: 3px 11px;
            border-radius: 999px;
            background: rgba(15,118,110,0.12);
            color: var(--accent);
            font-size: 11px;
            font-weight: 900;
            min-width: 44px;
            justify-content: center;
        }
        .mod-block-arrow {
            transition: transform 0.25s;
            color: var(--muted);
            flex: 0 0 auto;
        }
        .mod-block.mod-collapsed .mod-block-arrow { transform: rotate(-90deg); }
        .mod-block-body {
            padding: 10px;
            display: grid;
            gap: 6px;
        }
        .mod-block.mod-collapsed .mod-block-body { display: none; }

        /* ── Sub-sección colapsable ──────────────────────────────────── */
        .sub-block {
            border: 1px solid var(--line);
            border-radius: 8px;
            overflow: hidden;
            background: var(--surface);
        }
        .sub-block-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 8px 14px;
            background: rgba(23,32,51,0.03);
            cursor: pointer;
            user-select: none;
            transition: background 0.15s;
        }
        .sub-block-header:hover { background: rgba(15,118,110,0.06); }
        .sub-block-title {
            font-size: 11px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0.07em;
            color: var(--muted);
        }
        .sub-block-arrow {
            transition: transform 0.2s;
            color: var(--muted);
        }
        .sub-block.sub-collapsed .sub-block-arrow { transform: rotate(-90deg); }
        .sub-block-body {
            padding: 8px;
            display: grid;
            gap: 6px;
        }
        .sub-block.sub-collapsed .sub-block-body { display: none; }

        /* ── Ítem de opción ──────────────────────────────────────────── */
        .opc-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 9px 10px;
            border: 1px solid transparent;
            border-radius: 8px;
            background: var(--surface-soft);
            cursor: pointer;
            transition: all 0.15s;
        }
        .opc-item:hover { border-color: var(--accent); background: rgba(15,118,110,0.05); }
        .opc-item input[type="checkbox"] {
            width: 16px; height: 16px;
            min-height: unset;
            accent-color: var(--accent);
            cursor: pointer;
            flex: 0 0 auto;
        }
        .opc-item.checked {
            border-color: var(--accent);
            background: rgba(15,118,110,0.08);
        }
        .opc-code {
            font-size: 10px; font-weight: 900;
            color: var(--muted); text-transform: uppercase;
            display: block;
        }
        .opc-desc {
            font-size: 13px; font-weight: 700;
            color: var(--ink); display: block;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>Procesos de Seguridad</p>
            <h1>Asignar Opciones al Perfil</h1>
            <p>Selecciona qu&eacute; pantallas y m&oacute;dulos puede ver cada perfil.</p>
        </section>

        <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
            <div class="alert success"><%= h(mensaje) %></div>
        <% } %>
        <% if (error != null && !error.trim().isEmpty()) { %>
            <div class="alert error"><%= h(error) %></div>
        <% } %>

        <!-- Instrucciones paso a paso -->
        <div class="how-it-works" style="margin-bottom:20px">
            <div class="how-step">
                <span class="how-step-num" style="background:var(--accent)">1</span>
                <div class="how-step-text">
                    <strong>Selecciona el perfil</strong>
                    <span>Elige el perfil al que quieres asignar permisos de men&uacute;.</span>
                </div>
            </div>
            <div class="how-step">
                <span class="how-step-num" style="background:var(--accent)">2</span>
                <div class="how-step-text">
                    <strong>Marca las opciones</strong>
                    <span>Activa o desactiva las pantallas que este perfil puede ver.</span>
                </div>
            </div>
            <div class="how-step">
                <span class="how-step-num" style="background:var(--accent)">3</span>
                <div class="how-step-text">
                    <strong>Guarda los cambios</strong>
                    <span>El men&uacute; se actualiza inmediatamente para los usuarios con ese perfil.</span>
                </div>
            </div>
        </div>

        <!-- Paso 1: Selector de perfil (GET) -->
        <form method="GET" action="<%= ctx %>/admin/asignar-opciones" id="formPerfil">
            <div class="perfil-selector">
                <label for="perfilCodigo">Paso 1 &mdash; Selecciona el perfil:</label>
                <select id="perfilCodigo" name="perfilCodigo"
                        onchange="document.getElementById('formPerfil').submit()">
                    <option value="">— Seleccionar perfil —</option>
                    <% for (String[] p : perfiles) { %>
                        <option value="<%= h(p[0]) %>"
                            <%= perfilSeleccionado.equals(p[0]) ? "selected" : "" %>>
                            <%= h(p[0]) %> &mdash; <%= h(p[1]) %>
                        </option>
                    <% } %>
                </select>
                <% if (!perfilSeleccionado.isEmpty()) { %>
                    <span class="status">Editando</span>
                <% } %>
            </div>
        </form>

        <% if (perfilCargado) { %>
        <!-- Paso 2: POST guardar opciones -->
        <form method="POST" action="<%= ctx %>/admin/asignar-opciones" id="formOpciones">
            <input type="hidden" name="perfilCodigo" value="<%= h(perfilSeleccionado) %>">

            <section class="panel">
                <div class="panel-heading-row">
                    <h2>Paso 2 &mdash; Opciones para <code style="font-size:14px;background:rgba(15,118,110,0.1);color:var(--accent);padding:2px 8px;border-radius:6px"><%= h(perfilSeleccionado) %></code></h2>
                    <div class="select-all-row">
                        <button type="button" class="btn ghost" onclick="toggleTodas(true)">Seleccionar todo</button>
                        <button type="button" class="btn ghost" onclick="toggleTodas(false)">Deseleccionar todo</button>
                    </div>
                </div>

                <!-- Módulos jerárquicos -->
                <div id="modulosContainer">
                <%
                    int modIdx = 0;
                    for (Map.Entry<String, LinkedHashMap<String, List<Opcion>>> modEntry : grouped.entrySet()) {
                        String modKey   = modEntry.getKey();
                        String modNombre = getNombreModulo(modKey, moduloNombres.get(modKey));
                        LinkedHashMap<String, List<Opcion>> subSecs = modEntry.getValue();
                        String modId = "mod-" + safeId(modKey);

                        // Contar total y marcadas
                        int modTotal = 0, modChecked = 0;
                        for (List<Opcion> lst : subSecs.values()) {
                            for (Opcion o : lst) {
                                modTotal++;
                                if (codigosAsignados.contains(o.getCodigo())) modChecked++;
                            }
                        }
                        boolean soloGeneral = subSecs.size() == 1 && subSecs.containsKey("GENERAL");
                        modIdx++;
                %>
                <div class="mod-block" id="<%= h(modId) %>">
                    <div class="mod-block-header" onclick="toggleMod('<%= h(modId) %>')">
                        <span class="mod-block-num"><%= modIdx %></span>
                        <span class="mod-block-name"><%= h(modNombre) %></span>
                        <span class="mod-block-counter" id="cnt-<%= h(modId) %>"><%= modChecked %>/<%= modTotal %></span>
                        <svg class="mod-block-arrow" width="14" height="14" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                            <polyline points="6 9 12 15 18 9"/>
                        </svg>
                    </div>
                    <div class="mod-block-body" id="<%= h(modId) %>-body">
                    <%
                        if (soloGeneral) {
                            // Módulo con solo opciones generales: mostrar directo sin sub-cabecera
                            List<Opcion> gList = subSecs.get("GENERAL");
                            for (Opcion opc : gList) {
                                boolean marcada = codigosAsignados.contains(opc.getCodigo());
                    %>
                        <label class="opc-item <%= marcada ? "checked" : "" %>"
                               onclick="toggleItem(this, '<%= h(modId) %>')">
                            <input type="checkbox" name="opcionesSeleccionadas"
                                   value="<%= h(opc.getCodigo()) %>"
                                   <%= marcada ? "checked" : "" %>>
                            <span>
                                <span class="opc-code"><%= h(opc.getCodigo()) %></span>
                                <span class="opc-desc"><%= h(opc.getDescripcion()) %></span>
                            </span>
                        </label>
                    <%
                            }
                        } else {
                            // Módulo con sub-secciones colapsables
                            for (int si = 0; si < SUB_ORDER.length; si++) {
                                String subKey   = SUB_ORDER[si];
                                String subLabel = SUB_LABELS[si];
                                List<Opcion> subList = subSecs.get(subKey);
                                if (subList == null || subList.isEmpty()) continue;
                                String subId = "sub-" + safeId(modKey) + "-" + subKey.toLowerCase();
                    %>
                        <div class="sub-block" id="<%= h(subId) %>">
                            <div class="sub-block-header" onclick="toggleSub('<%= h(subId) %>')">
                                <span class="sub-block-title"><%= subLabel %></span>
                                <svg class="sub-block-arrow" width="12" height="12" viewBox="0 0 24 24" fill="none"
                                     stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                                    <polyline points="6 9 12 15 18 9"/>
                                </svg>
                            </div>
                            <div class="sub-block-body" id="<%= h(subId) %>-body">
                            <%
                                for (Opcion opc : subList) {
                                    boolean marcada = codigosAsignados.contains(opc.getCodigo());
                            %>
                                <label class="opc-item <%= marcada ? "checked" : "" %>"
                                       onclick="toggleItem(this, '<%= h(modId) %>')">
                                    <input type="checkbox" name="opcionesSeleccionadas"
                                           value="<%= h(opc.getCodigo()) %>"
                                           <%= marcada ? "checked" : "" %>>
                                    <span>
                                        <span class="opc-code"><%= h(opc.getCodigo()) %></span>
                                        <span class="opc-desc"><%= h(opc.getDescripcion()) %></span>
                                    </span>
                                </label>
                            <%
                                }
                            %>
                            </div>
                        </div>
                    <%
                            } // end for sub-sections
                        } // end if soloGeneral
                    %>
                    </div>
                </div>
                <%
                    } // end for modules
                %>
                </div><%-- #modulosContainer --%>

                <div class="button-row form-actions" style="margin-top:22px">
                    <a class="btn ghost" href="<%= ctx %>/admin/asignar-opciones">Cancelar</a>
                    <button type="submit" class="btn primary" style="min-width:220px">
                        Guardar opciones
                    </button>
                </div>
            </section>
        </form>
        <% } else if (!perfilSeleccionado.isEmpty()) { %>
            <div class="alert error">No se pudieron cargar las opciones. Intente de nuevo.</div>
        <% } else { %>
            <div class="placeholder-panel" style="text-align:center;padding:40px 24px">
                <strong>Selecciona un perfil</strong>
                <p>Elige un perfil en el selector de arriba para ver y editar sus opciones de men&uacute;.</p>
            </div>
        <% } %>
    </main>
</div>
<script>
    /* ── Módulo: colapsar/expandir ──────────────────────────────── */
    function toggleMod(modId) {
        const block = document.getElementById(modId);
        if (block) block.classList.toggle('mod-collapsed');
    }

    /* ── Sub-sección: colapsar/expandir ────────────────────────── */
    function toggleSub(subId) {
        const block = document.getElementById(subId);
        if (block) block.classList.toggle('sub-collapsed');
    }

    /* ── Checkbox: marcar y actualizar contador del módulo ──────── */
    function toggleItem(label, modId) {
        const cb = label.querySelector('input[type="checkbox"]');
        if (!cb) return;
        label.classList.toggle('checked', cb.checked);
        updateModCounter(modId);
    }

    /* ── Actualizar contador N/Total del módulo ─────────────────── */
    function updateModCounter(modId) {
        const body = document.getElementById(modId + '-body');
        const counter = document.getElementById('cnt-' + modId);
        if (!body || !counter) return;
        const all     = body.querySelectorAll('input[type="checkbox"]').length;
        const checked = body.querySelectorAll('input[type="checkbox"]:checked').length;
        counter.textContent = checked + '/' + all;
    }

    /* ── Seleccionar / deseleccionar todo ───────────────────────── */
    function toggleTodas(marcar) {
        document.querySelectorAll('#modulosContainer input[type="checkbox"]').forEach(function(cb) {
            cb.checked = marcar;
            var label = cb.closest('.opc-item');
            if (label) label.classList.toggle('checked', marcar);
        });
        document.querySelectorAll('.mod-block').forEach(function(block) {
            updateModCounter(block.id);
        });
    }
</script>
</body>
</html>
