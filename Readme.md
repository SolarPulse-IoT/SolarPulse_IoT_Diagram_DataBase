# Diagramas Físicos de la Base de Datos

## Presentación del Diagrama Físico Sin Normalizar

En este repositorio se presenta el desarrollo del **Diagrama Físico de la Base de Datos**, elaborado mediante un **Diagrama Entidad-Relación (ERD)**.

Como parte del desarrollo del proyecto, se tomó como referencia el **Diagrama Lógico de la Base de Datos**, en el cual se encuentran definidos con mayor precisión los atributos, entidades y relaciones necesarias para representar los requerimientos del sistema.

El propósito del diagrama físico sin normalizar es realizar una primera representación de cómo se organizarían los datos dentro de una estructura de base de datos, considerando la información identificada durante el análisis de los requerimientos del sistema.

Esta representación permite visualizar las entidades y sus respectivos atributos antes de aplicar las reglas de normalización. De esta manera, se busca mantener una correspondencia entre los requerimientos planteados y la información que deberá ser almacenada, evitando la pérdida de datos importantes y asegurando que la base de datos pueda soportar las funcionalidades esperadas por los usuarios.

---

## Presentación del Diagrama Físico Normalizado

En esta sección se presenta el **Diagrama Físico Normalizado**, elaborado a partir del modelo previamente definido y aplicando los principios de **normalización de bases de datos**.

La normalización permite organizar la información de manera estructurada, reduciendo la redundancia de datos y evitando problemas relacionados con la inserción, actualización y eliminación de información.

A partir del modelo sin normalizar, se identifican y separan los datos que corresponden a diferentes entidades, estableciendo las relaciones necesarias entre ellas mediante **claves primarias y claves foráneas**.

El resultado es una estructura de base de datos más consistente y organizada, que facilita el almacenamiento, consulta y mantenimiento de la información.

Este diagrama representa la estructura física propuesta para el sistema y sirve como referencia para una posterior implementación de las tablas y relaciones en un **Sistema Gestor de Bases de Datos (SGBD)**.

---

## Objetivo de los Diagramas

Los diagramas desarrollados tienen como finalidad representar progresivamente la estructura de la base de datos, partiendo de la información identificada en los requerimientos del sistema hasta llegar a una estructura organizada y preparada para su implementación.

El proceso permite:

- Identificar las entidades necesarias para el sistema.
- Definir los atributos correspondientes a cada entidad.
- Establecer las relaciones entre las diferentes entidades.
- Identificar las claves primarias y claves foráneas.
- Reducir la redundancia de información mediante la normalización.
- Mantener la integridad y consistencia de los datos.
- Facilitar la posterior implementación de la base de datos.

## Estructura del Repositorio

Los diagramas incluidos en este repositorio permiten observar las diferentes etapas del diseño físico de la base de datos:

1. **Diagrama Físico Sin Normalizar:** representa la estructura inicial de los datos antes de aplicar las reglas de normalización.
2. **Diagrama Físico Normalizado:** representa la estructura organizada después de aplicar los principios de normalización y establecer correctamente las relaciones entre las entidades.

De esta manera, ambos diagramas permiten visualizar la evolución del diseño de la base de datos y comprender cómo se transforma la estructura inicial en un modelo preparado para su implementación.
