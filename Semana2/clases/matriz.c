/* Adaptacion de scriptMatrizRecorrido.txt entregado en clase.
 * C almacena por filas. Se conserva N=4096 y la compilacion con -O0.
 * Se usa int64_t: long tiene 32 bits en Windows y la suma no cabe en el.
 */
#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>
#include <time.h>
#define N 4096
static int a[N][N];
int main(int argc, char **argv) {
    (void)argv;
    int por_columnas = argc > 1;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) a[i][j] = i + j;
    int64_t s = 0;
    clock_t t0 = clock();
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++)
            s += por_columnas ? a[j][i] : a[i][j];
    double seg = (double)(clock() - t0) / CLOCKS_PER_SEC;
    printf("%-9s %.6f s (suma = %" PRId64 ")\n", por_columnas ? "columnas" : "filas", seg, s);
    printf("Matriz: %d x %d; sizeof(int)=%zu; bytes=%zu\n", N,N,sizeof(int),sizeof(a));
    /* La misma suma permite verificar que ambos recorridos hacen el mismo trabajo. */
    return s == (int64_t)N * N * (N - 1) ? 0 : 1;
}
