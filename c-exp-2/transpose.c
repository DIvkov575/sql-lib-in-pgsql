#include "postgres.h"
#include "fmgr.h"
#include "utils/array.h"

PG_MODULE_MAGIC;

PG_FUNCTION_INFO_V1(transpose);

Datum transpose(PG_FUNCTION_ARGS) {
    int rows = PG_GETARG_INT32(1);
    int cols = PG_GETARG_INT32(2);
    int i, j;

    if (cols <= 0 || rows <= 0) {
        ereport(ERROR,
                (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
                        errmsg("Invalid matrix dimensions: rows and cols must be greater than zero")));
    }

    /* Input matrix */
    int32 **matrix = (int32 **) PG_GETARG_POINTER(0);

    /* Transposed matrix */
    int32 **transposed_matrix = palloc(sizeof(int32 *) * cols);

    for (i = 0; i < cols; i++) {
        transposed_matrix[i] = palloc(sizeof(int32) * rows);
        for (j = 0; j < rows; j++) {
            transposed_matrix[i][j] = matrix[j][i];
        }
    }

    PG_RETURN_POINTER(transposed_matrix);
}
