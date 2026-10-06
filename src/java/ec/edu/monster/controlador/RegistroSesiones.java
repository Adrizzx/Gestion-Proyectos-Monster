package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOUSUARIO;
import ec.edu.monster.modelo.Usuario;
import java.util.concurrent.ConcurrentHashMap;
import javax.servlet.annotation.WebListener;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpSessionEvent;
import javax.servlet.http.HttpSessionListener;

/**
 * Registro global de sesiones activas indexado por codigoEmpleado.
 * Permite invalidar o actualizar en tiempo real la sesión de cualquier
 * usuario cuando un administrador cambia su rol o estado sin que el
 * usuario tenga que cerrar sesión manualmente.
 */
@WebListener
public class RegistroSesiones implements HttpSessionListener {

    private static final ConcurrentHashMap<String, HttpSession> ACTIVAS = new ConcurrentHashMap<>();

    @Override
    public void sessionCreated(HttpSessionEvent se) {
        // El registro ocurre explícitamente en srvSeguridad tras autenticar.
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent se) {
        HttpSession sesion = se.getSession();
        try {
            Object attr = sesion.getAttribute("usuarioSesion");
            if (attr instanceof Usuario) {
                String codigo = ((Usuario) attr).getCodigoEmpleado();
                if (codigo != null) {
                    ACTIVAS.remove(codigo.trim().toUpperCase(), sesion);
                }
            }
        } catch (IllegalStateException ignorado) {
            // La sesión ya fue invalidada; no hay atributos accesibles.
        }
    }

    // ── API pública ──────────────────────────────────────────────────────────

    /** Registra la sesión del usuario autenticado. Llamar tras login exitoso. */
    public static void registrar(String codigoEmpleado, HttpSession sesion) {
        if (codigoEmpleado == null || sesion == null) {
            return;
        }
        ACTIVAS.put(codigoEmpleado.trim().toUpperCase(), sesion);
    }

    /**
     * Invalida la sesión activa del usuario (expulsión inmediata).
     * Usar cuando se desactiva un usuario o se resetea su contraseña.
     */
    public static void invalidar(String codigoEmpleado) {
        if (codigoEmpleado == null) {
            return;
        }
        HttpSession sesion = ACTIVAS.remove(codigoEmpleado.trim().toUpperCase());
        if (sesion != null) {
            try {
                sesion.invalidate();
            } catch (IllegalStateException ignorado) {
                // Ya estaba invalidada.
            }
        }
    }

    /**
     * Actualiza en tiempo real el rol de la sesión activa de un usuario.
     * El cambio es visible en su siguiente request sin que tenga que
     * volver a iniciar sesión.
     */
    public static void actualizarRol(String codigoEmpleado, String nuevoPerfil) {
        if (codigoEmpleado == null) {
            return;
        }
        HttpSession sesion = ACTIVAS.get(codigoEmpleado.trim().toUpperCase());
        if (sesion == null) {
            return;
        }
        try {
            Object attr = sesion.getAttribute("usuarioSesion");
            if (attr instanceof Usuario) {
                Usuario u = (Usuario) attr;
                String nuevoRol = resolverRolDesdePerfil(nuevoPerfil);
                u.setPerfilCodigo(nuevoPerfil);
                u.setRolUsuario(nuevoRol);
                sesion.setAttribute("usuarioSesion", u);
                sesion.setAttribute("rolUsuario", nuevoRol);
            }
        } catch (IllegalStateException ex) {
            // La sesión expiró entre el get() y el setAttribute(); limpiar.
            ACTIVAS.remove(codigoEmpleado.trim().toUpperCase());
        }
    }

    // ── Caché de opciones de menú ────────────────────────────────────────────

    /**
     * Elimina la caché de opciones (_opciones) de TODAS las sesiones activas.
     * Llamar cuando un administrador cambia las opciones asignadas a cualquier
     * perfil, para forzar que los usuarios recarguen sus permisos del DB en el
     * siguiente request.
     */
    public static void invalidarCacheOpcionesTodas() {
        for (HttpSession sesion : ACTIVAS.values()) {
            try {
                sesion.removeAttribute("_opciones");
            } catch (IllegalStateException ignorado) {}
        }
    }

    /**
     * Elimina la caché de opciones sólo para un usuario específico.
     */
    public static void invalidarCacheOpciones(String codigoEmpleado) {
        if (codigoEmpleado == null) return;
        HttpSession sesion = ACTIVAS.get(codigoEmpleado.trim().toUpperCase());
        if (sesion != null) {
            try {
                sesion.removeAttribute("_opciones");
            } catch (IllegalStateException ignorado) {}
        }
    }

    // ── Helpers privados ─────────────────────────────────────────────────────

    private static String resolverRolDesdePerfil(String perfilCodigo) {
        if (DAOUSUARIO.PERFIL_ADMINISTRADOR.equals(perfilCodigo)) {
            return Usuario.ROL_ADMINISTRADOR;
        }
        if (DAOUSUARIO.PERFIL_RRHH.equals(perfilCodigo)) {
            return Usuario.ROL_RRHH;
        }
        if (DAOUSUARIO.PERFIL_JEFE_DEPARTAMENTO.equals(perfilCodigo)) {
            return Usuario.ROL_JEFE_DEPARTAMENTO;
        }
        return Usuario.ROL_EMPLEADO;
    }
}
