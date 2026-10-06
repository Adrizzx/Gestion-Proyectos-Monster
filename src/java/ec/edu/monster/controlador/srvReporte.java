package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOEMPLEADO;
import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Empleado;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Genera el reporte de Personal Activo y Roles.
 * Produce una página HTML optimizada para impresión/PDF.
 * No requiere librerías externas — el usuario imprime con Ctrl+P
 * y selecciona "Guardar como PDF" en el diálogo del navegador.
 */
@WebServlet(name = "srvReporte", urlPatterns = {"/admin/reporte"})
public class srvReporte extends HttpServlet {

    private final DAOEMPLEADO daoEmpleado = new DAOEMPLEADO();
    private final DAOUSUARIO  daoUsuario  = new DAOUSUARIO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!SeguridadWeb.requiereRol(request, response,
                Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH)) {
            return;
        }

        try {
            List<Empleado> empleados = daoEmpleado.listar();
            request.setAttribute("empleados",   empleados);
            request.setAttribute("usuariosMap", construirMap(daoUsuario.listar()));
            request.setAttribute("totalEmpleados", empleados.size());
        } catch (SQLException ex) {
            request.setAttribute("error", "Error al cargar datos: " + ex.getMessage());
            request.setAttribute("empleados",   Collections.emptyList());
            request.setAttribute("usuariosMap", Collections.emptyMap());
            request.setAttribute("totalEmpleados", 0);
        }

        String fechaGen = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss"));
        request.setAttribute("fechaGen", fechaGen);

        // Nombre del usuario que genera el reporte
        Object sesionAttr = request.getSession(false) != null
                ? request.getSession(false).getAttribute("usuarioSesion") : null;
        String generadoPor = (sesionAttr instanceof Usuario)
                ? ((Usuario) sesionAttr).getNombreEmpleado() : "Administrador";
        request.setAttribute("generadoPor", generadoPor);

        request.getRequestDispatcher("/views/admin/reporte.jsp").forward(request, response);
    }

    private Map<String, Usuario> construirMap(List<Usuario> lista) {
        Map<String, Usuario> mapa = new HashMap<>();
        for (Usuario u : lista) {
            mapa.put(u.getCodigoEmpleado(), u);
        }
        return mapa;
    }
}
