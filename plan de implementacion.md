# PROMPT:

Hazme un plan para una app de anime como Crunchyroll en Flutter y Dart. No pongas nada de código, solo quiero el plan en Markdown.

Dime cómo organizar las carpetas y qué arquitectura usar, algo como Clean Architecture o Bloc/Riverpod, tú ve cuál queda mejor para que escale. También dime qué paquetes de pub.dev necesito para el video, el estado, las animaciones, el responsive y conectar todo.

Uso PostgreSQL para los datos fuertes (usuarios, planes, animes) pero también quiero meter Firebase para el Auth, el Storage de los videos y las notificaciones, así que dime qué va en cada lado y cómo se conectan. Explícame cómo hacer el streaming para que los videos carguen bien y qué onda con los subtítulos.

Aparte dime cómo diseñar la UI para que sea naranja con gris como Crunchyroll, con skeletons y efectos de hover. Hazme una lista de pasos o roadmap de qué hacer primero y qué después, desde la planeación hasta el testing. Que el texto sea largo y detallado pero así sin mucha estructura de títulos bonitos, solo la información de cómo armar todo el sistema de perfiles, el historial y el panel de admin. ¡No olvides lo de la seguridad y el JWT!

# RESULTADO:

# Plan de App de Anime — Flutter & Dart (estilo Crunchyroll)

la arquitectura que más conviene acá es **Clean Architecture combinada con Bloc** para el manejo de estado. Riverpod también escala bien pero Bloc tiene mejor separación de concerns para algo tan grande como esto donde vas a tener múltiples dominios: auth, catálogo, streaming, perfiles, suscripciones, notificaciones y admin. La idea es que cada feature viva completamente aislada y que el día que quieras agregar más cosas no tengas que tocar lo que ya funciona.

---

## estructura de carpetas

la raíz del proyecto quedaría algo así, muy granular para que no se enrede cuando el equipo crezca:

```
lib/
├── core/
│   ├── constants/           ← colores, strings, rutas nombradas
│   ├── errors/              ← failures, exceptions, mappers de errores
│   ├── network/             ← dio client, interceptors, token refresh
│   ├── router/              ← go_router config, guards de auth
│   ├── theme/               ← ThemeData, colores naranja/gris, tipografía
│   ├── utils/               ← formatters, validators, helpers
│   └── widgets/             ← widgets compartidos (skeletons, buttons, badges)
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/     ← firebase_auth_datasource.dart, postgres_auth_datasource.dart
│   │   │   ├── models/          ← user_model.dart (JSON serializable)
│   │   │   └── repositories/    ← auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/        ← user.dart (clase pura sin dependencias)
│   │   │   ├── repositories/    ← auth_repository.dart (abstract)
│   │   │   └── usecases/        ← login_usecase.dart, register_usecase.dart, logout_usecase.dart
│   │   └── presentation/
│   │       ├── bloc/            ← auth_bloc.dart, auth_event.dart, auth_state.dart
│   │       └── pages/           ← login_page.dart, register_page.dart
│   │
│   ├── catalog/              ← lista de animes, búsqueda, filtros por género
│   ├── detail/               ← página de detalle de anime, episodios
│   ├── player/               ← reproductor de video, subtítulos, calidad
│   ├── profile/              ← perfiles de usuario, historial, favoritos
│   ├── subscription/         ← planes, pagos, gestión de membresía
│   ├── notifications/        ← FCM, push, in-app
│   ├── search/               ← búsqueda global con debounce
│   ├── home/                 ← carrusel principal, banners, tendencias
│   └── admin/                ← panel de administración (rutas protegidas por rol)
│
├── injection/
│   └── injection_container.dart   ← get_it + injectable para DI
│
└── main.dart
```

dentro de cada feature la estructura data/domain/presentation se repite siempre igual. esto es clave para que cualquier dev nuevo entienda en 5 minutos dónde va cada cosa. los datasources hablan con APIs externas, Firebase o la base de datos. los repositories son la capa de abstracción que el dominio consume sin saber de dónde vienen los datos. los usecases contienen la lógica de negocio y son clases simples con un solo método `call()`. las entidades son objetos de dominio puros sin ninguna dependencia de paquetes. y los BLoCs manejan los estados de la UI.

---

## paquetes de pub.dev que necesitas

**estado y DI**
- `flutter_bloc` — el core, muy maduro y testeado
- `get_it` + `injectable` — inyección de dependencias sin boilerplate, con generación de código
- `equatable` — para comparar estados en el BLoC sin escribir operadores manualmente

**navegación**
- `go_router` — navegación declarativa, soporta deep links, guards de autenticación, y es el estándar actual en Flutter

**red y APIs**
- `dio` — HTTP client con interceptors, lo usarás para el backend en Postgres/Node o lo que pongas de API
- `retrofit` — genera código para los endpoints automáticamente a partir de anotaciones, va sobre Dio
- `pretty_dio_logger` — para debug en desarrollo

**Firebase**
- `firebase_core`, `firebase_auth`, `cloud_firestore` (si usas Firestore para algo ligero), `firebase_storage`, `firebase_messaging`

**video**
- `video_player` — el oficial de Flutter, base para todo
- `chewie` — wrapper sobre video_player con controles bonitos y personalizables, es lo más fácil para empezar
- `better_player` — alternativa más potente, soporta HLS, DASH, subtítulos .srt/.vtt, múltiples calidades, DRM básico. Para producción esta es la que conviene
- `flutter_hls_parser` — si necesitas parsear los manifests HLS en cliente

**almacenamiento local**
- `hive` + `hive_flutter` — para guardar historial offline, caché de datos del catálogo, preferencias del usuario. mucho más rápido que sqlite para este tipo de datos
- `flutter_secure_storage` — para guardar el JWT y tokens de refresh de forma segura en el keychain/keystore del dispositivo, jamás en SharedPreferences

**UI y animaciones**
- `shimmer` — los skeleton loaders, esencial para la percepción de velocidad
- `cached_network_image` — carga de imágenes con caché automático, indispensable para un catálogo grande
- `lottie` — animaciones desde archivos .json de After Effects, para splash, onboarding, estados vacíos
- `flutter_animate` — animaciones declarativas muy expresivas con una API limpia, ideal para transiciones de elementos
- `animations` — paquete oficial de Google, tiene las transiciones de Material 3 como container transform
- `carousel_slider` — para los banners y carruseles del home

**responsive y adaptativo**
- `flutter_screenutil` — escala automática de tamaños de texto y widgets basado en el diseño base
- `responsive_framework` — breakpoints declarativos para mobile/tablet/desktop/web si piensas hacer Flutter Web también

**subtítulos y accesibilidad**
- `subtitle_wrapper_package` o parsear manualmente — los subtítulos en streaming van en formato WebVTT (.vtt), puedes parsearlos con un paquete o escribir el parser tú mismo (no es complicado)

**formularios y validación**
- `reactive_forms` o `formz` — manejo de formularios con validación reactiva

**internacionalización**
- `flutter_localizations` + `intl` — para español, inglés y japonés si lo necesitas

**otros útiles**
- `freezed` + `json_serializable` — para generar los modelos de datos con copyWith, toJson, fromJson sin escribirlos a mano. indispensable
- `connectivity_plus` — detectar si hay internet y mostrar estados offline
- `permission_handler` — permisos de notificaciones

---

## PostgreSQL vs Firebase — qué va en cada lado

esto es lo más importante de la arquitectura del sistema completo, no mezcles todo en Firebase porque vas a tener costos imposibles y limitaciones a escala.

**PostgreSQL (tu backend principal)** — aquí van los datos estructurados, relacionales y críticos del negocio. la tabla `users` con id, email, username, avatar_url, created_at, plan_id, fecha de nacimiento para restricciones de contenido. la tabla `animes` con todos los metadatos: título, descripción, géneros (array o tabla separada con join), studio, año, rating, estado (en emisión, finalizado, próximamente), thumbnail_url, banner_url. los `episodes` con número, temporada, duración, video_url (que apunta al archivo en Firebase Storage o CDN), subtítulos_url, fecha de emisión. los `plans` con nombre, precio, resolución máxima, número de perfiles simultáneos, acceso a contenido sin publicidad. el `watch_history` de cada usuario (user_id, episode_id, progress_seconds, completed, updated_at). los `favorites` y `watchlists`. los `ratings` y comentarios. el sistema de `roles` para los admins. toda la lógica de negocio de suscripciones y pagos. Este backend lo puedes hacer en Node.js con Express/Fastify, NestJS si quieres más estructura, o Supabase que ya te da todo esto con PostgreSQL más una API REST/GraphQL automática más auth propia si no quieres Firebase para eso.

**Firebase** — lo usas para tres cosas específicas: autenticación, storage de archivos de video/imágenes, y notificaciones push. Firebase Auth lo pones como proveedor de identidad (email/password, Google Sign-In, Apple Sign-In) y cuando el usuario se autentica, tu backend de PostgreSQL recibe el Firebase UID y crea o busca el usuario en tu base de datos, devolviendo un JWT propio. así Firebase maneja la parte complicada del auth (reset de contraseña, verificación de email, OAuth) y tú mantienes el control total de los datos de usuario. Firebase Storage lo usas para subir los videos procesados y las imágenes de portadas/banners, porque necesitas URLs públicas con control de acceso. Firebase Cloud Messaging (FCM) para las notificaciones push de nuevos episodios, actualizaciones de watchlist, alertas de cuenta.

**la conexión entre ambos**: el flujo es Firebase Auth → obtiene UID y token → tu app llama a tu API backend con ese token en el header → el backend valifica el Firebase token con el Firebase Admin SDK → crea sesión o encuentra usuario en PostgreSQL → devuelve JWT propio con los claims de rol y plan → la app guarda ese JWT en flutter_secure_storage → todas las llamadas subsiguientes van con el JWT propio en el Authorization header.

nunca guardes información sensible del usuario en Firestore si ya tienes PostgreSQL, es duplicar datos y complejidad sin beneficio real.

---

## JWT y seguridad

el JWT que emite tu backend debe tener en el payload: `sub` (user_id de PostgreSQL), `firebase_uid`, `email`, `role` (user/admin/moderator), `plan` (free/basic/premium), `iat`, `exp` (expiración corta, 15 minutos), y el token de refresh que vive 30 días guardado en PostgreSQL con posibilidad de revocación.

en el interceptor de Dio configuras el token refresh automático: cuando una petición devuelve 401, el interceptor pausa las peticiones pendientes, llama al endpoint de refresh con el refresh_token que tienes en secure_storage, actualiza el access_token, y reintenta las peticiones que estaban esperando. si el refresh también falla, mandas al usuario a login.

para el panel de admin protege las rutas con un guard en go_router que lee el claim `role` del JWT decodificado. en el backend, cada endpoint sensible de admin verifica el rol en el middleware antes de ejecutar cualquier lógica. nunca confíes solo en el frontend para ocultar rutas de admin.

el HTTPS es obligatorio en todos los endpoints. en producción activa CORS restrictivo solo a tus dominios. implementa rate limiting en los endpoints de auth para evitar fuerza bruta. los videos en Firebase Storage deben tener reglas que requieran autenticación para acceder, o usa URLs firmadas con tiempo de expiración corto para mayor seguridad en contenido premium.

---

## streaming de video y subtítulos

para que los videos carguen bien y no dé una experiencia horrible, necesitas hacer streaming adaptativo. el flujo es: el video original (que sube el admin) lo procesas en el backend con FFmpeg para generar múltiples resoluciones (360p, 480p, 720p, 1080p) y lo empaquetas en formato HLS (HTTP Live Streaming), que genera un archivo `.m3u8` (el manifest) y muchos segmentos `.ts` de 6-10 segundos cada uno. ese manifiesto apunta a los diferentes streams de calidad y el player selecciona automáticamente cuál usar según el ancho de banda disponible.

`better_player` soporta HLS nativamente, le pasas la URL del `.m3u8` y él hace todo el adaptive bitrate. configura el buffer: `bufferingConfiguration` con `minBufferMs: 15000` para que empiece a reproducir rápido y `maxBufferMs: 50000` para que precargue suficiente. en redes lentas el buffer corto y en WiFi puede ser más generoso.

para los subtítulos, el estándar web es WebVTT (`.vtt`), que es texto plano con timestamps. `better_player` acepta subtítulos directamente pasándole la URL del archivo `.vtt` en el `BetterPlayerSubtitlesSource`. en tu base de datos guarda la URL del archivo de subtítulos por idioma para cada episodio. en la UI muestra un selector de subtítulos e idioma de audio que modifica el source del player en caliente.

si quieres descargas offline (como hace Crunchyroll Premium), esto se complica bastante porque necesitas DRM o al menos encriptar los segmentos descargados localmente. para MVP puedes omitirlo y dejarlo para una fase posterior.

---

## diseño UI — naranja y gris estilo Crunchyroll

los colores base que defines en `core/theme/`:

- `primaryOrange`: `#F47521` — el naranja icónico
- `primaryOrangeDark`: `#D4621A` — para hovers y pressed states
- `backgroundDark`: `#0D0D0D` — casi negro, fondo principal
- `surfaceDark`: `#1A1A1A` — cards, drawers, bottom sheets
- `surfaceMedium`: `#2A2A2A` — elementos secundarios
- `textPrimary`: `#FFFFFF`
- `textSecondary`: `#B3B3B3` — gris claro para subtítulos y metadata
- `textMuted`: `#666666` — texto terciario

los skeletons los haces con el paquete `shimmer` usando el color `surfaceDark` como base y `surfaceMedium` como el brillo que se mueve. cada card de anime tiene su skeleton equivalente con las mismas dimensiones. mientras el BLoC esté en estado `Loading`, muestras los skeletons. cuando llega `Loaded`, usas `AnimatedSwitcher` para hacer la transición suave entre skeleton y contenido real.

para los efectos de hover en Flutter (que aplica más en web y desktop), usa `MouseRegion` + `AnimatedContainer` para escalar ligeramente las cards (scale 1.0 → 1.05) y mostrar un overlay naranja semitransparente. en mobile esto se reemplaza por el efecto de ripple de Material pero con el color naranja como `splashColor`.

la tipografía recomendada es `Nunito` o `Poppins` para los títulos (bold, llamativo) y `Inter` o `DM Sans` para el cuerpo. estas las cargas con `google_fonts`.

el home tiene un hero banner con `PageView` que hace autoplay cada 5 segundos con un indicador de puntos, mostrando el anime más nuevo o destacado con un gradient de abajo hacia arriba para que el texto sea legible sobre la imagen. debajo vienen filas horizontales scrolleables (como Netflix) con categorías: "Nuevos episodios", "Popular esta semana", "Acción", "Romance", etc. cada fila es un `ListView.builder` horizontal con las cards de anime (120×170px aprox con bordes redondeados y la calidad/tipo en una badge naranja en la esquina).

---

## sistema de perfiles

Crunchyroll permite múltiples perfiles por cuenta. en tu esquema de base de datos tienes `accounts` (la cuenta principal) y `profiles` (hasta N perfiles según el plan). cada perfil tiene nombre, avatar, preferencias de género, restricción de contenido (perfil de niños), historial propio, favoritos propios y configuración de subtítulos por defecto.

en la app, después del login el usuario ve la pantalla de selección de perfil (con animación de entrada). el perfil seleccionado se guarda en el estado global del BLoC de auth y se incluye en las peticiones al backend como header o query param para personalizar recomendaciones y continuar historial.

el historial (`watch_history`) se sincroniza con el backend cada cierto tiempo y también se guarda localmente en Hive para tener acceso offline a "continuar viendo". cada vez que el usuario pausa o termina un episodio, el player manda al backend el `progress_seconds` con un debounce de 5 segundos para no spamear peticiones.

---

## panel de admin

el admin es una sección separada dentro de la misma app (o podrías hacer una app Flutter separada para web, usando Flutter Web) accesible solo si `role == 'admin'` en el JWT. las secciones del panel son:

gestión de animes — CRUD completo, con formulario para subir thumbnail/banner a Firebase Storage y guardar la URL en PostgreSQL, metadatos completos, asignación de géneros y categorías.

gestión de episodios — subida del video a Firebase Storage, trigger de procesamiento FFmpeg en el backend para generar HLS, asociación con el anime padre, upload de archivos de subtítulos por idioma.

gestión de usuarios — búsqueda por email, ver historial, cambiar plan manualmente, suspender cuentas, ver logs de actividad.

gestión de planes — configurar los precios y límites de cada plan.

estadísticas básicas — usuarios activos, animes más vistos, episodios más populares. esto lo puedes sacar con queries agregadas en PostgreSQL.

---

## roadmap de desarrollo — de planeación a testing

**fase 1 — fundamentos (semanas 1-3)**
primero configura el proyecto Flutter, define el ThemeData completo con los colores naranja/gris, instala todos los paquetes necesarios y configura el injection_container con get_it. configura go_router con las rutas básicas. levanta el backend (Node/Nest + PostgreSQL) con las migraciones iniciales de las tablas core: users, animes, episodes, plans. conecta Firebase al proyecto y configura Firebase Auth. implementa el flujo completo de autenticación: registro, login, logout, refresh de token, guard de rutas. esto es lo más crítico porque todo lo demás depende de aquí.

**fase 2 — catálogo y home (semanas 4-6)**
implementa los endpoints del backend para listar animes con paginación, filtros y búsqueda. construye la feature de home con el carrusel hero y las filas de categorías. skeletons en todos lados. lazy loading con paginación infinita. implementa la caché con Hive para que el catálogo funcione sin internet con datos del último fetch. pantalla de detalle del anime con lista de temporadas y episodios.

**fase 3 — player y streaming (semanas 7-9)**
esta es la fase más técnica. configura el pipeline de FFmpeg en el backend para procesar videos a HLS. integra better_player con configuración de calidades adaptativas. implementa la sincronización del progreso de visualización con debounce. subtítulos con selector de idioma. controles customizados (play/pause, seek, velocidad, pantalla completa). registro de historial en tiempo real.

**fase 4 — perfiles y personalización (semanas 10-11)**
múltiples perfiles por cuenta con avatares. historial independiente por perfil. sistema de favoritos y watchlist. preferencias de contenido. pantalla de selección de perfil al inicio.

**fase 5 — suscripciones y pagos (semanas 12-13)**
integra un gateway de pagos (Stripe es lo más fácil, o MercadoPago si tu mercado es LATAM). los planes en PostgreSQL con sus límites. verificación de plan en el backend para servir contenido premium. pantalla de gestión de suscripción.

**fase 6 — notificaciones (semana 14)**
FCM para push notifications de nuevos episodios. in-app notifications con un bell en la navbar. preferencias de notificaciones por usuario. el backend tiene un job programado que revisa nuevos episodios y dispara notificaciones a los usuarios que tienen ese anime en favoritos o watchlist.

**fase 7 — panel de admin (semanas 15-16)**
CRUD de animes y episodios con upload de archivos. gestión de usuarios. estadísticas básicas. protección de rutas por rol tanto en frontend como backend.

**fase 8 — testing, pulido y deploy (semanas 17-20)**
unit tests para todos los usecases (esto es lo más fácil de testear porque son clases puras). bloc tests con `bloc_test` para verificar que los estados se emiten correctamente. widget tests para los componentes más críticos. integration tests para los flujos de auth y player. optimización de performance: mide con Flutter DevTools, busca jank en los listados con muchas imágenes, verifica que las imágenes se están cacheando bien. configuración de flavors para dev/staging/production con diferentes configuraciones de Firebase y API URLs. CI/CD con GitHub Actions para builds automáticos. deploy del backend en Railway, Render o AWS según tu presupuesto.

---

## notas adicionales de seguridad y escalabilidad

el contenido premium nunca debe ser accesible sin JWT válido con el plan correcto. las URLs de Firebase Storage para videos deben ser signed URLs con expiración de 2-4 horas que tu backend genera y devuelve al cliente, no URLs permanentes. así aunque alguien comparta la URL, expira rápido.

implementa rate limiting en el backend para los endpoints de búsqueda y listado para evitar scraping. loggea los eventos importantes (auth events, payment events, errores del player) en una herramienta como Sentry o LogRocket.

si el proyecto crece y tienes muchos usuarios concurrentes viendo videos, el cuello de botella va a ser el almacenamiento y distribución de video. Firebase Storage no tiene CDN nativo potente, considera mover los videos a Cloudflare R2 + Cloudflare CDN o AWS S3 + CloudFront cuando escales, la latencia mejora enormemente para usuarios en diferentes regiones.

para el tema de GDPR/privacidad o leyes mexicanas de protección de datos, guarda solo lo que necesitas, permite que el usuario descargue o elimine su cuenta y datos, y documenta qué datos recolectas y para qué.
