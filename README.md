# 🏋️ FitSense Mobile App

Aplicación móvil y web para gestión de entrenamiento físico y nutrición.

## 🚀 Deploy Status

✅ **Compilado para Web** - Listo para desplegar  
📦 **Build Size**: ~3 MB  
🔗 **Backend**: Railway (Producción)

---

## 📱 Plataformas Soportadas

- ✅ **Web** (Chrome, Firefox, Safari, Edge)
- ✅ **Android** (APK/App Bundle listo)
- ✅ **iOS** (Requiere Mac + Xcode)

---

## 🔥 Deploy a Firebase

### **Inicio Rápido**

```powershell
# 1. Actualizar Node.js a v20+ (ver NODE_UPDATE_REQUIRED.md)
# 2. Login a Firebase
firebase login

# 3. Conectar proyecto
firebase use --add

# 4. Desplegar
firebase deploy --only hosting
```

📖 **Guía completa**: Ver [README_DEPLOY.md](README_DEPLOY.md)

---

## 🛠️ Desarrollo

### **Ejecutar en modo desarrollo**

```bash
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

### **Compilar para producción**

```bash
flutter build web --release      # Web
flutter build apk --release      # Android APK
flutter build appbundle          # Android Bundle
flutter build ios --release      # iOS
```

---

## 📂 Estructura del Proyecto

```
lib/
├── main.dart                    # Entry point
├── features/
│   └── auth/
│       ├── data/               # Data sources & repositories
│       ├── domain/             # Entities & use cases
│       └── presentation/       # UI (screens & widgets)
│           ├── home/           # Home screens
│           ├── chatbot/        # Chatbot AI
│           ├── settings/       # Settings & profile
│           └── setup/          # Initial setup flow
├── core/
│   └── widgets/                # Shared widgets
└── infrastructure/
    ├── config/                 # App configuration
    └── services/               # External services
```

---

## 🌐 Configuración de APIs

### **URLs de Producción** (Railway)

```dart
// lib/infrastructure/config/app_config.dart

apiBaseUrl: 'https://fitsense-backend-services-production.up.railway.app/api/v1'
chatbotBaseUrl: 'https://chatbox-ai-production-6ead.up.railway.app'
```

---

## 📦 Dependencias Principales

- `firebase_core` & `firebase_storage` - Cloud storage
- `http` - HTTP requests
- `image_picker` - Selección de imágenes
- `shared_preferences` - Almacenamiento local
- `table_calendar` - Calendario de entrenamientos
- `intl` - Internacionalización

---

## 🔧 Scripts de Utilidad

### **Deploy Automático**
```powershell
.\deploy.ps1
```

### **Limpiar y Reconstruir**
```powershell
flutter clean
flutter pub get
flutter build web --release
```

---

## 📚 Documentación Adicional

- 📖 [README_DEPLOY.md](README_DEPLOY.md) - Guía completa de deploy
- 📖 [DEPLOY.md](DEPLOY.md) - Instrucciones detalladas Firebase
- 📖 [NODE_UPDATE_REQUIRED.md](NODE_UPDATE_REQUIRED.md) - Actualizar Node.js
- 📖 [PLATFORM_DETECTION.md](PLATFORM_DETECTION.md) - Detección de plataforma
- 📖 [ROADMAP.md](ROADMAP.md) - Roadmap del proyecto

---

## 🆘 Soporte

### **Errores comunes**

- **Node.js versión incompatible**: Ver [NODE_UPDATE_REQUIRED.md](NODE_UPDATE_REQUIRED.md)
- **Firebase CLI no funciona**: `npm install -g firebase-tools`
- **Build falla**: `flutter clean && flutter pub get`

---

## 🎯 Deploy Checklist

- [x] ✅ Código compilado (`flutter build web --release`)
- [x] ✅ Configuración Firebase lista (`firebase.json`)
- [ ] 🔲 Node.js actualizado (v20+)
- [ ] 🔲 Firebase CLI instalado
- [ ] 🔲 Proyecto Firebase creado
- [ ] 🔲 Deploy ejecutado

---

## 📞 Contacto & Links

- 🔗 [Firebase Console](https://console.firebase.google.com/)
- 🔗 [Railway Dashboard](https://railway.app/)
- 🔗 [Flutter Docs](https://docs.flutter.dev/)

---

**Desarrollado con Flutter 💙**
