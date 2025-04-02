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

```

## Estructura de la Base de Datos

- */diagrama*: Contiene el diagrama.
- [DQL Select](DiagramaDBCampus.jpeg): Diagrama
- */tablas*: Contiene las tablas de la base de datos.
- [DQL Select](ddl.sql): Tablas
- */inserts*: Contiene los scripts de inserción de datos iniciales.
- [DQL Select](dml.sql): Insert
- */consultas*: Contiene las consultas SQL utilizadas en el proyecto.
- [DQL Select](dql_select.sql): Consultas de selección de datos.
- [DQL Select](dql_select_advance.sql): Consultas de selección de datos.
- */triggers*: Contiene los triggers SQL para la gestión de eventos en la base de datos.
- [DQL Select](dql.triggers.sql): Triggers
- */procedimientos*: Contiene los procedimientos almacenados utilizados en el sistema.
- [DQL Select](dql_procedimientos.sql): Procedimientos
- */funciones*: Contiene las funciones utilizados en el sistema.
- [DQL Select](dql_funciones.sql): Funciones

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
- **Email**: juanpablopiinilla@gmail.com
- **GitHub**: JuanPabloPinillaGuzman

Para cualquier pregunta o problema con la implementación, por favor contactar al desarrollador a través de los medios mencionados anteriormente.
