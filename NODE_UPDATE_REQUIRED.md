# ⚠️ Actualización de Node.js Requerida

## 🔍 Problema Detectado

Firebase CLI v14.25.0 requiere Node.js versión **>=20.0.0**

Tu versión actual: **v18.17.1**

---

## 📥 Solución: Actualizar Node.js

### **Opción 1: Descarga Directa (Recomendado)**

1. Ve a [nodejs.org](https://nodejs.org/)
2. Descarga **Node.js LTS** (versión 22.x o superior)
3. Ejecuta el instalador
4. Reinicia PowerShell

### **Opción 2: Usando Chocolatey**

Si tienes Chocolatey instalado:

```powershell
choco upgrade nodejs-lts -y
```

### **Opción 3: Usando NVM (Node Version Manager)**

```powershell
# Instalar NVM para Windows
# Descarga desde: https://github.com/coreybutler/nvm-windows/releases

# Luego instala Node.js 22
nvm install 22
nvm use 22
```

---

## ✅ Verificar Instalación

Después de actualizar, verifica:

```powershell
node --version
# Debería mostrar v20.x.x o superior

npm --version
# Debería funcionar correctamente

firebase --version
# Ya no debería mostrar error
```

---

## 🚀 Continuar con Deploy

Una vez actualizado Node.js, puedes continuar con:

```powershell
# 1. Login a Firebase
firebase login

# 2. Conectar proyecto
firebase use --add

# 3. Desplegar
firebase deploy --only hosting
```

---

## 📝 Alternativa: Usar Firebase sin CLI (Consola Web)

Si prefieres no actualizar Node.js ahora, puedes desplegar manualmente:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un proyecto
3. Ve a **Hosting** → **Get Started**
4. Arrastra la carpeta `build/web` a la consola
5. ¡Listo!

---

## 🔗 Enlaces Útiles

- [Node.js Downloads](https://nodejs.org/)
- [NVM for Windows](https://github.com/coreybutler/nvm-windows)
- [Firebase Console](https://console.firebase.google.com/)

