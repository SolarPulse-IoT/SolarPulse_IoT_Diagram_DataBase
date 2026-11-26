/* =====================================================================
   SOLARPULSEIOT - TRANSFORMACION CSV/STAGING -> 14 COLECCIONES FINALES
   Ejecutar con mongosh dentro de la base de datos SolarPulseIoT.

   Antes de ejecutar:
   - Importar los 25 CSV como colecciones con prefijo stg_.
   - En Compass, importar los id_* y campos numericos como Number.
   - Las fechas se exportan como texto ISO y este script las convierte
     a BSON Date.
   - Hacer respaldo si ya existen colecciones finales: $merge reemplaza
     documentos que tengan el mismo _id, pero no elimina documentos
     antiguos que ya no aparezcan en el origen.

   Colecciones finales:
   roles, usuarios, clientes, tarifas, factores_emision, modelos_panel,
   repuestos, instalaciones, mediciones, consumos_energia, anomalias,
   alertas, incidencias, ordenes_mantenimiento.
   ===================================================================== */

const SRC = {
  Rol: 'stg_Rol',
  Rol_Permiso: 'stg_Rol_Permiso',
  Permiso: 'stg_Permiso',
  Usuario: 'stg_Usuario',
  Cliente: 'stg_Cliente',
  Tecnico: 'stg_Tecnico',
  Especialidad: 'stg_Especialidad',
  Tecnico_Especialidad: 'stg_Tecnico_Especialidad',
  Distribuidora: 'stg_Distribuidora',
  Tarifa: 'stg_Tarifa_electrica',
  Factor: 'stg_Factor_emision',
  Instalacion: 'stg_Instalacion',
  Modelo: 'stg_Modelo_panel',
  Panel: 'stg_Panel_Solar',
  Sensor: 'stg_Sensor_iot',
  Medicion: 'stg_Medicion',
  Consumo: 'stg_Consumo_energia',
  Anomalia: 'stg_Anomalia',
  Alerta: 'stg_Alerta',
  Incidencia: 'stg_Incidencia',
  Orden: 'stg_Orden_mantenimiento',
  Actividad: 'stg_Actividad_mantenimiento',
  Costo: 'stg_Costo_mantenimiento',
  Repuesto: 'stg_Repuesto',
  Detalle: 'stg_Detalle_presupuesto'
};

function source(name) {
  return db.getCollection(SRC[name]);
}

function run(name, pipeline) {
  source(name).aggregate(pipeline, { allowDiskUse: true }).toArray();
}

function asDate(field) {
  return {
    $let: {
      vars: {
        fechaTexto: {
          $convert: {
            input: field,
            to: 'string',
            onError: '',
            onNull: ''
          }
        }
      },
      in: {
        $cond: [
          {
            $regexMatch: {
              input: '$$fechaTexto',
              regex: /^\d{2}\/\d{2}\/\d{4}$/
            }
          },
          {
            $dateFromString: {
              dateString: '$$fechaTexto',
              format: '%d/%m/%Y',
              onError: null,
              onNull: null
            }
          },
          {
            $convert: {
              input: field,
              to: 'date',
              onError: null,
              onNull: null
            }
          }
        ]
      }
    }
  };
}

function asNumber(field) {
  return {
    $convert: {
      input: field,
      to: 'double',
      onError: null,
      onNull: null
    }
  };
}

function writeTo(collection) {
  return {
    $merge: {
      into: collection,
      on: '_id',
      whenMatched: 'replace',
      whenNotMatched: 'insert'
    }
  };
}

// ================================================================
// 1. ROLES
// Embedding Pattern: permisos dentro de cada rol.
// ================================================================

print('1/14 - Construyendo roles');

run('Rol', [
  {
    $lookup: {
      from: SRC.Rol_Permiso,
      localField: 'id_rol',
      foreignField: 'id_rol',
      as: 'rp'
    }
  },
  {
    $lookup: {
      from: SRC.Permiso,
      localField: 'rp.id_permiso',
      foreignField: 'id_permiso',
      as: 'permisos_src'
    }
  },
  {
    $project: {
      _id: '$id_rol',
      nombre_rol: 1,
      descripcion: 1,
      permisos: {
        $map: {
          input: '$permisos_src',
          as: 'p',
          in: {
            codigo: '$$p.codigo',
            descripcion: '$$p.descripcion'
          }
        }
      }
    }
  },
  writeTo('roles')
]);

// ================================================================
// 2. CLIENTES
// ================================================================

print('2/14 - Construyendo clientes');

run('Cliente', [
  {
    $project: {
      _id: '$id_cliente',
      razon_social: 1,
      tipo_documento: 1,
      nro_documento: 1,
      direccion_fiscal: 1,
      telefono_contacto: 1,
      email_contacto: 1
    }
  },
  writeTo('clientes')
]);

// ================================================================
// 3. USUARIOS
// Extended Reference Pattern: rol.
// Embedding Pattern: perfil tecnico y especialidades.
// Referencing Pattern: cliente_id.
// ================================================================

print('3/14 - Construyendo usuarios y perfil tecnico');

run('Usuario', [
  {
    $lookup: {
      from: SRC.Rol,
      localField: 'id_rol',
      foreignField: 'id_rol',
      as: 'rol'
    }
  },
  {
    $unwind: '$rol'
  },
  {
    $lookup: {
      from: SRC.Cliente,
      localField: 'id_cliente',
      foreignField: 'id_cliente',
      as: 'cliente'
    }
  },
  {
    $unwind: {
      path: '$cliente',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: SRC.Tecnico,
      localField: 'id_usuario',
      foreignField: 'id_usuario',
      as: 'tecnico'
    }
  },
  {
    $unwind: {
      path: '$tecnico',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: SRC.Tecnico_Especialidad,
      localField: 'tecnico.id_tecnico',
      foreignField: 'id_tecnico',
      as: 'te'
    }
  },
  {
    $lookup: {
      from: SRC.Especialidad,
      localField: 'te.id_especialidad',
      foreignField: 'id_especialidad',
      as: 'esp'
    }
  },
  {
    $project: {
      _id: '$id_usuario',
      nombre_completo: 1,
      email: 1,
      password_hash: 1,
      telefono: 1,
      estado: 1,
      intentos_fallidos: 1,

      rol: {
        rol_id: '$rol.id_rol',
        nombre_rol: '$rol.nombre_rol'
      },

      cliente_id: '$id_cliente',

      perfil_tecnico: {
        $cond: [
          {
            $ne: [
              { $ifNull: ['$tecnico.id_tecnico', null] },
              null
            ]
          },
          {
            tecnico_id: '$tecnico.id_tecnico',
            codigo_empleado: '$tecnico.codigo_empleado',
            disponibilidad: '$tecnico.disponibilidad',
            calificacion_promedio: '$tecnico.calificacion_promedio',

            especialidades: {
              $map: {
                input: '$esp',
                as: 'e',
                in: {
                  especialidad_id: '$$e.id_especialidad',
                  nombre: '$$e.nombre'
                }
              }
            }
          },
          '$$REMOVE'
        ]
      }
    }
  },
  writeTo('usuarios')
]);

// ================================================================
// 4. TARIFAS
// Embedding Pattern: distribuidora dentro de tarifa.
// ================================================================

print('4/14 - Construyendo tarifas');

run('Tarifa', [
  {
    $lookup: {
      from: SRC.Distribuidora,
      localField: 'id_distribuidora',
      foreignField: 'id_distribuidora',
      as: 'dist'
    }
  },
  {
    $unwind: '$dist'
  },
  {
    $project: {
      _id: '$id_tarifa',
      tipo_tarifa: 1,
      costo_kwh: 1,
      moneda: 1,

      distribuidora: {
        distribuidora_id: '$id_distribuidora',
        nombre: '$dist.nombre'
      }
    }
  },
  writeTo('tarifas')
]);

// ================================================================
// 5. FACTORES DE EMISION
// ================================================================

print('5/14 - Construyendo factores_emision');

run('Factor', [
  {
    $project: {
      _id: '$id_factor_emision',
      nombre_red: 1,
      kg_co2_kwh: 1,
      anio_vigencia: 1
    }
  },
  writeTo('factores_emision')
]);

// ================================================================
// 6. MODELOS DE PANELES
// ================================================================

print('6/14 - Construyendo modelos_panel');

run('Modelo', [
  {
    $project: {
      _id: '$id_modelo_panel',
      marca: 1,
      modelo: 1,
      potencia_nominal_w: 1
    }
  },
  writeTo('modelos_panel')
]);

// ================================================================
// 7. REPUESTOS
// ================================================================

print('7/14 - Construyendo repuestos');

run('Repuesto', [
  {
    $project: {
      _id: '$id_repuesto',
      codigo_sku: 1,
      nombre: 1,
      stock_actual: 1,
      costo_unitario_estandar: 1
    }
  },
  writeTo('repuestos')
]);

// ================================================================
// 8. ANOMALIAS
// Referencing Pattern: sensor, panel e instalacion.
// ================================================================

print('8/14 - Construyendo anomalias con contexto de instalacion');

run('Anomalia', [
  {
    $lookup: {
      from: SRC.Sensor,
      localField: 'id_sensor_iot',
      foreignField: 'id_sensor_iot',
      as: 'sensor'
    }
  },
  {
    $unwind: '$sensor'
  },
  {
    $lookup: {
      from: SRC.Panel,
      localField: 'sensor.id_panel_solar',
      foreignField: 'id_panel_solar',
      as: 'panel'
    }
  },
  {
    $unwind: '$panel'
  },
  {
    $project: {
      _id: '$id_anomalia',
      fecha_deteccion: asDate('$fecha_deteccion'),
      tipo_anomalia: 1,
      valor_esperado: 1,
      valor_leido: 1,
      severidad: 1,
      sensor_id: '$sensor.id_sensor_iot',
      panel_id: '$panel.id_panel_solar',
      instalacion_id: '$panel.id_instalacion'
    }
  },
  writeTo('anomalias')
]);

// ================================================================
// 9. ALERTAS
// Extended Reference Pattern: datos de anomalia e instalacion.
// ================================================================

print('9/14 - Construyendo alertas');

run('Alerta', [
  {
    $lookup: {
      from: 'anomalias',
      localField: 'id_anomalia',
      foreignField: '_id',
      as: 'anomalia'
    }
  },
  {
    $unwind: '$anomalia'
  },
  {
    $project: {
      _id: '$id_alerta',
      fecha_generacion: asDate('$fecha_generacion'),
      mensaje: 1,
      recomendacion: 1,
      canal_envio: 1,
      estado: 1,

      anomalia: {
        anomalia_id: '$anomalia._id',
        tipo_anomalia: '$anomalia.tipo_anomalia',
        severidad: '$anomalia.severidad',
        valor_leido: '$anomalia.valor_leido'
      },

      instalacion_id: '$anomalia.instalacion_id'
    }
  },
  writeTo('alertas')
]);

// ================================================================
// 10. INCIDENCIAS
// Extended Reference Pattern: alerta, anomalia e instalacion.
// ================================================================

print('10/14 - Construyendo incidencias');

run('Incidencia', [
  {
    $lookup: {
      from: 'alertas',
      localField: 'id_alerta',
      foreignField: '_id',
      as: 'alerta'
    }
  },
  {
    $unwind: '$alerta'
  },
  {
    $project: {
      _id: '$id_incidencia',
      titulo: 1,
      descripcion_detallada: 1,
      prioridad: 1,
      estado: 1,
      fecha_apertura: asDate('$fecha_apertura'),
      fecha_cierre: asDate('$fecha_cierre'),
      tiempo_inactivo_min: 1,
      perdida_estimada_pen: 1,

      alerta: {
        alerta_id: '$alerta._id',
        mensaje: '$alerta.mensaje',
        fecha_generacion: '$alerta.fecha_generacion'
      },

      anomalia_id: '$alerta.anomalia.anomalia_id',
      instalacion_id: '$alerta.instalacion_id'
    }
  },
  writeTo('incidencias')
]);

// ================================================================
// 11. ORDENES DE MANTENIMIENTO
// Embedding Pattern: actividades, presupuesto y costo.
// Extended Reference Pattern: instalacion y tecnico.
// ================================================================

print('11/14 - Construyendo ordenes_mantenimiento');

run('Orden', [
  {
    $lookup: {
      from: 'incidencias',
      localField: 'id_incidencia',
      foreignField: '_id',
      as: 'inc'
    }
  },
  {
    $unwind: '$inc'
  },
  {
    $lookup: {
      from: SRC.Tecnico,
      localField: 'id_tecnico',
      foreignField: 'id_tecnico',
      as: 'tec'
    }
  },
  {
    $unwind: '$tec'
  },
  {
    $lookup: {
      from: SRC.Usuario,
      localField: 'tec.id_usuario',
      foreignField: 'id_usuario',
      as: 'usr'
    }
  },
  {
    $unwind: '$usr'
  },
  {
    $lookup: {
      from: SRC.Actividad,
      localField: 'id_orden_manten',
      foreignField: 'id_orden_manten',
      as: 'actividades'
    }
  },
  {
    $lookup: {
      from: SRC.Detalle,
      localField: 'id_orden_manten',
      foreignField: 'id_orden_manten',
      as: 'detalles'
    }
  },
  {
    $lookup: {
      from: SRC.Repuesto,
      localField: 'detalles.id_repuesto',
      foreignField: 'id_repuesto',
      as: 'repuestos_src'
    }
  },
  {
    $lookup: {
      from: SRC.Costo,
      localField: 'id_orden_manten',
      foreignField: 'id_orden_manten',
      as: 'costos'
    }
  },
  {
    $project: {
      _id: '$id_orden_manten',
      tipo_mantenimiento: 1,
      fecha_programada: asDate('$fecha_programada'),
      fecha_ejecucion: asDate('$fecha_ejecucion'),
      estado: 1,

      incidencia_id: '$id_incidencia',
      instalacion_id: '$inc.instalacion_id',

      tecnico: {
        tecnico_id: '$tec.id_tecnico',
        codigo_empleado: '$tec.codigo_empleado',
        usuario_id: '$usr.id_usuario',
        nombre_completo: '$usr.nombre_completo'
      },

      actividades: {
        $map: {
          input: '$actividades',
          as: 'a',
          in: {
            actividad_id: '$$a.id_actividad_manten',
            descripcion_tarea: '$$a.descripcion_tarea',
            tiempo_estimado_min: '$$a.tiempo_estimado_min',
            tiempo_real_min: '$$a.tiempo_real_min',
            resultado: '$$a.resultado',
            observaciones: '$$a.observaciones',
            tecnico_id: '$$a.id_tecnico'
          }
        }
      },

      presupuesto: {
        $map: {
          input: '$detalles',
          as: 'd',
          in: {
            detalle_id: '$$d.id_detalle_presupuesto',
            cantidad: '$$d.cantidad',
            precio_unitario: '$$d.precio_unitario',

            repuesto: {
              $let: {
                vars: {
                  r: {
                    $arrayElemAt: [
                      {
                        $filter: {
                          input: '$repuestos_src',
                          as: 'r',
                          cond: {
                            $eq: [
                              '$$r.id_repuesto',
                              '$$d.id_repuesto'
                            ]
                          }
                        }
                      },
                      0
                    ]
                  }
                },
                in: {
                  repuesto_id: '$$d.id_repuesto',
                  codigo_sku: '$$r.codigo_sku',
                  nombre: '$$r.nombre'
                }
              }
            }
          }
        }
      },

      costo: {
        $cond: [
          {
            $gt: [
              { $size: '$costos' },
              0
            ]
          },
          {
            costo_id: {
              $arrayElemAt: [
                '$costos.id_costo_manten',
                0
              ]
            },
            mano_obra: {
              $arrayElemAt: [
                '$costos.costo_mano_obra',
                0
              ]
            },
            materiales_repuestos: {
              $arrayElemAt: [
                '$costos.costo_materiales_repuestos',
                0
              ]
            },
            adicional_viaticos: {
              $arrayElemAt: [
                '$costos.costo_adicional_viaticos',
                0
              ]
            },
            moneda: {
              $arrayElemAt: [
                '$costos.moneda',
                0
              ]
            },
            fecha_registro: asDate({
              $arrayElemAt: [
                '$costos.fecha_registro_costo',
                0
              ]
            })
          },
          '$$REMOVE'
        ]
      }
    }
  },
  writeTo('ordenes_mantenimiento')
]);

// ================================================================
// 12. INSTALACIONES
// Embedding Pattern: paneles y sensores.
// Subset Pattern: ultimas 5 alertas.
// Extended Reference Pattern: cliente, tarifa y factor de emision.
// GeoJSON: ubicacion.
// ================================================================

print('12/14 - Construyendo instalaciones con paneles, sensores y referencias extendidas');

run('Instalacion', [
  {
    $lookup: {
      from: SRC.Cliente,
      localField: 'id_cliente',
      foreignField: 'id_cliente',
      as: 'cli'
    }
  },
  {
    $unwind: '$cli'
  },
  {
    $lookup: {
      from: SRC.Tarifa,
      localField: 'id_tarifa',
      foreignField: 'id_tarifa',
      as: 'tar'
    }
  },
  {
    $unwind: {
      path: '$tar',
      preserveNullAndEmptyArrays: true
    }
  },
  {
    $lookup: {
      from: SRC.Distribuidora,
      localField: 'tar.id_distribuidora',
      foreignField: 'id_distribuidora',
      as: 'dis'
    }
  },
  {
    $lookup: {
      from: SRC.Factor,
      localField: 'id_factor_emision',
      foreignField: 'id_factor_emision',
      as: 'fac'
    }
  },
  {
    $lookup: {
      from: SRC.Panel,
      localField: 'id_instalacion',
      foreignField: 'id_instalacion',
      as: 'panels'
    }
  },
  {
    $lookup: {
      from: SRC.Modelo,
      localField: 'panels.id_modelo_panel',
      foreignField: 'id_modelo_panel',
      as: 'models'
    }
  },
  {
    $lookup: {
      from: SRC.Sensor,
      localField: 'panels.id_panel_solar',
      foreignField: 'id_panel_solar',
      as: 'sensors'
    }
  },
  {
    $lookup: {
      from: 'alertas',
      localField: 'id_instalacion',
      foreignField: 'instalacion_id',
      as: 'alerts'
    }
  },
  {
    $project: {
      _id: '$id_instalacion',
      nombre: 1,

      ubicacion: {
        type: 'Point',
        coordinates: [
          { $toDouble: '$ubicacion_long' },
          { $toDouble: '$ubicacion_lat' }
        ]
      },

      direccion: 1,
      capacidad_nominal_kw: 1,
      fecha_puesta_marcha: asDate('$fecha_puesta_marcha'),
      estado_operativo: 1,

      cliente: {
        cliente_id: '$cli.id_cliente',
        razon_social: '$cli.razon_social',
        nro_documento: '$cli.nro_documento'
      },

      tarifa: {
        $cond: [
          {
            $ne: [
              { $ifNull: ['$tar.id_tarifa', null] },
              null
            ]
          },
          {
            tarifa_id: '$tar.id_tarifa',
            tipo_tarifa: '$tar.tipo_tarifa',
            costo_kwh: '$tar.costo_kwh',
            moneda: '$tar.moneda',

            distribuidora: {
              $let: {
                vars: {
                  d: {
                    $arrayElemAt: [
                      '$dis',
                      0
                    ]
                  }
                },
                in: {
                  nombre: '$$d.nombre'
                }
              }
            }
          },
          '$$REMOVE'
        ]
      },

      potencia_contratada_kw: 1,

      factor_emision: {
        $cond: [
          {
            $gt: [
              { $size: '$fac' },
              0
            ]
          },
          {
            factor_emision_id: {
              $arrayElemAt: [
                '$fac.id_factor_emision',
                0
              ]
            },
            nombre_red: {
              $arrayElemAt: [
                '$fac.nombre_red',
                0
              ]
            },
            kg_co2_kwh: {
              $arrayElemAt: [
                '$fac.kg_co2_kwh',
                0
              ]
            },
            anio_vigencia: {
              $arrayElemAt: [
                '$fac.anio_vigencia',
                0
              ]
            }
          },
          '$$REMOVE'
        ]
      },

      paneles: {
        $map: {
          input: '$panels',
          as: 'p',
          in: {
            panel_id: '$$p.id_panel_solar',
            codigo_serie: '$$p.codigo_serie',
            angulo_inclinacion: '$$p.angulo_inclinacion',
            orientacion: '$$p.orientacion',
            estado: '$$p.estado',

            modelo: {
              $let: {
                vars: {
                  m: {
                    $arrayElemAt: [
                      {
                        $filter: {
                          input: '$models',
                          as: 'm',
                          cond: {
                            $eq: [
                              '$$m.id_modelo_panel',
                              '$$p.id_modelo_panel'
                            ]
                          }
                        }
                      },
                      0
                    ]
                  }
                },
                in: {
                  modelo_id: '$$p.id_modelo_panel',
                  marca: '$$m.marca',
                  modelo: '$$m.modelo',
                  potencia_nominal_w: '$$m.potencia_nominal_w'
                }
              }
            },

            sensores: {
              $map: {
                input: {
                  $filter: {
                    input: '$sensors',
                    as: 's',
                    cond: {
                      $eq: [
                        '$$s.id_panel_solar',
                        '$$p.id_panel_solar'
                      ]
                    }
                  }
                },
                as: 's',
                in: {
                  sensor_id: '$$s.id_sensor_iot',
                  identificador_hardware: '$$s.identificador_hardware',
                  mac_address: '$$s.mac_address',
                  tipo_sensor: '$$s.tipo_sensor',
                  frecuencia_muestreo_seg: '$$s.frecuencia_muestreo_seg',
                  estado_conexion: '$$s.estado_conexion'
                }
              }
            }
          }
        }
      },

      alertas_recientes: {
        $slice: [
          {
            $map: {
              input: {
                $sortArray: {
                  input: '$alerts',
                  sortBy: {
                    fecha_generacion: -1
                  }
                }
              },
              as: 'a',
              in: {
                alerta_id: '$$a._id',
                fecha_generacion: '$$a.fecha_generacion',
                mensaje: '$$a.mensaje',
                estado: '$$a.estado'
              }
            }
          },
          5
        ]
      },

      resumen: {
        cantidad_paneles: {
          $size: '$panels'
        },
        cantidad_sensores: {
          $size: '$sensors'
        },
        cantidad_alertas: {
          $size: '$alerts'
        }
      }
    }
  },
  writeTo('instalaciones')
]);

// ================================================================
// 13. MEDICIONES
// Bucketing Pattern: agrupacion por sensor y hora.
// Computed Pattern: promedios y cantidad de lecturas.
// ================================================================

print('13/14 - Construyendo mediciones agrupadas por sensor y hora');

run('Medicion', [
  {
    $set: {
      fechaDate: asDate('$timestamp_registro')
    }
  },
  {
    $match: {
      fechaDate: {
        $ne: null
      }
    }
  },
  {
    $lookup: {
      from: SRC.Sensor,
      localField: 'id_sensor_iot',
      foreignField: 'id_sensor_iot',
      as: 's'
    }
  },
  {
    $unwind: '$s'
  },
  {
    $lookup: {
      from: SRC.Panel,
      localField: 's.id_panel_solar',
      foreignField: 'id_panel_solar',
      as: 'p'
    }
  },
  {
    $unwind: '$p'
  },
  {
    $set: {
      hora_inicio: {
        $dateTrunc: {
          date: '$fechaDate',
          unit: 'hour'
        }
      }
    }
  },
  {
    $group: {
      _id: {
        sensor_id: '$id_sensor_iot',
        hora: '$hora_inicio'
      },

      sensor_id: {
        $first: '$id_sensor_iot'
      },
      panel_id: {
        $first: '$p.id_panel_solar'
      },
      instalacion_id: {
        $first: '$p.id_instalacion'
      },
      hora_inicio: {
        $first: '$hora_inicio'
      },

      lecturas: {
        $push: {
          medicion_id: '$id_medicion',
          timestamp: '$fechaDate',
          voltaje_v: '$voltaje_v',
          corriente_a: '$corriente_a',
          temperatura_celda_c: '$temperatura_celda_c',
          irradiancia_w_m2: '$irradiancia_w_m2'
        }
      },

      cantidad_lecturas: {
        $sum: 1
      },
      voltaje_promedio: {
        $avg: '$voltaje_v'
      },
      corriente_promedio: {
        $avg: '$corriente_a'
      },
      irradiancia_promedio: {
        $avg: '$irradiancia_w_m2'
      }
    }
  },
  {
    $project: {
      _id: {
        $concat: [
          {
            $toString: '$_id.sensor_id'
          },
          '_',
          {
            $dateToString: {
              date: '$_id.hora',
              format: '%Y%m%d%H'
            }
          }
        ]
      },

      sensor_id: 1,
      panel_id: 1,
      instalacion_id: 1,
      hora_inicio: 1,
      lecturas: 1,

      resumen: {
        cantidad_lecturas: '$cantidad_lecturas',
        voltaje_promedio: '$voltaje_promedio',
        corriente_promedio: '$corriente_promedio',
        irradiancia_promedio: '$irradiancia_promedio',
        temperatura_promedio: {
          $avg: "$lecturas.temperatura_celda_c"
        }
      }
    }
  },
  writeTo('mediciones')
]);

// ================================================================
// 14. CONSUMOS DE ENERGIA
// Bucketing Pattern: agrupacion por instalacion y dia.
// Computed Pattern: energia total y promedio.
// ================================================================

print('14/14 - Construyendo consumos agrupados por instalacion y dia');

run('Consumo', [
  {
    $set: {
      fechaDate: asDate('$fecha_hora')
    }
  },
  {
    $match: {
      fechaDate: {
        $ne: null
      }
    }
  },
  {
    $group: {
      _id: {
        instalacion_id: '$id_instalacion',
        dia: {
          $dateTrunc: {
            date: '$fechaDate',
            unit: 'day'
          }
        }
      },

      instalacion_id: {
        $first: '$id_instalacion'
      },
      dia: {
        $first: {
          $dateTrunc: {
            date: '$fechaDate',
            unit: 'day'
          }
        }
      },

      registros: {
        $push: {
          consumo_id: '$id_consumo',
          fecha_hora: '$fechaDate',
          intervalo_min: '$intervalo_min',
          energia_consumida_kwh: '$energia_consumida_kwh'
        }
      },

      cantidad_registros: {
        $sum: 1
      },
      energia_total_kwh: {
        $sum: '$energia_consumida_kwh'
      },
      energia_promedio_kwh: {
        $avg: '$energia_consumida_kwh'
      }
    }
  },
  {
    $project: {
      _id: {
        $concat: [
          {
            $toString: '$_id.instalacion_id'
          },
          '_',
          {
            $dateToString: {
              date: '$_id.dia',
              format: '%Y%m%d'
            }
          }
        ]
      },

      instalacion_id: 1,
      dia: 1,
      registros: 1,

      resumen: {
        cantidad_registros: '$cantidad_registros',
        energia_total_kwh: '$energia_total_kwh',
        energia_promedio_kwh: '$energia_promedio_kwh'
      }
    }
  },
  writeTo('consumos_energia')
]);

print('Transformacion terminada. Se generaron/actualizaron las 14 colecciones finales.');

print('IMPORTANTE: revisar conteos y documentos antes de eliminar colecciones stg_.');