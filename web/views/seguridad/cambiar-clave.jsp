<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
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
    if (!SeguridadWeb.requiereSesion(request, response)) return;
    Usuario usuarioSesion = SeguridadWeb.usuarioSesion(request);
    String ctx    = request.getContextPath();
    String error  = (String) request.getAttribute("error");
    String mensaje = (String) request.getAttribute("mensaje");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cambiar Contrase&ntilde;a — Gesti&oacute;n de Proyectos Monster</title>
    <link rel="stylesheet" href="<%= ctx %>/estilos.css">
    <style>
        .clave-card {
            max-width: 520px;
            margin: 0 auto;
        }
        .policy-list {
            list-style: none;
            margin: 0; padding: 0;
            display: grid; gap: 5px;
        }
        .policy-item {
            display: flex; align-items: center; gap: 8px;
            font-size: 12px; color: var(--muted);
        }
        .policy-item .pi-icon {
            display: inline-flex; align-items: center; justify-content: center;
            width: 18px; height: 18px; border-radius: 50%;
            background: #e2e8f0; color: #94a3b8;
            font-size: 10px; font-weight: 900; flex: 0 0 auto;
            transition: background 0.2s, color 0.2s;
        }
        .policy-item.ok .pi-icon { background: #d1fae5; color: #065f46; }
        .policy-item.fail .pi-icon { background: #fee2e2; color: #991b1b; }

        .strength-bar {
            height: 6px; border-radius: 4px;
            background: #e2e8f0; margin-top: 6px; overflow: hidden;
        }
        .strength-fill {
            height: 100%; border-radius: 4px;
            transition: width 0.3s, background-color 0.3s;
        }
        .strength-label { font-size: 12px; font-weight: 700; margin-top: 4px; }

        .input-reveal { position: relative; }
        .input-reveal input { padding-right: 44px; }
        .reveal-btn {
            position: absolute; right: 0; top: 0; bottom: 0;
            width: 42px; border: none; background: transparent;
            cursor: pointer; color: var(--muted); font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 0 8px 8px 0;
            transition: color 0.2s;
        }
        .reveal-btn:hover { color: var(--accent); }

        .match-indicator {
            font-size: 12px; font-weight: 700; margin-top: 4px;
        }
        .divider-section {
            border-top: 1px solid var(--line);
            margin: 18px 0 16px;
            padding-top: 16px;
        }
    </style>
</head>
<body>
<div class="app-shell">
    <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
    <main class="main-area">
        <section class="page-heading">
            <p>Procesos de Seguridad</p>
            <h1>Cambiar Contrase&ntilde;a</h1>
            <p>Actualice su contrase&ntilde;a de acceso. Deber&aacute; volver a iniciar sesi&oacute;n tras el cambio.</p>
        </section>

        <div class="clave-card">
            <% if (mensaje != null && !mensaje.trim().isEmpty()) { %>
                <div class="alert success"><%= h(mensaje) %></div>
            <% } %>
            <% if (error != null && !error.trim().isEmpty()) { %>
                <div class="alert error"><%= h(error) %></div>
            <% } %>

            <section class="panel">
                <!-- Info del usuario -->
                <div class="sidebar-user" style="margin-bottom:20px">
                    <span>Modificando contrase&ntilde;a de</span>
                    <strong><%= h(usuarioSesion.getNombreEmpleado()) %></strong>
                </div>

                <form action="<%= ctx %>/seguridad/cambiar-clave" method="POST"
                      class="stack-form" accept-charset="UTF-8" id="formClave"
                      onsubmit="return validarEnvio()">

                    <!-- Contraseña actual -->
                    <label for="claveActual">Contrase&ntilde;a actual</label>
                    <div class="input-reveal">
                        <input id="claveActual" name="claveActual" type="password"
                               required autocomplete="current-password"
                               placeholder="Su contraseña actual">
                        <button type="button" class="reveal-btn"
                                onclick="toggleVer('claveActual',this)" title="Ver/ocultar">&#128065;</button>
                    </div>

                    <div class="divider-section"></div>

                    <!-- Nueva contraseña -->
                    <label for="nuevaClave">Nueva contrase&ntilde;a</label>
                    <div class="input-reveal">
                        <input id="nuevaClave" name="nuevaClave" type="password"
                               required minlength="9" autocomplete="new-password"
                               placeholder="M&iacute;n. 9 chars, 1 may&uacute;scula, 1 n&uacute;mero"
                               oninput="evaluarFuerza(this.value); evaluarCoincidencia()">
                        <button type="button" class="reveal-btn"
                                onclick="toggleVer('nuevaClave',this)" title="Ver/ocultar">&#128065;</button>
                    </div>
                    <div class="strength-bar"><div id="strengthFill" class="strength-fill" style="width:0"></div></div>
                    <span id="strengthLabel" class="strength-label muted">Ingrese una contrase&ntilde;a</span>

                    <!-- Política visual -->
                    <ul class="policy-list" id="policyList" style="margin-top:6px">
                        <li class="policy-item" id="pi-len">
                            <span class="pi-icon">&#10003;</span>
                            M&iacute;nimo 9 caracteres
                        </li>
                        <li class="policy-item" id="pi-upper">
                            <span class="pi-icon">&#10003;</span>
                            Al menos una may&uacute;scula (A-Z)
                        </li>
                        <li class="policy-item" id="pi-num">
                            <span class="pi-icon">&#10003;</span>
                            Al menos un n&uacute;mero (0-9)
                        </li>
                        <li class="policy-item" id="pi-special">
                            <span class="pi-icon">&#10003;</span>
                            Car&aacute;cter especial recomendado
                        </li>
                    </ul>

                    <!-- Confirmar nueva contraseña -->
                    <label for="confirmarClave" style="margin-top:8px">Confirmar nueva contrase&ntilde;a</label>
                    <div class="input-reveal">
                        <input id="confirmarClave" name="confirmarClave" type="password"
                               required minlength="9" autocomplete="new-password"
                               placeholder="Repita la nueva contrase&ntilde;a"
                               oninput="evaluarCoincidencia()">
                        <button type="button" class="reveal-btn"
                                onclick="toggleVer('confirmarClave',this)" title="Ver/ocultar">&#128065;</button>
                    </div>
                    <div id="matchLabel" class="match-indicator muted"></div>

                    <p class="field-help" style="margin-top:4px">
                        Tras guardar ser&aacute; redirigido al inicio de sesi&oacute;n.
                    </p>

                    <div class="button-row form-actions">
                        <a class="btn ghost"
                           href="<%= ctx + SeguridadWeb.rutaDashboard(usuarioSesion) %>">
                            Cancelar
                        </a>
                        <button type="submit" class="btn primary" id="btnGuardar" disabled>
                            Guardar nueva contrase&ntilde;a
                        </button>
                    </div>
                </form>
            </section>
        </div>
    </main>
</div>
<script>
    /* ── Ver / ocultar contraseña ─────────────────────────────────── */
    function toggleVer(id, btn) {
        const inp = document.getElementById(id);
        if (!inp) return;
        inp.type = inp.type === 'password' ? 'text' : 'password';
        btn.style.opacity = inp.type === 'text' ? '0.5' : '1';
    }

    /* ── Medidor de fortaleza ─────────────────────────────────────── */
    function evaluarFuerza(val) {
        const fill  = document.getElementById('strengthFill');
        const label = document.getElementById('strengthLabel');
        if (!fill || !label) return;

        const okLen     = val.length >= 9;
        const okUpper   = /[A-Z]/.test(val);
        const okNum     = /[0-9]/.test(val);
        const okSpecial = /[^A-Za-z0-9]/.test(val);
        const okLong    = val.length >= 14;

        // Actualizar ítems de política
        marcarPolitica('pi-len',     okLen);
        marcarPolitica('pi-upper',   okUpper);
        marcarPolitica('pi-num',     okNum);
        marcarPolitica('pi-special', okSpecial);

        let score = 0;
        if (okLen)     score++;
        if (okLong)    score++;
        if (okUpper)   score++;
        if (okNum)     score++;
        if (okSpecial) score++;

        const niveles = [
            { pct:'0%',   color:'#e2e8f0', txt:'Ingrese una contraseña' },
            { pct:'20%',  color:'#ef4444', txt:'Muy débil' },
            { pct:'40%',  color:'#f97316', txt:'Débil' },
            { pct:'60%',  color:'#eab308', txt:'Aceptable' },
            { pct:'80%',  color:'#22c55e', txt:'Fuerte' },
            { pct:'100%', color:'#10b981', txt:'Muy fuerte' }
        ];
        const n = niveles[val.length === 0 ? 0 : Math.min(score, 5)];
        fill.style.width = n.pct;
        fill.style.backgroundColor = n.color;
        label.textContent = n.txt;
        label.style.color = n.color === '#e2e8f0' ? '' : n.color;

        actualizarBoton();
    }

    function marcarPolitica(id, ok) {
        const li = document.getElementById(id);
        if (!li) return;
        li.classList.toggle('ok',   ok);
        li.classList.toggle('fail', !ok && li.classList.contains('ok') ? false : !ok);
        // simplificado: si hay valor
        const nueva = document.getElementById('nuevaClave');
        if (nueva && nueva.value.length > 0) {
            li.classList.toggle('fail', !ok);
        }
    }

    /* ── Verificar coincidencia ───────────────────────────────────── */
    function evaluarCoincidencia() {
        const a = document.getElementById('nuevaClave').value;
        const b = document.getElementById('confirmarClave').value;
        const lbl = document.getElementById('matchLabel');
        if (!lbl) return;
        if (b.length === 0) {
            lbl.textContent = '';
            lbl.style.color = '';
        } else if (a === b) {
            lbl.textContent = '✓ Las contraseñas coinciden';
            lbl.style.color = '#065f46';
        } else {
            lbl.textContent = '✗ No coinciden';
            lbl.style.color = '#991b1b';
        }
        actualizarBoton();
    }

    /* ── Habilitar botón solo si todo OK ─────────────────────────── */
    function actualizarBoton() {
        const btn  = document.getElementById('btnGuardar');
        const nue  = document.getElementById('nuevaClave').value;
        const conf = document.getElementById('confirmarClave').value;
        const actual = document.getElementById('claveActual').value;
        const valida = actual.length > 0
                    && nue.length >= 9
                    && /[A-Z]/.test(nue)
                    && /[0-9]/.test(nue)
                    && nue === conf;
        if (btn) btn.disabled = !valida;
    }

    /* ── Validación final antes del submit ───────────────────────── */
    function validarEnvio() {
        const nue  = document.getElementById('nuevaClave').value;
        const conf = document.getElementById('confirmarClave').value;
        if (nue !== conf) {
            alert('Las contraseñas no coinciden. Verifique e intente de nuevo.');
            return false;
        }
        return true;
    }

    document.getElementById('claveActual').addEventListener('input', actualizarBoton);
</script>
</body>
</html>
