package ec.edu.monster.controlador;

import ec.edu.monster.modelo.Conexion;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class InicializadorDatos implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        try (Connection cn = Conexion.getConexion()) {
            try (PreparedStatement ps = cn.prepareStatement(
                    "INSERT IGNORE INTO PESEX_SEXO (PESEX_CODIGO, PESEX_DESCRI) VALUES "
                    + "('M','Masculino'),('F','Femenino'),('H','Hermafrodita')")) {
                ps.executeUpdate();
            }
            try (PreparedStatement ps = cn.prepareStatement(
                    "INSERT IGNORE INTO PEPRT_PARENT (PEPRT_CODIGO, PEPRT_TIPPAR) VALUES "
                    + "('PRT001','Padre'),('PRT002','Madre'),('PRT003','Conyuge'),('PRT004','Hijo/a')")) {
                ps.executeUpdate();
            }
        } catch (Exception ignored) {
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
    }
}
