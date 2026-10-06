<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page import="ec.edu.monster.modelo.DAODEPARTAMENTO"%>
<%@page import="ec.edu.monster.modelo.Departamento"%>
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
    // Acceso dinámico por perfil: requiere la opción 012 (Gestión de Proyectos).
    if (!SeguridadWeb.requiereOpcion(request, response, "012")) return;
    String ctx = request.getContextPath();

    // Departamentos para el selector del formulario (se cargan en el servidor).
    List<Departamento> departamentos = java.util.Collections.emptyList();
    try { departamentos = new DAODEPARTAMENTO().listar(); }
    catch (java.sql.SQLException ex) { /* el selector quedará vacío */ }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gesti&oacute;n de Proyectos — Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        /* ── Tarjetas de estadísticas ─────────────────────────────────── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4, minmax(0,1fr));
            gap: 14px;
            margin-bottom: 22px;
        }
        .stat-card {
            padding: 18px 20px;
            border: 1px solid var(--line);
            border-radius: 12px;
            background: var(--surface);
            box-shadow: var(--shadow-soft);
        }
        .stat-card .stat-label {
            font-size: 12px; font-weight: 800; text-transform: uppercase;
            letter-spacing: 0.05em; color: var(--muted); margin-bottom: 8px;
        }
        .stat-card .stat-value { font-size: 26px; font-weight: 900; color: var(--ink); }
        .stat-card.accent { border-top: 3px solid var(--accent); }
        .stat-card.brand  { border-top: 3px solid var(--brand); }

        /* ── Barra de herramientas ────────────────────────────────────── */
        .toolbar {
            display: flex; align-items: center; justify-content: space-between;
            gap: 14px; flex-wrap: wrap; margin-bottom: 18px;
        }
        .search-box {
            position: relative; flex: 1; min-width: 240px; max-width: 460px;
        }
        .search-box input {
            width: 100%; padding-left: 40px;
        }
        .search-box svg {
            position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
            color: var(--muted);
        }

        /* ── Grid de proyectos ────────────────────────────────────────── */
        .proj-grid { display: grid; gap: 16px; }
        .proj-card {
            display: grid;
            grid-template-columns: minmax(0,1.4fr) minmax(0,1fr) minmax(0,1fr) auto;
            gap: 18px; align-items: center;
            padding: 20px 22px;
            border: 1px solid var(--line);
            border-left: 4px solid var(--accent);
            border-radius: 12px;
            background: var(--surface);
            box-shadow: var(--shadow-soft);
        }
        .proj-card.excedido { border-left-color: var(--brand); }
        .proj-card.atrasado { border-left-color: var(--warning); }

        .proj-code {
            display: inline-block; padding: 3px 10px; border-radius: 999px;
            background: var(--surface-soft); border: 1px solid var(--line);
            font-size: 11px; font-weight: 900; letter-spacing: 0.05em;
            color: var(--muted); margin-bottom: 8px;
        }
        .proj-name { font-size: 17px; font-weight: 900; color: var(--ink); margin: 0 0 4px; }
        .proj-desc { font-size: 13px; color: var(--muted); margin: 0 0 8px; }
        .proj-team-badge {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 12px; font-weight: 700; color: var(--accent);
        }
        .proj-meta { font-size: 12px; color: var(--muted); margin-top: 4px; }
        .proj-meta b { color: var(--ink); font-weight: 800; }

        .metric-label { font-size: 11px; font-weight: 800; text-transform: uppercase;
            letter-spacing: 0.04em; color: var(--muted); margin-bottom: 3px; }
        .metric-money { font-size: 15px; font-weight: 900; color: var(--ink); }
        .metric-sub { font-size: 12px; margin-top: 3px; }
        .metric-sub.ok   { color: var(--accent); }
        .metric-sub.over { color: var(--brand); font-weight: 800; }

        .avance-track {
            height: 8px; border-radius: 999px; background: var(--line);
            overflow: hidden; margin: 6px 0 4px;
        }
        .avance-fill { height: 100%; background: var(--accent); border-radius: 999px; }
        .avance-pct { font-size: 15px; font-weight: 900; color: var(--ink); }
        .proj-dates { font-size: 12px; color: var(--muted); margin-top: 6px; }

        .estado-chip, .dias-chip {
            display: inline-flex; align-items: center; padding: 3px 10px;
            border-radius: 999px; font-size: 11px; font-weight: 800;
        }
        .estado-chip.PLANIFICADO { background:#f1f5f9; color:#475569; }
        .estado-chip.EN_PROGRESO { background:#e7f6ed; color:#0f5132; }
        .estado-chip.COMPLETADO  { background:#dbeafe; color:#1e40af; }
        .estado-chip.CANCELADO   { background:#fde8eb; color:#b42334; }
        .dias-chip.ok   { background:#e7f6ed; color:#0f5132; }
        .dias-chip.warn { background:#fff2c2; color:#704a05; }
        .dias-chip.over { background:#fde8eb; color:#b42334; }

        .proj-actions { display: flex; flex-direction: column; gap: 6px; }
        .icon-btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 38px; height: 38px; border: 1px solid var(--line);
            border-radius: 9px; background: var(--surface); color: var(--ink);
            cursor: pointer; transition: all 0.15s;
        }
        .icon-btn:hover { border-color: var(--accent); color: var(--accent); background: rgba(15,118,110,0.06); }
        .icon-btn.danger:hover { border-color: var(--brand); color: var(--brand); background: rgba(180,35,52,0.06); }

        .empty-state, .loading-state {
            text-align: center; padding: 48px 24px; color: var(--muted);
            border: 1px dashed var(--line); border-radius: 12px; background: var(--surface-soft);
        }
        .empty-state strong { display:block; font-size:16px; color:var(--ink); margin-bottom:6px; }

        /* ── Modal ────────────────────────────────────────────────────── */
        .modal-overlay {
            position: fixed; inset: 0; background: rgba(23,32,51,0.55);
            display: none; align-items: flex-start; justify-content: center;
            padding: 40px 16px; z-index: 100; overflow-y: auto;
        }
        .modal-overlay.open { display: flex; }
        .modal {
            width: min(680px, 100%); background: var(--surface);
            border-radius: 14px; box-shadow: var(--shadow); overflow: hidden;
        }
        .modal-header {
            display: flex; align-items: center; justify-content: space-between;
            padding: 18px 22px; border-bottom: 1px solid var(--line);
        }
        .modal-header h2 { margin: 0; font-size: 18px; }
        .modal-close {
            border: none; background: none; font-size: 24px; line-height: 1;
            color: var(--muted); cursor: pointer;
        }
        .modal-body { padding: 22px; }
        .modal-footer {
            display: flex; justify-content: flex-end; gap: 10px;
            padding: 16px 22px; border-top: 1px solid var(--line); background: var(--surface-soft);
        }
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        .form-grid .full { grid-column: 1 / -1; }
        .form-grid label { display:block; font-size:13px; font-weight:800; margin-bottom:5px; }
        .modal-error {
            display:none; margin-bottom:14px; padding:10px 14px; border-radius:8px;
            background:#fde8eb; color:#b42334; font-size:13px; font-weight:700;
        }
        .modal-error.show { display:block; }

        .emp-check-list {
            max-height: 340px; overflow-y: auto; display: grid; gap: 6px;
            border: 1px solid var(--line); border-radius: 10px; padding: 10px;
        }
        .emp-check {
            display:flex; align-items:center; gap:10px; padding:8px 10px;
            border:1px solid transparent; border-radius:8px; cursor:pointer;
            background: var(--surface-soft);
        }
        .emp-check:hover { border-color: var(--accent); }
        .emp-check input { width:16px; height:16px; min-height:unset; accent-color:var(--accent); }
        .emp-check .e-avatar { width:36px; height:36px; border-radius:50%; object-fit:cover; border:2px solid var(--line); flex:0 0 auto; }
        .emp-check .e-name { font-size:13px; font-weight:700; }
        .emp-check .e-meta { font-size:11px; color:var(--muted); }

        @media (max-width: 1000px) {
            .stats-row { grid-template-columns: repeat(2,1fr); }
            .proj-card { grid-template-columns: 1fr; }
            .proj-actions { flex-direction: row; }
            .form-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading" style="display:flex;justify-content:space-between;align-items:flex-end;gap:16px;flex-wrap:wrap">
            <div>
                <p>Planificaci&oacute;n y Control</p>
                <h1>Gesti&oacute;n de Proyectos</h1>
                <p>Controle responsables, presupuesto, gasto, tiempo y avance de cada proyecto.</p>
            </div>
            <button class="btn primary" id="btnNuevo" style="display:none" onclick="abrirNuevo()">+ Nuevo proyecto</button>
        </section>

        <div class="alert error" id="alertError" style="display:none"></div>
        <div class="alert success" id="alertOk" style="display:none"></div>

        <!-- Tarjetas de estadísticas -->
        <div class="stats-row" id="statsRow">
            <div class="stat-card"><div class="stat-label">Total de proyectos</div><div class="stat-value" id="stTotal">—</div></div>
            <div class="stat-card accent"><div class="stat-label">Presupuesto total</div><div class="stat-value" id="stPresup">—</div></div>
            <div class="stat-card brand"><div class="stat-label">Gasto acumulado</div><div class="stat-value" id="stGasto">—</div></div>
            <div class="stat-card"><div class="stat-label">Avance promedio</div><div class="stat-value" id="stAvance">—</div></div>
        </div>

        <!-- Barra de herramientas -->
        <div class="toolbar">
            <div class="search-box">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
                    <circle cx="11" cy="11" r="7"/><path d="m21 21-4.3-4.3"/>
                </svg>
                <input type="text" id="buscador" placeholder="Buscar por código, nombre o departamento" oninput="filtrar()">
            </div>
        </div>

        <!-- Grid de proyectos -->
        <div class="proj-grid" id="projGrid">
            <div class="loading-state">Cargando proyectos…</div>
        </div>
    </main>
</div>

<!-- ── Modal: crear / editar proyecto ──────────────────────────────────── -->
<div class="modal-overlay" id="modalProyecto">
    <div class="modal">
        <div class="modal-header">
            <h2 id="modalTitulo">Nuevo proyecto</h2>
            <button class="modal-close" onclick="cerrar('modalProyecto')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="modal-error" id="formError"></div>
            <form id="formProyecto" onsubmit="guardarProyecto(event)">
                <input type="hidden" id="fCodigo">
                <div class="form-grid">
                    <div class="full">
                        <label for="fNombre">Nombre del proyecto *</label>
                        <input type="text" id="fNombre" maxlength="100" required>
                    </div>
                    <div class="full">
                        <label for="fDescripcion">Descripci&oacute;n</label>
                        <input type="text" id="fDescripcion" maxlength="255">
                    </div>
                    <div>
                        <label for="fDepartamento">Departamento asignado</label>
                        <select id="fDepartamento">
                            <option value="">— Sin departamento —</option>
                            <% for (Departamento d : departamentos) { %>
                                <option value="<%= h(d.getCodigo()) %>"><%= h(d.getDescripcion()) %></option>
                            <% } %>
                        </select>
                    </div>
                    <div>
                        <label for="fRecursos">Recursos</label>
                        <input type="text" id="fRecursos" maxlength="255"
                               placeholder="Ej: 4 laptops, licencias, servidor">
                    </div>
                    <div>
                        <label for="fPresupuesto">Presupuesto (USD) *</label>
                        <input type="number" id="fPresupuesto" min="0" step="0.01" required>
                    </div>
                    <div>
                        <label for="fGasto">Gasto acumulado (USD) *</label>
                        <input type="number" id="fGasto" min="0" step="0.01" required>
                    </div>
                    <div>
                        <label for="fFechaInicio">Fecha de inicio</label>
                        <input type="date" id="fFechaInicio">
                    </div>
                    <div>
                        <label for="fFechaFin">Fecha de fin</label>
                        <input type="date" id="fFechaFin">
                    </div>
                    <div>
                        <label for="fAvance">Avance (%) *</label>
                        <input type="number" id="fAvance" min="0" max="100" required>
                    </div>
                    <div>
                        <label for="fEstado">Estado *</label>
                        <select id="fEstado">
                            <option value="PLANIFICADO">Planificado</option>
                            <option value="EN_PROGRESO">En progreso</option>
                            <option value="COMPLETADO">Completado</option>
                            <option value="CANCELADO">Cancelado</option>
                        </select>
                    </div>
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn ghost" onclick="cerrar('modalProyecto')">Cancelar</button>
            <button class="btn primary" onclick="document.getElementById('formProyecto').requestSubmit()">Guardar</button>
        </div>
    </div>
</div>

<!-- ── Modal: asignar personal ─────────────────────────────────────────── -->
<div class="modal-overlay" id="modalAsignar">
    <div class="modal">
        <div class="modal-header">
            <h2>Asignar personal — <span id="asignarNombre"></span></h2>
            <button class="modal-close" onclick="cerrar('modalAsignar')">&times;</button>
        </div>
        <div class="modal-body">
            <div class="modal-error" id="asignarError"></div>
            <p class="field-help" style="margin-bottom:12px">Selecciona los colaboradores que forman parte de este proyecto.</p>
            <div class="emp-check-list" id="empList">Cargando…</div>
        </div>
        <div class="modal-footer">
            <button class="btn ghost" onclick="cerrar('modalAsignar')">Cancelar</button>
            <button class="btn primary" id="btnGuardarAsignar" onclick="guardarAsignacion()">Guardar equipo</button>
        </div>
    </div>
</div>

<script>
const CTX = '<%= ctx %>';
const API = CTX + '/api/proyectos';
let PROYECTOS = [];
let PERMISOS = { puedeGestionar: false, puedeAsignar: false };
let asignarCodigoActual = null;

// ── Utilidades ──────────────────────────────────────────────────────────
function esc(s){ return (s==null?'':String(s)).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function money(n){ return 'USD ' + Number(n||0).toLocaleString('es-EC',{minimumFractionDigits:2,maximumFractionDigits:2}); }
function fotoUrl(f){ if(!f) return CTX + '/resources/foto.jpg'; return f.charAt(0)==='/' ? CTX + f : CTX + '/' + f; }
function mostrarError(msg){ const e=document.getElementById('alertError'); e.textContent=msg; e.style.display='block'; setTimeout(()=>e.style.display='none',6000); }
function mostrarOk(msg){ const e=document.getElementById('alertOk'); e.textContent=msg; e.style.display='block'; setTimeout(()=>e.style.display='none',5000); }

// ── Carga inicial ───────────────────────────────────────────────────────
async function cargar(){
    try{
        const r = await fetch(API, {headers:{'Accept':'application/json'}});
        const j = await r.json();
        if(!j.ok){ mostrarError(j.error||'No se pudo cargar.'); return; }
        PROYECTOS = j.data || [];
        PERMISOS = j.permisos || PERMISOS;
        pintarStats(j.stats);
        if(PERMISOS.puedeGestionar){ document.getElementById('btnNuevo').style.display='inline-flex'; }
        render();
    }catch(e){ mostrarError('Error de conexión con la API.'); }
}

function pintarStats(s){
    if(!s) return;
    document.getElementById('stTotal').textContent  = s.total;
    document.getElementById('stPresup').textContent = money(s.presupuestoTotal);
    document.getElementById('stGasto').textContent  = money(s.gastoAcumulado);
    document.getElementById('stAvance').textContent = (s.avancePromedio||0).toFixed(1) + '%';
}

// ── Render de tarjetas ──────────────────────────────────────────────────
function filtrar(){ render(); }

function render(){
    const q = document.getElementById('buscador').value.toLowerCase().trim();
    const grid = document.getElementById('projGrid');
    const lista = PROYECTOS.filter(p =>
        !q || (p.codigo+' '+p.nombre+' '+(p.departamentoDescri||'')).toLowerCase().includes(q));

    if(lista.length === 0){
        grid.innerHTML = '<div class="empty-state"><strong>Sin proyectos</strong>'
            + (q ? 'No hay resultados para tu búsqueda.' : 'Aún no hay proyectos registrados.')
            + '</div>';
        return;
    }
    grid.innerHTML = lista.map(cardHtml).join('');
}

function cardHtml(p){
    const clase = p.excedido ? 'excedido' : (p.atrasado ? 'atrasado' : '');
    let dias = '';
    if(p.diasRestantes !== null && p.diasRestantes !== undefined){
        if(p.diasRestantes < 0) dias = '<span class="dias-chip over">'+Math.abs(p.diasRestantes)+' días de atraso</span>';
        else if(p.diasRestantes <= 7) dias = '<span class="dias-chip warn">'+p.diasRestantes+' días restantes</span>';
        else dias = '<span class="dias-chip ok">'+p.diasRestantes+' días restantes</span>';
    }
    const rango = (p.fechaInicio||'—') + ' → ' + (p.fechaFin||'—');
    const subGasto = p.excedido
        ? '<div class="metric-sub over">Exceso: '+money(p.exceso)+'</div>'
        : '<div class="metric-sub ok">Disponible: '+money(p.disponible)+'</div>';

    let acciones = '';
    if(PERMISOS.puedeAsignar){
        acciones += '<button class="icon-btn" title="Asignar personal" onclick="abrirAsignar(\''+p.codigo+'\')">'
            + '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg></button>';
    }
    if(PERMISOS.puedeGestionar){
        acciones += '<button class="icon-btn" title="Editar" onclick="abrirEditar(\''+p.codigo+'\')">'
            + '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg></button>';
        acciones += '<button class="icon-btn danger" title="Eliminar" onclick="eliminar(\''+p.codigo+'\')">'
            + '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m2 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/></svg></button>';
    }

    return '<div class="proj-card '+clase+'">'
        + '<div>'
            + '<span class="proj-code">'+esc(p.codigo)+'</span>'
            + '<h3 class="proj-name">'+esc(p.nombre)+'</h3>'
            + (p.descripcion ? '<p class="proj-desc">'+esc(p.descripcion)+'</p>' : '')
            + '<span class="proj-team-badge">'
                + '<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/></svg>'
                + p.totalEmpleados + ' persona(s) involucrada(s)'
            + '</span>'
            + (p.departamentoDescri ? '<div class="proj-meta"><b>Departamento:</b> '+esc(p.departamentoDescri)+'</div>' : '')
            + (p.recursos ? '<div class="proj-meta"><b>Recursos:</b> '+esc(p.recursos)+'</div>' : '')
        + '</div>'
        + '<div>'
            + '<div class="metric-label">Presupuesto / Gasto</div>'
            + '<div class="metric-money">'+money(p.presupuesto)+' / '+money(p.gasto)+'</div>'
            + subGasto
        + '</div>'
        + '<div>'
            + '<div class="metric-label">Avance y tiempo</div>'
            + '<div class="avance-pct">'+p.avance+'%</div>'
            + '<div class="avance-track"><div class="avance-fill" style="width:'+p.avance+'%'+(p.excedido?';background:var(--brand)':'')+'"></div></div>'
            + '<div class="proj-dates">'+esc(rango)+'</div>'
            + '<div style="margin-top:6px;display:flex;gap:6px;flex-wrap:wrap">'
                + '<span class="estado-chip '+esc(p.estado)+'">'+esc(p.estadoLabel)+'</span>' + dias
            + '</div>'
        + '</div>'
        + '<div class="proj-actions">'+ (acciones || '<span class="field-help">Solo lectura</span>') +'</div>'
    + '</div>';
}

// ── Crear / editar ──────────────────────────────────────────────────────
function abrirNuevo(){
    document.getElementById('modalTitulo').textContent = 'Nuevo proyecto';
    document.getElementById('formProyecto').reset();
    document.getElementById('fCodigo').value = '';
    document.getElementById('formError').classList.remove('show');
    abrir('modalProyecto');
}
function abrirEditar(codigo){
    const p = PROYECTOS.find(x=>x.codigo===codigo);
    if(!p) return;
    document.getElementById('modalTitulo').textContent = 'Editar proyecto ' + p.codigo;
    document.getElementById('fCodigo').value = p.codigo;
    document.getElementById('fNombre').value = p.nombre || '';
    document.getElementById('fDescripcion').value = p.descripcion || '';
    document.getElementById('fDepartamento').value = p.departamento || '';
    document.getElementById('fRecursos').value = p.recursos || '';
    document.getElementById('fPresupuesto').value = p.presupuesto;
    document.getElementById('fGasto').value = p.gasto;
    document.getElementById('fFechaInicio').value = p.fechaInicio || '';
    document.getElementById('fFechaFin').value = p.fechaFin || '';
    document.getElementById('fAvance').value = p.avance;
    document.getElementById('fEstado').value = p.estado;
    document.getElementById('formError').classList.remove('show');
    abrir('modalProyecto');
}

async function guardarProyecto(ev){
    ev.preventDefault();
    const codigo = document.getElementById('fCodigo').value;
    const body = new URLSearchParams();
    body.set('nombre', document.getElementById('fNombre').value);
    body.set('descripcion', document.getElementById('fDescripcion').value);
    body.set('departamento', document.getElementById('fDepartamento').value);
    body.set('recursos', document.getElementById('fRecursos').value);
    body.set('presupuesto', document.getElementById('fPresupuesto').value);
    body.set('gasto', document.getElementById('fGasto').value);
    body.set('fechaInicio', document.getElementById('fFechaInicio').value);
    body.set('fechaFin', document.getElementById('fFechaFin').value);
    body.set('avance', document.getElementById('fAvance').value);
    body.set('estado', document.getElementById('fEstado').value);

    // Se usa POST siempre (crear y editar): los servlets no parsean el cuerpo en PUT.
    const url = codigo ? (API + '/' + codigo) : API;
    try{
        const r = await fetch(url, {method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'}, body});
        const j = await r.json();
        if(!j.ok){ const fe=document.getElementById('formError'); fe.textContent=j.error; fe.classList.add('show'); return; }
        cerrar('modalProyecto');
        mostrarOk(j.mensaje || 'Guardado.');
        cargar();
    }catch(e){ const fe=document.getElementById('formError'); fe.textContent='Error de conexión.'; fe.classList.add('show'); }
}

async function eliminar(codigo){
    const p = PROYECTOS.find(x=>x.codigo===codigo);
    if(!confirm('¿Eliminar el proyecto "'+(p?p.nombre:codigo)+'"? Esta acción no se puede deshacer.')) return;
    try{
        const r = await fetch(API + '/' + codigo, {method:'DELETE'});
        const j = await r.json();
        if(!j.ok){ mostrarError(j.error); return; }
        mostrarOk(j.mensaje || 'Proyecto eliminado.');
        cargar();
    }catch(e){ mostrarError('Error de conexión.'); }
}

// ── Asignar personal ────────────────────────────────────────────────────
async function abrirAsignar(codigo){
    const p = PROYECTOS.find(x=>x.codigo===codigo);
    asignarCodigoActual = codigo;
    document.getElementById('asignarNombre').textContent = p ? p.nombre : codigo;
    document.getElementById('asignarError').classList.remove('show');
    document.getElementById('empList').innerHTML = 'Cargando…';
    abrir('modalAsignar');
    try{
        const [rEmp, rPro] = await Promise.all([
            fetch(API + '/empleados'),
            fetch(API + '/' + codigo)
        ]);
        const jEmp = await rEmp.json();
        const jPro = await rPro.json();
        if(!jEmp.ok || !jPro.ok){ document.getElementById('empList').textContent = 'No se pudo cargar.'; return; }
        const asignados = new Set(jPro.data.equipo || []);
        document.getElementById('empList').innerHTML = jEmp.data.map(e =>
            '<label class="emp-check">'
            + '<input type="checkbox" value="'+esc(e.codigo)+'" '+(asignados.has(e.codigo)?'checked':'')+'>'
            + '<img class="e-avatar" src="'+fotoUrl(e.foto)+'" alt="" onerror="this.src=\''+CTX+'/resources/foto.jpg\'">'
            + '<span><span class="e-name">'+esc(e.nombre)+'</span><br><span class="e-meta">'+esc(e.codigo)+(e.cargo?' · '+esc(e.cargo):'')+'</span></span>'
            + '</label>').join('');
    }catch(e){ document.getElementById('empList').textContent = 'Error de conexión.'; }
}

async function guardarAsignacion(){
    const seleccion = [...document.querySelectorAll('#empList input:checked')].map(c=>c.value);
    const body = new URLSearchParams();
    seleccion.forEach(c => body.append('empleados', c));
    try{
        const r = await fetch(API + '/' + asignarCodigoActual + '/asignar', {
            method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'}, body});
        const j = await r.json();
        if(!j.ok){ const ae=document.getElementById('asignarError'); ae.textContent=j.error; ae.classList.add('show'); return; }
        cerrar('modalAsignar');
        mostrarOk(j.mensaje || 'Equipo actualizado.');
        cargar();
    }catch(e){ const ae=document.getElementById('asignarError'); ae.textContent='Error de conexión.'; ae.classList.add('show'); }
}

// ── Modales ─────────────────────────────────────────────────────────────
function abrir(id){ document.getElementById(id).classList.add('open'); }
function cerrar(id){ document.getElementById(id).classList.remove('open'); }
document.querySelectorAll('.modal-overlay').forEach(ov => ov.addEventListener('click', e => { if(e.target===ov) ov.classList.remove('open'); }));

cargar();
</script>
</body>
</html>
