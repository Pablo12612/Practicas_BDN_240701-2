# Visualizador EERD para `db_test_7b.sql`

El artefacto Archify interactivo está en `.archify/erd-db-test-7b-20261015-131200/eerd-db-test-7b.html`. `candidate.json` contiene el modelo tipado y `build-eerd.mjs` vuelve a analizar un respaldo MySQL y reconstruye ese candidato.

## Regenerar

Requiere Node.js 18 o posterior y el CLI Archify disponible en esta instalación. En PowerShell:

```powershell
$env:ARCHIFY_CLI = "C:\ruta\a\archify\bin\archify.mjs"
node .\build-eerd.mjs .\db_test_7b.sql .\.archify\erd-db-test-7b-20261015-131200 --render
```

`ARCHIFY_CLI` es opcional cuando `build-eerd.mjs` ya apunta al CLI de Archify instalado en este equipo. Sin `--render`, el programa solo extrae tablas, columnas, claves y conteos, y escribe `candidate.json`. Los valores contados son filas en sentencias `INSERT INTO` del respaldo; no consultan una base de datos activa.

## Uso en Archify

Abre `candidate.json` como entrada del renderizador Archify ERD. El HTML entregado incluye el visor nativo con tema oscuro, zoom y movimiento del lienzo, Finder de entidades, vistas guiadas, enfoque semántico, leyenda interactiva y exportación. La posición de los nodos queda definida en el candidato JSON; el renderer ERD no aporta controles para arrastrar o colapsar entidades.

Los tipos y nulabilidad aparecen en las filas de atributos; los roles PK/FK/UNIQUE llevan insignias. `AUTO_INCREMENT`, `DEFAULT` y `ON UPDATE` se listan en tarjetas de detalle. Las seis relaciones entre tablas se dibujan con pata de gallo. La FK recursiva de categorías se explica en una tarjeta, ya que el renderer EERD no admite autorrelaciones.

## Alcance de la extracción

El analizador cubre definiciones MySQL `CREATE TABLE`, claves primarias, claves únicas, claves foráneas, columnas y filas insertadas. El respaldo no declara `CHECK`. `tb_logs.table_name` es texto auditado, no una FK. El contador del encabezado se añadió al título de la entidad porque el renderer Archify ERD conserva `sublabel` solo como dato accesible y no lo dibuja.
