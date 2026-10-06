package ec.edu.monster.modelo;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public final class Encriptador {

    private static final String ALGORITMO = "SHA-256";

    private Encriptador() {
    }

    public static String hash(String textoPlano) {
        if (textoPlano == null) {
            throw new IllegalArgumentException("La contraseña no puede ser nula.");
        }
        try {
            MessageDigest digest = MessageDigest.getInstance(ALGORITMO);
            byte[] hash = digest.digest(textoPlano.getBytes(StandardCharsets.UTF_8));
            StringBuilder resultado = new StringBuilder(hash.length * 2);
            for (byte b : hash) {
                resultado.append(String.format("%02x", b));
            }
            return resultado.toString();
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("No está disponible el algoritmo " + ALGORITMO, ex);
        }
    }

    public static boolean verificar(String textoPlano, String hashGuardado) {
        if (hashGuardado == null || hashGuardado.trim().isEmpty()) {
            return false;
        }
        return hash(textoPlano).equalsIgnoreCase(hashGuardado.trim());
    }
}
