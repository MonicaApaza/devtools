-- Datos demo para PostgreSQL con el esquema existente:
-- users, categories, shortcuts y commands.
-- Usuario: Dana | Contraseña de demo: 456789
--
-- A diferencia de demo_cris_postgresql.sql, las fechas de creación se
-- reparten entre hace ~210 días y hoy, para simular un historial real de
-- uso y que la pantalla de Estadísticas tenga datos variados que mostrar.

BEGIN;

-- Crea a Dana solo si aún no existe. password_hash es el hash BCrypt de
-- "456789" (generado con BCrypt.Net-Next, la misma librería que usa
-- DevTools.Infrastructure/Authentication/PasswordHasher.cs), no texto plano,
-- porque AuthService.LoginAsync compara con BCrypt.Verify.
INSERT INTO users (id, username, password_hash, created_at)
SELECT
  'e0000000-0000-4000-8000-000000000001'::uuid,
  'Dana',
  '$2a$11$vbkdNIe89iXX66vOQGgtcuqh1XIDZyMfN2v3qI5hzhgL9Y8U20oSy',
  NOW() - INTERVAL '210 days'
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE username = 'Dana'
);

-- Borra exclusivamente los datos de demostración de Dana para que el script
-- se pueda ejecutar de nuevo sin duplicar información.
DELETE FROM commands
WHERE user_id = (SELECT id FROM users WHERE username = 'Dana');

DELETE FROM shortcuts
WHERE user_id = (SELECT id FROM users WHERE username = 'Dana');

DELETE FROM categories
WHERE user_id = (SELECT id FROM users WHERE username = 'Dana');

-- Categorías del usuario Dana (7 de shortcuts, 6 de comandos).
-- El tipo se guarda tal cual el enum CategoryType de C# ("Shortcut"/"Command"),
-- porque EF Core lo persiste con EnumToStringConverter (ver
-- DevToolsDbContext.cs) y el filtro en CategoryRepository compara con "=",
-- sensible a mayúsculas.
INSERT INTO categories (id, name, icon, type, user_id, created_at) VALUES
  ('f1000000-0000-4000-8000-000000000001'::uuid, 'VS Code', 'code', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000002'::uuid, 'Flutter', 'flutter', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000003'::uuid, 'Git', 'git', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000004'::uuid, 'Terminal', 'terminal', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000005'::uuid, 'Android Studio', 'developer_mode', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000006'::uuid, 'Navegador', 'browser', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000007'::uuid, 'Docker', 'cloud', 'Shortcut', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000008'::uuid, 'Flutter', 'flutter', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000009'::uuid, 'Git', 'git', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000010'::uuid, 'Terminal', 'terminal', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000011'::uuid, 'Pub', 'pub', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000012'::uuid, 'Docker', 'cloud', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days'),
  ('f1000000-0000-4000-8000-000000000013'::uuid, 'NPM', 'extension', 'Command', (SELECT id FROM users WHERE username = 'Dana'), NOW() - INTERVAL '210 days');

-- 24 shortcuts repartidos de forma desigual entre categorías, con fechas
-- de creación históricas (de hace 210 días a hoy) y 10 favoritos.
INSERT INTO shortcuts
(id, title, keys, description, tags, is_favorite, created_at, category_id, user_id)
VALUES
  -- VS Code (6)
  ('f2000000-0000-4000-8000-000000000001'::uuid, 'Duplicar línea', 'Ctrl + D', 'Duplica la línea actual.', 'edicion', TRUE, NOW() - INTERVAL '210 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000002'::uuid, 'Formatear documento', 'Shift + Alt + F', 'Aplica formato al archivo actual.', 'formato', TRUE, NOW() - INTERVAL '195 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000003'::uuid, 'Buscar en archivos', 'Ctrl + Shift + F', 'Busca texto en todo el proyecto.', 'busqueda', FALSE, NOW() - INTERVAL '160 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000004'::uuid, 'Renombrar símbolo', 'F2', 'Renombra variables y clases.', 'refactor', FALSE, NOW() - INTERVAL '120 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000005'::uuid, 'Paleta de comandos', 'Ctrl + Shift + P', 'Abre la paleta de comandos.', 'navegacion', TRUE, NOW() - INTERVAL '60 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000006'::uuid, 'Ir a definición', 'F12', 'Salta a la definición del símbolo.', 'navegacion', FALSE, NOW() - INTERVAL '10 days', 'f1000000-0000-4000-8000-000000000001'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Flutter (5)
  ('f2000000-0000-4000-8000-000000000007'::uuid, 'Hot reload', 'Ctrl + F5', 'Actualiza Flutter sin reiniciar.', 'debug', TRUE, NOW() - INTERVAL '200 days', 'f1000000-0000-4000-8000-000000000002'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000008'::uuid, 'Hot restart', 'Ctrl + Shift + F5', 'Reinicia la aplicación Flutter.', 'debug', FALSE, NOW() - INTERVAL '175 days', 'f1000000-0000-4000-8000-000000000002'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000009'::uuid, 'Abrir DevTools', 'Ctrl + Shift + I', 'Abre herramientas de depuración.', 'debug', TRUE, NOW() - INTERVAL '130 days', 'f1000000-0000-4000-8000-000000000002'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000010'::uuid, 'Formatear código Dart', 'Ctrl + Alt + L', 'Aplica el formato estándar de Dart.', 'formato', FALSE, NOW() - INTERVAL '55 days', 'f1000000-0000-4000-8000-000000000002'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000011'::uuid, 'Organizar imports', 'Ctrl + Alt + O', 'Ordena y limpia los imports.', 'edicion', FALSE, NOW() - INTERVAL '8 days', 'f1000000-0000-4000-8000-000000000002'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Git (4)
  ('f2000000-0000-4000-8000-000000000012'::uuid, 'Ver cambios', 'Ctrl + Shift + G', 'Abre control de versiones.', 'git', TRUE, NOW() - INTERVAL '190 days', 'f1000000-0000-4000-8000-000000000003'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000013'::uuid, 'Confirmar cambios', 'Ctrl + Enter', 'Confirma un commit.', 'git', FALSE, NOW() - INTERVAL '140 days', 'f1000000-0000-4000-8000-000000000003'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000014'::uuid, 'Ver historial', 'Ctrl + H', 'Muestra el historial de commits.', 'git', FALSE, NOW() - INTERVAL '45 days', 'f1000000-0000-4000-8000-000000000003'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000015'::uuid, 'Cambiar de rama', 'Ctrl + Shift + B', 'Abre el selector de ramas.', 'git', TRUE, NOW() - INTERVAL '5 days', 'f1000000-0000-4000-8000-000000000003'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Terminal (3)
  ('f2000000-0000-4000-8000-000000000016'::uuid, 'Limpiar terminal', 'Ctrl + L', 'Limpia la consola activa.', 'terminal', FALSE, NOW() - INTERVAL '170 days', 'f1000000-0000-4000-8000-000000000004'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000017'::uuid, 'Buscar historial', 'Ctrl + R', 'Busca comandos ejecutados.', 'terminal', TRUE, NOW() - INTERVAL '90 days', 'f1000000-0000-4000-8000-000000000004'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000018'::uuid, 'Nueva pestaña', 'Ctrl + Shift + T', 'Abre una nueva pestaña de terminal.', 'terminal', FALSE, NOW() - INTERVAL '3 days', 'f1000000-0000-4000-8000-000000000004'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Android Studio (3)
  ('f2000000-0000-4000-8000-000000000019'::uuid, 'Ejecutar aplicación', 'Shift + F10', 'Ejecuta desde Android Studio.', 'android', FALSE, NOW() - INTERVAL '150 days', 'f1000000-0000-4000-8000-000000000005'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000020'::uuid, 'Abrir Logcat', 'Alt + 6', 'Muestra registros Android.', 'android', FALSE, NOW() - INTERVAL '70 days', 'f1000000-0000-4000-8000-000000000005'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000021'::uuid, 'Depurar aplicación', 'Shift + F9', 'Inicia una sesión de depuración.', 'android', TRUE, NOW() - INTERVAL '15 days', 'f1000000-0000-4000-8000-000000000005'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Navegador (2)
  ('f2000000-0000-4000-8000-000000000022'::uuid, 'Inspeccionar elemento', 'Ctrl + Shift + C', 'Activa el inspector web.', 'web', TRUE, NOW() - INTERVAL '100 days', 'f1000000-0000-4000-8000-000000000006'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f2000000-0000-4000-8000-000000000023'::uuid, 'Abrir pestaña privada', 'Ctrl + Shift + N', 'Abre una ventana de incógnito.', 'web', FALSE, NOW() - INTERVAL '20 days', 'f1000000-0000-4000-8000-000000000006'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Docker (1)
  ('f2000000-0000-4000-8000-000000000024'::uuid, 'Panel de contenedores', 'Ctrl + Shift + D', 'Muestra el panel de Docker Desktop.', 'docker', FALSE, NOW() - INTERVAL '12 days', 'f1000000-0000-4000-8000-000000000007'::uuid, (SELECT id FROM users WHERE username = 'Dana'));

-- 24 commands repartidos entre categorías, con usage_count variado (2 a 51)
-- y fechas de creación históricas, para que las estadísticas muestren datos
-- realistas y variados.
INSERT INTO commands
(id, title, command_text, description, tags, is_favorite, usage_count, created_at, category_id, user_id)
VALUES
  -- Flutter (6)
  ('f3000000-0000-4000-8000-000000000001'::uuid, 'Ejecutar Flutter', 'flutter run', 'Compila y ejecuta la aplicación.', 'flutter', TRUE, 42, NOW() - INTERVAL '205 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000002'::uuid, 'Instalar dependencias', 'flutter pub get', 'Descarga las dependencias.', 'flutter', TRUE, 35, NOW() - INTERVAL '190 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000003'::uuid, 'Ejecutar pruebas', 'flutter test', 'Ejecuta pruebas unitarias.', 'flutter', FALSE, 18, NOW() - INTERVAL '150 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000004'::uuid, 'Generar APK', 'flutter build apk --release', 'Genera un APK de producción.', 'build', TRUE, 9, NOW() - INTERVAL '100 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000005'::uuid, 'Analizar código', 'flutter analyze', 'Revisa el código en busca de problemas.', 'flutter', FALSE, 14, NOW() - INTERVAL '50 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000006'::uuid, 'Limpiar build', 'flutter clean', 'Elimina los artefactos de compilación.', 'flutter', FALSE, 6, NOW() - INTERVAL '7 days', 'f1000000-0000-4000-8000-000000000008'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Git (6)
  ('f3000000-0000-4000-8000-000000000007'::uuid, 'Estado del repositorio', 'git status', 'Muestra cambios locales.', 'git', TRUE, 51, NOW() - INTERVAL '200 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000008'::uuid, 'Agregar cambios', 'git add .', 'Prepara todos los cambios.', 'git', FALSE, 40, NOW() - INTERVAL '180 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000009'::uuid, 'Crear commit', 'git commit -m "mensaje"', 'Crea un commit.', 'git', TRUE, 33, NOW() - INTERVAL '130 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000010'::uuid, 'Enviar cambios', 'git push origin main', 'Envía commits al remoto.', 'git', FALSE, 22, NOW() - INTERVAL '90 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000011'::uuid, 'Traer cambios', 'git pull origin main', 'Trae los cambios del remoto.', 'git', TRUE, 19, NOW() - INTERVAL '40 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000012'::uuid, 'Ver diferencias', 'git diff', 'Muestra los cambios sin confirmar.', 'git', FALSE, 8, NOW() - INTERVAL '6 days', 'f1000000-0000-4000-8000-000000000009'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Terminal (5)
  ('f3000000-0000-4000-8000-000000000013'::uuid, 'Listar archivos', 'ls -la', 'Lista archivos incluidos los ocultos.', 'terminal', FALSE, 44, NOW() - INTERVAL '195 days', 'f1000000-0000-4000-8000-000000000010'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000014'::uuid, 'Ver directorio actual', 'pwd', 'Muestra la ruta actual.', 'terminal', FALSE, 30, NOW() - INTERVAL '160 days', 'f1000000-0000-4000-8000-000000000010'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000015'::uuid, 'Limpiar consola', 'clear', 'Limpia la terminal.', 'terminal', FALSE, 25, NOW() - INTERVAL '110 days', 'f1000000-0000-4000-8000-000000000010'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000016'::uuid, 'Buscar en archivos', 'grep -r "texto" .', 'Busca texto en todos los archivos.', 'terminal', TRUE, 12, NOW() - INTERVAL '35 days', 'f1000000-0000-4000-8000-000000000010'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000017'::uuid, 'Ver procesos activos', 'ps aux', 'Lista los procesos en ejecución.', 'terminal', FALSE, 5, NOW() - INTERVAL '4 days', 'f1000000-0000-4000-8000-000000000010'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Pub (3)
  ('f3000000-0000-4000-8000-000000000018'::uuid, 'Actualizar paquetes', 'dart pub upgrade', 'Actualiza dependencias Dart.', 'pub', TRUE, 16, NOW() - INTERVAL '145 days', 'f1000000-0000-4000-8000-000000000011'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000019'::uuid, 'Ver paquetes desactualizados', 'dart pub outdated', 'Muestra dependencias con nuevas versiones.', 'pub', FALSE, 7, NOW() - INTERVAL '60 days', 'f1000000-0000-4000-8000-000000000011'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000020'::uuid, 'Publicar paquete', 'dart pub publish --dry-run', 'Simula la publicación de un paquete.', 'pub', FALSE, 2, NOW() - INTERVAL '9 days', 'f1000000-0000-4000-8000-000000000011'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- Docker (2)
  ('f3000000-0000-4000-8000-000000000021'::uuid, 'Ver contenedores', 'docker ps', 'Lista los contenedores activos.', 'docker', TRUE, 20, NOW() - INTERVAL '80 days', 'f1000000-0000-4000-8000-000000000012'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000022'::uuid, 'Construir imagen', 'docker build -t app .', 'Construye una imagen Docker.', 'docker', FALSE, 11, NOW() - INTERVAL '25 days', 'f1000000-0000-4000-8000-000000000012'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  -- NPM (2)
  ('f3000000-0000-4000-8000-000000000023'::uuid, 'Instalar dependencias npm', 'npm install', 'Instala las dependencias del proyecto.', 'npm', FALSE, 15, NOW() - INTERVAL '65 days', 'f1000000-0000-4000-8000-000000000013'::uuid, (SELECT id FROM users WHERE username = 'Dana')),
  ('f3000000-0000-4000-8000-000000000024'::uuid, 'Ejecutar en desarrollo', 'npm run dev', 'Levanta el servidor de desarrollo.', 'npm', TRUE, 28, NOW() - INTERVAL '15 days', 'f1000000-0000-4000-8000-000000000013'::uuid, (SELECT id FROM users WHERE username = 'Dana'));

COMMIT;
