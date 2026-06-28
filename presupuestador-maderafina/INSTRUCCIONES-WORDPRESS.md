# Instalación del Presupuestador en maderafina.es (WordPress + Elementor)

## Opción A — Página Elementor con widget HTML (recomendado, 5 minutos)

1. En el panel de WordPress ir a **Páginas → Añadir nueva**
2. Título: `Presupuestador` (slug sugerido: `/presupuestador/`)
3. Hacer clic en **Editar con Elementor**
4. Añadir un widget **HTML** (buscarlo en la barra lateral izquierda de Elementor)
5. Abrir el archivo `elementor-embed.html` (ver más abajo cómo generarlo) y pegar todo su contenido en el campo del widget
6. Guardar y publicar
7. Proteger la página con contraseña desde **Visibilidad → Protegido con contraseña** para que solo la vean los técnicos

---

## Opción B — Página independiente en el servidor (más sencillo)

1. Subir el archivo `index.html` al servidor vía FTP/SFTP o el gestor de archivos de cPanel
   - Ruta sugerida: `/public_html/presupuestador/index.html`
2. Acceder desde el navegador en: `https://maderafina.es/presupuestador/`
3. Proteger con `.htaccess` si se quiere acceso solo para técnicos:

```apache
AuthType Basic
AuthName "Acceso restringido"
AuthUserFile /ruta/.htpasswd
Require valid-user
```

---

## Opción C — iFrame dentro de una página WordPress (alternativa rápida)

1. Subir `index.html` al servidor (igual que Opción B)
2. En cualquier página WordPress, añadir un widget HTML de Elementor con:

```html
<iframe src="https://maderafina.es/presupuestador/index.html"
        width="100%" height="900px"
        style="border:none;border-radius:10px">
</iframe>
```

---

## Notas importantes

- El archivo no necesita PHP, base de datos ni plugins adicionales
- Funciona 100% en el navegador del técnico
- Los precios están hardcodeados en el JS — para actualizarlos editar los valores en el array `PRODUCTS` y `SUPPLEMENTS` dentro del `<script>` del archivo HTML
- Compatible con Chrome, Firefox, Safari, Edge
