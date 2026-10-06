package ec.edu.monster.modelo;

import java.util.Date;

/**
 * Modelo que representa la Firma de un Empleado
 */
public class Firma {
    private String codigo;
    private String codigoEmpleado;
    private String descripcion;
    private String ruta;
    private Date fechaCarga;

    public Firma() {
    }

    public Firma(String codigo, String codigoEmpleado, String descripcion,
                String ruta, Date fechaCarga) {
        this.codigo = codigo;
        this.codigoEmpleado = codigoEmpleado;
        this.descripcion = descripcion;
        this.ruta = ruta;
        this.fechaCarga = fechaCarga;
    }

    // Getters y Setters
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

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getRuta() {
        return ruta;
    }

    public void setRuta(String ruta) {
        this.ruta = ruta;
    }

    public Date getFechaCarga() {
        return fechaCarga;
    }

    public void setFechaCarga(Date fechaCarga) {
        this.fechaCarga = fechaCarga;
    }
}
