
#!/bin/bash

# Crear el archivo en lenguaje C
cat > suma.c << 'EOF'
int suma(int a, int b) {
    int r = a + b;
    return r;
}
EOF

# Generar ensamblador sin optimizaciones
gcc -O0 -S -masm=intel -fno-asynchronous-unwind-tables -fcf-protection=none suma.c

# Mostrar el ensamblador generado
echo "===== CODIGO ENSAMBLADOR ====="
cat suma.s
