-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS campuslands_db;
USE campuslands_db;

-- Tabla de Tipos de Documento
CREATE TABLE tipos_documento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Ciudades
CREATE TABLE ciudades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    codigo_departamento VARCHAR(10) NOT NULL,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Departamentos
CREATE TABLE departamentos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    codigo VARCHAR(10) NOT NULL UNIQUE,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Niveles Educativos
CREATE TABLE niveles_educativos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Campers
CREATE TABLE campers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_documento_id INT NOT NULL,
    identificacion VARCHAR(20) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F', 'O') NOT NULL,
    ciudad_id INT NOT NULL,
    direccion TEXT NOT NULL,
    acudiente VARCHAR(200) NOT NULL,
    telefono_contacto VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    nivel_educativo_id INT NOT NULL,
    estado ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado') NOT NULL,
    nivel_riesgo ENUM('Bajo', 'Medio', 'Alto') NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tipo_documento_id) REFERENCES tipos_documento(id),
    FOREIGN KEY (ciudad_id) REFERENCES ciudades(id),
    FOREIGN KEY (nivel_educativo_id) REFERENCES niveles_educativos(id),
    UNIQUE KEY uk_camper_documento (tipo_documento_id, identificacion)
);

-- Tabla de Rutas de Entrenamiento
CREATE TABLE rutas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_meses INT NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Categorías de Módulos
CREATE TABLE categorias_modulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Módulos
CREATE TABLE modulos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT NOT NULL,
    categoria_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    orden INT NOT NULL,
    duracion_horas INT NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ruta_id) REFERENCES rutas(id),
    FOREIGN KEY (categoria_id) REFERENCES categorias_modulos(id)
);

-- Tabla de Bases de Datos por Ruta
CREATE TABLE bases_datos_rutas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    ruta_id INT NOT NULL,
    nombre_sgdb VARCHAR(50) NOT NULL,
    tipo ENUM('Principal', 'Alternativo') NOT NULL,
    version VARCHAR(20),
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

-- Tabla de Tipos de Área
CREATE TABLE tipos_area (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Áreas de Entrenamiento
CREATE TABLE areas_entrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_area_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    capacidad_maxima INT NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tipo_area_id) REFERENCES tipos_area(id)
);

-- Tabla de Equipos
CREATE TABLE equipos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    estado ENUM('Activo', 'Inactivo', 'Mantenimiento') NOT NULL,
    fecha_adquisicion DATE,
    FOREIGN KEY (area_id) REFERENCES areas_entrenamiento(id)
);

-- Tabla de Trainers
CREATE TABLE trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tipo_documento_id INT NOT NULL,
    identificacion VARCHAR(20) NOT NULL,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    especialidad VARCHAR(100) NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    fecha_ingreso DATE NOT NULL,
    FOREIGN KEY (tipo_documento_id) REFERENCES tipos_documento(id),
    UNIQUE KEY uk_trainer_documento (tipo_documento_id, identificacion)
);

-- Tabla de Certificaciones de Trainers
CREATE TABLE certificaciones_trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    entidad VARCHAR(100) NOT NULL,
    fecha_obtencion DATE NOT NULL,
    fecha_expiracion DATE,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (trainer_id) REFERENCES trainers(id)
);

-- Tabla de Asignaciones de Trainers a Rutas
CREATE TABLE asignaciones_trainers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    trainer_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('Activa', 'Finalizada', 'Cancelada') NOT NULL,
    FOREIGN KEY (trainer_id) REFERENCES trainers(id),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

-- Tabla de Horarios de Entrenamiento
CREATE TABLE horarios_entrenamiento (
    id INT PRIMARY KEY AUTO_INCREMENT,
    area_id INT NOT NULL,
    trainer_id INT NOT NULL,
    ruta_id INT NOT NULL,
    dia_semana ENUM('Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes') NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (area_id) REFERENCES areas_entrenamiento(id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(id),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

-- Tabla de Inscripciones
CREATE TABLE inscripciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_inscripcion DATE NOT NULL,
    estado ENUM('Activa', 'Finalizada', 'Cancelada') NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (camper_id) REFERENCES campers(id),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

-- Tabla de Tipos de Evaluación
CREATE TABLE tipos_evaluacion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    peso DECIMAL(5,2) NOT NULL,
    estado BOOLEAN DEFAULT TRUE
);

-- Tabla de Evaluaciones
CREATE TABLE evaluaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    inscripcion_id INT NOT NULL,
    modulo_id INT NOT NULL,
    tipo_evaluacion_id INT NOT NULL,
    nota DECIMAL(5,2) NOT NULL,
    fecha_evaluacion DATE NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (inscripcion_id) REFERENCES inscripciones(id),
    FOREIGN KEY (modulo_id) REFERENCES modulos(id),
    FOREIGN KEY (tipo_evaluacion_id) REFERENCES tipos_evaluacion(id)
);

-- Tabla de Asignaciones de Campers a Áreas
CREATE TABLE asignaciones_areas (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    area_id INT NOT NULL,
    fecha_asignacion DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('Activa', 'Finalizada', 'Cancelada') NOT NULL,
    FOREIGN KEY (camper_id) REFERENCES campers(id),
    FOREIGN KEY (area_id) REFERENCES areas_entrenamiento(id)
);

-- Tabla de Asistencias
CREATE TABLE asistencias (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    horario_id INT NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('Presente', 'Ausente', 'Justificado', 'Tardanza') NOT NULL,
    observaciones TEXT,
    FOREIGN KEY (camper_id) REFERENCES campers(id),
    FOREIGN KEY (horario_id) REFERENCES horarios_entrenamiento(id)
);

-- Tabla de Justificaciones
CREATE TABLE justificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    asistencia_id INT NOT NULL,
    motivo TEXT NOT NULL,
    documento_soporte VARCHAR(255),
    fecha_justificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('Pendiente', 'Aprobada', 'Rechazada') NOT NULL,
    FOREIGN KEY (asistencia_id) REFERENCES asistencias(id)
);

-- Tabla de Usuarios
CREATE TABLE usuarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol_id INT NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    ultimo_acceso TIMESTAMP NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de Notificaciones
CREATE TABLE notificaciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    destinatario_id INT NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    mensaje TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('No leída', 'Leída', 'Archivada') NOT NULL,
    FOREIGN KEY (destinatario_id) REFERENCES usuarios(id)
);

-- Tabla de Egresados
CREATE TABLE egresados (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    ruta_id INT NOT NULL,
    fecha_graduacion DATE NOT NULL,
    promedio_final DECIMAL(5,2) NOT NULL,
    certificado VARCHAR(255),
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (camper_id) REFERENCES campers(id),
    FOREIGN KEY (ruta_id) REFERENCES rutas(id)
);

-- Tabla de Historial Académico
CREATE TABLE historial_academico (
    id INT PRIMARY KEY AUTO_INCREMENT,
    camper_id INT NOT NULL,
    modulo_id INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('En curso', 'Aprobado', 'Reprobado', 'Retirado') NOT NULL,
    promedio DECIMAL(5,2),
    observaciones TEXT,
    FOREIGN KEY (camper_id) REFERENCES campers(id),
    FOREIGN KEY (modulo_id) REFERENCES modulos(id)
);

-- Tabla de Proyectos
CREATE TABLE proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    modulo_id INT NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (modulo_id) REFERENCES modulos(id)
);

-- Tabla de Entregas de Proyectos
CREATE TABLE entregas_proyectos (
    id INT PRIMARY KEY AUTO_INCREMENT,
    proyecto_id INT NOT NULL,
    camper_id INT NOT NULL,
    fecha_entrega TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    calificacion DECIMAL(5,2),
    observaciones TEXT,
    estado ENUM('Pendiente', 'Entregado', 'Calificado') NOT NULL,
    FOREIGN KEY (proyecto_id) REFERENCES proyectos(id),
    FOREIGN KEY (camper_id) REFERENCES campers(id)
);

-- Tabla de Materiales de Apoyo
CREATE TABLE materiales_apoyo (
    id INT PRIMARY KEY AUTO_INCREMENT,
    modulo_id INT NOT NULL,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo ENUM('Documento', 'Video', 'Enlace', 'Otro') NOT NULL,
    url VARCHAR(255),
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (modulo_id) REFERENCES modulos(id)
);

-- Tabla de Comentarios
CREATE TABLE comentarios (
    id INT PRIMARY KEY AUTO_INCREMENT,
    material_id INT NOT NULL,
    usuario_id INT NOT NULL,
    contenido TEXT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (material_id) REFERENCES materiales_apoyo(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Tabla de Encuestas de Satisfacción
CREATE TABLE encuestas_satisfaccion (
    id INT PRIMARY KEY AUTO_INCREMENT,
    modulo_id INT NOT NULL,
    trainer_id INT NOT NULL,
    camper_id INT NOT NULL,
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    calificacion_general INT NOT NULL,
    calificacion_contenido INT NOT NULL,
    calificacion_trainer INT NOT NULL,
    comentarios TEXT,
    FOREIGN KEY (modulo_id) REFERENCES modulos(id),
    FOREIGN KEY (trainer_id) REFERENCES trainers(id),
    FOREIGN KEY (camper_id) REFERENCES campers(id)
);

-- Tabla de Configuraciones del Sistema
CREATE TABLE configuraciones (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    valor TEXT NOT NULL,
    descripcion TEXT,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
); 