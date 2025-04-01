-- Control de Acceso y Roles de Usuario

-- Crear tabla de roles
CREATE TABLE roles (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de permisos
CREATE TABLE permisos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    modulo VARCHAR(50) NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear tabla de usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    ultimo_acceso TIMESTAMP NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

-- Crear tabla de asignación de permisos a roles
CREATE TABLE permisos_roles (
    rol_id INT NOT NULL,
    permiso_id INT NOT NULL,
    fecha_asignacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rol_id, permiso_id),
    FOREIGN KEY (rol_id) REFERENCES roles(id),
    FOREIGN KEY (permiso_id) REFERENCES permisos(id)
);

-- Crear tabla de auditoría de accesos
CREATE TABLE auditoria_accesos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    usuario_id INT NOT NULL,
    accion VARCHAR(50) NOT NULL,
    tabla_afectada VARCHAR(50) NOT NULL,
    registro_id INT,
    fecha_acceso TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_acceso VARCHAR(45),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Insertar roles base
INSERT INTO roles (nombre, descripcion) VALUES
('Coordinador Académico', 'Acceso total al sistema'),
('Trainer', 'Gestión de evaluaciones y asignación de rutas'),
('Encargado de Inscripciones', 'Registro y actualización de datos de campers'),
('Administrador de Rutas', 'Gestión de rutas y módulos'),
('Encargado de Áreas', 'Gestión de áreas y horarios');

-- Insertar permisos base
INSERT INTO permisos (nombre, descripcion, modulo) VALUES
-- Permisos de Campers
('ver_campers', 'Ver lista de campers', 'Campers'),
('crear_camper', 'Crear nuevo camper', 'Campers'),
('editar_camper', 'Editar información de camper', 'Campers'),
('eliminar_camper', 'Eliminar camper', 'Campers'),

-- Permisos de Evaluaciones
('ver_evaluaciones', 'Ver evaluaciones', 'Evaluaciones'),
('crear_evaluacion', 'Crear nueva evaluación', 'Evaluaciones'),
('editar_evaluacion', 'Editar evaluación', 'Evaluaciones'),
('eliminar_evaluacion', 'Eliminar evaluación', 'Evaluaciones'),

-- Permisos de Rutas
('ver_rutas', 'Ver lista de rutas', 'Rutas'),
('crear_ruta', 'Crear nueva ruta', 'Rutas'),
('editar_ruta', 'Editar ruta', 'Rutas'),
('eliminar_ruta', 'Eliminar ruta', 'Rutas'),

-- Permisos de Módulos
('ver_modulos', 'Ver lista de módulos', 'Módulos'),
('crear_modulo', 'Crear nuevo módulo', 'Módulos'),
('editar_modulo', 'Editar módulo', 'Módulos'),
('eliminar_modulo', 'Eliminar módulo', 'Módulos'),

-- Permisos de Áreas
('ver_areas', 'Ver lista de áreas', 'Áreas'),
('crear_area', 'Crear nueva área', 'Áreas'),
('editar_area', 'Editar área', 'Áreas'),
('eliminar_area', 'Eliminar área', 'Áreas'),

-- Permisos de Horarios
('ver_horarios', 'Ver horarios', 'Horarios'),
('crear_horario', 'Crear nuevo horario', 'Horarios'),
('editar_horario', 'Editar horario', 'Horarios'),
('eliminar_horario', 'Eliminar horario', 'Horarios'),

-- Permisos de Usuarios
('ver_usuarios', 'Ver lista de usuarios', 'Usuarios'),
('crear_usuario', 'Crear nuevo usuario', 'Usuarios'),
('editar_usuario', 'Editar usuario', 'Usuarios'),
('eliminar_usuario', 'Eliminar usuario', 'Usuarios'),

-- Permisos de Reportes
('ver_reportes', 'Ver reportes', 'Reportes'),
('generar_reportes', 'Generar reportes', 'Reportes'),
('exportar_reportes', 'Exportar reportes', 'Reportes');

-- Asignar permisos a roles
-- Coordinador Académico (todos los permisos)
INSERT INTO permisos_roles (rol_id, permiso_id)
SELECT 1, id FROM permisos;

-- Trainer
INSERT INTO permisos_roles (rol_id, permiso_id)
SELECT 2, id FROM permisos 
WHERE modulo IN ('Evaluaciones', 'Rutas', 'Horarios', 'Reportes');

-- Encargado de Inscripciones
INSERT INTO permisos_roles (rol_id, permiso_id)
SELECT 3, id FROM permisos 
WHERE modulo IN ('Campers', 'Inscripciones', 'Reportes');

-- Administrador de Rutas
INSERT INTO permisos_roles (rol_id, permiso_id)
SELECT 4, id FROM permisos 
WHERE modulo IN ('Rutas', 'Módulos', 'Reportes');

-- Encargado de Áreas
INSERT INTO permisos_roles (rol_id, permiso_id)
SELECT 5, id FROM permisos 
WHERE modulo IN ('Áreas', 'Horarios', 'Reportes');

-- Procedimiento para verificar permisos
DELIMITER //

CREATE PROCEDURE sp_verificar_permiso(
    IN p_usuario_id INT,
    IN p_permiso_nombre VARCHAR(50),
    OUT p_tiene_permiso BOOLEAN
)
BEGIN
    DECLARE v_rol_id INT;
    
    -- Obtener rol del usuario
    SELECT rol_id INTO v_rol_id
    FROM usuarios
    WHERE id = p_usuario_id;
    
    -- Verificar si tiene el permiso
    SELECT EXISTS (
        SELECT 1
        FROM permisos_roles pr
        JOIN permisos p ON pr.permiso_id = p.id
        WHERE pr.rol_id = v_rol_id
        AND p.nombre = p_permiso_nombre
        AND p.estado = 'Activo'
    ) INTO p_tiene_permiso;
END //

-- Procedimiento para registrar acceso
CREATE PROCEDURE sp_registrar_acceso(
    IN p_usuario_id INT,
    IN p_accion VARCHAR(50),
    IN p_tabla VARCHAR(50),
    IN p_registro_id INT,
    IN p_ip VARCHAR(45)
)
BEGIN
    INSERT INTO auditoria_accesos (
        usuario_id,
        accion,
        tabla_afectada,
        registro_id,
        ip_acceso
    ) VALUES (
        p_usuario_id,
        p_accion,
        p_tabla,
        p_registro_id,
        p_ip
    );
    
    -- Actualizar último acceso
    UPDATE usuarios
    SET ultimo_acceso = CURRENT_TIMESTAMP
    WHERE id = p_usuario_id;
END //

-- Trigger para auditoría de cambios
CREATE TRIGGER tr_auditoria_cambios
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.estado != NEW.estado THEN
        CALL sp_registrar_acceso(
            NEW.id,
            'Cambio de Estado',
            'usuarios',
            NEW.id,
            NULL
        );
    END IF;
END //

DELIMITER ; 