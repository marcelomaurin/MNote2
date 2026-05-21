# MNote2

MNote2 is a cross-platform text and code editor built with Lazarus/Free Pascal. It combines tabbed editing, script execution, database tooling, AI integration, document extraction, and auxiliary voice tools.

Current source version: **2.56**.

## Screenshots

### Integrated editor
![Editor](screenshots/Editor%20com%20IA%20integrada.jpg)

### File management
![File management](screenshots/Gest%C3%A3o%20de%20Arquivos.jpg)

### Artificial Intelligence
![AI usage](screenshots/IA.jpg)

### Database manager
![Database](screenshots/MQUERY.jpg)

## Key Features

### Editor and files

- Multi-tab editor based on SynEdit.
- Syntax highlighting support for Pascal, Python, Java, SQL, PHP, C, and other file types configured through helper lists.
- Search, replace, copy/paste, undo/redo, block selection, and font configuration.
- Open and save files in independent tabs.
- Text extraction from PDF, DOC, and DOCX files.
- Per-file conversation history stored in associated .RIA files.
- Integration with folder and project organization.

### Projects, folders, and AI analysis

- Folder traversal with source and document analysis.
- Generates technical per-file summaries cached as .RIA.
- Generates question-oriented analyses cached as .PIA.
- Removes .RIA cache when the source file changes after the summary.
- Generates a textual mind map to consolidate relevant points from a question.
- Automatically ignores .RIA and .PIA cache files during new analysis.
- Supports extensions such as .pas, .pp, .lfm, .lpr, .ini, .json, .yml, .yaml, .php, .htm, .html, .js, .xml, .c, .cpp, .txt, .doc, .docx, .pdf, .sql, .jsp, .py, .cob, and .md.

### Artificial Intelligence

- AI client encapsulated in TCHATGPT, internal version 1.5.
- Supported providers: OpenAI, OpenRouter, Cerebras, and Local/llama.cpp compatible with the /v1/chat/completions API.
- Models represented in code: gpt-3.5-turbo, gpt-4, gpt-4-turbo-preview, gpt-4o, gpt-o3-mini, gpt-4.1, gpt-4.1-mini, and gpt-5.
- Local/Ollama-style models are also represented, including llama3.2:3b, Qwen, and DeepSeek.
- Custom model support when configured.
- Local endpoint configuration through IPLocalIA.
- Conversation history, memory map, and thinking notes persisted in .RIA files.
- Conversation continuity classification.
- Context preparation from history, memory map, project, database, and analyzed files.
- AI-assisted actions, including SQL generation and table-structure creation.

### Python and automation

- Executes Python code opened in the editor through PythonEngine.
- Configurable Python DLL path.
- Execution output directed to the results area.
- Inspection of global and local variables after execution.
- External scripts can be configured for run, debug, clean, install, and compile.
- Samples live in sample/python, sample/gcc, and helper scripts under src.

### Database and MQuery2

MQuery2 works as the built-in SQL manager.

- Connects to MySQL, PostgreSQL, and SQLite through Zeos.
- Configures DLL/SO libraries for MySQL, PostgreSQL, and SQLite.
- Navigates database trees, tables, fields, views, procedures, functions, triggers, and sequences depending on the active connection.
- Runs free-form SQL from the integrated editor.
- Generates SQL from selected tables.
- Creates tables from CSV datasets.
- Creates PostgreSQL users.
- Generates data dictionaries for PostgreSQL and SQLite.
- Generates dependency and foreign-key lists for SQLite and PostgreSQL.
- Integrates with AI to analyze SQL, suggest improvements, beautify queries, and answer questions based on DDL and dependencies.
- TSQLiteDb provides SQLite connection, transactions, recommended pragmas, parameterized execution, and utility queries.
- TProjetoDB opens the SQLite project, checks tables, and loads metadata and configuration.

### Voice tools

- ToolsFalar sends text over TCP to a speech-synthesis service such as srvFalar.
- ToolsOuvir connects over TCP to receive external commands and messages.
- Optional automatic activation at startup, depending on configuration.
- IP and port are configured through the UI.

### Installation and distribution

- Windows installer built with Inno Setup at instalador/MNote2.iss.
- Windows installer version: 2.56.
- Copies MNote2.exe, DLLs, .dci files, .txt lists, .bat scripts, samples, and the default database.
- Copies the default database to C:db.
- Includes a post-install option to launch srvFalar_1.4.exe.
- Historical packages and binaries live under bin.
- buildlinux.sh keeps the Linux/deb packaging flow.

## Project Structure

- src/MNote2.lpr: Lazarus application entry point.
- src/main.pas: main form, tabs, editor, load/save, chat, history, tools, and overall integration.
- src/classes/item.pas: wraps each editable tab/item, Python execution, and configured scripts.
- src/classes/chatgpt.pas: HTTP client for AI providers.
- src/setmain.pas: global configuration and persistence in mnote.cfg.
- src/config.pas: configuration form for scripts, DLLs, AI, databases, and TCP tools.
- src/folders.pas: folder management, file analysis, .RIA/.PIA caches, and AI-based project analysis.
- src/ia.pas: AI interface with history, memory map, thinking notes, continuity, and actions.
- src/mquery2/mquery2.pas: database and SQL manager.
- src/sqlite_db.pas: SQLite wrapper.
- src/uprojetodb.pas: SQLite project loading and metadata.
- src/uPdfText.pas: simple native PDF text extraction.
- src/uDocText.pas: DOC/DOCX text extraction.
- src/toolsfalar and src/toolsouvir: TCP voice tools.
- db/projeto_padrao.db: default project database.
- screenshots: images used by the README.
- instalador: Windows packaging scripts.
- sample: Python, C, and image-processing examples.
- libs, sqlite, and tools: bundled external libraries and utilities.

## Requirements

### Development

- Lazarus IDE and Free Pascal Compiler.
- Lazarus packages used by the project, including LCL, SynEdit, TAChart, Indy, Zeos, RX, Python4Lazarus, lNet, and additional components listed in src/MNote2.lpi.
- Database libraries as needed: SQLite, MySQL client, and PostgreSQL/libpq/ODBC depending on configuration.
- Python 3 compatible with the configured DLL when Python execution is enabled.
- Inno Setup for the Windows installer.

### Usage

- Windows and Linux are the primary targets represented in the project.
- Classic .doc files require Windows with Microsoft Word installed.
- AI features require a configured token/provider or a compatible local server.
- Voice tools require the corresponding TCP service to be running.

## Configuration

The main configuration lives in mnote.cfg and is managed by TSetMain. It includes:

- Window position, size, and font.
- Recent files.
- run/debug/clean/install/compile scripts.
- AI token and provider.
- Local AI endpoint.
- Python, MySQL, and PostgreSQL DLL paths.
- MySQL, PostgreSQL, and SQLite connection details.
- ToolsFalar and ToolsOuvir activation and IP settings.
- Default folder and current project.

Note: mnote.cfg may contain AI tokens and database passwords. Protect it locally.

## Basic Usage

1. Open MNote2.
2. Configure DLL paths, scripts, databases, and AI in Settings.
3. Open or create files in the editor tabs.
4. Use the language menu to choose the file/code type.
5. Run Python directly or configured external scripts.
6. Open MQuery2 to connect to MySQL, PostgreSQL, or SQLite.
7. Use the AI panel for questions with history, memory map, and project analysis.
8. Use the folder manager to generate .RIA summaries and .PIA analyses.
9. Enable ToolsFalar/ToolsOuvir when you need TCP voice integration.

## Maintenance Notes

- The current codebase concentrates significant logic in main.pas, folders.pas, ia.pas, and mquery2.pas.
- The repository versions binaries, packages, and external libraries because the project ships artifacts alongside source.
- .RIA and .PIA files are used as AI cache/output and can be regenerated by the application.
- src/lib contains Lazarus/Free Pascal compilation artifacts for the project platforms.

## License

See the LICENSE file.
