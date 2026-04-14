# KILO CLI INTEGRATION - Instrucciones para Claude

## QUÉ ES KILO WRAPPER

Es un script (`./kilowrapper.sh`) que te permite enviar tareas a GLM (vía Kilo CLI) desde Claude Code.

## CÓMO USARLO EN CLAUDE

Cuando quieras que GLM ejecute algo, usa el Bash tool de Claude:

### Formato 1: Task simple (una línea):
```
Bash("kilo run 'Crear tabla Products en Drift con campos: id, barcode, name, price, stock' --model glm-5.1")
```

### Formato 2: Con spec detallada:
```
Bash("
  PREGUNTA: "Ejecuta la spec en specs/003-drift-database-setup.md"
  ARGUMENTOS: { command: "./kilowrapper.sh 'Ejecuta todas las tasks de specs/003-drift-database-setup.md'" }
")
```

### Formato 3: Revisar código generado por GLM:
```
Bash("
  PREGUNTA: "GLM generó código en lib/features/products/. Revisa los archivos y verifica:
  - Tipado correcto Dart
  - Sigue patrones Riverpod/Drift
  - No errores obvios
  Comando a ejecutar: find lib/features/products -name '*.dart' | head -10"
)
```

## EJEMPLOS DE FLUJO COMPLETO

### Ejemplo 1: Crear feature completa

Tú: "Claude, crea la base de datos Drift y haz que GLM la implemente"

Claude:
1. Genera spec detallada en `specs/`
2. Usa Bash tool: `./kilowrapper.sh 'Ejecuta specs/003...'`
3. Espera respuesta de GLM
4. Revisa con Bash: `find lib/ -name '*.dart' | head -20`
5. Si hay errores → genera corrections spec y ejecuta de nuevo

### Ejemplo 2: Debuggear

Tú: "Hay errores en el código que generó GLM"

Claude:
1. Lee los archivos con Bash: `find lib -name '*.dart' -exec cat {} \;`
2. Identifica errores
3. Genera spec de correcciones
4. Ejecuta: `./kilowrapper.sh 'Corrige estos errores: [pegar errores]'`
