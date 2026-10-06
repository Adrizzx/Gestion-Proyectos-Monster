package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOPERFIL;
import ec.edu.monster.modelo.Perfil;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * CRUD de perfiles de seguridad.
 * Código generado automáticamente: PERF0001, PERF0002 …
 */
@WebServlet(name = "srvPerfil", urlPatterns = {"/admin/perfiles"})
public class srvPerfil extends HttpServlet {

    private final DAOPERFIL daoPerfil = new DAOPERFIL();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        String accion = limpiar(request.getParameter("accion"));
        try {
            switch (accion) {
                case "editar":
                    prepararEdicion(request);
                    enviarVista(request, response);
                    break;
                case "eliminar":
                    eliminar(request, response);
                    break;
                default:
                    enviarVista(request, response);
                    break;
            }
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarVistaSegura(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        String descripcion     = limpiar(request.getParameter("descripcion"));
        String codigoOriginal  = limpiar(request.getParameter("codigoOriginal"));

        if (descripcion.isEmpty()) {
            request.setAttribute("error", "La descripción es obligatoria.");
            enviarVistaSegura(request, response);
            return;
        }
        if (descripcion.length() > 100) {
            request.setAttribute("error", "La descripción no puede superar 100 caracteres.");
            enviarVistaSegura(request, response);
            return;
        }

        try {
            if (codigoOriginal.isEmpty()) {
                Perfil creado = daoPerfil.insertar(descripcion);
                redirigir(request, response,
                        "Perfil " + creado.getCodigo() + " creado correctamente.", false);
            } else {
                daoPerfil.actualizar(codigoOriginal, descripcion);
                redirigir(request, response, "Perfil actualizado correctamente.", false);
            }
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarVistaSegura(request, response);
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private void prepararEdicion(HttpServletRequest request) throws SQLException {
        String codigo = limpiar(request.getParameter("codigo"));
        if (!codigo.isEmpty()) {
            request.setAttribute("perfilEditar", daoPerfil.buscarPorCodigo(codigo));
        }
    }

    private void eliminar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String codigo = limpiar(request.getParameter("codigo"));
        if (codigo.isEmpty()) {
            redirigir(request, response, "Seleccione un perfil para eliminar.", true);
            return;
        }
        String motivo = daoPerfil.motivoNoSePuedeEliminar(codigo);
        if (motivo != null) {
            redirigir(request, response, motivo, true);
            return;
        }
        try {
            daoPerfil.eliminar(codigo);
            redirigir(request, response, "Perfil eliminado correctamente.", false);
        } catch (SQLException ex) {
            String m2 = daoPerfil.motivoNoSePuedeEliminar(codigo);
            redirigir(request, response,
                    m2 != null ? m2 : "No se puede eliminar el perfil porque está referenciado.",
                    true);
        }
    }

    private void enviarVista(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        cargarDatos(request);
        copiarMensajesUrl(request);
        request.getRequestDispatcher("/views/admin/perfiles.jsp").forward(request, response);
    }

    private void enviarVistaSegura(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            cargarDatos(request);
        } catch (SQLException ex) {
            request.setAttribute("perfiles", java.util.Collections.emptyList());
            if (request.getAttribute("error") == null) {
                request.setAttribute("error", ex.getMessage());
            }
        }
        request.getRequestDispatcher("/views/admin/perfiles.jsp").forward(request, response);
    }

    private void cargarDatos(HttpServletRequest request) throws SQLException {
        List<Perfil> perfiles = daoPerfil.listar();
        request.setAttribute("perfiles", perfiles);
        request.setAttribute("proximoCodigo", daoPerfil.siguienteCodigo());
    }

    private void copiarMensajesUrl(HttpServletRequest request) {
        if (request.getParameter("mensaje") != null)
            request.setAttribute("mensaje", request.getParameter("mensaje"));
        if (request.getParameter("error") != null)
            request.setAttribute("error", request.getParameter("error"));
    }

    private void redirigir(HttpServletRequest request, HttpServletResponse response,
                            String mensaje, boolean esError) throws IOException {
        String param = esError ? "error" : "mensaje";
        String valor = URLEncoder.encode(mensaje, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/admin/perfiles?" + param + "=" + valor);
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
