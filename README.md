# 💸 Billey

La configuración y arquitectura de voz con ElevenLabs está documentada en
[docs/ELEVENLABS.md](docs/ELEVENLABS.md).

La recepción de gastos desde Apple Pay y Atajos, su configuración y las pruebas
pendientes en iPhone están documentadas en
[docs/APPLE_PAY_SHORTCUTS.md](docs/APPLE_PAY_SHORTCUTS.md).

Los presupuestos mensuales por categoría y su almacenamiento en Firebase están
documentados en [docs/CATEGORY_BUDGETS.md](docs/CATEGORY_BUDGETS.md).

![Billey](https://res.cloudinary.com/panmecar/image/upload/v1752550787/ChatGPT_Image_14_jul_2025_10_30_44_p.m._hpoaxj.png)

---

**Billey** es una aplicación móvil desarrollada en Flutter para gestionar tus finanzas personales de manera simple, visual y eficiente.

---

## ✨ Características

- **Dashboard interactivo** con balance, ingresos y gastos.
- **Gráficos modernos** para analizar tus gastos por categoría.
- **Gestión de categorías** personalizadas.
- **Soporte multimoneda** (COP, USD, EUR, etc).
- **Exportación de datos** en CSV.
- **Modo oscuro** elegante y consistente.

---

## 🖼️ Capturas de pantalla

![Screenshot 1](https://res.cloudinary.com/panmecar/image/upload/v1752550802/Simulator_Screenshot_-_iPhone_16_Plus_-_2025-07-14_at_19.49.35_b1exvu.png)

![Screenshot 2](https://res.cloudinary.com/panmecar/image/upload/v1752267739/Simulator_Screenshot_-_iPhone_16_Plus_-_2025-07-11_at_16.01.20_s5qp9s.png)

![Screenshot 3](https://res.cloudinary.com/panmecar/image/upload/v1752267739/Simulator_Screenshot_-_iPhone_16_Plus_-_2025-07-11_at_16.00.47_rtstly.png)

![Screenshot 4](https://res.cloudinary.com/panmecar/image/upload/v1752267738/Simulator_Screenshot_-_iPhone_16_Plus_-_2025-07-11_at_16.01.32_wiostg.png)

![Screenshot 5](https://res.cloudinary.com/panmecar/image/upload/v1752267739/Simulator_Screenshot_-_iPhone_16_Plus_-_2025-07-11_at_15.58.37_uoebhq.png)

---

## 🚀 Instalación

Versión configurada y comprobada: Flutter **3.47.4** (Dart **3.13.3**).
Si usas FVM, ejecuta `fvm install` y utiliza `fvm flutter` en los comandos
de abajo. VS Code apunta al enlace `.fvm/flutter_sdk` que crea FVM.
Si no usas FVM, selecciona tu instalación de Flutter con **Flutter: Change SDK**
en VS Code y comprueba su versión con `flutter --version`.

```bash
git clone https://github.com/Alsahim0420/Billey
cd Billey
flutter pub get
flutter run
```

---

## 🛠️ Tecnologías

- Flutter
- Hive
- Provider
- fl_chart
- intl

---

**Desarrollado con 💙💙 por Pablo Melo**
