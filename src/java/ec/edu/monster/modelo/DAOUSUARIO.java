package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DAOUSUARIO {

    public static final String PERFIL_ADMINISTRADOR = "PERF0001";
    public static final String PERFIL_RRHH = "PERF0002";
    public static final String PERFIL_JEFE_DEPARTAMENTO = "PERF0003";
    public static final String PERFIL_EMPLEADO = "PERF0004";

    public static final String[][] PERFILES_DISPONIBLES = {
        {PERFIL_ADMINISTRADOR, Usuario.ROL_ADMINISTRADOR},
        {PERFIL_RRHH, Usuario.ROL_RRHH},
        {PERFIL_JEFE_DEPARTAMENTO, Usuario.ROL_JEFE_DEPARTAMENTO},
        {PERFIL_EMPLEADO, Usuario.ROL_EMPLEADO}
    };

    public Usuario autenticar(String codigoEmpleado, String passwordPlano) throws SQLException {
        String sql = "SELECT u.PEEMP_CODIGO, u.XEUSU_PASWD, u.XEEST_CODIGO, u.XEUSU_FECCRE, "
                + "u.XEUSU_FECMOD, u.XEUSU_PIEFIR, "
                + "CONCAT(e.PEEMP_NOMBRE, ' ', e.PEEMP_APELLI) AS NOMBRE_EMPLEADO, "
                + "COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) AS EMP_DEPARTAMENTO, "
                + "e.PECAR_CODIGOCARGO AS EMP_CARGO, "
                + "es.XEEST_DESCRI, ux.XEPER_CODIGO, p.XEPER_DESCRI "
                + "FROM XEUSU_USUAR u "
                + "INNER JOIN PEEMP_EMPLE e ON e.PEEMP_CODIGO = u.PEEMP_CODIGO "
                + "INNER JOIN XEEST_ESTAD es ON es.XEEST_CODIGO = u.XEEST_CODIGO "
                + "LEFT JOIN XEUXP_USUPE ux ON ux.PEEMP_CODIGO = u.PEEMP_CODIGO "
                + "    AND ux.XEUSU_PASWD = u.XEUSU_PASWD "
                + "    AND ux.XEUXP_FECRET IS NULL "
                + "LEFT JOIN XEPER_PERFI p ON p.XEPER_CODIGO = ux.XEPER_CODIGO "
                + "WHERE u.PEEMP_CODIGO = ? AND u.XEEST_CODIGO = 'A' "
                + "ORDER BY ux.XEUXP_FECASI DESC";

        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, normalizarCodigo(codigoEmpleado));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Usuario usuario = mapear(rs);
                    if (Encriptador.verificar(passwordPlano, usuario.getPasswordHash())) {
                        return usuario;
                    }
                }
            }
        }
        return null;
    }

    public List<Usuario> listar() throws SQLException {
        String sql = "SELECT u.PEEMP_CODIGO, u.XEEST_CODIGO, u.XEUSU_FECCRE, "
                + "u.XEUSU_FECMOD, u.XEUSU_PIEFIR, "
                + "CONCAT(e.PEEMP_NOMBRE, ' ', e.PEEMP_APELLI) AS NOMBRE_EMPLEADO, "
                + "COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) AS EMP_DEPARTAMENTO, "
                + "e.PECAR_CODIGOCARGO AS EMP_CARGO, "
                + "es.XEEST_DESCRI, ux.XEPER_CODIGO, p.XEPER_DESCRI "
                + "FROM XEUSU_USUAR u "
                + "INNER JOIN PEEMP_EMPLE e ON e.PEEMP_CODIGO = u.PEEMP_CODIGO "
                + "INNER JOIN XEEST_ESTAD es ON es.XEEST_CODIGO = u.XEEST_CODIGO "
                + "LEFT JOIN XEUXP_USUPE ux ON ux.PEEMP_CODIGO = u.PEEMP_CODIGO "
                + "    AND ux.XEUSU_PASWD = u.XEUSU_PASWD "
                + "    AND ux.XEUXP_FECRET IS NULL "
                + "LEFT JOIN XEPER_PERFI p ON p.XEPER_CODIGO = ux.XEPER_CODIGO "
                + "ORDER BY u.PEEMP_CODIGO, ux.XEUXP_FECASI DESC";
        List<Usuario> usuarios = new ArrayList<>();
        String ultimoCodigo = null;
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String codigo = rs.getString("PEEMP_CODIGO");
                if (!codigo.equals(ultimoCodigo)) {
                    usuarios.add(mapearListado(rs));
                    ultimoCodigo = codigo;
                }
            }
        }
        return usuarios;
    }

    public boolean insertar(Usuario usuario, String passwordPlano) throws SQLException {
        String sqlUsuario = "INSERT INTO XEUSU_USUAR "
                + "(PEEMP_CODIGO, XEUSU_PASWD, XEEST_CODIGO, XEUSU_FECCRE, XEUSU_FECMOD, XEUSU_PIEFIR) "
                + "VALUES (?, ?, ?, NOW(), NOW(), ?)";
        String sqlPerfil = "INSERT INTO XEUXP_USUPE "
                + "(XEPER_CODIGO, PEEMP_CODIGO, XEUSU_PASWD, XEUXP_FECASI, XEUXP_FECRET) "
                + "VALUES (?, ?, ?, CURDATE(), NULL)";

        String codigoEmpleado = normalizarCodigo(usuario.getCodigoEmpleado());
        String errorContrasena = PoliticaContrasena.validar(passwordPlano);
        if (errorContrasena != null) {
            throw new IllegalArgumentException(errorContrasena);
        }
        String passwordHash = Encriptador.hash(passwordPlano);
        String perfilCodigo = limpiar(usuario.getPerfilCodigo(), PERFIL_EMPLEADO);

        try (Connection cn = Conexion.getConexion()) {
            boolean autoCommit = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try (PreparedStatement psUsuario = cn.prepareStatement(sqlUsuario);
                 PreparedStatement psPerfil = cn.prepareStatement(sqlPerfil)) {
                psUsuario.setString(1, codigoEmpleado);
                psUsuario.setString(2, passwordHash);
                psUsuario.setString(3, limpiar(usuario.getEstadoCodigo(), "A"));
                psUsuario.setString(4, limpiar(usuario.getPieFirma(), "Usuario creado desde MVC"));
                int filasUsuario = psUsuario.executeUpdate();

                psPerfil.setString(1, perfilCodigo);
                psPerfil.setString(2, codigoEmpleado);
                psPerfil.setString(3, passwordHash);
                psPerfil.executeUpdate();

                cn.commit();
                cn.setAutoCommit(autoCommit);
                return filasUsuario > 0;
            } catch (SQLException ex) {
                cn.rollback();
                cn.setAutoCommit(autoCommit);
                throw ex;
            }
        }
    }

    public boolean insertarEmpleadoYUsuario(Usuario usuario, String passwordPlano,
                                           String nombre, String apellido, String cedula,
                                           String email, String telefono, String departamento,
                                           String cargo) throws SQLException {
        // SQL para insertar en PEEMP_EMPLE
        String sqlEmpleado = "INSERT INTO PEEMP_EMPLE "
                + "(PEEMP_CODIGO, PEC_PEDEP_CODIGO, PECAR_CODIGOCARGO, PEDEP_CODIGO, PESEX_CODIGO, "
                + "PED_PEDEP_CODIGO, PED_PEDEP_CODIGO2, PEEMP_APELLI, PEEMP_NOMBRE, "
                + "PEEMP_FECNAC, PEEMP_FECSAL, PEEMP_DIREC, PEEMP_TELEF, PEEMP_EMAIL, "
                + "PEEMP_CEDULA, PEEMP_CARFAM, PEEMP_PASAPO, PEEMP_DISCAP) "
                + "VALUES (?, ?, ?, ?, 'M', ?, ?, ?, ?, '1990-01-01', '2025-01-01', "
                + "'No especificado', ?, ?, ?, 0, 'N/A', 'N')";

        String sqlUsuario = "INSERT INTO XEUSU_USUAR "
                + "(PEEMP_CODIGO, XEUSU_PASWD, XEEST_CODIGO, XEUSU_FECCRE, XEUSU_FECMOD, XEUSU_PIEFIR) "
                + "VALUES (?, ?, ?, NOW(), NOW(), ?)";
        
        String sqlPerfil = "INSERT INTO XEUXP_USUPE "
                + "(XEPER_CODIGO, PEEMP_CODIGO, XEUSU_PASWD, XEUXP_FECASI, XEUXP_FECRET) "
                + "VALUES (?, ?, ?, CURDATE(), NULL)";

        String codigoEmpleado = normalizarCodigo(usuario.getCodigoEmpleado());
        String errorContrasena = PoliticaContrasena.validar(passwordPlano);
        if (errorContrasena != null) {
            throw new IllegalArgumentException(errorContrasena);
        }
        
        String passwordHash = Encriptador.hash(passwordPlano);
        String perfilCodigo = limpiar(usuario.getPerfilCodigo(), PERFIL_EMPLEADO);

        try (Connection cn = Conexion.getConexion()) {
            boolean autoCommit = cn.getAutoCommit();
            cn.setAutoCommit(false);
            
            try (PreparedStatement psEmpleado = cn.prepareStatement(sqlEmpleado);
                 PreparedStatement psUsuario = cn.prepareStatement(sqlUsuario);
                 PreparedStatement psPerfil = cn.prepareStatement(sqlPerfil)) {

                // Insertar empleado
                psEmpleado.setString(1, codigoEmpleado);
                psEmpleado.setString(2, limpiar(departamento, "001"));
                psEmpleado.setString(3, limpiar(cargo, "EMP"));
                psEmpleado.setString(4, limpiar(departamento, "001"));
                psEmpleado.setString(5, limpiar(departamento, "001"));
                psEmpleado.setString(6, limpiar(departamento, "001"));
                psEmpleado.setString(7, limpiar(apellido, ""));
                psEmpleado.setString(8, limpiar(nombre, ""));
                psEmpleado.setString(9, limpiar(telefono, ""));
                psEmpleado.setString(10, limpiar(email, ""));
                psEmpleado.setString(11, limpiar(cedula, ""));
                int filasEmpleado = psEmpleado.executeUpdate();

                if (filasEmpleado <= 0) {
                    throw new SQLException("No se pudo insertar el empleado");
                }

                // Insertar usuario
                psUsuario.setString(1, codigoEmpleado);
                psUsuario.setString(2, passwordHash);
                psUsuario.setString(3, limpiar(usuario.getEstadoCodigo(), "A"));
                psUsuario.setString(4, limpiar(usuario.getPieFirma(), "Empleado creado desde MVC"));
                int filasUsuario = psUsuario.executeUpdate();

                if (filasUsuario <= 0) {
                    throw new SQLException("No se pudo insertar el usuario");
                }

                // Insertar perfil
                psPerfil.setString(1, perfilCodigo);
                psPerfil.setString(2, codigoEmpleado);
                psPerfil.setString(3, passwordHash);
                psPerfil.executeUpdate();

                cn.commit();
                cn.setAutoCommit(autoCommit);
                return true;
            } catch (SQLException ex) {
                cn.rollback();
                cn.setAutoCommit(autoCommit);
                throw ex;
            }
        }
    }

    public boolean cambiarEstado(String codigoEmpleado, String estado) throws SQLException {
        String sql = "UPDATE XEUSU_USUAR SET XEEST_CODIGO = ?, XEUSU_FECMOD = NOW() WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, limpiar(estado, "A"));
            ps.setString(2, normalizarCodigo(codigoEmpleado));
            return ps.executeUpdate() > 0;
        }
    }

    public boolean cambiarPerfil(String codigoEmpleado, String perfilCodigo) throws SQLException {
        String codigo = normalizarCodigo(codigoEmpleado);
        String perfil = limpiar(perfilCodigo, PERFIL_EMPLEADO);

        try (Connection cn = Conexion.getConexion()) {
            boolean autoCommit = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try {
                String passwordHash = obtenerPasswordHash(cn, codigo);
                if (passwordHash == null) {
                    cn.rollback();
                    cn.setAutoCommit(autoCommit);
                    return false;
                }
                String perfilActual = obtenerPerfilActual(cn, codigo, passwordHash);
                if (perfil.equals(perfilActual)) {
                    cn.commit();
                    cn.setAutoCommit(autoCommit);
                    return true;
                }
                cerrarPerfilesActivos(cn, codigo, passwordHash);
                insertarPerfil(cn, codigo, passwordHash, perfil);
                cn.commit();
                cn.setAutoCommit(autoCommit);
                return true;
            } catch (SQLException ex) {
                cn.rollback();
                cn.setAutoCommit(autoCommit);
                throw ex;
            }
        }
    }

    public boolean existeEmpleado(String codigoEmpleado) throws SQLException {
        String sql = "SELECT 1 FROM PEEMP_EMPLE WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, normalizarCodigo(codigoEmpleado));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean existeUsuario(String codigoEmpleado) throws SQLException {
        String sql = "SELECT 1 FROM XEUSU_USUAR WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, normalizarCodigo(codigoEmpleado));
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public boolean esPerfilValido(String perfilCodigo) {
        String perfil = limpiar(perfilCodigo, "");
        if (perfil.isEmpty()) return false;
        for (String[] opcion : PERFILES_DISPONIBLES) {
            if (opcion[0].equals(perfil)) return true;
        }
        try {
            return new DAOPERFIL().existeCodigo(perfil);
        } catch (java.sql.SQLException ex) {
            return false;
        }
    }

    private String obtenerPasswordHash(Connection cn, String codigoEmpleado) throws SQLException {
        String sql = "SELECT XEUSU_PASWD FROM XEUSU_USUAR WHERE PEEMP_CODIGO = ? ORDER BY XEUSU_FECMOD DESC LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("XEUSU_PASWD") : null;
            }
        }
    }

    private String obtenerPerfilActual(Connection cn, String codigoEmpleado, String passwordHash) throws SQLException {
        String sql = "SELECT XEPER_CODIGO FROM XEUXP_USUPE "
                + "WHERE PEEMP_CODIGO = ? AND XEUSU_PASWD = ? AND XEUXP_FECRET IS NULL "
                + "ORDER BY XEUXP_FECASI DESC LIMIT 1";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            ps.setString(2, passwordHash);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getString("XEPER_CODIGO") : null;
            }
        }
    }

    private void cerrarPerfilesActivos(Connection cn, String codigoEmpleado, String passwordHash) throws SQLException {
        String sql = "UPDATE XEUXP_USUPE SET XEUXP_FECRET = CURDATE() "
                + "WHERE PEEMP_CODIGO = ? AND XEUSU_PASWD = ? AND XEUXP_FECRET IS NULL";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            ps.setString(2, passwordHash);
            ps.executeUpdate();
        }
    }

    private void insertarPerfil(Connection cn, String codigoEmpleado, String passwordHash, String perfilCodigo) throws SQLException {
        String sql = "INSERT INTO XEUXP_USUPE "
                + "(XEPER_CODIGO, PEEMP_CODIGO, XEUSU_PASWD, XEUXP_FECASI, XEUXP_FECRET) "
                + "VALUES (?, ?, ?, CURDATE(), NULL) "
                + "ON DUPLICATE KEY UPDATE XEUXP_FECRET = NULL";
        try (PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, perfilCodigo);
            ps.setString(2, codigoEmpleado);
            ps.setString(3, passwordHash);
            ps.executeUpdate();
        }
    }

    private Usuario mapear(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setCodigoEmpleado(rs.getString("PEEMP_CODIGO"));
        usuario.setPasswordHash(rs.getString("XEUSU_PASWD"));
        usuario.setEstadoCodigo(rs.getString("XEEST_CODIGO"));
        usuario.setFechaCreacion(toLocalDateTime(rs.getTimestamp("XEUSU_FECCRE")));
        usuario.setFechaModificacion(toLocalDateTime(rs.getTimestamp("XEUSU_FECMOD")));
        usuario.setPieFirma(rs.getString("XEUSU_PIEFIR"));
        usuario.setNombreEmpleado(rs.getString("NOMBRE_EMPLEADO"));
        usuario.setEstadoDescripcion(rs.getString("XEEST_DESCRI"));
        usuario.setDepartamentoCodigo(rs.getString("EMP_DEPARTAMENTO"));
        usuario.setCargoCodigo(rs.getString("EMP_CARGO"));
        usuario.setPerfilCodigo(rs.getString("XEPER_CODIGO"));
        usuario.setPerfilDescripcion(rs.getString("XEPER_DESCRI"));
        usuario.setRolUsuario(resolverRol(usuario));
        ajustarPerfilLegado(usuario);
        return usuario;
    }

    private Usuario mapearListado(ResultSet rs) throws SQLException {
        Usuario usuario = new Usuario();
        usuario.setCodigoEmpleado(rs.getString("PEEMP_CODIGO"));
        usuario.setEstadoCodigo(rs.getString("XEEST_CODIGO"));
        usuario.setFechaCreacion(toLocalDateTime(rs.getTimestamp("XEUSU_FECCRE")));
        usuario.setFechaModificacion(toLocalDateTime(rs.getTimestamp("XEUSU_FECMOD")));
        usuario.setPieFirma(rs.getString("XEUSU_PIEFIR"));
        usuario.setNombreEmpleado(rs.getString("NOMBRE_EMPLEADO"));
        usuario.setEstadoDescripcion(rs.getString("XEEST_DESCRI"));
        usuario.setDepartamentoCodigo(rs.getString("EMP_DEPARTAMENTO"));
        usuario.setCargoCodigo(rs.getString("EMP_CARGO"));
        usuario.setPerfilCodigo(rs.getString("XEPER_CODIGO"));
        usuario.setPerfilDescripcion(rs.getString("XEPER_DESCRI"));
        usuario.setRolUsuario(resolverRol(usuario));
        ajustarPerfilLegado(usuario);
        return usuario;
    }

    private void ajustarPerfilLegado(Usuario usuario) {
        String descripcion = limpiar(usuario.getPerfilDescripcion(), "").toLowerCase();
        if (usuario.getPerfilCodigo() == null || descripcion.contains("operador")) {
            usuario.setPerfilCodigo(perfilDesdeRol(usuario.getRolUsuario()));
        }
    }

    private String perfilDesdeRol(String rol) {
        if (Usuario.ROL_ADMINISTRADOR.equals(rol)) {
            return PERFIL_ADMINISTRADOR;
        }
        if (Usuario.ROL_RRHH.equals(rol)) {
            return PERFIL_RRHH;
        }
        if (Usuario.ROL_JEFE_DEPARTAMENTO.equals(rol)) {
            return PERFIL_JEFE_DEPARTAMENTO;
        }
        return PERFIL_EMPLEADO;
    }

    private String resolverRol(Usuario usuario) {
        String descripcion = limpiar(usuario.getPerfilDescripcion(), "").toLowerCase();
        if (descripcion.contains("administrador")) {
            return Usuario.ROL_ADMINISTRADOR;
        }
        if (descripcion.contains("recursos humanos") || descripcion.contains("rrhh")) {
            return Usuario.ROL_RRHH;
        }
        if (descripcion.contains("jefe")) {
            return Usuario.ROL_JEFE_DEPARTAMENTO;
        }
        if (descripcion.contains("empleado")) {
            return Usuario.ROL_EMPLEADO;
        }

        String departamento = limpiar(usuario.getDepartamentoCodigo(), "");
        String cargo = limpiar(usuario.getCargoCodigo(), "");
        if ("ADM".equals(cargo)) {
            return Usuario.ROL_ADMINISTRADOR;
        }
        if ("002".equals(departamento)) {
            return Usuario.ROL_RRHH;
        }
        if ("JPR".equals(cargo)) {
            return Usuario.ROL_JEFE_DEPARTAMENTO;
        }

        String perfilCodigo = limpiar(usuario.getPerfilCodigo(), "");
        if (PERFIL_ADMINISTRADOR.equals(perfilCodigo)) {
            return Usuario.ROL_ADMINISTRADOR;
        }
        if (PERFIL_RRHH.equals(perfilCodigo)) {
            return Usuario.ROL_RRHH;
        }
        if (PERFIL_JEFE_DEPARTAMENTO.equals(perfilCodigo)) {
            return Usuario.ROL_JEFE_DEPARTAMENTO;
        }
        return Usuario.ROL_EMPLEADO;
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        return timestamp == null ? null : timestamp.toLocalDateTime();
    }

    private String normalizarCodigo(String valor) {
        return valor == null ? "" : valor.trim().toUpperCase();
    }

    private String limpiar(String valor, String valorDefault) {
        return valor == null || valor.trim().isEmpty() ? valorDefault : valor.trim();
    }

    // ── Gestión de contraseñas ────────────────────────────────────────────────

    /**
     * Cambia la contraseña respetando la FK compuesta (PEEMP_CODIGO, XEUSU_PASWD)
     * que XEUXP_USUPE tiene sobre XEUSU_USUAR.
     *
     * Problema: MySQL no permite UPDATE en XEUSU_USUAR mientras XEUXP_USUPE
     * referencia el hash antiguo; tampoco permite UPDATE en XEUXP_USUPE hacia
     * un hash que aún no existe en XEUSU_USUAR (dependencia circular).
     *
     * Solución: en una sola transacción —
     *   1. Leer el perfil activo actual.
     *   2. Eliminar TODOS los registros de XEUXP_USUPE del empleado (libera la FK).
     *   3. Actualizar el hash en XEUSU_USUAR.
     *   4. Re-insertar el perfil con el nuevo hash.
     */
    public boolean cambiarPassword(String codigoEmpleado, String nuevaPasswordPlano) throws SQLException {
        String err = PoliticaContrasena.validar(nuevaPasswordPlano);
        if (err != null) throw new IllegalArgumentException(err);

        String codigo    = normalizarCodigo(codigoEmpleado);
        String nuevoHash = Encriptador.hash(nuevaPasswordPlano);

        String sqlGetPerfil = "SELECT XEPER_CODIGO FROM XEUXP_USUPE "
                + "WHERE PEEMP_CODIGO = ? AND XEUXP_FECRET IS NULL "
                + "ORDER BY XEUXP_FECASI DESC LIMIT 1";
        String sqlDelPerfil = "DELETE FROM XEUXP_USUPE WHERE PEEMP_CODIGO = ?";
        String sqlUpdUser   = "UPDATE XEUSU_USUAR SET XEUSU_PASWD = ?, XEUSU_FECMOD = NOW() WHERE PEEMP_CODIGO = ?";
        String sqlInsPerfil = "INSERT INTO XEUXP_USUPE "
                + "(XEPER_CODIGO, PEEMP_CODIGO, XEUSU_PASWD, XEUXP_FECASI, XEUXP_FECRET) "
                + "VALUES (?, ?, ?, CURDATE(), NULL)";

        try (Connection cn = Conexion.getConexion()) {
            boolean ac = cn.getAutoCommit();
            cn.setAutoCommit(false);
            try {
                // 1. Guardar perfil activo
                String perfilActual = null;
                try (PreparedStatement ps = cn.prepareStatement(sqlGetPerfil)) {
                    ps.setString(1, codigo);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) perfilActual = rs.getString(1);
                    }
                }
                if (perfilActual == null) perfilActual = PERFIL_EMPLEADO;

                // 2. Eliminar perfiles (libera FK)
                try (PreparedStatement ps = cn.prepareStatement(sqlDelPerfil)) {
                    ps.setString(1, codigo);
                    ps.executeUpdate();
                }

                // 3. Actualizar hash en tabla de usuarios
                int filas;
                try (PreparedStatement ps = cn.prepareStatement(sqlUpdUser)) {
                    ps.setString(1, nuevoHash);
                    ps.setString(2, codigo);
                    filas = ps.executeUpdate();
                }

                // 4. Re-insertar perfil con nuevo hash
                try (PreparedStatement ps = cn.prepareStatement(sqlInsPerfil)) {
                    ps.setString(1, perfilActual);
                    ps.setString(2, codigo);
                    ps.setString(3, nuevoHash);
                    ps.executeUpdate();
                }

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

    /**
     * Crea el registro de seguridad (usuario + perfil base EMPLEADO) para un
     * empleado que ya existe en PEEMP_EMPLE. Si el usuario ya existe, no hace
     * nada y retorna true. Permite que RRHH registre empleados sin pasar por
     * el módulo de Seguridad.
     */
    public boolean crearPerfilBase(String codigoEmpleado, String passwordTemporal) throws SQLException {
        if (existeUsuario(codigoEmpleado)) {
            return true;
        }
        Usuario u = new Usuario();
        u.setCodigoEmpleado(codigoEmpleado);
        u.setEstadoCodigo("A");
        u.setPerfilCodigo(PERFIL_EMPLEADO);
        u.setPieFirma("Creado desde RRHH");
        return insertar(u, passwordTemporal);
    }
}
