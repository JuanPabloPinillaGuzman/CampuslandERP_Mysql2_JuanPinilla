
CREATE DATABASE IF NOT EXISTS campuslands_db;
USE campuslands_db;

CREATE TABLE campusland (
    id_campus INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(40) NOT NULL,
    region VARCHAR(40) NOT NULL,
    ciudad VARCHAR(40) NOT NULL,
    direccion VARCHAR(130)
);

CREATE TABLE estado_camper (
    id_estado INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(40) NOT NULL,
    estado_camper ENUM('En proceso de ingreso', 'Inscrito', 'Aprobado', 'Cursando', 'Graduado', 'Expulsado', 'Retirado')
);

CREATE TABLE salon (
    id_salon INT AUTO_INCREMENT PRIMARY KEY,
    nombre_salon VARCHAR(40) NOT NULL,
    capacidad INT NOT NULL,
    CONSTRAINT chk_capacidad CHECK (capacidad > 0)
);

CREATE TABLE horario_clase (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT chk_horario CHECK (hora_fin > hora_inicio)
);

CREATE TABLE skill (
    id_skill INT AUTO_INCREMENT PRIMARY KEY,
    nombre_skill VARCHAR(40) NOT NULL,
    descripcion TEXT
);

CREATE TABLE sistema_base_datos (
    id_sgdb INT AUTO_INCREMENT PRIMARY KEY,
    nombre_sgdb VARCHAR(40) NOT NULL,
    descripcion VARCHAR(130)
);

CREATE TABLE competencia (
    id_competencia INT AUTO_INCREMENT PRIMARY KEY,
    nombre_competencia VARCHAR(40) NOT NULL UNIQUE,
    descripcion VARCHAR(130)
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    rol ENUM('admin', 'trainer', 'camper') NOT NULL,
    estado ENUM('Activo', 'Inactivo') DEFAULT 'Activo',
    ultimo_acceso TIMESTAMP NULL,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE area_entrenamiento (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre_area VARCHAR(40) NOT NULL,
    descripcion TEXT,
    capacidad_maxima INT NOT NULL,
    estado BOOLEAN DEFAULT TRUE
);

CREATE TABLE camper (
    id_camper INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(40) NOT NULL,
    apellidos VARCHAR(40) NOT NULL,
    numero_identificacion VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    genero ENUM('M', 'F', 'O') NOT NULL,
    email VARCHAR(80),
    id_campus INT,
    id_estado INT,
    nivel_riesgo ENUM('Bajo', 'Medio', 'Alto') DEFAULT 'Bajo',
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_camper_campus FOREIGN KEY (id_campus) REFERENCES campusland(id_campus),
    CONSTRAINT fk_camper_estado FOREIGN KEY (id_estado) REFERENCES estado_camper(id_estado)
);

CREATE TABLE ruta_entrenamiento (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ruta VARCHAR(40) NOT NULL,
    descripcion VARCHAR(130),
    duracion_meses INT NOT NULL,
    id_sgdb_principal INT,
    id_sgdb_alternativo INT,
    estado BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ruta_sgdb_principal FOREIGN KEY (id_sgdb_principal) REFERENCES sistema_base_datos(id_sgdb),
    CONSTRAINT fk_ruta_sgdb_alternativo FOREIGN KEY (id_sgdb_alternativo) REFERENCES sistema_base_datos(id_sgdb)
);

CREATE TABLE entrenador (
    id_entrenador INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(40) NOT NULL,
    apellidos VARCHAR(40) NOT NULL,
    email VARCHAR(70) NOT NULL,
    especialidad VARCHAR(120),
    estado BOOLEAN DEFAULT TRUE,
    fecha_ingreso DATE NOT NULL
);

CREATE TABLE estado_inscripcion (
    id_estado_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(40) NOT NULL,
    estado_inscripcion ENUM('Activa', 'Completada', 'Cancelada') DEFAULT 'Activa'
);

CREATE TABLE direccion (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    calle VARCHAR(40),
    ciudad VARCHAR(40),
    codigo_postal VARCHAR(10),
    departamento VARCHAR(40),
    pais VARCHAR(30),
    CONSTRAINT fk_direccion_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper) ON DELETE CASCADE
);

CREATE TABLE inscripcion (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_ruta INT,
    fecha_inscripcion DATE,
    id_estado_inscripcion INT,
    observaciones TEXT,
    CONSTRAINT fk_inscripcion_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    CONSTRAINT fk_inscripcion_ruta FOREIGN KEY (id_ruta) REFERENCES ruta_entrenamiento(id_ruta),
    CONSTRAINT fk_inscripcion_estado FOREIGN KEY (id_estado_inscripcion) REFERENCES estado_inscripcion(id_estado_inscripcion)
);

CREATE TABLE modulo (
    id_modulo INT AUTO_INCREMENT PRIMARY KEY,
    id_skill INT,
    nombre_modulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_horas INT NOT NULL,
    orden INT NOT NULL,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_modulo_skill FOREIGN KEY (id_skill) REFERENCES skill(id_skill)
);

CREATE TABLE grupo_campers (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_grupo VARCHAR(50) NOT NULL,
    id_ruta INT NOT NULL,
    fecha_creacion DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_grupo_ruta FOREIGN KEY (id_ruta) REFERENCES ruta_entrenamiento(id_ruta)
);

CREATE TABLE acudiente (
    id_acudiente INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    nombres VARCHAR(40) NOT NULL,
    apellidos VARCHAR(40) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(70),
    parentesco VARCHAR(40),
    CONSTRAINT fk_acudiente_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper) ON DELETE CASCADE
);

CREATE TABLE telefono_entrenador (
    id_telefono INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('movil', 'fijo', 'trabajo', 'otro') DEFAULT 'movil',
    es_principal BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_telefono_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador) ON DELETE CASCADE
);

CREATE TABLE historial_estado_camper (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_estado INT,
    fecha_cambio DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historial_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    CONSTRAINT fk_historial_estado FOREIGN KEY (id_estado) REFERENCES estado_camper(id_estado)
);

CREATE TABLE entrenador_area (
    id_entrenador INT,
    id_area INT,
    PRIMARY KEY (id_entrenador, id_area),
    CONSTRAINT fk_entrenador_area_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT fk_entrenador_area_area FOREIGN KEY (id_area) REFERENCES area_entrenamiento(id_area)
);

CREATE TABLE asignacion_entrenador_ruta (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT,
    id_ruta INT,
    id_horario INT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado ENUM('Activa', 'Finalizada', 'Cancelada') NOT NULL,
    CONSTRAINT fk_asignacion_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT fk_asignacion_ruta FOREIGN KEY (id_ruta) REFERENCES ruta_entrenamiento(id_ruta),
    CONSTRAINT fk_asignacion_horario FOREIGN KEY (id_horario) REFERENCES horario_clase(id_horario)
);

CREATE TABLE asignacion_salon_horario (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_salon INT,
    id_horario INT,
    id_area INT,
    CONSTRAINT fk_asignacion_salon FOREIGN KEY (id_salon) REFERENCES salon(id_salon),
    CONSTRAINT fk_asignacion_horario_clase FOREIGN KEY (id_horario) REFERENCES horario_clase(id_horario),
    CONSTRAINT fk_asignacion_area FOREIGN KEY (id_area) REFERENCES area_entrenamiento(id_area)
);

CREATE TABLE telefono_camper (
    id_telefono INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('movil', 'fijo', 'trabajo', 'otro') DEFAULT 'movil',
    es_principal BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_telefono_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper) ON DELETE CASCADE
);

CREATE TABLE seccion (
    id_seccion INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT,
    nombre_seccion VARCHAR(40) NOT NULL,
    descripcion TEXT,
    fecha DATE,
    hora_inicio TIME,
    duracion DECIMAL(5,2),
    CONSTRAINT fk_seccion_modulo FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
);

CREATE TABLE sesion_clase (
    id_sesion INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT,
    id_horario INT,
    fecha_sesion DATE,
    tema VARCHAR(40),
    CONSTRAINT fk_sesion_modulo FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo),
    CONSTRAINT fk_sesion_horario FOREIGN KEY (id_horario) REFERENCES horario_clase(id_horario)
);

CREATE TABLE asistencia (
    id_asistencia INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_sesion INT,
    fecha_registro DATETIME,
    estado_asistencia ENUM('Presente', 'Ausente', 'Tardanza') DEFAULT 'Ausente',
    hora_llegada TIME NULL,
    justificacion TEXT,
    url_evidencia VARCHAR(130),
    CONSTRAINT fk_asistencia_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    CONSTRAINT fk_asistencia_sesion FOREIGN KEY (id_sesion) REFERENCES sesion_clase(id_sesion)
);

CREATE TABLE grupo_camper_asignacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT NOT NULL,
    id_camper INT NOT NULL,
    fecha_asignacion DATE DEFAULT (CURRENT_DATE),
    CONSTRAINT fk_asignacion_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_campers(id_grupo),
    CONSTRAINT fk_asignacion_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper),
    UNIQUE (id_grupo, id_camper)
);

CREATE TABLE evaluacion (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT,
    id_modulo INT,
    fecha_evaluacion DATE,
    nota_teorica DECIMAL(5,2),
    nota_practica DECIMAL(5,2),
    nota_trabajos_quizzes DECIMAL(5,2),
    nota_final DECIMAL(5,2) AS (nota_teorica * 0.3 + nota_practica * 0.6 + nota_trabajos_quizzes * 0.1) STORED,
    observaciones TEXT,
    CONSTRAINT fk_evaluacion_inscripcion FOREIGN KEY (id_inscripcion) REFERENCES inscripcion(id_inscripcion),
    CONSTRAINT fk_evaluacion_modulo FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo),
    CONSTRAINT chk_nota_teorica CHECK (nota_teorica >= 0 AND nota_teorica <= 100),
    CONSTRAINT chk_nota_practica CHECK (nota_practica >= 0 AND nota_practica <= 100),
    CONSTRAINT chk_nota_quizzes CHECK (nota_trabajos_quizzes >= 0 AND nota_trabajos_quizzes <= 100)
);

CREATE TABLE asignacion_entrenador_grupo (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT NOT NULL,
    id_grupo INT NOT NULL,
    id_area INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    CONSTRAINT fk_asignacion_entrenador_grupo FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT fk_asignacion_grupo_grupo FOREIGN KEY (id_grupo) REFERENCES grupo_campers(id_grupo),
    CONSTRAINT fk_asignacion_grupo_area FOREIGN KEY (id_area) REFERENCES area_entrenamiento(id_area)
);

CREATE TABLE material_educativo (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT,
    titulo VARCHAR(30),
    descripcion TEXT,
    url_material VARCHAR(130),
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_material_modulo FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
);

CREATE TABLE disponibilidad_entrenador (
    id_disponibilidad INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT NOT NULL,
    dia_semana ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo'),
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CONSTRAINT fk_disponibilidad_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT chk_hora_disponibilidad CHECK (hora_fin > hora_inicio)
);

CREATE TABLE ruta_skill (
    id_ruta INT,
    id_skill INT,
    PRIMARY KEY (id_ruta, id_skill),
    CONSTRAINT fk_ruta_skill_ruta FOREIGN KEY (id_ruta) REFERENCES ruta_entrenamiento(id_ruta),
    CONSTRAINT fk_ruta_skill_skill FOREIGN KEY (id_skill) REFERENCES skill(id_skill)
);

CREATE TABLE egresado (
    id_egresado INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    fecha_graduacion DATE,
    promedio_final DECIMAL(5,2) NOT NULL,
    certificado VARCHAR(130),
    comentarios TEXT,
    estado BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_egresado_camper FOREIGN KEY (id_camper) REFERENCES camper(id_camper)
);

CREATE TABLE entrenador_competencia (
    id_entrenador INT,
    id_competencia INT,
    PRIMARY KEY (id_entrenador, id_competencia),
    CONSTRAINT fk_entrenador_competencia_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT fk_entrenador_competencia_competencia FOREIGN KEY (id_competencia) REFERENCES competencia(id_competencia)
);

CREATE TABLE notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    mensaje TEXT,
    fecha_notificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('No leída', 'Leída', 'Archivada') NOT NULL,
    CONSTRAINT fk_notificacion_usuario FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE notificacion_trainer (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT,
    id_ruta INT,
    mensaje TEXT,
    fecha_notificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('No leída', 'Leída', 'Archivada') NOT NULL,
    CONSTRAINT fk_notificacion_entrenador FOREIGN KEY (id_entrenador) REFERENCES entrenador(id_entrenador),
    CONSTRAINT fk_notificacion_ruta FOREIGN KEY (id_ruta) REFERENCES ruta_entrenamiento(id_ruta)
);

