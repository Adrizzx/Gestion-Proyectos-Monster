package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DAODEPARTAMENTO {

    public List<Departamento> listar() throws SQLException {
        String sql = "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR ORDER BY PEDEP_CODIGO";
        List<Departamento> departamentos = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                departamentos.add(mapear(rs));
            }
        }
        return departamentos;
    }

    public Departamento buscarPorCodigo(String codigo) throws SQLException {
        String sql = "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapear(rs) : null;
            }
        }
    }

    public boolean insertar(Departamento departamento) throws SQLException {
        String sql = "INSERT INTO PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES (?, ?)";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, departamento.getCodigo());
            ps.setString(2, departamento.getDescripcion());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean actualizar(Departamento departamento) throws SQLException {
        String sql = "UPDATE PEDEP_DEPAR SET PEDEP_DESCRI = ? WHERE PEDEP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, departamento.getDescripcion());
            ps.setString(2, departamento.getCodigo());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean eliminar(String codigo) throws SQLException {
        String sql = "DELETE FROM PEDEP_DEPAR WHERE PEDEP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigo);
            return ps.executeUpdate() > 0;
        }
    }

    public String motivoNoSePuedeEliminar(String codigo) throws SQLException {
        List<String> motivos = new ArrayList<>();

        int empleados = contarRelacionados(
                "SELECT COUNT(*) FROM PEEMP_EMPLE WHERE PEDEP_CODIGO = ? OR PEC_PEDEP_CODIGO = ? OR PED_PEDEP_CODIGO = ? OR PED_PEDEP_CODIGO2 = ?",
                codigo
        );
        if (empleados > 0) {
            motivos.add(formatearCantidad(empleados, "empleado asociado", "empleados asociados"));
        }

        int cargos = contarRelacionados(
                "SELECT COUNT(*) FROM PECAR_CARGO WHERE PEDEP_CODIGO = ?",
                codigo
        );
        if (cargos > 0) {
            motivos.add(formatearCantidad(cargos, "cargo asociado", "cargos asociados"));
        }

        int proyectos = contarRelacionados(
                "SELECT COUNT(*) FROM GEPRO_PROYECT WHERE PEDEP_CODIGO = ?",
                codigo
        );
        if (proyectos > 0) {
            motivos.add(formatearCantidad(proyectos, "proyecto asociado", "proyectos asociados"));
        }

        if (motivos.isEmpty()) {
            return null;
        }
        return "No se puede eliminar el departamento porque tiene " + unirMotivos(motivos) + ".";
    }

    public String siguienteCodigo() throws SQLException {
        String sql = "SELECT MAX(PEDEP_CODIGO) FROM PEDEP_DEPAR";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getString(1) != null) {
                try {
                    int num = Integer.parseInt(rs.getString(1).trim());
                    return String.format("%03d", num + 1);
                } catch (NumberFormatException ignored) {}
            }
            return "001";
        }
    }

    public boolean insertarConAutocodigo(String descripcion) throws SQLException {
        String codigo = siguienteCodigo();
        return insertar(new Departamento(codigo, descripcion.trim()));
    }

    private Departamento mapear(ResultSet rs) throws SQLException {
        return new Departamento(
                rs.getString("PEDEP_CODIGO"),
                rs.getString("PEDEP_DESCRI")
        );
    }

    private int contarRelacionados(String sql, String codigo) throws SQLException {
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            int parametros = 0;
            for (int i = 0; i < sql.length(); i++) {
                if (sql.charAt(i) == '?') {
                    parametros++;
                }
            }
            for (int i = 1; i <= parametros; i++) {
                ps.setString(i, codigo);
            }
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : 0;
            }
        }
    }

    private String formatearCantidad(int cantidad, String singular, String plural) {
        return cantidad == 1 ? "1 " + singular : cantidad + " " + plural;
    }

    private String unirMotivos(List<String> motivos) {
        if (motivos.size() == 1) {
            return motivos.get(0);
        }
        if (motivos.size() == 2) {
            return motivos.get(0) + " y " + motivos.get(1);
        }
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < motivos.size(); i++) {
            if (i > 0) {
                sb.append(i == motivos.size() - 1 ? " y " : ", ");
            }
            sb.append(motivos.get(i));
        }
        return sb.toString();
    }
}
