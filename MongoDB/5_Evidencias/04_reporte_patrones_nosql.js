
use("SolarPulseIoT");

// ================================================
// REPORTE DE PATRONES DE MODELADO NOSQL
// Proyecto: SolarPulseIoT
// ================================================

const coleccionesFinales = [
  "roles",
  "usuarios",
  "clientes",
  "tarifas",
  "factores_emision",
  "modelos_panel",
  "repuestos",
  "instalaciones",
  "mediciones",
  "consumos_energia",
  "anomalias",
  "alertas",
  "incidencias",
  "ordenes_mantenimiento"
];

// Campos que indican estructuras embebidas
const camposEmbedding = [
  "permisos",
  "rol",
  "perfil_tecnico",
  "distribuidora",
  "cliente",
  "tarifa",
  "factor_emision",
  "paneles",
  "sensores",
  "alertas_recientes",
  "lecturas",
  "registros",
  "actividades",
  "presupuesto",
  "costo",
  "resumen"
];

// Campos que suelen contener referencias
const camposReferencia = [
  "cliente_id",
  "instalacion_id",
  "sensor_id",
  "panel_id",
  "modelo_id",
  "anomalia_id",
  "alerta_id",
  "incidencia_id",
  "usuario_id",
  "repuesto_id",
  "rol_id"
];

// Función para obtener un campo anidado
function obtenerCampo(documento, ruta) {
  return ruta.split(".").reduce(
    (obj, campo) => obj == null ? undefined : obj[campo],
    documento
  );
}

// Función para detectar objetos o arreglos embebidos
function esObjetoEmbebido(valor) {
  return valor !== null &&
    typeof valor === "object" &&
    !(valor instanceof Date) &&
    !Array.isArray(valor) === false;
}

// Función auxiliar para comprobar campos
function tieneCampo(documento, campo) {
  return obtenerCampo(documento, campo) !== undefined;
}

const reporte = {
  Embedding: {
    colecciones: new Set(),
    documentos: 0
  },
  Referencing: {
    colecciones: new Set(),
    documentos: 0
  },
  "Extended Reference": {
    colecciones: new Set(),
    documentos: 0
  },
  Subset: {
    colecciones: new Set(),
    documentos: 0,
    elementos: 0
  },
};

// Analizar cada colección final
coleccionesFinales.forEach(nombreColeccion => {
  const coleccion = db.getCollection(nombreColeccion);
  const documentos = coleccion.find().toArray();

  documentos.forEach(doc => {
    // 1. EMBEDDING
    const tieneEmbedding = camposEmbedding.some(campo => {
      const valor = doc[campo];

      return valor !== null &&
        typeof valor === "object";
    });

    if (tieneEmbedding) {
      reporte.Embedding.documentos++;
      reporte.Embedding.colecciones.add(nombreColeccion);
    }

    // 2. REFERENCING
    const tieneReferencia = camposReferencia.some(campo =>
      tieneCampo(doc, campo)
    );

    if (tieneReferencia) {
      reporte.Referencing.documentos++;
      reporte.Referencing.colecciones.add(nombreColeccion);
    }

    // 3. EXTENDED REFERENCE
    const camposExtendidos = [
      "rol.nombre_rol",
      "cliente.razon_social",
      "tarifa.tarifa_id",
      "factor_emision.factor_emision_id",
      "modelo.modelo_id",
      "tecnico.usuario_id",
      "repuesto.repuesto_id"
    ];

    const tieneExtendida = camposExtendidos.some(campo =>
      tieneCampo(doc, campo)
    );

    if (tieneExtendida) {
      reporte["Extended Reference"].documentos++;
      reporte["Extended Reference"].colecciones.add(nombreColeccion);
    }

    // 4. SUBSET
    if (
      nombreColeccion === "instalaciones" &&
      Array.isArray(doc.alertas_recientes)
    ) {
      reporte.Subset.documentos++;
      reporte.Subset.elementos += doc.alertas_recientes.length;
      reporte.Subset.colecciones.add(nombreColeccion);
    }
  });
});

// Mostrar reporte
print("========================================");
print("REPORTE DE PATRONES NOSQL");
print("Base de datos: SolarPulseIoT");
print("========================================");

Object.entries(reporte).forEach(([patron, datos]) => {
  print("");
  print("PATRON: " + patron);
  print("Colecciones: " + datos.colecciones.size);
  print("Documentos identificados: " + datos.documentos);

  if (datos.elementos !== undefined) {
    print("Elementos embebidos: " + datos.elementos);
  }

  print(
    "Colecciones detectadas: " +
    Array.from(datos.colecciones).join(", ")
  );
});

print("");
print("TOTAL DE PATRONES DOCUMENTADOS: 4");
print("========================================");