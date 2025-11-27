# 🚀 FitSense - Deploy a Firebase Hosting

## ✅ Compilación Exitosa

Tu proyecto FitSense ha sido compilado exitosamente para Web. Los archivos están listos en: `build/web/`

---

## 📋 Paso a Paso para Deploy

### **Paso 1: Instalar Firebase CLI**

```powershell
npm install -g firebase-tools
```

Verifica la instalación:
```powershell
firebase --version
```

---

### **Paso 2: Login a Firebase**

```powershell
firebase login
```

Se abrirá tu navegador. Inicia sesión con tu cuenta de Google.

---

### **Paso 3: Crear Proyecto en Firebase Console**

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto" o "Add project"
3. Nombre sugerido: **fitsense-mobile-app**
4. Sigue los pasos (puedes desactivar Google Analytics si quieres)

---

### **Paso 4: Conectar tu Proyecto Local**

```powershell
cd D:\AndroidStudioProjects\Fitsense-Mobile-App
firebase use --add
```

Selecciona el proyecto que acabas de crear y presiona Enter para confirmar el alias.

---

### **Paso 5: Desplegar a Firebase** 🎉

```powershell
firebase deploy --only hosting
```

---

## 🎯 Deploy Rápido (Una Línea)

Si ya hiciste el setup, para futuros deploys solo ejecuta:

```powershell
.\deploy.ps1
```

O manualmente:

```powershell
flutter build web --release; firebase deploy --only hosting
```

---

## 🌐 Tu App Estará Disponible En:

Una vez desplegado, tu app estará en:

```
https://fitsense-mobile-app.web.app
```

O:

```
https://fitsense-mobile-app.firebaseapp.com
```

---

## 📂 Archivos de Configuración Creados

- ✅ `firebase.json` - Configuración de Firebase Hosting
- ✅ `.firebaserc` - Proyecto de Firebase asociado
- ✅ `deploy.ps1` - Script de deploy automático
- ✅ `DEPLOY.md` - Documentación completa
- ✅ `build/web/` - Archivos compilados (2.8 MB)

---

## 🛠️ Comandos Útiles

### Ver Preview Local (antes de deploy)
```powershell
firebase serve
```
Tu app estará en: `http://localhost:5000`

### Recompilar
```powershell
flutter clean
flutter build web --release
```

### Ver Hosting en Firebase Console
```powershell
firebase open hosting:site
```

### Rollback a versión anterior
```powershell
firebase hosting:channel:deploy preview
```

---

## ⚙️ Configuración Actual

### URLs del Backend (Producción)
- **API Principal**: `https://fitsense-backend-services-production.up.railway.app/api/v1`
- **Chatbot API**: `https://chatbox-ai-production-6ead.up.railway.app`

### Archivos Generados
- **main.dart.js**: 2.8 MB (código compilado)
- **Total build**: ~3 MB
- **Optimizaciones**: Tree-shaking habilitado (99% reducción en fuentes)

---

## 🔒 Seguridad y Performance

El archivo `firebase.json` ya incluye:
- ✅ Rewrite rules para SPA
- ✅ Cache headers optimizados
- ✅ Compresión automática
- ✅ CDN global de Firebase

---

## 📱 Soporte de Plataformas

Tu app compilada soporta:
- ✅ Chrome/Edge (Chromium)
- ✅ Firefox
- ✅ Safari
- ✅ Mobile browsers
- ✅ PWA (Progressive Web App)

---

## 🐛 Troubleshooting

### Error: "No se puede encontrar firebase"
```powershell
npm install -g firebase-tools
firebase login --reauth
```

### Error: "Project not found"
```powershell
firebase use --add
# Selecciona tu proyecto
```

### Error: "Permission denied"
```powershell
firebase login --reauth
```

### Build muy pesado
```powershell
# Usa renderer HTML en lugar de CanvasKit
flutter build web --release --web-renderer html
```

---

## 📊 Checklist de Deploy

- [x] ✅ Compilar para web (`flutter build web --release`)
- [x] ✅ Archivos de configuración Firebase creados
- [ ] 🔲 Instalar Firebase CLI (`npm install -g firebase-tools`)
- [ ] 🔲 Login a Firebase (`firebase login`)
- [ ] 🔲 Crear proyecto en Firebase Console
- [ ] 🔲 Conectar proyecto (`firebase use --add`)
- [ ] 🔲 Desplegar (`firebase deploy --only hosting`)
- [ ] 🔲 Verificar URL en navegador

---

## 🎓 Recursos Adicionales

- [Firebase Hosting Docs](https://firebase.google.com/docs/hosting)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)

---

## 💡 Próximos Pasos

1. **Deploy a Firebase** (siguiendo los pasos arriba)
2. **Configurar dominio personalizado** (opcional)
3. **Habilitar Analytics** (opcional)
4. **Configurar CI/CD** con GitHub Actions (opcional)

---

## 🆘 Soporte

Si tienes problemas:
1. Verifica que estés logueado: `firebase login`
2. Verifica el proyecto: `firebase projects:list`
3. Revisa logs: `firebase hosting:logs`

---

**¡Tu app está lista para ser desplegada! 🚀**

Ejecuta: `firebase deploy --only hosting`

