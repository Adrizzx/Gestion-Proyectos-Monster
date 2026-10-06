package ec.edu.monster.modelo;

import java.util.Date;

/**
 * Modelo que representa un Empleado del sistema
 */
public class Empleado {
    private String codigo;
    private String nombre;
    private String apellido;
    private String cedula;
    private String email;
    private String telefono;
    private String departamentoCodigo;
    private String cargoCodigo;
    private String sexoCodigo;
    private String estadoCivilCodigo;
    private Date fechaNacimiento;
    private Date fechaSalida;
    private String direccion;
    private String pasaporte;
    private Integer cargosFamiliares;
    private String fotoRuta;
    private String departamentoDescripcion;
    private String cargoDescripcion;
    private String sexoDescripcion;
    private String estadoCivilDescripcion;

    public Empleado() {
    }

    public Empleado(String codigo, String nombre, String apellido, String cedula,
                   String email, String telefono, String departamentoCodigo,
                   String cargoCodigo, String sexoCodigo, String estadoCivilCodigo,
                   Date fechaNacimiento, Date fechaSalida, String direccion,
                   String pasaporte, Integer cargosFamiliares, String fotoRuta) {
        this.codigo = codigo;
        this.nombre = nombre;
        this.apellido = apellido;
        this.cedula = cedula;
        this.email = email;
        this.telefono = telefono;
        this.departamentoCodigo = departamentoCodigo;
        this.cargoCodigo = cargoCodigo;
        this.sexoCodigo = sexoCodigo;
        this.estadoCivilCodigo = estadoCivilCodigo;
        this.fechaNacimiento = fechaNacimiento;
        this.fechaSalida = fechaSalida;
        this.direccion = direccion;
        this.pasaporte = pasaporte;
        this.cargosFamiliares = cargosFamiliares;
        this.fotoRuta = fotoRuta;
    }

    // Getters y Setters
    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
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

    public String getNombreCompleto() {
        return (apellido != null ? apellido : "") + ", " + (nombre != null ? nombre : "");
    }

    public String getCedula() {
        return cedula;
    }

    public void setCedula(String cedula) {
        this.cedula = cedula;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
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

    public String getSexoCodigo() {
        return sexoCodigo;
    }

    public void setSexoCodigo(String sexoCodigo) {
        this.sexoCodigo = sexoCodigo;
    }

    public String getEstadoCivilCodigo() {
        return estadoCivilCodigo;
    }

    public void setEstadoCivilCodigo(String estadoCivilCodigo) {
        this.estadoCivilCodigo = estadoCivilCodigo;
    }

    public Date getFechaNacimiento() {
        return fechaNacimiento;
    }

    public void setFechaNacimiento(Date fechaNacimiento) {
        this.fechaNacimiento = fechaNacimiento;
    }

    public Date getFechaSalida() {
        return fechaSalida;
    }

    public void setFechaSalida(Date fechaSalida) {
        this.fechaSalida = fechaSalida;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getPasaporte() {
        return pasaporte;
    }

    public void setPasaporte(String pasaporte) {
        this.pasaporte = pasaporte;
    }

    public Integer getCargosFamiliares() {
        return cargosFamiliares;
    }

    public void setCargosFamiliares(Integer cargosFamiliares) {
        this.cargosFamiliares = cargosFamiliares;
    }

    public String getFotoRuta() {
        return fotoRuta;
    }

    public void setFotoRuta(String fotoRuta) {
        this.fotoRuta = fotoRuta;
    }

    public String getDepartamentoDescripcion() {
        return departamentoDescripcion;
    }

    public void setDepartamentoDescripcion(String departamentoDescripcion) {
        this.departamentoDescripcion = departamentoDescripcion;
    }

    public String getCargoDescripcion() {
        return cargoDescripcion;
    }

    public void setCargoDescripcion(String cargoDescripcion) {
        this.cargoDescripcion = cargoDescripcion;
    }

    public String getSexoDescripcion() {
        return sexoDescripcion;
    }

    public void setSexoDescripcion(String sexoDescripcion) {
        this.sexoDescripcion = sexoDescripcion;
    }

    public String getEstadoCivilDescripcion() {
        return estadoCivilDescripcion;
    }

    public void setEstadoCivilDescripcion(String estadoCivilDescripcion) {
        this.estadoCivilDescripcion = estadoCivilDescripcion;
    }
}
