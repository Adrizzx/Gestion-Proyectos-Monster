package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAODEPARTAMENTO;
import ec.edu.monster.modelo.Departamento;
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

@WebServlet(name = "srvDepartamento", urlPatterns = {"/srvDepartamento", "/admin/departamentos"})
public class srvDepartamento extends HttpServlet {

    private final DAODEPARTAMENTO daoDepartamento = new DAODEPARTAMENTO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) {
            return;
        }

        String accion = obtenerAccion(request);
        try {
            switch (accion) {
                case "editar":
                    prepararEdicion(request);
                    enviarListado(request, response);
                    break;
                case "eliminar":
                    eliminar(request, response);
                    break;
                default:
                    enviarListado(request, response);
                    break;
            }
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarListadoSeguro(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) {
            return;
        }

        String descripcion = limpiar(request.getParameter("descripcion"));
        String codigoOriginal = normalizar(request.getParameter("codigoOriginal"));

        if (descripcion.isEmpty()) {
            request.setAttribute("error", "La descripción es obligatoria.");
            enviarListadoSeguro(request, response);
            return;
        }
        if (descripcion.length() > 50) {
            request.setAttribute("error", "La descripción no puede superar 50 caracteres.");
            enviarListadoSeguro(request, response);
            return;
        }

        try {
            if (codigoOriginal.isEmpty()) {
                // Crear: código auto-incremental
                daoDepartamento.insertarConAutocodigo(descripcion);
                redirigir(request, response, "Departamento registrado correctamente.", false);
            } else {
                // Editar: mantener código existente
                daoDepartamento.actualizar(new Departamento(codigoOriginal, descripcion));
                redirigir(request, response, "Departamento actualizado correctamente.", false);
            }
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            enviarListadoSeguro(request, response);
        }
    }

    private void prepararEdicion(HttpServletRequest request) throws SQLException {
        String codigo = normalizar(request.getParameter("codigo"));
        if (!codigo.isEmpty()) {
            request.setAttribute("departamentoEditar", daoDepartamento.buscarPorCodigo(codigo));
        }
    }

    private void eliminar(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String codigo = normalizar(request.getParameter("codigo"));
        if (codigo.isEmpty()) {
            redirigir(request, response, "Seleccione un departamento para eliminar.", true);
            return;
        }
        String motivoBloqueo = null;
        try {
            motivoBloqueo = daoDepartamento.motivoNoSePuedeEliminar(codigo);
        } catch (SQLException ignore) {
            motivoBloqueo = null;
        }
        if (motivoBloqueo != null) {
            redirigir(request, response, motivoBloqueo, true);
            return;
        }
        try {
            daoDepartamento.eliminar(codigo);
            redirigir(request, response, "Departamento eliminado correctamente.", false);
        } catch (SQLException ex) {
            try {
                motivoBloqueo = daoDepartamento.motivoNoSePuedeEliminar(codigo);
            } catch (SQLException ignore) {
                motivoBloqueo = null;
            }
            redirigir(request, response,
                    motivoBloqueo != null ? motivoBloqueo : "No se puede eliminar el departamento porque esta relacionado con otros registros.",
                    true);
        }
    }

    private void enviarListado(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        request.setAttribute("departamentos", daoDepartamento.listar());
        request.setAttribute("proximoCodigo", daoDepartamento.siguienteCodigo());
        copiarMensajesQueryString(request);
        request.getRequestDispatcher("/departamentos.jsp").forward(request, response);
    }

    private void enviarListadoSeguro(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            request.setAttribute("departamentos", daoDepartamento.listar());
            request.setAttribute("proximoCodigo", daoDepartamento.siguienteCodigo());
        } catch (SQLException ex) {
            request.setAttribute("departamentos", java.util.Collections.emptyList());
            if (request.getAttribute("error") == null) {
                request.setAttribute("error", ex.getMessage());
            }
        }
        request.getRequestDispatcher("/departamentos.jsp").forward(request, response);
    }

    private void copiarMensajesQueryString(HttpServletRequest request) {
        if (request.getParameter("mensaje") != null) {
            request.setAttribute("mensaje", request.getParameter("mensaje"));
        }
        if (request.getParameter("error") != null) {
            request.setAttribute("error", request.getParameter("error"));
        }
    }

    private void redirigir(HttpServletRequest request, HttpServletResponse response, String mensaje, boolean esError) throws IOException {
        String parametro = esError ? "error" : "mensaje";
        String valor = URLEncoder.encode(mensaje, StandardCharsets.UTF_8);
        response.sendRedirect(request.getContextPath() + "/admin/departamentos?" + parametro + "=" + valor);
    }

    private String obtenerAccion(HttpServletRequest request) {
        String accion = request.getParameter("accion");
        return accion == null ? "listar" : accion.trim().toLowerCase();
    }

    private String normalizar(String valor) {
        return valor == null ? "" : valor.trim().toUpperCase();
    }

    private String limpiar(String valor) {
        return valor == null ? "" : valor.trim();
    }
}
