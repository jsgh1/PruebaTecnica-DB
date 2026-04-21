# Ejecución local

1. Copie `docker/.env.example` como `docker/.env`.
2. Levante PostgreSQL:
   ```bash
   cd docker
   docker compose up -d postgres
   ```
3. Ejecute las migraciones con Liquibase:
   ```bash
   docker compose --profile migration up liquibase
   ```
4. Para cargar datos de prueba, conéctese al contenedor y ejecute los scripts de `09_inserts/` en el orden documentado.

## Notas
- La imagen de Liquibase se ejecuta bajo demanda usando el perfil `migration`.
- La carpeta `liquibase/` orquesta los change logs y reutiliza los scripts SQL organizados por tipo de objeto.
