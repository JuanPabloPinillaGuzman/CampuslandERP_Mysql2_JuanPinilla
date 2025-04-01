USE campuslands_db;

-- Insertar Rutas de Entrenamiento
INSERT INTO rutas (nombre, descripcion) VALUES
('Fundamentos de Programación', 'Ruta básica de programación con PSeInt y Python'),
('Programación Web', 'Desarrollo web con HTML, CSS y Bootstrap'),
('Programación Formal', 'Programación avanzada con Java, JavaScript y C#'),
('Bases de Datos', 'Gestión de bases de datos con MySQL, MongoDB y PostgreSQL'),
('Backend Development', 'Desarrollo backend con NetCore, Spring Boot y NodeJS');

-- Insertar Módulos
INSERT INTO modulos (ruta_id, nombre, descripcion, orden) VALUES
(1, 'Introducción a la Algoritmia', 'Conceptos básicos de programación', 1),
(1, 'PSeInt', 'Programación estructurada con PSeInt', 2),
(1, 'Python Básico', 'Fundamentos de Python', 3),
(2, 'HTML5', 'Estructura y semántica web', 1),
(2, 'CSS3', 'Estilos y diseño web', 2),
(2, 'Bootstrap', 'Framework CSS', 3),
(3, 'Java', 'Programación orientada a objetos con Java', 1),
(3, 'JavaScript', 'Programación web con JavaScript', 2),
(3, 'C#', 'Desarrollo con C#', 3);

-- Insertar Bases de Datos por Ruta
INSERT INTO bases_datos_rutas (ruta_id, nombre_sgdb, tipo) VALUES
(4, 'MySQL', 'Principal'),
(4, 'PostgreSQL', 'Alternativo'),
(4, 'MongoDB', 'Alternativo');

-- Insertar Áreas de Entrenamiento
INSERT INTO areas_entrenamiento (nombre, capacidad_maxima) VALUES
('Área 1', 33),
('Área 2', 33),
('Área 3', 33),
('Área 4', 33);

-- Insertar Trainers
INSERT INTO trainers (identificacion, nombres, apellidos, especialidad) VALUES
('T001', 'Juan', 'Pérez', 'Fundamentos de Programación'),
('T002', 'María', 'García', 'Programación Web'),
('T003', 'Carlos', 'López', 'Programación Formal'),
('T004', 'Ana', 'Martínez', 'Bases de Datos'),
('T005', 'Pedro', 'Sánchez', 'Backend Development');

-- Insertar Campers
INSERT INTO campers (identificacion, nombres, apellidos, direccion, acudiente, telefono_contacto, estado, nivel_riesgo) VALUES
('C001', 'Luis', 'Ramírez', 'Calle 123 #45-67', 'María Ramírez', '3001234567', 'Inscrito', 'Bajo'),
('C002', 'Sofia', 'González', 'Avenida 89 #12-34', 'Carlos González', '3109876543', 'Cursando', 'Medio'),
('C003', 'Diego', 'Martínez', 'Carrera 56 #78-90', 'Ana Martínez', '3204567890', 'Aprobado', 'Bajo'),
('C004', 'Laura', 'Rodríguez', 'Diagonal 23 #45-67', 'Pedro Rodríguez', '3301234567', 'En proceso de ingreso', 'Alto'),
('C005', 'Andrés', 'López', 'Transversal 12 #34-56', 'Sofia López', '3409876543', 'Cursando', 'Medio');

-- Insertar Asignaciones de Trainers a Rutas
INSERT INTO asignaciones_trainers (trainer_id, ruta_id, fecha_inicio) VALUES
(1, 1, '2024-01-01'),
(2, 2, '2024-01-01'),
(3, 3, '2024-01-01'),
(4, 4, '2024-01-01'),
(5, 5, '2024-01-01');

-- Insertar Horarios de Entrenamiento
INSERT INTO horarios_entrenamiento (area_id, trainer_id, ruta_id, dia_semana, hora_inicio, hora_fin) VALUES
(1, 1, 1, 'Lunes', '08:00:00', '12:00:00'),
(2, 2, 2, 'Martes', '08:00:00', '12:00:00'),
(3, 3, 3, 'Miércoles', '08:00:00', '12:00:00'),
(4, 4, 4, 'Jueves', '08:00:00', '12:00:00'),
(1, 5, 5, 'Viernes', '08:00:00', '12:00:00');

-- Insertar Inscripciones
INSERT INTO inscripciones (camper_id, ruta_id, fecha_inscripcion, estado) VALUES
(1, 1, '2024-01-15', 'Activa'),
(2, 2, '2024-01-15', 'Activa'),
(3, 3, '2024-01-15', 'Activa'),
(4, 4, '2024-01-15', 'Activa'),
(5, 5, '2024-01-15', 'Activa');

-- Insertar Evaluaciones
INSERT INTO evaluaciones (inscripcion_id, modulo_id, nota_teorica, nota_practica, nota_trabajos, nota_final, fecha_evaluacion) VALUES
(1, 1, 85.00, 90.00, 95.00, 89.00, '2024-02-01'),
(2, 4, 75.00, 80.00, 85.00, 79.00, '2024-02-01'),
(3, 7, 90.00, 85.00, 95.00, 88.00, '2024-02-01'),
(4, 4, 70.00, 75.00, 80.00, 74.00, '2024-02-01'),
(5, 1, 95.00, 90.00, 100.00, 94.00, '2024-02-01');

-- Insertar Asignaciones de Campers a Áreas
INSERT INTO asignaciones_areas (camper_id, area_id, fecha_asignacion) VALUES
(1, 1, '2024-01-15'),
(2, 2, '2024-01-15'),
(3, 3, '2024-01-15'),
(4, 4, '2024-01-15'),
(5, 1, '2024-01-15'); 