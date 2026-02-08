#include "allegro_ffi.h"
#include <allegro5/allegro.h>

lean_object* allegro_al_create_transform(void) {
    ALLEGRO_TRANSFORM *t = (ALLEGRO_TRANSFORM *)malloc(sizeof(ALLEGRO_TRANSFORM));
    al_identity_transform(t);
    return io_ok_uint64(ptr_to_u64(t));
}

lean_object* allegro_al_destroy_transform(uint64_t transform) {
    if (transform != 0) {
        free(u64_to_ptr(transform));
    }
    return io_ok_unit();
}

lean_object* allegro_al_identity_transform(uint64_t transform) {
    if (transform != 0) {
        al_identity_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform));
    }
    return io_ok_unit();
}

lean_object* allegro_al_copy_transform(uint64_t dest, uint64_t src) {
    if (dest != 0 && src != 0) {
        al_copy_transform(
            (ALLEGRO_TRANSFORM *)u64_to_ptr(dest),
            (const ALLEGRO_TRANSFORM *)u64_to_ptr(src));
    }
    return io_ok_unit();
}

lean_object* allegro_al_use_transform(uint64_t transform) {
    if (transform != 0) {
        al_use_transform((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_current_transform(void) {
    const ALLEGRO_TRANSFORM *t = al_get_current_transform();
    /* Return a copy so the caller owns the memory */
    ALLEGRO_TRANSFORM *copy = (ALLEGRO_TRANSFORM *)malloc(sizeof(ALLEGRO_TRANSFORM));
    al_copy_transform(copy, t);
    return io_ok_uint64(ptr_to_u64(copy));
}

lean_object* allegro_al_translate_transform(uint64_t transform, double x, double y) {
    if (transform != 0) {
        al_translate_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)x, (float)y);
    }
    return io_ok_unit();
}

lean_object* allegro_al_rotate_transform(uint64_t transform, double theta) {
    if (transform != 0) {
        al_rotate_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)theta);
    }
    return io_ok_unit();
}

lean_object* allegro_al_scale_transform(uint64_t transform, double sx, double sy) {
    if (transform != 0) {
        al_scale_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)sx, (float)sy);
    }
    return io_ok_unit();
}

lean_object* allegro_al_build_transform(uint64_t transform, double x, double y, double sx, double sy, double theta) {
    if (transform != 0) {
        al_build_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
                           (float)x, (float)y, (float)sx, (float)sy, (float)theta);
    }
    return io_ok_unit();
}

lean_object* allegro_al_compose_transform(uint64_t transform, uint64_t other) {
    if (transform != 0 && other != 0) {
        al_compose_transform(
            (ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (const ALLEGRO_TRANSFORM *)u64_to_ptr(other));
    }
    return io_ok_unit();
}

lean_object* allegro_al_invert_transform(uint64_t transform) {
    if (transform != 0) {
        al_invert_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform));
    }
    return io_ok_unit();
}

lean_object* allegro_al_check_inverse(uint64_t transform, double tol) {
    if (transform == 0) {
        return io_ok_uint32(0);
    }
    return io_ok_uint32(
        al_check_inverse((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)tol) ? 1u : 0u);
}

lean_object* allegro_al_use_projection_transform(uint64_t transform) {
    if (transform != 0) {
        al_use_projection_transform((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform));
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_current_projection_transform(void) {
    const ALLEGRO_TRANSFORM *t = al_get_current_projection_transform();
    ALLEGRO_TRANSFORM *copy = (ALLEGRO_TRANSFORM *)malloc(sizeof(ALLEGRO_TRANSFORM));
    al_copy_transform(copy, t);
    return io_ok_uint64(ptr_to_u64(copy));
}

lean_object* allegro_al_orthographic_transform(uint64_t transform,
    double left, double top, double n,
    double right, double bottom, double f) {
    if (transform != 0) {
        al_orthographic_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)left, (float)top, (float)n,
            (float)right, (float)bottom, (float)f);
    }
    return io_ok_unit();
}

lean_object* allegro_al_perspective_transform(uint64_t transform,
    double left, double top, double n,
    double right, double bottom, double f) {
    if (transform != 0) {
        al_perspective_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)left, (float)top, (float)n,
            (float)right, (float)bottom, (float)f);
    }
    return io_ok_unit();
}

lean_object* allegro_al_horizontal_shear_transform(uint64_t transform, double theta) {
    if (transform != 0) {
        al_horizontal_shear_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)theta);
    }
    return io_ok_unit();
}

lean_object* allegro_al_vertical_shear_transform(uint64_t transform, double theta) {
    if (transform != 0) {
        al_vertical_shear_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform), (float)theta);
    }
    return io_ok_unit();
}

/* ── Tuple-returning queries ── */

lean_object* allegro_al_transform_coordinates(uint64_t transform, double x, double y) {
    if (transform == 0) return io_ok_f64_pair(x, y);
    float fx = (float)x, fy = (float)y;
    al_transform_coordinates((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform), &fx, &fy);
    return io_ok_f64_pair((double)fx, (double)fy);
}

/* ── 3D transforms ── */

lean_object* allegro_al_translate_transform_3d(uint64_t transform, double x, double y, double z) {
    if (transform != 0) {
        al_translate_transform_3d((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)x, (float)y, (float)z);
    }
    return io_ok_unit();
}

lean_object* allegro_al_rotate_transform_3d(uint64_t transform, double x, double y, double z, double angle) {
    if (transform != 0) {
        al_rotate_transform_3d((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)x, (float)y, (float)z, (float)angle);
    }
    return io_ok_unit();
}

lean_object* allegro_al_scale_transform_3d(uint64_t transform, double sx, double sy, double sz) {
    if (transform != 0) {
        al_scale_transform_3d((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)sx, (float)sy, (float)sz);
    }
    return io_ok_unit();
}

lean_object* allegro_al_transform_coordinates_3d(uint64_t transform, double x, double y, double z) {
    if (transform == 0) return io_ok_f64_triple(x, y, z);
    float fx = (float)x, fy = (float)y, fz = (float)z;
    al_transform_coordinates_3d((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform), &fx, &fy, &fz);
    return io_ok_f64_triple((double)fx, (double)fy, (double)fz);
}

lean_object* allegro_al_transform_coordinates_3d_projective(uint64_t transform, double x, double y, double z) {
    if (transform == 0) return io_ok_f64_triple(x, y, z);
    float fx = (float)x, fy = (float)y, fz = (float)z;
    al_transform_coordinates_3d_projective((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform), &fx, &fy, &fz);
    return io_ok_f64_triple((double)fx, (double)fy, (double)fz);
}

lean_object* allegro_al_transform_coordinates_4d(uint64_t transform, double x, double y, double z, double w) {
    if (transform == 0) return io_ok_f64_quad(x, y, z, w);
    float fx = (float)x, fy = (float)y, fz = (float)z, fw = (float)w;
    al_transform_coordinates_4d((const ALLEGRO_TRANSFORM *)u64_to_ptr(transform), &fx, &fy, &fz, &fw);
    return io_ok_f64_quad((double)fx, (double)fy, (double)fz, (double)fw);
}

lean_object* allegro_al_build_camera_transform(uint64_t transform,
    double px, double py, double pz,
    double lx, double ly, double lz,
    double ux, double uy, double uz) {
    if (transform != 0) {
        al_build_camera_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform),
            (float)px, (float)py, (float)pz,
            (float)lx, (float)ly, (float)lz,
            (float)ux, (float)uy, (float)uz);
    }
    return io_ok_unit();
}

lean_object* allegro_al_get_current_inverse_transform(void) {
    const ALLEGRO_TRANSFORM *t = al_get_current_inverse_transform();
    ALLEGRO_TRANSFORM *copy = (ALLEGRO_TRANSFORM *)malloc(sizeof(ALLEGRO_TRANSFORM));
    al_copy_transform(copy, t);
    return io_ok_uint64(ptr_to_u64(copy));
}

lean_object* allegro_al_transpose_transform(uint64_t transform) {
    if (transform != 0) {
        al_transpose_transform((ALLEGRO_TRANSFORM *)u64_to_ptr(transform));
    }
    return io_ok_unit();
}
