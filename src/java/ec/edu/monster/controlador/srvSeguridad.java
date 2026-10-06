package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet(name = "srvSeguridad", urlPatterns = {"/srvSeguridad"})
public class srvSeguridad extends HttpServlet {

    private final DAOUSUARIO daoUsuario = new DAOUSUARIO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String accion = request.getParameter("accion");
        if ("salir".equalsIgnoreCase(accion)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/login.jsp?mensaje=Sesi%C3%B3n%20cerrada%20correctamente");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String usuario = request.getParameter("usuario");
        String clave = request.getParameter("clave");

        if (estaVacio(usuario) || estaVacio(clave)) {
            request.setAttribute("error", "Ingrese usuario y contraseña.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        try {
            Usuario usuarioAutenticado = daoUsuario.autenticar(usuario, clave);
            if (usuarioAutenticado == null) {
                request.setAttribute("error", "Usuario o contraseña incorrectos, o usuario inactivo.");
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioSesion", usuarioAutenticado);
            session.setAttribute("rolUsuario", usuarioAutenticado.getRolUsuario());
            session.setMaxInactiveInterval(30 * 60);
            // Registrar en el mapa global para permitir actualización de rol en tiempo real.
            RegistroSesiones.registrar(usuarioAutenticado.getCodigoEmpleado(), session);
            response.sendRedirect(request.getContextPath() + SeguridadWeb.rutaDashboard(usuarioAutenticado));
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }

    private boolean estaVacio(String valor) {
        return valor == null || valor.trim().isEmpty();
    }
}
