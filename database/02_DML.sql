-- =============================================================================
-- DML - Data Manipulation Language
-- Sistema: Gestión de Proyectos Monster
-- Base de datos: gestion_proyectos_monster
-- Ejecutar DESPUÉS del DDL.sql
-- =============================================================================

USE gestion_proyectos_monster;

-- =============================================================================
-- CATÁLOGOS BASE
-- =============================================================================

-- Departamentos
INSERT INTO PEDEP_DEPAR (PEDEP_CODIGO, PEDEP_DESCRI) VALUES
('001', 'Sistemas'),
('002', 'Talento Humano'),
('003', 'Proyectos'),
('004', 'Finanzas');

-- Sexo
INSERT INTO PESEX_SEXO (PESEX_CODIGO, PESEX_DESCRI) VALUES
('M', 'Masculino'),
('F', 'Femenino'),
('H', 'Hermafrodita');

-- Estado civil
INSERT INTO PEESC_ESTCIV (PEESC_CODIGO, PEESC_DESCRI) VALUES
('S', 'Soltero'),
('C', 'Casado');

-- Parentesco
INSERT INTO PEPRT_PARENT (PEPRT_CODIGO, PEPRT_TIPPAR) VALUES
('PRT001', 'Padre'),
('PRT002', 'Madre'),
('PRT003', 'Conyuge'),
('PRT004', 'Hijo/a');

-- Estados de usuario
INSERT INTO XEEST_ESTAD (XEEST_CODIGO, XEEST_DESCRI) VALUES
('A', 'Activo'),
('I', 'Inactivo');

-- =============================================================================
-- CARGOS POR DEPARTAMENTO
-- =============================================================================

INSERT INTO PECAR_CARGO (PEDEP_CODIGO, PECAR_CODIGOCARGO, PECAR_DESCRICARGO) VALUES
('001', 'ADM', 'Administrador'),
('002', 'ANA', 'Analista'),
('003', 'JPR', 'Jefe de proyecto'),
('003', 'EMP', 'Empleado');

-- =============================================================================
-- SEGURIDAD: SISTEMAS, OPCIONES Y PERFILES
-- =============================================================================

-- Sistemas (categorías del menú)
INSERT INTO XESIS_SISTE (XESIS_CODIGO, XESIS_DESCRI) VALUES
('S', 'Seguridad'),
('H', 'Recursos Humanos'),
('P', 'Proyectos');

-- Opciones del menú del sistema
INSERT INTO XEOPC_OPCIO (XEOPC_CODIGO, XESIS_CODIGO, XEOPC_DESCRI) VALUES
('001', 'S', 'Inicio'),
('002', 'S', 'Gestión de usuarios'),
('003', 'H', 'Gestión de departamentos'),
('004', 'S', 'Asignación de perfiles'),
('005', 'S', 'Gestión de contraseñas'),
('006', 'S', 'Asignar opciones al perfil'),
('007', 'S', 'Cambiar contraseña propia'),
('008', 'H', 'Gestión de personal'),
('009', 'H', 'Gestionar familiares'),
('010', 'H', 'Organigrama'),
('011', 'H', 'Reporte de personal'),
('012', 'P', 'Gestión de proyectos'),
('013', 'P', 'Asignación de personal a proyectos'),
('014', 'P', 'Aprobación de horas'),
('015', 'P', 'Reportes de horas'),
('016', 'P', 'Registrar horas reales'),
('017', 'S', 'Gestión de perfiles'),
('018', 'P', 'Reporte de gestión de proyectos');

-- Perfiles de acceso
INSERT INTO XEPER_PERFI (XEPER_CODIGO, XEPER_DESCRI, XEPER_OBSER) VALUES
('PERF0001', 'Administrador',        'Acceso completo al sistema'),
('PERF0002', 'RR. HH.',              'Administración de empleados, familiares y reportes de personal'),
('PERF0003', 'Jefe de Departamento', 'Gestión de proyectos, asignaciones, aprobación y reportes de horas'),
('PERF0004', 'Empleado',             'Registro de horas reales en proyectos asignados');

-- Asignación opciones ↔ perfiles
-- PERF0001 Administrador → TODAS las opciones
INSERT INTO XEOXP_OPCPE (XEPER_CODIGO, XEOPC_CODIGO, XEOXP_FECASI, XEOXP_FECRET) VALUES
('PERF0001', '001', '2026-05-14', NULL),
('PERF0001', '002', '2026-05-14', NULL),
('PERF0001', '003', '2026-05-14', NULL),
('PERF0001', '004', '2026-05-14', NULL),
('PERF0001', '005', '2026-05-14', NULL),
('PERF0001', '006', '2026-05-14', NULL),
('PERF0001', '007', '2026-05-14', NULL),
('PERF0001', '008', '2026-05-14', NULL),
('PERF0001', '009', '2026-05-14', NULL),
('PERF0001', '010', '2026-05-14', NULL),
('PERF0001', '011', '2026-05-14', NULL),
('PERF0001', '012', '2026-05-14', NULL),
('PERF0001', '013', '2026-05-14', NULL),
('PERF0001', '014', '2026-05-14', NULL),
('PERF0001', '015', '2026-05-14', NULL),
('PERF0001', '016', '2026-05-14', NULL),
('PERF0001', '017', '2026-05-14', NULL),
-- PERF0002 RR. HH. → Personal, departamentos y cambiar clave propia
('PERF0002', '001', '2026-05-14', NULL),
('PERF0002', '003', '2026-05-14', NULL),
('PERF0002', '007', '2026-05-14', NULL),
('PERF0002', '008', '2026-05-14', NULL),
('PERF0002', '009', '2026-05-14', NULL),
('PERF0002', '010', '2026-05-14', NULL),
('PERF0002', '011', '2026-05-14', NULL),
-- PERF0003 Jefe de Departamento → Proyectos y cambiar clave propia
('PERF0003', '001', '2026-05-14', NULL),
('PERF0003', '007', '2026-05-14', NULL),
('PERF0003', '012', '2026-05-14', NULL),
('PERF0003', '013', '2026-05-14', NULL),
('PERF0003', '014', '2026-05-14', NULL),
('PERF0003', '015', '2026-05-14', NULL),
('PERF0003', '016', '2026-05-14', NULL),
-- PERF0004 Empleado → Registrar horas y cambiar clave propia
('PERF0004', '001', '2026-05-14', NULL),
('PERF0004', '007', '2026-05-14', NULL),
('PERF0004', '016', '2026-05-14', NULL),
-- PERF0001 y PERF0003 → Reporte de gestión de proyectos (opción 018)
('PERF0001', '018', '2026-05-14', NULL),
('PERF0003', '018', '2026-05-14', NULL);

-- =============================================================================
-- EMPLEADOS
-- Contraseñas (SHA-256):
--   EMP001 Marco   → Admin1234!
--   EMP002 Edgar   → Rrhh1234!
--   EMP003 Kenned  → Jefe1234!
--   EMP004 Carla   → Emp1234!!
-- =============================================================================

INSERT INTO PEEMP_EMPLE (
    PEEMP_CODIGO, PEC_PEDEP_CODIGO, PECAR_CODIGOCARGO, PEE_PEEMP_CODIGO,
    PEDEP_CODIGO, PEE_PEEMP_CODIGO2, PESEX_CODIGO, PED_PEDEP_CODIGO,
    PEESC_CODIGO, PED_PEDEP_CODIGO2, PEEMP_APELLI, PEEMP_NOMBRE,
    PEEMP_FECNAC, PEEMP_FECSAL, PEEMP_DIREC, PEEMP_TELEF, PEEMP_EMAIL,
    PEEMP_CEDULA, PEEMP_FOTO, PEEMP_CARFAM, PEEMP_PASAPO, PEEMP_DISCAP
) VALUES
('EMP001', '001', 'ADM', NULL, '001', NULL, 'M', '001', 'S', '001',
 'Padilla', 'Marco', '2000-01-15', '2099-12-31',
 'Quito', '0999999991', 'marco.padilla@monster.edu', '1711111111',
 NULL, 0, 'P001', X'00'),

('EMP002', '002', 'ANA', NULL, '002', NULL, 'M', '002', 'S', '002',
 'Toscano', 'Edgar', '2001-03-20', '2099-12-31',
 'Quito', '0999999992', 'edgar.toscano@monster.edu', '1722222222',
 NULL, 0, 'P002', X'00'),

('EMP003', '003', 'JPR', NULL, '003', NULL, 'M', '003', 'C', '003',
 'Sigcha', 'Kenned', '1999-07-10', '2099-12-31',
 'Quito', '0999999993', 'kenned.sigcha@monster.edu', '1733333333',
 NULL, 0, 'P003', X'00'),

('EMP004', '003', 'EMP', NULL, '003', NULL, 'F', '003', 'S', '003',
 'Benitez', 'Carla', '2002-11-05', '2099-12-31',
 'Quito', '0999999994', 'carla.benitez@monster.edu', '1744444444',
 NULL, 0, 'P004', X'00');

-- =============================================================================
-- USUARIOS Y ASIGNACIÓN DE PERFILES
-- Los hashes corresponden a contraseñas cifradas con SHA-256
-- =============================================================================

INSERT INTO XEUSU_USUAR (
    PEEMP_CODIGO, XEUSU_PASWD, XEEST_CODIGO, XEUSU_FECCRE, XEUSU_FECMOD, XEUSU_PIEFIR
) VALUES
('EMP001', '0044987cdf13f5acc8daab9eced9435743e8a013f87ef561dea3bee7c2196696',
 'A', NOW(), NOW(), 'Administrador del sistema'),
('EMP002', 'c0abb0c3a0c510bff5cefab61b90588865c17e4dcc22d560ff9f6d47314c0b67',
 'A', NOW(), NOW(), 'Director de Recursos Humanos'),
('EMP003', '975ee79f5b5894888012afd43c3548628d479e3d75348fccb5c2bf3cff280831',
 'A', NOW(), NOW(), 'Jefe de Departamento'),
('EMP004', 'c5ffd4a5cf1b0b2941f56283c4b34be0279ec2635aaa8417feb9a6bf137f1c42',
 'A', NOW(), NOW(), 'Empleado operativo');

-- Historial perfil activo por usuario
INSERT INTO XEUXP_USUPE (XEPER_CODIGO, PEEMP_CODIGO, XEUSU_PASWD, XEUXP_FECASI, XEUXP_FECRET) VALUES
('PERF0001', 'EMP001', '0044987cdf13f5acc8daab9eced9435743e8a013f87ef561dea3bee7c2196696', '2026-05-14', NULL),
('PERF0002', 'EMP002', 'c0abb0c3a0c510bff5cefab61b90588865c17e4dcc22d560ff9f6d47314c0b67', '2026-05-14', NULL),
('PERF0003', 'EMP003', '975ee79f5b5894888012afd43c3548628d479e3d75348fccb5c2bf3cff280831', '2026-05-14', NULL),
('PERF0004', 'EMP004', 'c5ffd4a5cf1b0b2941f56283c4b34be0279ec2635aaa8417feb9a6bf137f1c42', '2026-05-14', NULL);

-- =============================================================================
-- PROYECTOS Y ASIGNACIÓN DE EMPLEADOS
-- =============================================================================

INSERT INTO GEPRO_PROYECT (GEPRO_CODIGO, PEDEP_CODIGO, GEPRO_NOMBRE) VALUES
('P01', '003', 'Sistema de Gestión de Proyectos');

INSERT INTO GR_PEEMP_GEPRO (PEEMP_CODIGO, GEPRO_CODIGO) VALUES
('EMP001', 'P01'),
('EMP002', 'P01'),
('EMP003', 'P01'),
('EMP004', 'P01');
