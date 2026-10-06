package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOPERFIL;
import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Perfil;
import ec.edu.monster.modelo.PoliticaContrasena;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Gestiona la seguridad del sistema: activar/desactivar usuarios,
 * cambiar roles y restablecer contraseñas.
 * La creación de empleados se realiza exclusivamente desde Gestión de Personal.
 */
@WebServlet(name = "srvUsuario", urlPatterns = {"/srvUsuario", "/admin/seguridad", "/admin/gestionar-clave"})
public class srvUsuario extends HttpServlet {

    private final DAOUSUARIO daoUsuario = new DAOUSUARIO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) {
            return;
        }
        String uri = request.getRequestURI();
        if (uri.endsWith("/gestionar-clave")) {
            copiarMensajesDeUrl(request);
            try {
                request.setAttribute("usuarios", daoUsuario.listar());
            } catch (SQLException ex) {
                request.setAttribute("usuarios", java.util.Collections.emptyList());
            }
            request.getRequestDispatcher("/views/admin/gestionar-clave.jsp").forward(request, response);
            return;
        }
        enviarListado(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) {
            return;
        }
        String accion = limpiar(request.getParameter("accion"));
        if ("cambiarEstado".equals(accion)) {
            cambiarEstado(request, response);
            return;
        }
        if ("cambiarRol".equals(accion)) {
            cambiarRol(request, response);
            return;
        }
        if ("resetearClave".equals(accion)) {
            resetearClave(request, response);
            return;
        }
        // Acción desconocida: regresar al listado
        enviarListado(request, response);
    }

    // ── Acciones ─────────────────────────────────────────────────────────────

    private void cambiarEstado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String codigoEmpleado = normalizar(request.getParameter("codigoEmpleado"));
        String estado = normalizar(request.getParameter("estado"));
        if (codigoEmpleado.isEmpty() || (!"A".equals(estado) && !"I".equals(estado))) {
            request.setAttribute("error", "Seleccione un usuario y un estado válidos.");
            enviarListado(request, response);
            return;
        }
        try {
            daoUsuario.cambiarEstado(codigoEmpleado, estado);
            if ("I".equals(estado)) {
                RegistroSesiones.invalidar(codigoEmpleado);
            }
            redirigir(response, request, "Estado del usuario actualizado correctamente.", false);
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarListado(request, response);
        }
    }

    private void cambiarRol(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String codigoEmpleado = normalizar(request.getParameter("codigoEmpleado"));
        String perfil = limpiar(request.getParameter("perfil"));
        if (codigoEmpleado.isEmpty() || !daoUsuario.esPerfilValido(perfil)) {
            request.setAttribute("error", "Seleccione un usuario y un rol válidos.");
            enviarListado(request, response);
            return;
        }
        try {
            daoUsuario.cambiarPerfil(codigoEmpleado, perfil);
            RegistroSesiones.actualizarRol(codigoEmpleado, perfil);
            redirigir(response, request, "Rol del usuario actualizado correctamente.", false);
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarListado(request, response);
        }
    }

    private void resetearClave(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String codigoEmpleado = normalizar(request.getParameter("codigoEmpleado"));
        String nuevaClave     = limpiar(request.getParameter("nuevaClave"));
        String confirmarClave = limpiar(request.getParameter("confirmarClave"));

        if (codigoEmpleado.isEmpty() || nuevaClave.isEmpty() || confirmarClave.isEmpty()) {
            request.setAttribute("error", "Complete todos los campos.");
            enviarClaveView(request, response);
            return;
        }
        if (!nuevaClave.equals(confirmarClave)) {
            request.setAttribute("error", "Las contraseñas no coinciden.");
            enviarClaveView(request, response);
            return;
        }
        String errPass = PoliticaContrasena.validar(nuevaClave);
        if (errPass != null) {
            request.setAttribute("error", errPass);
            enviarClaveView(request, response);
            return;
        }
        try {
            boolean ok = daoUsuario.cambiarPassword(codigoEmpleado, nuevaClave);
            if (!ok) {
                request.setAttribute("error", "No se encontró el usuario especificado.");
                enviarClaveView(request, response);
                return;
            }
            RegistroSesiones.invalidar(codigoEmpleado);
            String msg = URLEncoder.encode(
                "Contraseña actualizada. El usuario debe iniciar sesión de nuevo.", StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/admin/gestionar-clave?mensaje=" + msg);
        } catch (IllegalArgumentException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarClaveView(request, response);
        } catch (SQLException ex) {
            request.setAttribute("error", "Error en BD: " + ex.getMessage());
            enviarClaveView(request, response);
        }
    }

    // ── Vistas ────────────────────────────────────────────────────────────────

    private void enviarListado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Usuario> usuarios = daoUsuario.listar();
            request.setAttribute("usuarios", usuarios);

            // Cargar TODOS los perfiles reales (incluye los creados dinámicamente),
            // no solo los 4 fijos, para el dropdown y el TreeView.
            List<Perfil> perfiles = new DAOPERFIL().listar();
            String[][] perfilesArray = new String[perfiles.size()][2];
            Map<String, String> codigoADescri = new LinkedHashMap<>();
            Map<String, List<Usuario>> porPerfil = new LinkedHashMap<>();
            for (int i = 0; i < perfiles.size(); i++) {
                Perfil pf = perfiles.get(i);
                perfilesArray[i][0] = pf.getCodigo();
                perfilesArray[i][1] = pf.getDescripcion();
                codigoADescri.put(pf.getCodigo(), pf.getDescripcion());
                porPerfil.put(pf.getDescripcion(), new ArrayList<>());
            }
            request.setAttribute("perfiles",
                    perfilesArray.length > 0 ? perfilesArray : DAOUSUARIO.PERFILES_DISPONIBLES);

            // Agrupar cada usuario según su perfil real (código), no según el rol fijo.
            for (Usuario u : usuarios) {
                String desc = codigoADescri.get(u.getPerfilCodigo());
                if (desc == null) desc = "Sin perfil asignado";
                porPerfil.computeIfAbsent(desc, k -> new ArrayList<>()).add(u);
            }
            request.setAttribute("usuariosPorPerfil", porPerfil);

        } catch (SQLException ex) {
            request.setAttribute("usuarios", java.util.Collections.emptyList());
            request.setAttribute("usuariosPorPerfil", java.util.Collections.emptyMap());
            request.setAttribute("error", ex.getMessage());
        }
        copiarMensajesDeUrl(request);
        request.getRequestDispatcher("/usuarios.jsp").forward(request, response);
    }

    private void enviarClaveView(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("usuarios", daoUsuario.listar());
        } catch (SQLException ex) {
            request.setAttribute("usuarios", java.util.Collections.emptyList());
        }
        request.getRequestDispatcher("/views/admin/gestionar-clave.jsp").forward(request, response);
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private void copiarMensajesDeUrl(HttpServletRequest request) {
        if (request.getParameter("mensaje") != null) {
            request.setAttribute("mensaje", request.getParameter("mensaje"));
        }
        if (request.getParameter("error") != null) {
            request.setAttribute("error", request.getParameter("error"));
        }
    }

    private void redirigir(HttpServletResponse response, HttpServletRequest request,
                            String mensaje, boolean esError) throws IOException {
        String parametro = esError ? "error" : "mensaje";
        String valor = URLEncoder.encode(mensaje, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/admin/seguridad?" + parametro + "=" + valor);
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim().toUpperCase();
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
