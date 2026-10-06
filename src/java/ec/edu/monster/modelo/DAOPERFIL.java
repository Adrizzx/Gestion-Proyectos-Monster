package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DAOPERFIL {

    // ── Listar todos los perfiles ────────────────────────────────────────────
    public List<Perfil> listar() throws SQLException {
        String sql = "SELECT XEPER_CODIGO, XEPER_DESCRI FROM XEPER_PERFI ORDER BY XEPER_CODIGO";
        List<Perfil> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Perfil(rs.getString(1), rs.getString(2)));
            }
        }
        return lista;
    }

    // ── Buscar por código ───────────────────────────────────────────────────
    public Perfil buscarPorCodigo(String codigo) throws SQLException {
        String sql = "SELECT XEPER_CODIGO, XEPER_DESCRI FROM XEPER_PERFI WHERE XEPER_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigo));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? new Perfil(rs.getString(1), rs.getString(2)) : null;
            }
        }
    }

    // ── Siguiente código libre: PERF0001 → PERF0002 → … ───────────────────
    public String siguienteCodigo() throws SQLException {
        String sql = "SELECT MAX(XEPER_CODIGO) FROM XEPER_PERFI";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getString(1) != null) {
                String ultimo = rs.getString(1); // "PERF0004"
                try {
                    // Extraer solo los dígitos del final
                    String parte = ultimo.replaceAll("[^0-9]", "");
                    int num = Integer.parseInt(parte);
                    return String.format("PERF%04d", num + 1);
                } catch (NumberFormatException ignored) {}
            }
            return "PERF0001";
        }
    }

    // ── Insertar con código auto-generado ───────────────────────────────────
    public Perfil insertar(String descripcion) throws SQLException {
        String codigo = siguienteCodigo();
        String sql = "INSERT INTO XEPER_PERFI (XEPER_CODIGO, XEPER_DESCRI) VALUES (?, ?)";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigo);
            ps.setString(2, descripcion.trim());
            ps.executeUpdate();
        }
        return new Perfil(codigo, descripcion.trim());
    }

    // ── Actualizar descripción ──────────────────────────────────────────────
    public boolean actualizar(String codigo, String descripcion) throws SQLException {
        String sql = "UPDATE XEPER_PERFI SET XEPER_DESCRI = ? WHERE XEPER_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, descripcion.trim());
            ps.setString(2, limpiar(codigo));
            return ps.executeUpdate() > 0;
        }
    }

    // ── Eliminar ────────────────────────────────────────────────────────────
    public boolean eliminar(String codigo) throws SQLException {
        String sql = "DELETE FROM XEPER_PERFI WHERE XEPER_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigo));
            return ps.executeUpdate() > 0;
        }
    }

    // ── Por qué no se puede eliminar (FK check) ─────────────────────────────
    public String motivoNoSePuedeEliminar(String codigo) throws SQLException {
        String cod = limpiar(codigo);

        // Usuarios activos asignados a este perfil
        String sqlUsu = "SELECT COUNT(*) FROM XEUXP_USUPE WHERE XEPER_CODIGO = ? AND XEUXP_FECRET IS NULL";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sqlUsu)) {
            ps.setString(1, cod);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    return "No se puede eliminar: el perfil tiene "
                            + n + (n == 1 ? " usuario asignado." : " usuarios asignados.");
                }
            }
        }

        // Opciones asignadas
        String sqlOpc = "SELECT COUNT(*) FROM XEOXP_OPCPE WHERE XEPER_CODIGO = ? AND XEOXP_FECRET IS NULL";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sqlOpc)) {
            ps.setString(1, cod);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    int n = rs.getInt(1);
                    return "No se puede eliminar: el perfil tiene "
                            + n + (n == 1 ? " opción asignada." : " opciones asignadas.")
                            + " Quite las opciones primero.";
                }
            }
        }

        return null;
    }

    // ── Verificar si el código existe (para validación) ─────────────────────
    public boolean existeCodigo(String codigo) throws SQLException {
        String sql = "SELECT 1 FROM XEPER_PERFI WHERE XEPER_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigo));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    // ── Compatibilidad: lista como String[][] [código, descripción] ──────────
    public String[][] listarComoArray() throws SQLException {
        List<Perfil> lista = listar();
        String[][] arr = new String[lista.size()][2];
        for (int i = 0; i < lista.size(); i++) {
            arr[i][0] = lista.get(i).getCodigo();
            arr[i][1] = lista.get(i).getDescripcion();
        }
        return arr;
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
