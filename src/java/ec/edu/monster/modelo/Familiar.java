package ec.edu.monster.modelo;

import java.util.Date;

/**
 * Modelo que representa la Carga Familiar (PEFAM_FAMILI) de un Empleado
 */
public class Familiar {
    private String codigo;
    private String codigoEmpleado;
    private String parentescoCodigo;
    private String parentescoDescripcion;
    private String sexoCodigo;
    private String sexoDescripcion;
    private String nombre;
    private String apellido;
    private Date fechaNacimiento;
    private Date fechaActualizacion;

    public Familiar() {
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getCodigoEmpleado() {
        return codigoEmpleado;
    }

    public void setCodigoEmpleado(String codigoEmpleado) {
        this.codigoEmpleado = codigoEmpleado;
    }

    public String getParentescoCodigo() {
        return parentescoCodigo;
    }

    public void setParentescoCodigo(String parentescoCodigo) {
        this.parentescoCodigo = parentescoCodigo;
    }

    public String getParentescoDescripcion() {
        return parentescoDescripcion;
    }

    public void setParentescoDescripcion(String parentescoDescripcion) {
        this.parentescoDescripcion = parentescoDescripcion;
    }

    public String getSexoCodigo() {
        return sexoCodigo;
    }

    public void setSexoCodigo(String sexoCodigo) {
        this.sexoCodigo = sexoCodigo;
    }

    public String getSexoDescripcion() {
        return sexoDescripcion;
    }

    public void setSexoDescripcion(String sexoDescripcion) {
        this.sexoDescripcion = sexoDescripcion;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellido() {
        return apellido;
    }

    public void setApellido(String apellido) {
        this.apellido = apellido;
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }
}
