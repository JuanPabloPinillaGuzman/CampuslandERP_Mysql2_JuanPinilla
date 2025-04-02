-- CONSULTAS CON SUBCONSULTAS Y CÁLCULOS AVANZADOS

-- 1. Obtener los campers con la nota más alta en cada módulo
WITH NotasModulo AS (
    SELECT m.id as modulo_id, m.nombre as modulo_nombre,
           MAX(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_maxima
    FROM evaluaciones e
    JOIN modulos m ON e.modulo_id = m.id
    GROUP BY m.id, m.nombre
)
SELECT c.nombres, c.apellidos, nm.modulo_nombre, nm.nota_maxima
FROM NotasModulo nm
JOIN evaluaciones e ON nm.modulo_id = e.modulo_id
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
WHERE (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) = nm.nota_maxima;

-- 2. Mostrar el promedio general de notas por ruta y comparar con el promedio global
WITH PromediosRuta AS (
    SELECT r.id, r.nombre,
           AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_ruta
    FROM rutas r
    JOIN inscripciones i ON r.id = i.ruta_id
    JOIN evaluaciones e ON i.id = e.inscripcion_id
    GROUP BY r.id, r.nombre
),
PromedioGlobal AS (
    SELECT AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_global
    FROM evaluaciones e
)
SELECT pr.nombre, pr.promedio_ruta, pg.promedio_global,
       CASE 
           WHEN pr.promedio_ruta > pg.promedio_global THEN 'Superior'
           WHEN pr.promedio_ruta < pg.promedio_global THEN 'Inferior'
           ELSE 'Igual'
       END as comparacion
FROM PromediosRuta pr
CROSS JOIN PromedioGlobal pg;

-- 3. Listar las áreas con más del 80% de ocupación
SELECT a.nombre, a.capacidad_maxima, 
       COUNT(aa.id) as ocupacion_actual,
       (COUNT(aa.id) / a.capacidad_maxima * 100) as porcentaje_ocupacion
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
WHERE aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima
HAVING (COUNT(aa.id) / a.capacidad_maxima * 100) > 80;

-- 4. Mostrar los trainers con menos del 70% de rendimiento promedio
WITH RendimientoTrainer AS (
    SELECT t.id, t.nombres, t.apellidos,
           AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
    FROM trainers t
    JOIN asignaciones_trainers at ON t.id = at.trainer_id
    JOIN inscripciones i ON at.ruta_id = i.ruta_id
    JOIN evaluaciones e ON i.id = e.inscripcion_id
    GROUP BY t.id, t.nombres, t.apellidos
)
SELECT nombres, apellidos, promedio_rendimiento
FROM RendimientoTrainer
WHERE promedio_rendimiento < 70;

-- 5. Consultar los campers cuyo promedio está por debajo del promedio general
WITH PromedioCamper AS (
    SELECT c.id, c.nombres, c.apellidos,
           AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_camper
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN evaluaciones e ON i.id = e.inscripcion_id
    GROUP BY c.id, c.nombres, c.apellidos
),
PromedioGlobal AS (
    SELECT AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_global
    FROM evaluaciones e
)
SELECT pc.nombres, pc.apellidos, pc.promedio_camper, pg.promedio_global
FROM PromedioCamper pc
CROSS JOIN PromedioGlobal pg
WHERE pc.promedio_camper < pg.promedio_global;

-- 6. Obtener los módulos con la menor tasa de aprobación
SELECT m.nombre as modulo,
       COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) >= 60 THEN 1 END) * 100.0 / COUNT(*) as tasa_aprobacion
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
GROUP BY m.id, m.nombre
ORDER BY tasa_aprobacion ASC;

-- 7. Listar los campers que han aprobado todos los módulos de su ruta
WITH ModulosAprobados AS (
    SELECT c.id as camper_id, r.id as ruta_id,
           COUNT(DISTINCT m.id) as total_modulos,
           COUNT(DISTINCT CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) >= 60 THEN m.id END) as modulos_aprobados
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN rutas r ON i.ruta_id = r.id
    JOIN modulos m ON r.id = m.ruta_id
    LEFT JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    GROUP BY c.id, r.id
)
SELECT c.nombres, c.apellidos, r.nombre as ruta
FROM ModulosAprobados ma
JOIN campers c ON ma.camper_id = c.id
JOIN rutas r ON ma.ruta_id = r.id
WHERE ma.total_modulos = ma.modulos_aprobados;

-- 8. Mostrar rutas con más de 10 campers en bajo rendimiento
SELECT r.nombre as ruta, COUNT(DISTINCT c.id) as total_bajo_rendimiento
FROM rutas r
JOIN inscripciones i ON r.id = i.ruta_id
JOIN campers c ON i.camper_id = c.id
JOIN evaluaciones e ON i.id = e.inscripcion_id
WHERE (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60
GROUP BY r.id, r.nombre
HAVING COUNT(DISTINCT c.id) > 10;

-- 9. Calcular el promedio de rendimiento por SGDB principal
SELECT bdr.nombre_sgdb,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
FROM bases_datos_rutas bdr
JOIN rutas r ON bdr.ruta_id = r.id
JOIN inscripciones i ON r.id = i.ruta_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
WHERE bdr.tipo = 'Principal'
GROUP BY bdr.nombre_sgdb;

-- 10. Listar los módulos con al menos un 30% de campers reprobados
SELECT m.nombre as modulo,
       COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60 THEN 1 END) * 100.0 / COUNT(*) as porcentaje_reprobados
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
GROUP BY m.id, m.nombre
HAVING COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60 THEN 1 END) * 100.0 / COUNT(*) >= 30;

-- 11. Mostrar el módulo más cursado por campers con riesgo alto
SELECT m.nombre as modulo, COUNT(DISTINCT c.id) as total_campers_riesgo_alto
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
WHERE c.nivel_riesgo = 'Alto'
GROUP BY m.id, m.nombre
ORDER BY total_campers_riesgo_alto DESC
LIMIT 1;

-- 12. Consultar los trainers con más de 3 rutas asignadas
SELECT t.nombres, t.apellidos, COUNT(DISTINCT at.ruta_id) as total_rutas
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
GROUP BY t.id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT at.ruta_id) > 3;

-- 13. Listar los horarios más ocupados por áreas
WITH HorariosOcupacion AS (
    SELECT a.nombre as area, h.dia_semana, h.hora_inicio, h.hora_fin,
           COUNT(DISTINCT aa.id) as total_asignaciones
    FROM areas_entrenamiento a
    JOIN horarios_entrenamiento h ON a.id = h.area_id
    LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
    GROUP BY a.id, a.nombre, h.dia_semana, h.hora_inicio, h.hora_fin
)
SELECT area, dia_semana, hora_inicio, hora_fin, total_asignaciones
FROM HorariosOcupacion
ORDER BY total_asignaciones DESC;

-- 14. Consultar las rutas con el mayor número de módulos
SELECT r.nombre as ruta, COUNT(m.id) as total_modulos
FROM rutas r
JOIN modulos m ON r.id = m.ruta_id
GROUP BY r.id, r.nombre
ORDER BY total_modulos DESC;

-- 15. Obtener los campers que han cambiado de estado más de una vez
WITH CambiosEstado AS (
    SELECT c.id, c.nombres, c.apellidos,
           COUNT(DISTINCT c.estado) as total_estados
    FROM campers c
    GROUP BY c.id, c.nombres, c.apellidos
)
SELECT nombres, apellidos, total_estados
FROM CambiosEstado
WHERE total_estados > 1;

-- 16. Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica
SELECT c.nombres, c.apellidos, m.nombre as modulo,
       e.nota_teorica, e.nota_practica
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id
WHERE e.nota_teorica > e.nota_practica;

-- 17. Listar los módulos donde la media de quizzes supera el 9
SELECT m.nombre as modulo, AVG(e.nota_trabajos) as promedio_quizzes
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
GROUP BY m.id, m.nombre
HAVING AVG(e.nota_trabajos) > 9;

-- 18. Consultar la ruta con mayor tasa de graduación
SELECT r.nombre as ruta,
       COUNT(CASE WHEN c.estado = 'Graduado' THEN 1 END) * 100.0 / COUNT(*) as tasa_graduacion
FROM rutas r
JOIN inscripciones i ON r.id = i.ruta_id
JOIN campers c ON i.camper_id = c.id
GROUP BY r.id, r.nombre
ORDER BY tasa_graduacion DESC
LIMIT 1;

-- 19. Mostrar los módulos cursados por campers de nivel de riesgo medio o alto
SELECT DISTINCT m.nombre as modulo, c.nivel_riesgo
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
WHERE c.nivel_riesgo IN ('Medio', 'Alto')
ORDER BY m.nombre, c.nivel_riesgo;

-- 20. Obtener la diferencia entre capacidad y ocupación en cada área
SELECT a.nombre, a.capacidad_maxima,
       COUNT(aa.id) as ocupacion_actual,
       (a.capacidad_maxima - COUNT(aa.id)) as espacios_disponibles
FROM areas_entrenamiento a
LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima
ORDER BY espacios_disponibles ASC;

-- JOINs Básicos

-- 1. Obtener los nombres completos de los campers junto con el nombre de la ruta
SELECT c.nombres, c.apellidos, r.nombre as ruta
FROM campers c
JOIN inscripciones i ON c.id = i.camper_id
JOIN rutas r ON i.ruta_id = r.id
WHERE i.estado = 'Activa';

-- 2. Mostrar los campers con sus evaluaciones por módulo
SELECT c.nombres, c.apellidos, m.nombre as modulo,
       e.nota_teorica, e.nota_practica, e.nota_trabajos,
       (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_final
FROM campers c
JOIN inscripciones i ON c.id = i.camper_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
JOIN modulos m ON e.modulo_id = m.id;

-- 3. Listar todos los módulos que componen cada ruta
SELECT r.nombre as ruta, m.nombre as modulo, m.orden
FROM rutas r
JOIN modulos m ON r.id = m.ruta_id
ORDER BY r.nombre, m.orden;

-- 4. Consultar las rutas con sus trainers y áreas
SELECT r.nombre as ruta,
       t.nombres as trainer_nombres, t.apellidos as trainer_apellidos,
       a.nombre as area
FROM rutas r
JOIN asignaciones_trainers at ON r.id = at.ruta_id
JOIN trainers t ON at.trainer_id = t.id
JOIN horarios_entrenamiento h ON t.id = h.trainer_id AND r.id = h.ruta_id
JOIN areas_entrenamiento a ON h.area_id = a.id;

-- 5. Mostrar los campers junto con su trainer actual
SELECT c.nombres, c.apellidos, r.nombre as ruta,
       t.nombres as trainer_nombres, t.apellidos as trainer_apellidos
FROM campers c
JOIN inscripciones i ON c.id = i.camper_id
JOIN rutas r ON i.ruta_id = r.id
JOIN asignaciones_trainers at ON r.id = at.ruta_id
JOIN trainers t ON at.trainer_id = t.id
WHERE i.estado = 'Activa';

-- 6. Obtener el listado de evaluaciones con detalles
SELECT c.nombres, c.apellidos, m.nombre as modulo, r.nombre as ruta,
       e.nota_teorica, e.nota_practica, e.nota_trabajos,
       (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as nota_final
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id
JOIN rutas r ON i.ruta_id = r.id;

-- 7. Listar los trainers y sus horarios
SELECT t.nombres, t.apellidos, a.nombre as area,
       h.dia_semana, h.hora_inicio, h.hora_fin
FROM trainers t
JOIN horarios_entrenamiento h ON t.id = h.trainer_id
JOIN areas_entrenamiento a ON h.area_id = a.id
ORDER BY t.nombres, h.dia_semana, h.hora_inicio;

-- 8. Consultar campers con estado y nivel de riesgo
SELECT c.nombres, c.apellidos, c.estado, c.nivel_riesgo
FROM campers c;

-- 9. Obtener módulos con sus porcentajes
SELECT m.nombre as modulo, r.nombre as ruta,
       m.porcentaje_teorico, m.porcentaje_practico, m.porcentaje_quizzes
FROM modulos m
JOIN rutas r ON m.ruta_id = r.id;

-- 10. Mostrar áreas con sus campers
SELECT a.nombre as area, c.nombres, c.apellidos
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
JOIN campers c ON aa.camper_id = c.id
WHERE aa.fecha_fin IS NULL;

-- JOINs con condiciones específicas

-- 1. Listar campers que han aprobado todos los módulos
WITH ModulosAprobados AS (
    SELECT c.id, r.id as ruta_id,
           COUNT(DISTINCT m.id) as total_modulos,
           COUNT(DISTINCT CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) >= 60 THEN m.id END) as modulos_aprobados
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN rutas r ON i.ruta_id = r.id
    JOIN modulos m ON r.id = m.ruta_id
    LEFT JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    GROUP BY c.id, r.id
)
SELECT c.nombres, c.apellidos, r.nombre as ruta
FROM ModulosAprobados ma
JOIN campers c ON ma.camper_id = c.id
JOIN rutas r ON ma.ruta_id = r.id
WHERE ma.total_modulos = ma.modulos_aprobados;

-- 2. Mostrar rutas con más de 10 campers
SELECT r.nombre as ruta, COUNT(i.id) as total_campers
FROM rutas r
JOIN inscripciones i ON r.id = i.ruta_id
WHERE i.estado = 'Activa'
GROUP BY r.id, r.nombre
HAVING COUNT(i.id) > 10;

-- 3. Consultar áreas con más del 80% de ocupación
SELECT a.nombre, a.capacidad_maxima,
       COUNT(aa.id) as ocupacion_actual,
       (COUNT(aa.id) / a.capacidad_maxima * 100) as porcentaje_ocupacion
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
WHERE aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima
HAVING (COUNT(aa.id) / a.capacidad_maxima * 100) > 80;

-- 4. Obtener trainers con múltiples rutas
SELECT t.nombres, t.apellidos, COUNT(DISTINCT at.ruta_id) as total_rutas
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
GROUP BY t.id, t.nombres, t.apellidos
HAVING COUNT(DISTINCT at.ruta_id) > 1;

-- 5. Listar evaluaciones con nota práctica mayor que teórica
SELECT c.nombres, c.apellidos, m.nombre as modulo,
       e.nota_teorica, e.nota_practica
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
JOIN modulos m ON e.modulo_id = m.id
WHERE e.nota_practica > e.nota_teorica;

-- 6. Mostrar campers en rutas con MySQL como SGDB principal
SELECT c.nombres, c.apellidos, r.nombre as ruta
FROM campers c
JOIN inscripciones i ON c.id = i.camper_id
JOIN rutas r ON i.ruta_id = r.id
JOIN bases_datos_rutas bdr ON r.id = bdr.ruta_id
WHERE bdr.tipo = 'Principal' AND bdr.nombre_sgdb = 'MySQL';

-- 7. Obtener módulos con bajo rendimiento
SELECT m.nombre as modulo, r.nombre as ruta,
       COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60 THEN 1 END) as total_bajo_rendimiento
FROM modulos m
JOIN rutas r ON m.ruta_id = r.id
JOIN evaluaciones e ON m.id = e.modulo_id
GROUP BY m.id, m.nombre, r.id, r.nombre
HAVING COUNT(CASE WHEN (e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) < 60 THEN 1 END) > 5;

-- 8. Consultar rutas con más de 3 módulos
SELECT r.nombre as ruta, COUNT(m.id) as total_modulos
FROM rutas r
JOIN modulos m ON r.id = m.ruta_id
GROUP BY r.id, r.nombre
HAVING COUNT(m.id) > 3;

-- 9. Listar inscripciones recientes
SELECT c.nombres, c.apellidos, r.nombre as ruta, i.fecha_inscripcion
FROM inscripciones i
JOIN campers c ON i.camper_id = c.id
JOIN rutas r ON i.ruta_id = r.id
WHERE i.fecha_inscripcion >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- 10. Obtener trainers de campers en alto riesgo
SELECT DISTINCT t.nombres, t.apellidos
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
JOIN campers c ON i.camper_id = c.id
WHERE c.nivel_riesgo = 'Alto';

-- JOINs con funciones de agregación

-- 1. Promedio de nota final por módulo
SELECT m.nombre as modulo,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_nota_final
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
GROUP BY m.id, m.nombre;

-- 2. Cantidad total de campers por ruta
SELECT r.nombre as ruta, COUNT(i.id) as total_campers
FROM rutas r
LEFT JOIN inscripciones i ON r.id = i.ruta_id
WHERE i.estado = 'Activa'
GROUP BY r.id, r.nombre;

-- 3. Cantidad de evaluaciones por trainer
SELECT t.nombres, t.apellidos, COUNT(e.id) as total_evaluaciones
FROM trainers t
JOIN asignaciones_trainers at ON t.id = at.trainer_id
JOIN inscripciones i ON at.ruta_id = i.ruta_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
GROUP BY t.id, t.nombres, t.apellidos;

-- 4. Promedio de rendimiento por área
SELECT a.nombre as area,
       AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_rendimiento
FROM areas_entrenamiento a
JOIN asignaciones_areas aa ON a.id = aa.area_id
JOIN inscripciones i ON aa.camper_id = i.camper_id
JOIN evaluaciones e ON i.id = e.inscripcion_id
GROUP BY a.id, a.nombre;

-- 5. Cantidad de módulos por ruta
SELECT r.nombre as ruta, COUNT(m.id) as total_modulos
FROM rutas r
JOIN modulos m ON r.id = m.ruta_id
GROUP BY r.id, r.nombre;

-- 6. Promedio de nota final de campers cursando
SELECT AVG(e.nota_teorica * 0.3 + e.nota_practica * 0.6 + e.nota_trabajos * 0.1) as promedio_nota_final
FROM evaluaciones e
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
WHERE c.estado = 'Cursando';

-- 7. Número de campers evaluados por módulo
SELECT m.nombre as modulo, COUNT(DISTINCT c.id) as total_campers_evaluados
FROM modulos m
JOIN evaluaciones e ON m.id = e.modulo_id
JOIN inscripciones i ON e.inscripcion_id = i.id
JOIN campers c ON i.camper_id = c.id
GROUP BY m.id, m.nombre;

-- 8. Porcentaje de ocupación por área
SELECT a.nombre, a.capacidad_maxima,
       COUNT(aa.id) as ocupacion_actual,
       (COUNT(aa.id) / a.capacidad_maxima * 100) as porcentaje_ocupacion
FROM areas_entrenamiento a
LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
GROUP BY a.id, a.nombre, a.capacidad_maxima;

-- 9. Cantidad de trainers por área
SELECT a.nombre, COUNT(DISTINCT t.id) as total_trainers
FROM areas_entrenamiento a
JOIN horarios_entrenamiento h ON a.id = h.area_id
JOIN trainers t ON h.trainer_id = t.id
GROUP BY a.id, a.nombre;

-- 10. Rutas con más campers en riesgo alto
SELECT r.nombre as ruta, COUNT(c.id) as total_campers_riesgo_alto
FROM rutas r
JOIN inscripciones i ON r.id = i.ruta_id
JOIN campers c ON i.camper_id = c.id
WHERE c.nivel_riesgo = 'Alto'
GROUP BY r.id, r.nombre
ORDER BY total_campers_riesgo_alto DESC; 