package ec.edu.monster.modelo;

import java.time.LocalDateTime;

public class Usuario {

    public static final String ROL_ADMINISTRADOR = "Administrador";
    public static final String ROL_RRHH = "RR. HH.";
    public static final String ROL_JEFE_DEPARTAMENTO = "Jefe de Departamento";
    public static final String ROL_EMPLEADO = "Empleado";

    private String codigoEmpleado;
    private String passwordHash;
    private String estadoCodigo;
    private String perfilCodigo;
    private String perfilDescripcion;
    private String rolUsuario;
    private String departamentoCodigo;
    private String cargoCodigo;
    private LocalDateTime fechaCreacion;
    private LocalDateTime fechaModificacion;
    private String pieFirma;
    private String nombreEmpleado;
    private String estadoDescripcion;

    public Usuario() {
    }

    public String getCodigoEmpleado() {
        return codigoEmpleado;
    }

    public void setCodigoEmpleado(String codigoEmpleado) {
        this.codigoEmpleado = codigoEmpleado;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getEstadoCodigo() {
        return estadoCodigo;
    }

    public void setEstadoCodigo(String estadoCodigo) {
        this.estadoCodigo = estadoCodigo;
    }

    public String getPerfilCodigo() {
        return perfilCodigo;
    }

    public void setPerfilCodigo(String perfilCodigo) {
        this.perfilCodigo = perfilCodigo;
    }

    public String getPerfilDescripcion() {
        return perfilDescripcion;
    }

    public void setPerfilDescripcion(String perfilDescripcion) {
        this.perfilDescripcion = perfilDescripcion;
    }

    public String getRolUsuario() {
        return rolUsuario == null || rolUsuario.trim().isEmpty() ? ROL_EMPLEADO : rolUsuario;
    }

    public void setRolUsuario(String rolUsuario) {
        this.rolUsuario = rolUsuario;
    }

    public String getDepartamentoCodigo() {
        return departamentoCodigo;
    }

    public void setDepartamentoCodigo(String departamentoCodigo) {
        this.departamentoCodigo = departamentoCodigo;
    }

    public String getCargoCodigo() {
        return cargoCodigo;
    }

    public void setCargoCodigo(String cargoCodigo) {
        this.cargoCodigo = cargoCodigo;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    public LocalDateTime getFechaModificacion() {
        return fechaModificacion;
    }

    public void setFechaModificacion(LocalDateTime fechaModificacion) {
        this.fechaModificacion = fechaModificacion;
    }

    public String getPieFirma() {
        return pieFirma;
    }

    public void setPieFirma(String pieFirma) {
        this.pieFirma = pieFirma;
    }

    public String getNombreEmpleado() {
        return nombreEmpleado;
    }

    public void setNombreEmpleado(String nombreEmpleado) {
        this.nombreEmpleado = nombreEmpleado;
    }

    public String getEstadoDescripcion() {
        return estadoDescripcion;
    }

    public void setEstadoDescripcion(String estadoDescripcion) {
        this.estadoDescripcion = estadoDescripcion;
    }

    public boolean esAdministrador() {
        return ROL_ADMINISTRADOR.equals(getRolUsuario());
    }

    public boolean esRRHH() {
        return ROL_RRHH.equals(getRolUsuario());
    }

    public boolean esJefeDepartamento() {
        return ROL_JEFE_DEPARTAMENTO.equals(getRolUsuario());
    }

    public boolean esEmpleado() {
        return ROL_EMPLEADO.equals(getRolUsuario());
    }

    public boolean tieneRol(String... rolesPermitidos) {
        if (rolesPermitidos == null) {
            return false;
        }
        String rolActual = getRolUsuario();
        for (String rolPermitido : rolesPermitidos) {
            if (rolActual.equals(rolPermitido)) {
                return true;
            }
        }
        return false;
    }
}
