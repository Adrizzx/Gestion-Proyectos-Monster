package ec.edu.monster.controlador;

import ec.edu.monster.modelo.DAOOPCIONES;
import ec.edu.monster.modelo.Usuario;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.Set;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public final class SeguridadWeb {

    private static final String ATTR_OPCIONES = "_opciones";

    private SeguridadWeb() {}

    public static Usuario usuarioSesion(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return null;
        Object usuario = session.getAttribute("usuarioSesion");
        return usuario instanceof Usuario ? (Usuario) usuario : null;
    }

    public static boolean requiereSesion(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (usuarioSesion(request) != null) return true;
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return false;
    }

    public static boolean requiereRol(HttpServletRequest request, HttpServletResponse response,
                                       String... rolesPermitidos) throws IOException {
        Usuario usuario = usuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        if (usuario.tieneRol(rolesPermitidos)) return true;
        // Sin acceso → redirigir silenciosamente al dashboard propio sin mostrar error
        response.sendRedirect(request.getContextPath() + rutaDashboard(usuario));
        return false;
    }

    /**
     * Exige que el usuario tenga asignada una opción de menú concreta (control
     * de acceso dinámico por perfil, no por rol fijo). Si no la tiene, redirige
     * a su dashboard. Pensado para páginas cuyo acceso depende del perfil.
     */
    public static boolean requiereOpcion(HttpServletRequest request, HttpServletResponse response,
                                          String codigoOpcion) throws IOException {
        Usuario usuario = usuarioSesion(request);
        if (usuario == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        if (tieneOpcion(request, codigoOpcion)) return true;
        response.sendRedirect(request.getContextPath() + rutaDashboard(usuario));
        return false;
    }

    public static String rutaDashboard(Usuario usuario) {
        if (usuario == null) return "/login.jsp";
        switch (usuario.getRolUsuario()) {
            case Usuario.ROL_ADMINISTRADOR:    return "/views/admin/dashboard.jsp";
            case Usuario.ROL_RRHH:            return "/views/rrhh/dashboard.jsp";
            case Usuario.ROL_JEFE_DEPARTAMENTO: return "/views/jefe/dashboard.jsp";
            default:                           return "/views/empleado/dashboard.jsp";
        }
    }

    // ── Control de acceso por opción de menú ─────────────────────────────────

    /**
     * Devuelve true si el usuario en sesión tiene la opción de menú con el
     * código indicado asignada a su perfil. El resultado se cachea en sesión.
     */
    public static boolean tieneOpcion(HttpServletRequest request, String codigoOpcion) {
        if (codigoOpcion == null) return false;
        return getOpcionesPermitidas(request).contains(codigoOpcion);
    }

    /**
     * Devuelve true si el usuario tiene AL MENOS UNA de las opciones indicadas.
     * Útil para decidir si mostrar una categoría entera del menú.
     */
    public static boolean tieneOpcionCualquiera(HttpServletRequest request, String... codigos) {
        Set<String> permitidas = getOpcionesPermitidas(request);
        for (String c : codigos) {
            if (permitidas.contains(c)) return true;
        }
        return false;
    }

    /**
     * Retorna el Set de códigos de opción permitidos para el usuario en sesión.
     * El resultado se almacena como atributo de sesión (_opciones) y se recarga
     * automáticamente la próxima vez que sea null (por ejemplo, tras un
     * invalidarCacheOpciones desde RegistroSesiones).
     */
    @SuppressWarnings("unchecked")
    public static Set<String> getOpcionesPermitidas(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return Collections.emptySet();

        Object cached = session.getAttribute(ATTR_OPCIONES);
        if (cached instanceof Set) {
            return (Set<String>) cached;
        }

        Usuario u = usuarioSesion(request);
        if (u == null || u.getPerfilCodigo() == null) return Collections.emptySet();

        Set<String> opciones;
        try {
            opciones = new DAOOPCIONES().getCodigosParaPerfil(u.getPerfilCodigo());
        } catch (SQLException ex) {
            opciones = Collections.emptySet();
        }
        session.setAttribute(ATTR_OPCIONES, opciones);
        return opciones;
    }

    /** Elimina la caché de opciones de la sesión del request actual. */
    public static void invalidarCacheOpciones(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            try { session.removeAttribute(ATTR_OPCIONES); } catch (IllegalStateException ignored) {}
        }
    }
}
