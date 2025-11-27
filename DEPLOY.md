# FitSense - Instrucciones de Deploy a Firebase

## 📦 Prerequisites

1. **Node.js** instalado (para Firebase CLI)
2. **Flutter** instalado y configurado
3. Cuenta de Firebase/Google

---

## 🔥 Instalación de Firebase CLI

```powershell
# Instalar Firebase CLI globalmente
npm install -g firebase-tools

# Verificar instalación
firebase --version
```

---

## 🚀 Pasos para Deploy

### 1. Login a Firebase

```powershell
firebase login
```

Se abrirá tu navegador para autenticarte con tu cuenta de Google.

### 2. Inicializar Proyecto Firebase (Solo primera vez)

```powershell
# En la raíz del proyecto
firebase init hosting

# Responde:
# - Use an existing project? → Sí (selecciona tu proyecto de Firebase)
# - What do you want to use as your public directory? → build/web
# - Configure as a single-page app? → Sí
# - Set up automatic builds? → No
# - File build/web/index.html already exists. Overwrite? → No
```

### 3. Compilar para Web

```powershell
# Limpiar builds anteriores
flutter clean

# Compilar para producción web
flutter build web --release

# O con optimizaciones adicionales:
flutter build web --release --web-renderer canvaskit
```

### 4. Desplegar a Firebase

```powershell
# Deploy
firebase deploy

# O solo hosting
firebase deploy --only hosting
```

---

## 🌐 Tu App estará disponible en:

```
https://fitsense-mobile-app.web.app
```

O tu dominio personalizado si lo configuraste.

---

## 📝 Comandos Útiles

### Ver Preview Local

```powershell
firebase serve
```

### Ver URL de Deploy

```powershell
firebase hosting:channel:list
```

### Rollback a versión anterior

```powershell
firebase hosting:rollback
```

### Ver logs

```powershell
firebase hosting:logs
```

---

## 🔧 Configuración Actual

- **API Backend**: `https://fitsense-backend-services-production.up.railway.app/api/v1`
- **Chatbot**: `https://chatbox-ai-production-6ead.up.railway.app`
- **Build Output**: `build/web/`
- **Renderer**: CanvasKit (mejor rendimiento)

---

## ⚙️ Variables de Entorno (Opcional)

Si necesitas diferentes URLs para staging/producción:

```powershell
# Para desarrollo
flutter build web --dart-define=ENV=dev

# Para producción
flutter build web --dart-define=ENV=prod
```

Y en `app_config.dart`:

```dart
static String get apiBaseUrl {
  const env = String.fromEnvironment('ENV', defaultValue: 'prod');
  return env == 'dev' 
    ? 'http://localhost:8080/api/v1' 
    : 'https://fitsense-backend-services-production.up.railway.app/api/v1';
}
```

---

## 🐛 Troubleshooting

### Error: Firebase project not found
```powershell
firebase use --add
# Selecciona tu proyecto
```

### Error: Permission denied
```powershell
firebase login --reauth
```

### Build muy pesado
```powershell
# Usa el renderer HTML en lugar de CanvasKit
flutter build web --release --web-renderer html
```

---

## 📊 Checklist de Deploy

- [ ] Instalar Firebase CLI
- [ ] Login a Firebase (`firebase login`)
- [ ] Compilar para web (`flutter build web --release`)
- [ ] Desplegar (`firebase deploy`)
- [ ] Verificar URL en consola
- [ ] Probar la aplicación en producción

---

## 🎯 Deploy Rápido (Script)

Crea un archivo `deploy.ps1`:

```powershell
# Limpiar
flutter clean

# Obtener dependencias
flutter pub get

# Compilar
Write-Host "🔨 Compilando para Web..." -ForegroundColor Cyan
flutter build web --release --web-renderer canvaskit

# Deploy
Write-Host "🚀 Desplegando a Firebase..." -ForegroundColor Green
firebase deploy --only hosting

Write-Host "✅ Deploy completado!" -ForegroundColor Green
```

Ejecutar:
```powershell
.\deploy.ps1
```

