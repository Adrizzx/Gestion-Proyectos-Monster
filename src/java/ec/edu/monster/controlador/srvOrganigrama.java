package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOEMPLEADO;
import ec.edu.monster.modelo.Empleado;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
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
 * Construye el organigrama de la empresa:
 * Departamento → Cargo → Empleados.
 * No requiere nuevas consultas: reutiliza DAOEMPLEADO.listar().
 */
@WebServlet(name = "srvOrganigrama", urlPatterns = {"/admin/organigrama"})
public class srvOrganigrama extends HttpServlet {

    private final DAOEMPLEADO daoEmpleado = new DAOEMPLEADO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!SeguridadWeb.requiereRol(request, response,
                Usuario.ROL_ADMINISTRADOR, Usuario.ROL_RRHH)) {
            return;
        }

        try {
            List<Empleado> todos = daoEmpleado.listar();

            // Estructura: departamentoDesc -> cargoDesc -> [empleados]
            Map<String, Map<String, List<Empleado>>> organigrama = new LinkedHashMap<>();

            for (Empleado e : todos) {
                String dept  = emptyDefault(e.getDepartamentoDescripcion(), "Sin departamento");
                String cargo = emptyDefault(e.getCargoDescripcion(), "Sin cargo");

                organigrama
                    .computeIfAbsent(dept,  k -> new LinkedHashMap<>())
                    .computeIfAbsent(cargo, k -> new ArrayList<>())
                    .add(e);
            }

            request.setAttribute("organigrama", organigrama);
            request.setAttribute("totalEmpleados", todos.size());
        } catch (SQLException ex) {
            request.setAttribute("organigrama", new LinkedHashMap<>());
            request.setAttribute("error", "Error al cargar organigrama: " + ex.getMessage());
        }

        request.getRequestDispatcher("/views/admin/organigrama.jsp").forward(request, response);
    }

    private String emptyDefault(String valor, String defVal) {
        return (valor == null || valor.trim().isEmpty()) ? defVal : valor.trim();
    }
}
