
CREATE TABLE Actividad_mantenimiento
(
  id_actividad_manten INT           NOT NULL IDENTITY(1,1),
  descripcion_tarea   NVARCHAR(500) NOT NULL,
  tiempo_estimado_min INT           NOT NULL,
  tiempo_real_min     INT          ,
  resultado           VARCHAR(30)  ,
  observaciones       NVARCHAR(500),
  id_orden_manten     INT           NOT NULL,
  id_tecnico          INT           NOT NULL,
  CONSTRAINT PK_Actividad_mantenimiento PRIMARY KEY (id_actividad_manten)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Actividad_mantenimiento', 'column', 'id_actividad_manten'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Exitosa | Incompleta | Requiere segunda visita', 'schema', 'dbo', 'table', 'Actividad_mantenimiento', 'column', 'resultado'
GO

CREATE TABLE Alerta
(
  id_alerta        INT           NOT NULL IDENTITY(1,1),
  fecha_generacion DATETIME2(0)  NOT NULL,
  mensaje          NVARCHAR(500) NOT NULL,
  recomendacion    NVARCHAR(300),
  canal_envio      VARCHAR(20)   NOT NULL,
  estado           VARCHAR(20)   NOT NULL DEFAULT 'No leida',
  id_anomalia      INT           NOT NULL,
  CONSTRAINT PK_Alerta PRIMARY KEY (id_alerta)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Lenguaje no técnico', 'schema', 'dbo', 'table', 'Alerta', 'column', 'mensaje'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'SMS | Correo | Webhook | Push | WhatsApp', 'schema', 'dbo', 'table', 'Alerta', 'column', 'canal_envio'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'No leida | Atendida | Silenciada', 'schema', 'dbo', 'table', 'Alerta', 'column', 'estado'
GO

CREATE TABLE Anomalia
(
  id_anomalia     INT           NOT NULL IDENTITY(1,1),
  fecha_deteccion DATETIME2(0)  NOT NULL,
  tipo_anomalia   VARCHAR(40)   NOT NULL,
  valor_esperado  DECIMAL(10,3) NOT NULL,
  valor_leido     DECIMAL(10,3) NOT NULL,
  severidad       VARCHAR(10)   NOT NULL,
  id_sensor_iot   INT           NOT NULL,
  CONSTRAINT PK_Anomalia PRIMARY KEY (id_anomalia)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Hotspot | Sombreado | Degradacion | Circuito abierto', 'schema', 'dbo', 'table', 'Anomalia', 'column', 'tipo_anomalia'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Baja | Media | Alta | Critica', 'schema', 'dbo', 'table', 'Anomalia', 'column', 'severidad'
GO

CREATE TABLE Cliente
(
  id_cliente        INT           NOT NULL IDENTITY(1,1),
  razon_social      NVARCHAR(150) NOT NULL,
  tipo_documento    VARCHAR(10)   NOT NULL DEFAULT 'RUC',
  nro_documento     VARCHAR(11)   NOT NULL,
  direccion_fiscal  NVARCHAR(200),
  telefono_contacto VARCHAR(15)  ,
  email_contacto    NVARCHAR(150),
  CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente)
)
GO

ALTER TABLE Cliente
  ADD CONSTRAINT UQ_Cliente_nro_documento UNIQUE (nro_documento)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'RUC | DNI | CE', 'schema', 'dbo', 'table', 'Cliente', 'column', 'tipo_documento'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'RUC (11) o DNI (8)', 'schema', 'dbo', 'table', 'Cliente', 'column', 'nro_documento'
GO

CREATE TABLE Consumo_energia
(
  id_consumo            BIGINT        NOT NULL IDENTITY(1,1),
  fecha_hora            DATETIME2(0)  NOT NULL,
  intervalo_min         SMALLINT      NOT NULL DEFAULT '15',
  energia_consumida_kwh DECIMAL(10,4) NOT NULL,
  id_instalacion        INT           NOT NULL,
  CONSTRAINT PK_Consumo_energia PRIMARY KEY (id_consumo)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Inicio del intervalo', 'schema', 'dbo', 'table', 'Consumo_energia', 'column', 'fecha_hora'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'15 | 30 | 60', 'schema', 'dbo', 'table', 'Consumo_energia', 'column', 'intervalo_min'
GO

CREATE TABLE Costo_mantenimiento
(
  id_costo_manten            INT           NOT NULL IDENTITY(1,1),
  costo_mano_obra            DECIMAL(12,2) NOT NULL DEFAULT 0,
  costo_materiales_repuestos DECIMAL(12,2) NOT NULL DEFAULT 0,
  costo_adicional_viaticos   DECIMAL(12,2) NOT NULL DEFAULT 0,
  moneda                     CHAR(3)       NOT NULL DEFAULT 'PEN',
  fecha_registro_costo       DATETIME2(0)  NOT NULL,
  id_orden_manten            INT           NOT NULL,
  CONSTRAINT PK_Costo_mantenimiento PRIMARY KEY (id_costo_manten)
)
GO

ALTER TABLE Costo_mantenimiento
  ADD CONSTRAINT UQ_Costo_mantenimiento_id_orden_manten UNIQUE (id_orden_manten)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE (1 liquidación por orden)', 'schema', 'dbo', 'table', 'Costo_mantenimiento', 'column', 'id_orden_manten'
GO

CREATE TABLE Detalle_presupuesto
(
  id_detalle_presupuesto INT           NOT NULL IDENTITY(1,1),
  cantidad               DECIMAL(10,2) NOT NULL,
  precio_unitario        DECIMAL(10,2) NOT NULL,
  id_orden_manten        INT           NOT NULL,
  id_repuesto            INT           NOT NULL,
  CONSTRAINT PK_Detalle_presupuesto PRIMARY KEY (id_detalle_presupuesto)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Detalle_presupuesto', 'column', 'id_detalle_presupuesto'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Precio pactado en la orden (histórico)', 'schema', 'dbo', 'table', 'Detalle_presupuesto', 'column', 'precio_unitario'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Detalle_presupuesto', 'column', 'id_orden_manten'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Detalle_presupuesto', 'column', 'id_repuesto'
GO

CREATE TABLE Distribuidora
(
  id_distribuidora INT          NOT NULL IDENTITY(1,1),
  nombre           NVARCHAR(50) NOT NULL,
  CONSTRAINT PK_Distribuidora PRIMARY KEY (id_distribuidora)
)
GO

ALTER TABLE Distribuidora
  ADD CONSTRAINT UQ_Distribuidora_nombre UNIQUE (nombre)
GO

CREATE TABLE Especialidad
(
  id_especialidad INT           NOT NULL IDENTITY(1,1),
  nombre          NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_Especialidad PRIMARY KEY (id_especialidad)
)
GO

ALTER TABLE Especialidad
  ADD CONSTRAINT UQ_Especialidad_nombre UNIQUE (nombre)
GO

CREATE TABLE Factor_emision
(
  id_factor_emision INT           NOT NULL IDENTITY(1,1),
  nombre_red        NVARCHAR(100) NOT NULL,
  kg_co2_kwh        DECIMAL(6,4)  NOT NULL,
  anio_vigencia     SMALLINT      NOT NULL,
  CONSTRAINT PK_Factor_emision PRIMARY KEY (id_factor_emision)
)
GO

ALTER TABLE Factor_emision
  ADD CONSTRAINT UQ_Factor_emision_nombre_red UNIQUE (nombre_red)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Factor_emision', 'column', 'id_factor_emision'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Factor_emision', 'column', 'nombre_red'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'kg CO2 por kWh', 'schema', 'dbo', 'table', 'Factor_emision', 'column', 'kg_co2_kwh'
GO

CREATE TABLE Incidencia
(
  id_incidencia         INT           NOT NULL IDENTITY(1,1),
  titulo                NVARCHAR(100) NOT NULL,
  descripcion_detallada NVARCHAR(250),
  prioridad             VARCHAR(10)   NOT NULL DEFAULT 'Media',
  estado                VARCHAR(20)   NOT NULL DEFAULT 'Abierta',
  fecha_apertura        DATETIME2(0)  NOT NULL,
  fecha_cierre          DATETIME2(0) ,
  tiempo_inactivo_min   INT          ,
  perdida_estimada_pen  DECIMAL(12,2),
  id_alerta             INT           NOT NULL,
  CONSTRAINT PK_Incidencia PRIMARY KEY (id_incidencia)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Incidencia', 'column', 'id_incidencia'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Baja | Media | Alta | Urgente', 'schema', 'dbo', 'table', 'Incidencia', 'column', 'prioridad'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Abierta | En diagnostico | En mantenimiento | Resuelta | Cerrada', 'schema', 'dbo', 'table', 'Incidencia', 'column', 'estado'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'NULL mientras esté abierta', 'schema', 'dbo', 'table', 'Incidencia', 'column', 'fecha_cierre'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Pérdida económica estimada en soles', 'schema', 'dbo', 'table', 'Incidencia', 'column', 'perdida_estimada_pen'
GO

CREATE TABLE Instalacion
(
  id_instalacion         INT           NOT NULL IDENTITY(1,1),
  nombre                 NVARCHAR(100) NOT NULL,
  ubicacion_lat          DECIMAL(10,7) NOT NULL,
  ubicacion_long         DECIMAL(10,7) NOT NULL,
  direccion              NVARCHAR(250),
  capacidad_nominal_kw   DECIMAL(10,2) NOT NULL,
  fecha_puesta_marcha    DATE          NOT NULL,
  estado_operativo       VARCHAR(30)   NOT NULL DEFAULT 'Operativa',
  id_cliente             INT           NOT NULL,
  id_tarifa              INT          ,
  potencia_contratada_kw DECIMAL(8,2) ,
  id_factor_emision      INT          ,
  CONSTRAINT PK_Instalacion PRIMARY KEY (id_instalacion)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'kWp', 'schema', 'dbo', 'table', 'Instalacion', 'column', 'capacidad_nominal_kw'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Operativa | En mantenimiento parcial | Fuera de servicio', 'schema', 'dbo', 'table', 'Instalacion', 'column', 'estado_operativo'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Del contrato con la distribuidora', 'schema', 'dbo', 'table', 'Instalacion', 'column', 'potencia_contratada_kw'
GO

CREATE TABLE Medicion
(
  id_medicion         BIGINT       NOT NULL IDENTITY(1,1),
  timestamp_registro  DATETIME2(3) NOT NULL,
  voltaje_v           DECIMAL(8,3) NOT NULL,
  corriente_a         DECIMAL(8,3) NOT NULL,
  temperatura_celda_c DECIMAL(5,2),
  irradiancia_w_m2    DECIMAL(7,2),
  id_sensor_iot       INT          NOT NULL,
  CONSTRAINT PK_Medicion PRIMARY KEY (id_medicion)
)
GO

CREATE TABLE Modelo_panel
(
  id_modelo_panel    INT          NOT NULL IDENTITY(1,1),
  marca              NVARCHAR(50) NOT NULL,
  modelo             NVARCHAR(50) NOT NULL,
  potencia_nominal_w DECIMAL(8,2) NOT NULL,
  CONSTRAINT PK_Modelo_panel PRIMARY KEY (id_modelo_panel)
)
GO

ALTER TABLE Modelo_panel
  ADD CONSTRAINT UQ_Modelo_panel_marca UNIQUE (marca)
GO

ALTER TABLE Modelo_panel
  ADD CONSTRAINT UQ_Modelo_panel_modelo UNIQUE (modelo)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Wp de fábrica', 'schema', 'dbo', 'table', 'Modelo_panel', 'column', 'potencia_nominal_w'
GO

CREATE TABLE Orden_mantenimiento
(
  id_orden_manten    INT         NOT NULL IDENTITY(1,1),
  tipo_mantenimiento VARCHAR(20) NOT NULL,
  fecha_programada   DATE        NOT NULL,
  fecha_ejecucion    DATE       ,
  estado             VARCHAR(20) NOT NULL DEFAULT 'Pendiente',
  id_incidencia      INT         NOT NULL,
  id_tecnico         INT         NOT NULL,
  CONSTRAINT PK_Orden_mantenimiento PRIMARY KEY (id_orden_manten)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Preventivo | Correctivo | Predictivo | Limpieza', 'schema', 'dbo', 'table', 'Orden_mantenimiento', 'column', 'tipo_mantenimiento'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'NULL hasta ejecutarse', 'schema', 'dbo', 'table', 'Orden_mantenimiento', 'column', 'fecha_ejecucion'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Pendiente | Asignada | En progreso | Completada | Cancelada', 'schema', 'dbo', 'table', 'Orden_mantenimiento', 'column', 'estado'
GO

CREATE TABLE Panel_Solar
(
  id_panel_solar     INT          NOT NULL IDENTITY(1,1),
  codigo_serie       VARCHAR(50)  NOT NULL,
  angulo_inclinacion DECIMAL(5,2) NOT NULL,
  orientacion        VARCHAR(10) ,
  estado             VARCHAR(20)  NOT NULL DEFAULT Optimo,
  id_instalacion     INT          NOT NULL,
  id_modelo_panel    INT          NOT NULL,
  CONSTRAINT PK_Panel_Solar PRIMARY KEY (id_panel_solar)
)
GO

ALTER TABLE Panel_Solar
  ADD CONSTRAINT UQ_Panel_Solar_codigo_serie UNIQUE (codigo_serie)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Panel_Solar', 'column', 'id_panel_solar'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Panel_Solar', 'column', 'codigo_serie'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Grados', 'schema', 'dbo', 'table', 'Panel_Solar', 'column', 'angulo_inclinacion'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Norte | Sur | Este | Oeste', 'schema', 'dbo', 'table', 'Panel_Solar', 'column', 'orientacion'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Optimo | Degradado | Danado | Desconectado', 'schema', 'dbo', 'table', 'Panel_Solar', 'column', 'estado'
GO

CREATE TABLE Permiso
(
  id_permiso  INT           NOT NULL IDENTITY(1,1),
  codigo      VARCHAR(50)   NOT NULL,
  descripcion NVARCHAR(200),
  CONSTRAINT PK_Permiso PRIMARY KEY (id_permiso)
)
GO

ALTER TABLE Permiso
  ADD CONSTRAINT UQ_Permiso_codigo UNIQUE (codigo)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Permiso', 'column', 'id_permiso'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Permiso', 'column', 'codigo'
GO

CREATE TABLE Repuesto
(
  id_repuesto             INT           NOT NULL IDENTITY(1,1),
  codigo_sku              VARCHAR(50)   NOT NULL,
  nombre                  NVARCHAR(100) NOT NULL,
  stock_actual            INT           NOT NULL DEFAULT 0,
  costo_unitario_estandar DECIMAL(10,2) NOT NULL,
  CONSTRAINT PK_Repuesto PRIMARY KEY (id_repuesto)
)
GO

ALTER TABLE Repuesto
  ADD CONSTRAINT UQ_Repuesto_codigo_sku UNIQUE (codigo_sku)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Repuesto', 'column', 'id_repuesto'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Repuesto', 'column', 'codigo_sku'
GO

CREATE TABLE Rol
(
  id_rol      INT           NOT NULL IDENTITY(1,1),
  nombre_rol  VARCHAR(50)   NOT NULL,
  descripcion NVARCHAR(200),
  CONSTRAINT PK_Rol PRIMARY KEY (id_rol)
)
GO

ALTER TABLE Rol
  ADD CONSTRAINT UQ_Rol_nombre_rol UNIQUE (nombre_rol)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Rol', 'column', 'id_rol'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Rol', 'column', 'nombre_rol'
GO

CREATE TABLE Rol_Permiso
(
  id_rol     INT NOT NULL,
  id_permiso INT NOT NULL,
  CONSTRAINT PK_Rol_Permiso PRIMARY KEY (id_rol, id_permiso)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK compuesta, FK', 'schema', 'dbo', 'table', 'Rol_Permiso', 'column', 'id_rol'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK compuesta, FK', 'schema', 'dbo', 'table', 'Rol_Permiso', 'column', 'id_permiso'
GO

CREATE TABLE Sensor_iot
(
  id_sensor_iot           INT         NOT NULL IDENTITY(1,1),
  identificador_hardware  VARCHAR(50) NOT NULL,
  mac_address             VARCHAR(17) NOT NULL,
  tipo_sensor             VARCHAR(30) NOT NULL,
  frecuencia_muestreo_seg INT         NOT NULL,
  estado_conexion         VARCHAR(20) NOT NULL DEFAULT 'Online',
  id_panel_solar          INT         NOT NULL,
  CONSTRAINT PK_Sensor_iot PRIMARY KEY (id_sensor_iot)
)
GO

ALTER TABLE Sensor_iot
  ADD CONSTRAINT UQ_Sensor_iot_identificador_hardware UNIQUE (identificador_hardware)
GO

ALTER TABLE Sensor_iot
  ADD CONSTRAINT UQ_Sensor_iot_mac_address UNIQUE (mac_address)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Online | Offline | Bateria baja', 'schema', 'dbo', 'table', 'Sensor_iot', 'column', 'estado_conexion'
GO

CREATE TABLE Tarifa_electrica
(
  id_tarifa        INT          NOT NULL IDENTITY(1,1),
  tipo_tarifa      VARCHAR(10)  NOT NULL,
  costo_kwh        DECIMAL(8,4) NOT NULL,
  moneda           CHAR(3)      NOT NULL DEFAULT 'PEN',
  id_distribuidora INT          NOT NULL,
  CONSTRAINT PK_Tarifa_electrica PRIMARY KEY (id_tarifa)
)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'PK, IDENTITY(1,1)', 'schema', 'dbo', 'table', 'Tarifa_electrica', 'column', 'id_tarifa'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'BT5A | BT5B | ... (UNIQUE con id_distribuidora)', 'schema', 'dbo', 'table', 'Tarifa_electrica', 'column', 'tipo_tarifa'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Costo por kWh', 'schema', 'dbo', 'table', 'Tarifa_electrica', 'column', 'costo_kwh'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'UNIQUE', 'schema', 'dbo', 'table', 'Tarifa_electrica', 'column', 'id_distribuidora'
GO

CREATE TABLE Tecnico
(
  id_tecnico            INT          NOT NULL IDENTITY(1,1),
  codigo_empleado       VARCHAR(20)  NOT NULL,
  disponibilidad        VARCHAR(20)  NOT NULL DEFAULT 'Disponible',
  calificacion_promedio DECIMAL(3,2),
  id_usuario            INT          NOT NULL,
  CONSTRAINT PK_Tecnico PRIMARY KEY (id_tecnico)
)
GO

ALTER TABLE Tecnico
  ADD CONSTRAINT UQ_Tecnico_codigo_empleado UNIQUE (codigo_empleado)
GO

ALTER TABLE Tecnico
  ADD CONSTRAINT UQ_Tecnico_id_usuario UNIQUE (id_usuario)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Disponible | En ruta | En servicio | De baja', 'schema', 'dbo', 'table', 'Tecnico', 'column', 'disponibilidad'
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'0.00 - 5.00', 'schema', 'dbo', 'table', 'Tecnico', 'column', 'calificacion_promedio'
GO

CREATE TABLE Tecnico_Especialidad
(
  id_tecnico      INT NOT NULL,
  id_especialidad INT NOT NULL,
  CONSTRAINT PK_Tecnico_Especialidad PRIMARY KEY (id_tecnico, id_especialidad)
)
GO

CREATE TABLE Usuario
(
  id_usuario        INT           NOT NULL IDENTITY(1,1),
  nombre_completo   NVARCHAR(100) NOT NULL,
  email             NVARCHAR(150) NOT NULL,
  password_hash     VARCHAR(255)  NOT NULL,
  telefono          VARCHAR(15)  ,
  estado            VARCHAR(15)   NOT NULL DEFAULT 'Activo',
  intentos_fallidos INT           NOT NULL DEFAULT 0,
  id_rol            INT           NOT NULL,
  id_cliente        INT           NOT NULL,
  CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario)
)
GO

ALTER TABLE Usuario
  ADD CONSTRAINT UQ_Usuario_email UNIQUE (email)
GO

EXECUTE sys.sp_addextendedproperty 'MS_Description',
  N'Activo | Suspendido | Inactivo', 'schema', 'dbo', 'table', 'Usuario', 'column', 'estado'
GO

ALTER TABLE Usuario
  ADD CONSTRAINT FK_Rol_TO_Usuario
    FOREIGN KEY (id_rol)
    REFERENCES Rol (id_rol)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Instalacion
  ADD CONSTRAINT FK_Cliente_TO_Instalacion
    FOREIGN KEY (id_cliente)
    REFERENCES Cliente (id_cliente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Panel_Solar
  ADD CONSTRAINT FK_Instalacion_TO_Panel_Solar
    FOREIGN KEY (id_instalacion)
    REFERENCES Instalacion (id_instalacion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Medicion
  ADD CONSTRAINT FK_Sensor_iot_TO_Medicion
    FOREIGN KEY (id_sensor_iot)
    REFERENCES Sensor_iot (id_sensor_iot)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Alerta
  ADD CONSTRAINT FK_Anomalia_TO_Alerta
    FOREIGN KEY (id_anomalia)
    REFERENCES Anomalia (id_anomalia)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Incidencia
  ADD CONSTRAINT FK_Alerta_TO_Incidencia
    FOREIGN KEY (id_alerta)
    REFERENCES Alerta (id_alerta)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Orden_mantenimiento
  ADD CONSTRAINT FK_Incidencia_TO_Orden_mantenimiento
    FOREIGN KEY (id_incidencia)
    REFERENCES Incidencia (id_incidencia)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Tecnico
  ADD CONSTRAINT FK_Usuario_TO_Tecnico
    FOREIGN KEY (id_usuario)
    REFERENCES Usuario (id_usuario)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Actividad_mantenimiento
  ADD CONSTRAINT FK_Orden_mantenimiento_TO_Actividad_mantenimiento
    FOREIGN KEY (id_orden_manten)
    REFERENCES Orden_mantenimiento (id_orden_manten)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Actividad_mantenimiento
  ADD CONSTRAINT FK_Tecnico_TO_Actividad_mantenimiento
    FOREIGN KEY (id_tecnico)
    REFERENCES Tecnico (id_tecnico)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Costo_mantenimiento
  ADD CONSTRAINT FK_Orden_mantenimiento_TO_Costo_mantenimiento
    FOREIGN KEY (id_orden_manten)
    REFERENCES Orden_mantenimiento (id_orden_manten)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Detalle_presupuesto
  ADD CONSTRAINT FK_Orden_mantenimiento_TO_Detalle_presupuesto
    FOREIGN KEY (id_orden_manten)
    REFERENCES Orden_mantenimiento (id_orden_manten)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Detalle_presupuesto
  ADD CONSTRAINT FK_Repuesto_TO_Detalle_presupuesto
    FOREIGN KEY (id_repuesto)
    REFERENCES Repuesto (id_repuesto)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Sensor_iot
  ADD CONSTRAINT FK_Panel_Solar_TO_Sensor_iot
    FOREIGN KEY (id_panel_solar)
    REFERENCES Panel_Solar (id_panel_solar)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Usuario
  ADD CONSTRAINT FK_Cliente_TO_Usuario
    FOREIGN KEY (id_cliente)
    REFERENCES Cliente (id_cliente)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Instalacion
  ADD CONSTRAINT FK_Tarifa_electrica_TO_Instalacion
    FOREIGN KEY (id_tarifa)
    REFERENCES Tarifa_electrica (id_tarifa)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Consumo_energia
  ADD CONSTRAINT FK_Instalacion_TO_Consumo_energia
    FOREIGN KEY (id_instalacion)
    REFERENCES Instalacion (id_instalacion)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Anomalia
  ADD CONSTRAINT FK_Sensor_iot_TO_Anomalia
    FOREIGN KEY (id_sensor_iot)
    REFERENCES Sensor_iot (id_sensor_iot)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Orden_mantenimiento
  ADD CONSTRAINT FK_Tecnico_TO_Orden_mantenimiento
    FOREIGN KEY (id_tecnico)
    REFERENCES Tecnico (id_tecnico)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Rol_Permiso
  ADD CONSTRAINT FK_Rol_TO_Rol_Permiso
    FOREIGN KEY (id_rol)
    REFERENCES Rol (id_rol)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Rol_Permiso
  ADD CONSTRAINT FK_Permiso_TO_Rol_Permiso
    FOREIGN KEY (id_permiso)
    REFERENCES Permiso (id_permiso)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Tecnico_Especialidad
  ADD CONSTRAINT FK_Tecnico_TO_Tecnico_Especialidad
    FOREIGN KEY (id_tecnico)
    REFERENCES Tecnico (id_tecnico)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Tecnico_Especialidad
  ADD CONSTRAINT FK_Especialidad_TO_Tecnico_Especialidad
    FOREIGN KEY (id_especialidad)
    REFERENCES Especialidad (id_especialidad)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Panel_Solar
  ADD CONSTRAINT FK_Modelo_panel_TO_Panel_Solar
    FOREIGN KEY (id_modelo_panel)
    REFERENCES Modelo_panel (id_modelo_panel)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Tarifa_electrica
  ADD CONSTRAINT FK_Distribuidora_TO_Tarifa_electrica
    FOREIGN KEY (id_distribuidora)
    REFERENCES Distribuidora (id_distribuidora)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO

ALTER TABLE Instalacion
  ADD CONSTRAINT FK_Factor_emision_TO_Instalacion
    FOREIGN KEY (id_factor_emision)
    REFERENCES Factor_emision (id_factor_emision)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
GO
