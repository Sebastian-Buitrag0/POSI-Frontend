RESTRICCIONES IMPORTANTES
✅ SIEMPRE USA BASH TOOL DE CLAUDE PARA LLAMAR KILO
❌ NO copies y pegues manualmente entre Claude y Kilo (eso es lento)
🔄 EL FLUJO ES: Claude → Kilo (vía wrapper) → Claude (revisión) → siguiente task
EOF

text


---

### **Paso 3: Probar la integración**

En Claude Code, pega:

Testea la integración con Kilo.

Usa Bash tool para ejecutar:
./kilowrapper.sh "Responde 'Kilo CLI funcionando desde Claude' --model glm-4.7"

Luego revisa la salida.

text


Deberías ver que Claude ejecuta el comando y te muestra la respuesta de GLM.

---

## 💬 **CUANDO ESTÉ TODO LISTO, DIME:**

A) "✅ Kilo CLI instalado y configurado"
→ Te doy el primer flujo automatizado completo

B) "❌ Error al instalar/configurar Kilo"
→ Pega el error aquí

C) "✅ Todo listo, ¿qué hago primero?"
→ Te doy: "Paso 3: Base de Datos Drift con Claude+Kilo automatizado"

D) "¿Puedes mostrarme un ejemplo visual del flujo?"
→ Te dibujo un diagrama ASCII de cómo se ve la conversación