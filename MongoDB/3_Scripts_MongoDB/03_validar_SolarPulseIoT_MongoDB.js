/* ================================================================
   SOLARPULSEIOT - VALIDACION DE LAS 14 COLECCIONES FINALES

   Ejecutar en mongosh despues de ejecutar:
   02_transformar_SolarPulseIoT_MongoDB.js

   IMPORTANTE:
   No eliminar las colecciones stg_ hasta verificar los resultados
   y compararlos con los datos originales de SQL Server.
   ================================================================ */

const finales = [
  'roles',
  'usuarios',
  'clientes',
  'tarifas',
  'factores_emision',
  'modelos_panel',
  'repuestos',
  'instalaciones',
  'mediciones',
  'consumos_energia',
  'anomalias',
  'alertas',
  'incidencias',
  'ordenes_mantenimiento'
];

// ================================================================
// 1. CONTEO DE DOCUMENTOS
// ================================================================

print('\n=== CONTEO DE COLECCIONES FINALES ===');

finales.forEach(nombre => {
  print(
    nombre + ': ' +
    db.getCollection(nombre).countDocuments()
  );
});

// ================================================================
// 2. VALIDACION DE REFERENCIAS
// ================================================================

print('\n=== VALIDACIONES DE REFERENCIAS ===');

print(
  'Usuarios sin rol embebido: ' +
  db.usuarios.countDocuments({
    rol: {
      $exists: false
    }
  })
);

print(
  'Instalaciones sin cliente embebido: ' +
  db.instalaciones.countDocuments({
    cliente: {
      $exists: false
    }
  })
);

print(
  'Paneles sin modelo dentro de instalaciones: ' +
  db.instalaciones.countDocuments({
    'paneles.modelo': {
      $exists: false
    }
  })
);

print(
  'Anomalias sin instalacion_id: ' +
  db.anomalias.countDocuments({
    instalacion_id: {
      $exists: false
    }
  })
);

print(
  'Alertas sin anomalia embebida: ' +
  db.alertas.countDocuments({
    'anomalia.anomalia_id': {
      $exists: false
    }
  })
);

print(
  'Incidencias sin instalacion_id: ' +
  db.incidencias.countDocuments({
    instalacion_id: {
      $exists: false
    }
  })
);

// ================================================================
// 3. MUESTRAS DE DOCUMENTOS
// ================================================================

print('\n=== MUESTRAS ===');

print('\nDocumento de usuario:');
printjson(
  db.usuarios.findOne()
);

print('\nDocumento de instalacion:');
printjson(
  db.instalaciones.findOne()
);

print('\nDocumento de orden de mantenimiento:');
printjson(
  db.ordenes_mantenimiento.findOne()
);

// ================================================================
// 4. MENSAJE FINAL
// ================================================================

print('\n=== VALIDACION FINALIZADA ===');

print(
  'No elimines las colecciones stg_ hasta revisar estos resultados ' +
  'y comparar conteos con SQL Server.'
);