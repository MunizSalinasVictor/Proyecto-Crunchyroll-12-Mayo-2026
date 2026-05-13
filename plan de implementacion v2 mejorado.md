# PROMPT:

- **Flujo de datos:**  
- Desde UI → evento → bloc/cubit → caso de uso → repositorio → fuente remota (API) o local (Hive/SQLite).
- **Escalabilidad:**  
- Inyección de dependencias (get_it, injectable)  
- Módulos feature-lazy loading  
- Multiplataforma: usar `dart:io` y condiciones para diferenciar web/móvil/desktop.

**Recomendaciones específicas:**  
- Clean Architecture + Bloc (con Freezed para eventos/estados)  
- Feature-first por dominio de negocio  
- Uso de casos de uso (UseCases) para lógica compleja

---

## 🗄️ 3. Base de Datos PostgreSQL

La base de datos ya está diseñada (`bdcrunchyroll.sql`) con UUIDs, relaciones, constraints, etc.

**Explica cómo integrar PostgreSQL con Flutter:**

- No se conecta directamente desde el cliente.  
- Se debe crear una **API REST (o GraphQL)** como middleware.  
- Recomendación:  
- **Backend:** Dart + Shelf / Dart Frog / Node.js (Express) o mejor **Supabase** (PostgreSQL + API automática) pero respetando estándares abiertos.  
- O bien **PostgREST** para generar API REST automática desde esquema.
- **Manejo de relaciones:**  
- Uso de joins, vistas o endpoints específicos para anidar datos (ej: anime con géneros y estudios).
- **Rendimiento:**  
- Índices (ya incluidos) + caché en frontend (Hive, Isar) para catálogo.
- **Seguridad:**  
- Row Level Security (RLS) si se usa Supabase.  
- Siempre usar Prepared Statements o un ORM (Dart `postgres` no en cliente).  
- Variables de entorno para conexiones.
- **Escalabilidad:**  
- Pool de conexiones, réplicas de lectura, paginación en respuestas.

**Entidades a considerar:**  
usuarios, animes, episodios, géneros, idiomas, estudios, suscripciones, favoritos (listas), historial.

---

## 🔥 4. Firebase como complemento

Firebase **no** reemplaza a PostgreSQL, lo complementa.

**Qué va en PostgreSQL:**  
- Datos maestro y transaccionales (usuarios, suscripciones, catálogo, reseñas, historial)

**Qué va en Firebase:**  
- **Authentication** (gestión de usuarios, pero sincronizando UUID con PostgreSQL)  
- **Storage** (imágenes de portada, thumbnails, avatares)  
- **Cloud Messaging** (notificaciones push)  
- **Analytics** (eventos de navegación, reproducción)  
- **Crashlytics** (reportes de fallos)  
- **Firestore** (opcional para mensajería en vivo, pero no esencial)

**Cuándo usar SQL vs Firebase:**  
- SQL → datos relacionales consistentes, reportes complejos, integridad transaccional.  
- Firebase → almacenamiento de archivos, notificaciones, análisis, autenticación delegada.

**Explica además:**  
- Cómo mantener consistencia entre Firebase Auth UUID y PostgreSQL.  
- Arquitectura de sincronización (Cloud Functions para actualizar metadatos).  
- Seguridad: reglas de Storage y Firestore.

---

## 📦 5. Dependencias Flutter (lista organizada)

Para cada categoría, lista de dependencias con: **propósito, ventajas, por qué usarla, alternativas**.

**Ejemplo de formato:**
| Categoría | Dependencia | Propósito | Ventajas | Alternativas |
|-----------|-------------|-----------|----------|---------------|
| Manejo de estado | flutter_bloc | Separación clara de eventos y estados | Testeable, escalable | Riverpod, Provider |

**Categorías obligatorias:**
- Manejo de estado (Bloc / Riverpod)
- Routing (go_router / auto_route)
- Firebase (firebase_core, firebase_auth, cloud_firestore, firebase_storage, firebase_messaging)
- Networking (dio, retrofit)
- Almacenamiento local (hive, isar, shared_preferences)
- Video player (video_player, chewie, media_kit)
- Animaciones (implicitly_animated, lottie, rive)
- Responsive UI (responsive_framework, flutter_screenutil)
- Shimmer / skeleton (shimmer, skeletonizer)
- Inyección de dependencias (get_it, injectable)
- Utilidades (equatable, freezed, json_serializable)

---

## 🔐 6. Sistema de Autenticación

**Explicar:**

- **Flujo completo:**  
Registro (email + contraseña) → Verificación email → Login → Sesión persistente → Logout
- **Uso de Firebase Auth** como proveedor de identidad, pero luego el backend PostgreSQL almacena el perfil vinculado al `uid` o a un `UUID` propio generado.
- **Manejo de sesiones:**  
- Tokens JWT emitidos por un backend propio (o usar Firebase Custom Tokens).  
- Almacenamiento seguro de tokens (Flutter Secure Storage).
- **Roles:**  
- `usuario_normal` y `administrador` (campo en tabla usuario de PostgreSQL).  
- Rutas protegidas según rol (middleware en router).
- **Panel de administrador:**  
- Autenticación de doble factor (opcional).  
- Solo accesible desde web/desktop.
- **Seguridad adicional:**  
- Rate limiting, captcha en registro, validación de email, expiración de sesión.

**Incluir recomendaciones sobre:**  
- JWT vs sesiones basadas en cookies  
- Protección contra CSRF, XSS  
- Refresh token rotation

---

## 🎬 7. Streaming y Multimedia

**Explicar:**

- **Almacenamiento de videos:**  
- No guardar en Firebase Storage (costoso). Usar CDN especializada (Mux, api.video, Cloudflare Stream) o S3 compatible.
- **Protocolo de streaming:** HLS (m3u8) para compatibilidad multiplataforma y adaptación de ancho de banda.
- **Reproductor en Flutter:**  
- `video_player` + `chewie` no soportan bien HLS en todas las plataformas.  
- Recomendar `media_kit` (basado en libmpv, soporta HLS, subtítulos, rendimiento).
- **Subtítulos y doblaje:**  
- Sincronización con el reproductor a través de pistas WebVTT.  
- URLs generadas por el backend (desde `subtitulo.url_archivo`).
- **Miniaturas:**  
- Almacenadas en Firebase Storage (optimizadas con `ffmpeg` para generar thumbnails).
- **Optimización:**  
- Caché de fragmentos HLS en disco (usando `flutter_cache_manager`).  
- Precarga de metadatos.  
- Modo offline (descarga de episodios enteros usando `dio` + almacenamiento cifrado).

---

## 🗺️ 8. Roadmap de Desarrollo (por fases)

**Fase 1: Planeación**  
- Definir alcance, épicas, historias de usuario.  
- Herramientas: Jira, Notion, Miro.  
- Buenas prácticas: reuniones semanales, documentación de ADR.

**Fase 2: Diseño UI/UX**  
- Wireframes (Figma) → Prototipo navegable → Design System.  
- Entregables: guía de estilos, assets, iconografía.

**Fase 3: Configuración del proyecto**  
- Crear repositorio, estructura de carpetas.  
- Configurar Firebase (proyectos por entorno: dev, staging, prod).  
- Configurar backend (API PostgreSQL + despliegue local con Docker).  
- Estándares: usar variables de entorno, scripts de automatización (Makefile).

**Fase 4: Arquitectura base**  
- Implementar la capa core (temas, routing, inyección de dependencias).  
- Definir modelos de dominio.  
- Configurar generación de código (build_runner).

**Fase 5: Base de datos y API**  
- Desplegar PostgreSQL con el esquema dado.  
- Crear API REST (PostgREST o Dart Frog) con endpoints para todas las operaciones.  
- Documentación con OpenAPI.

**Fase 6: Backend adicional**  
- Integración con Firebase Auth y Storage.  
- Cloud Functions para notificaciones.  
- Sistema de suscripciones y webhooks de pago (Stripe).

**Fase 7: Frontend por features**  
- Feature Auth (login, registro, recuperación).  
- Feature Catálogo (lista, detalles).  
- Feature Reproductor.  
- Feature Perfiles y listas.  
- Feature Búsqueda.  
- Feature Admin (web/desktop).

**Fase 8: Streaming y optimización multimedia**  
- Configurar CDN de video.  
- Integrar reproductor con HLS y subtítulos.  
- Implementar caché y modo offline.

**Fase 9: Testing**  
- Unit tests (bloc, use cases).  
- Widget tests.  
- Integration tests (uno por plataforma).  
- Pruebas de rendimiento y consumo de batería.

**Fase 10: Optimización y despliegue**  
- Bundle size (obfuscación, división por plataforma).  
- Soporte offline-first.  
- CI/CD (GitHub Actions) para Android, iOS, Web, Windows.  
- Canary releases.

**Cada fase debe incluir:** objetivos, tareas principales, herramientas, buenas prácticas y errores comunes a evitar.

---

## 📄 9. Formato de salida

- **Markdown exclusivamente.**  
- **Jerarquía clara** (encabezados, listas, tablas).  
- **Lenguaje profesional, sin código.**  
- **Orientado a producción real y escalabilidad.**  
- **Sección final:** Resumen de estándares aplicados y cómo se evita la "opción de producción" (portabilidad, configuración por entorno, uso de emuladores locales, etc.).

---

> ⚠️ **Recuerda:** No generes código, widgets, clases ni snippets.  
> Solo documentación estratégica y táctica.  
> Incluye las directrices de **Antigravity** (ligereza, eficiencia), **soporte multiplataforma** (Android, Web, Windows, iOS) y **estándares abiertos sin bloqueo de proveedor**.
