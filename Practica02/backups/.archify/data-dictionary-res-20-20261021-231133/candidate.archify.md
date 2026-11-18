# Diccionario de datos de RES 20 {#res20-dictionary}

El respaldo contiene 13 tablas y 20,228 registros. El diccionario interactivo adjunto conserva los nombres técnicos, explica cada campo en lenguaje cotidiano y permite buscar o desplegar cada tabla.

- Las explicaciones se infieren de los nombres, tipos, llaves y relaciones del respaldo.
- Cada conteo se calcula desde las sentencias `INSERT` del archivo.
- Las relaciones declaradas conectan personas, productos, compras, pagos y auditoría.

@answer scope="RES 20.sql · respaldo analizado · explicaciones inferidas"
@meta locale=es style=product

## ¿Qué grupos de información guarda el sistema? {#scope}

@facts id=summary
| Tablas | 13 |
| Registros | 20,228 |
| Relaciones declaradas | 16 |

| Grupo | Tablas principales | Explicación sencilla |
| --- | --- | --- |
| Personas | `tb_users`, pagos y lista de deseos | Quién usa el sistema y sus preferencias. |
| Catálogo | `tb_products`, categorías y proveedores | Qué productos se ofrecen y cómo se clasifican. |
| Compra | carritos, órdenes y partidas | Qué desea o compra una persona. |
| Control | `tb_logs` | Qué cambio ocurrió y cuándo. |

## ¿Cómo se conectan las partes clave? {#connections}

| Tabla y campo | Se conecta con | Explicación sencilla |
| --- | --- | --- |
| `tb_carts.user_ID` | `tb_users.ID` | Cada carrito pertenece a una persona usuaria. |
| `tb_buyer_orders.seller_ID` | `tb_users.ID` | Cada orden señala al usuario vendedor. |
| `tbd_user_payment_methods.user_ID` | `tb_users.ID` | Cada método guardado tiene una persona titular. |
| `tbd_users_wishlist_products.product_ID` | `tb_products.ID` | Cada favorito apunta a un producto del catálogo. |

## ¿Cómo usar el diccionario? {#use}

@steps id=use-steps
| search | Buscar | Escriba un nombre técnico o una palabra cotidiana para encontrar una tabla o campo. |
| expand | Abrir tabla | Abra una tarjeta para ver tipos SQL, significado, obligatoriedad y llaves. |
| connect | Revisar conexiones | Consulte las relaciones para entender qué registro referencia a cuál. |
