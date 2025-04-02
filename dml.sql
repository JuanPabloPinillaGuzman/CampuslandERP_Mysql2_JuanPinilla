USE campuslands_db;

INSERT INTO campusland (nombre, region, ciudad, direccion) VALUES
('CampusLands', 'Santander', 'Bucaramanga', 'Zona Franca')
('CampusLands', 'Cundinamarca', 'Bogota', 'EAN')
('CampusLands', 'Norte de Santander', 'Cucuta', 'Sede Cucuta')

;


INSERT INTO area_entrenamiento (nombre_area, descripcion, capacidad_maxima) VALUES
('Base de Datos', 'Gestión y administración de bases de datos', 40),
('Desarrollo Móvil', 'Programación de aplicaciones móviles', 40),
('Desarrollo Backend', 'Programación del lado del servidor', 40),
('Desarrollo Frontend', 'Programación de interfaces de usuario', 40);


INSERT INTO salon (nombre_salon, capacidad) VALUES
('Sputnik', 40),
('Apolo', 40),
('Artemis', 40);

INSERT INTO horario_clase (hora_inicio, hora_fin) VALUES
('06:00:00', '09:00:00'),
('10:00:00', '13:00:00'),
('14:00:00', '17:00:00'),
('18:00:00', '21:00:00');


INSERT INTO estado_inscripcion (descripcion, estado_inscripcion) VALUES
('Inscripción en curso', 'Activa'),
('Inscripción finalizada', 'Completada'),
('Inscripción cancelada', 'Cancelada');

INSERT INTO competencia (nombre_competencia, descripcion) VALUES
('Lógica de Programación', 'Capacidad de resolver problemas mediante algoritmos'),
('Diseño Web', 'Habilidades en diseño y desarrollo web'),
('Gestión de Datos', 'Manejo y administración de bases de datos'),
('Arquitectura Backend', 'Diseño de sistemas del lado del servidor');

INSERT INTO estado_camper (descripcion, estado_camper) VALUES
('Iniciando proceso', 'En proceso de ingreso'),
('Inscrito en programa', 'Inscrito'),
('Aprobado para iniciar', 'Aprobado'),
('Actualmente estudiando', 'Cursando'),
('Finalización exitosa', 'Graduado'),
('Expulsión disciplinaria', 'Expulsado'),
('Retiro voluntario', 'Retirado');

INSERT INTO usuario (username, password, rol) VALUES
('admin', '123456789', 'admin'),
('trainer1', '123456789', 'trainer'),
('trainer2', '123456789', 'trainer');

INSERT INTO entrenador (nombres, apellidos, email, especialidad, fecha_ingreso) VALUES
('Johlver', 'Pardo', 'johlver@campuslands.edu.co', 'Desarrollo Backend', '2024-01-01'),
('Miguel', 'Cardenas', 'miguel@campuslands.edu.co', 'Desarrollo Backend', '2024-01-01'),
('Pedro', 'Lopez', 'pedro@campuslands.edu.co', 'Desarrollo Frontend', '2024-01-01');

INSERT INTO ruta_entrenamiento (nombre_ruta, descripcion, duracion_meses, id_sgdb_principal, id_sgdb_alternativo) VALUES
('Java Spring Boot', 'Desarrollo backend con Spring Boot', 6, 1, 3),
('NodeJS', 'Desarrollo backend con Node.js y Express', 6, 1, 2),
('NetCore', 'Desarrollo backend con .NET Core', 6, 1, 3)
;

INSERT INTO sistema_base_datos (nombre_sgdb, descripcion) VALUES
('MySQL', 'Bases de datos relacional'),
('MongoDB', 'Orientada a documentos'),
('PostgreSQL', 'Bases de datos relacional-objeto');

INSERT INTO skill (nombre_skill, descripcion) VALUES
('Fundamentos de Programación', 'Conceptos básicos de programación y lógica'),
('Desarrollo Web', 'Tecnologías y frameworks web'),
('Bases de Datos', 'Diseño y gestión de bases de datos'),
('Backend', 'Desarrollo del lado del servidor'),
('Frontend', 'Desarrollo de interfaces de usuario');

INSERT INTO camper (nombres, apellidos, numero_identificacion, fecha_nacimiento, genero, email, id_campus, id_estado, nivel_riesgo) VALUES
-- Campers Inscritos
('Andrés', 'Ramírez', '1012345670', '1999-11-15', 'M', 'andres.ramirez@email.com', 1, 2, 'Bajo'),
('Sofía', 'Fernández', '1012345671', '2000-08-22', 'F', 'sofia.fernandez@email.com', 1, 2, 'Medio'),
('Diego', 'Castro', '1012345672', '2001-02-10', 'M', 'diego.castro@email.com', 1, 2, 'Alto'),
-- Campers Aprobados
('Valentina', 'Ortiz', '1012345673', '1998-12-05', 'F', 'valentina.ortiz@email.com', 1, 3, 'Bajo'),
('Javier', 'Medina', '1012345674', '2000-06-30', 'M', 'javier.medina@email.com', 1, 3, 'Medio'),
-- Campers Cursando
('Gabriel', 'Morales', '1012345675', '2001-09-18', 'M', 'gabriel.morales@email.com', 1, 4, 'Bajo'),
('Camila', 'Vargas', '1012345676', '1999-03-25', 'F', 'camila.vargas@email.com', 1, 4, 'Alto');


INSERT INTO acudiente (id_camper, nombres, apellidos, telefono, email, parentesco) VALUES
(1, 'Fernando', 'López', '3209876543', 'fernando.lopez@email.com', 'Padre'),
(2, 'Elena', 'Martínez', '3209876544', 'elena.martinez@email.com', 'Madre'),
(3, 'Ricardo', 'Fernández', '3209876545', 'ricardo.fernandez@email.com', 'Padrino');


INSERT INTO direccion (id_camper, calle, ciudad, departamento, codigo_postal, pais) VALUES
(1, 'Calle 45 #23-56', 'Bucaramanga', 'Santander', '680001', 'Colombia'),
(2, 'Carrera 12 #34-78', 'Bucaramanga', 'Santander', '680002', 'Colombia'),
(3, 'Avenida 90 #67-12', 'Bucaramanga', 'Santander', '680003', 'Colombia');


INSERT INTO inscripcion (id_camper, id_ruta, fecha_inscripcion, id_estado_inscripcion) VALUES
(1, 1, '2024-01-15', 1),
(2, 1, '2024-01-15', 1),
(3, 2, '2024-01-20', 1),
(4, 2, '2024-01-20', 1),
(5, 3, '2024-01-25', 1),
(6, 3, '2024-01-25', 1);

INSERT INTO modulo (id_skill, nombre_modulo, descripcion, duracion_horas, orden) VALUES
(1, 'Introducción a JavaScript', 'Fundamentos del lenguaje', 40, 1),
(1, 'ES6+ Features', 'Características modernas de JS', 30, 2),
(2, 'Node.js Basics', 'Fundamentos de Node.js', 40, 3),
(2, 'Async Programming', 'Programación asíncrona', 30, 4),
(3, 'Express Basics', 'Fundamentos de Express', 40, 5),
(3, 'REST APIs', 'Desarrollo de APIs REST', 30, 6);

INSERT INTO grupo_campers (nombre_grupo, id_ruta) VALUES
('Artemis 2024-1', 1),
('Apolo 2024-1', 2),
('Sputnik 2024-1', 3);

INSERT INTO telefono_camper (id_camper, numero, tipo, es_principal) VALUES
(1, '3159876543', 'movil', TRUE),
(1, '3159876544', 'fijo', FALSE),
(2, '3159876545', 'movil', TRUE),
(2, '3159876546', 'trabajo', FALSE),
(3, '3159876547', 'movil', TRUE);


INSERT INTO telefono_entrenador (id_entrenador, numero, tipo, es_principal) VALUES
(1, '3148765432', 'movil', TRUE),
(2, '3148765433', 'movil', TRUE),
(3, '3148765434', 'movil', TRUE);


INSERT INTO historial_estado_camper (id_camper, id_estado) VALUES
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(2, 1),
(2, 2),
(2, 3),
(2, 4);

INSERT INTO entrenador_area (id_entrenador, id_area) VALUES
(1, 1),
(2, 1),
(3, 2);

INSERT INTO asignacion_entrenador_ruta (id_entrenador, id_ruta, id_horario, fecha_inicio, estado) VALUES
(1, 1, 1, '2024-01-16', 'Activa'),
(2, 2, 2, '2024-01-21', 'Activa'),
(3, 3, 3, '2024-01-26', 'Activa');

INSERT INTO asignacion_salon_horario (id_salon, id_horario, id_area) VALUES
(1, 1, 1),
(2, 2, 1),
(3, 3, 2);

INSERT INTO evaluacion (id_inscripcion, id_modulo, fecha_evaluacion, nota_teorica, nota_practica, nota_trabajos_quizzes) VALUES
(1, 1, '2024-02-01', 85, 78, 90),
(2, 1, '2024-02-01', 55, 45, 60),
(3, 3, '2024-02-01', 90, 88, 95),
(4, 3, '2024-02-01', 50, 55, 45);

INSERT INTO seccion (id_modulo, nombre_seccion, descripcion, fecha, hora_inicio, duracion) VALUES
(1, 'Variables y Tipos', 'Introducción a variables y tipos de datos', '2024-02-01', '06:00:00', 2.0),
(1, 'Estructuras de Control', 'Estructuras de control en JavaScript', '2024-02-02', '06:00:00', 2.0),
(2, 'Arrow Functions', 'Funciones flecha y destructuring', '2024-02-15', '10:00:00', 2.0);

INSERT INTO material_educativo (id_modulo, titulo, descripcion, url_material) VALUES
(1, 'Introducción a JavaScript', 'Fundamentos básicos de JS', 'https://example.com/js-basics'),
(2, 'ES6+ Features', 'Características modernas de JS', 'https://example.com/es6-features'),
(3, 'Express.js Fundamentals', 'Conceptos básicos de Express', 'https://example.com/express-basics');

INSERT INTO sesion_clase (id_modulo, id_horario, fecha_sesion, tema) VALUES
(1, 1, '2024-02-01', 'Variables y tipos de datos en JS'),
(1, 1, '2024-02-02', 'Estructuras de control'),
(2, 2, '2024-02-15', 'Arrow functions y destructuring');

INSERT INTO asistencia (id_camper, id_sesion, fecha_registro, estado_asistencia, hora_llegada) VALUES
(1, 1, '2024-02-01 06:00:00', 'Presente', '06:00:00'),
(2, 1, '2024-02-01 06:15:00', 'Tardanza', '06:15:00'),
(3, 2, '2024-02-02 06:00:00', 'Presente', '06:00:00');

INSERT INTO grupo_camper_asignacion (id_grupo, id_camper) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6);

INSERT INTO asignacion_entrenador_grupo (id_entrenador, id_grupo, id_area, fecha_inicio) VALUES
(1, 1, 1, '2024-01-16'),
(2, 2, 1, '2024-01-16'),
(3, 3, 2, '2024-01-16');

INSERT INTO disponibilidad_entrenador (id_entrenador, dia_semana, hora_inicio, hora_fin) VALUES
(1, 'Lunes', '06:00:00', '14:00:00'),
(1, 'Martes', '06:00:00', '14:00:00'),
(1, 'Miercoles', '06:00:00', '14:00:00'),
(1, 'Jueves', '06:00:00', '14:00:00'),
(1, 'Viernes', '06:00:00', '14:00:00');

INSERT INTO ruta_skill (id_ruta, id_skill) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5);

INSERT INTO egresado (id_camper, fecha_graduacion, promedio_final, certificado) VALUES
(7, '2023-12-15', 85.5, 'CERT-2023-001');

INSERT INTO entrenador_competencia (id_entrenador, id_competencia) VALUES
(1, 1),
(1, 2),
(2, 1),
(2, 4),
(3, 2);