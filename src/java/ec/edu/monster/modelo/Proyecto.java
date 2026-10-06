package ec.edu.monster.modelo;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

/**
 * Modelo de un proyecto. Además de los datos persistidos incluye getters
 * calculados (disponible, exceso, días restantes, estado de presupuesto) que la
 * capa de API expone como parte del JSON para no repetir esa lógica en el cliente.
 */
public class Proyecto {

    // ── Estados válidos ──────────────────────────────────────────────────────
    public static final String EST_PLANIFICADO = "PLANIFICADO";
    public static final String EST_EN_PROGRESO = "EN_PROGRESO";
    public static final String EST_COMPLETADO  = "COMPLETADO";
    public static final String EST_CANCELADO   = "CANCELADO";

    // ── Campos persistidos ───────────────────────────────────────────────────
    private String codigo;
    private String nombre;
    private String descripcion;
    private String departamentoCodigo;
    private String departamentoDescripcion;
    private double presupuesto;
    private double gasto;
    private LocalDate fechaInicio;
    private LocalDate fechaFin;
    private int avance;            // 0-100
    private String estado;
    private String recursos;       // materiales, licencias, equipos

    // Cantidad de colaboradores asignados (se llena en el listado con equipo)
    private int totalEmpleados;

    public Proyecto() {
        this.estado = EST_PLANIFICADO;
    }

    /** Constructor legado usado por listados simples (código, nombre, depto). */
    public Proyecto(String codigo, String nombre, String departamentoCodigo, String departamentoDescripcion) {
        this();
        this.codigo = codigo;
        this.nombre = nombre;
        this.departamentoCodigo = departamentoCodigo;
        this.departamentoDescripcion = departamentoDescripcion;
    }

    // ── Getters / setters persistidos ────────────────────────────────────────
    public String getCodigo() { return codigo; }
    public void setCodigo(String codigo) { this.codigo = codigo; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getDepartamentoCodigo() { return departamentoCodigo; }
    public void setDepartamentoCodigo(String departamentoCodigo) { this.departamentoCodigo = departamentoCodigo; }

    public String getDepartamentoDescripcion() { return departamentoDescripcion; }
    public void setDepartamentoDescripcion(String departamentoDescripcion) { this.departamentoDescripcion = departamentoDescripcion; }

    public double getPresupuesto() { return presupuesto; }
    public void setPresupuesto(double presupuesto) { this.presupuesto = presupuesto; }

    public double getGasto() { return gasto; }
    public void setGasto(double gasto) { this.gasto = gasto; }

    public LocalDate getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDate fechaInicio) { this.fechaInicio = fechaInicio; }

    public LocalDate getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDate fechaFin) { this.fechaFin = fechaFin; }

    public int getAvance() { return avance; }
    public void setAvance(int avance) { this.avance = avance; }

    public String getEstado() { return estado == null ? EST_PLANIFICADO : estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public String getRecursos() { return recursos; }
    public void setRecursos(String recursos) { this.recursos = recursos; }

    public int getTotalEmpleados() { return totalEmpleados; }
    public void setTotalEmpleados(int totalEmpleados) { this.totalEmpleados = totalEmpleados; }

    // ── Getters calculados (reglas de negocio) ───────────────────────────────

    /** Saldo disponible del presupuesto (puede ser negativo si hay exceso). */
    public double getDisponible() {
        return presupuesto - gasto;
    }

    /** true si el gasto superó al presupuesto. */
    public boolean isExcedido() {
        return gasto > presupuesto;
    }

    /** Monto en que el gasto supera al presupuesto (0 si no hay exceso). */
    public double getExceso() {
        double e = gasto - presupuesto;
        return e > 0 ? e : 0;
    }

    /** Porcentaje de presupuesto consumido (0 si no hay presupuesto). */
    public double getPorcentajeGasto() {
        if (presupuesto <= 0) return 0;
        return (gasto / presupuesto) * 100.0;
    }

    /**
     * Días restantes hasta la fecha fin desde hoy. Negativo si ya venció,
     * null si no hay fecha fin.
     */
    public Long getDiasRestantes() {
        if (fechaFin == null) return null;
        return ChronoUnit.DAYS.between(LocalDate.now(), fechaFin);
    }

    /** true si la fecha fin ya pasó y el proyecto no está completado/cancelado. */
    public boolean isAtrasado() {
        Long dias = getDiasRestantes();
        return dias != null && dias < 0
                && !EST_COMPLETADO.equals(getEstado())
                && !EST_CANCELADO.equals(getEstado());
    }

    /** Etiqueta legible del estado para la UI. */
    public String getEstadoLabel() {
        switch (getEstado()) {
            case EST_PLANIFICADO: return "Planificado";
            case EST_EN_PROGRESO: return "En progreso";
            case EST_COMPLETADO:  return "Completado";
            case EST_CANCELADO:   return "Cancelado";
            default:              return getEstado();
        }
    }

    /** Valida que el estado recibido sea uno de los permitidos. */
    public static boolean esEstadoValido(String estado) {
        return EST_PLANIFICADO.equals(estado) || EST_EN_PROGRESO.equals(estado)
                || EST_COMPLETADO.equals(estado) || EST_CANCELADO.equals(estado);
    }
}
