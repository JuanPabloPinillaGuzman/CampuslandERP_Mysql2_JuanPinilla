# Sistema de Seguimiento Académico CampusLands

Este proyecto implementa un sistema de gestión académica para el programa intensivo de programación de CampusLands. El sistema permite gestionar inscripciones, rutas de aprendizaje, evaluaciones, reportes y asignaciones de entrenadores y áreas de entrenamiento.

## Estructura de la Base de Datos

El sistema está compuesto por las siguientes tablas principales:

- `campers`: Información de los estudiantes
- `rutas`: Rutas de entrenamiento disponibles
- `modulos`: Módulos de aprendizaje por ruta
- `bases_datos_rutas`: Bases de datos asociadas a cada ruta
- `areas_entrenamiento`: Áreas físicas de entrenamiento
- `trainers`: Información de los entrenadores
- `asignaciones_trainers`: Asignación de trainers a rutas
- `horarios_entrenamiento`: Horarios de clases
- `inscripciones`: Registro de inscripciones de campers
- `evaluaciones`: Registro de evaluaciones por módulo
- `asignaciones_areas`: Asignación de campers a áreas

## Requisitos

- MySQL 8.0 o superior
- Acceso a un servidor MySQL

## Instalación

1. Clonar el repositorio
2. Importar el archivo `schema.sql` para crear la estructura de la base de datos
3. Importar el archivo `datos_ejemplo.sql` para cargar datos de ejemplo

```bash
mysql -u tu_usuario -p < schema.sql
mysql -u tu_usuario -p campuslands_db < datos_ejemplo.sql
```

## Características Principales

- Gestión completa de campers y su información personal
- Control de rutas de aprendizaje y módulos
- Sistema de evaluación con ponderación (teórica 30%, práctica 60%, trabajos 10%)
- Gestión de áreas de entrenamiento con capacidad máxima de 33 campers
- Control de horarios y asignaciones de trainers
- Seguimiento del estado académico de los campers

## Normalización

La base de datos está normalizada hasta la Tercera Forma Normal (3FN) para garantizar la integridad de los datos y evitar redundancias.

## Mantenimiento

Para mantener la base de datos actualizada, se recomienda:

1. Realizar copias de seguridad periódicas
2. Monitorear el rendimiento de las consultas
3. Actualizar los datos de los campers y trainers según sea necesario
4. Mantener un registro de cambios en la estructura de la base de datos