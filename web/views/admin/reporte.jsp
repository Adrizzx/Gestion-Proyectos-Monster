<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Empleado"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Map"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%!
    private String h(String v) {
        if (v == null) return "";
        return v.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private String safe(String v) { return v == null ? "—" : v.trim().isEmpty() ? "—" : v; }
%>
<%
    if (!SeguridadWeb.requiereRol(request, response,
            Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH)) return;

    String ctx = request.getContextPath();
    String error = (String) request.getAttribute("error");
    String fechaGen   = (String)  request.getAttribute("fechaGen");
    String generadoPor = (String) request.getAttribute("generadoPor");
    Integer total     = (Integer) request.getAttribute("totalEmpleados");

    @SuppressWarnings("unchecked")
    List<Empleado> empleados = (List<Empleado>) request.getAttribute("empleados");
    @SuppressWarnings("unchecked")
    Map<String,Usuario> usuariosMap = (Map<String,Usuario>) request.getAttribute("usuariosMap");

    if (empleados   == null) empleados   = java.util.Collections.emptyList();
    if (usuariosMap == null) usuariosMap = java.util.Collections.emptyMap();
    if (total == null) total = 0;
    if (fechaGen == null) fechaGen = "—";
    if (generadoPor == null) generadoPor = "Administrador";

    int activos   = 0;
    int inactivos = 0;
    for (Usuario u : usuariosMap.values()) {
        if ("A".equals(u.getEstadoCodigo())) activos++; else inactivos++;
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Personal Activo — Gestión de Proyectos Monster</title>
    <style>
        /* ── Base ─────────────────────────────────────────────────── */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            font-size: 13px;
            color: #172033;
            background: #f4f7f8;
            overflow-x: hidden;
        }

        /* ── Barra de acciones (solo pantalla) ───────────────────── */
        .toolbar {
            position: sticky;
            top: 0;
            z-index: 10;
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 12px 32px;
            background: #22324a;
            color: #fff;
            box-shadow: 0 4px 16px rgba(0,0,0,.25);
        }
        .toolbar h2 { flex: 1; font-size: 15px; font-weight: 800; }
        .toolbar a, .toolbar button {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 8px 18px; border-radius: 7px; border: none;
            font: inherit; font-size: 13px; font-weight: 800;
            cursor: pointer; text-decoration: none;
        }
        .btn-print  { background: #b42334; color: #fff; }
        .btn-print:hover  { background: #8f1d2b; }
        .btn-back   { background: rgba(255,255,255,.12); color: #fff; }
        .btn-back:hover   { background: rgba(255,255,255,.22); }

        /* ── Página de reporte ───────────────────────────────────── */
        .report-page {
            width: 100%;
            max-width: 210mm;
            min-height: 297mm;
            margin: 24px auto;
            padding: 16mm 12mm;
            background: #fff;
            box-shadow: 0 8px 34px rgba(23,32,51,.14);
            box-sizing: border-box;
        }

        .table-wrapper {
            width: 100%;
            overflow-x: auto;
        }

        /* ── Encabezado ──────────────────────────────────────────── */
        .report-header {
            display: flex;
            align-items: center;
            gap: 18px;
            padding-bottom: 14px;
            border-bottom: 3px solid #b42334;
            margin-bottom: 14px;
        }
        .report-logo {
            width: 70px; height: 70px;
            object-fit: contain;
            border: 1px solid #e5edf2;
            border-radius: 8px;
            background: #f9fbfc;
            padding: 4px;
            flex: 0 0 auto;
        }
        .report-title-block { flex: 1; }
        .report-title-block h1 {
            font-size: 20px; font-weight: 900;
            color: #b42334; margin-bottom: 2px;
        }
        .report-title-block .subtitle {
            font-size: 12px; font-weight: 700;
            color: #22324a; margin-bottom: 6px;
        }
        .report-meta {
            display: flex; gap: 18px; flex-wrap: wrap;
            font-size: 11px; color: #657084;
        }
        .report-meta span strong { color: #22324a; }

        /* ── Estadísticas rápidas ────────────────────────────────── */
        .stat-row {
            display: flex; gap: 10px;
            margin-bottom: 14px;
        }
        .stat-box {
            flex: 1; padding: 10px 14px;
            border-radius: 8px; border: 1px solid #dce4ea;
            text-align: center;
        }
        .stat-box .num {
            display: block; font-size: 26px;
            font-weight: 900; line-height: 1;
            margin-bottom: 3px;
        }
        .stat-box .lbl {
            font-size: 10px; font-weight: 800;
            text-transform: uppercase; letter-spacing: .03em;
            color: #657084;
        }
        .stat-total  { background: #f0f4f8; }
        .stat-total .num  { color: #22324a; }
        .stat-activo { background: #e7f6ed; }
        .stat-activo .num { color: #0f766e; }
        .stat-inact  { background: #fde8eb; }
        .stat-inact .num  { color: #b42334; }

        /* ── Tabla ───────────────────────────────────────────────── */
        table {
            width: 100%; border-collapse: collapse;
            font-size: 11.5px;
        }
        thead tr th {
            background: #22324a; color: #fff;
            padding: 8px 10px;
            text-align: left;
            font-size: 10px; font-weight: 900;
            text-transform: uppercase; letter-spacing: .04em;
        }
        tbody tr:nth-child(even) { background: #f9fbfc; }
        tbody tr:hover { background: #f0f7f6; }
        tbody td {
            padding: 7px 10px;
            border-bottom: 1px solid #e5edf2;
            vertical-align: middle;
        }
        .td-foto img {
            width: 30px; height: 30px;
            border-radius: 50%; object-fit: cover;
            border: 1px solid #dce4ea;
            vertical-align: middle;
        }
        .td-code { font-weight: 900; color: #22324a; }
        .badge {
            display: inline-block; padding: 2px 8px;
            border-radius: 999px; font-size: 10px; font-weight: 800;
        }
        .badge-activo  { background: #e7f6ed; color: #0f5132; }
        .badge-inactivo{ background: #fde8eb; color: #7a1d27; }
        .badge-sinuser { background: #f1f5f9; color: #64748b; }
        .badge-rol {
            background: #eef3f6; color: #334155;
            font-size: 10px; font-weight: 700;
        }

        /* ── Pie de página ───────────────────────────────────────── */
        .report-footer {
            margin-top: 20px;
            padding-top: 10px;
            border-top: 1px solid #dce4ea;
            font-size: 10px; color: #94a3b8;
            text-align: center;
        }

        /* ── Media print ─────────────────────────────────────────── */
        @media print {
            body {
                background: #fff;
                font-size: 10px;
                overflow: visible;
            }

            .toolbar { display: none !important; }

            .table-wrapper { overflow: visible; }

            .report-page {
                width: 100%;
                max-width: 100%;
                margin: 0;
                padding: 6mm 8mm;
                box-shadow: none;
                min-height: auto;
            }

            .report-logo { width: 52px; height: 52px; }

            .report-title-block h1 { font-size: 15px; }

            .stat-row { gap: 6px; margin-bottom: 10px; }
            .stat-box {
                padding: 6px 8px;
                border: 1px solid #ccc !important;
            }
            .stat-box .num { font-size: 20px; }
            .stat-box .lbl { font-size: 8px; }

            table { font-size: 9px; }

            thead tr th {
                padding: 5px 6px;
                font-size: 8px;
            }

            tbody td { padding: 4px 6px; }

            .td-foto img { width: 22px; height: 22px; }

            .badge { padding: 1px 5px; font-size: 8px; }

            tbody tr:hover { background: inherit; }
            tbody tr { page-break-inside: avoid; }
            thead     { display: table-header-group; }
        }

        @page {
            size: A4 landscape;
            margin: 10mm 8mm;
        }
    </style>
</head>
<body>

    <!-- Barra de acciones: solo visible en pantalla -->
    <div class="toolbar">
        <h2>Reporte de Personal Activo y Roles</h2>
        <a class="btn-back" href="<%= ctx %>/admin/seguridad">← Volver</a>
        <button class="btn-print" onclick="window.print()">
            Imprimir / Guardar PDF
        </button>
    </div>

    <!-- Página del reporte -->
    <div class="report-page">

        <!-- Encabezado -->
        <div class="report-header">
            <img class="report-logo"
                 src="<%= ctx %>/resources/LOGO%20EMPRESA/monster.png"
                 alt="Monster"
                 onerror="this.style.display='none'">
            <div class="report-title-block">
                <h1>Reporte General de Personal Activo y Roles</h1>
                <div class="subtitle">Gestión de Proyectos Monster — Documento confidencial de uso interno</div>
                <div class="report-meta">
                    <span><strong>Fecha:</strong> <%= h(fechaGen) %></span>
                    <span><strong>Generado por:</strong> <%= h(generadoPor) %></span>
                    <span><strong>Total colaboradores:</strong> <%= total %></span>
                </div>
            </div>
        </div>

        <!-- Estadísticas rápidas -->
        <div class="stat-row">
            <div class="stat-box stat-total">
                <span class="num"><%= total %></span>
                <span class="lbl">Colaboradores</span>
            </div>
            <div class="stat-box stat-activo">
                <span class="num"><%= activos %></span>
                <span class="lbl">Usuarios activos</span>
            </div>
            <div class="stat-box stat-inact">
                <span class="num"><%= inactivos %></span>
                <span class="lbl">Usuarios inactivos</span>
            </div>
            <div class="stat-box stat-total">
                <span class="num"><%= total - usuariosMap.size() %></span>
                <span class="lbl">Sin usuario</span>
            </div>
        </div>

        <% if (error != null && !error.trim().isEmpty()) { %>
            <p style="color:#b42334;font-weight:800;margin-bottom:10px"><%= h(error) %></p>
        <% } %>

        <!-- Tabla principal -->
        <div class="table-wrapper">
        <table>
            <thead>
                <tr>
                    <th>#</th>
                    <th>Foto</th>
                    <th>Código</th>
                    <th>Cédula</th>
                    <th>Apellidos</th>
                    <th>Nombres</th>
                    <th>Departamento</th>
                    <th>Cargo</th>
                    <th>Rol del sistema</th>
                    <th>Estado</th>
                </tr>
            </thead>
            <tbody>
                <% if (empleados.isEmpty()) { %>
                    <tr>
                        <td colspan="10" style="text-align:center;padding:20px;color:#657084">
                            Sin colaboradores registrados.
                        </td>
                    </tr>
                <% } else {
                    int n = 0;
                    for (Empleado e : empleados) {
                        n++;
                        Usuario u = usuariosMap.get(e.getCodigo());
                        boolean tieneUsuario = (u != null);
                        boolean activo = tieneUsuario && "A".equals(u.getEstadoCodigo());
                        String rol    = tieneUsuario ? h(safe(u.getRolUsuario())) : "Sin usuario";
                        String estado = tieneUsuario ? h(safe(u.getEstadoDescripcion())) : "Sin usuario";
                        String badgeClase = !tieneUsuario ? "badge-sinuser"
                                          : activo ? "badge-activo" : "badge-inactivo";
                        String foto = (e.getFotoRuta() != null && !e.getFotoRuta().isEmpty())
                                      ? ctx + e.getFotoRuta() : ctx + "/resources/foto.jpg";
                %>
                <tr>
                    <td style="color:#94a3b8;font-weight:700"><%= n %></td>
                    <td class="td-foto">
                        <img src="<%= h(foto) %>"
                             alt="Foto"
                             onerror="this.src='<%= ctx %>/resources/foto.jpg'">
                    </td>
                    <td class="td-code"><%= h(safe(e.getCodigo())) %></td>
                    <td><%= h(safe(e.getCedula())) %></td>
                    <td><strong><%= h(safe(e.getApellido())) %></strong></td>
                    <td><%= h(safe(e.getNombre())) %></td>
                    <td><%= h(safe(e.getDepartamentoDescripcion())) %></td>
                    <td><%= h(safe(e.getCargoDescripcion())) %></td>
                    <td><span class="badge badge-rol"><%= rol %></span></td>
                    <td><span class="badge <%= badgeClase %>"><%= estado %></span></td>
                </tr>
                <% } } %>
            </tbody>
        </table>
        </div><!-- /table-wrapper -->

        <!-- Pie de página -->
        <div class="report-footer">
            Este documento es de uso interno y confidencial &nbsp;·&nbsp;
            Gestión de Proyectos Monster &nbsp;·&nbsp;
            Generado el <%= h(fechaGen) %>
        </div>

    </div><!-- /report-page -->

</body>
</html>
