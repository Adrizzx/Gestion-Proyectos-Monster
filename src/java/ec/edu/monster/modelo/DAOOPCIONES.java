package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class DAOOPCIONES {

    // ── Códigos de opción de menú ────────────────────────────────────────────
    public static final String OPC_INICIO              = "001";
    public static final String OPC_GESTION_USUARIOS    = "002";
    public static final String OPC_DEPARTAMENTOS       = "003";
    public static final String OPC_ASIGNAR_PERFILES    = "004";
    public static final String OPC_GESTION_CLAVE       = "005";
    public static final String OPC_ASIGNAR_OPCIONES    = "006";
    public static final String OPC_CAMBIAR_CLAVE       = "007";
    public static final String OPC_GESTION_PERSONAL    = "008";
    public static final String OPC_FAMILIARES          = "009";
    public static final String OPC_ORGANIGRAMA         = "010";
    public static final String OPC_REPORTE_PERSONAL    = "011";
    public static final String OPC_PROYECTOS           = "012";
    public static final String OPC_ASIGNAR_PERSONAL    = "013";
    public static final String OPC_APROBACION_HORAS    = "014";
    public static final String OPC_REPORTES_HORAS      = "015";
    public static final String OPC_REGISTRAR_HORAS     = "016";
    public static final String OPC_GESTION_PERFILES    = "017";
    public static final String OPC_REPORTE_PROYECTOS   = "018";

    // ── Listar todas las opciones del sistema ────────────────────────────────

    public List<Opcion> listar() throws SQLException {
        String sql = "SELECT o.XEOPC_CODIGO, o.XESIS_CODIGO, s.XESIS_DESCRI, o.XEOPC_DESCRI "
                + "FROM XEOPC_OPCIO o "
                + "INNER JOIN XESIS_SISTE s ON s.XESIS_CODIGO = o.XESIS_CODIGO "
                + "ORDER BY o.XESIS_CODIGO, o.XEOPC_CODIGO";
        List<Opcion> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(mapear(rs));
            }
        }
        return lista;
    }

    // ── Opciones actualmente asignadas a un perfil ───────────────────────────

    public List<Opcion> listarAsignadasAPerfil(String perfilCodigo) throws SQLException {
        String sql = "SELECT o.XEOPC_CODIGO, o.XESIS_CODIGO, s.XESIS_DESCRI, o.XEOPC_DESCRI "
                + "FROM XEOPC_OPCIO o "
                + "INNER JOIN XESIS_SISTE s ON s.XESIS_CODIGO = o.XESIS_CODIGO "
                + "INNER JOIN XEOXP_OPCPE xop ON xop.XEOPC_CODIGO = o.XEOPC_CODIGO "
                + "WHERE xop.XEPER_CODIGO = ? AND xop.XEOXP_FECRET IS NULL "
                + "ORDER BY o.XESIS_CODIGO, o.XEOPC_CODIGO";
        List<Opcion> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(perfilCodigo));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    lista.add(mapear(rs));
                }
            }
        }
        return lista;
    }

    // ── Set de códigos permitidos (para chequeo rápido en sidebar) ───────────

    public Set<String> getCodigosParaPerfil(String perfilCodigo) throws SQLException {
        String sql = "SELECT XEOPC_CODIGO FROM XEOXP_OPCPE "
                + "WHERE XEPER_CODIGO = ? AND XEOXP_FECRET IS NULL";
        Set<String> codigos = new HashSet<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(perfilCodigo));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    codigos.add(rs.getString(1));
                }
            }
        }
        return codigos;
    }

    // ── Asignar lista completa de opciones a un perfil (reemplaza) ───────────

    public boolean asignarOpciones(String perfilCodigo, List<String> codigos) throws SQLException {
        String sqlDel = "DELETE FROM XEOXP_OPCPE WHERE XEPER_CODIGO = ? AND XEOXP_FECRET IS NULL";
        String sqlIns = "INSERT INTO XEOXP_OPCPE "
                + "(XEPER_CODIGO, XEOPC_CODIGO, XEOXP_FECASI, XEOXP_FECRET) "
                + "VALUES (?, ?, CURDATE(), NULL)";

        String perfil = limpiar(perfilCodigo);
        if (perfil.isEmpty()) return false;

        try (Connection cn = Conexion.getConexion()) {
            boolean ac = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try (PreparedStatement psDel = cn.prepareStatement(sqlDel);
                 PreparedStatement psIns = cn.prepareStatement(sqlIns)) {

                psDel.setString(1, perfil);
                psDel.executeUpdate();

                for (String codigo : codigos) {
                    if (codigo != null && !codigo.trim().isEmpty()) {
                        psIns.setString(1, perfil);
                        psIns.setString(2, codigo.trim());
                        psIns.addBatch();
                    }
                }
                if (!codigos.isEmpty()) {
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

    // ── Helpers ──────────────────────────────────────────────────────────────

    private Opcion mapear(ResultSet rs) throws SQLException {
        return new Opcion(
                rs.getString("XEOPC_CODIGO"),
                rs.getString("XESIS_CODIGO"),
                rs.getString("XESIS_DESCRI"),
                rs.getString("XEOPC_DESCRI")
        );
    }

    private String limpiar(String v) {
        return v == null ? "" : v.trim();
    }
}
