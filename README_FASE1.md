# CyberPlatform — Fase 1: Movimiento

## Qué se implementó
- Proyecto Godot 4.x configurado para pixel art (resolución interna 320x180, escalado entero, filtrado Nearest, snapping de píxeles).
- Input Map: move_left (A/←), move_right (D/→), jump (Espacio/↑).
- Player (CharacterBody2D) con movimiento horizontal por aceleración/fricción y salto, usando gravedad del proyecto.
- StatusEffectManager (Node hijo del Player): infraestructura genérica para activar/desactivar efectos con duración, lista para Adware/Backdoor en la Fase 5. El Player ya consulta has_effect("inverted_controls") para invertir el input horizontal cuando corresponda (aún no hay ningún efecto que lo active).
- StatusEffect (scripts/effects/status_effect.gd): clase base/contrato para los futuros efectos concretos.
- Cámara2D con position_smoothing activado, hija del Player.
- Escena de prueba (scenes/test/test_main.tscn) con un suelo simple para poder probar el salto y el movimiento. Esta escena NO es el Nivel 1 real (eso es Fase 2); es solo para validar la mecánica base.
- Placeholders generados (PNG simples) para el jugador y el suelo.

## Estructura de archivos
```
CyberPlatform/
├── project.godot
├── scenes/
│   ├── player/player.tscn
│   ├── test/test_main.tscn
│   ├── levels/        (vacío, para Fase 2/6/7)
│   ├── ui/             (vacío, para Fase 4)
│   └── effects/        (vacío, para Fase 5)
├── scripts/
│   ├── player.gd
│   ├── status_effect_manager.gd
│   └── effects/status_effect.gd
└── assets/
	├── player/player_placeholder.png
	├── environment/ground_placeholder.png
	├── ui/          (vacío)
	└── effects/     (vacío)
```

## Dónde colocar cada archivo
Descomprime el .zip completo tal cual: la carpeta `CyberPlatform/` ES el proyecto de Godot. No muevas archivos individualmente; las rutas `res://scripts/...` y `res://assets/...` dependen de que la estructura se mantenga intacta.

## Cómo probarlo en Godot
1. Abre Godot 4.x (recomendado 4.3+).
2. "Import" → selecciona la carpeta `CyberPlatform/` (el archivo `project.godot`).
3. Al abrir el proyecto, la escena principal ya está configurada (`scenes/test/test_main.tscn`), así que solo pulsa **F5** (Run Project) o el botón de Play.
4. Deberías ver un rectángulo azul (el jugador) cayendo sobre una franja verde/marrón (el suelo).
5. Prueba:
   - `A`/`←` y `D`/`→` → moverse horizontalmente.
   - `Espacio`/`↑` → saltar (solo funciona si `is_on_floor()` es true).
6. Si quieres remapear teclas: Project → Project Settings → Input Map, ahí están `move_left`, `move_right`, `jump` ya creadas.

## Posibles errores y solución
- **"Identifier StatusEffectManager not declared"**: asegúrate de que `scripts/status_effect_manager.gd` tenga la línea `class_name StatusEffectManager` y que Godot haya reimportado los scripts (cierra y reabre el proyecto si acabas de copiar los archivos).
- **El jugador atraviesa el suelo**: revisa que la capa de colisión de `Ground` (StaticBody2D) y la de `Player` (CharacterBody2D) estén en la misma capa física (por defecto, capa 1 para ambos — no debería requerir cambios).
- **Los sprites se ven borrosos al escalar la ventana**: confirma en Project Settings → Rendering → Textures que "Default Texture Filter" esté en "Nearest" (ya viene configurado en `project.godot`, pero puede sobreescribirse si tocas el import de las texturas individualmente — en ese caso, selecciona el PNG en el FileSystem, pestaña "Import", y pon Filter = Off).
- **La ventana se abre en un tamaño raro**: es normal, el stretch mode "viewport" con aspect "keep" reescala 320x180 a 1280x720 (factor x4); si tu monitor es más pequeño, Godot ajustará la ventana pero mantendrá la proporción.
