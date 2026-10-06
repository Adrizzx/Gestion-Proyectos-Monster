package ec.edu.monster.modelo;

import java.util.Date;

/**
 * Modelo que representa la Educación/Formación de un Empleado
 */
public class Educacion {
    private String codigo;
    private String codigoEmpleado;
    private String titulo;
    private String institucion;
    private Date fechaGrado;
    private Date fechaInicio;

    public Educacion() {
    }

    public Educacion(String codigo, String codigoEmpleado, String titulo,
                    String institucion, Date fechaGrado, Date fechaInicio) {
        this.codigo = codigo;
        this.codigoEmpleado = codigoEmpleado;
        this.titulo = titulo;
        this.institucion = institucion;
        this.fechaGrado = fechaGrado;
        this.fechaInicio = fechaInicio;
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

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getInstitucion() {
        return institucion;
    }

    public void setInstitucion(String institucion) {
        this.institucion = institucion;
    }

    public Date getFechaGrado() {
        return fechaGrado;
    }

    public void setFechaGrado(Date fechaGrado) {
        this.fechaGrado = fechaGrado;
    }

    public Date getFechaInicio() {
        return fechaInicio;
    }

    public void setFechaInicio(Date fechaInicio) {
        this.fechaInicio = fechaInicio;
    }
}
