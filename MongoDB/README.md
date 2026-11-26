# Migracion de SolarPulseIoT a MongoDB

Este apartado documenta la migracion de la base de datos relacional
`SolarPulseIoT` desde SQL Server hacia MongoDB.

La base de datos documental final conserva la informacion de origen mediante
14 colecciones. Las 25 colecciones temporales `stg_*` representan la etapa
intermedia de importacion y pueden conservarse para revisar o repetir la
transformacion.

## Informacion del proceso

- Base de datos de origen: SQL Server `SolarPulseIoT`
- Base de datos de destino: MongoDB `SolarPulseIoT`
- Conexion local documentada: `mongodb://localhost:27017`
- Herramienta de administracion: MongoDB Compass
- Formato de intercambio: CSV
- Colecciones temporales: 25
- Colecciones finales: 14
- Fecha de documentacion: 20 de noviembre de 2026

## Patrones de modelado NoSQL

Para la transformación de la base de datos SolarPulseIoT se aplicaron cuatro patrones de modelado documental:

- **Embedding:** incorporación de información relacionada directamente dentro de los documentos principales, como permisos, roles, paneles y sensores.
- **Referencing:** utilización de identificadores para relacionar documentos almacenados en diferentes colecciones.
- **Extended Reference:** almacenamiento de información descriptiva relacionada dentro del documento principal, evitando consultas adicionales para recuperar datos frecuentes.
- **Subset:** incorporación de un subconjunto limitado de información, como las cinco alertas más recientes de cada instalación.

Estos patrones permiten adaptar la estructura documental a las necesidades de consulta y operación del sistema.

## Colecciones finales

| Coleccion | Contenido principal |
|---|---|
| `roles` | Roles y permisos embebidos |
| `usuarios` | Usuarios, rol, cliente asociado y perfil tecnico |
| `clientes` | Datos generales y fiscales de clientes |
| `tarifas` | Tarifas electricas y distribuidora embebida |
| `factores_emision` | Factores de emision por red |
| `modelos_panel` | Marcas, modelos y potencia nominal |
| `repuestos` | Repuestos, stock y costo unitario |
| `instalaciones` | Instalacion, ubicacion GeoJSON, cliente, tarifa, factor de emision, paneles, sensores y alertas recientes |
| `mediciones` | Mediciones agrupadas por sensor y hora |
| `consumos_energia` | Consumos agrupados por instalacion y dia |
| `anomalias` | Anomalia y referencias a sensor, panel e instalacion |
| `alertas` | Alerta e informacion extendida de anomalia e instalacion |
| `incidencias` | Incidencia, alerta relacionada y referencias de anomalia e instalacion |
| `ordenes_mantenimiento` | Orden, tecnico, actividades, presupuesto y costo |

## Colecciones temporales

Los datos exportados desde SQL Server se importaron en 25 colecciones con el
prefijo `stg_`:

- `stg_Cliente`
- `stg_Rol`
- `stg_Permiso`
- `stg_Rol_Permiso`
- `stg_Usuario`
- `stg_Tecnico`
- `stg_Especialidad`
- `stg_Tecnico_Especialidad`
- `stg_Distribuidora`
- `stg_Tarifa_electrica`
- `stg_Factor_emision`
- `stg_Instalacion`
- `stg_Modelo_panel`
- `stg_Panel_Solar`
- `stg_Sensor_iot`
- `stg_Medicion`
- `stg_Consumo_energia`
- `stg_Anomalia`
- `stg_Alerta`
- `stg_Incidencia`
- `stg_Orden_mantenimiento`
- `stg_Actividad_mantenimiento`
- `stg_Costo_mantenimiento`
- `stg_Repuesto`
- `stg_Detalle_presupuesto`

Estas colecciones no deben utilizarse como modelo definitivo del diagrama.

## Script de transformacion

El script [02_transformar_SolarPulseIoT_MongoDB.js](03_Scripts_MongoDB/02_transformar_SolarPulseIoT_MongoDB.js)
construye las colecciones finales mediante agregaciones con `$lookup`,
`$unwind`, `$group`, `$project` y `$merge`.

Antes de ejecutarlo:

1. Importar los CSV en MongoDB como las 25 colecciones `stg_*`.
2. Importar los identificadores y campos numericos como tipos numericos.
3. Ejecutar el script dentro de la base de datos `SolarPulseIoT`.
4. Revisar las cantidades y las relaciones antes de eliminar las colecciones
   temporales.

## Script de validacion

El script [03_validar_SolarPulseIoT_MongoDB.js](03_Scripts_MongoDB/03_validar_SolarPulseIoT_MongoDB.js)
comprueba:

- La cantidad de documentos finales.
- Usuarios sin rol embebido.
- Instalaciones sin cliente embebido.
- Paneles sin modelo dentro de instalaciones.
- Anomalias sin `instalacion_id`.
- Alertas sin anomalia embebida.
- Incidencias sin `instalacion_id`.
- Ejemplos de documentos finales.

## Resultados documentados

Los resultados registrados durante la validacion fueron:

| Coleccion | Documentos |
|---|---:|
| `roles` | 3 |
| `usuarios` | 4 |
| `clientes` | 3 |
| `tarifas` | 2 |
| `factores_emision` | 1 |
| `modelos_panel` | 2 |
| `repuestos` | 2 |
| `instalaciones` | 2 |
| `mediciones` | 3 |
| `consumos_energia` | 2 |
| `anomalias` | 4 |
| `alertas` | 4 |
| `incidencias` | 4 |
| `ordenes_mantenimiento` | 1 |
| **Total** | **37** |

Las seis comprobaciones de referencias devolvieron cero registros con errores.

### Mediciones y consumos

- Mediciones originales: 6.
- Lecturas migradas: 6.
- Errores encontrados: 0.
- Consumos originales: 3.
- Registros migrados: 3.
- Errores encontrados: 0.

Las mediciones se agrupan por sensor y hora. Los consumos se agrupan por
instalacion y dia. El resumen almacenado incluye promedios, totales y cantidad
de registros.

## Diagrama

- Imagen del modelo documental:
  [Diagrama_SolarPulseIoT.png](04_Diagrama/Diagrama_SolarPulseIoT.png)
- Archivo editable:
  [Diagrama_SolarPulseIoT.mdm](04_Diagrama/Diagrama_SolarPulseIoT.mdm)

El diagrama debe representar las 14 colecciones finales, sus campos, documentos
embebidos y relaciones por identificador.

## Estructura del directorio

```text
MongoDB/
├── 01_Documentacion/
├── 02_Scripts_SQL/
├── 03_Scripts_MongoDB/
├── 04_Diagrama/
└── 05_Evidencias/
```

## Archivos principales

- [01_exportar_SolarPulseIoT_CSV.sql](02_Scripts_SQL/01_exportar_SolarPulseIoT_CSV.sql):
  exportacion de las 25 tablas SQL Server.
- [02_transformar_SolarPulseIoT_MongoDB.js](03_Scripts_MongoDB/02_transformar_SolarPulseIoT_MongoDB.js):
  construccion de las 14 colecciones finales.
- [03_validar_SolarPulseIoT_MongoDB.js](03_Scripts_MongoDB/03_validar_SolarPulseIoT_MongoDB.js):
  validacion de conteos y referencias.
- [04_reporte_patrones_nosql.js](05_Evidencias/04_reporte_patrones_nosql.js): 
  validacion de patrones de modelado implementados.
- [GUÍA TÉCNICA DE MIGRACIÓN Y MODELADO NoSQL.txt](01_Documentacion/GUÍA%20TÉCNICA%20DE%20MIGRACIÓN%20Y%20MODELADO%20NoSQL.txt):
  procedimiento detallado de migracion y modelado.