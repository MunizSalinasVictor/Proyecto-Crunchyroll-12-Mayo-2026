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

# RESULTADO:

# Documento de Arquitectura y Estrategia Técnica — Plataforma Crunchyroll-like

---

# Estructura de archivos:

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── di/
│       └── injection.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── pages/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── widgets/
│   │   │   └── login_form.dart
│   │   └── models/
│   │       └── user_model.dart
│   ├── catalog/
│   │   ├── bloc/
│   │   │   ├── catalog_bloc.dart
│   │   │   ├── catalog_event.dart
│   │   │   └── catalog_state.dart
│   │   ├── pages/
│   │   │   ├── home_page.dart
│   │   │   └── anime_detail_page.dart
│   │   ├── widgets/
│   │   │   ├── anime_card.dart
│   │   │   └── episode_tile.dart
│   │   └── models/
│   │       ├── anime_model.dart
│   │       ├── episode_model.dart
│   │       └── genre_model.dart
│   ├── player/
│   │   ├── bloc/
│   │   │   ├── player_bloc.dart
│   │   │   ├── player_event.dart
│   │   │   └── player_state.dart
│   │   ├── pages/
│   │   │   └── player_page.dart
│   │   ├── widgets/
│   │   │   └── video_controls.dart
│   │   └── models/
│   │       ├── video_source_model.dart
│   │       └── subtitle_model.dart
│   ├── favorites/
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   └── favorites_page.dart
│   │   └── models/
│   │       └── favorite_model.dart
│   ├── history/
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   └── history_page.dart
│   │   └── models/
│   │       └── watch_history_model.dart
│   ├── profile/
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   └── profile_page.dart
│   │   └── models/
│   │       └── profile_model.dart
│   ├── subscription/
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   └── plans_page.dart
│   │   └── models/
│   │       └── subscription_model.dart
│   ├── search/
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   └── search_page.dart
│   │   └── models/
│   │       └── search_result_model.dart
│   └── admin/
│       ├── bloc/
│       ├── pages/
│       │   ├── admin_dashboard_page.dart
│       │   └── manage_animes_page.dart
│       └── models/
│           └── admin_stats_model.dart
└── shared/
    ├── widgets/
    │   ├── error_display.dart
    │   └── loading_indicator.dart
    └── models/
        └── api_response.dart
```



## 1. Flujo de Datos

La aplicación sigue una arquitectura en capas orientada a la unidireccionalidad y la inmutabilidad de los datos.

**Capa de presentación**  
El usuario interactúa con la interfaz (UI). Esta envía eventos (intenciones del usuario) al gestor de estado.

**Capa de lógica de negocio (BLoC/Cubit)**  
El BLoC recibe eventos, los transforma en nuevos estados mediante operaciones síncronas o asíncronas, y delega la ejecución de la lógica a casos de uso.

**Capa de dominio**  
Los casos de uso encapsulan reglas de negocio. Se comunican con repositorios a través de contratos (interfaces), sin conocer la implementación concreta.

**Capa de datos**  
Los repositorios implementan las interfaces y deciden de dónde obtener los datos:
- **Remoto**: se conectan a una API REST (o GraphQL) mediante clientes HTTP (Dio).
- **Local**: acceden a bases de datos ligeras (Hive/Isar) para caché, persistencia de sesión o modo offline.

El flujo completo es:  
`UI → evento → BLoC/Cubit → caso de uso → repositorio → API remota / fuente local`.

---

## 2. Escalabilidad

Para que el proyecto pueda crecer sin deuda técnica, se aplican estas estrategias desde el inicio:

- **Inyección de dependencias (DI)**  
  Se usa `get_it` junto con `injectable` para registrar y resolver dependencias. Permite reemplazar implementaciones reales por mock en pruebas y configurar entornos distintos fácilmente.

- **Módulos feature-lazy loading**  
  Cada funcionalidad se aísla en un paquete o módulo, con carga diferida cuando sea posible. Así se reduce el tamaño inicial de la aplicación y se mejora el rendimiento de arranque.

- **Soporte multiplataforma real**  
  Se utiliza `dart:io` para importar condicionalmente implementaciones específicas de plataforma (web, móvil, escritorio). Las capas de datos y presentación adaptan comportamientos según la plataforma mediante abstracciones.

- **Separación de entornos**  
  Configuración por variables de entorno (dev, staging, prod) y archivos de configuración diferenciados, evitando valores fijos en código. Se utilizan emuladores y entornos locales para desarrollo, lo que reduce la dependencia de servicios externos en etapas tempranas.

---

## 3. Recomendaciones Específicas

- **Clean Architecture + BLoC con Freezed**  
  - Cada feature contiene capas de presentación, dominio y datos.  
  - Los eventos y estados se modelan con `freezed`, obteniendo inmutabilidad, copyWith y pattern matching de manera automática.  
  - BLoC se encarga de la lógica de presentación, manteniendo la vista reactiva y testeable.

- **Organización Feature‑first por dominio de negocio**  
  La estructura de carpetas refleja dominios (auth, catálogo, reproductor, administración), y dentro de cada uno se replican las capas. Así, los equipos pueden trabajar en paralelo y los cambios se aíslan.

- **Uso obligatorio de casos de uso (UseCases)**  
  Toda lógica de negocio que no sea trivial se encapsula en un caso de uso. Esto facilita las pruebas unitarias, el reúso y la documentación de los requisitos funcionales directamente en el código.

---

## 4. Integración con PostgreSQL

La base de datos ya está diseñada (archivo `bdcrunchyroll.sql`) y usa UUIDs, relaciones y restricciones de integridad. La conexión directa desde Flutter no es viable por seguridad ni arquitectura.

### Backend intermediario — API REST o GraphQL
Se debe desplegar un servicio backend que actúe de puente entre el cliente y PostgreSQL. Opciones recomendadas respetando estándares abiertos y portabilidad:

- **PostgREST**  
  Genera automáticamente una API REST a partir del esquema de PostgreSQL. Es liviano, de alto rendimiento y elimina la escritura de controladores repetitivos. Ideal si se quiere mantener un backend mínimo y sin bloqueo de proveedor.

- **Dart Frog**  
  Framework minimalista en Dart para construir APIs REST. Permite escribir controladores propios, aprovechar las mismas habilidades de Dart del equipo y desplegar en entornos serverless (como Cloud Run). Integración natural con PostgreSQL usando paquetes seguros del lado servidor (`postgres`).

- **Supabase**  
  Proporciona una API REST/GraphQL automática sobre PostgreSQL con Row Level Security (RLS). Es una opción productiva, pero debe evaluarse el posible bloqueo de proveedor. Se mitiga usando siempre la interfaz estándar SQL y limitando las funcionalidades exclusivas a servicios bien encapsulados.

### Manejo de relaciones y rendimiento
- **Endpoints enriquecidos**  
  Para evitar múltiples llamadas, se crearán endpoints que devuelvan datos anidados (anime con géneros y estudios) mediante joins o vistas materializadas. La capa de repositorio en Flutter consumirá estos DTOs optimizados.
- **Índices**  
  El esquema ya incluye índices en columnas de búsqueda. Se revisarán periódicamente con logs de consultas lentas.
- **Caché en frontend**  
  Catálogo, géneros y configuraciones se cachean localmente usando Hive/Isar para reducir tráfico y permitir modo offline.
- **Paginación**  
  Todas las listas (animes, episodios, historial) se sirven con cursores o paginación basada en offset, implementada en el backend. En Flutter se usa scroll infinito combinado con el BLoC.

### Seguridad
- **Autenticación**  
  Los clientes nunca reciben credenciales de base de datos. Se utiliza autenticación delegada (Firebase Auth) y se pasa un token JWT al backend propio, que valida y extrae el UUID del usuario.
- **Autorización**  
  Si se usa Supabase, las políticas de RLS garantizan que los usuarios solo accedan a sus propios datos. Con PostgREST se puede configurar JWT y RLS igualmente, o delegar autorización en el backend Dart Frog.
- **Sanitización**  
  Todas las consultas usan parámetros preparados (nunca concatenación de strings) para evitar inyección SQL.
- **Configuración**  
  Las cadenas de conexión y secretos se almacenan en variables de entorno del servidor, nunca en el cliente.

### Escalabilidad del lado servidor
- **Pool de conexiones**  
  Gestión eficiente desde el backend (pgBouncer o el propio pool del driver).
- **Réplicas de lectura**  
  Consultas de catálogo pueden dirigirse a réplicas para aliviar la instancia principal.
- **Arquitectura serverless**  
  Dart Frog sobre Cloud Run o equivalentes permite escalar a cero y manejar picos de tráfico sin aprovisionamiento manual.

### Entidades principales
- **usuarios** – perfiles, suscripciones, roles.  
- **animes** – metadatos, estado de emisión, calificación.  
- **episodios** – vinculación con temporadas, URLs de video en CDN.  
- **géneros** y **estudios** – tablas de referencia.  
- **idiomas** – para doblajes y subtítulos.  
- **suscripciones** – planes, pagos, periodo de vigencia.  
- **favoritos** (listas personales) e **historial de visualización** – asociados al usuario.

---

## 5. Firebase como complemento

Firebase no reemplaza a PostgreSQL; cada herramienta se usa donde ofrece mayor valor.

### Responsabilidades divididas

| Función               | Dónde se almacena / procesa            | Razón |
|-----------------------|----------------------------------------|-------|
| Datos transaccionales (usuarios, suscripciones, catálogo) | PostgreSQL | Consistencia relacional, reportes complejos, integridad ACID. |
| Autenticación         | Firebase Auth                          | Gestión delegada de identidades, múltiples proveedores sociales, seguridad verificada. |
| Archivos multimedia (avatares, carátulas, thumbnails) | Firebase Storage / Cloud Storage      | Escalabilidad y CDN incorporado para imágenes, control de acceso seguro. |
| Notificaciones push   | Firebase Cloud Messaging (FCM)         | Multiplataforma, segmentación, entrega confiable. |
| Analítica y eventos   | Firebase Analytics + Crashlytics       | Informes embebidos, visualización de embudos, bajo costo de integración. |
| Mensajería en tiempo real (opcional) | Firestore (en modo limitado) si fuera necesario, pero no es esencial y se puede evitar para no duplicar datos. |

### Sincronización de identidad
- En registro/login, Firebase Auth genera un `uid`. Inmediatamente, un Cloud Function (o un paso en el backend) crea/actualiza un registro en PostgreSQL con ese mismo `uid` como UUID del usuario.
- El backend valida el JWT de Firebase en cada petición y extrae el `uid` para buscar el perfil en PostgreSQL. Así se mantiene consistencia sin replicar datos personales en Firestore.

### Arquitectura de sincronización y metadatos
- Cuando se sube una carátula a Firebase Storage, un Cloud Function puede dispararse para generar miniaturas y actualizar la URL en PostgreSQL (campo `url_imagen`). Esto mantiene el catálogo siempre actualizado.
- Para notificaciones (nuevo episodio), el backend programado consulta la base y envía mensajes a través de FCM.

### Seguridad en Firebase
- **Storage**  
  Reglas basadas en autenticación y metadata del usuario. Sólo administradores pueden cargar imágenes de animes; cada usuario puede subir su avatar.
- **Firestore**  
  Si se usa, reglas estrictas que coincidan con los UUIDs, nunca acceso abierto.
- **Claves de API**  
  Restricciones por dominio/paquete en la consola de Firebase para evitar uso no autorizado.

---

## 6. Dependencias Flutter organizadas

| Categoría               | Dependencia                    | Propósito                                                               | Ventajas                                                                                             | Alternativas                       |
|-------------------------|--------------------------------|-------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|------------------------------------|
| **Manejo de estado**    | `flutter_bloc`                 | Gestión de estado con eventos/estados y separación clara de la UI.     | Altamente testeable, escalable, documentación madura, integración con freezed.                       | Riverpod, Provider                 |
| **Modelado inmutable**  | `freezed`                      | Generar clases inmutables con copyWith y pattern matching.              | Reduce boilerplate, union types para estados, perfecta sinergia con BLoC.                           | `equatable` (más simple)           |
| **Routing**             | `go_router`                    | Navegación declarativa y basada en URL, con soporte para deep links.    | Multiplataforma real, redirecciones y guardias de autenticación, integración con el sistema operativo. | `auto_route` (generación de código) |
| **Firebase**            | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging` | Integración con los servicios Firebase seleccionados.                  | SDK oficial, mantenido por Google, amplia comunidad, compatibilidad multiplataforma.               | Supabase SDK, Auth0, AWS Amplify   |
| **Networking**          | `dio`                          | Cliente HTTP avanzado con interceptores, transformers y cancelación.   | Rendimiento, manejo de timeouts, reintentos, soporte para isolates en descargas.                    | `http`, `chopper`                  |
| **Generación de API**   | `retrofit`                     | Generador de clientes API tipados a partir de anotaciones en interfaces. | Evita errores manuales, fácil mantenimiento, trabaja con Dio.                                      | `chopper`                          |
| **Almacenamiento local**| `hive`                         | Base de datos clave-valor rápida y ligera para caché y preferencias.    | Escrita en Dart puro, sin dependencias nativas, ideal para catálogo offline.                        | `isar` (consultas avanzadas), `shared_preferences` (solo ajustes) |
| **Video player**        | `media_kit`                    | Reproductor multimedia basado en libmpv/libmdk con soporte HLS nativo. | Rendimiento superior, subtítulos WebVTT, múltiples pistas, multiplataforma real (incluye escritorio). | `video_player` + `chewie` (limitado en HLS) |
| **Animaciones**         | `lottie`                       | Animaciones vectoriales complejas exportadas desde After Effects.      | Ligereza (json), fluidez a 60fps, amplia librería pública, soporta interactividad.                 | `rive` (más potente, estado)       |
| **UI responsiva**       | `flutter_screenutil`           | Adaptación de tamaños de fuente, márgenes y widgets a distintos tamaños de pantalla. | Simplifica la escalabilidad visual en móviles y tablets.                                           | `responsive_framework`            |
| **Efecto de carga**     | `shimmer`                      | Marcadores de carga brillantes para texto e imágenes.                  | Ligero, personalizable, mejora la percepción de velocidad.                                         | `skeletonizer` (más genérico)      |
| **Inyección de dependencias** | `get_it` + `injectable`  | Localizador de servicios con generación de código para registro automático. | Desacopla módulos, facilita testing, sin código boilerplate manual.                               | `riverpod` (también DI)            |
| **Utilidades**          | `json_serializable`            | Generación de serialización JSON a partir de anotaciones.               | Integración total con build_runner, reduce errores y código manual.                                | `dart_mappable`                    |

---

## 7. Sistema de Autenticación

### Flujo completo
1. **Registro**  
   El usuario proporciona email y contraseña (u OAuth con Google/Apple). Firebase Auth crea la cuenta y envía un correo de verificación.

2. **Verificación de email**  
   Hasta que el email no esté verificado, las funcionalidades premium quedan bloqueadas. Se muestra una pantalla de reenvío de verificación.

3. **Login**  
   Se autentica contra Firebase Auth. A cambio se obtiene un token ID (JWT) de Firebase que el cliente envía a **nuestro backend**.

4. **Vinculación con PostgreSQL**  
   El backend verifica la firma del token, extrae el `uid` y lo utiliza para identificar al usuario en la tabla `usuarios` (UUID). Si no existe, se crea un nuevo perfil con valores por defecto y rol `usuario_normal`.

5. **Sesión persistente**  
   El cliente almacena de forma segura el token de refresco (Firebase gestiona esto automáticamente) y, opcionalmente, un JWT propio si se requiere un backend con estado. El refresco ocurre en segundo plano sin intervención del usuario.

6. **Logout**  
   Se invalida la sesión en Firebase y se borra cualquier token almacenado localmente. El estado de la UI vuelve a la pantalla de login.

### Roles y autorización
- Dos roles definidos en PostgreSQL: `usuario_normal` y `administrador`.
- El backend retorna el rol junto con el perfil. El enrutador (`go_router`) utiliza guardias que redirigen al login o a una pantalla de acceso denegado si el rol no coincide con la ruta.
- El panel de administración solo está habilitado en plataformas web/escritorio y requiere rol `administrador`. Opcionalmente se puede exigir segundo factor de autenticación (2FA) mediante un código temporal.

### Seguridad de la sesión
- **JWT vs cookies**  
  Se prefiere JWT para el backend propio (estándar abierto, sin estado, fácil de escalar). El cliente envía el token en el header `Authorization: Bearer <token>`. Para mitigar riesgos, se emplea:
  - **Refresh token rotation**  
    Cada vez que se usa un refresh token, se emite uno nuevo y se invalida el anterior.
  - **Expiración corta** del access token (15-30 min).
  - **Almacenamiento** en `flutter_secure_storage` (Keychain/Keystore en móviles, almacenamiento cifrado en web/escritorio) y nunca en `localStorage` o `shared_preferences`.
- **Protección contra CSRF**  
  Al usar JWT en headers y no cookies, el riesgo de CSRF es casi nulo. Si se optara por cookies, se implementaría el atributo `SameSite=Strict`.
- **Protección contra XSS**  
  La aplicación Flutter escapa por defecto. Se debe asegurar que el backend sanitiza cualquier contenido inyectado que pueda mostrarse en WebView.

### Medidas adicionales
- **Rate limiting** en los endpoints de login y registro para prevenir fuerza bruta.
- **CAPTCHA** (por ejemplo, reCAPTCHA v3) en el formulario de registro para evitar bots.
- **Validación de emails** temporales, exigiendo verificación antes de acceder a datos sensibles.

---

## 8. Streaming y Multimedia

### Almacenamiento de video
Los archivos de video **no** se guardan en Firebase Storage por su elevado coste y falta de optimización para streaming. En su lugar se utiliza una **CDN especializada** o un almacenamiento de objetos compatible con S3, junto con un servicio de transcoding:

- **Opciones abiertas y sin bloqueo**:  
  - **Cloudflare Stream** o **api.video** (usan protocolos estándar).  
  - **Mux** (API potente para HLS).  
  - **Almacenamiento S3‑compatible** (MinIO, AWS S3, Backblaze B2) más una función de transcoding propia con FFmpeg, para mantener el control completo.

### Protocolo de streaming
Se adopta **HLS (HTTP Live Streaming)** con codificación en múltiples bitrates (ABR). El reproductor selecciona automáticamente la calidad según la conexión. HLS es compatible con todas las plataformas objetivo y permite cifrado con claves si se requiere DRM básico.

### Reproductor en Flutter
- **`media_kit`** es la elección principal porque utiliza `libmpv` (motor de reproductores como VLC) y tiene:
  - Soporte nativo de HLS y DASH sin plugins adicionales.
  - Sincronización de múltiples pistas de subtítulos (WebVTT).
  - Manejo eficiente de audio y video en segundo plano.
  - Funcionamiento comprobado en Android, iOS, macOS, Windows y Linux.
- Se descarta `video_player` + `chewie` por limitaciones en algunas plataformas y falta de soporte robusto de HLS sin parches.

### Subtítulos y doblaje
- Los archivos de subtítulos se almacenan en el CDN/S3 y se referencian en la tabla `subtitulo` (url_archivo). El backend expone las URLs protegidas o firmadas.
- El reproductor carga las pistas de subtítulos desde esas URLs y las muestra en sincronía.
- Para doblajes, cada versión de audio es una pista alternativa en el manifiesto HLS. La tabla `idioma` y las relaciones permiten asociar pistas de audio con idiomas específicos.

### Miniaturas y carátulas
- Las imágenes (carátulas, avatares, thumbnails de episodios) se almacenan en **Firebase Storage** porque no requieren streaming, son de bajo volumen y se benefician de la CDN de Google.
- Los thumbnails se generan automáticamente mediante Cloud Functions o un microservicio que utiliza `ffmpeg` para extraer fotogramas y subirlos a Storage.

### Optimización y modo offline
- **Caché de fragmentos HLS**  
  `media_kit` cuenta con cache interno; adicionalmente se puede usar `flutter_cache_manager` para precargar segmentos y reducir buffering.
- **Descarga offline**  
  Para suscriptores, se permite descargar episodios completos. Se utiliza `dio` con soporte para descargas en segundo plano y se almacenan cifrados en el directorio de la aplicación (por ejemplo, Hive con cifrado o un contenedor encriptado). El DRM en offline se apoya en claves por dispositivo y gestión de licencias simples.

---

## 9. Roadmap de Desarrollo

### Fase 1: Planeación
**Objetivo:** Definir el alcance, roadmap de producto y prioridades técnicas.  
**Tareas:**  
- Crear épicas e historias de usuario.  
- Definir MVP y versiones posteriores.  
- Seleccionar y configurar herramientas de gestión (Jira, Notion, Miro para diagramas).  
- Redactar Architectural Decision Records (ADR) para decisiones clave.  
**Buenas prácticas:** Reuniones semanales de refinamiento, involucrar a todo el equipo en la visión.  
**Errores comunes:** Saltar a codificar sin tener claro el flujo de valor, ignorar restricciones de negocio.

### Fase 2: Diseño UI/UX
**Objetivo:** Traducir las historias de usuario en una experiencia visual tangible.  
**Tareas:**  
- Elaborar wireframes de baja fidelidad y prototipos navegables en Figma.  
- Definir un Design System: paleta de colores, tipografía, espaciado, iconografía y componentes reutilizables.  
- Validar los prototipos con usuarios representativos.  
**Entregables:** Guía de estilos, biblioteca de componentes en Figma y assets exportables (SVG/PNG).  
**Errores comunes:** Diseñar sin considerar las diferencias entre plataformas (ratón vs táctil), exceso de animaciones que afectan rendimiento.

### Fase 3: Configuración del proyecto
**Objetivo:** Establecer la infraestructura técnica base y la cultura de desarrollo.  
**Tareas:**  
- Crear repositorio Git con estructura de ramas (GitFlow o trunk-based).  
- Configurar tres proyectos Firebase (dev, staging, prod) con las reglas de seguridad básicas.  
- Levantar el backend local con Docker (PostgreSQL + PostgREST o Dart Frog) y scripts de migración.  
- Preparar scripts de automatización (Makefile) para tareas comunes.  
- Configurar variables de entorno con archivos `.env` en cada entorno, nunca en el código.  
**Buenas prácticas:** Usar emuladores de Firebase y bases de datos locales para desarrollo.  
**Errores comunes:** Compartir la misma instancia de base de datos entre desarrolladores; no versionar el esquema SQL.

### Fase 4: Arquitectura base
**Objetivo:** Implementar las capas transversales que usarán todos los features.  
**Tareas:**  
- Crear el tema de la aplicación (ThemeData) alineado al Design System.  
- Configurar el enrutador global con `go_router` y guardias de autenticación.  
- Establecer la inyección de dependencias con `get_it` e `injectable`.  
- Definir modelos de dominio principales (usuario, anime, episodio) como entidades puras.  
- Activar generación de código (build_runner) para freezed, json_serializable, retrofit.  
**Errores comunes:** Acoplar la UI a la lógica de negocio, no crear contratos (interfaces) desde el principio.

### Fase 5: Base de datos y API
**Objetivo:** Poner en marcha la fuente de verdad de los datos.  
**Tareas:**  
- Desplegar PostgreSQL en un entorno de desarrollo (local o cloud).  
- Ejecutar el script `bdcrunchyroll.sql` y verificar índices, restricciones y seeds.  
- Si se usa PostgREST, exponer la API y configurar JWT + RLS.  
- Si se usa Dart Frog, implementar endpoints para CRUD de animes, episodios, géneros, usuarios (perfil).  
- Documentar la API con OpenAPI (Swagger) para facilitar el trabajo del frontend.  
- Implementar paginación en las consultas de listado.  
**Buenas prácticas:** Migraciones versionadas con Flyway o similar.  
**Errores comunes:** Ignorar la seguridad (RLS) en etapas tempranas, endpoints N+1 sin joins.

### Fase 6: Backend adicional
**Objetivo:** Integrar servicios externos y lógica de negocio compleja.  
**Tareas:**  
- Integrar Firebase Auth y el flujo de sincronización de UUID con PostgreSQL (Cloud Function o endpoint en el backend).  
- Configurar Firebase Storage y las reglas de acceso.  
- Implementar notificaciones push: Cloud Function que escuche eventos (nuevo episodio) y envíe mensajes FCM.  
- Diseñar e implementar el sistema de suscripciones: webhooks de Stripe para actualizar estado en PostgreSQL, manejo de renovaciones y cancelaciones.  
**Errores comunes:** No manejar idempotencia en webhooks, exponer secretos de Stripe en el cliente.

### Fase 7: Frontend por features
**Objetivo:** Construir las funcionalidades de cara al usuario.  
**Tareas para cada feature** (Auth, Catálogo, Reproductor, Perfiles, Búsqueda, Admin):  
- Crear el módulo feature con sus capas (presentation, domain, data).  
- Implementar los BLoCs correspondientes con eventos/estados y casos de uso.  
- Desarrollar las pantallas y widgets reutilizables.  
- Integrar la API y la caché local para funcionamiento offline (si aplica).  
- Feature Admin solo habilitada en web/escritorio y protegida por rol.  
**Buenas prácticas:** Entregar cada feature con tests unitarios y de widget.  
**Errores comunes:** No respetar la separación de capas, compartir lógica entre features sin abstraer.

### Fase 8: Streaming y optimización multimedia
**Objetivo:** Ofrecer reproducción fluida y eficiente.  
**Tareas:**  
- Configurar la CDN de video y transcoding a HLS multibitrate.  
- Integrar `media_kit` como reproductor principal, con selector de calidad y pistas de audio/subtítulos.  
- Implementar la gestión de subtítulos desde las URLs proporcionadas por el backend.  
- Desarrollar caché de segmentos HLS y descarga offline con cifrado.  
- Probar en condiciones de red variables (simulación de 3G, pérdida de paquetes).  
**Errores comunes:** Usar reproductores no optimizados para HLS, no manejar errores de red en el streaming, omitir tests en diferentes plataformas.

### Fase 9: Testing
**Objetivo:** Garantizar calidad y robustez antes del lanzamiento.  
**Tareas:**  
- Unit tests para BLoCs, casos de uso y repositorios (con mocks).  
- Widget tests de componentes clave y pantallas.  
- Integration tests automatizados en CI para Android, iOS, Web y Windows.  
- Pruebas de rendimiento: tiempos de carga, memoria, consumo de batería (Android Profiler, Instruments).  
- Pruebas de accesibilidad básicas.  
**Buenas prácticas:** Cobertura mínima del 80% en lógica de negocio, tests de humo diarios.  
**Errores comunes:** Asumir que el código funciona sin validar en todas las plataformas, ignorar la consistencia de la caché offline.

### Fase 10: Optimización y despliegue
**Objetivo:** Lanzar de forma controlada y mantener la calidad.  
**Tareas:**  
- Minimizar el tamaño del bundle (tree shaking, ofuscación, compilación AOT).  
- Implementar división de descargas por plataforma (Deferred Components en Android, App Clips en iOS).  
- Configurar CI/CD con GitHub Actions para construcción, firma y distribución en tiendas y web.  
- Establecer despliegues canarios y pruebas A/B para nuevas características.  
- Monitoreo post-lanzamiento: Crashlytics, Analytics, logging de errores.  
**Errores comunes:** Subestimar el tiempo de revisión de tiendas, no preparar un plan de rollback.

---

## 10. Resumen de estándares aplicados y prevención del bloqueo de proveedor

### Estándares abiertos y portabilidad
- **API REST documentada con OpenAPI** en lugar de protocolos propietarios. El frontend consume DTOs estándar JSON.
- **PostgreSQL** como base de datos relacional, con posibilidad de migrarla a cualquier proveedor o autoalojarla. Uso de PostgREST permite cambiar de backend sin reescribir consultas si se mantiene el esquema.
- **HLS como protocolo de streaming**, soportado por cualquier reproductor moderno y CDN.
- **Dart Frog** o **PostgREST** como backend: ambos son de código abierto y no imponen un ecosistema cerrado.
- **Autenticación basada en JWT** (abierto), con Firebase Auth como proveedor fácilmente reemplazable por Auth0 o cualquier OIDC sin alterar la lógica de negocio.

### Cómo se evita el bloqueo de proveedor
- Las implementaciones concretas de servicios externos se encapsulan tras interfaces en la capa de datos. Cambiar de CDN de video, de sistema de notificaciones o de almacenamiento de imágenes no afecta a la lógica de dominio.
- Todas las configuraciones dependientes del proveedor se externalizan en variables de entorno, nunca en código.
- Uso de emuladores locales (Firebase Emulator Suite, bases de datos Docker) para desarrollo y pruebas, eliminando la dependencia de conexiones reales a la nube durante la construcción.
- La arquitectura Clean Architecture mantiene el dominio puro, sin anotaciones ni dependencias de frameworks de terceros.

### Principios Antigravity (ligereza y eficiencia)
- **Ligereza del frontend**: Uso de Hive para caché, `media_kit` con libmpv (alto rendimiento en decodificación), `lottie` para animaciones vectoriales comprimidas. Minimización de dependencias pesadas.
- **Eficiencia en la transferencia**: Caché agresiva del catálogo, paginación en todas las listas, imágenes optimizadas con compresión progresiva.
- **Arranque rápido**: Carga diferida de módulos (lazy loading) y precarga solo de la información crítica en el splash screen.
- **Bajo consumo en streaming**: ABR adaptativo y descarga de segmentos justo a tiempo, sin sobrecargar la memoria.

Esta combinación de decisiones técnicas y metodológicas asegura que la plataforma sea escalable, mantenible, portable y alineada con los valores de independencia y eficiencia requeridos.

