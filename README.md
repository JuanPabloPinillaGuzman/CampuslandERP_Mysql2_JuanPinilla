# Sistema de Gestión Académica CampusLands

## Descripción del Proyecto

Este proyecto implementa un sistema de gestión académica para el programa intensivo de programación de CampusLands. El sistema permite gestionar inscripciones, rutas de aprendizaje, evaluaciones, reportes y asignaciones de entrenadores y áreas de entrenamiento.

### Propósito
La base de datos está diseñada para manejar toda la información relacionada con el proceso de formación de los campers, incluyendo:
- Gestión de estudiantes (campers)
- Control de rutas de aprendizaje
- Seguimiento de evaluaciones
- Gestión de entrenadores
- Control de asistencia
- Sistema de notificaciones

## Requisitos del Sistema

- MySQL 8.0 o superior
- MySQL Workbench 8.0 o superior
- Cliente MySQL (mysql-cli)
- Sistema operativo compatible con MySQL (Windows, Linux, macOS)

## Instalación y Configuración

### 1. Configuración del Entorno

```bash
# Instalar MySQL (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install mysql-server

# Instalar MySQL (Windows)
# Descargar e instalar MySQL Installer desde la página oficial
```

### 2. Carga de la Base de Datos

```bash
# Crear la base de datos y cargar la estructura
mysql -u root -p < ddl.sql

# Cargar datos iniciales
mysql -u root -p campuslands_db < dml.sql
```

### 3. Ejecución de Scripts

```bash
# Para ejecutar consultas
mysql -u root -p campuslands_db -e "SELECT * FROM camper;"

# Para ejecutar procedimientos almacenados
mysql -u root -p campuslands_db -e "CALL nombre_procedimiento();"

# Para ejecutar funciones
mysql -u root -p campuslands_db -e "SELECT nombre_funcion();"
```

## Estructura de la Base de Datos

### Tablas Principales

1. **campusland**: Almacena información de los campus
2. **camper**: Información de los estudiantes
3. **entrenador**: Datos de los entrenadores
4. **ruta_entrenamiento**: Rutas de aprendizaje disponibles
5. **modulo**: Módulos de cada ruta
6. **evaluacion**: Registro de evaluaciones
7. **inscripcion**: Control de inscripciones
8. **grupo_campers**: Grupos de estudiantes
9. **asistencia**: Control de asistencia
10. **notificacion**: Sistema de notificaciones

### Relaciones Principales

- Un camper pertenece a un campus y tiene un estado
- Un camper se inscribe en una ruta
- Un entrenador puede estar asignado a múltiples rutas
- Un módulo pertenece a una ruta y tiene múltiples evaluaciones
- Un grupo tiene múltiples campers y un entrenador asignado

## Ejemplos de Consultas

### Consultas Básicas

```sql
-- Listar todos los campers activos
SELECT nombres, apellidos, email 
FROM camper 
WHERE id_estado IN (SELECT id_estado FROM estado_camper WHERE estado_camper = 'Cursando');

-- Obtener promedio de notas por módulo
SELECT m.nombre_modulo, AVG(e.nota_final) as promedio
FROM evaluacion e
JOIN modulo m ON e.id_modulo = m.id_modulo
GROUP BY m.id_modulo;
```

### Consultas Avanzadas

```sql
-- Obtener estadísticas de asistencia por camper
SELECT 
    c.nombres,
    c.apellidos,
    COUNT(CASE WHEN a.estado_asistencia = 'Presente' THEN 1 END) as asistencias,
    COUNT(CASE WHEN a.estado_asistencia = 'Ausente' THEN 1 END) as ausencias
FROM camper c
LEFT JOIN asistencia a ON c.id_camper = a.id_camper
GROUP BY c.id_camper;

-- Reporte de rendimiento por ruta
SELECT 
    r.nombre_ruta,
    COUNT(DISTINCT i.id_camper) as total_campers,
    AVG(e.nota_final) as promedio_general
FROM ruta_entrenamiento r
LEFT JOIN inscripcion i ON r.id_ruta = i.id_ruta
LEFT JOIN evaluacion e ON i.id_inscripcion = e.id_inscripcion
GROUP BY r.id_ruta;
```

## Procedimientos, Funciones, Triggers y Eventos

### Procedimientos Almacenados

```sql
-- Procedimiento para registrar asistencia
DELIMITER //
CREATE PROCEDURE registrar_asistencia(
    IN p_id_camper INT,
    IN p_id_sesion INT,
    IN p_estado VARCHAR(20)
)
BEGIN
    INSERT INTO asistencia (id_camper, id_sesion, estado_asistencia)
    VALUES (p_id_camper, p_id_sesion, p_estado);
END //
DELIMITER ;
```

### Triggers

```sql
-- Trigger para actualizar historial de estado
DELIMITER //
CREATE TRIGGER actualizar_historial_estado
AFTER UPDATE ON camper
FOR EACH ROW
BEGIN
    IF OLD.id_estado != NEW.id_estado THEN
        INSERT INTO historial_estado_camper (id_camper, id_estado)
        VALUES (NEW.id_camper, NEW.id_estado);
    END IF;
END //
DELIMITER ;
```

## Roles de Usuario y Permisos

### Roles Implementados

1. **Administrador (admin)**
   - Acceso total al sistema
   - Gestión de usuarios
   - Configuración del sistema

2. **Entrenador (trainer)**
   - Gestión de módulos
   - Evaluación de campers
   - Control de asistencia

3. **Camper**
   - Ver sus propias evaluaciones
   - Ver material educativo
   - Recibir notificaciones

4. **Coordinador**
   - Gestión de rutas
   - Asignación de entrenadores
   - Reportes generales

5. **Supervisor**
   - Monitoreo de rendimiento
   - Gestión de campus
   - Reportes avanzados

### Asignación de Roles

```sql
-- Crear usuario
CREATE USER 'usuario'@'localhost' IDENTIFIED BY 'contraseña';

-- Asignar rol
GRANT SELECT, INSERT, UPDATE ON campuslands_db.* TO 'usuario'@'localhost';

-- Aplicar cambios
FLUSH PRIVILEGES;
```

## Contribuciones

Este proyecto fue desarrollado por:

- **Juan Pablo Pinilla Guzman**
  - Diseño de la estructura de la base de datos
  - Implementación de tablas y relaciones
  - Desarrollo de procedimientos almacenados
  - Creación de triggers y eventos
  - Documentación del proyecto

## Licencia y Contacto

### Licencia
Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

### Contacto
- **Nombre**: Juan Pablo Pinilla Guzman
- **Grupo**: J1
- **Materia**: MySQLll
- **Email**: [Tu correo electrónico]
- **GitHub**: [Tu perfil de GitHub]

Para cualquier pregunta o problema con la implementación, por favor contactar al desarrollador a través de los medios mencionados anteriormente.