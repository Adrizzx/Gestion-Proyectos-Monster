package ec.edu.monster.modelo;

public class Cargo {

    private String departamentoCodigo;
    private String departamentoDescripcion;
    private String codigo;
    private String descripcion;

    public Cargo() {
    }

    public Cargo(String departamentoCodigo, String departamentoDescripcion, String codigo, String descripcion) {
        this.departamentoCodigo = departamentoCodigo;
        this.departamentoDescripcion = departamentoDescripcion;
        this.codigo = codigo;
        this.descripcion = descripcion;
    }

    public String getDepartamentoCodigo() {
        return departamentoCodigo;
    }

    public void setDepartamentoCodigo(String departamentoCodigo) {
        this.departamentoCodigo = departamentoCodigo;
    }

    public String getDepartamentoDescripcion() {
        return departamentoDescripcion;
    }

    public void setDepartamentoDescripcion(String departamentoDescripcion) {
        this.departamentoDescripcion = departamentoDescripcion;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }
}
