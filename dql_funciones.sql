-- Funciones SQL para el Sistema de Seguimiento Académico

DELIMITER //

-- 1. Calcular promedio ponderado de evaluaciones de un camper
CREATE FUNCTION fn_calcular_promedio_ponderado(
    p_camper_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(
        (nota_teorica * 0.3) + 
        (nota_practica * 0.6) + 
        (nota_trabajos * 0.1)
    )
    INTO v_promedio
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.camper_id = p_camper_id;
    
    RETURN COALESCE(v_promedio, 0);
END //

-- 2. Determinar si un camper aprueba un módulo
CREATE FUNCTION fn_aprueba_modulo(
    p_camper_id INT,
    p_modulo_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    SELECT nota_final
    INTO v_nota_final
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.camper_id = p_camper_id
    AND e.modulo_id = p_modulo_id;
    
    RETURN COALESCE(v_nota_final >= 60, FALSE);
END //

-- 3. Evaluar nivel de riesgo de un camper
CREATE FUNCTION fn_evaluar_nivel_riesgo(
    p_camper_id INT
) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    DECLARE v_modulos_reprobados INT;
    
    SELECT 
        AVG(e.nota_final),
        COUNT(CASE WHEN e.nota_final < 60 THEN 1 END)
    INTO v_promedio, v_modulos_reprobados
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.camper_id = p_camper_id;
    
    RETURN CASE
        WHEN v_promedio < 60 OR v_modulos_reprobados >= 2 THEN 'Alto'
        WHEN v_promedio < 70 OR v_modulos_reprobados = 1 THEN 'Medio'
        ELSE 'Bajo'
    END;
END //

-- 4. Obtener total de campers en una ruta
CREATE FUNCTION fn_total_campers_ruta(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total INT;
    
    SELECT COUNT(*)
    INTO v_total
    FROM inscripciones
    WHERE ruta_id = p_ruta_id
    AND estado = 'Activa';
    
    RETURN COALESCE(v_total, 0);
END //

-- 5. Consultar módulos aprobados por camper
CREATE FUNCTION fn_modulos_aprobados_camper(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_aprobados INT;
    
    SELECT COUNT(*)
    INTO v_total_aprobados
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.camper_id = p_camper_id
    AND e.nota_final >= 60;
    
    RETURN COALESCE(v_total_aprobados, 0);
END //

-- 6. Validar cupos disponibles en área
CREATE FUNCTION fn_cupos_disponibles_area(
    p_area_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_capacidad_maxima INT;
    DECLARE v_ocupacion_actual INT;
    
    SELECT 
        a.capacidad_maxima,
        COUNT(aa.id)
    INTO v_capacidad_maxima, v_ocupacion_actual
    FROM areas_entrenamiento a
    LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
    WHERE a.id = p_area_id
    GROUP BY a.id, a.capacidad_maxima;
    
    RETURN COALESCE(v_capacidad_maxima - v_ocupacion_actual, 0);
END //

-- 7. Calcular porcentaje de ocupación de área
CREATE FUNCTION fn_porcentaje_ocupacion_area(
    p_area_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_porcentaje DECIMAL(5,2);
    
    SELECT 
        (COUNT(aa.id) * 100.0 / a.capacidad_maxima)
    INTO v_porcentaje
    FROM areas_entrenamiento a
    LEFT JOIN asignaciones_areas aa ON a.id = aa.area_id AND aa.fecha_fin IS NULL
    WHERE a.id = p_area_id
    GROUP BY a.id, a.capacidad_maxima;
    
    RETURN COALESCE(v_porcentaje, 0);
END //

-- 8. Obtener nota más alta en módulo
CREATE FUNCTION fn_nota_maxima_modulo(
    p_modulo_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_nota_maxima DECIMAL(5,2);
    
    SELECT MAX(nota_final)
    INTO v_nota_maxima
    FROM evaluaciones
    WHERE modulo_id = p_modulo_id;
    
    RETURN COALESCE(v_nota_maxima, 0);
END //

-- 9. Calcular tasa de aprobación de ruta
CREATE FUNCTION fn_tasa_aprobacion_ruta(
    p_ruta_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_tasa DECIMAL(5,2);
    
    SELECT 
        (COUNT(CASE WHEN e.nota_final >= 60 THEN 1 END) * 100.0 / COUNT(*))
    INTO v_tasa
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.ruta_id = p_ruta_id;
    
    RETURN COALESCE(v_tasa, 0);
END //

-- 10. Verificar disponibilidad de horario trainer
CREATE FUNCTION fn_horario_trainer_disponible(
    p_trainer_id INT,
    p_dia_semana VARCHAR(20),
    p_hora_inicio TIME,
    p_hora_fin TIME
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_disponible BOOLEAN;
    
    SELECT NOT EXISTS (
        SELECT 1
        FROM horarios_entrenamiento h
        WHERE h.trainer_id = p_trainer_id
        AND h.dia_semana = p_dia_semana
        AND (
            (p_hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
            (p_hora_fin BETWEEN h.hora_inicio AND h.hora_fin)
        )
    ) INTO v_disponible;
    
    RETURN COALESCE(v_disponible, FALSE);
END //

-- 11. Obtener promedio de notas por ruta
CREATE FUNCTION fn_promedio_notas_ruta(
    p_ruta_id INT
) RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(e.nota_final)
    INTO v_promedio
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.ruta_id = p_ruta_id;
    
    RETURN COALESCE(v_promedio, 0);
END //

-- 12. Calcular rutas asignadas a trainer
CREATE FUNCTION fn_total_rutas_trainer(
    p_trainer_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_rutas INT;
    
    SELECT COUNT(DISTINCT ruta_id)
    INTO v_total_rutas
    FROM asignaciones_trainers
    WHERE trainer_id = p_trainer_id;
    
    RETURN COALESCE(v_total_rutas, 0);
END //

-- 13. Verificar si camper puede ser graduado
CREATE FUNCTION fn_puede_graduarse(
    p_camper_id INT
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_total_modulos INT;
    DECLARE v_modulos_aprobados INT;
    
    SELECT 
        COUNT(DISTINCT m.id),
        COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN m.id END)
    INTO v_total_modulos, v_modulos_aprobados
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN modulos m ON i.ruta_id = m.ruta_id
    LEFT JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    WHERE c.id = p_camper_id;
    
    RETURN COALESCE(v_total_modulos = v_modulos_aprobados, FALSE);
END //

-- 14. Obtener estado actual de camper
CREATE FUNCTION fn_estado_actual_camper(
    p_camper_id INT
) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE v_estado VARCHAR(20);
    
    SELECT estado
    INTO v_estado
    FROM campers
    WHERE id = p_camper_id;
    
    RETURN COALESCE(v_estado, 'Desconocido');
END //

-- 15. Calcular carga horaria semanal trainer
CREATE FUNCTION fn_carga_horaria_semanal(
    p_trainer_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_carga_horaria INT;
    
    SELECT SUM(
        TIME_TO_SEC(TIMEDIFF(hora_fin, hora_inicio)) / 3600
    )
    INTO v_carga_horaria
    FROM horarios_entrenamiento
    WHERE trainer_id = p_trainer_id;
    
    RETURN COALESCE(v_carga_horaria, 0);
END //

-- 16. Verificar módulos pendientes por evaluación
CREATE FUNCTION fn_modulos_pendientes_ruta(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_pendientes INT;
    
    SELECT COUNT(*)
    INTO v_total_pendientes
    FROM modulos m
    LEFT JOIN evaluaciones e ON m.id = e.modulo_id
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE m.ruta_id = p_ruta_id
    AND e.id IS NULL;
    
    RETURN COALESCE(v_total_pendientes, 0);
END //

-- 17. Calcular promedio general del programa
CREATE FUNCTION fn_promedio_general_programa()
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(e.nota_final)
    INTO v_promedio
    FROM evaluaciones e;
    
    RETURN COALESCE(v_promedio, 0);
END //

-- 18. Verificar choque de horarios en área
CREATE FUNCTION fn_verificar_choque_horarios(
    p_area_id INT,
    p_dia_semana VARCHAR(20),
    p_hora_inicio TIME,
    p_hora_fin TIME
) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_hay_choque BOOLEAN;
    
    SELECT EXISTS (
        SELECT 1
        FROM horarios_entrenamiento h
        WHERE h.area_id = p_area_id
        AND h.dia_semana = p_dia_semana
        AND (
            (p_hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
            (p_hora_fin BETWEEN h.hora_inicio AND h.hora_fin)
        )
    ) INTO v_hay_choque;
    
    RETURN COALESCE(v_hay_choque, FALSE);
END //

-- 19. Calcular campers en riesgo por ruta
CREATE FUNCTION fn_campers_riesgo_ruta(
    p_ruta_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_riesgo INT;
    
    SELECT COUNT(DISTINCT c.id)
    INTO v_total_riesgo
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN evaluaciones e ON i.id = e.inscripcion_id
    WHERE i.ruta_id = p_ruta_id
    AND (
        AVG(e.nota_final) < 60 OR
        COUNT(CASE WHEN e.nota_final < 60 THEN 1 END) >= 2
    )
    GROUP BY c.id;
    
    RETURN COALESCE(v_total_riesgo, 0);
END //

-- 20. Consultar módulos evaluados por camper
CREATE FUNCTION fn_total_modulos_evaluados(
    p_camper_id INT
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_total_evaluados INT;
    
    SELECT COUNT(DISTINCT e.modulo_id)
    INTO v_total_evaluados
    FROM evaluaciones e
    JOIN inscripciones i ON e.inscripcion_id = i.id
    WHERE i.camper_id = p_camper_id;
    
    RETURN COALESCE(v_total_evaluados, 0);
END //

DELIMITER ; 