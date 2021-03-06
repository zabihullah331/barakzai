(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *)

section "Words of Length 64"

theory Word_64
  imports
    Word_Lemmas
    Word_Names
    Word_Syntax
    Rsplit
    More_Word_Operations
begin

lemma len64: "len_of (x :: 64 itself) = 64" by simp

type_synonym machine_word_len = 64
type_synonym machine_word = "machine_word_len word"

definition word_bits :: nat
where
  "word_bits = LENGTH(machine_word_len)"

text \<open>The following two are numerals so they can be used as nats and words.\<close>
definition word_size_bits :: "'a :: numeral"
where
  "word_size_bits = 3"

definition word_size :: "'a :: numeral"
where
  "word_size = 8"

lemma word_bits_conv[code]:
  "word_bits = 64"
  unfolding word_bits_def by simp

lemma word_size_word_size_bits:
  "(word_size::nat) = 2 ^ word_size_bits"
  unfolding word_size_def word_size_bits_def by simp

lemma word_bits_word_size_conv:
  "word_bits = word_size * 8"
  unfolding word_bits_def word_size_def by simp

lemma ucast_8_64_inj:
  "inj (ucast ::  8 word \<Rightarrow> 64 word)"
  by (rule down_ucast_inj) (clarsimp simp: is_down_def target_size source_size)

lemma upto_2_helper:
  "{0..<2 :: 64 word} = {0, 1}"
  by (safe; simp) unat_arith

lemmas upper_bits_unset_is_l2p_64 = upper_bits_unset_is_l2p [where 'a=64, folded word_bits_def]
lemmas le_2p_upper_bits_64 = le_2p_upper_bits [where 'a=64, folded word_bits_def]
lemmas le2p_bits_unset_64 = le2p_bits_unset[where 'a=64, folded word_bits_def]

lemma word_bits_len_of:
  "len_of TYPE (64) = word_bits"
  by (simp add: word_bits_conv)

lemmas unat_power_lower64' = unat_power_lower[where 'a=64]
lemmas unat_power_lower64 [simp] = unat_power_lower64'[unfolded word_bits_len_of]

lemmas word64_less_sub_le' = word_less_sub_le[where 'a = 64]
lemmas word64_less_sub_le[simp] = word64_less_sub_le' [folded word_bits_def]

lemma word_bits_size:
  "size (w::word64) = word_bits"
  by (simp add: word_bits_def word_size)

lemmas word64_power_less_1' = word_power_less_1[where 'a = 64]
lemmas word64_power_less_1[simp] = word64_power_less_1'[folded word_bits_def]

lemma of_nat64_0:
  "\<lbrakk>of_nat n = (0::word64); n < 2 ^ word_bits\<rbrakk> \<Longrightarrow> n = 0"
  by (erule of_nat_0, simp add: word_bits_def)

lemma unat_mask_2_less_4:
  "unat (p && mask 2 :: word64) < 4"
  by (rule unat_less_helper) (simp flip: take_bit_eq_mask add: take_bit_eq_mod word_mod_less_divisor)

lemmas unat_of_nat64' = unat_of_nat_eq[where 'a=64]
lemmas unat_of_nat64 = unat_of_nat64'[unfolded word_bits_len_of]

lemmas word_power_nonzero_64 = word_power_nonzero [where 'a=64, folded word_bits_def]

lemmas unat_mult_simple = iffD1 [OF unat_mult_lem [where 'a = 64, unfolded word_bits_len_of]]

lemmas div_power_helper_64 = div_power_helper [where 'a=64, folded word_bits_def]

lemma n_less_word_bits:
  "(n < word_bits) = (n < 64)"
  by (simp add: word_bits_def)

lemmas of_nat_less_pow_64 = of_nat_power [where 'a=64, folded word_bits_def]

lemma lt_word_bits_lt_pow:
  "sz < word_bits \<Longrightarrow> sz < 2 ^ word_bits"
  by (simp add: word_bits_conv)

lemma unat_less_word_bits:
  fixes y :: word64
  shows "x < unat y \<Longrightarrow> x < 2 ^ word_bits"
  unfolding word_bits_def
  by (rule order_less_trans [OF _ unat_lt2p])

lemmas unat_mask_word64' = unat_mask[where 'a=64]
lemmas unat_mask_word64 = unat_mask_word64'[folded word_bits_def]

lemma unat_less_2p_word_bits:
  "unat (x :: 64 word) < 2 ^ word_bits"
  apply (simp only: word_bits_def)
  apply (rule unat_lt2p)
  done

lemma Suc_unat_mask_div:
  "Suc (unat (mask sz div word_size::word64)) = 2 ^ (min sz word_bits - 3)"
proof (cases \<open>sz \<ge> 3\<close>)
  case False
  then have \<open>sz \<in> {0, 1, 2}\<close>
    by auto
  then show ?thesis by (auto simp add: unat_div word_size_def unat_mask)
next
  case True
  moreover define n where \<open>n = sz - 3\<close>
  ultimately have \<open>sz = n + 3\<close>
    by simp
  moreover have \<open>2 ^ n * 8 - Suc 0 = (2 ^ n - 1) * 8 + 7\<close>
    by (simp add: mult_eq_if)
  ultimately show ?thesis
    by (simp add: unat_div unat_mask word_size_def word_bits_def min_def power_add)
qed

lemmas word64_minus_one_le' = word_minus_one_le[where 'a=64]
lemmas word64_minus_one_le = word64_minus_one_le'[simplified]

lemma ucast_not_helper:
  fixes a::"8 word"
  assumes a: "a \<noteq> 0xFF"
  shows "ucast a \<noteq> (0xFF::word64)"
proof
  assume "ucast a = (0xFF::word64)"
  also
  have "(0xFF::word64) = ucast (0xFF::8 word)" by simp
  finally
  show False using a
    apply -
    apply (drule up_ucast_inj, simp)
    apply simp
    done
qed

lemma less_4_cases:
  "(x::word64) < 4 \<Longrightarrow> x=0 \<or> x=1 \<or> x=2 \<or> x=3"
  apply clarsimp
  apply (drule word_less_cases, erule disjE, simp, simp)+
  done

lemma if_then_1_else_0:
  "((if P then 1 else 0) = (0 :: word64)) = (\<not> P)"
  by simp

lemma if_then_0_else_1:
  "((if P then 0 else 1) = (0 :: word64)) = (P)"
  by simp

lemmas if_then_simps = if_then_0_else_1 if_then_1_else_0

lemma ucast_le_ucast_8_64:
  "(ucast x \<le> (ucast y :: word64)) = (x \<le> (y :: 8 word))"
  by (simp add: ucast_le_ucast)

lemma in_16_range:
  "0 \<in> S \<Longrightarrow> r \<in> (\<lambda>x. r + x * (16 :: word64)) ` S"
  "n - 1 \<in> S \<Longrightarrow> (r + (16 * n - 16)) \<in> (\<lambda>x :: word64. r + x * 16) ` S"
  by (clarsimp simp: image_def elim!: bexI[rotated])+

lemma eq_2_64_0:
  "(2 ^ 64 :: word64) = 0"
  by simp

lemma x_less_2_0_1:
  fixes x :: word64 shows
  "x < 2 \<Longrightarrow> x = 0 \<or> x = 1"
  by (rule x_less_2_0_1') auto

lemmas mask_64_max_word  = max_word_mask [symmetric, where 'a=64, simplified]

lemma of_nat64_n_less_equal_power_2:
 "n < 64 \<Longrightarrow> ((of_nat n)::64 word) < 2 ^ n"
  by (rule of_nat_n_less_equal_power_2, clarsimp simp: word_size)

lemma word_rsplit_0:
  "word_rsplit (0 :: word64) = [0, 0, 0, 0, 0, 0, 0, 0 :: 8 word]"
  by (simp add: word_rsplit_def bin_rsplit_def)

lemma unat_ucast_10_64 :
  fixes x :: "10 word"
  shows "unat (ucast x :: word64) = unat x"
  by transfer simp

lemma bool_mask [simp]:
  fixes x :: word64
  shows "(0 < x && 1) = (x && 1 = 1)"
  by (rule bool_mask') auto

lemma word64_bounds:
  "- (2 ^ (size (x :: word64) - 1)) = (-9223372036854775808 :: int)"
  "((2 ^ (size (x :: word64) - 1)) - 1) = (9223372036854775807 :: int)"
  "- (2 ^ (size (y :: 64 signed word) - 1)) = (-9223372036854775808 :: int)"
  "((2 ^ (size (y :: 64 signed word) - 1)) - 1) = (9223372036854775807 :: int)"
  by (simp_all add: word_size)

lemma word_ge_min:"sint (x::64 word) \<ge> -9223372036854775808"
  by (metis sint_ge word64_bounds(1) word_size)

lemmas signed_arith_ineq_checks_to_eq_word64'
    = signed_arith_ineq_checks_to_eq[where 'a=64]
      signed_arith_ineq_checks_to_eq[where 'a="64 signed"]

lemmas signed_arith_ineq_checks_to_eq_word64
    = signed_arith_ineq_checks_to_eq_word64' [unfolded word64_bounds]

lemmas signed_mult_eq_checks64_to_64'
    = signed_mult_eq_checks_double_size[where 'a=64 and 'b=64]
      signed_mult_eq_checks_double_size[where 'a="64 signed" and 'b=64]

lemmas signed_mult_eq_checks64_to_64 = signed_mult_eq_checks64_to_64'[simplified]

lemmas sdiv_word64_max' = sdiv_word_max [where 'a=64] sdiv_word_max [where 'a="64 signed"]
lemmas sdiv_word64_max = sdiv_word64_max'[simplified word_size, simplified]

lemmas sdiv_word64_min' = sdiv_word_min [where 'a=64] sdiv_word_min [where 'a="64 signed"]
lemmas sdiv_word64_min = sdiv_word64_min' [simplified word_size, simplified]

lemmas sint64_of_int_eq' = sint_of_int_eq [where 'a=64]
lemmas sint64_of_int_eq = sint64_of_int_eq' [simplified]

lemma ucast_of_nats [simp]:
  "(ucast (of_nat x :: word64) :: sword64) = (of_nat x)"
  "(ucast (of_nat x :: word64) :: 16 sword) = (of_nat x)"
  "(ucast (of_nat x :: word64) :: 8 sword) = (of_nat x)"
  by (simp_all add: of_nat_take_bit take_bit_word_eq_self)

lemmas signed_shift_guard_simpler_64'
    = power_strict_increasing_iff[where b="2 :: nat" and y=31]
lemmas signed_shift_guard_simpler_64 = signed_shift_guard_simpler_64'[simplified]

lemma word64_31_less:
  "31 < len_of TYPE (64 signed)" "31 > (0 :: nat)"
  "31 < len_of TYPE (64)" "31 > (0 :: nat)"
  by auto

lemmas signed_shift_guard_to_word_64
    = signed_shift_guard_to_word[OF word64_31_less(1-2)]
    signed_shift_guard_to_word[OF word64_31_less(3-4)]

lemma le_step_down_word_3:
  fixes x :: "64 word"
  shows "\<lbrakk>x \<le>  y; x \<noteq> y; y < 2 ^ 64 - 1\<rbrakk> \<Longrightarrow> x \<le> y - 1"
  by (rule le_step_down_word_2, assumption+)

lemma shiftr_1:
  "(x::word64) >> 1 = 0 \<Longrightarrow> x < 2"
  by transfer (simp add: take_bit_drop_bit drop_bit_Suc)

lemma mask_step_down_64:
  \<open>\<exists>x. mask x = b\<close> if \<open>b && 1 = 1\<close>
    and \<open>\<exists>x. x < 64 \<and> mask x = b >> 1\<close> for b :: \<open>64word\<close>
proof -
  from \<open>b && 1 = 1\<close> have \<open>odd b\<close>
    by (auto simp add: mod_2_eq_odd and_one_eq)
  then have \<open>b mod 2 = 1\<close>
    using odd_iff_mod_2_eq_one by blast
  from \<open>\<exists>x. x < 64 \<and> mask x = b >> 1\<close> obtain x where \<open>x < 64\<close> \<open>mask x = b >> 1\<close> by blast
  then have \<open>mask x = b div 2\<close>
    using shiftr1_is_div_2 [of b] by simp
  with \<open>b mod 2 = 1\<close> have \<open>2 * mask x + 1 = 2 * (b div 2) + b mod 2\<close>
    by (simp only:)
  also have \<open>\<dots> = b\<close>
    by (simp add: mult_div_mod_eq)
  finally have \<open>2 * mask x + 1 = b\<close> .
  moreover have \<open>mask (Suc x) = 2 * mask x + (1 :: 'a::len word)\<close>
    by (simp add: mask_Suc_rec)
  ultimately show ?thesis
    by auto
qed

lemma unat_of_int_64:
  "\<lbrakk>i \<ge> 0; i \<le> 2 ^ 63\<rbrakk> \<Longrightarrow> (unat ((of_int i)::sword64)) = nat i"
  unfolding unat_eq_nat_uint
  apply (subst eq_nat_nat_iff)
  apply (simp_all add: take_bit_int_eq_self)
  done

lemmas word_ctz_not_minus_1_64 = word_ctz_not_minus_1[where 'a=64, simplified]

lemma word64_and_max_simp:
  \<open>x AND 0xFFFFFFFFFFFFFFFF = x\<close> for x :: \<open>64 word\<close>
  using word_and_full_mask_simp [of x]
  by (simp add: numeral_eq_Suc mask_Suc_exp)

end
