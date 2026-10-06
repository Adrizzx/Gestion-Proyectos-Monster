package ec.edu.monster.modelo;

public class Opcion {

    private String codigo;
    private String sistemaCodigo;
    private String sistemaDescripcion;
    private String descripcion;

    public Opcion() {}

    public Opcion(String codigo, String sistemaCodigo, String sistemaDescripcion, String descripcion) {
        this.codigo = codigo;
        this.sistemaCodigo = sistemaCodigo;
        this.sistemaDescripcion = sistemaDescripcion;
        this.descripcion = descripcion;
    }

    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getSistemaCodigo() { return sistemaCodigo; }
    public void setSistemaCodigo(String sistemaCodigo) { this.sistemaCodigo = sistemaCodigo; }

    public String getSistemaDescripcion() { return sistemaDescripcion; }
    public void setSistemaDescripcion(String sistemaDescripcion) { this.sistemaDescripcion = sistemaDescripcion; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
}
