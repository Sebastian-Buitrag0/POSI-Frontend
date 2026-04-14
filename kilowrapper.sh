#!/bin/bash
# Wrapper para que Claude pueda llamar a Kilo CLI fácilmente

# Argumentos:
# $1 = Prompt/texto para GLM
# $2 = (opcional) Archivo de spec a leer (ruta)

PROMPT="${1:-$1}"
SPEC_FILE="${2:-}"

# Si hay spec file, leerla y agregar al prompt
if [ -n "$SPEC_FILE" ] && [ -f "$SPEC_FILE" ]; then
  SPEC_CONTENT=$(cat "$SPEC_FILE")
  PROMPT="$PROMPT\n\n=== ESPECIFICACIÓN DEL ARCHIVO ($SPEC_FILE) ===\n$SPEC_CONTENT"
fi

# Ejecutar Kilo CLI con el modelo GLM
exec kilo run "$PROMPT" --model glm-5.1
