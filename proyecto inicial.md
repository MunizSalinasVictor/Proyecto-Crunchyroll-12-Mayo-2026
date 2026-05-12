Como administrador de base de datos para Crunchyroll, aquí está el análisis de entidades necesarias para gestionar la plataforma:Aquí tienes el desglose por dominio:
<img width="1092" height="451" alt="image" src="https://github.com/user-attachments/assets/88bde391-9fd0-4878-b06f-211d2c3e36cd" />

**Usuarios y acceso**
`USUARIO` es el núcleo: almacena datos de registro, país y estado. Puede tener múltiples `PERFIL` (como Netflix, hasta un máximo definido por el plan), lo que permite separar historial y preferencias por miembro del hogar.

**Suscripción y pagos**
`SUSCRIPCION` vincula al usuario con un `PLAN` (Fan, Mega Fan, Ultimate Fan). `PAGO` registra cada transacción con su `METODO_PAGO` (tarjeta, PayPal, etc.), lo que permite auditoría y reintentos de cobro.

**Catálogo de contenido**
`ANIME` contiene la ficha maestra (título, sinopsis, estado: en emisión/finalizado). Cada anime tiene `EPISODIO`s organizados por temporada. Las relaciones N:M con `GENERO` y `ESTUDIO` permiten filtros y búsquedas.

**Localización**
`SUBTITULO` y `DOBLAJE` referencian un `IDIOMA`, separando el texto del audio. Esto es crítico para Crunchyroll que opera globalmente con más de 10 idiomas simultáneos.

**Consumo y personalización**
`HISTORIAL_VISTO` guarda el segundo exacto de pausa por perfil, esencial para el "continuar viendo". `LISTA_REPRODUCCION` es la watchlist del usuario. `RESENA` maneja las valoraciones de la comunidad.

---


