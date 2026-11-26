/* =====================================================================
   SOLARPULSEIOT - EXPORTACION DE LAS 25 TABLAS A CSV
   Origen: SQL Server / Base de datos SolarPulseIoT
   Destino: importar cada resultado como una coleccion temporal stg_*

   INSTRUCCIONES:
   1. Ejecutar cada SELECT por separado en SSMS.
   2. Guardar cada resultado con el nombre CSV indicado.
   3. Exportar en UTF-8 (Code Page 65001), delimitador coma y
      calificador de texto comillas dobles.
   4. No eliminar las columnas id_*: se necesitan para reconstruir
      las relaciones en MongoDB.
   5. Los campos fecha se convierten a ISO 8601 para facilitar la
      importacion y conversion posterior a Date en MongoDB.
   ===================================================================== */
USE SolarPulseIoT;
GO

/* 01. clientes.csv -> stg_Cliente */
SELECT id_cliente, razon_social, tipo_documento, nro_documento,
       direccion_fiscal, telefono_contacto, email_contacto
FROM dbo.Cliente
ORDER BY id_cliente;
GO

/* 02. roles.csv -> stg_Rol */
SELECT id_rol, nombre_rol, descripcion
FROM dbo.Rol
ORDER BY id_rol;
GO

/* 03. permisos.csv -> stg_Permiso */
SELECT id_permiso, codigo, descripcion
FROM dbo.Permiso
ORDER BY id_permiso;
GO

/* 04. rol_permiso.csv -> stg_Rol_Permiso */
SELECT id_rol, id_permiso
FROM dbo.Rol_Permiso
ORDER BY id_rol, id_permiso;
GO

/* 05. usuarios.csv -> stg_Usuario */
SELECT id_usuario, nombre_completo, email, password_hash, telefono,
       estado, intentos_fallidos, id_rol, id_cliente
FROM dbo.Usuario
ORDER BY id_usuario;
GO

/* 06. tecnicos.csv -> stg_Tecnico */
SELECT id_tecnico, codigo_empleado, disponibilidad,
       calificacion_promedio, id_usuario
FROM dbo.Tecnico
ORDER BY id_tecnico;
GO

/* 07. especialidades.csv -> stg_Especialidad */
SELECT id_especialidad, nombre
FROM dbo.Especialidad
ORDER BY id_especialidad;
GO

/* 08. tecnico_especialidad.csv -> stg_Tecnico_Especialidad */
SELECT id_tecnico, id_especialidad
FROM dbo.Tecnico_Especialidad
ORDER BY id_tecnico, id_especialidad;
GO

/* 09. distribuidoras.csv -> stg_Distribuidora */
SELECT id_distribuidora, nombre
FROM dbo.Distribuidora
ORDER BY id_distribuidora;
GO

/* 10. tarifas.csv -> stg_Tarifa_electrica */
SELECT id_tarifa, tipo_tarifa, costo_kwh, CONVERT(nvarchar(3), moneda) AS moneda, id_distribuidora
FROM dbo.Tarifa_electrica
ORDER BY id_tarifa;
GO

/* 11. factores_emision.csv -> stg_Factor_emision */
SELECT id_factor_emision, nombre_red, kg_co2_kwh, anio_vigencia
FROM dbo.Factor_emision
ORDER BY id_factor_emision;
GO

/* 12. instalaciones.csv -> stg_Instalacion */
SELECT id_instalacion, nombre, ubicacion_lat, ubicacion_long, direccion,
       capacidad_nominal_kw,
       CONVERT(nvarchar(10), fecha_puesta_marcha, 23) AS fecha_puesta_marcha,
       estado_operativo, id_cliente, id_tarifa, potencia_contratada_kw,
       id_factor_emision
FROM dbo.Instalacion
ORDER BY id_instalacion;
GO

/* 13. modelos_panel.csv -> stg_Modelo_panel */
SELECT id_modelo_panel, marca, modelo, potencia_nominal_w
FROM dbo.Modelo_panel
ORDER BY id_modelo_panel;
GO

/* 14. paneles_solares.csv -> stg_Panel_Solar */
SELECT id_panel_solar, codigo_serie, angulo_inclinacion, orientacion,
       estado, id_instalacion, id_modelo_panel
FROM dbo.Panel_Solar
ORDER BY id_panel_solar;
GO

/* 15. sensores_iot.csv -> stg_Sensor_iot */
SELECT id_sensor_iot, identificador_hardware, mac_address, tipo_sensor,
       frecuencia_muestreo_seg, estado_conexion, id_panel_solar
FROM dbo.Sensor_iot
ORDER BY id_sensor_iot;
GO

/* 16. mediciones.csv -> stg_Medicion */
SELECT id_medicion,
       CONVERT(nvarchar(23), timestamp_registro, 126) AS timestamp_registro,
       voltaje_v, corriente_a, temperatura_celda_c, irradiancia_w_m2,
       id_sensor_iot
FROM dbo.Medicion
ORDER BY id_medicion;
GO

/* 17. consumos_energia.csv -> stg_Consumo_energia */
SELECT id_consumo,
       CONVERT(nvarchar(19), fecha_hora, 126) AS fecha_hora,
       intervalo_min, energia_consumida_kwh, id_instalacion
FROM dbo.Consumo_energia
ORDER BY id_consumo;
GO

/* 18. anomalias.csv -> stg_Anomalia */
SELECT id_anomalia,
       CONVERT(nvarchar(19), fecha_deteccion, 126) AS fecha_deteccion,
       tipo_anomalia, valor_esperado, valor_leido, severidad, id_sensor_iot
FROM dbo.Anomalia
ORDER BY id_anomalia;
GO

/* 19. alertas.csv -> stg_Alerta */
SELECT id_alerta,
       CONVERT(nvarchar(19), fecha_generacion, 126) AS fecha_generacion,
       mensaje, recomendacion, canal_envio, estado, id_anomalia
FROM dbo.Alerta
ORDER BY id_alerta;
GO

/* 20. incidencias.csv -> stg_Incidencia */
SELECT id_incidencia, titulo, descripcion_detallada, prioridad, estado,
       CONVERT(nvarchar(19), fecha_apertura, 126) AS fecha_apertura,
       CASE WHEN fecha_cierre IS NULL THEN NULL
            ELSE CONVERT(nvarchar(19), fecha_cierre, 126) END AS fecha_cierre,
       tiempo_inactivo_min, perdida_estimada_pen, id_alerta
FROM dbo.Incidencia
ORDER BY id_incidencia;
GO

/* 21. ordenes_mantenimiento.csv -> stg_Orden_mantenimiento */
SELECT id_orden_manten, tipo_mantenimiento,
       CONVERT(nvarchar(10), fecha_programada, 23) AS fecha_programada,
       CASE WHEN fecha_ejecucion IS NULL THEN NULL
            ELSE CONVERT(nvarchar(10), fecha_ejecucion, 23) END AS fecha_ejecucion,
       estado, id_incidencia, id_tecnico
FROM dbo.Orden_mantenimiento
ORDER BY id_orden_manten;
GO

/* 22. actividades_mantenimiento.csv -> stg_Actividad_mantenimiento */
SELECT id_actividad_manten, descripcion_tarea, tiempo_estimado_min,
       tiempo_real_min, resultado, observaciones, id_orden_manten, id_tecnico
FROM dbo.Actividad_mantenimiento
ORDER BY id_actividad_manten;
GO

/* 23. costos_mantenimiento.csv -> stg_Costo_mantenimiento */
SELECT id_costo_manten, costo_mano_obra, costo_materiales_repuestos,
       costo_adicional_viaticos, CONVERT(nvarchar(3), moneda) AS moneda,
       CONVERT(nvarchar(19), fecha_registro_costo, 126) AS fecha_registro_costo,
       id_orden_manten
FROM dbo.Costo_mantenimiento
ORDER BY id_costo_manten;
GO

/* 24. repuestos.csv -> stg_Repuesto */
SELECT id_repuesto, codigo_sku, nombre, stock_actual, costo_unitario_estandar
FROM dbo.Repuesto
ORDER BY id_repuesto;
GO

/* 25. detalles_presupuesto.csv -> stg_Detalle_presupuesto */
SELECT id_detalle_presupuesto, cantidad, precio_unitario,
       id_orden_manten, id_repuesto
FROM dbo.Detalle_presupuesto
ORDER BY id_detalle_presupuesto;
GO
