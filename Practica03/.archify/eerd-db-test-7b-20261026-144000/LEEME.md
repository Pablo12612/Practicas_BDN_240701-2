# Visualizador EERD de db_test_7b

Abre visualizador-eerd.html en un navegador moderno. Es autónomo y no requiere servidor ni dependencias.

## Regenerar

    node tools/generate-eerd.cjs db_test_7b.sql .archify/eerd-db-test-7b

El generador también crea modelo.json y candidate.erd.json, compatible con Archify. Para renderizar la vista ERD nativa, desde la raíz ejecuta:

    node "C:\Users\pmgjk\.agents\skills\archify\bin\archify.mjs" finalize erd .archify/eerd-db-test-7b/candidate.erd.json .archify/eerd-db-test-7b/modelo-er.html --quality standard --json
