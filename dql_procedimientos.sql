-- Procedimientos Almacenados para el Sistema de Seguimiento Académico

DELIMITER //

-- 1. Registrar un nuevo camper
CREATE PROCEDURE sp_registrar_camper(
    IN p_identificacion VARCHAR(20),
    IN p_nombres VARCHAR(100),
    IN p_apellidos VARCHAR(100),
    IN p_direccion TEXT,
    IN p_acudiente VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_email VARCHAR(100)
)
BEGIN
    DECLARE v_existe INT;
    
    -- Validar si el camper ya existe
    SELECT COUNT(*) INTO v_existe
    FROM campers
    WHERE identificacion = p_identificacion;
    
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El camper ya existe en el sistema';
    ELSE
        INSERT INTO campers (
            identificacion, nombres, apellidos, 
            direccion, acudiente, telefono, email,
            estado, nivel_riesgo
        ) VALUES (
            p_identificacion, p_nombres, p_apellidos,
            p_direccion, p_acudiente, p_telefono, p_email,
            'Inscrito', 'Bajo'
        );
    END IF;
END //

-- 2. Actualizar estado de un camper
CREATE PROCEDURE sp_actualizar_estado_camper(
    IN p_camper_id INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_estado_valido BOOLEAN;
    
    -- Validar estado válido
    SET v_estado_valido = p_nuevo_estado IN ('Inscrito', 'Cursando', 'Graduado', 'Retirado');
    
    IF NOT v_estado_valido THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado no válido';
    ELSE
        UPDATE campers
        SET estado = p_nuevo_estado
        WHERE id = p_camper_id;
    END IF;
END //

-- 3. Procesar inscripción de un camper
CREATE PROCEDURE sp_procesar_inscripcion(
    IN p_camper_id INT,
    IN p_ruta_id INT,
    IN p_fecha_inscripcion DATE
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    DECLARE v_inscritos_actuales INT;
    
    -- Verificar capacidad de la ruta
    SELECT COUNT(*) INTO v_inscritos_actuales
    FROM inscripciones
    WHERE ruta_id = p_ruta_id AND estado = 'Activa';
    
    SELECT capacidad_maxima INTO v_capacidad_disponible
    FROM rutas
    WHERE id = p_ruta_id;
    
    IF v_inscritos_actuales >= v_capacidad_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La ruta ha alcanzado su capacidad máxima';
    ELSE
        INSERT INTO inscripciones (
            camper_id, ruta_id, fecha_inscripcion, estado
        ) VALUES (
            p_camper_id, p_ruta_id, p_fecha_inscripcion, 'Activa'
        );
        
        -- Actualizar estado del camper
        UPDATE campers
        SET estado = 'Cursando'
        WHERE id = p_camper_id;
    END IF;
END //

-- 4. Registrar evaluación completa
CREATE PROCEDURE sp_registrar_evaluacion(
    IN p_inscripcion_id INT,
    IN p_modulo_id INT,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_nota_practica DECIMAL(5,2),
    IN p_nota_trabajos DECIMAL(5,2)
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    -- Validar rangos de notas
    IF p_nota_teorica < 0 OR p_nota_teorica > 10 OR
       p_nota_practica < 0 OR p_nota_practica > 10 OR
       p_nota_trabajos < 0 OR p_nota_trabajos > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Las notas deben estar entre 0 y 10';
    ELSE
        -- Calcular nota final
        SET v_nota_final = (p_nota_teorica * 0.3) + 
                          (p_nota_practica * 0.6) + 
                          (p_nota_trabajos * 0.1);
        
        INSERT INTO evaluaciones (
            inscripcion_id, modulo_id, nota_teorica,
            nota_practica, nota_trabajos, nota_final,
            fecha_evaluacion
        ) VALUES (
            p_inscripcion_id, p_modulo_id, p_nota_teorica,
            p_nota_practica, p_nota_trabajos, v_nota_final,
            CURDATE()
        );
    END IF;
END //

-- 5. Calcular y registrar nota final de módulo
CREATE PROCEDURE sp_calcular_nota_final_modulo(
    IN p_inscripcion_id INT,
    IN p_modulo_id INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    
    -- Calcular nota final
    SELECT (nota_teorica * 0.3 + nota_practica * 0.6 + nota_trabajos * 0.1)
    INTO v_nota_final
    FROM evaluaciones
    WHERE inscripcion_id = p_inscripcion_id
    AND modulo_id = p_modulo_id;
    
    -- Actualizar nota final
    UPDATE evaluaciones
    SET nota_final = v_nota_final
    WHERE inscripcion_id = p_inscripcion_id
    AND modulo_id = p_modulo_id;
END //

-- 6. Asignar campers aprobados a ruta
CREATE PROCEDURE sp_asignar_campers_aprobados(
    IN p_ruta_id INT
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    DECLARE v_inscritos_actuales INT;
    
    -- Verificar capacidad
    SELECT COUNT(*) INTO v_inscritos_actuales
    FROM inscripciones
    WHERE ruta_id = p_ruta_id AND estado = 'Activa';
    
    SELECT capacidad_maxima INTO v_capacidad_disponible
    FROM rutas
    WHERE id = p_ruta_id;
    
    IF v_inscritos_actuales >= v_capacidad_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La ruta ha alcanzado su capacidad máxima';
    ELSE
        -- Asignar campers aprobados
        INSERT INTO inscripciones (
            camper_id, ruta_id, fecha_inscripcion, estado
        )
        SELECT c.id, p_ruta_id, CURDATE(), 'Activa'
        FROM campers c
        JOIN evaluaciones e ON c.id = e.inscripcion_id
        WHERE e.nota_final >= 60
        AND c.estado = 'Cursando'
        LIMIT (v_capacidad_disponible - v_inscritos_actuales);
    END IF;
END //

-- 7. Asignar trainer a ruta y área
CREATE PROCEDURE sp_asignar_trainer(
    IN p_trainer_id INT,
    IN p_ruta_id INT,
    IN p_area_id INT,
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME
)
BEGIN
    DECLARE v_horario_disponible BOOLEAN;
    
    -- Verificar disponibilidad del horario
    SELECT NOT EXISTS (
        SELECT 1
        FROM horarios_entrenamiento h
        WHERE h.area_id = p_area_id
        AND h.dia_semana = p_dia_semana
        AND (
            (p_hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
            (p_hora_fin BETWEEN h.hora_inicio AND h.hora_fin)
        )
    ) INTO v_horario_disponible;
    
    IF NOT v_horario_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El horario no está disponible';
    ELSE
        -- Registrar asignación del trainer
        INSERT INTO asignaciones_trainers (
            trainer_id, ruta_id, fecha_inicio
        ) VALUES (
            p_trainer_id, p_ruta_id, CURDATE()
        );
        
        -- Registrar horario
        INSERT INTO horarios_entrenamiento (
            area_id, trainer_id, ruta_id,
            dia_semana, hora_inicio, hora_fin
        ) VALUES (
            p_area_id, p_trainer_id, p_ruta_id,
            p_dia_semana, p_hora_inicio, p_hora_fin
        );
    END IF;
END //

-- 8. Registrar nueva ruta con módulos
CREATE PROCEDURE sp_registrar_ruta(
    IN p_nombre VARCHAR(100),
    IN p_capacidad_maxima INT,
    IN p_sgdb_principal VARCHAR(50)
)
BEGIN
    DECLARE v_ruta_id INT;
    
    -- Insertar ruta
    INSERT INTO rutas (nombre, capacidad_maxima)
    VALUES (p_nombre, p_capacidad_maxima);
    
    SET v_ruta_id = LAST_INSERT_ID();
    
    -- Registrar SGDB principal
    INSERT INTO bases_datos_rutas (
        ruta_id, nombre_sgdb, tipo
    ) VALUES (
        v_ruta_id, p_sgdb_principal, 'Principal'
    );
    
    -- Retornar ID de la ruta creada
    SELECT v_ruta_id AS ruta_id;
END //

-- 9. Registrar nueva área de entrenamiento
CREATE PROCEDURE sp_registrar_area(
    IN p_nombre VARCHAR(100),
    IN p_capacidad_maxima INT
)
BEGIN
    IF p_capacidad_maxima <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La capacidad máxima debe ser mayor a 0';
    ELSE
        INSERT INTO areas_entrenamiento (
            nombre, capacidad_maxima
        ) VALUES (
            p_nombre, p_capacidad_maxima
        );
    END IF;
END //

-- 10. Consultar disponibilidad de horario
CREATE PROCEDURE sp_consultar_disponibilidad(
    IN p_area_id INT,
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME
)
BEGIN
    SELECT 
        h.dia_semana,
        h.hora_inicio,
        h.hora_fin,
        t.nombres AS trainer_nombres,
        t.apellidos AS trainer_apellidos,
        r.nombre AS ruta
    FROM horarios_entrenamiento h
    JOIN trainers t ON h.trainer_id = t.id
    JOIN rutas r ON h.ruta_id = r.id
    WHERE h.area_id = p_area_id
    AND h.dia_semana = p_dia_semana
    AND (
        (p_hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
        (p_hora_fin BETWEEN h.hora_inicio AND h.hora_fin)
    );
END //

-- 11. Reasignar camper a otra ruta
CREATE PROCEDURE sp_reasignar_camper(
    IN p_camper_id INT,
    IN p_nueva_ruta_id INT
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    DECLARE v_inscritos_actuales INT;
    
    -- Verificar capacidad de la nueva ruta
    SELECT COUNT(*) INTO v_inscritos_actuales
    FROM inscripciones
    WHERE ruta_id = p_nueva_ruta_id AND estado = 'Activa';
    
    SELECT capacidad_maxima INTO v_capacidad_disponible
    FROM rutas
    WHERE id = p_nueva_ruta_id;
    
    IF v_inscritos_actuales >= v_capacidad_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nueva ruta ha alcanzado su capacidad máxima';
    ELSE
        -- Finalizar inscripción actual
        UPDATE inscripciones
        SET estado = 'Finalizada', fecha_fin = CURDATE()
        WHERE camper_id = p_camper_id AND estado = 'Activa';
        
        -- Crear nueva inscripción
        INSERT INTO inscripciones (
            camper_id, ruta_id, fecha_inscripcion, estado
        ) VALUES (
            p_camper_id, p_nueva_ruta_id, CURDATE(), 'Activa'
        );
    END IF;
END //

-- 12. Cambiar estado a Graduado
CREATE PROCEDURE sp_graduar_camper(
    IN p_camper_id INT
)
BEGIN
    DECLARE v_total_modulos INT;
    DECLARE v_modulos_aprobados INT;
    
    -- Verificar si aprobó todos los módulos
    SELECT 
        COUNT(DISTINCT m.id),
        COUNT(DISTINCT CASE WHEN e.nota_final >= 60 THEN m.id END)
    INTO v_total_modulos, v_modulos_aprobados
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN modulos m ON i.ruta_id = m.ruta_id
    LEFT JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    WHERE c.id = p_camper_id;
    
    IF v_total_modulos = v_modulos_aprobados THEN
        UPDATE campers
        SET estado = 'Graduado'
        WHERE id = p_camper_id;
        
        UPDATE inscripciones
        SET estado = 'Finalizada', fecha_fin = CURDATE()
        WHERE camper_id = p_camper_id AND estado = 'Activa';
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El camper no ha aprobado todos los módulos';
    END IF;
END //

-- 13. Consultar rendimiento de camper
CREATE PROCEDURE sp_consultar_rendimiento(
    IN p_camper_id INT
)
BEGIN
    SELECT 
        c.nombres,
        c.apellidos,
        c.estado,
        c.nivel_riesgo,
        r.nombre AS ruta,
        m.nombre AS modulo,
        e.nota_teorica,
        e.nota_practica,
        e.nota_trabajos,
        e.nota_final,
        e.fecha_evaluacion
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN rutas r ON i.ruta_id = r.id
    JOIN modulos m ON r.id = m.ruta_id
    LEFT JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    WHERE c.id = p_camper_id
    ORDER BY m.orden, e.fecha_evaluacion;
END //

-- 14. Registrar asistencia
CREATE PROCEDURE sp_registrar_asistencia(
    IN p_area_id INT,
    IN p_camper_id INT,
    IN p_fecha DATE,
    IN p_hora TIME,
    IN p_estado VARCHAR(20)
)
BEGIN
    -- Validar estado de asistencia
    IF p_estado NOT IN ('Presente', 'Ausente', 'Justificado') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Estado de asistencia no válido';
    ELSE
        INSERT INTO asistencias (
            area_id, camper_id, fecha, hora, estado
        ) VALUES (
            p_area_id, p_camper_id, p_fecha, p_hora, p_estado
        );
    END IF;
END //

-- 15. Generar reporte mensual de notas
CREATE PROCEDURE sp_generar_reporte_mensual(
    IN p_ruta_id INT,
    IN p_mes INT,
    IN p_anio INT
)
BEGIN
    SELECT 
        c.nombres,
        c.apellidos,
        m.nombre AS modulo,
        e.nota_teorica,
        e.nota_practica,
        e.nota_trabajos,
        e.nota_final,
        e.fecha_evaluacion
    FROM campers c
    JOIN inscripciones i ON c.id = i.camper_id
    JOIN modulos m ON i.ruta_id = m.ruta_id
    JOIN evaluaciones e ON i.id = e.inscripcion_id AND m.id = e.modulo_id
    WHERE i.ruta_id = p_ruta_id
    AND MONTH(e.fecha_evaluacion) = p_mes
    AND YEAR(e.fecha_evaluacion) = p_anio
    ORDER BY c.nombres, m.orden;
END //

-- 16. Validar y registrar asignación de salón
CREATE PROCEDURE sp_asignar_salon(
    IN p_area_id INT,
    IN p_ruta_id INT,
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME
)
BEGIN
    DECLARE v_capacidad_disponible INT;
    DECLARE v_inscritos_actuales INT;
    
    -- Verificar capacidad
    SELECT COUNT(*) INTO v_inscritos_actuales
    FROM inscripciones
    WHERE ruta_id = p_ruta_id AND estado = 'Activa';
    
    SELECT capacidad_maxima INTO v_capacidad_disponible
    FROM areas_entrenamiento
    WHERE id = p_area_id;
    
    IF v_inscritos_actuales > v_capacidad_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El número de estudiantes excede la capacidad del salón';
    ELSE
        -- Registrar horario
        INSERT INTO horarios_entrenamiento (
            area_id, ruta_id, dia_semana,
            hora_inicio, hora_fin
        ) VALUES (
            p_area_id, p_ruta_id, p_dia_semana,
            p_hora_inicio, p_hora_fin
        );
    END IF;
END //

-- 17. Registrar cambio de horario de trainer
CREATE PROCEDURE sp_cambiar_horario_trainer(
    IN p_trainer_id INT,
    IN p_area_id INT,
    IN p_dia_semana VARCHAR(20),
    IN p_hora_inicio TIME,
    IN p_hora_fin TIME
)
BEGIN
    DECLARE v_horario_disponible BOOLEAN;
    
    -- Verificar disponibilidad
    SELECT NOT EXISTS (
        SELECT 1
        FROM horarios_entrenamiento h
        WHERE h.area_id = p_area_id
        AND h.dia_semana = p_dia_semana
        AND (
            (p_hora_inicio BETWEEN h.hora_inicio AND h.hora_fin) OR
            (p_hora_fin BETWEEN h.hora_inicio AND h.hora_fin)
        )
    ) INTO v_horario_disponible;
    
    IF NOT v_horario_disponible THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El horario no está disponible';
    ELSE
        -- Actualizar horario
        UPDATE horarios_entrenamiento
        SET hora_inicio = p_hora_inicio,
            hora_fin = p_hora_fin
        WHERE trainer_id = p_trainer_id
        AND area_id = p_area_id
        AND dia_semana = p_dia_semana;
    END IF;
END //

-- 18. Eliminar inscripción de camper
CREATE PROCEDURE sp_eliminar_inscripcion(
    IN p_camper_id INT,
    IN p_ruta_id INT
)
BEGIN
    -- Finalizar inscripción
    UPDATE inscripciones
    SET estado = 'Finalizada',
        fecha_fin = CURDATE()
    WHERE camper_id = p_camper_id
    AND ruta_id = p_ruta_id
    AND estado = 'Activa';
    
    -- Actualizar estado del camper si no tiene otras inscripciones activas
    UPDATE campers
    SET estado = 'Retirado'
    WHERE id = p_camper_id
    AND NOT EXISTS (
        SELECT 1
        FROM inscripciones
        WHERE camper_id = p_camper_id
        AND estado = 'Activa'
    );
END //

-- 19. Recalcular estado de campers
CREATE PROCEDURE sp_recalcular_estados()
BEGIN
    -- Actualizar estado de campers basado en rendimiento
    UPDATE campers c
    JOIN (
        SELECT 
            i.camper_id,
            AVG(e.nota_final) as promedio_general,
            COUNT(CASE WHEN e.nota_final < 60 THEN 1 END) as modulos_reprobados
        FROM inscripciones i
        JOIN evaluaciones e ON i.id = e.inscripcion_id
        WHERE i.estado = 'Activa'
        GROUP BY i.camper_id
    ) r ON c.id = r.camper_id
    SET c.nivel_riesgo = CASE
        WHEN r.promedio_general < 60 OR r.modulos_reprobados >= 2 THEN 'Alto'
        WHEN r.promedio_general < 70 OR r.modulos_reprobados = 1 THEN 'Medio'
        ELSE 'Bajo'
    END;
END //

-- 20. Asignar horarios automáticamente
CREATE PROCEDURE sp_asignar_horarios_automaticos()
BEGIN
    DECLARE v_trainer_id INT;
    DECLARE v_area_id INT;
    DECLARE v_ruta_id INT;
    DECLARE v_dia_semana VARCHAR(20);
    DECLARE v_hora_inicio TIME;
    DECLARE v_hora_fin TIME;
    
    -- Cursor para trainers disponibles
    DECLARE cur_trainers CURSOR FOR
    SELECT t.id, a.id, r.id
    FROM trainers t
    JOIN asignaciones_trainers at ON t.id = at.trainer_id
    JOIN rutas r ON at.ruta_id = r.id
    JOIN areas_entrenamiento a
    WHERE NOT EXISTS (
        SELECT 1
        FROM horarios_entrenamiento h
        WHERE h.trainer_id = t.id
    );
    
    -- Variables para horarios
    SET v_dia_semana = 'Lunes';
    SET v_hora_inicio = '08:00:00';
    SET v_hora_fin = '12:00:00';
    
    -- Procesar cada trainer
    OPEN cur_trainers;
    read_loop: LOOP
        FETCH cur_trainers INTO v_trainer_id, v_area_id, v_ruta_id;
        
        IF v_trainer_id IS NULL THEN
            LEAVE read_loop;
        END IF;
        
        -- Asignar horario
        INSERT INTO horarios_entrenamiento (
            area_id, trainer_id, ruta_id,
            dia_semana, hora_inicio, hora_fin
        ) VALUES (
            v_area_id, v_trainer_id, v_ruta_id,
            v_dia_semana, v_hora_inicio, v_hora_fin
        );
    END LOOP;
    CLOSE cur_trainers;
END //

DELIMITER ; 