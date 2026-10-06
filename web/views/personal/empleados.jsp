<%@page import="ec.edu.monster.controlador.SeguridadWeb"%>
<%@page import="ec.edu.monster.modelo.Usuario"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH)) {
        return;
    }
    if (request.getAttribute("empleados") == null && request.getAttribute("modo") == null) {
        String query = request.getQueryString();
        request.getRequestDispatcher("/srvEmpleado" + (query == null || query.trim().isEmpty() ? "" : "?" + query))
                .forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Gesti&oacute;n de Personal - Gesti&oacute;n de Proyectos Monster</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/estilos.css">
        <style>
            .employee-master {
                position: sticky;
                top: 16px;
                z-index: 5;
                margin-bottom: 18px;
            }

            .employee-master-grid {
                display: grid;
                grid-template-columns: 144px minmax(0, 1fr);
                gap: 18px;
                align-items: center;
            }

            .photo-box {
                display: grid;
                gap: 10px;
                justify-items: center;
            }

            .photo-preview {
                width: 116px;
                height: 116px;
                border: 1px solid var(--line);
                border-radius: 8px;
                background: var(--surface-soft);
                object-fit: cover;
                box-shadow: var(--shadow-soft);
            }

            .photo-box input[type="file"] {
                min-height: auto;
                padding: 8px;
                font-size: 12px;
            }

            .identity-grid,
            .form-grid,
            .detail-form-grid {
                display: grid;
                grid-template-columns: repeat(4, minmax(0, 1fr));
                gap: 13px;
                align-items: end;
            }

            .identity-grid {
                grid-template-columns: 150px repeat(2, minmax(0, 1fr)) 140px;
            }

            .field-span-2 {
                grid-column: span 2;
            }

            .field-span-4 {
                grid-column: 1 / -1;
            }

            .wizard-stepper {
                display: grid;
                grid-template-columns: repeat(3, minmax(0, 1fr));
                gap: 10px;
                margin: 18px 0 16px;
            }

            .wizard-step {
                display: flex;
                align-items: center;
                justify-content: center;
                min-height: 38px;
                padding: 8px 12px;
                border: 1px solid var(--line);
                border-radius: 8px;
                color: #475569;
                background: var(--surface-soft);
                font-size: 13px;
                font-weight: 800;
                text-align: center;
            }

            .wizard-step.active {
                color: #ffffff;
                border-color: var(--accent);
                background: var(--accent);
                box-shadow: 0 8px 18px rgba(15, 118, 110, 0.18);
            }

            .wizard-step.done {
                color: #0f172a;
                border-color: #cbd5e1;
                background: #f8fafc;
            }

            .wizard-step-pane {
                display: none;
            }

            .wizard-step-pane.active {
                display: block;
            }

            .section-title {
                margin: 0 0 14px;
                font-size: 16px;
                font-weight: 900;
            }

            .subform {
                margin-bottom: 18px;
                padding: 16px;
                border: 1px solid var(--line);
                border-radius: 8px;
                background: var(--surface-soft);
            }

            .table-actions {
                display: flex;
                gap: 8px;
                align-items: center;
                justify-content: flex-end;
            }

            .nowrap {
                white-space: nowrap;
            }

            @media (max-width: 960px) {
                .employee-master {
                    position: static;
                }

                .employee-master-grid,
                .identity-grid,
                .form-grid,
                .detail-form-grid {
                    grid-template-columns: 1fr;
                }

                .wizard-stepper {
                    grid-template-columns: 1fr;
                }

                .field-span-2,
                .field-span-4 {
                    grid-column: auto;
                }
            }
        </style>
    </head>
    <body>
        <div class="app-shell">
            <%@ include file="/WEB-INF/jspf/sidebar.jspf" %>
            <main class="main-area">
                <section class="page-heading">
                    <p>Talento humano</p>
                    <h1>Gesti&oacute;n de Personal</h1>
                    <p>Administraci&oacute;n de colaboradores, formaci&oacute;n y cargas familiares.</p>
                </section>

                <c:if test="${not empty mensaje}">
                    <div class="alert success"><c:out value="${mensaje}"/></div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="alert error"><c:out value="${error}"/></div>
                </c:if>

                <%-- Contraseña temporal generada automáticamente — visible solo al crear --%>
                <c:if test="${not empty claveTemp}">
                    <div style="margin-bottom:16px;padding:16px 18px;border:2px solid #eab308;border-radius:10px;background:#fefce8">
                        <p style="margin:0 0 6px;font-weight:900;font-size:14px;color:#713f12">
                            Contraseña temporal de acceso asignada
                        </p>
                        <p style="margin:0 0 10px;font-size:12px;color:#92400e">
                            Informe esta contraseña al colaborador. Puede cambiarla luego desde <strong>Seguridad del Sistema &rarr; Gesti&oacute;n de Contrase&ntilde;as</strong>.
                        </p>
                        <div style="display:flex;align-items:center;gap:10px;flex-wrap:wrap">
                            <code id="claveTemp" style="font-size:16px;font-weight:900;padding:8px 14px;background:#fff;border:1px solid #eab308;border-radius:7px;letter-spacing:.05em;color:#1c1917">
                                <c:out value="${claveTemp}"/>
                            </code>
                            <button type="button"
                                    onclick="navigator.clipboard.writeText(document.getElementById('claveTemp').textContent.trim()).then(function(){this.textContent='Copiado';setTimeout(function(){document.querySelector('[onclick*=claveTemp]').textContent='Copiar'},2000)}.bind(this))"
                                    style="padding:7px 14px;border:1px solid #eab308;border-radius:7px;background:#fef08a;font-weight:800;font-size:13px;cursor:pointer">
                                Copiar
                            </button>
                        </div>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${modo == 'nuevo' or modo == 'editar'}">
                        <c:set var="pasoVisible" value="${empty pasoActual ? 'general' : pasoActual}" />
                        <c:set var="rutaFoto" value="${empty empleado.fotoRuta ? '/resources/foto.jpg' : empleado.fotoRuta}" />
                        <c:url value="${rutaFoto}" var="fotoEmpleadoUrl" />
                        <fmt:formatDate value="${empleado.fechaNacimiento}" pattern="yyyy-MM-dd" var="fechaNacValor" />
                        <fmt:formatDate value="${empleado.fechaSalida}" pattern="yyyy-MM-dd" var="fechaSalidaValor" />

                        <section class="panel employee-master">
                            <form id="formGeneral" action="${pageContext.request.contextPath}/admin/gestion-personal" method="post" enctype="multipart/form-data" accept-charset="UTF-8">
                                <input type="hidden" name="accion" value="${modo == 'nuevo' ? 'crearEmpleado' : 'actualizarGeneral'}">
                                <input type="hidden" name="fotoActual" value="${empleado.fotoRuta}">
                                <c:if test="${modo == 'editar'}">
                                    <input type="hidden" name="codigo" value="${empleado.codigo}">
                                </c:if>
                                <div class="employee-master-grid">
                                    <div class="photo-box">
                                        <img id="fotoPreview" class="photo-preview" src="${fotoEmpleadoUrl}" alt="Fotografía del colaborador">
                                        <input id="foto" name="foto" type="file" accept="image/*" <c:if test="${pasoVisible != 'general'}">disabled</c:if>>
                                    </div>
                                    <div class="identity-grid">
                                        <div>
                                            <label for="codigoVista">Código</label>
                                            <input id="codigoVista" type="text" value="${modo == 'nuevo' ? proximoCodigo : empleado.codigo}" readonly>
                                        </div>
                                        <div>
                                            <label for="nombre">Nombres</label>
                                            <input id="nombre" name="nombre" type="text" maxlength="50" value="${empleado.nombre}" <c:if test="${pasoVisible != 'general'}">readonly</c:if> required>
                                        </div>
                                        <div>
                                            <label for="apellido">Apellidos</label>
                                            <input id="apellido" name="apellido" type="text" maxlength="50" value="${empleado.apellido}" <c:if test="${pasoVisible != 'general'}">readonly</c:if> required>
                                        </div>
                                        <div>
                                            <label>Cargas</label>
                                            <input type="text" value="${empty empleado.cargosFamiliares ? 0 : empleado.cargosFamiliares}" readonly>
                                        </div>
                                    </div>
                                </div>

                                <div class="wizard-stepper">
                                    <span class="wizard-step ${pasoVisible == 'general' ? 'active' : 'done'}">1. Datos Generales</span>
                                    <span class="wizard-step ${pasoVisible == 'formacion' ? 'active' : (pasoVisible == 'familiares' ? 'done' : '')}">2. Formación</span>
                                    <span class="wizard-step ${pasoVisible == 'familiares' ? 'active' : ''}">3. Cargas Familiares</span>
                                </div>

                                <c:if test="${pasoVisible == 'general'}">
                                    <section class="wizard-step-pane active" id="step-general">
                                        <h2 class="section-title">Datos Generales</h2>
                                        <div class="form-grid">
                                            <div>
                                                <label for="cedula">Cédula</label>
                                                <input id="cedula" name="cedula" type="text" maxlength="10" value="${empleado.cedula}" required>
                                            </div>
                                            <div>
                                                <label for="sexo">Sexo</label>
                                                <select id="sexo" name="sexo" required>
                                                    <option value="">Seleccionar</option>
                                                    <c:forEach var="s" items="${listaSexos}">
                                                        <option value="${s.key}" ${empleado.sexoCodigo == s.key ? 'selected' : ''}><c:out value="${s.value}"/></option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div>
                                                <label for="estadoCivil">Estado Civil</label>
                                                <select id="estadoCivil" name="estadoCivil" required>
                                                    <option value="">Seleccionar</option>
                                                    <c:forEach var="ec" items="${listaEstados}">
                                                        <option value="${ec.key}" ${empleado.estadoCivilCodigo == ec.key ? 'selected' : ''}><c:out value="${ec.value}"/></option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div>
                                                <label for="cargo">Cargo</label>
                                                <select id="cargo" name="cargo" required>
                                                    <option value="">Seleccionar</option>
                                                    <c:forEach var="carg" items="${listaCargos}">
                                                        <option value="${carg.codigo}" data-departamento-codigo="${carg.departamentoCodigo}" data-departamento-descripcion="${carg.departamentoDescripcion}" ${empleado.cargoCodigo == carg.codigo ? 'selected' : ''}>
                                                            <c:out value="${carg.descripcion}"/> - <c:out value="${carg.departamentoDescripcion}"/>
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div>
                                                <label for="departamentoVista">Departamento</label>
                                                <input id="departamentoVista" type="text"
                                                       value="${not empty empleado.departamentoDescripcion
                                                               ? empleado.departamentoDescripcion
                                                               : empleado.departamentoCodigo}"
                                                       readonly placeholder="Se llena al seleccionar un cargo">
                                                <input id="departamento" name="departamento" type="hidden" value="${empleado.departamentoCodigo}">
                                            </div>
                                            <div>
                                                <label for="telefono">Teléfono</label>
                                                <input id="telefono" name="telefono" type="text" maxlength="15" value="${empleado.telefono}" required>
                                            </div>
                                            <div>
                                                <label for="email">Correo electrónico</label>
                                                <input id="email" name="email" type="email" maxlength="100" value="${empleado.email}" required>
                                            </div>
                                            <div>
                                                <label for="fechaNac">Fecha de nacimiento</label>
                                                <input id="fechaNac" name="fechaNac" type="date" value="${fechaNacValor}" required>
                                            </div>
                                            <div>
                                                <label for="fechaSalida">Fecha de salida</label>
                                                <input id="fechaSalida" name="fechaSalida" type="date" value="${empty fechaSalidaValor ? '2099-12-31' : fechaSalidaValor}" required>
                                            </div>
                                            <div class="field-span-2">
                                                <label for="direccion">Dirección</label>
                                                <input id="direccion" name="direccion" type="text" maxlength="200" value="${empleado.direccion}" required>
                                            </div>
                                        </div>
                                        <%-- Contraseña inicial: solo Admin al crear un empleado nuevo --%>
                                        <c:if test="${modo == 'nuevo' and sessionScope.usuarioSesion.rolUsuario == 'Administrador'}">
                                            <div class="field-span-4" style="margin-top:10px;padding:14px 16px;border:1px solid var(--line);border-radius:8px;background:var(--surface-soft)">
                                                <p style="margin-bottom:10px;font-weight:800;font-size:13px;color:var(--ink)">
                                                    Contraseña de acceso al sistema
                                                </p>
                                                <div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">
                                                    <div>
                                                        <label for="clave">Contraseña inicial *</label>
                                                        <input id="clave" name="clave" type="password"
                                                               minlength="9" autocomplete="new-password"
                                                               placeholder="Mín. 9 chars, 1 mayúscula, 1 número">
                                                        <p class="field-help">Mín. 9 caracteres, al menos 1 mayúscula y 1 número.</p>
                                                    </div>
                                                    <div>
                                                        <label for="confirmarClave">Confirmar contraseña *</label>
                                                        <input id="confirmarClave" name="confirmarClave" type="password"
                                                               minlength="9" autocomplete="new-password">
                                                    </div>
                                                </div>
                                                <p class="field-help" style="margin-top:6px">
                                                    Si deja los campos vacíos, se asignará una contraseña temporal automática que podrá cambiar después en <strong>Gestión de Contraseñas</strong>.
                                                </p>
                                            </div>
                                        </c:if>

                                        <c:if test="${modo == 'nuevo' and sessionScope.usuarioSesion.rolUsuario != 'Administrador'}">
                                            <div class="field-span-4" style="margin-top:10px;padding:10px 14px;border-radius:8px;background:#fff2c2;color:#704a05;font-size:12px;font-weight:700">
                                                Nota: El acceso al sistema lo asignar&aacute; el Administrador desde <em>Gesti&oacute;n de Contrase&ntilde;as</em>. Se generar&aacute; una contrase&ntilde;a temporal autom&aacute;ticamente al guardar.
                                            </div>
                                        </c:if>
                                        </div>
                                        <div class="button-row form-actions">
                                            <a class="btn ghost" href="${pageContext.request.contextPath}/admin/gestion-personal">Cancelar</a>
                                            <button class="btn primary" type="submit">Siguiente</button>
                                        </div>
                                    </section>
                                </c:if>
                            </form>
                        </section>

                        <c:if test="${modo == 'editar'}">
                            <section class="panel wizard-step-pane ${pasoVisible == 'formacion' ? 'active' : ''}" id="step-formacion">
                                <h2 class="section-title">Formación</h2>
                                <form action="${pageContext.request.contextPath}/admin/gestion-personal" method="post" class="subform" accept-charset="UTF-8">
                                    <input type="hidden" name="accion" value="agregarEducacion">
                                    <input type="hidden" name="codigo" value="${empleado.codigo}">
                                    <input type="hidden" name="paso" value="formacion">
                                    <div class="detail-form-grid">
                                        <div>
                                            <label for="titulo">Título</label>
                                            <select id="titulo" name="titulo" required>
                                                <option value="">Seleccionar</option>
                                                <c:forEach var="tituloCat" items="${listaTitulosEducacion}">
                                                    <option value="${tituloCat}"><c:out value="${tituloCat}"/></option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div>
                                            <label for="institucion">Institución</label>
                                            <select id="institucion" name="institucion" required>
                                                <option value="">Seleccionar</option>
                                                <c:forEach var="institucionCat" items="${listaInstitucionesEducacion}">
                                                    <option value="${institucionCat}"><c:out value="${institucionCat}"/></option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div>
                                            <label for="fechaInicio">Fecha inicio</label>
                                            <input id="fechaInicio" name="fechaInicio" type="date" required>
                                        </div>
                                        <div>
                                            <label for="fechaGrado">Fecha grado</label>
                                            <input id="fechaGrado" name="fechaGrado" type="date" required>
                                        </div>
                                    </div>
                                    <div class="button-row form-actions">
                                        <a class="btn ghost" href="${pageContext.request.contextPath}/admin/gestion-personal?accion=editar&codigo=${empleado.codigo}&paso=general">Atr&aacute;s</a>
                                        <button class="btn secondary" type="submit">Registrar formación</button>
                                        <a class="btn primary" href="${pageContext.request.contextPath}/admin/gestion-personal?accion=editar&codigo=${empleado.codigo}&paso=familiares">Siguiente</a>
                                    </div>
                                </form>

                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Título</th>
                                                <th>Institución</th>
                                                <th>Inicio</th>
                                                <th>Grado</th>
                                                <th class="nowrap">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty educaciones}">
                                                    <tr>
                                                        <td colspan="5" class="empty">Sin formación registrada.</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="ed" items="${educaciones}">
                                                        <tr>
                                                            <td><c:out value="${ed.titulo}"/></td>
                                                            <td><c:out value="${ed.institucion}"/></td>
                                                            <td><fmt:formatDate value="${ed.fechaInicio}" pattern="dd/MM/yyyy"/></td>
                                                            <td><fmt:formatDate value="${ed.fechaGrado}" pattern="dd/MM/yyyy"/></td>
                                                            <td>
                                                                <form action="${pageContext.request.contextPath}/admin/gestion-personal" method="post" class="table-actions">
                                                                    <input type="hidden" name="accion" value="eliminarEducacion">
                                                                    <input type="hidden" name="codigoEdu" value="${ed.codigo}">
                                                                    <input type="hidden" name="codigo" value="${empleado.codigo}">
                                                                    <button type="submit" class="link-danger" onclick="return confirm('¿Eliminar formación?')">Eliminar</button>
                                                                </form>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </section>

                            <section class="panel wizard-step-pane ${pasoVisible == 'familiares' ? 'active' : ''}" id="step-familiares">
                                <h2 class="section-title">Cargas Familiares</h2>
                                <form action="${pageContext.request.contextPath}/admin/gestion-personal" method="post" class="subform" accept-charset="UTF-8">
                                    <input type="hidden" name="accion" value="agregarFamiliar">
                                    <input type="hidden" name="codigo" value="${empleado.codigo}">
                                    <input type="hidden" name="paso" value="familiares">
                                    <div class="detail-form-grid">
                                        <div>
                                            <label for="parentesco">Tipo de relación</label>
                                            <select id="parentesco" name="parentesco" required>
                                                <option value="">Seleccionar</option>
                                                <c:forEach var="p" items="${listaParentescos}">
                                                    <option value="${p.key}"><c:out value="${p.value}"/></option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div>
                                            <label for="sexoFamiliar">Sexo</label>
                                            <select id="sexoFamiliar" name="sexoFamiliar" required>
                                                <option value="">Seleccionar</option>
                                                <c:forEach var="sx" items="${listaSexos}">
                                                    <option value="${sx.key}"><c:out value="${sx.value}"/></option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                        <div>
                                            <label for="nombreFam">Nombres</label>
                                            <input id="nombreFam" name="nombreFam" type="text" maxlength="50" required>
                                        </div>
                                        <div>
                                            <label for="apellidoFam">Apellidos</label>
                                            <input id="apellidoFam" name="apellidoFam" type="text" maxlength="50" required>
                                        </div>
                                        <div>
                                            <label for="fechaNacFam">Fecha de nacimiento</label>
                                            <input id="fechaNacFam" name="fechaNacFam" type="date" required>
                                        </div>
                                    </div>
                                    <div class="button-row form-actions">
                                        <a class="btn ghost" href="${pageContext.request.contextPath}/admin/gestion-personal?accion=editar&codigo=${empleado.codigo}&paso=formacion">Atr&aacute;s</a>
                                        <button class="btn secondary" type="submit">Agregar carga</button>
                                        <a class="btn primary" href="${pageContext.request.contextPath}/admin/gestion-personal">Finalizar</a>
                                    </div>
                                </form>

                                <div class="table-wrap">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>Tipo de relación</th>
                                                <th>Nombres</th>
                                                <th>Apellidos</th>
                                                <th>Sexo</th>
                                                <th>Nacimiento</th>
                                                <th class="nowrap">Acciones</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:choose>
                                                <c:when test="${empty familiares}">
                                                    <tr>
                                                        <td colspan="6" class="empty">Sin cargas familiares registradas.</td>
                                                    </tr>
                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="fm" items="${familiares}">
                                                        <tr>
                                                            <td><c:out value="${fm.parentescoDescripcion}"/></td>
                                                            <td><c:out value="${fm.nombre}"/></td>
                                                            <td><c:out value="${fm.apellido}"/></td>
                                                            <td><c:out value="${fm.sexoDescripcion}"/></td>
                                                            <td><fmt:formatDate value="${fm.fechaNacimiento}" pattern="dd/MM/yyyy"/></td>
                                                            <td>
                                                                <form action="${pageContext.request.contextPath}/admin/gestion-personal" method="post" class="table-actions">
                                                                    <input type="hidden" name="accion" value="eliminarFamiliar">
                                                                    <input type="hidden" name="codigoFamiliar" value="${fm.codigo}">
                                                                    <input type="hidden" name="codigo" value="${empleado.codigo}">
                                                                    <button type="submit" class="link-danger" onclick="return confirm('¿Eliminar carga familiar?')">Eliminar</button>
                                                                </form>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </c:otherwise>
                                            </c:choose>
                                        </tbody>
                                    </table>
                                </div>
                            </section>
                        </c:if>
                    </c:when>

                    <c:otherwise>
                        <section class="panel table-panel">
                            <div class="panel-heading-row">
                                <h2>Directorio de colaboradores</h2>
                                <a class="btn primary" href="${pageContext.request.contextPath}/admin/gestion-personal?accion=nuevo">Nuevo colaborador</a>
                            </div>
                            <div class="table-wrap">
                                <table>
                                    <thead>
                                        <tr>
                                            <th>Foto</th>
                                            <th>C&oacute;digo</th>
                                            <th>C&eacute;dula</th>
                                            <th>Colaborador</th>
                                            <th>Departamento</th>
                                            <th>Cargo</th>
                                            <th>Sexo</th>
                                            <th>Estado civil</th>
                                            <th>Cargas</th>
                                            <th>Acciones</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty empleados}">
                                                <tr>
                                                    <td colspan="10" class="empty">Sin colaboradores registrados.</td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="e" items="${empleados}">
                                                    <tr>
                                                        <td>
                                                            <img class="employee-thumb"
                                                                 src="${not empty e.fotoRuta ? pageContext.request.contextPath.concat(e.fotoRuta) : pageContext.request.contextPath.concat('/resources/foto.jpg')}"
                                                                 alt="Foto de ${e.nombre}"
                                                                 onerror="this.src='${pageContext.request.contextPath}/resources/foto.jpg'">
                                                        </td>
                                                        <td><strong><c:out value="${e.codigo}"/></strong></td>
                                                        <td><c:out value="${e.cedula}"/></td>
                                                        <td><c:out value="${e.apellido}"/>, <c:out value="${e.nombre}"/></td>
                                                        <td><c:out value="${e.departamentoDescripcion}"/></td>
                                                        <td><c:out value="${e.cargoDescripcion}"/></td>
                                                        <td><c:out value="${e.sexoDescripcion}"/></td>
                                                        <td><c:out value="${e.estadoCivilDescripcion}"/></td>
                                                        <td><span class="status pending"><c:out value="${e.cargosFamiliares}"/></span></td>
                                                        <td>
                                                            <a class="link-action" href="${pageContext.request.contextPath}/admin/gestion-personal?accion=editar&codigo=${e.codigo}">Editar</a>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </c:otherwise>
                </c:choose>
            </main>
        </div>

        <script>
            const cargoSelect = document.getElementById('cargo');
            const departamentoCodigo = document.getElementById('departamento');
            const departamentoVista = document.getElementById('departamentoVista');
            const sincronizarCargoDepartamento = () => {
                if (!cargoSelect || !departamentoCodigo || !departamentoVista) {
                    return;
                }
                const selected = cargoSelect.selectedOptions && cargoSelect.selectedOptions.length > 0
                    ? cargoSelect.selectedOptions[0]
                    : null;
                const codigo = selected && selected.dataset ? (selected.dataset.departamentoCodigo || '') : '';
                const descripcion = selected && selected.dataset ? (selected.dataset.departamentoDescripcion || '') : '';
                departamentoCodigo.value = codigo;
                // Mostrar descripción si existe, si no al menos el código
                departamentoVista.value = codigo
                    ? (descripcion ? `${descripcion}` : codigo)
                    : '';
            };
            if (cargoSelect) {
                cargoSelect.addEventListener('change', sincronizarCargoDepartamento);
                sincronizarCargoDepartamento();
            }

            const fotoInput = document.getElementById('foto');
            const fotoPreview = document.getElementById('fotoPreview');
            if (fotoInput && fotoPreview) {
                fotoInput.addEventListener('change', () => {
                    const file = fotoInput.files && fotoInput.files[0];
                    if (file) {
                        fotoPreview.src = URL.createObjectURL(file);
                    }
                });
            }
        </script>
    </body>
</html>
