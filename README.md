# PruebaTecnica-DB

Repositorio técnico de base de datos para la prueba supervisada. La entrega parte del archivo `modelo_postgresql.sql`, lo separa por dominios y deja preparada una ruta de despliegue y versionamiento con Docker + Liquibase.

## Alcance de la entrega

- Línea base original preservada en `modelo_postgresql.sql`.
- Separación del DDL por tipo de objeto y por dominio funcional.
- Cambio adicional ADR-001 implementado como nuevo dominio `baggage_incidents`.
- Índices organizados por dominio.
- Datos de prueba y validaciones para un flujo funcional completo.
- Rollbacks manuales para seeds y para eliminación de esquema.
- Contenedorización de PostgreSQL y ejecución de migraciones con Liquibase.

## Estructura principal

- `01_tables/`: DDL base separado por dominio.
- `06_indexes/`: índices por dominio.
- `09_inserts/`: seeds y consultas de validación.
- `11_rollbacks/`: reversión manual controlada.
- `docker/`: `docker-compose.yml` y variables de entorno de ejemplo.
- `liquibase/`: changelog master y changelogs por dominio.

## Hallazgos de la línea base

- Modelo original con **76 tablas**, **59 índices** y **5 comentarios DDL**.
- Uso consistente de UUID como clave primaria y marcas `created_at` / `updated_at`.
- Las carpetas de vistas, funciones, procedimientos, triggers, materialized views y types quedan preparadas para evolución futura, porque la línea base aún no define objetos de esos tipos.

## Dominios identificados en la base entregada

- `Geografía y datos de referencia`: 8 tablas.
- `Aerolínea`: 1 tablas.
- `Identidad`: 6 tablas.
- `Seguridad`: 6 tablas.
- `Clientes y fidelización`: 9 tablas.
- `Aeropuerto`: 5 tablas.
- `Aeronaves`: 9 tablas.
- `Operaciones de vuelo`: 5 tablas.
- `Ventas, reservas y tiquetería`: 12 tablas.
- `Abordaje`: 5 tablas.
- `Pagos`: 5 tablas.
- `Facturación`: 5 tablas.
- `Incidencias de equipaje`: 4 tablas nuevas propuestas como ampliación funcional relacionada.

## Orden sugerido de ejecución de seeds

1. `09_inserts/00_reference_seed.sql`
2. `09_inserts/01_security_seed.sql`
3. `09_inserts/02_operational_seed.sql`
4. `09_inserts/03_commercial_seed.sql`
5. `09_inserts/04_baggage_incident_seed.sql`
6. `09_inserts/99_validation_queries.sql`

## Flujo de despliegue local

```bash
cp docker/.env.example docker/.env
cd docker
docker compose up -d postgres
docker compose run --rm liquibase
```

Posteriormente, cargar los seeds con `psql` o desde una herramienta cliente en el orden indicado.
