package ec.edu.monster.modelo;

public final class PoliticaContrasena {

    public static final int LONGITUD_MINIMA = 9;
    private static final String DESCRIPCION = "Más de 8 caracteres, al menos una mayúscula y un número.";

    private PoliticaContrasena() {
    }

    public static String descripcion() {
        return DESCRIPCION;
    }

    public static String validar(String contrasena) {
        if (contrasena == null || contrasena.trim().isEmpty()) {
            return "La contraseña es obligatoria.";
        }
        if (contrasena.length() < LONGITUD_MINIMA) {
            return "La contraseña debe tener más de 8 caracteres.";
        }
        if (!contieneMayuscula(contrasena)) {
            return "La contraseña debe incluir al menos una letra mayúscula.";
        }
        if (!contieneNumero(contrasena)) {
            return "La contraseña debe incluir al menos un número.";
        }
        return null;
    }

    private static boolean contieneMayuscula(String texto) {
        for (int i = 0; i < texto.length(); i++) {
            if (Character.isUpperCase(texto.charAt(i))) {
                return true;
            }
        }
        return false;
    }

    private static boolean contieneNumero(String texto) {
        for (int i = 0; i < texto.length(); i++) {
            if (Character.isDigit(texto.charAt(i))) {
                return true;
            }
        }
        return false;
    }
}
