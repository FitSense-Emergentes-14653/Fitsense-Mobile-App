# 🎯 Deploy FitSense a Firebase - Guía Rápida

## ⚡ Comando Rápido (Todo en uno)

```powershell
# Actualizar Node.js primero (ver abajo)
# Luego ejecutar:

firebase login && firebase use --add && firebase deploy --only hosting
```

---

## 📋 3 Pasos Esenciales

### **Paso 1: Actualizar Node.js** ⚠️
```
Versión actual: v18.17.1
Versión requerida: v20.0.0+

Descarga: https://nodejs.org/
```

### **Paso 2: Setup Firebase**
```powershell
firebase login
firebase use --add  # Selecciona o crea proyecto
```

### **Paso 3: Deploy** 🚀
```powershell
firebase deploy --only hosting
```

---

## ✅ Tu Build Está Listo

```
✅ Compilado: build/web/
✅ Tamaño: 31.2 MB
✅ Backend: Railway (Producción)
✅ Config: firebase.json
```

---

## 🌐 URLs

### Backend (Ya configurado)
```
API: https://fitsense-backend-services-production.up.railway.app/api/v1
Chatbot: https://chatbox-ai-production-6ead.up.railway.app
```

### Frontend (Después del deploy)
```
https://fitsense-mobile-app.web.app
https://fitsense-mobile-app.firebaseapp.com
```

---

## 📚 Documentación Completa

| Lee esto primero | Archivo |
|------------------|---------|
| ⭐ **Guía paso a paso** | [README_DEPLOY.md](README_DEPLOY.md) |
| ⚠️ **Actualizar Node.js** | [NODE_UPDATE_REQUIRED.md](NODE_UPDATE_REQUIRED.md) |
| 📖 **Deploy detallado** | [DEPLOY.md](DEPLOY.md) |

---

## 🔧 Script Automático

```powershell
# Ejecutar después del setup:
.\deploy.ps1
```

Este script hace:
1. Limpia builds anteriores
2. Obtiene dependencias
3. Compila para web
4. Despliega a Firebase

---

## 🆘 Problemas Comunes

### "Firebase CLI incompatible"
```powershell
# Actualiza Node.js a v20+
# Descarga: https://nodejs.org/
```

### "Project not found"
```powershell
firebase use --add
# Selecciona tu proyecto
```

### "Permission denied"
```powershell
firebase login --reauth
```

---

## 📊 Estado Actual

| Item | Estado |
|------|--------|
| Compilación Web | ✅ Completo |
| Config Firebase | ✅ Completo |
| Script Deploy | ✅ Completo |
| Documentación | ✅ Completo |
| Node.js v20+ | ⚠️ Pendiente |
| Firebase Login | ⚠️ Pendiente |
| Deploy | ⚠️ Pendiente |

---

**¡Todo configurado! Solo actualiza Node.js y ejecuta el deploy! 🚀**

