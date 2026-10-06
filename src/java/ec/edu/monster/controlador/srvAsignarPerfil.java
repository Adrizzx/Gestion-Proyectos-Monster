package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOEMPLEADO;
import ec.edu.monster.modelo.DAOPERFIL;
import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Empleado;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Gestiona la asignación masiva de un perfil a uno o varios empleados.
 * Muestra un PickList visual con foto, código y nombre completo.
 */
@WebServlet(name = "srvAsignarPerfil", urlPatterns = {"/admin/asignar-perfil"})
public class srvAsignarPerfil extends HttpServlet {

    private final DAOUSUARIO daoUsuario   = new DAOUSUARIO();
    private final DAOEMPLEADO daoEmpleado = new DAOEMPLEADO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        cargarDatos(request);
        if (request.getParameter("mensaje") != null) {
            request.setAttribute("mensaje", request.getParameter("mensaje"));
        }
        if (request.getParameter("error") != null) {
            request.setAttribute("error", request.getParameter("error"));
        }
        request.getRequestDispatcher("/views/admin/asignar-perfil.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!SeguridadWeb.requiereRol(request, response, Usuario.ROL_ADMINISTRADOR)) return;

        String perfilDestino = limpiar(request.getParameter("perfilDestino"));
        String[] seleccionados = request.getParameterValues("seleccionados");

        if (perfilDestino.isEmpty() || !daoUsuario.esPerfilValido(perfilDestino)) {
            request.setAttribute("error", "Seleccione un perfil de destino válido.");
            cargarDatos(request);
            request.getRequestDispatcher("/views/admin/asignar-perfil.jsp").forward(request, response);
            return;
        }
        if (seleccionados == null || seleccionados.length == 0) {
            request.setAttribute("error", "Seleccione al menos un colaborador para asignar.");
            cargarDatos(request);
            request.getRequestDispatcher("/views/admin/asignar-perfil.jsp").forward(request, response);
            return;
        }

        int actualizados = 0;
        StringBuilder errores = new StringBuilder();
        for (String codigo : seleccionados) {
            try {
                if (daoUsuario.existeUsuario(codigo)) {
                    daoUsuario.cambiarPerfil(codigo, perfilDestino);
                    RegistroSesiones.actualizarRol(codigo, perfilDestino);
                    actualizados++;
                }
            } catch (SQLException ex) {
                errores.append(codigo).append(": ").append(ex.getMessage()).append("; ");
            }
        }

        String msgFinal = actualizados + " usuario(s) actualizado(s) al perfil seleccionado.";
        if (errores.length() > 0) {
            msgFinal += " Errores: " + errores;
        }
        response.sendRedirect(request.getContextPath() + "/admin/asignar-perfil?mensaje="
                + URLEncoder.encode(msgFinal, StandardCharsets.UTF_8));
    }

    private void cargarDatos(HttpServletRequest request) {
        try {
            List<Empleado> empleados = daoEmpleado.listar();
            List<Usuario>  usuarios  = daoUsuario.listar();
            request.setAttribute("empleados", empleados);
            request.setAttribute("usuariosMap", construirMap(usuarios));
        } catch (SQLException ex) {
            request.setAttribute("empleados", Collections.emptyList());
            request.setAttribute("usuariosMap", Collections.emptyMap());
            request.setAttribute("error", "Error al cargar datos: " + ex.getMessage());
        }
        try {
            request.setAttribute("perfiles", new DAOPERFIL().listarComoArray());
        } catch (SQLException ex) {
            request.setAttribute("perfiles", DAOUSUARIO.PERFILES_DISPONIBLES);
        }
    }

    private java.util.Map<String, Usuario> construirMap(List<Usuario> lista) {
        java.util.Map<String, Usuario> mapa = new java.util.HashMap<>();
        for (Usuario u : lista) {
            mapa.put(u.getCodigoEmpleado(), u);
        }
        return mapa;
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
