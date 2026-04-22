# INTEGRACIÓN DE AGENTES - Instrucciones para Claude

## AGENTES DISPONIBLES

| Agente | Script | Modelo | Cuándo usar |
|---|---|---|---|
| **GLM 5.1** | `./kilowrapper.sh` | zai/glm-5.1 | Tareas simples: CRUD, boilerplate, fixes pequeños |
| **Kimi k2.6** | `./kimiwrapper.sh` | kimi-for-coding | Features complejas, contexto largo (262k tokens), arquitectura |

## FLUJO DE TRABAJO

```
[Tú] → requisito en lenguaje natural
  ↓
[Claude Code] → analiza, genera spec detallada en specs/
  ↓
[Kimi/GLM] → implementa según spec
  ↓
[Claude Code] → revisa, corrige, integra
```

**Regla:** Ningún agente recibe instrucciones vagas. Todo lo que va a Kimi/GLM es una spec estructurada.

## CÓMO LLAMAR CADA AGENTE

### GLM — tareas simples
```bash
./kilowrapper.sh "Crea el widget ProductCard con campos: id, name, price, stock"
./kilowrapper.sh "Ejecuta la spec" specs/005-products-crud.md
./kilowrapper.sh "Tarea" specs/mi-spec.md --auto
```

### Kimi k2.6 — features complejas
```bash
./kimiwrapper.sh "Implementa el sistema de sincronización offline-first completo"
./kimiwrapper.sh "Ejecuta la spec" specs/011-sync-frontend.md
./kimiwrapper.sh "Implementa con plan" specs/mi-spec.md --plan
```

## CUÁNDO USAR CADA UNO

**GLM cuando:**
- Tarea < 200 líneas, completamente especificada
- Boilerplate repetitivo (DAOs, modelos, widgets simples)
- Fix puntual con contexto claro

**Kimi k2.6 cuando:**
- La feature toca múltiples archivos o capas
- Necesita entender mucho contexto del proyecto
- Requiere decisiones de arquitectura durante la implementación
- La spec es larga o compleja

## ESTRUCTURA DE SPEC (para ambos agentes)

```markdown
# [NNN] Nombre de la feature

## Objetivo
Una oración clara de qué debe hacer.

## Archivos a crear/modificar
- lib/features/X/...

## Comportamiento esperado
- Punto 1
- Punto 2

## Restricciones
- Usar Riverpod para estado
- Usar Drift para persistencia local
- No romper tests existentes

## Definición de hecho
- [ ] flutter analyze sin errores
- [ ] Feature funciona en modo offline
```

## FLUJO COMPLETO — Ejemplo

Tú: "Implementa descuentos en el POS"

Claude:
1. Genera `specs/016-discounts-pos.md`
2. Ejecuta: `./kimiwrapper.sh "Ejecuta la spec" specs/016-discounts-pos.md`
3. Revisa con: `flutter analyze` + leer archivos modificados
4. Si hay errores → genera spec de corrección y re-ejecuta con GLM o Kimi
