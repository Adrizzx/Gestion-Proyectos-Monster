package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOEMPLEADO;
import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.PoliticaContrasena;
import ec.edu.monster.modelo.Cargo;
import ec.edu.monster.modelo.Educacion;
import ec.edu.monster.modelo.Empleado;
import ec.edu.monster.modelo.Familiar;
import ec.edu.monster.modelo.Usuario;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.Locale;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

@WebServlet(name = "srvEmpleado", urlPatterns = {"/srvEmpleado", "/admin/gestion-personal"})
@MultipartConfig(maxFileSize = 2 * 1024 * 1024, maxRequestSize = 4 * 1024 * 1024)
public class srvEmpleado extends HttpServlet {

    private static final String VISTA_EMPLEADOS = "/views/personal/empleados.jsp";
    private static final String FECHA_SALIDA_DEFAULT = "2099-12-31";
    private static final String DIRECTORIO_FOTOS = "/resources/personal/fotos";
    private static final Set<String> EXTENSIONES_IMAGEN = Set.of(".jpg", ".jpeg", ".png", ".gif", ".webp");
    private static final String PASO_GENERAL = "general";
    private static final String PASO_FORMACION = "formacion";
    private static final String PASO_FAMILIARES = "familiares";

    private final DAOEMPLEADO daoEmpleado = new DAOEMPLEADO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!requiereAccesoPersonal(request, response)) {
            return;
        }

        copiarMensajes(request);
        String accion = limpiar(request.getParameter("accion"));
        if ("nuevo".equals(accion)) {
            mostrarNuevoEmpleado(request, response);
            return;
        }
        if ("editar".equals(accion)) {
            mostrarEditarEmpleado(request, response);
            return;
        }

        listarEmpleados(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!requiereAccesoPersonal(request, response)) {
            return;
        }

        String accion = limpiar(request.getParameter("accion"));
        if ("crearEmpleado".equals(accion)) {
            crearEmpleado(request, response);
            return;
        }
        if ("actualizarGeneral".equals(accion)) {
            actualizarDatosGenerales(request, response);
            return;
        }
        if ("agregarEducacion".equals(accion)) {
            agregarEducacion(request, response);
            return;
        }
        if ("eliminarEducacion".equals(accion)) {
            eliminarEducacion(request, response);
            return;
        }
        if ("agregarFamiliar".equals(accion)) {
            agregarFamiliar(request, response);
            return;
        }
        if ("eliminarFamiliar".equals(accion)) {
            eliminarFamiliar(request, response);
            return;
        }

        listarEmpleados(request, response);
    }

    private boolean requiereAccesoPersonal(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        return SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH);
    }

    private void cargarCatalogos(HttpServletRequest request) throws Exception {
        request.setAttribute("listaSexos", daoEmpleado.listarSexos());
        request.setAttribute("listaEstados", daoEmpleado.listarEstadosCiviles());
        request.setAttribute("listaDepartamentos", daoEmpleado.listarDepartamentos());
        request.setAttribute("listaCargos", daoEmpleado.listarCargos());
        request.setAttribute("listaParentescos", daoEmpleado.listarParentescos());
        request.setAttribute("listaTitulosEducacion", daoEmpleado.listarTitulosEducacion());
        request.setAttribute("listaInstitucionesEducacion", daoEmpleado.listarInstitucionesEducacion());
    }

    private void listarEmpleados(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("empleados", daoEmpleado.listar());
        } catch (Exception e) {
            request.setAttribute("empleados", Collections.emptyList());
            request.setAttribute("error", "Error al cargar empleados: " + e.getMessage());
        }
        request.getRequestDispatcher(VISTA_EMPLEADOS).forward(request, response);
    }

    private void mostrarNuevoEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        mostrarNuevoEmpleado(request, response, new Empleado());
    }

    private void mostrarNuevoEmpleado(HttpServletRequest request, HttpServletResponse response, Empleado empleado)
            throws ServletException, IOException {
        try {
            cargarCatalogos(request);
            request.setAttribute("empleado", empleado);
            request.setAttribute("educaciones", Collections.emptyList());
            request.setAttribute("familiares", Collections.emptyList());
            request.setAttribute("proximoCodigo", daoEmpleado.generarCodigoSiguiente());
            request.setAttribute("modo", "nuevo");
            request.setAttribute("pasoActual", PASO_GENERAL);
            request.getRequestDispatcher(VISTA_EMPLEADOS).forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al preparar la ficha: " + e.getMessage());
            listarEmpleados(request, response);
        }
    }

    private void mostrarEditarEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigoEmpleado = limpiar(request.getParameter("codigo"));
            if (codigoEmpleado.isEmpty()) {
                request.setAttribute("error", "Codigo de empleado invalido.");
                listarEmpleados(request, response);
                return;
            }

            Empleado empleado = daoEmpleado.obtenerPorCodigo(codigoEmpleado);
            if (empleado == null) {
                request.setAttribute("error", "Empleado no encontrado.");
                listarEmpleados(request, response);
                return;
            }

            cargarCatalogos(request);
            request.setAttribute("empleado", empleado);
            request.setAttribute("educaciones", daoEmpleado.listarEducacion(codigoEmpleado));
            request.setAttribute("familiares", daoEmpleado.listarFamiliares(codigoEmpleado));
            request.setAttribute("modo", "editar");
            String pasoActual = resolverPasoActual(request, PASO_GENERAL);
            request.setAttribute("pasoActual", pasoActual);
            request.getRequestDispatcher(VISTA_EMPLEADOS).forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al cargar la ficha: " + e.getMessage());
            listarEmpleados(request, response);
        }
    }

    private void crearEmpleado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Empleado empleado = null;
        try {
            String codigoEmpleado = daoEmpleado.generarCodigoSiguiente();
            empleado = leerEmpleadoDesdeRequest(request, codigoEmpleado, null);
            String error = validarEmpleado(empleado);
            if (error != null) {
                request.setAttribute("error", error);
                mostrarNuevoEmpleado(request, response, empleado);
                return;
            }

            // Validar contraseña solo si el admin la proporcionó
            Usuario usuarioActual = SeguridadWeb.usuarioSesion(request);
            boolean esAdmin = usuarioActual != null
                    && Usuario.ROL_ADMINISTRADOR.equals(usuarioActual.getRolUsuario());
            String clave          = limpiar(request.getParameter("clave"));
            String confirmarClave = limpiar(request.getParameter("confirmarClave"));
            boolean clavePersonalizada = esAdmin && !clave.isEmpty();

            if (clavePersonalizada) {
                if (!clave.equals(confirmarClave)) {
                    request.setAttribute("error", "Las contraseñas no coinciden.");
                    mostrarNuevoEmpleado(request, response, empleado);
                    return;
                }
                String errClave = PoliticaContrasena.validar(clave);
                if (errClave != null) {
                    request.setAttribute("error", errClave);
                    mostrarNuevoEmpleado(request, response, empleado);
                    return;
                }
            }

            empleado.setFotoRuta(guardarFotoEmpleado(request, codigoEmpleado, null));
            empleado.setCargosFamiliares(0);
            daoEmpleado.insertar(empleado);

            // Crear perfil de seguridad usando la contraseña del admin o una temporal
            String claveUsada = clavePersonalizada ? clave : "Monster1_" + codigoEmpleado;
            try {
                new DAOUSUARIO().crearPerfilBase(codigoEmpleado, claveUsada);
            } catch (Exception exSeguridad) {
                // No bloquear si falla; el admin puede asignar contraseña desde Gestión de Contraseñas.
            }

            String msgExito     = "Empleado registrado correctamente.";
            String claveMostrar = clavePersonalizada ? null : "Monster1_" + codigoEmpleado;
            redirigirAEdicion(request, response, codigoEmpleado, msgExito, PASO_FORMACION, claveMostrar);
        } catch (ParseException e) {
            request.setAttribute("error", e.getMessage());
            mostrarNuevoEmpleado(request, response, empleado == null ? new Empleado() : empleado);
        } catch (Exception e) {
            request.setAttribute("error", "Error al crear empleado: " + e.getMessage());
            mostrarNuevoEmpleado(request, response, empleado == null ? new Empleado() : empleado);
        }
    }

    private void actualizarDatosGenerales(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigo = limpiar(request.getParameter("codigo"));
            Empleado empleadoActual = daoEmpleado.obtenerPorCodigo(codigo);
            if (empleadoActual == null) {
                request.setAttribute("error", "Empleado no encontrado.");
                listarEmpleados(request, response);
                return;
            }

            Empleado empleado = leerEmpleadoDesdeRequest(request, codigo, empleadoActual);
            String error = validarEmpleado(empleado);
            if (error != null) {
                request.setAttribute("error", error);
                request.setAttribute("pasoActual", PASO_GENERAL);
                mostrarEditarEmpleado(request, response);
                return;
            }

            empleado.setFotoRuta(guardarFotoEmpleado(request, codigo, empleado.getFotoRuta()));
            daoEmpleado.actualizar(empleado);
            request.setAttribute("mensaje", "Ficha actualizada correctamente.");
            redirigirAEdicion(request, response, codigo, "Ficha actualizada correctamente.", PASO_FORMACION);
        } catch (ParseException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pasoActual", PASO_GENERAL);
            mostrarEditarEmpleado(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al actualizar: " + e.getMessage());
            request.setAttribute("pasoActual", PASO_GENERAL);
            mostrarEditarEmpleado(request, response);
        }
    }

    private void agregarEducacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigo = limpiar(request.getParameter("codigo"));
            String titulo = limpiar(request.getParameter("titulo"));
            String institucion = limpiar(request.getParameter("institucion"));
            Date fechaInicio = parseFecha(limpiar(request.getParameter("fechaInicio")), "Fecha de inicio invalida.");
            Date fechaGrado = parseFecha(limpiar(request.getParameter("fechaGrado")), "Fecha de grado invalida.");

            if (codigo.isEmpty() || titulo.isEmpty() || institucion.isEmpty() || fechaInicio == null || fechaGrado == null) {
                request.setAttribute("error", "Complete los datos de formacion.");
                request.setAttribute("pasoActual", PASO_FORMACION);
                mostrarEditarEmpleado(request, response);
                return;
            }

            Educacion educacion = new Educacion();
            educacion.setCodigo(daoEmpleado.generarCodigoEducacion());
            educacion.setCodigoEmpleado(codigo);
            educacion.setTitulo(titulo);
            educacion.setInstitucion(institucion);
            educacion.setFechaInicio(fechaInicio);
            educacion.setFechaGrado(fechaGrado);

            daoEmpleado.insertarEducacion(educacion);
            request.setAttribute("mensaje", "Formacion agregada correctamente.");
            redirigirAEdicion(request, response, codigo, "Formacion agregada correctamente.", PASO_FORMACION);
        } catch (ParseException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pasoActual", PASO_FORMACION);
            mostrarEditarEmpleado(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al agregar formacion: " + e.getMessage());
            request.setAttribute("pasoActual", PASO_FORMACION);
            mostrarEditarEmpleado(request, response);
        }
    }

    private void eliminarEducacion(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigoEmpleado = limpiar(request.getParameter("codigo"));
            String codigoEdu = limpiar(request.getParameter("codigoEdu"));
            if (codigoEmpleado.isEmpty() || codigoEdu.isEmpty()) {
                request.setAttribute("error", "Codigo de formacion invalido.");
                request.setAttribute("pasoActual", PASO_FORMACION);
                mostrarEditarEmpleado(request, response);
                return;
            }
            daoEmpleado.eliminarEducacion(codigoEdu);
            redirigirAEdicion(request, response, codigoEmpleado, "Formacion eliminada correctamente.", PASO_FORMACION);
        } catch (Exception e) {
            request.setAttribute("error", "Error al eliminar formacion: " + e.getMessage());
            request.setAttribute("pasoActual", PASO_FORMACION);
            mostrarEditarEmpleado(request, response);
        }
    }

    private void agregarFamiliar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigo = limpiar(request.getParameter("codigo"));
            Date fechaNacimiento = parseFecha(limpiar(request.getParameter("fechaNacFam")), "Fecha de nacimiento invalida.");
            Familiar fam = new Familiar();
            fam.setCodigo(daoEmpleado.generarCodigoFamiliar());
            fam.setCodigoEmpleado(codigo);
            fam.setParentescoCodigo(limpiar(request.getParameter("parentesco")));
            fam.setSexoCodigo(limpiar(request.getParameter("sexoFamiliar")));
            fam.setNombre(limpiar(request.getParameter("nombreFam")));
            fam.setApellido(limpiar(request.getParameter("apellidoFam")));
            fam.setFechaNacimiento(fechaNacimiento);

            if (codigo.isEmpty() || fam.getParentescoCodigo().isEmpty() || fam.getSexoCodigo().isEmpty()
                    || fam.getNombre().isEmpty() || fam.getApellido().isEmpty() || fechaNacimiento == null) {
                request.setAttribute("error", "Complete los datos de la carga familiar.");
                request.setAttribute("pasoActual", PASO_FAMILIARES);
                mostrarEditarEmpleado(request, response);
                return;
            }

            daoEmpleado.insertarFamiliar(fam);
            request.setAttribute("mensaje", "Carga familiar agregada correctamente.");
            redirigirAEdicion(request, response, codigo, "Carga familiar agregada correctamente.", PASO_FAMILIARES);
        } catch (ParseException e) {
            request.setAttribute("error", e.getMessage());
            request.setAttribute("pasoActual", PASO_FAMILIARES);
            mostrarEditarEmpleado(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "Error al agregar familiar: " + e.getMessage());
            request.setAttribute("pasoActual", PASO_FAMILIARES);
            mostrarEditarEmpleado(request, response);
        }
    }

    private void eliminarFamiliar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String codigoEmpleado = limpiar(request.getParameter("codigo"));
            String codigoFamiliar = limpiar(request.getParameter("codigoFamiliar"));
            if (codigoEmpleado.isEmpty() || codigoFamiliar.isEmpty()) {
                request.setAttribute("error", "Codigo de carga familiar invalido.");
                request.setAttribute("pasoActual", PASO_FAMILIARES);
                mostrarEditarEmpleado(request, response);
                return;
            }
            daoEmpleado.eliminarFamiliar(codigoFamiliar);
            redirigirAEdicion(request, response, codigoEmpleado, "Carga familiar eliminada correctamente.", PASO_FAMILIARES);
        } catch (Exception e) {
            request.setAttribute("error", "Error al eliminar familiar: " + e.getMessage());
            request.setAttribute("pasoActual", PASO_FAMILIARES);
            mostrarEditarEmpleado(request, response);
        }
    }

    private Empleado leerEmpleadoDesdeRequest(HttpServletRequest request, String codigo, Empleado actual)
            throws ParseException, Exception {
        String fechaSalida = limpiar(request.getParameter("fechaSalida"));
        if (fechaSalida.isEmpty()) {
            fechaSalida = actual != null && actual.getFechaSalida() != null
                    ? formatoFecha(actual.getFechaSalida())
                    : FECHA_SALIDA_DEFAULT;
        }

        Empleado empleado = new Empleado();
        empleado.setCodigo(codigo);
        empleado.setNombre(limpiar(request.getParameter("nombre")));
        empleado.setApellido(limpiar(request.getParameter("apellido")));
        empleado.setCedula(limpiar(request.getParameter("cedula")));
        empleado.setEmail(limpiar(request.getParameter("email")));
        empleado.setTelefono(limpiar(request.getParameter("telefono")));
        String cargoCodigo = limpiar(request.getParameter("cargo"));
        empleado.setCargoCodigo(cargoCodigo);
        empleado.setSexoCodigo(limpiar(request.getParameter("sexo")));
        empleado.setEstadoCivilCodigo(limpiar(request.getParameter("estadoCivil")));
        empleado.setFechaNacimiento(parseFecha(limpiar(request.getParameter("fechaNac")), "Fecha de nacimiento invalida."));
        empleado.setFechaSalida(parseFecha(fechaSalida, "Fecha de salida invalida."));
        empleado.setDireccion(limpiar(request.getParameter("direccion")));

        Cargo cargo = cargoCodigo.isEmpty() ? null : daoEmpleado.obtenerCargoPorCodigo(cargoCodigo);
        if (cargo != null) {
            empleado.setDepartamentoCodigo(cargo.getDepartamentoCodigo());
            empleado.setDepartamentoDescripcion(cargo.getDepartamentoDescripcion());
            empleado.setCargoDescripcion(cargo.getDescripcion());
        } else {
            String departamentoCodigo = limpiar(request.getParameter("departamento"));
            if (departamentoCodigo.isEmpty() && actual != null) {
                departamentoCodigo = limpiar(actual.getDepartamentoCodigo());
            }
            empleado.setDepartamentoCodigo(departamentoCodigo);
            if (actual != null) {
                empleado.setDepartamentoDescripcion(actual.getDepartamentoDescripcion());
                empleado.setCargoDescripcion(actual.getCargoDescripcion());
            }
        }

        String pasaporte = limpiar(request.getParameter("pasaporte"));
        if (pasaporte.isEmpty()) {
            pasaporte = actual != null ? limpiar(actual.getPasaporte()) : "N/A";
        }
        empleado.setPasaporte(pasaporte.isEmpty() ? "N/A" : pasaporte);
        empleado.setFotoRuta(rutaFotoActual(request, actual));
        empleado.setCargosFamiliares(actual == null ? 0 : actual.getCargosFamiliares());
        return empleado;
    }

    private String validarEmpleado(Empleado empleado) throws Exception {
        if (empleado == null) return "Datos de empleado invalidos.";
        if (limpiar(empleado.getNombre()).isEmpty()) return "Nombre requerido.";
        if (limpiar(empleado.getApellido()).isEmpty()) return "Apellido requerido.";
        if (limpiar(empleado.getCedula()).isEmpty()) return "Cedula requerida.";
        if (limpiar(empleado.getEmail()).isEmpty() || !empleado.getEmail().contains("@")) return "Correo electronico invalido.";
        if (limpiar(empleado.getTelefono()).isEmpty()) return "Telefono requerido.";
        if (limpiar(empleado.getCargoCodigo()).isEmpty()) return "Cargo requerido.";
        Cargo cargo = daoEmpleado.obtenerCargoPorCodigo(empleado.getCargoCodigo());
        if (cargo == null) {
            return "El cargo seleccionado no es valido.";
        }
        empleado.setDepartamentoCodigo(cargo.getDepartamentoCodigo());
        empleado.setDepartamentoDescripcion(cargo.getDepartamentoDescripcion());
        empleado.setCargoDescripcion(cargo.getDescripcion());
        if (limpiar(empleado.getSexoCodigo()).isEmpty()) return "Sexo requerido.";
        if (limpiar(empleado.getEstadoCivilCodigo()).isEmpty()) return "Estado civil requerido.";
        if (empleado.getFechaNacimiento() == null) return "Fecha de nacimiento requerida.";
        if (empleado.getFechaSalida() == null) return "Fecha de salida requerida.";
        if (limpiar(empleado.getDireccion()).isEmpty()) return "Direccion requerida.";
        return null;
    }

    private String guardarFotoEmpleado(HttpServletRequest request, String codigoEmpleado, String fotoActual)
            throws IOException, ServletException {
        Part foto = request.getPart("foto");
        if (foto == null || foto.getSize() == 0) {
            return limpiar(fotoActual).isEmpty() ? null : fotoActual;
        }

        String contentType = foto.getContentType();
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith("image/")) {
            throw new IllegalArgumentException("La foto debe ser un archivo de imagen.");
        }

        String realPath = getServletContext().getRealPath(DIRECTORIO_FOTOS);
        if (realPath == null) {
            String webRoot = getServletContext().getRealPath("/");
            if (webRoot == null) {
                throw new IOException("No se pudo resolver el directorio de fotografias.");
            }
            String subPath = DIRECTORIO_FOTOS.startsWith("/") ? DIRECTORIO_FOTOS.substring(1) : DIRECTORIO_FOTOS;
            realPath = webRoot + (webRoot.endsWith(File.separator) ? "" : File.separator)
                     + subPath.replace("/", File.separator);
        }

        Path carpeta = Paths.get(realPath);
        Files.createDirectories(carpeta);

        String nombreArchivo = codigoEmpleado + "_" + System.currentTimeMillis() + extensionImagen(foto);
        Path destino = carpeta.resolve(nombreArchivo);
        try (InputStream input = foto.getInputStream()) {
            Files.copy(input, destino, StandardCopyOption.REPLACE_EXISTING);
        }
        return DIRECTORIO_FOTOS + "/" + nombreArchivo;
    }

    private String extensionImagen(Part foto) {
        String nombre = foto.getSubmittedFileName();
        String limpio = nombre == null ? "" : nombre.replace("\\", "/");
        int slash = limpio.lastIndexOf('/');
        if (slash >= 0) {
            limpio = limpio.substring(slash + 1);
        }
        int punto = limpio.lastIndexOf('.');
        if (punto >= 0 && punto < limpio.length() - 1) {
            String extension = limpio.substring(punto).toLowerCase(Locale.ROOT);
            if (EXTENSIONES_IMAGEN.contains(extension)) {
                return extension;
            }
        }

        String contentType = limpiar(foto.getContentType()).toLowerCase(Locale.ROOT);
        if (contentType.contains("png")) return ".png";
        if (contentType.contains("gif")) return ".gif";
        if (contentType.contains("webp")) return ".webp";
        return ".jpg";
    }

    private Date parseFecha(String valor, String mensajeError) throws ParseException {
        if (valor == null || valor.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);
            return sdf.parse(valor.trim());
        } catch (ParseException ex) {
            throw new ParseException(mensajeError, ex.getErrorOffset());
        }
    }

    private String formatoFecha(Date fecha) {
        return new SimpleDateFormat("yyyy-MM-dd").format(fecha);
    }

    private String rutaFotoActual(HttpServletRequest request, Empleado actual) {
        String fotoActual = limpiar(request.getParameter("fotoActual"));
        if (!fotoActual.isEmpty()) {
            return fotoActual;
        }
        return actual == null ? null : actual.getFotoRuta();
    }

    private void copiarMensajes(HttpServletRequest request) {
        String mensaje   = limpiar(request.getParameter("mensaje"));
        String error     = limpiar(request.getParameter("error"));
        String claveTemp = limpiar(request.getParameter("claveTemp"));
        if (!mensaje.isEmpty())   request.setAttribute("mensaje",   mensaje);
        if (!error.isEmpty())     request.setAttribute("error",     error);
        if (!claveTemp.isEmpty()) request.setAttribute("claveTemp", claveTemp);
    }

    private void redirigirAEdicion(HttpServletRequest request, HttpServletResponse response,
                                   String codigo, String mensaje, String paso) throws IOException {
        redirigirAEdicion(request, response, codigo, mensaje, paso, null);
    }

    private void redirigirAEdicion(HttpServletRequest request, HttpServletResponse response,
                                   String codigo, String mensaje, String paso,
                                   String claveTemp) throws IOException {
        String url = request.getContextPath() + "/admin/gestion-personal?accion=editar&codigo="
                + URLEncoder.encode(codigo, StandardCharsets.UTF_8)
                + "&paso=" + URLEncoder.encode(paso, StandardCharsets.UTF_8)
                + "&mensaje=" + URLEncoder.encode(mensaje, StandardCharsets.UTF_8);
        if (claveTemp != null && !claveTemp.isEmpty()) {
            url += "&claveTemp=" + URLEncoder.encode(claveTemp, StandardCharsets.UTF_8);
        }
        response.sendRedirect(url);
    }

    private String resolverPasoActual(HttpServletRequest request, String defecto) {
        String paso = limpiar(request.getParameter("paso"));
        if (paso.isEmpty()) {
            Object atributoPaso = request.getAttribute("pasoActual");
            if (atributoPaso != null) {
                paso = limpiar(String.valueOf(atributoPaso));
            }
        }
        if (paso.isEmpty()) {
            return defecto;
        }
        if (PASO_FORMACION.equals(paso) || PASO_FAMILIARES.equals(paso) || PASO_GENERAL.equals(paso)) {
            return paso;
        }
        return defecto;
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
