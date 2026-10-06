package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

/**
 * Acceso a datos de Empleados
 */
public class DAOEMPLEADO {

    /**
     * Generar el siguiente código incremental de empleado
     */
    public String generarCodigoSiguiente() throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(PEEMP_CODIGO, 4, 3) AS UNSIGNED)) AS ultimo_numero "
                + "FROM PEEMP_EMPLE "
                + "WHERE PEEMP_CODIGO LIKE 'EMP%'";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int numero = rs.getInt("ultimo_numero") + 1;
                return String.format("EMP%03d", numero);
            }
        }
        return "EMP001";
    }

    /**
     * Listar todos los empleados
     */
    public List<Empleado> listar() throws SQLException {
        String sql = "SELECT e.PEEMP_CODIGO, e.PEEMP_NOMBRE, e.PEEMP_APELLI, "
                + "e.PEEMP_CEDULA, e.PEEMP_EMAIL, e.PEEMP_TELEF, "
                + "COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) AS PEDEP_CODIGO, "
                + "e.PECAR_CODIGOCARGO, e.PESEX_CODIGO, "
                + "e.PEESC_CODIGO, e.PEEMP_FECNAC, e.PEEMP_FECSAL, "
                + "e.PEEMP_DIREC, e.PEEMP_PASAPO, e.PEEMP_CARFAM, e.PEEMP_FOTO, "
                + "d.PEDEP_DESCRI, c.PECAR_DESCRICARGO, s.PESEX_DESCRI, e2.PEESC_DESCRI "
                + "FROM PEEMP_EMPLE e "
                + "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) "
                + "LEFT JOIN PECAR_CARGO c ON c.PEDEP_CODIGO = e.PEC_PEDEP_CODIGO "
                + "    AND c.PECAR_CODIGOCARGO = e.PECAR_CODIGOCARGO "
                + "LEFT JOIN PESEX_SEXO s ON s.PESEX_CODIGO = e.PESEX_CODIGO "
                + "LEFT JOIN PEESC_ESTCIV e2 ON e2.PEESC_CODIGO = e.PEESC_CODIGO "
                + "ORDER BY e.PEEMP_CODIGO";
        List<Empleado> empleados = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                empleados.add(mapear(rs));
            }
        }
        return empleados;
    }

    /**
     * Obtener un empleado por código
     */
    public Empleado obtenerPorCodigo(String codigo) throws SQLException {
        String sql = "SELECT e.PEEMP_CODIGO, e.PEEMP_NOMBRE, e.PEEMP_APELLI, "
                + "e.PEEMP_CEDULA, e.PEEMP_EMAIL, e.PEEMP_TELEF, "
                + "COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) AS PEDEP_CODIGO, "
                + "e.PECAR_CODIGOCARGO, e.PESEX_CODIGO, "
                + "e.PEESC_CODIGO, e.PEEMP_FECNAC, e.PEEMP_FECSAL, "
                + "e.PEEMP_DIREC, e.PEEMP_PASAPO, e.PEEMP_CARFAM, e.PEEMP_FOTO, "
                + "d.PEDEP_DESCRI, c.PECAR_DESCRICARGO, s.PESEX_DESCRI, e2.PEESC_DESCRI "
                + "FROM PEEMP_EMPLE e "
                + "LEFT JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = COALESCE(e.PEDEP_CODIGO, e.PEC_PEDEP_CODIGO, e.PED_PEDEP_CODIGO) "
                + "LEFT JOIN PECAR_CARGO c ON c.PEDEP_CODIGO = e.PEC_PEDEP_CODIGO "
                + "    AND c.PECAR_CODIGOCARGO = e.PECAR_CODIGOCARGO "
                + "LEFT JOIN PESEX_SEXO s ON s.PESEX_CODIGO = e.PESEX_CODIGO "
                + "LEFT JOIN PEESC_ESTCIV e2 ON e2.PEESC_CODIGO = e.PEESC_CODIGO "
                + "WHERE e.PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapear(rs);
                }
            }
        }
        return null;
    }

    /**
     * Verificar si existe un empleado
     */
    public boolean existe(String codigo) throws SQLException {
        return obtenerPorCodigo(codigo) != null;
    }

    /**
     * Insertar nuevo empleado
     */
    public void insertar(Empleado empleado) throws SQLException {
        String sql = "INSERT INTO PEEMP_EMPLE "
                + "(PEEMP_CODIGO, PEC_PEDEP_CODIGO, PECAR_CODIGOCARGO, PEE_PEEMP_CODIGO, "
                + "PEDEP_CODIGO, PEE_PEEMP_CODIGO2, PESEX_CODIGO, PED_PEDEP_CODIGO, "
                + "PEESC_CODIGO, PED_PEDEP_CODIGO2, PEEMP_APELLI, PEEMP_NOMBRE, "
                + "PEEMP_FECNAC, PEEMP_FECSAL, PEEMP_DIREC, PEEMP_TELEF, PEEMP_EMAIL, "
                + "PEEMP_CEDULA, PEEMP_FOTO, PEEMP_CARFAM, PEEMP_PASAPO, PEEMP_DISCAP) "
                + "VALUES (?, ?, ?, NULL, ?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, X'00')";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, empleado.getCodigo());
            ps.setString(2, empleado.getDepartamentoCodigo());      // PEC_PEDEP_CODIGO
            ps.setString(3, empleado.getCargoCodigo());             // PECAR_CODIGOCARGO
            // ps.setNull(4, Types.CHAR); // PEE_PEEMP_CODIGO - NULL (implícito)
            ps.setString(4, empleado.getDepartamentoCodigo());      // PEDEP_CODIGO
            // ps.setNull(5, Types.CHAR); // PEE_PEEMP_CODIGO2 - NULL (implícito)
            ps.setString(5, empleado.getSexoCodigo());              // PESEX_CODIGO
            ps.setString(6, empleado.getDepartamentoCodigo());      // PED_PEDEP_CODIGO
            ps.setString(7, empleado.getEstadoCivilCodigo());       // PEESC_CODIGO
            ps.setString(8, empleado.getDepartamentoCodigo());      // PED_PEDEP_CODIGO2
            ps.setString(9, empleado.getApellido());                // PEEMP_APELLI
            ps.setString(10, empleado.getNombre());                 // PEEMP_NOMBRE
            ps.setDate(11, new Date(empleado.getFechaNacimiento().getTime()));  // PEEMP_FECNAC
            ps.setDate(12, new Date(empleado.getFechaSalida().getTime()));      // PEEMP_FECSAL
            ps.setString(13, empleado.getDireccion());              // PEEMP_DIREC
            ps.setString(14, empleado.getTelefono());               // PEEMP_TELEF
            ps.setString(15, empleado.getEmail());                  // PEEMP_EMAIL
            ps.setString(16, empleado.getCedula());                 // PEEMP_CEDULA
            ps.setString(17, empleado.getFotoRuta());               // PEEMP_FOTO
            ps.setInt(18, empleado.getCargosFamiliares() != null ? empleado.getCargosFamiliares() : 0);  // PEEMP_CARFAM
            ps.setString(19, valorNoNulo(empleado.getPasaporte())); // PEEMP_PASAPO
            // ps.setBlob(20, X'00'); // PEEMP_DISCAP - X'00' (implícito en VALUES)
            ps.executeUpdate();
        }
    }

    /**
     * Actualizar datos generales del empleado
     */
    public void actualizar(Empleado empleado) throws SQLException {
        String sql = "UPDATE PEEMP_EMPLE SET "
                + "PEC_PEDEP_CODIGO = ?, PECAR_CODIGOCARGO = ?, PEDEP_CODIGO = ?, "
                + "PED_PEDEP_CODIGO = ?, PED_PEDEP_CODIGO2 = ?, "
                + "PEEMP_NOMBRE = ?, PEEMP_APELLI = ?, PESEX_CODIGO = ?, PEESC_CODIGO = ?, "
                + "PEEMP_FECNAC = ?, PEEMP_FECSAL = ?, PEEMP_DIREC = ?, "
                + "PEEMP_TELEF = ?, PEEMP_EMAIL = ?, PEEMP_CEDULA = ?, "
                + "PEEMP_PASAPO = ?, PEEMP_FOTO = ? "
                + "WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, empleado.getDepartamentoCodigo());
            ps.setString(2, empleado.getCargoCodigo());
            ps.setString(3, empleado.getDepartamentoCodigo());
            ps.setString(4, empleado.getDepartamentoCodigo());
            ps.setString(5, empleado.getDepartamentoCodigo());
            ps.setString(6, empleado.getNombre());
            ps.setString(7, empleado.getApellido());
            ps.setString(8, empleado.getSexoCodigo());
            ps.setString(9, empleado.getEstadoCivilCodigo());
            ps.setDate(10, new Date(empleado.getFechaNacimiento().getTime()));
            ps.setDate(11, new Date(empleado.getFechaSalida().getTime()));
            ps.setString(12, empleado.getDireccion());
            ps.setString(13, empleado.getTelefono());
            ps.setString(14, empleado.getEmail());
            ps.setString(15, empleado.getCedula());
            ps.setString(16, valorNoNulo(empleado.getPasaporte()));
            ps.setString(17, empleado.getFotoRuta());
            ps.setString(18, empleado.getCodigo());
            ps.executeUpdate();
        }
    }

    /**
     * Actualizar foto del empleado
     */
    public void actualizarFoto(String codigoEmpleado, String rutaFoto) throws SQLException {
        String sql = "UPDATE PEEMP_EMPLE SET PEEMP_FOTO = ? WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, rutaFoto);
            ps.setString(2, codigoEmpleado);
            ps.executeUpdate();
        }
    }

    /**
     * Listar educación de un empleado
     */
    public List<Educacion> listarEducacion(String codigoEmpleado) throws SQLException {
        String sql = "SELECT PEEDU_CODIGO, PEEMP_CODIGO, PEEDU_TITULO, PEEDU_INSTITUCION, "
                + "PEEDU_FECGRADO, PEEDU_FECINI FROM PEEDU_EDUCACION "
                + "WHERE PEEMP_CODIGO = ? ORDER BY PEEDU_FECGRADO DESC";
        List<Educacion> educaciones = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    educaciones.add(mapearEducacion(rs));
                }
            }
        }
        return educaciones;
    }

    /**
     * Insertar educación de empleado
     */
    public void insertarEducacion(Educacion educacion) throws SQLException {
        String sql = "INSERT INTO PEEDU_EDUCACION "
                + "(PEEDU_CODIGO, PEEMP_CODIGO, PEEDU_TITULO, PEEDU_INSTITUCION, PEEDU_FECGRADO, PEEDU_FECINI) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, educacion.getCodigo());
            ps.setString(2, educacion.getCodigoEmpleado());
            ps.setString(3, educacion.getTitulo());
            ps.setString(4, educacion.getInstitucion());
            ps.setDate(5, new Date(educacion.getFechaGrado().getTime()));
            ps.setDate(6, new Date(educacion.getFechaInicio().getTime()));
            ps.executeUpdate();
        }
    }

    /**
     * Actualizar educación de empleado
     */
    public void actualizarEducacion(Educacion educacion) throws SQLException {
        String sql = "UPDATE PEEDU_EDUCACION SET "
                + "PEEDU_TITULO = ?, PEEDU_INSTITUCION = ?, PEEDU_FECGRADO = ?, PEEDU_FECINI = ? "
                + "WHERE PEEDU_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, educacion.getTitulo());
            ps.setString(2, educacion.getInstitucion());
            ps.setDate(3, new Date(educacion.getFechaGrado().getTime()));
            ps.setDate(4, new Date(educacion.getFechaInicio().getTime()));
            ps.setString(5, educacion.getCodigo());
            ps.executeUpdate();
        }
    }

    /**
     * Eliminar educación de empleado
     */
    public void eliminarEducacion(String codigoEducacion) throws SQLException {
        String sql = "DELETE FROM PEEDU_EDUCACION WHERE PEEDU_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEducacion);
            ps.executeUpdate();
        }
    }

    /**
     * Listar firmas de un empleado
     */
    public List<Firma> listarFirmas(String codigoEmpleado) throws SQLException {
        String sql = "SELECT PEFIR_CODIGO, PEEMP_CODIGO, PEFIR_DESCRIP, PEFIR_RUTA, PEFIR_FECCARGA "
                + "FROM PEFIR_FIRMA WHERE PEEMP_CODIGO = ? ORDER BY PEFIR_FECCARGA DESC";
        List<Firma> firmas = new ArrayList<>();
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    firmas.add(mapearFirma(rs));
                }
            }
        }
        return firmas;
    }

    /**
     * Insertar firma de empleado
     */
    public void insertarFirma(Firma firma) throws SQLException {
        String sql = "INSERT INTO PEFIR_FIRMA "
                + "(PEFIR_CODIGO, PEEMP_CODIGO, PEFIR_DESCRIP, PEFIR_RUTA, PEFIR_FECCARGA) "
                + "VALUES (?, ?, ?, ?, ?)";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, firma.getCodigo());
            ps.setString(2, firma.getCodigoEmpleado());
            ps.setString(3, firma.getDescripcion());
            ps.setString(4, firma.getRuta());
            ps.setDate(5, new Date(firma.getFechaCarga().getTime()));
            ps.executeUpdate();
        }
    }

    /**
     * Actualizar firma de empleado
     */
    public void actualizarFirma(Firma firma) throws SQLException {
        String sql = "UPDATE PEFIR_FIRMA SET "
                + "PEFIR_DESCRIP = ?, PEFIR_RUTA = ? WHERE PEFIR_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, firma.getDescripcion());
            ps.setString(2, firma.getRuta());
            ps.setString(3, firma.getCodigo());
            ps.executeUpdate();
        }
    }

    /**
     * Eliminar firma de empleado
     */
    public void eliminarFirma(String codigoFirma) throws SQLException {
        String sql = "DELETE FROM PEFIR_FIRMA WHERE PEFIR_CODIGO = ?";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoFirma);
            ps.executeUpdate();
        }
    }

    // ==================== CATÁLOGOS / LISTBOX ====================

    public Map<String, String> listarSexos() throws SQLException {
        Map<String, String> map = new LinkedHashMap<>();
        map.put("M", "Masculino");
        map.put("F", "Femenino");
        map.put("H", "Hermafrodita");
        return map;
    }

    public Map<String, String> listarEstadosCiviles() throws SQLException {
        Map<String, String> map = new LinkedHashMap<>();
        String sql = "SELECT PEESC_CODIGO, PEESC_DESCRI FROM PEESC_ESTCIV";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString("PEESC_CODIGO"), rs.getString("PEESC_DESCRI"));
        }
        return map;
    }

    public Map<String, String> listarDepartamentos() throws SQLException {
        Map<String, String> map = new LinkedHashMap<>();
        String sql = "SELECT PEDEP_CODIGO, PEDEP_DESCRI FROM PEDEP_DEPAR";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString("PEDEP_CODIGO"), rs.getString("PEDEP_DESCRI"));
        }
        return map;
    }

    public List<Cargo> listarCargos() throws SQLException {
        List<Cargo> lista = new ArrayList<>();
        String sql = "SELECT c.PEDEP_CODIGO, d.PEDEP_DESCRI, c.PECAR_CODIGOCARGO, c.PECAR_DESCRICARGO "
                + "FROM PECAR_CARGO c "
                + "INNER JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = c.PEDEP_CODIGO "
                + "ORDER BY d.PEDEP_DESCRI, c.PECAR_DESCRICARGO";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                lista.add(new Cargo(
                        rs.getString("PEDEP_CODIGO"),
                        rs.getString("PEDEP_DESCRI"),
                        rs.getString("PECAR_CODIGOCARGO"),
                        rs.getString("PECAR_DESCRICARGO")
                ));
            }
        }
        return lista;
    }

    public Map<String, String> listarParentescos() throws SQLException {
        Map<String, String> map = new LinkedHashMap<>();
        String sql = "SELECT PEPRT_CODIGO, PEPRT_TIPPAR FROM PEPRT_PARENT ORDER BY PEPRT_CODIGO";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) map.put(rs.getString("PEPRT_CODIGO"), rs.getString("PEPRT_TIPPAR"));
        }
        if (map.isEmpty()) {
            map.put("PRT001", "Padre");
            map.put("PRT002", "Madre");
            map.put("PRT003", "Conyuge");
            map.put("PRT004", "Hijo/a");
        }
        return map;
    }

    public List<String> listarTitulosEducacion() throws SQLException {
        LinkedHashSet<String> valores = new LinkedHashSet<>(Arrays.asList(
                "Ingenier\u00eda en Software",
                "Ingenier\u00eda en Sistemas",
                "Ingenier\u00eda en Tecnolog\u00edas de la Informaci\u00f3n",
                "Ingenier\u00eda Industrial",
                "Licenciatura en Administraci\u00f3n de Empresas",
                "Tecn\u00f3logo Superior",
                "Tecn\u00f3logo Superior en Desarrollo de Software",
                "Bachiller General Unificado",
                "Licenciatura en Contabilidad y Auditor\u00eda"
        ));
        valores.addAll(listarValores("SELECT DISTINCT PEEDU_TITULO FROM PEEDU_EDUCACION "
                + "WHERE PEEDU_TITULO IS NOT NULL AND TRIM(PEEDU_TITULO) <> '' ORDER BY PEEDU_TITULO"));
        return new ArrayList<>(valores);
    }

    public List<String> listarInstitucionesEducacion() throws SQLException {
        LinkedHashSet<String> valores = new LinkedHashSet<>(Arrays.asList(
                "Escuela Polit\u00e9cnica Nacional (EPN)",
                "Universidad Central del Ecuador (UCE)",
                "Pontificia Universidad Cat\u00f3lica del Ecuador (PUCE)",
                "Universidad de las Fuerzas Armadas (ESPE)",
                "Universidad San Francisco de Quito (USFQ)",
                "Escuela Superior Polit\u00e9cnica del Litoral (ESPOL)",
                "Universidad de Cuenca",
                "Universidad T\u00e9cnica Particular de Loja (UTPL)"
        ));
        valores.addAll(listarValores("SELECT DISTINCT PEEDU_INSTITUCION FROM PEEDU_EDUCACION "
                + "WHERE PEEDU_INSTITUCION IS NOT NULL AND TRIM(PEEDU_INSTITUCION) <> '' ORDER BY PEEDU_INSTITUCION"));
        return new ArrayList<>(valores);
    }

    public boolean esCargoValidoParaDepartamento(String departamentoCodigo, String cargoCodigo) throws SQLException {
        String sql = "SELECT 1 FROM PECAR_CARGO WHERE PEDEP_CODIGO = ? AND PECAR_CODIGOCARGO = ?";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, departamentoCodigo);
            ps.setString(2, cargoCodigo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Cargo obtenerCargoPorCodigo(String cargoCodigo) throws SQLException {
        String sql = "SELECT c.PEDEP_CODIGO, d.PEDEP_DESCRI, c.PECAR_CODIGOCARGO, c.PECAR_DESCRICARGO "
                + "FROM PECAR_CARGO c "
                + "INNER JOIN PEDEP_DEPAR d ON d.PEDEP_CODIGO = c.PEDEP_CODIGO "
                + "WHERE c.PECAR_CODIGOCARGO = ? "
                + "ORDER BY d.PEDEP_DESCRI, c.PECAR_DESCRICARGO";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, cargoCodigo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Cargo(
                            rs.getString("PEDEP_CODIGO"),
                            rs.getString("PEDEP_DESCRI"),
                            rs.getString("PECAR_CODIGOCARGO"),
                            rs.getString("PECAR_DESCRICARGO")
                    );
                }
            }
        }
        return null;
    }

    private List<String> listarValores(String sql) throws SQLException {
        List<String> valores = new ArrayList<>();
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                valores.add(rs.getString(1));
            }
        }
        return valores;
    }

    // ==================== FAMILIARES ====================

    public String generarCodigoFamiliar() throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(PEFAM_CODIGO, 4, 3) AS UNSIGNED)) AS ultimo FROM PEFAM_FAMILI WHERE PEFAM_CODIGO LIKE 'FAM%'";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return String.format("FAM%03d", rs.getInt("ultimo") + 1);
        }
        return "FAM001";
    }

    public List<Familiar> listarFamiliares(String codigoEmpleado) throws SQLException {
        String sql = "SELECT f.*, p.PEPRT_TIPPAR, s.PESEX_DESCRI "
                + "FROM PEFAM_FAMILI f "
                + "LEFT JOIN PEPRT_PARENT p ON f.PEPRT_CODIGO = p.PEPRT_CODIGO "
                + "LEFT JOIN PESEX_SEXO s ON f.PESEX_CODIGO = s.PESEX_CODIGO "
                + "WHERE f.PEEMP_CODIGO = ? ORDER BY f.PEFAM_FECACT DESC";
        List<Familiar> lista = new ArrayList<>();
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            try (ResultSet rs = ps.executeQuery()) {
                while(rs.next()) {
                    Familiar fam = new Familiar();
                    fam.setCodigo(rs.getString("PEFAM_CODIGO"));
                    fam.setCodigoEmpleado(rs.getString("PEEMP_CODIGO"));
                    fam.setParentescoCodigo(rs.getString("PEPRT_CODIGO"));
                    fam.setParentescoDescripcion(rs.getString("PEPRT_TIPPAR"));
                    fam.setSexoCodigo(rs.getString("PESEX_CODIGO"));
                    fam.setSexoDescripcion(rs.getString("PESEX_DESCRI"));
                    fam.setNombre(rs.getString("PEFAM_NOMBRE"));
                    fam.setApellido(rs.getString("PEFAM_APELLI"));
                    fam.setFechaNacimiento(rs.getDate("PEFAM_FECNAC") != null ? new java.util.Date(rs.getDate("PEFAM_FECNAC").getTime()) : null);
                    lista.add(fam);
                }
            }
        }
        return lista;
    }

    public void insertarFamiliar(Familiar fam) throws SQLException {
        String sql = "INSERT INTO PEFAM_FAMILI (PEFAM_CODIGO, PEEMP_CODIGO, PEPRT_CODIGO, PESEX_CODIGO, PEFAM_NOMBRE, PEFAM_APELLI, PEFAM_FECNAC, PEFAM_FECACT) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, fam.getCodigo());
            ps.setString(2, fam.getCodigoEmpleado());
            ps.setString(3, fam.getParentescoCodigo());
            ps.setString(4, fam.getSexoCodigo());
            ps.setString(5, fam.getNombre());
            ps.setString(6, fam.getApellido());
            ps.setDate(7, new java.sql.Date(fam.getFechaNacimiento().getTime()));
            ps.setDate(8, new java.sql.Date(System.currentTimeMillis()));
            ps.executeUpdate();
        }
        actualizarConteoCargasFamiliares(fam.getCodigoEmpleado());
    }

    public void eliminarFamiliar(String codigoFamiliar) throws SQLException {
        String empCode = null;
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement("SELECT PEEMP_CODIGO FROM PEFAM_FAMILI WHERE PEFAM_CODIGO = ?")) {
            ps.setString(1, codigoFamiliar);
            try(ResultSet rs = ps.executeQuery()) { if (rs.next()) empCode = rs.getString(1); }
        }
        
        String sql = "DELETE FROM PEFAM_FAMILI WHERE PEFAM_CODIGO = ?";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoFamiliar);
            ps.executeUpdate();
        }
        
        if (empCode != null) actualizarConteoCargasFamiliares(empCode);
    }

    private void actualizarConteoCargasFamiliares(String codigoEmpleado) throws SQLException {
        String sql = "UPDATE PEEMP_EMPLE SET PEEMP_CARFAM = (SELECT COUNT(*) FROM PEFAM_FAMILI WHERE PEEMP_CODIGO = ?) WHERE PEEMP_CODIGO = ?";
        try (Connection cn = Conexion.getConexion(); PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, codigoEmpleado);
            ps.setString(2, codigoEmpleado);
            ps.executeUpdate();
        }
    }

    // ==================== MÉTODOS PRIVADOS ====================

    private Empleado mapear(ResultSet rs) throws SQLException {
        Empleado empleado = new Empleado();
        empleado.setCodigo(rs.getString("PEEMP_CODIGO"));
        empleado.setNombre(rs.getString("PEEMP_NOMBRE"));
        empleado.setApellido(rs.getString("PEEMP_APELLI"));
        empleado.setCedula(rs.getString("PEEMP_CEDULA"));
        empleado.setEmail(rs.getString("PEEMP_EMAIL"));
        empleado.setTelefono(rs.getString("PEEMP_TELEF"));
        empleado.setDepartamentoCodigo(rs.getString("PEDEP_CODIGO"));
        empleado.setCargoCodigo(rs.getString("PECAR_CODIGOCARGO"));
        empleado.setSexoCodigo(rs.getString("PESEX_CODIGO"));
        empleado.setEstadoCivilCodigo(rs.getString("PEESC_CODIGO"));
        java.sql.Date fechaNac = rs.getDate("PEEMP_FECNAC");
        if (fechaNac != null) {
            empleado.setFechaNacimiento(new java.util.Date(fechaNac.getTime()));
        }
        java.sql.Date fechaSal = rs.getDate("PEEMP_FECSAL");
        if (fechaSal != null) {
            empleado.setFechaSalida(new java.util.Date(fechaSal.getTime()));
        }
        empleado.setDireccion(rs.getString("PEEMP_DIREC"));
        empleado.setPasaporte(rs.getString("PEEMP_PASAPO"));
        empleado.setCargosFamiliares(rs.getInt("PEEMP_CARFAM"));
        empleado.setFotoRuta(rs.getString("PEEMP_FOTO"));
        empleado.setDepartamentoDescripcion(rs.getString("PEDEP_DESCRI"));
        empleado.setCargoDescripcion(rs.getString("PECAR_DESCRICARGO"));
        empleado.setSexoDescripcion(rs.getString("PESEX_DESCRI"));
        empleado.setEstadoCivilDescripcion(rs.getString("PEESC_DESCRI"));
        return empleado;
    }

    private Educacion mapearEducacion(ResultSet rs) throws SQLException {
        Educacion educacion = new Educacion();
        educacion.setCodigo(rs.getString("PEEDU_CODIGO"));
        educacion.setCodigoEmpleado(rs.getString("PEEMP_CODIGO"));
        educacion.setTitulo(rs.getString("PEEDU_TITULO"));
        educacion.setInstitucion(rs.getString("PEEDU_INSTITUCION"));
        java.sql.Date fechaGrado = rs.getDate("PEEDU_FECGRADO");
        if (fechaGrado != null) {
            educacion.setFechaGrado(new java.util.Date(fechaGrado.getTime()));
        }
        java.sql.Date fechaInicio = rs.getDate("PEEDU_FECINI");
        if (fechaInicio != null) {
            educacion.setFechaInicio(new java.util.Date(fechaInicio.getTime()));
        }
        return educacion;
    }

    private Firma mapearFirma(ResultSet rs) throws SQLException {
        Firma firma = new Firma();
        firma.setCodigo(rs.getString("PEFIR_CODIGO"));
        firma.setCodigoEmpleado(rs.getString("PEEMP_CODIGO"));
        firma.setDescripcion(rs.getString("PEFIR_DESCRIP"));
        firma.setRuta(rs.getString("PEFIR_RUTA"));
        java.sql.Date fechaCarga = rs.getDate("PEFIR_FECCARGA");
        if (fechaCarga != null) {
            firma.setFechaCarga(new java.util.Date(fechaCarga.getTime()));
        }
        return firma;
    }

    /**
     * Generar código único para educación
     */
    public String generarCodigoEducacion() throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(PEEDU_CODIGO, 4, 3) AS UNSIGNED)) AS ultimo FROM PEEDU_EDUCACION WHERE PEEDU_CODIGO LIKE 'EDU%'";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int numero = rs.getInt("ultimo") + 1;
                return String.format("EDU%03d", numero);
            }
        }
        return "EDU001";
    }

    /**
     * Generar código único para firma
     */
    public String generarCodigoFirma() throws SQLException {
        String sql = "SELECT MAX(CAST(SUBSTRING(PEFIR_CODIGO, 4, 3) AS UNSIGNED)) AS ultimo FROM PEFIR_FIRMA WHERE PEFIR_CODIGO LIKE 'FIR%'";
        try (Connection cn = Conexion.getConexion();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                int numero = rs.getInt("ultimo") + 1;
                return String.format("FIR%03d", numero);
            }
        }
        return "FIR001";
    }

    private String valorNoNulo(String valor) {
        return valor == null ? "" : valor;
    }
}
