#!/bin/bash

# Script para ejecutar todos los tests de My Finances App
# Autor: My Finances Team
# Fecha: $(date)

echo "🧪 Ejecutando tests para My Finances App"
echo "========================================"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar resultados
show_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2 completado exitosamente${NC}"
    else
        echo -e "${RED}❌ $2 falló${NC}"
        exit 1
    fi
}

# Función para mostrar información
show_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Función para mostrar advertencia
show_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: No se encontró pubspec.yaml. Ejecuta este script desde la raíz del proyecto.${NC}"
    exit 1
fi

# Limpiar y obtener dependencias
show_info "Limpiando y obteniendo dependencias..."
flutter clean
flutter pub get
show_result $? "Limpieza y obtención de dependencias"

# Ejecutar análisis estático
show_info "Ejecutando análisis estático..."
flutter analyze
show_result $? "Análisis estático"

# Ejecutar tests unitarios
show_info "Ejecutando tests unitarios..."
flutter test test/unit/ --reporter=expanded
show_result $? "Tests unitarios"

# Ejecutar tests de widgets
show_info "Ejecutando tests de widgets..."
flutter test test/widget/ --reporter=expanded
show_result $? "Tests de widgets"

# Ejecutar test principal
show_info "Ejecutando test principal..."
flutter test test/widget_test.dart --reporter=expanded
show_result $? "Test principal"

# Ejecutar tests de integración (si hay dispositivo conectado)
show_info "Verificando dispositivos para tests de integración..."
if flutter devices | grep -q "connected"; then
    show_info "Ejecutando tests de integración..."
    flutter test integration_test/ --reporter=expanded
    show_result $? "Tests de integración"
else
    show_warning "No hay dispositivos conectados. Saltando tests de integración."
fi

# Ejecutar tests con cobertura
show_info "Ejecutando tests con cobertura..."
flutter test --coverage --reporter=expanded
show_result $? "Tests con cobertura"

# Mostrar resumen
echo ""
echo "🎉 ¡Todos los tests completados!"
echo "========================================"
echo -e "${GREEN}✅ Tests unitarios: Completados${NC}"
echo -e "${GREEN}✅ Tests de widgets: Completados${NC}"
echo -e "${GREEN}✅ Test principal: Completado${NC}"
if flutter devices | grep -q "connected"; then
    echo -e "${GREEN}✅ Tests de integración: Completados${NC}"
else
    echo -e "${YELLOW}⚠️  Tests de integración: Saltados (sin dispositivo)${NC}"
fi
echo -e "${GREEN}✅ Tests con cobertura: Completados${NC}"
echo ""
echo -e "${BLUE}📊 Para ver el reporte de cobertura, ejecuta:${NC}"
echo "genhtml coverage/lcov.info -o coverage/html"
echo "open coverage/html/index.html"
echo ""
echo -e "${BLUE}📝 Para ejecutar tests específicos:${NC}"
echo "flutter test test/unit/models/transaction_test.dart"
echo "flutter test test/widget/dashboard_screen_test.dart"
echo "flutter test integration_test/app_test.dart" 