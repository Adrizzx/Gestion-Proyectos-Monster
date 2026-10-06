package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOOPCIONES;
import ec.edu.monster.modelo.DAOPERFIL;
import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Opcion;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Gestiona la asignación de opciones de menú a perfiles de seguridad.
 * Permite al administrador controlar qué pantallas puede ver cada perfil.
 */
@WebServlet(name = "srvOpcionesPerfil", urlPatterns = {"/admin/asignar-opciones"})
public class srvOpcionesPerfil extends HttpServlet {

    private final DAOOPCIONES daoOpciones = new DAOOPCIONES();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        copiarMensajesDeUrl(request);
        cargarDatos(request);
        request.getRequestDispatcher("/views/admin/asignar-opciones.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        String perfilCodigo = limpiar(request.getParameter("perfilCodigo"));

        if (perfilCodigo.isEmpty() || !new DAOUSUARIO().esPerfilValido(perfilCodigo)) {
            request.setAttribute("error", "Seleccione un perfil válido.");
            cargarDatos(request);
            request.getRequestDispatcher("/views/admin/asignar-opciones.jsp").forward(request, response);
            return;
        }

        String[] seleccionadas = request.getParameterValues("opcionesSeleccionadas");
        List<String> codigos = (seleccionadas != null)
                ? Arrays.asList(seleccionadas)
                : Collections.emptyList();

        try {
            daoOpciones.asignarOpciones(perfilCodigo, codigos);
            // Forzar recarga de caché de opciones en todas las sesiones activas
            RegistroSesiones.invalidarCacheOpcionesTodas();

            String msg = URLEncoder.encode(
                    "Opciones actualizadas correctamente para el perfil seleccionado.",
                    StandardCharsets.UTF_8);
            response.sendRedirect(request.getContextPath()
                    + "/admin/asignar-opciones?perfilCodigo="
                    + URLEncoder.encode(perfilCodigo, StandardCharsets.UTF_8)
                    + "&mensaje=" + msg);
        } catch (SQLException ex) {
            request.setAttribute("error", "Error al guardar opciones: " + ex.getMessage());
            cargarDatos(request);
            request.getRequestDispatcher("/views/admin/asignar-opciones.jsp").forward(request, response);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private void cargarDatos(HttpServletRequest request) {
        String perfilCodigo = limpiar(request.getParameter("perfilCodigo"));
        try {
            request.setAttribute("perfiles", new DAOPERFIL().listarComoArray());
        } catch (SQLException ex2) {
            request.setAttribute("perfiles", DAOUSUARIO.PERFILES_DISPONIBLES);
        }
        request.setAttribute("perfilSeleccionado", perfilCodigo);

        try {
            List<Opcion> todasOpciones = daoOpciones.listar();
            request.setAttribute("todasOpciones", todasOpciones);

            if (!perfilCodigo.isEmpty()) {
                List<Opcion> asignadas = daoOpciones.listarAsignadasAPerfil(perfilCodigo);
                Set<String> codigosAsignados = new HashSet<>();
                for (Opcion o : asignadas) {
                    codigosAsignados.add(o.getCodigo());
                }
                request.setAttribute("codigosAsignados", codigosAsignados);
            }
        } catch (SQLException ex) {
            request.setAttribute("error", "Error al cargar opciones: " + ex.getMessage());
            request.setAttribute("todasOpciones", Collections.emptyList());
            request.setAttribute("codigosAsignados", Collections.emptySet());
        }
    }

    private void copiarMensajesDeUrl(HttpServletRequest request) {
        if (request.getParameter("mensaje") != null)
            request.setAttribute("mensaje", request.getParameter("mensaje"));
        if (request.getParameter("error") != null)
            request.setAttribute("error", request.getParameter("error"));
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
