# PROMPT:

Actúa como un Arquitecto de Software Senior especializado en Flutter, Dart, Firebase y PostgreSQL.

Quiero desarrollar una aplicación multiplataforma inspirada en Crunchyroll utilizando:

- Flutter + Dart
- Firebase
- PostgreSQL como base de datos principal
- VS Code o Android Studio
- Arquitectura escalable y profesional

IMPORTANTE:
NO quiero código.
NO quiero widgets.
NO quiero clases.
NO quiero snippets.
NO quiero implementación técnica todavía.

ÚNICAMENTE quiero un PLAN DE IMPLEMENTACIÓN detallado en formato Markdown, organizado profesionalmente y explicado paso a paso.

La aplicación será una plataforma de streaming tipo Crunchyroll con:
- autenticación
- catálogo de anime
- episodios
- perfiles de usuario
- favoritos
- historial
- sistema premium
- búsqueda
- panel administrador
- notificaciones
- diseño responsive multiplataforma

---

# Diseño UI/UX

La interfaz debe estar inspirada visualmente en Crunchyroll:

- fondos gris oscuro / negro
- naranja intenso para hover y elementos activos
- texto blanco y naranja
- diseño moderno tipo streaming premium
- tarjetas elegantes
- animaciones fluidas
- transiciones llamativas
- hover effects para desktop/web
- microinteracciones
- skeleton loading
- responsive design

Quiero que expliques:
- sistema de diseño
- experiencia de usuario
- navegación
- estructura visual
- diseño mobile/web/desktop
- organización de pantallas
- flujo de navegación

---

# Arquitectura del Proyecto

Explica detalladamente:

- arquitectura recomendada
- estructura de carpetas
- organización modular
- separación frontend/backend
- manejo de estado
- flujo de datos
- escalabilidad
- arquitectura limpia

Incluye recomendaciones sobre:
- Clean Architecture
- Feature First
- Provider / Riverpod / Bloc

---

# Base de Datos PostgreSQL

La aplicación utilizará PostgreSQL como almacenamiento principal.

La base de datos ya cuenta con:
- UUIDs
- relaciones normalizadas
- tablas organizadas
- constraints
- relaciones entre entidades
- estructura escalable

Quiero que expliques:
- cómo integrar PostgreSQL con Flutter
- arquitectura recomendada para backend
- manejo de relaciones
- rendimiento
- optimización
- seguridad
- escalabilidad

Tomando en cuenta entidades como:
- usuarios
- animes
- géneros
- idiomas
- estudios
- planes de suscripción
- favoritos
- historial

---

# Firebase

Explica cómo utilizar Firebase como complemento de PostgreSQL.

Incluye:
- Authentication
- Firestore
- Storage
- Cloud Messaging
- Analytics
- Crashlytics

Explica:
- qué información debe ir en PostgreSQL
- qué información puede ir en Firebase
- cuándo usar SQL y cuándo Firebase

---

# Dependencias Flutter

Quiero una lista organizada de dependencias recomendadas para:

- manejo de estado
- routing
- Firebase
- PostgreSQL/API
- networking
- animaciones
- video player
- responsive UI
- caché
- autenticación
- loading effects
- shimmer effects
- seguridad

Para cada dependencia explica:
- para qué sirve
- ventajas
- por qué usarla
- posibles alternativas

---

# Sistema de Autenticación

Explica cómo debería funcionar:
- login
- registro
- recuperación de contraseña
- autenticación segura
- manejo de sesiones
- roles de usuario
- panel administrador

Incluye recomendaciones sobre:
- JWT
- Firebase Auth
- seguridad
- protección de rutas
- validaciones

---

# Streaming y Multimedia

Explica:
- cómo manejar videos
- almacenamiento multimedia
- streaming
- subtítulos
- thumbnails
- optimización multimedia
- rendimiento
- experiencia de reproducción

---

# Roadmap de Desarrollo

Quiero un procedimiento paso a paso para desarrollar la aplicación.

Divide el roadmap en fases:
1. Planeación
2. Diseño UI/UX
3. Configuración del proyecto
4. Arquitectura
5. Base de datos
6. Backend
7. Frontend
8. Autenticación
9. Streaming
10. Testing
11. Optimización

Cada fase debe incluir:
- objetivos
- tareas principales
- herramientas recomendadas
- buenas prácticas
- errores comunes

---

# Formato del Documento

El resultado debe estar:
- completamente en Markdown
- organizado profesionalmente
- bien estructurado
- detallado
- limpio visualmente
- orientado a producción real
- pensado para escalabilidad

NO GENERES CÓDIGO.
SOLO DOCUMENTACIÓN Y PLANIFICACIÓN.

# RESULTADO:

# 📋 Plan de Implementación: Plataforma de Streaming Tipo Crunchyroll

> **Nota del Arquitecto:** Este documento es una guía estratégica, arquitectónica y de planificación. No contiene código, widgets, clases ni snippets. Está diseñado para servir como hoja de ruta técnica para un equipo de desarrollo senior, enfocada en escalabilidad, mantenibilidad y experiencia de usuario premium.

---

## 1. 🎨 Diseño UI/UX

### Sistema de Diseño
- **Paleta Cromática:** Fondo principal en gris carbón/negro mate (`#0D0D0D` a `#1A1A1A`), acentos en naranja intenso (`#F47521`) para estados activos, hover y CTAs. Texto en blanco puro (`#FFFFFF`) y grises intermedios (`#B0B0B0`, `#888888`) para jerarquía secundaria.
- **Tipografía:** Sans-serif moderna, altamente legible en pantallas pequeñas y grandes. Pesos variables para títulos, metadatos y subtítulos.
- **Componentes Visuales:** Tarjetas con bordes sutiles, sombras difuminadas, overlays de gradiente oscuro para legibilidad sobre posters, badges para calidad/idiomas/subtítulos.
- **Microinteracciones:** Hover con elevación y cambio de opacidad en desktop, tap feedback háptico y visual en mobile, transiciones de desplazamiento suaves, indicadores de progreso animados.

### Experiencia de Usuario (UX)
- **Enfoque en Descubrimiento:** Scroll infinito optimizado, categorías destacadas, carruseles por género/estudio, sección "Continuar Viendo" visible inmediatamente tras autenticación.
- **Carga Perceptiva:** Skeleton loading en todas las vistas de catálogo, placeholders de imagen optimizados, precarga de metadatos críticos.
- **Feedback Inmediato:** Estados de carga, éxito y error claramente diferenciados. Toasts no intrusivos para acciones secundarias (favoritos, historial).

### Navegación y Estructura Visual
- **Mobile:** Barra inferior con 5 ítems principales (Inicio, Explorar, Búsqueda, Mi Lista, Perfil). Botón de reproducción flotante contextual en vistas de detalle.
- **Web/Desktop:** Barra lateral colapsable + top bar fija con búsqueda global y acceso rápido a perfil. Grid responsive de 3 a 6 columnas según viewport.
- **Organización de Pantallas:**
  - *Públicas:* Landing, Onboarding, Catálogo general, Detalle de anime (sin autenticación requerida para metadatos).
  - *Privadas:* Reproductor, Historial, Favoritos, Configuración, Panel Premium.
  - *Administrativas:* Gestión de contenido, reportes, moderación, configuración de planes.
- **Flujo de Navegación:** `Landing → Auth → Home (Personalizado) → Explorar → Detalle → Reproductor → (Auto-play/Recomendaciones)`. Deep linking habilitado para compartir episodios directamente.

---

## 2. 🏗️ Arquitectura del Proyecto

### Arquitectura Recomendada
- **Clean Architecture + Feature-First:** Separación estricta por capas (Presentación, Dominio, Datos) organizada verticalmente por funcionalidad. Cada feature es un módulo autónomo que depende únicamente de contratos abstractos.
- **Separación Frontend/Backend:** Flutter actúa exclusivamente como cliente visual. Toda lógica de negocio, persistencia relacional y orquestación multimedia reside en un backend dedicado.

### Estructura de Carpetas (Conceptual)
```
lib/
├── core/           (utilidades, constantes, temas, router, interceptores, DI)
├── features/       (auth, catalog, player, profile, favorites, history, admin, subscription)
│   ├── presentation/ (screens, viewmodels/notifiers, widgets UI)
│   ├── domain/       (entities, use cases, repositories interfaces)
│   └── data/         (repositories impl, remote sources, local sources, mappers)
└── shared/         (componentes reutilizables, diseño, helpers genéricos)
```

### Manejo de Estado y Flujo de Datos
- **Recomendación Principal:** Riverpod 2.0+ por su tipado seguro, inyección de dependencias nativa, testabilidad y arquitectura orientada a flujos asíncronos. Alternativa enterprise: Bloc/Cubit para flujos estrictos de eventos y estados explícitos.
- **Flujo de Datos:** `UI → Notifier/ViewModel → Use Case → Repository → DataSource (API/Backend) → Mappers → Entities → UI`. Las mutaciones viajan unidireccionalmente; los streams/reactive streams actualizan vistas específicas.

### Escalabilidad y Limpieza Arquitectónica
- **Inyección de Dependencias:** Contenedor global configurado en startup, con scopes por feature.
- **Contratos vs Implementaciones:** Interfaces en `domain/`, implementaciones en `data/`. Permite cambiar de API, base de datos o mock sin tocar UI.
- **Testing Boundaries:** Unit tests en use cases, widget tests en presentación, integration tests en flujos completos. La arquitectura facilita mocks y stubs.

---

## 3. 🗄️ Base de Datos PostgreSQL

### Integración con Flutter
- **Conexión Directa Prohibida:** Flutter nunca debe conectarse directamente a PostgreSQL en producción. Se implementa un **API Gateway/Backend** (REST o GraphQL) que expone endpoints seguros. Flutter consume estos endpoints mediante clientes generados o HTTP typed clients.
- **Backend Recomendado:** Node.js (Express/NestJS), Go (Gin/Fiber), Python (FastAPI) o Dart (Dart Frog). El backend gestiona pooling, validación, transacciones y caché.

### Arquitectura Recomendada para Backend
- **Patrón Repository + Service Layer:** Controllers/Endpoints → Services (lógica) → Repositories (PostgreSQL queries) → Mappers → DTOs → Cliente.
- **Read/Write Split:** Réplicas de lectura para catálogo y búsqueda. Base principal para transacciones (pagos, historial, favoritos).
- **Capa de Caché:** Redis frente a PostgreSQL para consultas frecuentes (top charts, metadatos de episodios, sesiones).

### Manejo de Relaciones y Entidades
- **Modelado:** UUIDs como claves primarias. Relaciones muchos-a-muchos mediante tablas intermedias (`anime_genres`, `user_favorites`, `watch_history`). Índices compuestos en `user_id + anime_id`, `studio_id`, `release_date`.
- **Integridad:** Constraints `NOT NULL`, `UNIQUE`, `FOREIGN KEY` con `ON DELETE CASCADE` o `SET NULL` según contexto. Triggers para auditoría y actualización de `updated_at`.
- **Entidades Clave:** `users`, `subscriptions`, `animes`, `episodes`, `genres`, `studios`, `languages`, `favorites`, `history`, `admin_roles`.

### Rendimiento, Optimización y Escalabilidad
- **Indexación Estratégica:** B-tree para búsqueda exacta, GIN/GiST para búsqueda full-text en títulos/descripciones, índices parciales para `is_active = true`.
- **Particionamiento:** Tablas de `history` y `logs` particionadas por mes/año. Archiving automático a almacenamiento frío.
- **Seguridad:** Row Level Security (RLS) para aislamiento multi-tenant interno. Roles con privilegios mínimos. Credenciales gestionadas por secret manager. Conexiones encriptadas (TLS). Prepared statements obligatorios.

---

## 4. 🔥 Integración y Rol de Firebase

### Estrategia Complementaria
Firebase no reemplaza a PostgreSQL. Actúa como capa de **servicios en tiempo real, infraestructura de mensajería y observabilidad**.

### Distribución de Responsabilidades
| Capa | PostgreSQL | Firebase |
|------|------------|----------|
| Datos Relacionales | ✅ Usuarios, planes, catálogo, favoritos, historial, transacciones | ❌ |
| Autenticación | ❌ | ✅ Social, email, phone, gestión de sesiones iniciales |
| Archivos Multimedia | ❌ | ✅ Thumbnails, banners, avatares (no videos principales) |
| Tiempo Real/Config | ❌ | ✅ Feature flags, estados de mantenimiento, notificaciones push |
| Métricas/Error Tracking | ❌ | ✅ Analytics, Crashlytics, Performance Monitoring |

### Cuándo Usar Cada Tecnología
- **Usar PostgreSQL:** Cualquier dato estructurado, transaccional, con relaciones complejas, reportes financieros, historial de consumo, planes de suscripción.
- **Usar Firebase:** Push notifications, configuración remota, autenticación rápida, métricas de uso, crash reporting, almacenamiento de assets estáticos ligeros.
- **Sincronización:** Al registrarse vía Firebase Auth, un webhook o backend process crea/actualiza el registro en PostgreSQL y vincula el `firebase_uid` con el `user_uuid`.

---

## 5. 📦 Ecosistema de Dependencias Recomendadas

| Categoría | Dependencia | Propósito | Ventajas | Alternativas |
|-----------|-------------|-----------|----------|--------------|
| **Estado** | `riverpod` + `riverpod_generator` | Gestión reactiva, inyección, flujos asíncronos | Tipado seguro, menos boilerplate, testing nativo | `bloc`, `flutter_modular`, `getx` |
| **Routing** | `go_router` | Navegación declarativa, deep linking, guards | Integración con estado, manejo de rutas anidadas, web/desktop support | `auto_route`, `fluro` |
| **Networking** | `dio` + `retrofit` | Cliente HTTP typed, interceptores, retry, logging | Abstracción limpia, generación automática de clientes, manejo robusto de errores | `http`, `chopper` |
| **Video Player** | `video_player` + `chewy` o `better_player` | Reproducción HLS/DASH, controles personalizados | Ligero, extensible, soporta Picture-in-Picture y audio background | `media_kit`, `flutter_vlc_player` |
| **Responsive** | `responsive_framework` o `flutter_screenutil` | Adaptación de layouts y tipografía por viewport | Breakpoints claros, escalado proporcional, soporta web/desktop | `sizer`, `device_preview` |
| **Caché/Imágenes** | `cached_network_image` + `hive` | Descarga y persistencia de assets y tokens offline | Gestión automática de caché, encriptación opcional, lectura rápida | `shared_preferences`, `isar`, `flutter_cache_manager` |
| **Loading/Shimmer** | `shimmer` + `flutter_spinkit` | Indicadores visuales de carga y placeholders | Alto rendimiento, personalizable, accesible | `loading_indicator`, `lottie` |
| **Seguridad** | `flutter_secure_storage` | Almacenamiento encriptado de tokens y credenciales | Integración con Keychain/Keystore nativo, resistente a root/jailbreak | `flutter_secure_storage_platform_interface` custom |
| **Firebase SDK** | `firebase_core`, `firebase_auth`, `firebase_messaging`, `firebase_analytics`, `firebase_crashlytics` | Integración oficial de servicios cloud | Mantenimiento Google, compatibilidad multiplataforma, monitoreo integrado | Custom backend wrappers (menos recomendado) |

---

## 6. 🔐 Sistema de Autenticación y Control de Acceso

### Flujos Principales
- **Registro/Login:** Firebase Auth maneja la verificación inicial. Tras éxito, el backend valida, crea/actualiza el perfil en PostgreSQL, asigna rol y devuelve un JWT personalizado.
- **Recuperación de Contraseña:** Firebase envía enlace seguro. El backend revoca sesiones activas si es necesario y fuerza revalidación tras reset.
- **Sesiones:** JWT de corta duración (15-30 min) + Refresh Token (7-30 días). Almacenamiento seguro en `flutter_secure_storage`. Renovación automática silenciosa antes de expiración.

### Seguridad y Validaciones
- **Protección de Rutas:** Middleware/Guards en router verifican validez de JWT, claims y suscripción activa antes de renderizar pantallas premium o admin.
- **Roles:** `guest`, `user`, `premium`, `admin`, `moderator`. Gestionados en PostgreSQL y reflejados como custom claims en Firebase para validación rápida.
- **Validaciones:** Cliente (formato, fuerza, duplicados locales) + Servidor (unicidad, existencia, integridad relacional). Rate limiting por IP/email para prevenir fuerza bruta.
- **Panel Administrador:** Acceso restringido por IP o 2FA. Logs de auditoría para cada acción sensible (edición de catálogo, cambio de roles, reembolsos).

---

## 7. 🎬 Streaming y Gestión Multimedia

### Arquitectura de Video
- **Formato:** HLS (`.m3u8`) y/o DASH para adaptive bitrate streaming. Fragmentación en múltiples calidades (360p a 1080p/4K).
- **Almacenamiento:** Buckets en Cloud Storage (AWS S3, Cloudflare R2, GCP). CDN global para distribución de baja latencia (CloudFront, Fastly, Akamai).
- **Reproducción:** Backend genera URLs firmadas con expiración (JWT en query o header). El cliente solicita manifiestos, selecciona calidad según red y buffer dinámicamente.

### Subtítulos, Thumbnails y Optimización
- **Subtítulos:** WebVTT o SRT separados. Sincronización manejada por reproductor. Soporte multiidioma con carga bajo demanda.
- **Thumbnails/Banners:** Generación automática en múltiples resoluciones. Formato WebP/AVIF. Lazy loading + prefetch inteligente en scroll.
- **Rendimiento:** Pre-carga de siguiente episodio, memoria de buffer optimizada, desactivación de descargas en redes móviles, soporte para Picture-in-Picture y audio background.
- **UX de Reproducción:** "Continuar donde lo dejaste", saltar intro/outro (marcadores en BD), calidad manual/auto, controles por gestos, historial de reproducción sincronizado en tiempo real (cada X segundos o al pausar).

---

## 8. 🗺️ Roadmap de Desarrollo

### Fase 1: Planeación
- **Objetivos:** Definir alcance, requisitos técnicos, presupuesto, equipo y métricas de éxito.
- **Tareas:** Documentar PRD, diagramas de flujo, modelo de negocio, selección de stack backend, definición de SLA.
- **Herramientas:** Notion, Miro, Figma, Jira/Linear.
- **Buenas Prácticas:** Validar supuestos con stakeholders, priorizar MVP, definir KPIs (retención, tiempo de reproducción, conversión premium).
- **Errores Comunes:** Alcance indefinido, ignorar limitaciones legales de licencias, subestimar costos de CDN/almacenamiento.

### Fase 2: Diseño UI/UX
- **Objetivos:** Entregar sistema de diseño completo y prototipos navegables.
- **Tareas:** Wireframes de baja/alta fidelidad, componente library, flujos de navegación, validación de accesibilidad (WCAG), diseño responsive.
- **Herramientas:** Figma, Storybook, LottieFiles.
- **Buenas Prácticas:** Design tokens desde día 1, testing de usabilidad con usuarios reales, iteraciones rápidas.
- **Errores Comunes:** Diseño desktop-first ignorando mobile, falta de estados de error/vacío, colores sin contraste suficiente.

### Fase 3: Configuración del Proyecto
- **Objetivos:** Estandarizar entorno de desarrollo y pipelines.
- **Tareas:** Configurar repositorio, linter, formatter, pre-commit hooks, CI/CD base, variables de entorno, estructura de carpetas.
- **Herramientas:** VS Code/Android Studio, Git, GitHub Actions/GitLab CI, `flutter_lints`, `very_good_cli`.
- **Buenas Prácticas:** Branch protection, commits semánticos, documentación de setup, Docker opcional para backend.
- **Errores Comunes:** Mezclar entornos, hardcodear claves, falta de hooks de calidad.

### Fase 4: Arquitectura
- **Objetivos:** Establecer patrones, inyección, routing base y contratos.
- **Tareas:** Implementar Clean Architecture, configurar DI container, definir routing base, crear mocks de API, establecer guías de nombrado y testing.
- **Herramientas:** Riverpod/Bloc, `go_router`, `mocktail`, `build_runner`.
- **Buenas Prácticas:** Contratos antes que implementaciones, separación estricta de responsabilidades, documentación de flujos.
- **Errores Comunes:** Acoplamiento entre capas, business logic en UI, over-engineering inicial.

### Fase 5: Base de Datos
- **Objetivos:** Desplegar PostgreSQL, migraciones, seed data y políticas de acceso.
- **Tareas:** Esquema completo, índices, relaciones, RLS, scripts de seed, backups automatizados, réplicas de lectura.
- **Herramientas:** PostgreSQL, pgAdmin/DBeaver, `prisma`/`flyway`/`alembic` (según backend), PgBouncer.
- **Buenas Prácticas:** Versionar migraciones, tests de integridad, monitoreo de queries lentas, políticas de retención.
- **Errores Comunes:** Índices faltantes, N+1 queries, falta de pooling, backups manuales.

### Fase 6: Backend
- **Objetivos:** API segura, endpoints REST/GraphQL, integración PostgreSQL, caché.
- **Tareas:** Controllers, services, repositories, middleware de auth, rate limiting, logging, Redis integration, documentación OpenAPI.
- **Herramientas:** NestJS/Express/Go/FastAPI, Swagger/Postman, Redis, JWT lib, OpenTelemetry.
- **Buenas Prácticas:** Validación estricta de entrada, idempotencia en POST, versionado de API, circuit breakers para servicios externos.
- **Errores Comunes:** Lógica en controllers, falta de paginación, exponer IDs internos, ignorar timeouts.

### Fase 7: Frontend
- **Objetivos:** Implementar pantallas, navegación, estado y consumo de API.
- **Tareas:** Maquetado UI, integración con notifiers/viewmodels, routing protegido, manejo de errores, skeletons, responsive breakpoints.
- **Herramientas:** Flutter SDK, `dio`, `riverpod`, `go_router`, `flutter_test`.
- **Buenas Prácticas:** Componentes reutilizables, gestión centralizada de errores, lazy loading de vistas, accesibilidad semántica.
- **Errores Comunes:** Rebuilds innecesarios, UI bloqueante, falta de manejo de estados de red, hardcodear dimensiones.

### Fase 8: Autenticación
- **Objetivos:** Flujos de registro/login, sesiones, roles y seguridad.
- **Tareas:** Integración Firebase Auth, sync con PostgreSQL, JWT issuance, refresh tokens, route guards, validaciones, panel admin acceso.
- **Herramientas:** `firebase_auth`, `flutter_secure_storage`, backend auth service, custom claims.
- **Buenas Prácticas:** Sesiones efímeras, renovación silenciosa, logout seguro (revoke), auditoría de accesos.
- **Errores Comunes:** Tokens en memoria plana, no validar expiración, permitir acceso sin claims correctos.

### Fase 9: Streaming
- **Objetivos:** Reproductor funcional, HLS/DASH, subtítulos, CDN, historial.
- **Tareas:** Integración video player, manifiesto fetching, adaptive bitrate, carga de WebVTT, sync de progreso, bookmarks, CDN config.
- **Herramientas:** `video_player`/`better_player`, HLS.js (web), AWS MediaConvert/Mux, CDN provider.
- **Buenas Prácticas:** Buffer optimizado, fallback de calidad, registro de eventos de reproducción, respeto a derechos de contenido.
- **Errores Comunes:** Streaming directo de archivos, no manejar reconexiones, ignorar ancho de banda variable.

### Fase 10: Testing
- **Objetivos:** Cobertura, estabilidad y calidad pre-lanzamiento.
- **Tareas:** Unit tests (use cases/repos), widget tests (UI crítica), integration tests (flujos completos), load testing backend, security audit.
- **Herramientas:** `flutter_test`, `integration_test`, `jest`/`pytest`, k6/Locust, OWASP ZAP.
- **Buenas Prácticas:** Pirámide de testing, mocks realistas, CI gating, reportes automatizados.
- **Errores Comunes:** Ignorar tests de integración, testing solo en happy path, falta de pruebas de red inestable.

### Fase 11: Optimización
- **Objetivos:** Rendimiento, tamaño de app, monitoreo y lanzamiento.
- **Tareas:** Tree shaking, obfuscación, reducción de assets, profiling de memoria/render, Crashlytics/Analytics live, A/B testing, deploy progresivo.
- **Herramientas:** `flutter analyze`, DevTools, Firebase Performance, Sentry/Crashlytics, App Store Connect/Play Console.
- **Buenas Prácticas:** Lanzamiento canary, monitoreo continuo, feedback loop rápido, documentación de incidencias.
- **Errores Comunes:** Lanzar sin métricas, ignorar warnings de linter, optimizar prematuramente, no planificar rollback.

---

## ✅ Conclusión y Próximos Pasos

Este plan establece una base técnica sólida, escalable y orientada a producción. La clave del éxito radica en:
1. Mantener la separación estricta entre cliente (Flutter) y backend (PostgreSQL + servicios cloud).
2. Utilizar Firebase exclusivamente para capacidades complementarias, no como almacén relacional.
3. Implementar Clean Architecture con Feature-First para garantizar mantenibilidad a largo plazo.
4. Priorizar la experiencia de reproducción y la seguridad de sesiones desde el primer día.

**Próximo paso recomendado:** Validar este plan con el equipo de desarrollo, ajustar prioridades según recursos disponibles, y comenzar la Fase 1 con un backlog priorizado y criterios de aceptación claros por cada fase.
