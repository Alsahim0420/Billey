# Tests para Billey App

Esta carpeta contiene todos los tests para la aplicación Billey, incluyendo tests unitarios, de widgets y de integración.

## Estructura de Tests

```
test/
├── unit/                          # Tests unitarios
│   ├── models/                    # Tests para modelos de datos
│   │   ├── transaction_test.dart  # Tests para TransactionModel
│   │   └── category_test.dart     # Tests para CategoryModel
│   └── providers/                 # Tests para providers
│       └── transaction_provider_test.dart
├── widget/                        # Tests de widgets
│   └── dashboard_screen_test.dart # Tests para DashboardScreen
├── integration_test/              # Tests de integración
│   └── app_test.dart             # Tests de integración completos
├── widget_test.dart              # Test principal de widgets
└── README.md                     # Esta documentación
```

## Tipos de Tests

### 1. Tests Unitarios (`test/unit/`)
- **Propósito**: Probar la lógica de negocio individual
- **Cobertura**: Modelos, providers, utilidades
- **Ejecución**: `flutter test test/unit/`

### 2. Tests de Widgets (`test/widget/`)
- **Propósito**: Probar la interfaz de usuario
- **Cobertura**: Pantallas, widgets, interacciones
- **Ejecución**: `flutter test test/widget/`

### 3. Tests de Integración (`integration_test/`)
- **Propósito**: Probar el flujo completo de la aplicación
- **Cobertura**: Navegación, funcionalidades end-to-end
- **Ejecución**: `flutter test integration_test/`

## Comandos para Ejecutar Tests

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests unitarios
```bash
flutter test test/unit/
```

### Ejecutar tests de widgets
```bash
flutter test test/widget/
```

### Ejecutar tests de integración
```bash
flutter test integration_test/
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

### Ejecutar tests específicos
```bash
flutter test test/unit/models/transaction_test.dart
```

## Cobertura de Tests

### Modelos (TransactionModel, CategoryModel)
- ✅ Creación de instancias
- ✅ Validación de propiedades
- ✅ Conversión a/desde JSON/Map
- ✅ Métodos de copia (copyWith)
- ✅ Extensiones y getters

### Providers (TransactionProvider, CategoryProvider)
- ✅ Inicialización
- ✅ Métodos CRUD
- ✅ Cálculos de totales
- ✅ Filtros y búsquedas
- ✅ Notificaciones de cambios

### Widgets (DashboardScreen)
- ✅ Renderizado correcto
- ✅ Estados vacíos
- ✅ Interacciones de usuario
- ✅ Navegación

### Integración
- ✅ Flujo completo de la app
- ✅ Navegación entre pantallas
- ✅ Funcionalidades principales
- ✅ Manejo de errores

## Configuración de Tests

### Dependencias
Las siguientes dependencias están configuradas en `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.4
  test: ^1.24.9
```

### Configuración de Mocking
Para tests que requieren mocks (como base de datos), se usa Mockito:

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([DatabaseHelper])
void main() {
  // Tests aquí
}
```

## Mejores Prácticas

### 1. Nomenclatura
- Usar nombres descriptivos para tests
- Agrupar tests relacionados con `group()`
- Usar `setUp()` para configuración común

### 2. Estructura AAA
- **Arrange**: Preparar datos y configuración
- **Act**: Ejecutar la acción a probar
- **Assert**: Verificar resultados

### 3. Tests Independientes
- Cada test debe ser independiente
- Limpiar estado entre tests
- No depender de orden de ejecución

### 4. Cobertura
- Apuntar a >80% de cobertura
- Probar casos edge y errores
- Incluir tests de integración

## Troubleshooting

### Problemas Comunes

1. **Tests fallan por dependencias**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   ```

2. **Tests de integración no funcionan**
   ```bash
   flutter test integration_test/ --device-id=<device-id>
   ```

3. **Problemas con Hive en tests**
   - Usar `TestWidgetsFlutterBinding.ensureInitialized()`
   - Inicializar Hive para tests

### Debugging Tests
```bash
# Ejecutar tests con verbose output
flutter test --verbose

# Ejecutar un test específico con debug
flutter test test/unit/models/transaction_test.dart --verbose
```

## Contribución

Al agregar nuevas funcionalidades:

1. **Escribir tests primero** (TDD)
2. **Mantener cobertura alta**
3. **Documentar casos edge**
4. **Actualizar esta documentación**

## Recursos Adicionales

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Mockito Documentation](https://pub.dev/packages/mockito) 