# Diccionario de datos de db_test_7b {#diccionario-datos}

El diccionario interactivo traduce el respaldo de MySQL a lenguaje de negocio sin ocultar los nombres ni tipos técnicos originales.

- Cada tabla conserva su nombre exacto y añade una explicación cotidiana.
- Cada campo muestra tipo SQL, categoría visual, obligación y rol de llave.
- Los conteos se obtienen del respaldo más reciente disponible: `Dump20261022.sql`.
- Las relaciones se explican como conexiones entre registros, no como jerga de base de datos.

@answer scope="Esquema db_test_7b.sql · datos Dump20261022.sql · 16 tablas"
@meta locale=es style=product

## ¿Qué muestra la interfaz? {#contenido}

@facts id=alcance
| Tablas | 16 tablas con nombre técnico y propósito de negocio |
| Campos | 122 campos con tipo SQL y explicación inferida |
| Registros | 20,228 registros contados en el respaldo disponible |
| Relaciones | Referencias entre tablas explicadas en lenguaje cotidiano |

## ¿Cómo recorre una persona el diccionario? {#recorrido}

@steps id=pasos-consulta
| paso-buscar | Buscar un término | Escriba una tabla, un campo o una idea de negocio. |
| paso-tabla | Elegir una tabla | Abra la tarjeta que coincide con el resultado. |
| paso-campos | Revisar los campos | Compare nombre técnico, tipo y explicación. |
| paso-conexiones | Entender conexiones | Lea qué registro se relaciona con cuál y para qué. |

## ¿Cómo se vuelve a generar? {#regeneracion}

El archivo `tools/generate-data-dictionary.cjs` lee el esquema y los datos. Al ejecutar el generador con una ruta HTML, recalcula las tablas, los campos, las llaves, las relaciones y los conteos antes de crear una nueva versión.

```powershell title="Generar una versión actualizada"
node tools/generate-data-dictionary.cjs .archify/diccionario-actualizado/diccionario-datos.html
```
