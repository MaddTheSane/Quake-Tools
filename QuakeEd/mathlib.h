#ifndef __MATHLIB__
#define __MATHLIB__

#include "cmdlib.h"
#include <stdbool.h>
#include <simd/simd.h>

// mathlib.h

typedef float vec_t;
typedef vector_float3 vec3_t;

extern vec3_t vec3_origin;

bool VectorCompare (vec3_t v1, vec3_t v2);

#define DotProduct(x,y) vector_dot(x,y)
#define VectorSubtract(a,b,c) {c = a - b;}
#define VectorAdd(a,b,c) {c = a + b;}
#define VectorCopy(a,b) { b = a;}

vec_t _DotProduct (vec3_t v1, vec3_t v2);
void _VectorSubtract (vec3_t va, vec3_t vb, vec3_t out) UNAVAILABLE_ATTRIBUTE;
void _VectorAdd (vec3_t va, vec3_t vb, vec3_t out) UNAVAILABLE_ATTRIBUTE;
void _VectorCopy (vec3_t in, vec3_t out) UNAVAILABLE_ATTRIBUTE;

vec3_t CrossProduct (vec3_t v1, vec3_t v2);
vec3_t VectorNormalize (vec3_t v);
vec3_t VectorScale (vec3_t v, vec_t scale);
double VectorLength(vec3_t v);
vec3_t VectorMA (vec3_t va, double scale, vec3_t vb);

#endif
