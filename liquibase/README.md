# Estrategia Liquibase

- `changelog-master.xml` centraliza el orden de aplicación.
- Cada changelog agrupa un único dominio funcional.
- Los cambios consumen los scripts SQL del repositorio (`01_tables/` y `06_indexes/`) para evitar duplicar la fuente de verdad.
- Los datos de prueba no forman parte de la línea base productiva; se ejecutan desde `09_inserts/` según el plan documentado.
