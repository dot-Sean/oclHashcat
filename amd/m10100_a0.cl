/**
 * Author......: Jens Steube <jens.steube@gmail.com>
 * License.....: MIT
 */

#define _SIPHASH_

#include "include/constants.h"
#include "include/kernel_vendor.h"

#ifdef  VLIW1
#define VECT_SIZE1
#endif

#ifdef  VLIW4
#define VECT_SIZE1
#endif

#ifdef  VLIW5
#define VECT_SIZE1
#endif

#define DGST_R0 0
#define DGST_R1 1
#define DGST_R2 2
#define DGST_R3 3

#include "include/kernel_functions.c"
#include "types_amd.c"
#include "common_amd.c"
#include "include/rp_gpu.h"
#include "rp_amd.c"

#ifdef  VECT_SIZE1
#define VECT_COMPARE_S "check_single_vect1_comp4.c"
#define VECT_COMPARE_M "check_multi_vect1_comp4.c"
#endif

#ifdef  VECT_SIZE2
#define VECT_COMPARE_S "check_single_vect2_comp4.c"
#define VECT_COMPARE_M "check_multi_vect2_comp4.c"
#endif

#ifdef  VECT_SIZE4
#define VECT_COMPARE_S "check_single_vect4_comp4.c"
#define VECT_COMPARE_M "check_multi_vect4_comp4.c"
#endif

#ifdef VECT_SIZE1
#define SIPROUND(v0,v1,v2,v3) \
  (v0) += (v1);               \
  (v1)  = rotl64 ((v1), 13);  \
  (v1) ^= (v0);               \
  (v0)  = as_ulong (as_uint2 ((v0)).s10); \
  (v2) += (v3);               \
  (v3)  = rotl64 ((v3), 16);  \
  (v3) ^= (v2);               \
  (v0) += (v3);               \
  (v3)  = rotl64 ((v3), 21);  \
  (v3) ^= (v0);               \
  (v2) += (v1);               \
  (v1)  = rotl64 ((v1), 17);  \
  (v1) ^= (v2);               \
  (v2)  = as_ulong (as_uint2 ((v2)).s10);
#else
#define SIPROUND(v0,v1,v2,v3) \
  (v0) += (v1);               \
  (v1)  = rotl64 ((v1), 13);  \
  (v1) ^= (v0);               \
  (v0)  = rotl64 ((v0), 32);  \
  (v2) += (v3);               \
  (v3)  = rotl64 ((v3), 16);  \
  (v3) ^= (v2);               \
  (v0) += (v3);               \
  (v3)  = rotl64 ((v3), 21);  \
  (v3) ^= (v0);               \
  (v2) += (v1);               \
  (v1)  = rotl64 ((v1), 17);  \
  (v1) ^= (v2);               \
  (v2)  = rotl64 ((v2), 32);
#endif

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_m04 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  /**
   * modifier
   */

  const u32 lid = get_local_id (0);

  /**
   * base
   */

  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32x pw_buf0[4];

  pw_buf0[0] = pws[gid].i[ 0];
  pw_buf0[1] = pws[gid].i[ 1];
  pw_buf0[2] = pws[gid].i[ 2];
  pw_buf0[3] = pws[gid].i[ 3];

  u32x pw_buf1[4];

  pw_buf1[0] = pws[gid].i[ 4];
  pw_buf1[1] = pws[gid].i[ 5];
  pw_buf1[2] = pws[gid].i[ 6];
  pw_buf1[3] = pws[gid].i[ 7];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * base
   */

  u64 v0p = SIPHASHM_0;
  u64 v1p = SIPHASHM_1;
  u64 v2p = SIPHASHM_2;
  u64 v3p = SIPHASHM_3;

  v0p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[1], salt_bufs[salt_pos].salt_buf[0]);
  v1p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[3], salt_bufs[salt_pos].salt_buf[2]);
  v2p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[1], salt_bufs[salt_pos].salt_buf[0]);
  v3p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[3], salt_bufs[salt_pos].salt_buf[2]);

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < rules_cnt; il_pos++)
  {
    u32x w[16];

    w[ 0] = pw_buf0[0];
    w[ 1] = pw_buf0[1];
    w[ 2] = pw_buf0[2];
    w[ 3] = pw_buf0[3];
    w[ 4] = pw_buf1[0];
    w[ 5] = pw_buf1[1];
    w[ 6] = pw_buf1[2];
    w[ 7] = pw_buf1[3];
    w[ 8] = 0;
    w[ 9] = 0;
    w[10] = 0;
    w[11] = 0;
    w[12] = 0;
    w[13] = 0;
    w[14] = 0;
    w[15] = 0;

    const u32x out_len = apply_rules (rules_buf[il_pos].cmds, &w[0], &w[4], pw_len);

    u64 *w_ptr = (u64 *) w;

    w_ptr[out_len / 8] |= (u64) out_len << 56;

    u64x v0 = v0p;
    u64x v1 = v1p;
    u64x v2 = v2p;
    u64x v3 = v3p;

    int i;
    int j;

    for (i = 0, j = 0; i <= pw_len; i += 8, j += 2)
    {
      u64x m = hl32_to_64 (w[j + 1], w[j + 0]);

      v3 ^= m;

      SIPROUND (v0, v1, v2, v3);
      SIPROUND (v0, v1, v2, v3);

      v0 ^= m;
    }

    v2 ^= 0xff;

    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);

    const u64x v = v0 ^ v1 ^ v2 ^ v3;

    const u32x a = l32_from_64 (v);
    const u32x b = h32_from_64 (v);

    const u32x r0 = a;
    const u32x r1 = b;
    const u32x r2 = 0;
    const u32x r3 = 0;

    #include VECT_COMPARE_M
  }
}

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_m08 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_m16 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_s04 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
  /**
   * modifier
   */

  const u32 lid = get_local_id (0);

  /**
   * base
   */

  const u32 gid = get_global_id (0);

  if (gid >= gid_max) return;

  u32x pw_buf0[4];

  pw_buf0[0] = pws[gid].i[ 0];
  pw_buf0[1] = pws[gid].i[ 1];
  pw_buf0[2] = pws[gid].i[ 2];
  pw_buf0[3] = pws[gid].i[ 3];

  u32x pw_buf1[4];

  pw_buf1[0] = pws[gid].i[ 4];
  pw_buf1[1] = pws[gid].i[ 5];
  pw_buf1[2] = pws[gid].i[ 6];
  pw_buf1[3] = pws[gid].i[ 7];

  const u32 pw_len = pws[gid].pw_len;

  /**
   * base
   */

  u64 v0p = SIPHASHM_0;
  u64 v1p = SIPHASHM_1;
  u64 v2p = SIPHASHM_2;
  u64 v3p = SIPHASHM_3;

  v0p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[1], salt_bufs[salt_pos].salt_buf[0]);
  v1p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[3], salt_bufs[salt_pos].salt_buf[2]);
  v2p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[1], salt_bufs[salt_pos].salt_buf[0]);
  v3p ^= hl32_to_64 (salt_bufs[salt_pos].salt_buf[3], salt_bufs[salt_pos].salt_buf[2]);

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[digests_offset].digest_buf[DGST_R0],
    digests_buf[digests_offset].digest_buf[DGST_R1],
    digests_buf[digests_offset].digest_buf[DGST_R2],
    digests_buf[digests_offset].digest_buf[DGST_R3]
  };

  /**
   * loop
   */

  for (u32 il_pos = 0; il_pos < rules_cnt; il_pos++)
  {
    u32x w[16];

    w[ 0] = pw_buf0[0];
    w[ 1] = pw_buf0[1];
    w[ 2] = pw_buf0[2];
    w[ 3] = pw_buf0[3];
    w[ 4] = pw_buf1[0];
    w[ 5] = pw_buf1[1];
    w[ 6] = pw_buf1[2];
    w[ 7] = pw_buf1[3];
    w[ 8] = 0;
    w[ 9] = 0;
    w[10] = 0;
    w[11] = 0;
    w[12] = 0;
    w[13] = 0;
    w[14] = 0;
    w[15] = 0;

    const u32x out_len = apply_rules (rules_buf[il_pos].cmds, &w[0], &w[4], pw_len);

    u64 *w_ptr = (u64 *) w;

    w_ptr[out_len / 8] |= (u64) out_len << 56;

    u64x v0 = v0p;
    u64x v1 = v1p;
    u64x v2 = v2p;
    u64x v3 = v3p;

    int i;
    int j;

    for (i = 0, j = 0; i <= pw_len; i += 8, j += 2)
    {
      u64x m = hl32_to_64 (w[j + 1], w[j + 0]);

      v3 ^= m;

      SIPROUND (v0, v1, v2, v3);
      SIPROUND (v0, v1, v2, v3);

      v0 ^= m;
    }

    v2 ^= 0xff;

    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);
    SIPROUND (v0, v1, v2, v3);

    const u64x v = v0 ^ v1 ^ v2 ^ v3;

    const u32x a = l32_from_64 (v);
    const u32x b = h32_from_64 (v);

    const u32x r0 = a;
    const u32x r1 = b;
    const u32x r2 = 0;
    const u32x r3 = 0;

    #include VECT_COMPARE_S
  }
}

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_s08 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
}

__kernel void __attribute__((reqd_work_group_size (64, 1, 1))) m10100_s16 (__global pw_t *pws, __global gpu_rule_t *  rules_buf, __global comb_t *combs_buf, __global bf_t *bfs_buf, __global void *tmps, __global void *hooks, __global u32 *bitmaps_buf_s1_a, __global u32 *bitmaps_buf_s1_b, __global u32 *bitmaps_buf_s1_c, __global u32 *bitmaps_buf_s1_d, __global u32 *bitmaps_buf_s2_a, __global u32 *bitmaps_buf_s2_b, __global u32 *bitmaps_buf_s2_c, __global u32 *bitmaps_buf_s2_d, __global plain_t *plains_buf, __global digest_t *digests_buf, __global u32 *hashes_shown, __global salt_t *salt_bufs, __global void *esalt_bufs, __global u32 *d_return_buf, __global u32 *d_scryptV_buf, const u32 bitmap_mask, const u32 bitmap_shift1, const u32 bitmap_shift2, const u32 salt_pos, const u32 loop_pos, const u32 loop_cnt, const u32 rules_cnt, const u32 digests_cnt, const u32 digests_offset, const u32 combs_mode, const u32 gid_max)
{
}
