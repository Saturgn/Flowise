# Presupuestador Madera Fina

Calculadora de presupuestos al instante, inspirada en la rapidez del
configurador de [Tylko](https://tylko.com) y pensada para sustituir al
presupuestador actual (lento) de [maderafina.es](https://maderafina.es).

## Por qué es rápido

- **Un único archivo HTML**, sin frameworks, sin build, sin llamadas a
  servidor ni CDN. Todo (HTML + CSS + JS) va inline, así que carga y
  responde de forma instantánea incluso en móvil con conexión mala.
- El precio se recalcula **en el cliente**, al vuelo, con cada cambio
  (slider, selector, checkbox) — sin recargar la página ni esperar a un
  backend.
- Cero dependencias externas = cero peticiones de red = cero tiempos de
  espera.

## Cómo usarlo

Abre `index.html` en un navegador. Funciona igual como archivo local, en
un hosting estático o embebido con un `<iframe>` dentro de una página de
WordPress/otro CMS:

```html
<iframe src="https://tu-dominio.es/presupuestador/" style="width:100%;height:900px;border:0;"></iframe>
```

## Flujo para el usuario

1. **Elige producto**: Tableros a medida, Escritorios a medida o
   Estanterías a medida.
2. **Configura**: medidas con sliders, material, acabado y extras. La
   vista previa esquemática y el precio se actualizan al instante.
3. **Solicita el presupuesto**: rellena nombre y email (teléfono y
   comentarios opcionales) y pulsa "Enviar solicitud". Esto:
   - Abre el cliente de correo del usuario con un `mailto:` prerellenado
     dirigido a `CONFIG.contactEmail`, con el desglose completo.
   - También puede **descargar** el resumen como `.txt`.
   - Puede **copiar un enlace** que reabre el configurador con esa
     configuración exacta (útil para guardarlo o compartirlo).

No hay backend: es intencionado, para que sea instantáneo. El envío usa
`mailto:` como mecanismo simple y universal. Ver más abajo cómo conectarlo
a un backend real si lo necesitas.

## Cómo editar precios y catálogo

Todo el negocio vive en el objeto `CONFIG` al principio del `<script>` de
`index.html`. Los números actuales son **valores de ejemplo** — ajústalos
a tus tarifas reales:

```js
const CONFIG = {
  contactEmail: 'presupuestos@maderafina.es', // a dónde llega el mailto:
  whatsapp: '34600000000',                    // reservado por si quieres añadir un botón de WhatsApp
  iva: 0.21,

  materials: [ ... ],   // €/m² por material, compartido entre los 3 productos
  finishes: [ ... ],    // recargo €/m² por acabado, compartido

  tablero: { ... },     // grosores disponibles, precio de canteado/taladros, pedido mínimo
  escritorio: { ... },  // factor de refuerzo del tablero, tipos de pata, extras
  estanteria: { ... },  // factor del panel trasero, precio de puertas/cajones/patas/montaje
};
```

### Fórmulas de precio (resumen)

- **Tableros**: `área (m²) × precio material × (grosor/19) + área × recargo acabado + extras`,
  con un pedido mínimo configurable.
- **Escritorios**: igual que un tablero pero con un factor de refuerzo
  (`structureFactor`) por ser una superficie de trabajo, más el precio de
  las patas elegidas y los extras marcados (cajonera, pasacables,
  estructura elevable, montaje).
- **Estanterías**: suma el área de los dos laterales + el área de cada
  balda + (opcional) un panel trasero más fino, todo al precio del
  material elegido; las puertas y cajones se cobran aparte según su
  tamaño/cantidad.

Todas las líneas de precio se muestran desglosadas en el panel derecho
para que el cliente vea de dónde sale el total.

## Conectar con un backend real (opcional)

Para dejar de depender de `mailto:` y guardar los presupuestos en un CRM,
sustituye el bloque `sendBtn` (búscalo por `getElementById('sendBtn')`)
por una llamada `fetch()` a tu endpoint (por ejemplo Formspree, un
webhook de Make/Zapier, o tu propia API), enviando el mismo objeto de
`state` y el desglose de `calcCurrent()`.

## Estructura del archivo

- `CONFIG`: catálogo y precios (edítalo tú).
- `state`: valores actuales elegidos por el usuario, uno por producto.
- `calcTablero / calcEscritorio / calcEstanteria`: lógica de precios.
- `drawPreview`: dibuja la vista previa esquemática en SVG (sin
  imágenes, así que no añade peso ni peticiones).
- `renderOptions` / `bindOptionEvents`: pintan y conectan los controles
  de cada producto.
- `openModal` / `sendBtn` / `downloadBtn` / `shareBtn`: flujo final de
  solicitud de presupuesto.
