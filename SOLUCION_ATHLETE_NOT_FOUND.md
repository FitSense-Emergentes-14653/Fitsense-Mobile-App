# ✅ SOLUCIÓN: Error "Athlete not found" al Incrementar Agua

**Fecha:** 2025-12-01  
**Error Original:** 500 Internal Server Error - "Athlete not found"

---

## 🔍 Diagnóstico del Problema

### Error del Backend
```json
{
  "status": 500,
  "error": "Internal Server Error",
  "message": "Athlete not found",
  "path": "/api/v1/hydration/5"
}
```

### Causa Raíz
El frontend estaba enviando `userId: 5` al backend, pero ese ID **no corresponde al `athleteId`** en la base de datos.

**Problema:**
```dart
// ❌ ANTES: Usaba userId (parámetro del widget)
final water = await _waterService.getTodayWaterIntake(widget.userId); // userId = 5
await _waterService.incrementWaterIntake(widget.userId); // Error: Athlete not found
```

**¿Por qué fallaba?**
- `userId` es el ID del usuario (User table)
- `athleteId` es el ID del perfil de atleta (Athlete table)
- Son IDs **diferentes** en tablas diferentes
- El backend espera `athleteId` pero recibía `userId`

---

## ✅ Solución Implementada

### Cambio Principal
Obtener el `athleteId` correcto desde `SessionService` en lugar de usar `widget.userId`.

### Archivo Modificado
`lib/features/auth/presentation/home/tabs/metrics_tab.dart`

### Cambios Realizados

#### 1. Import de SessionService
```dart
import 'package:fitsense/infrastructure/services/session_service.dart';
```

#### 2. Nueva Variable de Estado
```dart
final SessionService _session = SessionService();
int? _athleteId; // ID correcto del atleta desde la sesión
```

#### 3. Nuevo Método de Inicialización
```dart
Future<void> _initSession() async {
  await _session.init();
  _athleteId = _session.getAthleteId();
  
  print('📊 [METRICS TAB] User ID (parámetro): ${widget.userId}');
  print('📊 [METRICS TAB] Athlete ID (sesión): $_athleteId');
  
  if (_athleteId != null && _athleteId! > 0) {
    _loadData();
  } else {
    // Mostrar error si no se pudo obtener el ID
  }
}
```

#### 4. Actualización de Métodos
**Todos los métodos ahora usan `_athleteId!` en lugar de `widget.userId`:**

```dart
// _loadData()
final water = await _waterService.getTodayWaterIntake(_athleteId!);
final calories = await _mealService.getDailySummary(_athleteId!);

// _incrementWater()
final updated = await _waterService.incrementWaterIntake(_athleteId!);

// _decrementWater()
final updated = await _waterService.decrementWaterIntake(_athleteId!);

// _updateGoal()
final updated = await _waterService.updateGoal(_athleteId!, newGoal);
```

---

## 🧪 Verificación

### Logs Esperados Ahora
```
📊 [METRICS TAB] ========== INICIALIZACIÓN ==========
📊 [METRICS TAB] User ID (parámetro): 5
📊 [METRICS TAB] Athlete ID (sesión): 8  <-- ID correcto
📊 [METRICS TAB] ==========================================
📊 [METRICS TAB] Iniciando carga de datos...
📊 [METRICS TAB] Athlete ID: 8
🔵 [HYDRATION] GET Request URL: http://localhost:8080/api/v1/hydration/8
🔵 [HYDRATION] Response Status: 200  <-- ✓ Éxito
```

### Al Incrementar Agua
```
➕ [METRICS TAB] ========== INCREMENTAR AGUA ==========
➕ [METRICS TAB] Athlete ID: 8  <-- Usa el ID correcto
💧 [ADD WATER] POST Request URL: http://localhost:8080/api/v1/hydration/8?amount=250
💧 [ADD WATER] Response Status: 200  <-- ✓ Éxito
💧 [ADD WATER] Response Body: {"total":250,"hydrationGoal":2000,...}
➕ [METRICS TAB] Respuesta del servicio: ✓ Exitoso
➕ [METRICS TAB] Nuevo estado: 1 / 8
```

---

## 🎯 Resultado Esperado

### ✅ Antes del Fix
```
❌ Error 500: Athlete not found
❌ UserId: 5 (incorrecto)
❌ Backend no encuentra el atleta
```

### ✅ Después del Fix
```
✓ Response 200: OK
✓ AthleteId: 8 (correcto, desde sesión)
✓ Backend encuentra el atleta
✓ Agua se incrementa correctamente
✓ UI se actualiza
```

---

## 📋 Checklist de Validación

Ejecuta la app y verifica:

- [ ] **Logs de inicialización aparecen**
  ```
  📊 [METRICS TAB] User ID (parámetro): 5
  📊 [METRICS TAB] Athlete ID (sesión): 8
  ```

- [ ] **athleteId es diferente de userId**
  - Si son iguales, es posible que sí sean el mismo
  - Si son diferentes, ahora usa el correcto

- [ ] **GET /hydration/{athleteId} responde 200**
  ```
  🔵 [HYDRATION] Response Status: 200
  ```

- [ ] **Al presionar "+", POST responde 200**
  ```
  💧 [ADD WATER] Response Status: 200
  ```

- [ ] **El número de vasos se incrementa**
  ```
  ➕ [METRICS TAB] Nuevo estado: 1 / 8
  ```

- [ ] **SnackBar verde aparece**
  ```
  ✓ Agua agregada: 1 / 8 vasos
  ```

---

## 🐛 Si Aún No Funciona

### Problema 1: athleteId es null
**Log:**
```
❌ [METRICS TAB] athleteId no válido: null
```

**Solución:**
1. Verifica que la sesión esté guardada correctamente
2. Hacer logout y login nuevamente
3. Verificar que `SessionService.getAthleteId()` retorna un valor

### Problema 2: athleteId existe pero backend dice "not found"
**Log:**
```
💧 [ADD WATER] Response Status: 500
💧 [ADD WATER] Response Body: {"message":"Athlete not found"}
```

**Solución:**
Verificar en el backend (base de datos):
```sql
SELECT * FROM athletes WHERE id = 8;
```

Si no existe, el problema es que la sesión tiene un `athleteId` inválido.

### Problema 3: athleteId es 0
**Log:**
```
📊 [METRICS TAB] Athlete ID (sesión): 0
```

**Solución:**
1. La sesión no tiene datos
2. Hacer logout completo
3. Login nuevamente
4. Verificar que después del setup se guarde el athleteId

---

## 📁 Archivos Modificados

- ✅ `lib/features/auth/presentation/home/tabs/metrics_tab.dart`
  - Línea ~7: Import de SessionService
  - Línea ~19-20: Nuevas variables (_session, _athleteId)
  - Línea ~30-55: Método `_initSession()` agregado
  - Línea ~57-70: `_loadData()` actualizado
  - Línea ~72-90: `_incrementWater()` actualizado
  - Línea ~92-110: `_decrementWater()` actualizado
  - Línea ~357-362: `_updateGoal()` actualizado

---

## ✅ Próximos Pasos

1. **Ejecutar la app:**
   ```bash
   flutter run -d chrome
   ```

2. **Ir a Métricas**

3. **Observar los logs de inicialización:**
   ```
   📊 [METRICS TAB] ========== INICIALIZACIÓN ==========
   📊 [METRICS TAB] User ID (parámetro): ???
   📊 [METRICS TAB] Athlete ID (sesión): ???
   ```

4. **Presionar el botón "+"**

5. **Verificar que aparezca:**
   - ⏳ Spinner
   - ✓ SnackBar verde
   - 🔢 Número incrementado

6. **Copiar todos los logs** y reportar si funciona o no.

---

**Con este cambio, el frontend ahora usa el `athleteId` correcto obtenido de la sesión, que debería coincidir con el atleta en la base de datos del backend.** 🎉

