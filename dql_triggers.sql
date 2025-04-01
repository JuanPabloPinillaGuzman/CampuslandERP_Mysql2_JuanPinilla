-- Triggers SQL para el Sistema de Seguimiento Académico

DELIMITER //

-- 1. Calcular nota final al insertar evaluación
CREATE TRIGGER tr_calcular_nota_final_ins
AFTER INSERT ON evaluaciones
FOR EACH ROW
BEGIN
    UPDATE evaluaciones
    SET nota_final = (
        NEW.nota_teorica * 0.3 +
        NEW.nota_practica * 0.6 +
        NEW.nota_trabajos * 0.1
    )
    WHERE id = NEW.id;
END //

-- 2. Verificar aprobación al actualizar nota final
CREATE TRIGGER tr_verificar_aprobacion_upd
AFTER UPDATE ON evaluaciones
FOR EACH ROW
BEGIN
    IF NEW.nota_final >= 60 THEN
        UPDATE inscripciones i
        JOIN evaluaciones e ON i.id = e.inscripcion_id
        SET i.estado = 'Aprobado'
        WHERE e.id = NEW.id;
    ELSE
        UPDATE inscripciones i
        JOIN evaluaciones e ON i.id = e.inscripcion_id
        SET i.estado = 'Reprobado'
        WHERE e.id = NEW.id;
    END IF;
END //

-- 3. Actualizar estado del camper al inscribirse
CREATE TRIGGER tr_actualizar_estado_inscripcion_ins
AFTER INSERT ON inscripciones
FOR EACH ROW
BEGIN
    UPDATE campers
    SET estado = 'Inscrito'
    WHERE id = NEW.camper_id;
END //

-- 4. Recalcular promedio al actualizar evaluación
CREATE TRIGGER tr_recalcular_promedio_upd
AFTER UPDATE ON evaluaciones
FOR EACH ROW
BEGIN
    DECLARE v_promedio DECIMAL(5,2);
    
    SELECT AVG(nota_final)
    INTO v_promedio
    FROM evaluaciones
    WHERE inscripcion_id = NEW.inscripcion_id;
    
    UPDATE inscripciones
    SET promedio = v_promedio
    WHERE id = NEW.inscripcion_id;
END //

-- 5. Marcar camper como retirado al eliminar inscripción
CREATE TRIGGER tr_marcar_retirado_del
AFTER DELETE ON inscripciones
FOR EACH ROW
BEGIN
    UPDATE campers
    SET estado = 'Retirado'
    WHERE id = OLD.camper_id;
END //

-- 6. Registrar SGDB al insertar módulo
CREATE TRIGGER tr_registrar_sgdb_modulo_ins
AFTER INSERT ON modulos
FOR EACH ROW
BEGIN
    IF NEW.nombre LIKE '%Bases de Datos%' THEN
        INSERT INTO bases_datos_rutas (ruta_id, nombre_sgdb)
        VALUES (NEW.ruta_id, 'MySQL');
    END IF;
END //

-- 7. Verificar duplicados de trainer
CREATE TRIGGER tr_verificar_duplicado_trainer_ins
BEFORE INSERT ON trainers
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM trainers 
        WHERE identificacion = NEW.identificacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un trainer con esta identificación';
    END IF;
END //

-- 8. Validar capacidad de área
CREATE TRIGGER tr_validar_capacidad_area_ins
BEFORE INSERT ON asignaciones_areas
FOR EACH ROW
BEGIN
    DECLARE v_capacidad_actual INT;
    
    SELECT COUNT(*)
    INTO v_capacidad_actual
    FROM asignaciones_areas
    WHERE area_id = NEW.area_id
    AND fecha_fin IS NULL;
    
    IF v_capacidad_actual >= (
        SELECT capacidad_maxima 
        FROM areas_entrenamiento 
        WHERE id = NEW.area_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El área ha alcanzado su capacidad máxima';
    END IF;
END //

-- 9. Marcar bajo rendimiento
CREATE TRIGGER tr_marcar_bajo_rendimiento_ins
AFTER INSERT ON evaluaciones
FOR EACH ROW
BEGIN
    IF NEW.nota_final < 60 THEN
        UPDATE campers c
        JOIN inscripciones i ON c.id = i.camper_id
        SET c.estado = 'Bajo rendimiento'
        WHERE i.id = NEW.inscripcion_id;
    END IF;
END //

-- 10. Mover a egresados al graduarse
CREATE TRIGGER tr_mover_egresado_upd
AFTER UPDATE ON campers
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Graduado' AND OLD.estado != 'Graduado' THEN
        INSERT INTO egresados (
            camper_id, fecha_graduacion, ruta_id
        )
        SELECT 
            NEW.id,
            CURDATE(),
            i.ruta_id
        FROM inscripciones i
        WHERE i.camper_id = NEW.id
        AND i.estado = 'Activa';
    END IF;
END //

-- 11. Verificar solapamiento de horarios
CREATE TRIGGER tr_verificar_solapamiento_horarios_ins
BEFORE INSERT ON horarios_entrenamiento
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM horarios_entrenamiento
        WHERE trainer_id = NEW.trainer_id
        AND dia_semana = NEW.dia_semana
        AND (
            (NEW.hora_inicio BETWEEN hora_inicio AND hora_fin) OR
            (NEW.hora_fin BETWEEN hora_inicio AND hora_fin)
        )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El horario se solapa con otro existente';
    END IF;
END //

-- 12. Liberar recursos al eliminar trainer
CREATE TRIGGER tr_liberar_recursos_trainer_del
AFTER DELETE ON trainers
FOR EACH ROW
BEGIN
    -- Liberar horarios
    DELETE FROM horarios_entrenamiento
    WHERE trainer_id = OLD.id;
    
    -- Liberar asignaciones
    DELETE FROM asignaciones_trainers
    WHERE trainer_id = OLD.id;
END //

-- 13. Actualizar módulos al cambiar ruta
CREATE TRIGGER tr_actualizar_modulos_ruta_upd
AFTER UPDATE ON inscripciones
FOR EACH ROW
BEGIN
    IF NEW.ruta_id != OLD.ruta_id THEN
        -- Eliminar evaluaciones antiguas
        DELETE FROM evaluaciones
        WHERE inscripcion_id = NEW.id;
        
        -- Insertar nuevos módulos
        INSERT INTO evaluaciones (
            inscripcion_id, modulo_id, fecha_evaluacion
        )
        SELECT 
            NEW.id,
            m.id,
            CURDATE()
        FROM modulos m
        WHERE m.ruta_id = NEW.ruta_id;
    END IF;
END //

-- 14. Verificar duplicado de camper
CREATE TRIGGER tr_verificar_duplicado_camper_ins
BEFORE INSERT ON campers
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1 FROM campers 
        WHERE identificacion = NEW.identificacion
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ya existe un camper con esta identificación';
    END IF;
END //

-- 15. Actualizar estado del módulo
CREATE TRIGGER tr_actualizar_estado_modulo_upd
AFTER UPDATE ON evaluaciones
FOR EACH ROW
BEGIN
    UPDATE modulos
    SET estado = CASE
        WHEN NEW.nota_final >= 60 THEN 'Aprobado'
        ELSE 'Reprobado'
    END
    WHERE id = NEW.modulo_id;
END //

-- 16. Verificar conocimiento del trainer
CREATE TRIGGER tr_verificar_conocimiento_trainer_ins
BEFORE INSERT ON asignaciones_trainers
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM trainers
        WHERE id = NEW.trainer_id
        AND especialidad LIKE CONCAT('%', (
            SELECT nombre FROM rutas WHERE id = NEW.ruta_id
        ), '%')
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El trainer no tiene la especialidad requerida para esta ruta';
    END IF;
END //

-- 17. Liberar campers al desactivar área
CREATE TRIGGER tr_liberar_campers_area_upd
AFTER UPDATE ON areas_entrenamiento
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Inactiva' AND OLD.estado = 'Activa' THEN
        UPDATE asignaciones_areas
        SET fecha_fin = CURDATE()
        WHERE area_id = NEW.id
        AND fecha_fin IS NULL;
    END IF;
END //

-- 18. Clonar plantilla de ruta
CREATE TRIGGER tr_clonar_plantilla_ruta_ins
AFTER INSERT ON rutas
FOR EACH ROW
BEGIN
    -- Clonar módulos base
    INSERT INTO modulos (
        ruta_id, nombre, descripcion, orden
    )
    SELECT 
        NEW.id,
        nombre,
        descripcion,
        orden
    FROM modulos
    WHERE ruta_id = 1; -- Asumiendo que la ruta 1 es la plantilla base
    
    -- Clonar SGDBs base
    INSERT INTO bases_datos_rutas (
        ruta_id, nombre_sgdb
    )
    SELECT 
        NEW.id,
        nombre_sgdb
    FROM bases_datos_rutas
    WHERE ruta_id = 1;
END //

-- 19. Validar nota práctica
CREATE TRIGGER tr_validar_nota_practica_ins
BEFORE INSERT ON evaluaciones
FOR EACH ROW
BEGIN
    IF NEW.nota_practica > 60 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total';
    END IF;
END //

-- 20. Notificar cambios de ruta
CREATE TRIGGER tr_notificar_cambios_ruta_upd
AFTER UPDATE ON rutas
FOR EACH ROW
BEGIN
    -- Insertar notificación para trainers
    INSERT INTO notificaciones (
        destinatario_id,
        tipo,
        mensaje,
        fecha
    )
    SELECT 
        t.id,
        'Cambio de Ruta',
        CONCAT('La ruta ', NEW.nombre, ' ha sido modificada'),
        CURDATE()
    FROM trainers t
    JOIN asignaciones_trainers at ON t.id = at.trainer_id
    WHERE at.ruta_id = NEW.id;
END //

DELIMITER ; 