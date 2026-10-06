package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Encriptador;
import ec.edu.monster.modelo.PoliticaContrasena;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Auto-servicio de cambio de contraseña para cualquier usuario autenticado.
 * A diferencia de la gestión de contraseñas administrativa, aquí el propio
 * usuario debe confirmar su contraseña actual antes de establecer una nueva.
 */
@WebServlet(name = "srvCambiarClave", urlPatterns = {"/seguridad/cambiar-clave"})
public class srvCambiarClave extends HttpServlet {

    private final DAOUSUARIO daoUsuario = new DAOUSUARIO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereSesion(request, response)) return;

        if (request.getParameter("mensaje") != null)
            request.setAttribute("mensaje", request.getParameter("mensaje"));

        request.getRequestDispatcher("/views/seguridad/cambiar-clave.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereSesion(request, response)) return;

        Usuario usuario = SeguridadWeb.usuarioSesion(request);
        String claveActual   = limpiar(request.getParameter("claveActual"));
        String nuevaClave    = limpiar(request.getParameter("nuevaClave"));
        String confirmarClave = limpiar(request.getParameter("confirmarClave"));

        // ── Validaciones del lado del servidor ──────────────────────────────

        if (claveActual.isEmpty() || nuevaClave.isEmpty() || confirmarClave.isEmpty()) {
            reenviar(request, response, null, "Complete todos los campos.");
            return;
        }

        // Verificar contraseña actual contra el hash almacenado en sesión
        if (!Encriptador.verificar(claveActual, usuario.getPasswordHash())) {
            reenviar(request, response, null, "La contraseña actual es incorrecta.");
            return;
        }

        if (claveActual.equals(nuevaClave)) {
            reenviar(request, response, null,
                    "La nueva contraseña no puede ser igual a la actual.");
            return;
        }

        if (!nuevaClave.equals(confirmarClave)) {
            reenviar(request, response, null, "Las contraseñas no coinciden.");
            return;
        }

        String errPolicy = PoliticaContrasena.validar(nuevaClave);
        if (errPolicy != null) {
            reenviar(request, response, null, errPolicy);
            return;
        }

        // ── Actualizar contraseña en base de datos ───────────────────────────

        try {
            boolean ok = daoUsuario.cambiarPassword(usuario.getCodigoEmpleado(), nuevaClave);
            if (!ok) {
                reenviar(request, response, null, "No se pudo actualizar la contraseña.");
                return;
            }
            // Invalidar sesión → el usuario debe autenticarse de nuevo con la nueva clave
            RegistroSesiones.invalidar(usuario.getCodigoEmpleado());
            String msg = URLEncoder.encode(
                    "Contraseña actualizada correctamente. Inicie sesión con su nueva contraseña.",
                    StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath() + "/login.jsp?mensaje=" + msg);
        } catch (IllegalArgumentException ex) {
            reenviar(request, response, null, ex.getMessage());
        } catch (SQLException ex) {
            reenviar(request, response, null, "Error en base de datos: " + ex.getMessage());
        }
    }

    private void reenviar(HttpServletRequest request, HttpServletResponse response,
                           String mensaje, String error) throws ServletException, IOException {
        if (mensaje != null) request.setAttribute("mensaje", mensaje);
        if (error   != null) request.setAttribute("error",   error);
        request.getRequestDispatcher("/views/seguridad/cambiar-clave.jsp").forward(request, response);
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
