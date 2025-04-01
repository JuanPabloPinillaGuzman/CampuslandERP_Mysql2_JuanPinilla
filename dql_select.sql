-- CONSULTAS SOBRE CAMPERS

-- 1. Obtener todos los campers inscritos actualmente
SELECT c.* 
FROM campers c
WHERE c.estado = 'Inscrito';

-- 2. Listar los campers con estado "Aprobado"
SELECT c.* 
FROM campers c
WHERE c.estado = 'Aprobado';

-- 3. Mostrar los campers que ya están cursando alguna ruta
SELECT c.*, r.nombre as ruta_nombre
FROM campers c
JOIN inscripciones i ON c.id = i.camper_id
JOIN rutas r ON i.ruta_id = r.id
WHERE c.estado = 'Cursando' AND i.estado = 'Activa';

-- 4. Consultar los campers graduados por cada ruta
SELECT r.nombre as ruta, COUNT(c.id) as total_graduados
FROM rutas r
LEFT JOIN inscripciones i ON r.id = i.ruta_id
LEFT JOIN campers c ON i.camper_id = c.id
WHERE c.estado = 'Graduado'
GROUP BY r.id, r.nombre;

-- 5. Obtener los campers que se encuentran en estado "Expulsado" o "Retirado"
SELECT c.* 
FROM campers c
WHERE c.estado IN ('Expulsado', 'Retirado');

-- 6. Listar campers con nivel de riesgo "Alto"
SELECT c.* 
FROM campers c
WHERE c.nivel_riesgo = 'Alto';

-- 7. Mostrar el total de campers por cada nivel de riesgo
SELECT nivel_riesgo, COUNT(*) as total_campers
FROM campers
GROUP BY nivel_riesgo;

-- 8. Obtener campers con más de un número telefónico registrado
-- (Esta consulta requeriría una nueva tabla para múltiples teléfonos)
SELECT c.*, COUNT(t.telefono) as total_telefonos
FROM campers c
LEFT JOIN telefonos_campers t ON c.id = t.camper_id
GROUP BY c.id
HAVING COUNT(t.telefono) > 1;

-- 9. Listar los campers y sus respectivos acudientes y teléfonos
SELECT c.nombres, c.apellidos, c.acudiente, c.telefono_contacto
FROM campers c;

-- 10. Mostrar campers que aún no han sido asignados a una ruta
SELECT c.*
FROM campers c
LEFT JOIN inscripciones i ON c.id = i.camper_id
WHERE i.id IS NULL;

-- CONSULTAS SOBRE EVALUACIONES

-- 1. Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo
SELECT c.nombres, c.apellidos, m.nombre as modulo, 
       e.nota_teorica, e.nota_practica, e.nota_trabajos
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id;

-- 2. Calcular la nota final de cada camper por módulo
SELECT c.nombres, c.apellidos, m.nombre as modulo,
       (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_final
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id;

-- 3. Mostrar los campers que reprobaron algún módulo (nota < 60)
SELECT c.nombres, c.apellidos, m.nombre as modulo,
       (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_final
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id
WHERE (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60;

-- 4. Listar los módulos con más campers en bajo rendimiento
SELECT m.nombre as modulo, COUNT(*) as total_bajo_rendimiento
FROM evaluaciones e
JOIN modulos m ON e.modulo_id = m.id
WHERE (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60
GROUP BY m.id, m.nombre
ORDER BY total_bajo_rendimiento DESC;

-- 5. Obtener el promedio de notas finales por cada módulo
SELECT m.nombre as modulo,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio
FROM evaluaciones e
JOIN modulos m ON e.modulo_id = m.id
GROUP BY m.id, m.nombre;

-- 6. Consultar el rendimiento general por ruta de entrenamiento
SELECT r.nombre as ruta,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN rutas r ON i.ruta_id = r.id
GROUP BY r.id, r.nombre;

-- 7. Mostrar los trainers responsables de campers con bajo rendimiento
SELECT t.nombres, t.apellidos, COUNT(DISTINCT c.id) as total_bajo_rendimiento
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
JOIN campers c ON i.camper_id = c.id
JOIN evaluaciones e ON i.id = e.inscripcion_id
WHERE (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60
GROUP BY t.id, t.nombres, t.apellidos;

-- 8. Comparar el promedio de rendimiento por trainer
SELECT t.nombres, t.apellidos,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
GROUP BY t.id, t.nombres, t.apellidos
ORDER BY promedio_rendimiento DESC;

-- 9. Listar los mejores 5 campers por nota final en cada ruta
WITH RankedCampers AS (
    SELECT c.nombres, c.apellidos, r.nombre as ruta,
           (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_final,
           ROW_NUMBER() OVER (PARTITION BY r.id ORDER BY 
               (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) DESC) as ranking
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    JOIN campers c ON i.camper_id = c.id
    JOIN rutas r ON i.ruta_id = r.id
)
SELECT nombres, apellidos, ruta, nota_final
FROM RankedCampers
WHERE ranking <= 5;

-- 10. Mostrar cuántos campers pasaron cada módulo por ruta
SELECT r.nombre as ruta, m.nombre as modulo,
       COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) >= 60 THEN 1 END) as aprobados,
       COUNT(*) as total
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN rutas r ON i.ruta_id = r.id
JOIN modulos m ON e.modulo_id = m.id
GROUP BY r.id, r.nombre, m.id, m.nombre;

-- CONSULTAS SOBRE RUTAS Y ÁREAS DE ENTRENAMIENTO

-- 1. Mostrar todas las rutas de entrenamiento disponibles
SELECT * FROM rutas WHERE estado = TRUE;

-- 2. Obtener las rutas con su SGDB principal y alternativo
SELECT r.nombre as ruta,
       MAX(CASE WHEN bdr.tipo = 'Principal' THEN bdr.nombre_sgdb END) as sgdb_principal,
       GROUP_CONCAT(CASE WHEN bdr.tipo = 'Alternativo' THEN bdr.nombre_sgdb END) as sgdb_alternativos
FROM rutas r
LEFT JOIN bases_datos_rutas bdr ON r.id = bdr.ruta_id
GROUP BY r.id, r.nombre;

-- 3. Listar los módulos asociados a cada ruta
SELECT r.nombre as ruta, m.nombre as modulo, m.orden
FROM rutas r
JOIN modulos m ON r.id = m.ruta_id
ORDER BY r.nombre, m.orden;

-- 4. Consultar cuántos campers hay en cada ruta
SELECT r.nombre as ruta, COUNT(i.id) as total_campers
FROM rutas r
LEFT JOIN inscripciones i ON r.id = i.ruta_id
WHERE i.estado = 'Activa'
GROUP BY r.id, r.nombre;

-- 5. Mostrar las áreas de entrenamiento y su capacidad máxima
SELECT * FROM areas_entrenamiento WHERE estado = TRUE;

-- 6. Obtener las áreas que están ocupadas al 100%
SELECT a.nombre, a.capacidad_maxima, COUNT(aa.id) as ocupacion_actual
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
WHERE aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima
HAVING COUNT(aa.id) >= a.capacidad_maxima;

-- 7. Verificar la ocupación actual de cada área
SELECT a.nombre, a.capacidad_maxima, COUNT(aa.id) as ocupacion_actual,
       (COUNT(aa.id) / a.capacidad_maxima * 100) as porcentaje_ocupacion
FROM areas_entrenamiento a
LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima;

-- 8. Consultar los horarios disponibles por cada área
SELECT a.nombre as area, h.dia_semana, h.hora_inicio, h.hora_fin
FROM areas_entrenamiento a
JOIN horarios_entrenamiento h ON a.id = h.area_id
ORDER BY a.nombre, h.dia_semana, h.hora_inicio;

-- 9. Mostrar las áreas con más campers asignados
SELECT a.nombre, COUNT(aa.id) as total_campers
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
WHERE aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre
ORDER BY total_campers DESC;

-- 10. Listar las rutas con sus respectivos trainers y áreas asignadas
SELECT r.nombre as ruta, 
       t.nombres as trainer_nombres, t.apellidos as trainer_apellidos,
       a.nombre as area
FROM rutas r
JOIN asignaciones_trainers at ON r.id = at.ruta_id
JOIN trainers t ON at.trainer_id = t.id
JOIN horarios_entrenamiento h ON t.id = h.trainer_id AND r.id = h.ruta_id
JOIN areas_entrenamiento a ON h.area_id = a.id;

-- CONSULTAS SOBRE TRAINERS

-- 1. Listar todos los entrenadores registrados
SELECT * FROM trainers WHERE estado = TRUE;

-- 2. Mostrar los trainers con sus horarios asignados
SELECT t.nombres, t.apellidos, h.dia_semana, h.hora_inicio, h.hora_fin
FROM trainers t
JOIN horarios_entrenamiento h ON t.id = h.trainer_id
ORDER BY t.nombres, h.dia_semana, h.hora_inicio;

-- 3. Consultar los trainers asignados a más de una ruta
SELECT t.nombres, t.apellidos, COUNT(DISTINCT at.ruta_id) as total_rutas
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
GROUP BY t.id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT at.ruta_id) > 1;

-- 4. Obtener el número de campers por trainer
SELECT t.nombres, t.apellidos, COUNT(DISTINCT i.camper_id) as total_campers
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
WHERE i.estado = 'Activa'
GROUP BY t.id, t.nombres, t.apellidos;

-- 5. Mostrar las áreas en las que trabaja cada trainer
SELECT t.nombres, t.apellidos, GROUP_CONCAT(DISTINCT a.nombre) as areas
FROM trainers t
JOIN horarios_entrenamiento h ON t.id = h.trainer_id
JOIN areas_entrenamiento a ON h.area_id = a.id
GROUP BY t.id, t.nombres, t.apellidos;

-- 6. Listar los trainers sin asignación de área o ruta
SELECT t.*
FROM trainers t
LEFT JOIN asignaciones_trainers at ON t.id = at.trainer_id
WHERE at.id IS NULL;

-- 7. Mostrar cuántos módulos están a cargo de cada trainer
SELECT t.nombres, t.apellidos, COUNT(DISTINCT m.id) as total_modulos
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN modulos m ON at.ruta_id = m.ruta_id
GROUP BY t.id, t.nombres, t.apellidos;

-- 8. Obtener el trainer con mejor rendimiento promedio de campers
SELECT t.nombres, t.apellidos,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
GROUP BY t.id, t.nombres, t.apellidos
ORDER BY promedio_rendimiento DESC
LIMIT 1;

-- 9. Consultar los horarios ocupados por cada trainer
SELECT t.nombres, t.apellidos, h.dia_semana, h.hora_inicio, h.hora_fin
FROM trainers t
JOIN horarios_entrenamiento h ON t.id = h.trainer_id
ORDER BY t.nombres, h.dia_semana, h.hora_inicio;

-- 10. Mostrar la disponibilidad semanal de cada trainer
SELECT t.nombres, t.apellidos,
       GROUP_CONCAT(DISTINCT CONCAT(h.dia_semana, ' ', h.hora_inicio, '-', h.hora_fin) ORDER BY h.dia_semana) as horarios
FROM trainers t
JOIN horarios_entrenamiento h ON t.id = h.trainer_id
GROUP BY t.id, t.nombres, t.apellidos; 