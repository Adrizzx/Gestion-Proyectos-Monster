package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class DAOPROYECTO {

    // Columnas comunes de proyecto para reutilizar en los SELECT
    private static final String COLS =
            "p.GEPRO_CODIGO, p.PEDEP_CODIGO, p.GEPRO_NOMBRE, p.GEPRO_DESCRI, " +
            "p.GEPRO_PRESUP, p.GEPRO_GASTO, p.GEPRO_FECINI, p.GEPRO_FECFIN, " +
            "p.GEPRO_AVANCE, p.GEPRO_ESTADO, p.GEPRO_RECURS, d.PEDEP_DESCRI AS DEP_DESCRI, " +
            "(SELECT COUNT(*) FROM GR_PEEMP_GEPRO g WHERE g.GEPRO_CODIGO = p.GEPRO_CODIGO) AS TOTAL_EMP";

    // ── Listado completo (todos los proyectos con datos de control) ───────────
    public List<Proyecto> listarTodos() throws SQLException {
        String sql = "SELECT " + COLS + " FROM GEPRO_PROYECT p " +
                "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = p.PEDEP_CODIGO " +
                "ORDER BY p.GEPRO_CODIGO";
        List<Proyecto> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) lista.add(mapearCompleto(rs));
        }
        return lista;
    }

    // ── Proyectos de un empleado (para su vista "Mis proyectos") ──────────────
    public List<Proyecto> listarDetalladoPorEmpleado(String codigoEmpleado) throws SQLException {
        String sql = "SELECT " + COLS + " FROM GEPRO_PROYECT p " +
                "INNER JOIN GR_PEEMP_GEPRO gp ON gp.GEPRO_CODIGO = p.GEPRO_CODIGO " +
                "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = p.PEDEP_CODIGO " +
                "WHERE gp.PEEMP_CODIGO = ? ORDER BY p.GEPRO_CODIGO";
        List<Proyecto> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigoEmpleado));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) lista.add(mapearCompleto(rs));
            }
        }
        return lista;
    }

    // ── Buscar un proyecto por código ─────────────────────────────────────────
    public Proyecto buscarPorCodigo(String codigo) throws SQLException {
        String sql = "SELECT " + COLS + " FROM GEPRO_PROYECT p " +
                "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = p.PEDEP_CODIGO " +
                "WHERE p.GEPRO_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigo));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapearCompleto(rs) : null;
            }
        }
    }

    // ── Siguiente código libre: P01 → P02 → … P99 ─────────────────────────────
    public String siguienteCodigo() throws SQLException {
        String sql = "SELECT MAX(GEPRO_CODIGO) FROM GEPRO_PROYECT";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next() && rs.getString(1) != null) {
                String ultimo = rs.getString(1);
                try {
                    int num = Integer.parseInt(ultimo.replaceAll("[^0-9]", ""));
                    return String.format("P%02d", num + 1);
                } catch (NumberFormatException ignored) {}
            }
            return "P01";
        }
    }

    // ── Crear proyecto (código auto-generado) ─────────────────────────────────
    public Proyecto insertar(Proyecto p) throws SQLException {
        String codigo = siguienteCodigo();
        String sql = "INSERT INTO GEPRO_PROYECT " +
                "(GEPRO_CODIGO, PEDEP_CODIGO, GEPRO_NOMBRE, GEPRO_DESCRI, GEPRO_PRESUP, " +
                " GEPRO_GASTO, GEPRO_FECINI, GEPRO_FECFIN, GEPRO_AVANCE, GEPRO_ESTADO, GEPRO_RECURS) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigo);
            setDepartamento(ps, 2, p.getDepartamentoCodigo());
            ps.setString(3, limpiar(p.getNombre()));
            ps.setString(4, p.getDescripcion());
            ps.setDouble(5, p.getPresupuesto());
            ps.setDouble(6, p.getGasto());
            setFecha(ps, 7, p.getFechaInicio());
            setFecha(ps, 8, p.getFechaFin());
            ps.setInt(9, p.getAvance());
            ps.setString(10, p.getEstado());
            ps.setString(11, p.getRecursos());
            ps.executeUpdate();
        }
        p.setCodigo(codigo);
        return p;
    }

    // ── Actualizar proyecto ───────────────────────────────────────────────────
    public boolean actualizar(Proyecto p) throws SQLException {
        String sql = "UPDATE GEPRO_PROYECT SET " +
                "PEDEP_CODIGO = ?, GEPRO_NOMBRE = ?, GEPRO_DESCRI = ?, GEPRO_PRESUP = ?, " +
                "GEPRO_GASTO = ?, GEPRO_FECINI = ?, GEPRO_FECFIN = ?, GEPRO_AVANCE = ?, " +
                "GEPRO_ESTADO = ?, GEPRO_RECURS = ? WHERE GEPRO_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            setDepartamento(ps, 1, p.getDepartamentoCodigo());
            ps.setString(2, limpiar(p.getNombre()));
            ps.setString(3, p.getDescripcion());
            ps.setDouble(4, p.getPresupuesto());
            ps.setDouble(5, p.getGasto());
            setFecha(ps, 6, p.getFechaInicio());
            setFecha(ps, 7, p.getFechaFin());
            ps.setInt(8, p.getAvance());
            ps.setString(9, p.getEstado());
            ps.setString(10, p.getRecursos());
            ps.setString(11, limpiar(p.getCodigo()));
            return ps.executeUpdate() > 0;
        }
    }

    // ── Eliminar proyecto (primero libera las asignaciones) ───────────────────
    public boolean eliminar(String codigo) throws SQLException {
        String cod = limpiar(codigo);
        try (Connection cn = Conexion.getConexion()) {
            boolean ac = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try (PreparedStatement psAsig = cn.prepareStatement(
                        "DELETE FROM GR_PEEMP_GEPRO WHERE GEPRO_CODIGO = ?");
                 PreparedStatement psPro = cn.prepareStatement(
                        "DELETE FROM GEPRO_PROYECT WHERE GEPRO_CODIGO = ?")) {
                psAsig.setString(1, cod);
                psAsig.executeUpdate();
                psPro.setString(1, cod);
                int filas = psPro.executeUpdate();
                cn.commit();
                cn.setAutoCommit(ac);
                return filas > 0;
            } catch (SQLException ex) {
                cn.rollback();
                cn.setAutoCommit(ac);
                throw ex;
            }
        }
    }

    public boolean existeCodigo(String codigo) throws SQLException {
        String sql = "SELECT 1 FROM GEPRO_PROYECT WHERE GEPRO_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigo));
            try (ResultSet rs = ps.executeQuery()) { return rs.next(); }
        }
    }

    // ── Estadísticas globales (tarjetas resumen) ──────────────────────────────
    public Estadisticas estadisticas() throws SQLException {
        String sql = "SELECT COUNT(*) AS TOTAL, " +
                "COALESCE(SUM(GEPRO_PRESUP),0) AS SUM_PRESUP, " +
                "COALESCE(SUM(GEPRO_GASTO),0)  AS SUM_GASTO, " +
                "COALESCE(AVG(GEPRO_AVANCE),0) AS AVG_AVANCE " +
                "FROM GEPRO_PROYECT";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            Estadisticas e = new Estadisticas();
            if (rs.next()) {
                e.total = rs.getInt("TOTAL");
                e.sumaPresupuesto = rs.getDouble("SUM_PRESUP");
                e.sumaGasto = rs.getDouble("SUM_GASTO");
                e.promedioAvance = rs.getDouble("AVG_AVANCE");
            }
            return e;
        }
    }

    /** Resumen agregado para las tarjetas de la parte superior de la pantalla. */
    public static class Estadisticas {
        public int total;
        public double sumaPresupuesto;
        public double sumaGasto;
        public double promedioAvance;
        public double getSaldo() { return sumaPresupuesto - sumaGasto; }
    }

    // ── Asignación de empleados a un proyecto ─────────────────────────────────

    public Set<String> codigosEmpleadosDe(String codigoProyecto) throws SQLException {
        String sql = "SELECT PEEMP_CODIGO FROM GR_PEEMP_GEPRO WHERE GEPRO_CODIGO = ?";
        Set<String> set = new HashSet<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(codigoProyecto));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) set.add(rs.getString(1));
            }
        }
        return set;
    }

    /** Reemplaza el equipo del proyecto por la lista indicada (transaccional). */
    public boolean asignarEmpleados(String codigoProyecto, List<String> codigosEmpleados) throws SQLException {
        String cod = limpiar(codigoProyecto);
        String sqlDel = "DELETE FROM GR_PEEMP_GEPRO WHERE GEPRO_CODIGO = ?";
        String sqlIns = "INSERT INTO GR_PEEMP_GEPRO (PEEMP_CODIGO, GEPRO_CODIGO) VALUES (?, ?)";
        try (Connection cn = Conexion.getConexion()) {
            boolean ac = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try (PreparedStatement psDel = cn.prepareStatement(sqlDel);
                 PreparedStatement psIns = cn.prepareStatement(sqlIns)) {
                psDel.setString(1, cod);
                psDel.executeUpdate();
                if (codigosEmpleados != null) {
                    Set<String> vistos = new HashSet<>();
                    for (String emp : codigosEmpleados) {
                        String e = limpiar(emp);
                        if (e.isEmpty() || !vistos.add(e)) continue;
                        psIns.setString(1, e);
                        psIns.setString(2, cod);
                        psIns.addBatch();
                    }
                    psIns.executeBatch();
                }
                cn.commit();
                cn.setAutoCommit(ac);
                return true;
            } catch (SQLException ex) {
                cn.rollback();
                cn.setAutoCommit(ac);
                throw ex;
            }
        }
    }

    // ── Mapeo / helpers ───────────────────────────────────────────────────────

    private Proyecto mapearCompleto(ResultSet rs) throws SQLException {
        Proyecto p = new Proyecto();
        p.setCodigo(rs.getString("GEPRO_CODIGO"));
        p.setDepartamentoCodigo(rs.getString("PEDEP_CODIGO"));
        p.setNombre(rs.getString("GEPRO_NOMBRE"));
        p.setDescripcion(rs.getString("GEPRO_DESCRI"));
        p.setPresupuesto(rs.getDouble("GEPRO_PRESUP"));
        p.setGasto(rs.getDouble("GEPRO_GASTO"));
        Date fi = rs.getDate("GEPRO_FECINI");
        Date ff = rs.getDate("GEPRO_FECFIN");
        p.setFechaInicio(fi == null ? null : fi.toLocalDate());
        p.setFechaFin(ff == null ? null : ff.toLocalDate());
        p.setAvance(rs.getInt("GEPRO_AVANCE"));
        p.setEstado(rs.getString("GEPRO_ESTADO"));
        p.setRecursos(rs.getString("GEPRO_RECURS"));
        p.setDepartamentoDescripcion(rs.getString("DEP_DESCRI"));
        p.setTotalEmpleados(rs.getInt("TOTAL_EMP"));
        return p;
    }

    private void setFecha(PreparedStatement ps, int idx, LocalDate fecha) throws SQLException {
        if (fecha == null) ps.setNull(idx, java.sql.Types.DATE);
        else ps.setDate(idx, Date.valueOf(fecha));
    }

    private void setDepartamento(PreparedStatement ps, int idx, String dep) throws SQLException {
        String d = limpiar(dep);
        if (d.isEmpty()) ps.setNull(idx, java.sql.Types.CHAR);
        else ps.setString(idx, d);
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }

    public List<ProyectoReporte> listarConEmpleados() throws SQLException {
        String sql =
            "SELECT p.GEPRO_CODIGO, p.GEPRO_NOMBRE, p.PEDEP_CODIGO, d.PEDEP_DESCRI, " +
            "       e.PEEMP_CODIGO, e.PEEMP_NOMBRE, e.PEEMP_APELLI, e.PEEMP_EMAIL, " +
            "       COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO) AS EMP_DEP_COD, " +
            "       dep.PEDEP_DESCRI AS EMP_DEP_DESCRI, " +
            "       e.PECAR_CODIGOCARGO, c.PECAR_DESCRICARGO " +
            "FROM GEPRO_PROYECT p " +
            "LEFT JOIN PEDEP_DEPAR d  ON d.PEDEP_CODIGO = p.PEDEP_CODIGO " +
            "LEFT JOIN GR_PEEMP_GEPRO gp ON gp.GEPRO_CODIGO = p.GEPRO_CODIGO " +
            "LEFT JOIN PEEMP_EMPLE e  ON e.PEEMP_CODIGO = gp.PEEMP_CODIGO " +
            "LEFT JOIN PEDEP_DEPAR dep ON dep.PEDEP_CODIGO = COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO) " +
            "LEFT JOIN PECAR_CARGO c  ON c.PEDEP_CODIGO = e.PEC_PEDEP_CODIGO " +
            "    AND c.PECAR_CODIGOCARGO = e.PECAR_CODIGOCARGO " +
            "ORDER BY p.GEPRO_CODIGO, e.PEEMP_APELLI, e.PEEMP_NOMBRE";

        Map<String, ProyectoReporte> mapa = new LinkedHashMap<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String cod = rs.getString("GEPRO_CODIGO");
                if (!mapa.containsKey(cod)) {
                    mapa.put(cod, new ProyectoReporte(
                        cod,
                        rs.getString("GEPRO_NOMBRE"),
                        rs.getString("PEDEP_CODIGO"),
                        rs.getString("PEDEP_DESCRI")
                    ));
                }
                ProyectoReporte pr = mapa.get(cod);
                String empCod = rs.getString("PEEMP_CODIGO");
                if (empCod != null) {
                    Empleado emp = new Empleado();
                    emp.setCodigo(empCod);
                    emp.setNombre(rs.getString("PEEMP_NOMBRE"));
                    emp.setApellido(rs.getString("PEEMP_APELLI"));
                    emp.setEmail(rs.getString("PEEMP_EMAIL"));
                    emp.setDepartamentoCodigo(rs.getString("EMP_DEP_COD"));
                    emp.setDepartamentoDescripcion(rs.getString("EMP_DEP_DESCRI"));
                    emp.setCargoCodigo(rs.getString("PECAR_CODIGOCARGO"));
                    emp.setCargoDescripcion(rs.getString("PECAR_DESCRICARGO"));
                    pr.getEmpleados().add(emp);
                }
            }
        }
        return new ArrayList<>(mapa.values());
    }

    public List<Proyecto> listarPorEmpleado(String codigoEmpleado) throws SQLException {
        String sql = "SELECT p.GEPRO_CODIGO, p.GEPRO_NOMBRE, p.PEDEP_CODIGO, d.PEDEP_DESCRI "
                + "FROM GEPRO_PROYECT p "
                + "INNER JOIN GR_PEEMP_GEPRO gp ON gp.GEPRO_CODIGO = p.GEPRO_CODIGO "
                + "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = p.PEDEP_CODIGO "
                + "WHERE gp.PEEMP_CODIGO = ? "
                + "ORDER BY p.GEPRO_CODIGO";
        List<Proyecto> proyectos = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    proyectos.add(new Proyecto(
                            rs.getString("GEPRO_CODIGO"),
                            rs.getString("GEPRO_NOMBRE"),
                            rs.getString("PEDEP_CODIGO"),
                            rs.getString("PEDEP_DESCRI")
                    ));
                }
            }
        }
        return proyectos;
    }
}
