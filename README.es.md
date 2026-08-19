# MNote2

MNote2 es un editor de texto y código multiplataforma desarrollado con Lazarus/Free Pascal. La aplicación combina edición con pestañas, ejecución de scripts, herramientas de bases de datos, integración con IA, extracción de documentos y utilidades de voz.

Versión actual del código fuente: **2.68**.

## Capturas

### Editor integrado
![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)

### Gestión de archivos
![Gestión de archivos](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Inteligencia Artificial
![Uso de la IA](screenshots/IA.jpg)

### Gestor de bases de datos
![Base de datos](screenshots/MQUERY.jpg)

## Funciones principales

### Editor y archivos

- Editor multi-pestaña basado en SynEdit.
- Resaltado de sintaxis para Pascal, Python, Java, SQL, PHP, C y otros tipos configurados mediante listas auxiliares.
- Búsqueda, reemplazo, copiar/pegar, deshacer/rehacer, selección de bloques y configuración de fuente.
- Apertura y guardado de archivos en pestañas independientes.
- Extracción de texto de PDF, DOC y DOCX.
- Historial de conversación por archivo usando archivos .RIA asociados.
- Integración con organización de carpetas y proyectos.

### Proyectos, carpetas y análisis IA

- Exploración de carpetas con análisis de archivos fuente y documentos.
- Genera resúmenes técnicos por archivo en caché .RIA.
- Genera análisis orientados a preguntas en caché .PIA.
- Elimina la caché .RIA cuando el archivo fuente cambia después del resumen.
- Genera un mapa mental textual para consolidar los puntos relevantes de una pregunta.
- Ignora automáticamente los archivos de caché .RIA y .PIA durante nuevos análisis.
- Compatible con extensiones como .pas, .pp, .lfm, .lpr, .ini, .json, .yml, .yaml, .php, .htm, .html, .js, .xml, .c, .cpp, .txt, .doc, .docx, .pdf, .sql, .jsp, .py, .cob y .md.

### Inteligencia Artificial

- Cliente de IA encapsulado en TCHATGPT, versión interna 1.5.
- Proveedores compatibles: OpenAI, OpenRouter, Cerebras y Local/llama.cpp compatible con la API /v1/chat/completions.
- Modelos presentes en el código: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview, gpt-4o, gpt-o3-mini, gpt-4.1, gpt-4.1-mini y gpt-5.
- También se contemplan modelos locales tipo Ollama, incluidos llama3.2:3b, Qwen y DeepSeek.
- Soporte para modelo personalizado cuando está configurado.
- Configuración del endpoint local mediante IPLocalIA.
- Historial, mapa de memoria y pensamiento persistidos en archivos .RIA.
- Clasificación de continuidad de la conversación.
- Preparación de contexto a partir de historial, mapa de memoria, proyecto, base de datos y archivos analizados.
- Acciones asistidas por IA, incluida la generación de consultas SQL y la creación de estructuras de tabla.

### Python y automatización

- Ejecución de código Python abierto en el editor mediante PythonEngine.
- Ruta de DLL de Python configurable.
- Salida de ejecución dirigida al área de resultados.
- Inspección de variables globales y locales después de la ejecución.
- Scripts externos configurables para run, debug, clean, install y compile.
- Ejemplos en sample/python, sample/gcc y scripts auxiliares en src.

### Base de datos y MQuery2

MQuery2 funciona como gestor SQL integrado.

- Conexión a MySQL, PostgreSQL y SQLite mediante Zeos.
- Configuración de bibliotecas DLL/SO para MySQL, PostgreSQL y SQLite.
- Navegación por árboles de base de datos, tablas, campos, vistas, procedimientos, funciones, triggers y secuencias según la conexión activa.
- Ejecución de SQL libre desde el editor integrado.
- Generación de SQL a partir de tablas seleccionadas.
- Creación de tablas a partir de datasets CSV.
- Creación de usuarios PostgreSQL.
- Generación de diccionarios de datos para PostgreSQL y SQLite.
- Generación de listas de dependencias y claves foráneas para SQLite y PostgreSQL.
- Integración con IA para analizar SQL, sugerir mejoras, embellecer consultas y responder preguntas a partir de DDL y dependencias.
- TSQLiteDb ofrece conexión SQLite, transacciones, pragmas recomendados, ejecución parametrizada y consultas utilitarias.
- TProjetoDB abre el proyecto SQLite, verifica tablas y carga metadatos y configuración.

### Herramientas de voz

- ToolsFalar envía texto por TCP a un servicio de síntesis de voz como srvFalar.
- ToolsOuvir se conecta por TCP para recibir comandos y mensajes externos.
- Activación automática opcional al iniciar, según configuración.
- IP y puerto configurados desde la interfaz.

### Instalación y distribución

- Instalador Windows basado en Inno Setup en instalador/MNote2.iss.
- Versión del instalador Windows: 2.64.
- Copia MNote2.exe, DLLs, archivos .dci, listas .txt, scripts .bat, ejemplos y la base de datos predeterminada.
- Copia la base de datos predeterminada a C:db.
- Incluye una opción posinstalación para iniciar srvFalar_1.4.exe.
- Los paquetes y binarios históricos están en bin.
- buildlinux.sh mantiene el flujo de empaquetado Linux/deb.

## Estructura del Proyecto

- src/MNote2.lpr: punto de entrada de la aplicación Lazarus.
- src/main.pas: formulario principal, pestañas, editor, carga/guardado, chat, historial, herramientas e integración general.
- src/classes/item.pas: encapsula cada pestaña/elemento editable, ejecución Python y ejecución de scripts configurados.
- src/classes/chatgpt.pas: cliente HTTP para proveedores de IA.
- src/setmain.pas: configuración global y persistencia en mnote.cfg.
- src/config.pas: formulario de configuración de scripts, DLLs, IA, bases de datos y herramientas TCP.
- src/folders.pas: gestión de carpetas, análisis de archivos, cachés .RIA/.PIA y análisis de proyectos con IA.
- src/ia.pas: interfaz de IA con historial, mapa de memoria, pensamiento, continuidad y acciones.
- src/mquery2/mquery2.pas: gestor de bases de datos y SQL.
- src/sqlite_db.pas: envoltorio de SQLite.
- src/uprojetodb.pas: carga de proyectos SQLite y metadatos.
- src/uPdfText.pas: extracción nativa simple de texto de PDF.
- src/uDocText.pas: extracción de texto de DOC/DOCX.
- src/toolsfalar y src/toolsouvir: herramientas TCP de voz.
- db/projeto_padrao.db: base de datos predeterminada del proyecto.
- screenshots: imágenes usadas en el README.
- instalador: scripts de empaquetado para Windows.
- sample: ejemplos de Python, C y procesamiento de imagen.
- libs, sqlite y tools: bibliotecas y utilidades externas incluidas con el proyecto.

## Requisitos

### Desarrollo

- Lazarus IDE y Free Pascal Compiler.
- Paquetes Lazarus usados por el proyecto, incluidos LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet y componentes adicionales listados en src/MNote2.lpi.
- Bibliotecas de base de datos según necesidad: SQLite, cliente MySQL y PostgreSQL/libpq/ODBC según configuración.
- Python 3 compatible con la DLL configurada cuando la ejecución Python esté habilitada.
- Inno Setup para generar el instalador Windows.

### Uso

- Windows y Linux son los destinos principales representados en el proyecto.
- Los archivos .doc clásicos requieren Windows con Microsoft Word instalado.
- Las funciones de IA requieren un token/proveedor configurado o un servidor local compatible.
- Las herramientas de voz requieren que el servicio TCP correspondiente esté activo.

## Configuración

La configuración principal se guarda en mnote.cfg y la gestiona TSetMain. Incluye:

- Posición, tamaño de ventana y fuente.
- Archivos recientes.
- Scripts run/debug/clean/install/compile.
- Token de IA y proveedor.
- Endpoint local de IA.
- Rutas de DLL de Python, MySQL y PostgreSQL.
- Datos de conexión MySQL, PostgreSQL y SQLite.
- Activación y direcciones IP de ToolsFalar y ToolsOuvir.
- Carpeta predeterminada y proyecto actual.

Nota: mnote.cfg puede contener tokens de IA y contraseñas de base de datos. Protégelo localmente.

## Uso Básico

1. Abre MNote2.
2. Configura rutas de DLL, scripts, bases de datos e IA en Ajustes.
3. Abre o crea archivos en las pestañas del editor.
4. Usa el menú de lenguaje para elegir el tipo de archivo/código.
5. Ejecuta Python directamente o scripts externos configurados.
6. Abre MQuery2 para conectar con MySQL, PostgreSQL o SQLite.
7. Usa el panel de IA para preguntas con historial, mapa de memoria y análisis de proyecto.
8. Usa el gestor de carpetas para generar resúmenes .RIA y análisis .PIA.
9. Activa ToolsFalar/ToolsOuvir cuando necesites integración TCP de voz.

## Notas de Mantenimiento

- El código actual concentra mucha lógica en main.pas, folders.pas, ia.pas y mquery2.pas.
- El repositorio versiona binarios, paquetes y bibliotecas externas porque el proyecto distribuye artefactos junto al código fuente.
- Los archivos .RIA y .PIA se usan como caché/salida de IA y pueden regenerarse desde la aplicación.
- src/lib contiene artefactos de compilación de Lazarus/Free Pascal para las plataformas del proyecto.

## Licencia

Consulta el archivo LICENSE.
