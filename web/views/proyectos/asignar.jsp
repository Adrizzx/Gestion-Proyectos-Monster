<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Acceso dinámico por perfil: requiere la opción 013 (Asignación de Personal).
    if (!SeguridadWeb.requiereOpcion(request, response, "013")) return;
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asignaci&oacute;n de Personal — Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        .perfil-bar {
            display: flex; align-items: center; gap: 14px; flex-wrap: wrap;
            padding: 16px 18px; border: 2px solid var(--accent); border-radius: 10px;
            background: rgba(15,118,110,0.05); margin-bottom: 18px;
        }
        .perfil-bar label { font-size: 14px; font-weight: 900; white-space: nowrap; }
        .perfil-bar select { width: auto; min-width: 260px; }

        .proj-info {
            display: none; grid-template-columns: repeat(4, minmax(0,1fr)); gap: 12px;
            margin-bottom: 18px;
        }
        .proj-info.show { display: grid; }
        .info-card {
            padding: 14px 16px; border: 1px solid var(--line); border-radius: 10px;
            background: var(--surface); box-shadow: var(--shadow-soft);
        }
        .info-card .lbl { font-size: 11px; font-weight: 800; text-transform: uppercase;
            letter-spacing: 0.04em; color: var(--muted); margin-bottom: 5px; }
        .info-card .val { font-size: 16px; font-weight: 900; color: var(--ink); }

        .asig-search { margin-bottom: 10px; }
        .asig-search input { width: 100%; }
        .asig-toolbar { display: flex; justify-content: space-between; align-items: center;
            gap: 10px; flex-wrap: wrap; margin-bottom: 10px; }
        .asig-count { font-size: 13px; font-weight: 800; color: var(--accent); }

        .emp-list {
            max-height: 460px; overflow-y: auto; display: grid; gap: 6px;
            border: 1px solid var(--line); border-radius: 10px; padding: 10px;
        }
        .emp-row {
            display: flex; align-items: center; gap: 12px; padding: 10px 12px;
            border: 1px solid transparent; border-radius: 8px; cursor: pointer;
            background: var(--surface-soft); transition: all 0.15s;
        }
        .emp-row:hover { border-color: var(--accent); }
        .emp-row.on { border-color: var(--accent); background: rgba(15,118,110,0.08); }
        .emp-row input { width: 17px; height: 17px; min-height: unset; accent-color: var(--accent); }
        .emp-row .e-avatar { width: 42px; height: 42px; border-radius: 50%; object-fit: cover; border: 2px solid var(--line); flex: 0 0 auto; }
        .emp-row .e-name { font-size: 14px; font-weight: 700; }
        .emp-row .e-meta { font-size: 12px; color: var(--muted); }

        .placeholder-panel { text-align:center; padding:40px 24px; }
        .placeholder-panel strong { display:block; font-size:16px; margin-bottom:6px; }
        #panelAsig { display: none; }
        @media (max-width: 900px){ .proj-info.show { grid-template-columns: 1fr 1fr; } }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>M&oacute;dulo de Proyectos</p>
            <h1>Asignaci&oacute;n de Personal</h1>
            <p>Vincula colaboradores a cada proyecto. Selecciona un proyecto y marca su equipo.</p>
        </section>

        <div class="alert error" id="alertError" style="display:none"></div>
        <div class="alert success" id="alertOk" style="display:none"></div>

        <!-- Paso 1: seleccionar proyecto -->
        <div class="perfil-bar">
            <label for="selProyecto">Paso 1 &mdash; Proyecto:</label>
            <select id="selProyecto" onchange="cargarProyecto()">
                <option value="">— Seleccionar proyecto —</option>
            </select>
        </div>

        <!-- Info del proyecto -->
        <div class="proj-info" id="projInfo">
            <div class="info-card"><div class="lbl">Presupuesto</div><div class="val" id="iPresup">—</div></div>
            <div class="info-card"><div class="lbl">Gasto</div><div class="val" id="iGasto">—</div></div>
            <div class="info-card"><div class="lbl">Avance</div><div class="val" id="iAvance">—</div></div>
            <div class="info-card"><div class="lbl">Estado</div><div class="val" id="iEstado">—</div></div>
        </div>

        <!-- Paso 2: equipo -->
        <section class="panel" id="panelAsig">
            <div class="panel-heading-row">
                <h2>Paso 2 &mdash; Equipo del proyecto</h2>
                <div style="display:flex;gap:8px">
                    <button type="button" class="btn ghost" onclick="marcarTodos(true)">Marcar todos</button>
                    <button type="button" class="btn ghost" onclick="marcarTodos(false)">Desmarcar todos</button>
                </div>
            </div>
            <div class="asig-toolbar">
                <span class="asig-count" id="contador">0 colaborador(es) seleccionado(s)</span>
            </div>
            <div class="asig-search">
                <input type="text" id="buscador" placeholder="Buscar por nombre, código o cargo…" oninput="filtrar()">
            </div>
            <div class="emp-list" id="empList">Cargando…</div>
            <div class="button-row form-actions" style="margin-top:18px">
                <a class="btn ghost" href="<%= ctx %>/views/proyectos/gestion.jsp">Ir a Gesti&oacute;n de Proyectos</a>
                <button class="btn primary" style="min-width:200px" onclick="guardar()">Guardar equipo</button>
            </div>
        </section>

        <!-- Estado inicial -->
        <div class="panel placeholder-panel" id="panelVacio">
            <strong>Selecciona un proyecto</strong>
            <p>Elige un proyecto en el selector de arriba para asignar su equipo de colaboradores.</p>
        </div>
    </main>
</div>

<script>
const CTX = '<%= ctx %>';
const API = CTX + '/api/proyectos';
let EMPLEADOS = [];       // catálogo completo
let PROYECTOS = [];       // lista de proyectos
let codigoActual = null;

function esc(s){ return (s==null?'':String(s)).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
function money(n){ return 'USD ' + Number(n||0).toLocaleString('es-EC',{minimumFractionDigits:2,maximumFractionDigits:2}); }
function fotoUrl(f){ if(!f) return CTX + '/resources/foto.jpg'; return f.charAt(0)==='/' ? CTX + f : CTX + '/' + f; }
function mostrarError(m){ const e=document.getElementById('alertError'); e.textContent=m; e.style.display='block'; setTimeout(()=>e.style.display='none',6000); }
function mostrarOk(m){ const e=document.getElementById('alertOk'); e.textContent=m; e.style.display='block'; setTimeout(()=>e.style.display='none',5000); }

// ── Carga inicial: proyectos + catálogo de empleados ─────────────────────
async function init(){
    try{
        const [rPro, rEmp] = await Promise.all([ fetch(API), fetch(API + '/empleados') ]);
        const jPro = await rPro.json();
        const jEmp = await rEmp.json();
        if(!jPro.ok){ mostrarError(jPro.error||'No se pudo cargar proyectos.'); return; }
        if(!jEmp.ok){ mostrarError(jEmp.error||'No se pudo cargar colaboradores.'); return; }
        PROYECTOS = jPro.data || [];
        EMPLEADOS = jEmp.data || [];
        const sel = document.getElementById('selProyecto');
        sel.innerHTML = '<option value="">— Seleccionar proyecto —</option>'
            + PROYECTOS.map(p => '<option value="'+esc(p.codigo)+'">'+esc(p.codigo)+' — '+esc(p.nombre)+'</option>').join('');
    }catch(e){ mostrarError('Error de conexión con la API.'); }
}

// ── Al elegir un proyecto: cargar su equipo actual ───────────────────────
async function cargarProyecto(){
    const codigo = document.getElementById('selProyecto').value;
    codigoActual = codigo;
    if(!codigo){
        document.getElementById('panelAsig').style.display='none';
        document.getElementById('panelVacio').style.display='block';
        document.getElementById('projInfo').classList.remove('show');
        return;
    }
    try{
        const r = await fetch(API + '/' + codigo);
        const j = await r.json();
        if(!j.ok){ mostrarError(j.error); return; }
        const p = j.data;
        // Info
        document.getElementById('iPresup').textContent = money(p.presupuesto);
        document.getElementById('iGasto').textContent  = money(p.gasto);
        document.getElementById('iAvance').textContent = p.avance + '%';
        document.getElementById('iEstado').textContent = p.estadoLabel;
        document.getElementById('projInfo').classList.add('show');
        // Checklist
        const asignados = new Set(p.equipo || []);
        document.getElementById('empList').innerHTML = EMPLEADOS.map(e =>
            '<label class="emp-row '+(asignados.has(e.codigo)?'on':'')+'" data-buscar="'+esc((e.nombre+' '+e.codigo+' '+(e.cargo||'')).toLowerCase())+'">'
            + '<input type="checkbox" value="'+esc(e.codigo)+'" '+(asignados.has(e.codigo)?'checked':'')+' onchange="sync(this)">'
            + '<img class="e-avatar" src="'+fotoUrl(e.foto)+'" alt="" onerror="this.src=\''+CTX+'/resources/foto.jpg\'">'
            + '<span><span class="e-name">'+esc(e.nombre)+'</span><br>'
            + '<span class="e-meta">'+esc(e.codigo)+(e.cargo?' · '+esc(e.cargo):'')+(e.departamento?' · '+esc(e.departamento):'')+'</span></span>'
            + '</label>').join('');
        document.getElementById('panelVacio').style.display='none';
        document.getElementById('panelAsig').style.display='block';
        document.getElementById('buscador').value='';
        actualizarContador();
    }catch(e){ mostrarError('Error de conexión.'); }
}

function sync(cb){ cb.closest('.emp-row').classList.toggle('on', cb.checked); actualizarContador(); }

function marcarTodos(v){
    document.querySelectorAll('#empList .emp-row').forEach(row => {
        if(row.style.display === 'none') return;        // respeta el filtro
        const cb = row.querySelector('input'); cb.checked = v; row.classList.toggle('on', v);
    });
    actualizarContador();
}

function actualizarContador(){
    const n = document.querySelectorAll('#empList input:checked').length;
    document.getElementById('contador').textContent = n + ' colaborador(es) seleccionado(s)';
}

function filtrar(){
    const q = document.getElementById('buscador').value.toLowerCase().trim();
    document.querySelectorAll('#empList .emp-row').forEach(row => {
        row.style.display = (!q || row.dataset.buscar.includes(q)) ? '' : 'none';
    });
}

async function guardar(){
    if(!codigoActual){ mostrarError('Selecciona un proyecto.'); return; }
    const seleccion = [...document.querySelectorAll('#empList input:checked')].map(c=>c.value);
    const body = new URLSearchParams();
    seleccion.forEach(c => body.append('empleados', c));
    try{
        const r = await fetch(API + '/' + codigoActual + '/asignar', {
            method:'POST', headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'}, body});
        const j = await r.json();
        if(!j.ok){ mostrarError(j.error); return; }
        mostrarOk(j.mensaje || 'Equipo actualizado.');
    }catch(e){ mostrarError('Error de conexión.'); }
}

init();
</script>
</body>
</html>
