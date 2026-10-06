package ec.edu.monster.modelo;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class Conexion {

    private static final String URL_DEFAULT = "jdbc:mysql://localhost:3306/gestion_proyectos_monster?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USER_DEFAULT = "root";
    private static final String PASSWORD_DEFAULT = "";

    private Conexion() {
    }

    public static Connection getConexion() throws SQLException {
        cargarDriver();
        String url = obtenerConfiguracion("DB_URL", URL_DEFAULT);
        String usuario = obtenerConfiguracion("DB_USER", USER_DEFAULT);
        String clave = obtenerConfiguracion("DB_PASSWORD", PASSWORD_DEFAULT);
        return DriverManager.getConnection(url, usuario, clave);
    }

    private static void cargarDriver() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new SQLException("No se encontro MySQL Connector/J. Agrega el JAR al proyecto o al dominio de Payara.", ex);
        }
    }

    private static String obtenerConfiguracion(String clave, String valorDefault) {
        String valor = System.getProperty(clave);
        if (valor == null || valor.trim().isEmpty()) {
            valor = System.getenv(clave);
        }
        return (valor == null || valor.trim().isEmpty()) ? valorDefault : valor.trim();
    }
}
