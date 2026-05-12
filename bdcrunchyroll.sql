-- =============================================================
--  BASE DE DATOS: bdcrunchyroll
--  Descripción : Plataforma de streaming de anime
--  Motor       : PostgreSQL 15+
--  Generado    : 2026
-- =============================================================

-- -------------------------------------------------------------
-- 0. CREACIÓN Y SELECCIÓN DE BASE DE DATOS
-- -------------------------------------------------------------
CREATE DATABASE bdcrunchyroll
    ENCODING = 'UTF8'
    LC_COLLATE = 'es_MX.UTF-8'
    LC_CTYPE   = 'es_MX.UTF-8'
    TEMPLATE   = template0;

\c bdcrunchyroll;

-- Extensión para UUIDs
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================================
-- 1. TABLAS DE CATÁLOGO / MAESTROS (sin dependencias externas)
-- =============================================================

-- -------------------------------------------------------------
-- IDIOMA
-- -------------------------------------------------------------
CREATE TABLE idioma (
    id       UUID         NOT NULL DEFAULT gen_random_uuid(),
    codigo   CHAR(5)      NOT NULL,
    nombre   VARCHAR(50)  NOT NULL,
    nombre_nativo VARCHAR(50) NOT NULL,

    CONSTRAINT pk_idioma  PRIMARY KEY (id),
    CONSTRAINT uk_idioma_codigo UNIQUE (codigo)
);

COMMENT ON TABLE  idioma          IS 'Idiomas soportados en la plataforma';
COMMENT ON COLUMN idioma.codigo   IS 'BCP-47 (es-MX, en-US, ja)';

-- -------------------------------------------------------------
-- GENERO
-- -------------------------------------------------------------
CREATE TABLE genero (
    id          UUID          NOT NULL DEFAULT gen_random_uuid(),
    nombre      VARCHAR(50)   NOT NULL,
    slug        VARCHAR(50)   NOT NULL,
    descripcion VARCHAR(255)  NULL,

    CONSTRAINT pk_genero       PRIMARY KEY (id),
    CONSTRAINT uk_genero_nombre UNIQUE (nombre),
    CONSTRAINT uk_genero_slug   UNIQUE (slug)
);

COMMENT ON TABLE  genero      IS 'Clasificación temática del catálogo';
COMMENT ON COLUMN genero.slug IS 'URL-friendly del nombre';

-- -------------------------------------------------------------
-- ESTUDIO
-- -------------------------------------------------------------
CREATE TABLE estudio (
    id          UUID          NOT NULL DEFAULT gen_random_uuid(),
    nombre      VARCHAR(150)  NOT NULL,
    pais_codigo CHAR(2)       NOT NULL,
    sitio_web   VARCHAR(255)  NULL,
    fundado_en  SMALLINT      NULL,

    CONSTRAINT pk_estudio       PRIMARY KEY (id),
    CONSTRAINT uk_estudio_nombre UNIQUE (nombre)
);

COMMENT ON TABLE  estudio             IS 'Productoras de anime';
COMMENT ON COLUMN estudio.pais_codigo IS 'Código ISO del país';

-- -------------------------------------------------------------
-- PLAN
-- -------------------------------------------------------------
CREATE TABLE plan (
    id                  UUID           NOT NULL DEFAULT gen_random_uuid(),
    nombre              VARCHAR(50)    NOT NULL,
    precio_mensual      DECIMAL(8,2)   NOT NULL,
    precio_anual        DECIMAL(8,2)   NULL,
    moneda              CHAR(3)        NOT NULL,
    perfiles_max        SMALLINT       NOT NULL,
    streams_simultaneos SMALLINT       NOT NULL,
    sin_anuncios        BOOLEAN        NOT NULL DEFAULT FALSE,
    calidad_max         VARCHAR(10)    NOT NULL,
    descarga_offline    BOOLEAN        NOT NULL DEFAULT FALSE,
    activo              BOOLEAN        NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_plan       PRIMARY KEY (id),
    CONSTRAINT uk_plan_nombre UNIQUE (nombre),
    CONSTRAINT ck_plan_precio_mensual CHECK (precio_mensual >= 0),
    CONSTRAINT ck_plan_precio_anual   CHECK (precio_anual IS NULL OR precio_anual >= 0),
    CONSTRAINT ck_plan_perfiles_max   CHECK (perfiles_max > 0),
    CONSTRAINT ck_plan_streams        CHECK (streams_simultaneos > 0)
);

COMMENT ON TABLE  plan         IS 'Niveles de suscripción disponibles';
COMMENT ON COLUMN plan.moneda  IS 'Código ISO 4217 (USD, MXN…)';

-- =============================================================
-- 2. TABLAS DE USUARIO Y AUTENTICACIÓN
-- =============================================================

-- -------------------------------------------------------------
-- USUARIO
-- -------------------------------------------------------------
CREATE TABLE usuario (
    id                 UUID          NOT NULL DEFAULT gen_random_uuid(),
    email              VARCHAR(255)  NOT NULL,
    nombre             VARCHAR(100)  NOT NULL,
    apellido           VARCHAR(100)  NOT NULL,
    fecha_nacimiento   DATE          NOT NULL,
    pais_codigo        CHAR(2)       NOT NULL,
    idioma_preferido   CHAR(5)       NOT NULL,
    password_hash      VARCHAR(255)  NOT NULL,
    verificado_email   BOOLEAN       NOT NULL DEFAULT FALSE,
    activo             BOOLEAN       NOT NULL DEFAULT TRUE,
    fecha_registro     TIMESTAMP     NOT NULL DEFAULT NOW(),
    ultimo_login       TIMESTAMP     NULL,

    CONSTRAINT pk_usuario       PRIMARY KEY (id),
    CONSTRAINT uk_usuario_email UNIQUE (email)
);

COMMENT ON TABLE  usuario               IS 'Cuenta principal del cliente';
COMMENT ON COLUMN usuario.idioma_preferido IS 'Código BCP-47 del idioma';
COMMENT ON COLUMN usuario.password_hash    IS 'Hash bcrypt de contraseña';

-- -------------------------------------------------------------
-- PERFIL
-- -------------------------------------------------------------
CREATE TABLE perfil (
    id                  UUID          NOT NULL DEFAULT gen_random_uuid(),
    usuario_id          UUID          NOT NULL,
    nombre              VARCHAR(50)   NOT NULL,
    avatar_url          VARCHAR(500)  NULL,
    clasificacion_edad  SMALLINT      NOT NULL,
    es_infantil         BOOLEAN       NOT NULL DEFAULT FALSE,
    creado_en           TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_perfil         PRIMARY KEY (id),
    CONSTRAINT fk_perfil_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_perfil_clasificacion CHECK (clasificacion_edad >= 0)
);

COMMENT ON TABLE  perfil                   IS 'Sub-perfil por miembro del hogar';
COMMENT ON COLUMN perfil.clasificacion_edad IS 'Rating máx. permitido (ej: 13)';

-- -------------------------------------------------------------
-- METODO_PAGO
-- -------------------------------------------------------------
CREATE TABLE metodo_pago (
    id               UUID          NOT NULL DEFAULT gen_random_uuid(),
    usuario_id       UUID          NOT NULL,
    tipo             VARCHAR(30)   NOT NULL,
    ultimos4         CHAR(4)       NULL,
    marca            VARCHAR(20)   NULL,
    mes_expiracion   SMALLINT      NULL,
    anio_expiracion  SMALLINT      NULL,
    token_vault      VARCHAR(255)  NULL,
    predeterminado   BOOLEAN       NOT NULL DEFAULT FALSE,
    creado_en        TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_metodo_pago         PRIMARY KEY (id),
    CONSTRAINT fk_metodo_pago_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_metodo_pago_tipo    CHECK (tipo IN ('tarjeta','paypal','google_pay')),
    CONSTRAINT ck_metodo_pago_mes     CHECK (mes_expiracion BETWEEN 1 AND 12),
    CONSTRAINT ck_metodo_pago_anio    CHECK (anio_expiracion IS NULL OR anio_expiracion >= 2020)
);

COMMENT ON TABLE  metodo_pago             IS 'Tarjetas y métodos de pago guardados';
COMMENT ON COLUMN metodo_pago.token_vault IS 'Token tokenizado del proveedor externo';

-- -------------------------------------------------------------
-- SUSCRIPCION
-- -------------------------------------------------------------
CREATE TABLE suscripcion (
    id             UUID          NOT NULL DEFAULT gen_random_uuid(),
    usuario_id     UUID          NOT NULL,
    plan_id        UUID          NOT NULL,
    fecha_inicio   DATE          NOT NULL,
    fecha_fin      DATE          NOT NULL,
    estado         VARCHAR(20)   NOT NULL DEFAULT 'activa',
    renovacion_auto BOOLEAN      NOT NULL DEFAULT TRUE,
    cancelada_en   TIMESTAMP     NULL,
    creada_en      TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_suscripcion         PRIMARY KEY (id),
    CONSTRAINT fk_suscripcion_usuario FOREIGN KEY (usuario_id)
        REFERENCES usuario (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_suscripcion_plan    FOREIGN KEY (plan_id)
        REFERENCES plan (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_suscripcion_estado  CHECK (estado IN ('activa','cancelada','vencida')),
    CONSTRAINT ck_suscripcion_fechas  CHECK (fecha_fin > fecha_inicio)
);

COMMENT ON TABLE suscripcion IS 'Contrato activo entre usuario y plan';

-- -------------------------------------------------------------
-- PAGO
-- -------------------------------------------------------------
CREATE TABLE pago (
    id                  UUID           NOT NULL DEFAULT gen_random_uuid(),
    usuario_id          UUID           NOT NULL,
    suscripcion_id      UUID           NOT NULL,
    metodo_pago_id      UUID           NOT NULL,
    monto               DECIMAL(10,2)  NOT NULL,
    moneda              CHAR(3)        NOT NULL,
    estado              VARCHAR(20)    NOT NULL,
    referencia_externa  VARCHAR(255)   NULL,
    procesado_en        TIMESTAMP      NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_pago              PRIMARY KEY (id),
    CONSTRAINT fk_pago_usuario      FOREIGN KEY (usuario_id)
        REFERENCES usuario (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pago_suscripcion  FOREIGN KEY (suscripcion_id)
        REFERENCES suscripcion (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pago_metodo_pago  FOREIGN KEY (metodo_pago_id)
        REFERENCES metodo_pago (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT ck_pago_monto        CHECK (monto > 0),
    CONSTRAINT ck_pago_estado       CHECK (estado IN ('exitoso','fallido','reembolsado'))
);

COMMENT ON TABLE  pago                    IS 'Transacciones de cobro';
COMMENT ON COLUMN pago.referencia_externa IS 'ID de Stripe/PayPal etc.';

-- =============================================================
-- 3. CATÁLOGO DE CONTENIDO
-- =============================================================

-- -------------------------------------------------------------
-- ANIME
-- -------------------------------------------------------------
CREATE TABLE anime (
    id                  UUID           NOT NULL DEFAULT gen_random_uuid(),
    titulo_original     VARCHAR(255)   NOT NULL,
    titulo_romaji       VARCHAR(255)   NULL,
    titulo_es           VARCHAR(255)   NULL,
    sinopsis            TEXT           NULL,
    anio_estreno        SMALLINT       NOT NULL,
    estado              VARCHAR(20)    NOT NULL,
    tipo                VARCHAR(20)    NOT NULL,
    clasificacion_edad  VARCHAR(10)    NOT NULL,
    episodios_totales   SMALLINT       NULL,
    imagen_portada_url  VARCHAR(500)   NULL,
    imagen_banner_url   VARCHAR(500)   NULL,
    puntuacion_media    DECIMAL(3,2)   NULL,
    total_resenas       INTEGER        NOT NULL DEFAULT 0,
    creado_en           TIMESTAMP      NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_anime              PRIMARY KEY (id),
    CONSTRAINT ck_anime_estado       CHECK (estado IN ('en_emision','finalizado','anunciado')),
    CONSTRAINT ck_anime_tipo         CHECK (tipo IN ('serie','pelicula','OVA','especial')),
    CONSTRAINT ck_anime_clasificacion CHECK (clasificacion_edad IN ('G','PG','PG-13','R','R+')),
    CONSTRAINT ck_anime_puntuacion   CHECK (puntuacion_media IS NULL OR
                                            puntuacion_media BETWEEN 0.00 AND 5.00),
    CONSTRAINT ck_anime_total_resenas CHECK (total_resenas >= 0)
);

COMMENT ON TABLE  anime               IS 'Catálogo principal de series/películas';
COMMENT ON COLUMN anime.total_resenas IS 'Contador desnormalizado de reseñas';

-- -------------------------------------------------------------
-- ANIME_GENERO  (N:M)
-- -------------------------------------------------------------
CREATE TABLE anime_genero (
    anime_id   UUID NOT NULL,
    genero_id  UUID NOT NULL,

    CONSTRAINT pk_anime_genero        PRIMARY KEY (anime_id, genero_id),
    CONSTRAINT fk_anime_genero_anime  FOREIGN KEY (anime_id)
        REFERENCES anime (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_anime_genero_genero FOREIGN KEY (genero_id)
        REFERENCES genero (id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE anime_genero IS 'Relación N:M anime–género';

-- -------------------------------------------------------------
-- ANIME_ESTUDIO  (N:M)
-- -------------------------------------------------------------
CREATE TABLE anime_estudio (
    anime_id    UUID         NOT NULL,
    estudio_id  UUID         NOT NULL,
    rol         VARCHAR(30)  NULL,

    CONSTRAINT pk_anime_estudio         PRIMARY KEY (anime_id, estudio_id),
    CONSTRAINT fk_anime_estudio_anime   FOREIGN KEY (anime_id)
        REFERENCES anime (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_anime_estudio_estudio FOREIGN KEY (estudio_id)
        REFERENCES estudio (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_anime_estudio_rol     CHECK (rol IS NULL OR
                                               rol IN ('principal','animacion','co-produccion'))
);

COMMENT ON TABLE  anime_estudio     IS 'Relación N:M anime–estudio';
COMMENT ON COLUMN anime_estudio.rol IS 'principal / animacion / co-produccion';

-- -------------------------------------------------------------
-- EPISODIO
-- -------------------------------------------------------------
CREATE TABLE episodio (
    id                UUID          NOT NULL DEFAULT gen_random_uuid(),
    anime_id          UUID          NOT NULL,
    numero            SMALLINT      NOT NULL,
    temporada         SMALLINT      NOT NULL,
    titulo            VARCHAR(255)  NULL,
    sinopsis          TEXT          NULL,
    duracion_seg      INTEGER       NOT NULL,
    url_thumbnail     VARCHAR(500)  NULL,
    fecha_estreno     DATE          NULL,
    fecha_disponible  TIMESTAMP     NULL,
    es_premium        BOOLEAN       NOT NULL DEFAULT TRUE,
    creado_en         TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_episodio         PRIMARY KEY (id),
    CONSTRAINT fk_episodio_anime   FOREIGN KEY (anime_id)
        REFERENCES anime (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uk_episodio_num_temp UNIQUE (anime_id, temporada, numero),
    CONSTRAINT ck_episodio_duracion CHECK (duracion_seg > 0),
    CONSTRAINT ck_episodio_numero   CHECK (numero > 0),
    CONSTRAINT ck_episodio_temporada CHECK (temporada > 0)
);

COMMENT ON TABLE  episodio          IS 'Unidad mínima de contenido reproducible';
COMMENT ON COLUMN episodio.es_premium IS 'Solo para suscriptores de pago';

-- -------------------------------------------------------------
-- SUBTITULO
-- -------------------------------------------------------------
CREATE TABLE subtitulo (
    id           UUID          NOT NULL DEFAULT gen_random_uuid(),
    episodio_id  UUID          NOT NULL,
    idioma_id    UUID          NOT NULL,
    url_archivo  VARCHAR(500)  NOT NULL,
    formato      VARCHAR(10)   NOT NULL,
    creado_en    TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_subtitulo           PRIMARY KEY (id),
    CONSTRAINT fk_subtitulo_episodio  FOREIGN KEY (episodio_id)
        REFERENCES episodio (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_subtitulo_idioma    FOREIGN KEY (idioma_id)
        REFERENCES idioma (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_subtitulo_ep_idioma UNIQUE (episodio_id, idioma_id),
    CONSTRAINT ck_subtitulo_formato   CHECK (formato IN ('vtt','srt','ass'))
);

COMMENT ON TABLE subtitulo IS 'Archivo de subtítulos por episodio e idioma';

-- -------------------------------------------------------------
-- DOBLAJE
-- -------------------------------------------------------------
CREATE TABLE doblaje (
    id              UUID          NOT NULL DEFAULT gen_random_uuid(),
    episodio_id     UUID          NOT NULL,
    idioma_id       UUID          NOT NULL,
    url_audio       VARCHAR(500)  NOT NULL,
    estudio_doblaje VARCHAR(150)  NULL,
    creado_en       TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_doblaje           PRIMARY KEY (id),
    CONSTRAINT fk_doblaje_episodio  FOREIGN KEY (episodio_id)
        REFERENCES episodio (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_doblaje_idioma    FOREIGN KEY (idioma_id)
        REFERENCES idioma (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT uk_doblaje_ep_idioma UNIQUE (episodio_id, idioma_id)
);

COMMENT ON TABLE doblaje IS 'Pista de audio doblada por episodio e idioma';

-- =============================================================
-- 4. ACTIVIDAD DEL USUARIO
-- =============================================================

-- -------------------------------------------------------------
-- HISTORIAL_VISTO
-- -------------------------------------------------------------
CREATE TABLE historial_visto (
    id            UUID          NOT NULL DEFAULT gen_random_uuid(),
    perfil_id     UUID          NOT NULL,
    episodio_id   UUID          NOT NULL,
    segundo_pausa INTEGER       NOT NULL DEFAULT 0,
    completado    BOOLEAN       NOT NULL DEFAULT FALSE,
    dispositivo   VARCHAR(50)   NULL,
    visto_en      TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_historial_visto           PRIMARY KEY (id),
    CONSTRAINT fk_historial_visto_perfil    FOREIGN KEY (perfil_id)
        REFERENCES perfil (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_historial_visto_episodio  FOREIGN KEY (episodio_id)
        REFERENCES episodio (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_historial_segundo_pausa   CHECK (segundo_pausa >= 0),
    CONSTRAINT ck_historial_dispositivo     CHECK (dispositivo IS NULL OR
                                                    dispositivo IN ('web','ios','android','tv'))
);

COMMENT ON TABLE  historial_visto             IS 'Progreso de reproducción por perfil';
COMMENT ON COLUMN historial_visto.completado  IS 'Episodio visto al 90%+';

-- -------------------------------------------------------------
-- LISTA_REPRODUCCION
-- -------------------------------------------------------------
CREATE TABLE lista_reproduccion (
    id            UUID          NOT NULL DEFAULT gen_random_uuid(),
    perfil_id     UUID          NOT NULL,
    nombre        VARCHAR(100)  NOT NULL,
    es_favoritos  BOOLEAN       NOT NULL DEFAULT FALSE,
    creada_en     TIMESTAMP     NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_lista_reproduccion         PRIMARY KEY (id),
    CONSTRAINT fk_lista_reproduccion_perfil  FOREIGN KEY (perfil_id)
        REFERENCES perfil (id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE  lista_reproduccion             IS 'Watchlist y listas personalizadas';
COMMENT ON COLUMN lista_reproduccion.es_favoritos IS 'Lista de favoritos del sistema';

-- -------------------------------------------------------------
-- LISTA_ANIME  (N:M lista–anime)
-- -------------------------------------------------------------
CREATE TABLE lista_anime (
    lista_id    UUID       NOT NULL,
    anime_id    UUID       NOT NULL,
    posicion    SMALLINT   NOT NULL,
    agregado_en TIMESTAMP  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_lista_anime         PRIMARY KEY (lista_id, anime_id),
    CONSTRAINT fk_lista_anime_lista   FOREIGN KEY (lista_id)
        REFERENCES lista_reproduccion (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_lista_anime_anime   FOREIGN KEY (anime_id)
        REFERENCES anime (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_lista_anime_posicion CHECK (posicion >= 0)
);

COMMENT ON TABLE lista_anime IS 'Animes dentro de una lista de reproducción';

-- -------------------------------------------------------------
-- RESENA
-- -------------------------------------------------------------
CREATE TABLE resena (
    id                 UUID       NOT NULL DEFAULT gen_random_uuid(),
    usuario_id         UUID       NOT NULL,
    anime_id           UUID       NOT NULL,
    puntuacion         SMALLINT   NOT NULL,
    comentario         TEXT       NULL,
    contiene_spoilers  BOOLEAN    NOT NULL DEFAULT FALSE,
    util_count         INTEGER    NOT NULL DEFAULT 0,
    creada_en          TIMESTAMP  NOT NULL DEFAULT NOW(),

    CONSTRAINT pk_resena            PRIMARY KEY (id),
    CONSTRAINT fk_resena_usuario    FOREIGN KEY (usuario_id)
        REFERENCES usuario (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_resena_anime      FOREIGN KEY (anime_id)
        REFERENCES anime (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT uk_resena_usr_anime  UNIQUE (usuario_id, anime_id),
    CONSTRAINT ck_resena_puntuacion CHECK (puntuacion BETWEEN 1 AND 5),
    CONSTRAINT ck_resena_util_count CHECK (util_count >= 0)
);

COMMENT ON TABLE  resena              IS 'Valoraciones y comentarios de usuarios';
COMMENT ON COLUMN resena.puntuacion   IS 'Calificación del 1 al 5';
COMMENT ON COLUMN resena.util_count   IS 'Votos de utilidad de otros usuarios';

-- =============================================================
-- 5. ÍNDICES DE RENDIMIENTO
-- =============================================================

-- Usuario
CREATE INDEX idx_usuario_email         ON usuario (email);
CREATE INDEX idx_usuario_pais          ON usuario (pais_codigo);

-- Perfil
CREATE INDEX idx_perfil_usuario        ON perfil (usuario_id);

-- Suscripcion
CREATE INDEX idx_suscripcion_usuario   ON suscripcion (usuario_id);
CREATE INDEX idx_suscripcion_plan      ON suscripcion (plan_id);
CREATE INDEX idx_suscripcion_estado    ON suscripcion (estado);

-- Pago
CREATE INDEX idx_pago_usuario          ON pago (usuario_id);
CREATE INDEX idx_pago_suscripcion      ON pago (suscripcion_id);
CREATE INDEX idx_pago_procesado        ON pago (procesado_en DESC);

-- Metodo_pago
CREATE INDEX idx_metodo_pago_usuario   ON metodo_pago (usuario_id);

-- Anime
CREATE INDEX idx_anime_estado          ON anime (estado);
CREATE INDEX idx_anime_tipo            ON anime (tipo);
CREATE INDEX idx_anime_anio            ON anime (anio_estreno DESC);
CREATE INDEX idx_anime_puntuacion      ON anime (puntuacion_media DESC NULLS LAST);

-- Episodio
CREATE INDEX idx_episodio_anime        ON episodio (anime_id);
CREATE INDEX idx_episodio_disponible   ON episodio (fecha_disponible);

-- Subtitulo / Doblaje
CREATE INDEX idx_subtitulo_episodio    ON subtitulo (episodio_id);
CREATE INDEX idx_doblaje_episodio      ON doblaje (episodio_id);

-- Historial_visto
CREATE INDEX idx_historial_perfil      ON historial_visto (perfil_id);
CREATE INDEX idx_historial_episodio    ON historial_visto (episodio_id);
CREATE INDEX idx_historial_visto_en    ON historial_visto (visto_en DESC);

-- Lista_reproduccion
CREATE INDEX idx_lista_perfil          ON lista_reproduccion (perfil_id);

-- Reseña
CREATE INDEX idx_resena_anime          ON resena (anime_id);
CREATE INDEX idx_resena_usuario        ON resena (usuario_id);
CREATE INDEX idx_resena_puntuacion     ON resena (puntuacion DESC);

-- =============================================================
-- 6. TRIGGER: mantener puntuacion_media y total_resenas en ANIME
-- =============================================================

CREATE OR REPLACE FUNCTION trg_actualizar_puntuacion_anime()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    UPDATE anime
    SET
        puntuacion_media = (
            SELECT ROUND(AVG(puntuacion)::NUMERIC, 2)
            FROM resena
            WHERE anime_id = COALESCE(NEW.anime_id, OLD.anime_id)
        ),
        total_resenas = (
            SELECT COUNT(*)
            FROM resena
            WHERE anime_id = COALESCE(NEW.anime_id, OLD.anime_id)
        )
    WHERE id = COALESCE(NEW.anime_id, OLD.anime_id);

    RETURN NEW;
END;
$$;

CREATE TRIGGER tg_resena_after_insert
AFTER INSERT ON resena
FOR EACH ROW EXECUTE FUNCTION trg_actualizar_puntuacion_anime();

CREATE TRIGGER tg_resena_after_update
AFTER UPDATE OF puntuacion ON resena
FOR EACH ROW EXECUTE FUNCTION trg_actualizar_puntuacion_anime();

CREATE TRIGGER tg_resena_after_delete
AFTER DELETE ON resena
FOR EACH ROW EXECUTE FUNCTION trg_actualizar_puntuacion_anime();

-- =============================================================
-- FIN DEL SCRIPT  –  bdcrunchyroll
-- =============================================================
