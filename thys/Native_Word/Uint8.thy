(*  Title:      Uint8.thy
    Author:     Andreas Lochbihler, ETH Zurich
*)

chapter \<open>Unsigned words of 8 bits\<close>

theory Uint8 imports
  Code_Target_Word_Base
begin

text \<open>
  Restriction for OCaml code generation:
  OCaml does not provide an int8 type, so no special code generation 
  for this type is set up. If the theory \<open>Code_Target_Bits_Int\<close>
  is imported, the type \<open>uint8\<close> is emulated via @{typ "8 word"}.
\<close>

declare prod.Quotient[transfer_rule]

section \<open>Type definition and primitive operations\<close>

typedef uint8 = "UNIV :: 8 word set" ..

setup_lifting type_definition_uint8

text \<open>Use an abstract type for code generation to disable pattern matching on @{term Abs_uint8}.\<close>
declare Rep_uint8_inverse[code abstype]

declare Quotient_uint8[transfer_rule]

instantiation uint8 :: comm_ring_1
begin
lift_definition zero_uint8 :: uint8 is "0 :: 8 word" .
lift_definition one_uint8 :: uint8 is "1" .
lift_definition plus_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" is "(+) :: 8 word \<Rightarrow> _" .
lift_definition minus_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" is "(-)" .
lift_definition uminus_uint8 :: "uint8 \<Rightarrow> uint8" is uminus .
lift_definition times_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" is "(*)" .
instance by (standard; transfer) (simp_all add: algebra_simps)
end

instantiation uint8 :: semiring_modulo
begin
lift_definition divide_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" is "(div)" .
lift_definition modulo_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" is "(mod)" .
instance by (standard; transfer) (fact word_mod_div_equality)
end

instantiation uint8 :: linorder begin
lift_definition less_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> bool" is "(<)" .
lift_definition less_eq_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> bool" is "(\<le>)" .
instance by (standard; transfer) (simp_all add: less_le_not_le linear)
end

lemmas [code] = less_uint8.rep_eq less_eq_uint8.rep_eq

context
  includes lifting_syntax
  notes
    transfer_rule_of_bool [transfer_rule]
    transfer_rule_numeral [transfer_rule]
begin

lemma [transfer_rule]:
  "((=) ===> cr_uint8) of_bool of_bool"
  by transfer_prover

lemma transfer_rule_numeral_uint [transfer_rule]:
  "((=) ===> cr_uint8) numeral numeral"
  by transfer_prover

lemma [transfer_rule]:
  \<open>(cr_uint8 ===> (\<longleftrightarrow>)) even ((dvd) 2 :: uint8 \<Rightarrow> bool)\<close>
  by (unfold dvd_def) transfer_prover

end

instantiation uint8 :: semiring_bits
begin

lift_definition bit_uint8 :: \<open>uint8 \<Rightarrow> nat \<Rightarrow> bool\<close> is bit .

instance
  by (standard; transfer)
    (fact bit_iff_odd even_iff_mod_2_eq_zero odd_iff_mod_2_eq_one odd_one bits_induct
       bits_div_0 bits_div_by_1 bits_mod_div_trivial even_succ_div_2
       even_mask_div_iff exp_div_exp_eq div_exp_eq mod_exp_eq mult_exp_mod_exp_eq
       div_exp_mod_exp_eq even_mult_exp_div_exp_iff)+

end

instantiation uint8 :: semiring_bit_shifts
begin
lift_definition push_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is push_bit .
lift_definition drop_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is drop_bit .
lift_definition take_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is take_bit .
instance by (standard; transfer)
  (fact push_bit_eq_mult drop_bit_eq_div take_bit_eq_mod)+
end

instantiation uint8 :: ring_bit_operations
begin
lift_definition not_uint8 :: \<open>uint8 \<Rightarrow> uint8\<close> is NOT .
lift_definition and_uint8 :: \<open>uint8 \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>(AND)\<close> .
lift_definition or_uint8 :: \<open>uint8 \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>(OR)\<close> .
lift_definition xor_uint8 :: \<open>uint8 \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>(XOR)\<close> .
lift_definition mask_uint8 :: \<open>nat \<Rightarrow> uint8\<close> is mask .
lift_definition set_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>Bit_Operations.set_bit\<close> .
lift_definition unset_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>unset_bit\<close> .
lift_definition flip_bit_uint8 :: \<open>nat \<Rightarrow> uint8 \<Rightarrow> uint8\<close> is \<open>flip_bit\<close> .
instance by (standard; transfer)
  (simp_all add: bit_simps mask_eq_decr_exp minus_eq_not_minus_1 set_bit_def flip_bit_def)
end

lemma [code]:
  \<open>take_bit n a = a AND mask n\<close> for a :: uint8
  by (fact take_bit_eq_mask)

lemma [code]:
  \<open>mask (Suc n) = push_bit n (1 :: uint8) OR mask n\<close>
  \<open>mask 0 = (0 :: uint8)\<close>
  by (simp_all add: mask_Suc_exp push_bit_of_1)

lemma [code]:
  \<open>Bit_Operations.set_bit n w = w OR push_bit n 1\<close> for w :: uint8
  by (fact set_bit_eq_or)

lemma [code]:
  \<open>unset_bit n w = w AND NOT (push_bit n 1)\<close> for w :: uint8
  by (fact unset_bit_eq_and_not)

lemma [code]:
  \<open>flip_bit n w = w XOR push_bit n 1\<close> for w :: uint8
  by (fact flip_bit_eq_xor)

instantiation uint8 :: lsb
begin
lift_definition lsb_uint8 :: \<open>uint8 \<Rightarrow> bool\<close> is lsb .
instance by (standard; transfer)
  (fact lsb_odd)
end

instantiation uint8 :: msb
begin
lift_definition msb_uint8 :: \<open>uint8 \<Rightarrow> bool\<close> is msb .
instance ..
end

setup \<open>Context.theory_map (Name_Space.map_naming (Name_Space.qualified_path true \<^binding>\<open>Generic\<close>))\<close>

instantiation uint8 :: set_bit
begin
lift_definition set_bit_uint8 :: \<open>uint8 \<Rightarrow> nat \<Rightarrow> bool \<Rightarrow> uint8\<close> is set_bit .
instance
  apply standard
  apply transfer
  apply (simp add: bit_simps)
  done
end

setup \<open>Context.theory_map (Name_Space.map_naming (Name_Space.parent_path))\<close>

instantiation uint8 :: bit_comprehension begin
lift_definition set_bits_uint8 :: "(nat \<Rightarrow> bool) \<Rightarrow> uint8" is "set_bits" .
instance by (standard; transfer) (fact set_bits_bit_eq)
end

lemmas [code] = bit_uint8.rep_eq lsb_uint8.rep_eq msb_uint8.rep_eq

instantiation uint8 :: equal begin
lift_definition equal_uint8 :: "uint8 \<Rightarrow> uint8 \<Rightarrow> bool" is "equal_class.equal" .
instance by standard (transfer, simp add: equal_eq)
end

lemmas [code] = equal_uint8.rep_eq

instantiation uint8 :: size begin
lift_definition size_uint8 :: "uint8 \<Rightarrow> nat" is "size" .
instance ..
end

lemmas [code] = size_uint8.rep_eq

lift_definition sshiftr_uint8 :: "uint8 \<Rightarrow> nat \<Rightarrow> uint8" (infixl ">>>" 55) is \<open>\<lambda>w n. signed_drop_bit n w\<close> .

lift_definition uint8_of_int :: "int \<Rightarrow> uint8" is "word_of_int" .

definition uint8_of_nat :: "nat \<Rightarrow> uint8"
where "uint8_of_nat = uint8_of_int \<circ> int"

lift_definition int_of_uint8 :: "uint8 \<Rightarrow> int" is "uint" .
lift_definition nat_of_uint8 :: "uint8 \<Rightarrow> nat" is "unat" .

definition integer_of_uint8 :: "uint8 \<Rightarrow> integer"
where "integer_of_uint8 = integer_of_int o int_of_uint8"

text \<open>Use pretty numerals from integer for pretty printing\<close>

context includes integer.lifting begin

lift_definition Uint8 :: "integer \<Rightarrow> uint8" is "word_of_int" .

lemma Rep_uint8_numeral [simp]: "Rep_uint8 (numeral n) = numeral n"
by(induction n)(simp_all add: one_uint8_def Abs_uint8_inverse numeral.simps plus_uint8_def)

lemma numeral_uint8_transfer [transfer_rule]:
  "(rel_fun (=) cr_uint8) numeral numeral"
by(auto simp add: cr_uint8_def)

lemma numeral_uint8 [code_unfold]: "numeral n = Uint8 (numeral n)"
by transfer simp

lemma Rep_uint8_neg_numeral [simp]: "Rep_uint8 (- numeral n) = - numeral n"
by(simp only: uminus_uint8_def)(simp add: Abs_uint8_inverse)

lemma neg_numeral_uint8 [code_unfold]: "- numeral n = Uint8 (- numeral n)"
by transfer(simp add: cr_uint8_def)

end

lemma Abs_uint8_numeral [code_post]: "Abs_uint8 (numeral n) = numeral n"
by(induction n)(simp_all add: one_uint8_def numeral.simps plus_uint8_def Abs_uint8_inverse)

lemma Abs_uint8_0 [code_post]: "Abs_uint8 0 = 0"
by(simp add: zero_uint8_def)

lemma Abs_uint8_1 [code_post]: "Abs_uint8 1 = 1"
by(simp add: one_uint8_def)

section \<open>Code setup\<close>

code_printing code_module Uint8 \<rightharpoonup> (SML)
\<open>(* Test that words can handle numbers between 0 and 3 *)
val _ = if 3 <= Word.wordSize then () else raise (Fail ("wordSize less than 3"));

structure Uint8 : sig
  val set_bit : Word8.word -> IntInf.int -> bool -> Word8.word
  val shiftl : Word8.word -> IntInf.int -> Word8.word
  val shiftr : Word8.word -> IntInf.int -> Word8.word
  val shiftr_signed : Word8.word -> IntInf.int -> Word8.word
  val test_bit : Word8.word -> IntInf.int -> bool
end = struct

fun set_bit x n b =
  let val mask = Word8.<< (0wx1, Word.fromLargeInt (IntInf.toLarge n))
  in if b then Word8.orb (x, mask)
     else Word8.andb (x, Word8.notb mask)
  end

fun shiftl x n =
  Word8.<< (x, Word.fromLargeInt (IntInf.toLarge n))

fun shiftr x n =
  Word8.>> (x, Word.fromLargeInt (IntInf.toLarge n))

fun shiftr_signed x n =
  Word8.~>> (x, Word.fromLargeInt (IntInf.toLarge n))

fun test_bit x n =
  Word8.andb (x, Word8.<< (0wx1, Word.fromLargeInt (IntInf.toLarge n))) <> Word8.fromInt 0

end; (* struct Uint8 *)\<close>
code_reserved SML Uint8

code_printing code_module Uint8 \<rightharpoonup> (Haskell)
 \<open>module Uint8(Int8, Word8) where

  import Data.Int(Int8)
  import Data.Word(Word8)\<close>
code_reserved Haskell Uint8

text \<open>
  Scala provides only signed 8bit numbers, so we use these and 
  implement sign-sensitive operations like comparisons manually.
\<close>

code_printing code_module Uint8 \<rightharpoonup> (Scala)
\<open>object Uint8 {

def less(x: Byte, y: Byte) : Boolean =
  if (x < 0) y < 0 && x < y
  else y < 0 || x < y

def less_eq(x: Byte, y: Byte) : Boolean =
  if (x < 0) y < 0 && x <= y
  else y < 0 || x <= y

def set_bit(x: Byte, n: BigInt, b: Boolean) : Byte =
  if (b)
    (x | (1 << n.intValue)).toByte
  else
    (x & (1 << n.intValue).unary_~).toByte

def shiftl(x: Byte, n: BigInt) : Byte = (x << n.intValue).toByte

def shiftr(x: Byte, n: BigInt) : Byte = ((x & 255) >>> n.intValue).toByte

def shiftr_signed(x: Byte, n: BigInt) : Byte = (x >> n.intValue).toByte

def test_bit(x: Byte, n: BigInt) : Boolean =
  (x & (1 << n.intValue)) != 0

} /* object Uint8 */\<close>
code_reserved Scala Uint8

text \<open>
  Avoid @{term Abs_uint8} in generated code, use @{term Rep_uint8'} instead. 
  The symbolic implementations for code\_simp use @{term Rep_uint8}.

  The new destructor @{term Rep_uint8'} is executable.
  As the simplifier is given the [code abstract] equations literally, 
  we cannot implement @{term Rep_uint8} directly, because that makes code\_simp loop.

  If code generation raises Match, some equation probably contains @{term Rep_uint8} 
  ([code abstract] equations for @{typ uint8} may use @{term Rep_uint8} because
  these instances will be folded away.)

  To convert @{typ "8 word"} values into @{typ uint8}, use @{term "Abs_uint8'"}.
\<close>

definition Rep_uint8' where [simp]: "Rep_uint8' = Rep_uint8"

lemma Rep_uint8'_transfer [transfer_rule]:
  "rel_fun cr_uint8 (=) (\<lambda>x. x) Rep_uint8'"
unfolding Rep_uint8'_def by(rule uint8.rep_transfer)

lemma Rep_uint8'_code [code]: "Rep_uint8' x = (BITS n. bit x n)"
  by transfer (simp add: set_bits_bit_eq)

lift_definition Abs_uint8' :: "8 word \<Rightarrow> uint8" is "\<lambda>x :: 8 word. x" .

lemma Abs_uint8'_code [code]: "Abs_uint8' x = Uint8 (integer_of_int (uint x))"
including integer.lifting by transfer simp

declare [[code drop: "term_of_class.term_of :: uint8 \<Rightarrow> _"]]

lemma term_of_uint8_code [code]:
  defines "TR \<equiv> typerep.Typerep" and "bit0 \<equiv> STR ''Numeral_Type.bit0''" shows
  "term_of_class.term_of x = 
   Code_Evaluation.App (Code_Evaluation.Const (STR ''Uint8.uint8.Abs_uint8'') (TR (STR ''fun'') [TR (STR ''Word.word'') [TR bit0 [TR bit0 [TR bit0 [TR (STR ''Numeral_Type.num1'') []]]]], TR (STR ''Uint8.uint8'') []]))
       (term_of_class.term_of (Rep_uint8' x))"
by(simp add: term_of_anything)

lemma Uin8_code [code abstract]: "Rep_uint8 (Uint8 i) = word_of_int (int_of_integer_symbolic i)"
unfolding Uint8_def int_of_integer_symbolic_def by(simp add: Abs_uint8_inverse)

code_printing type_constructor uint8 \<rightharpoonup>
  (SML) "Word8.word" and
  (Haskell) "Uint8.Word8" and
  (Scala) "Byte"
| constant Uint8 \<rightharpoonup> 
  (SML) "Word8.fromLargeInt (IntInf.toLarge _)" and
  (Haskell) "(Prelude.fromInteger _ :: Uint8.Word8)" and
  (Haskell_Quickcheck) "(Prelude.fromInteger (Prelude.toInteger _) :: Uint8.Word8)" and
  (Scala) "_.byteValue"
| constant "0 :: uint8" \<rightharpoonup>
  (SML) "(Word8.fromInt 0)" and
  (Haskell) "(0 :: Uint8.Word8)" and
  (Scala) "0.toByte"
| constant "1 :: uint8" \<rightharpoonup>
  (SML) "(Word8.fromInt 1)" and
  (Haskell) "(1 :: Uint8.Word8)" and
  (Scala) "1.toByte"
| constant "plus :: uint8 \<Rightarrow> _ \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.+ ((_), (_))" and
  (Haskell) infixl 6 "+" and
  (Scala) "(_ +/ _).toByte"
| constant "uminus :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.~" and
  (Haskell) "negate" and
  (Scala) "(- _).toByte"
| constant "minus :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.- ((_), (_))" and
  (Haskell) infixl 6 "-" and
  (Scala) "(_ -/ _).toByte"
| constant "times :: uint8 \<Rightarrow> _ \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.* ((_), (_))" and
  (Haskell) infixl 7 "*" and
  (Scala) "(_ */ _).toByte"
| constant "HOL.equal :: uint8 \<Rightarrow> _ \<Rightarrow> bool" \<rightharpoonup>
  (SML) "!((_ : Word8.word) = _)" and
  (Haskell) infix 4 "==" and
  (Scala) infixl 5 "=="
| class_instance uint8 :: equal \<rightharpoonup> (Haskell) -
| constant "less_eq :: uint8 \<Rightarrow> _ \<Rightarrow> bool" \<rightharpoonup>
  (SML) "Word8.<= ((_), (_))" and
  (Haskell) infix 4 "<=" and
  (Scala) "Uint8.less'_eq"
| constant "less :: uint8 \<Rightarrow> _ \<Rightarrow> bool" \<rightharpoonup>
  (SML) "Word8.< ((_), (_))" and
  (Haskell) infix 4 "<" and
  (Scala) "Uint8.less"
| constant "NOT :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.notb" and
  (Haskell) "Data'_Bits.complement" and
  (Scala) "_.unary'_~.toByte"
| constant "(AND) :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.andb ((_),/ (_))" and
  (Haskell) infixl 7 "Data_Bits..&." and
  (Scala) "(_ & _).toByte"
| constant "(OR) :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.orb ((_),/ (_))" and
  (Haskell) infixl 5 "Data_Bits..|." and
  (Scala) "(_ | _).toByte"
| constant "(XOR) :: uint8 \<Rightarrow> _" \<rightharpoonup>
  (SML) "Word8.xorb ((_),/ (_))" and
  (Haskell) "Data'_Bits.xor" and
  (Scala) "(_ ^ _).toByte"

definition uint8_divmod :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8 \<times> uint8" where
  "uint8_divmod x y = 
  (if y = 0 then (undefined ((div) :: uint8 \<Rightarrow> _) x (0 :: uint8), undefined ((mod) :: uint8 \<Rightarrow> _) x (0 :: uint8)) 
  else (x div y, x mod y))"

definition uint8_div :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" 
where "uint8_div x y = fst (uint8_divmod x y)"

definition uint8_mod :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8" 
where "uint8_mod x y = snd (uint8_divmod x y)"

lemma div_uint8_code [code]: "x div y = (if y = 0 then 0 else uint8_div x y)"
including undefined_transfer unfolding uint8_divmod_def uint8_div_def
by transfer (simp add: word_div_def)

lemma mod_uint8_code [code]: "x mod y = (if y = 0 then x else uint8_mod x y)"
including undefined_transfer unfolding uint8_mod_def uint8_divmod_def
by transfer (simp add: word_mod_def)

definition uint8_sdiv :: "uint8 \<Rightarrow> uint8 \<Rightarrow> uint8"
where
  "uint8_sdiv x y =
   (if y = 0 then undefined ((div) :: uint8 \<Rightarrow> _) x (0 :: uint8)
    else Abs_uint8 (Rep_uint8 x sdiv Rep_uint8 y))"

definition div0_uint8 :: "uint8 \<Rightarrow> uint8"
where [code del]: "div0_uint8 x = undefined ((div) :: uint8 \<Rightarrow> _) x (0 :: uint8)"
declare [[code abort: div0_uint8]]

definition mod0_uint8 :: "uint8 \<Rightarrow> uint8"
where [code del]: "mod0_uint8 x = undefined ((mod) :: uint8 \<Rightarrow> _) x (0 :: uint8)"
declare [[code abort: mod0_uint8]]

lemma uint8_divmod_code [code]:
  "uint8_divmod x y =
  (if 0x80 \<le> y then if x < y then (0, x) else (1, x - y)
   else if y = 0 then (div0_uint8 x, mod0_uint8 x)
   else let q = push_bit 1 (uint8_sdiv (drop_bit 1 x) y);
            r = x - q * y
        in if r \<ge> y then (q + 1, r - y) else (q, r))"
including undefined_transfer unfolding uint8_divmod_def uint8_sdiv_def div0_uint8_def mod0_uint8_def
  apply transfer
  apply (simp add: divmod_via_sdivmod push_bit_eq_mult)
  done

lemma uint8_sdiv_code [code abstract]:
  "Rep_uint8 (uint8_sdiv x y) =
   (if y = 0 then Rep_uint8 (undefined ((div) :: uint8 \<Rightarrow> _) x (0 :: uint8))
    else Rep_uint8 x sdiv Rep_uint8 y)"
unfolding uint8_sdiv_def by(simp add: Abs_uint8_inverse)

text \<open>
  Note that we only need a translation for signed division, but not for the remainder
  because @{thm uint8_divmod_code} computes both with division only.
\<close>

code_printing
  constant uint8_div \<rightharpoonup>
  (SML) "Word8.div ((_), (_))" and
  (Haskell) "Prelude.div"
| constant uint8_mod \<rightharpoonup>
  (SML) "Word8.mod ((_), (_))" and
  (Haskell) "Prelude.mod"
| constant uint8_divmod \<rightharpoonup>
  (Haskell) "divmod"
| constant uint8_sdiv \<rightharpoonup>
  (Scala) "(_ '/ _).toByte"

definition uint8_test_bit :: "uint8 \<Rightarrow> integer \<Rightarrow> bool"
where [code del]:
  "uint8_test_bit x n =
  (if n < 0 \<or> 7 < n then undefined (bit :: uint8 \<Rightarrow> _) x n
   else bit x (nat_of_integer n))"

lemma bit_uint8_code [code]:
  "bit x n \<longleftrightarrow> n < 8 \<and> uint8_test_bit x (integer_of_nat n)"
  including undefined_transfer integer.lifting unfolding uint8_test_bit_def
  by (transfer, simp, transfer, simp)

lemma uint8_test_bit_code [code]:
  "uint8_test_bit w n =
  (if n < 0 \<or> 7 < n then undefined (bit :: uint8 \<Rightarrow> _) w n else bit (Rep_uint8 w) (nat_of_integer n))"
  unfolding uint8_test_bit_def
  by (simp add: bit_uint8.rep_eq)

code_printing constant uint8_test_bit \<rightharpoonup>
  (SML) "Uint8.test'_bit" and
  (Haskell) "Data'_Bits.testBitBounded" and
  (Scala) "Uint8.test'_bit" and
  (Eval) "(fn x => fn i => if i < 0 orelse i >= 8 then raise (Fail \"argument to uint8'_test'_bit out of bounds\") else Uint8.test'_bit x i)"


definition uint8_set_bit :: "uint8 \<Rightarrow> integer \<Rightarrow> bool \<Rightarrow> uint8"
where [code del]:
  "uint8_set_bit x n b =
  (if n < 0 \<or> 7 < n then undefined (set_bit :: uint8 \<Rightarrow> _) x n b
   else set_bit x (nat_of_integer n) b)"

lemma set_bit_uint8_code [code]:
  "set_bit x n b = (if n < 8 then uint8_set_bit x (integer_of_nat n) b else x)"
including undefined_transfer integer.lifting unfolding uint8_set_bit_def
by(transfer)(auto cong: conj_cong simp add: not_less set_bit_beyond word_size)

lemma uint8_set_bit_code [code abstract]:
  "Rep_uint8 (uint8_set_bit w n b) = 
  (if n < 0 \<or> 7 < n then Rep_uint8 (undefined (set_bit :: uint8 \<Rightarrow> _) w n b)
   else set_bit (Rep_uint8 w) (nat_of_integer n) b)"
including undefined_transfer unfolding uint8_set_bit_def by transfer simp

code_printing constant uint8_set_bit \<rightharpoonup>
  (SML) "Uint8.set'_bit" and
  (Haskell) "Data'_Bits.setBitBounded" and
  (Scala) "Uint8.set'_bit" and
  (Eval) "(fn x => fn i => fn b => if i < 0 orelse i >= 8 then raise (Fail \"argument to uint8'_set'_bit out of bounds\") else Uint8.set'_bit x i b)"


lift_definition uint8_set_bits :: "(nat \<Rightarrow> bool) \<Rightarrow> uint8 \<Rightarrow> nat \<Rightarrow> uint8" is set_bits_aux .

lemma uint8_set_bits_code [code]:
  "uint8_set_bits f w n =
  (if n = 0 then w 
   else let n' = n - 1 in uint8_set_bits f (push_bit 1 w OR (if f n' then 1 else 0)) n')"
  apply (transfer fixing: n)
  apply (cases n)
   apply simp_all
  done

lemma set_bits_uint8 [code]:
  "(BITS n. f n) = uint8_set_bits f 0 8"
by transfer(simp add: set_bits_conv_set_bits_aux)


lemma lsb_code [code]: fixes x :: uint8 shows "lsb x = bit x 0"
  by (simp add: lsb_odd)


definition uint8_shiftl :: "uint8 \<Rightarrow> integer \<Rightarrow> uint8"
where [code del]:
  "uint8_shiftl x n = (if n < 0 \<or> 8 \<le> n then undefined (push_bit :: nat \<Rightarrow> uint8 \<Rightarrow> _) x n else push_bit (nat_of_integer n) x)"

lemma shiftl_uint8_code [code]:
  "push_bit n x = (if n < 8 then uint8_shiftl x (integer_of_nat n) else 0)"
  including undefined_transfer integer.lifting unfolding uint8_shiftl_def
  by transfer simp

lemma uint8_shiftl_code [code abstract]:
  "Rep_uint8 (uint8_shiftl w n) =
  (if n < 0 \<or> 8 \<le> n then Rep_uint8 (undefined (push_bit :: nat \<Rightarrow> uint8 \<Rightarrow> _) w n)
   else push_bit (nat_of_integer n) (Rep_uint8 w))"
  including undefined_transfer unfolding uint8_shiftl_def
  by transfer simp

code_printing constant uint8_shiftl \<rightharpoonup>
  (SML) "Uint8.shiftl" and
  (Haskell) "Data'_Bits.shiftlBounded" and
  (Scala) "Uint8.shiftl" and
  (Eval) "(fn x => fn i => if i < 0 orelse i >= 8 then raise (Fail \"argument to uint8'_shiftl out of bounds\") else Uint8.shiftl x i)"

definition uint8_shiftr :: "uint8 \<Rightarrow> integer \<Rightarrow> uint8"
where [code del]:
  "uint8_shiftr x n = (if n < 0 \<or> 8 \<le> n then undefined (drop_bit :: _ \<Rightarrow> _ \<Rightarrow> uint8) x n else drop_bit (nat_of_integer n) x)"

lemma shiftr_uint8_code [code]:
  "drop_bit n x = (if n < 8 then uint8_shiftr x (integer_of_nat n) else 0)"
  including undefined_transfer integer.lifting unfolding uint8_shiftr_def
  by transfer simp

lemma uint8_shiftr_code [code abstract]:
  "Rep_uint8 (uint8_shiftr w n) =
  (if n < 0 \<or> 8 \<le> n then Rep_uint8 (undefined (drop_bit :: _ \<Rightarrow> _ \<Rightarrow> uint8) w n) 
   else drop_bit (nat_of_integer n) (Rep_uint8 w))"
including undefined_transfer unfolding uint8_shiftr_def by transfer simp

code_printing constant uint8_shiftr \<rightharpoonup>
  (SML) "Uint8.shiftr" and
  (Haskell) "Data'_Bits.shiftrBounded" and
  (Scala) "Uint8.shiftr" and
  (Eval) "(fn x => fn i => if i < 0 orelse i >= 8 then raise (Fail \"argument to uint8'_shiftr out of bounds\") else Uint8.shiftr x i)"

definition uint8_sshiftr :: "uint8 \<Rightarrow> integer \<Rightarrow> uint8"
where [code del]:
  "uint8_sshiftr x n =
  (if n < 0 \<or> 8 \<le> n then undefined sshiftr_uint8 x n else sshiftr_uint8 x (nat_of_integer n))"

lemma sshiftr_uint8_code [code]:
  "x >>> n = 
  (if n < 8 then uint8_sshiftr x (integer_of_nat n) else if bit x 7 then -1 else 0)"
  including undefined_transfer integer.lifting unfolding uint8_sshiftr_def
  by transfer (simp add: not_less signed_drop_bit_beyond word_size)

lemma uint8_sshiftr_code [code abstract]:
  "Rep_uint8 (uint8_sshiftr w n) =
  (if n < 0 \<or> 8 \<le> n then Rep_uint8 (undefined sshiftr_uint8 w n)
   else signed_drop_bit (nat_of_integer n) (Rep_uint8 w))"
  including undefined_transfer unfolding uint8_sshiftr_def
  by transfer simp

code_printing constant uint8_sshiftr \<rightharpoonup>
  (SML) "Uint8.shiftr'_signed" and
  (Haskell) 
    "(Prelude.fromInteger (Prelude.toInteger (Data'_Bits.shiftrBounded (Prelude.fromInteger (Prelude.toInteger _) :: Uint8.Int8) _)) :: Uint8.Word8)" and
  (Scala) "Uint8.shiftr'_signed" and
  (Eval) "(fn x => fn i => if i < 0 orelse i >= 8 then raise (Fail \"argument to uint8'_sshiftr out of bounds\") else Uint8.shiftr'_signed x i)"

lemma uint8_msb_test_bit: "msb x \<longleftrightarrow> bit (x :: uint8) 7"
  by transfer (simp add: msb_word_iff_bit)

lemma msb_uint16_code [code]: "msb x \<longleftrightarrow> uint8_test_bit x 7"
  by (simp add: uint8_test_bit_def uint8_msb_test_bit)

lemma uint8_of_int_code [code]: "uint8_of_int i = Uint8 (integer_of_int i)"
including integer.lifting by transfer simp

lemma int_of_uint8_code [code]:
  "int_of_uint8 x = int_of_integer (integer_of_uint8 x)"
by(simp add: integer_of_uint8_def)

lemma nat_of_uint8_code [code]:
  "nat_of_uint8 x = nat_of_integer (integer_of_uint8 x)"
unfolding integer_of_uint8_def including integer.lifting by transfer simp

definition integer_of_uint8_signed :: "uint8 \<Rightarrow> integer"
where
  "integer_of_uint8_signed n = (if bit n 7 then undefined integer_of_uint8 n else integer_of_uint8 n)"

lemma integer_of_uint8_signed_code [code]:
  "integer_of_uint8_signed n =
  (if bit n 7 then undefined integer_of_uint8 n else integer_of_int (uint (Rep_uint8' n)))"
unfolding integer_of_uint8_signed_def integer_of_uint8_def
including undefined_transfer by transfer simp

lemma integer_of_uint8_code [code]:
  "integer_of_uint8 n =
  (if bit n 7 then integer_of_uint8_signed (n AND 0x7F) OR 0x80 else integer_of_uint8_signed n)"
proof -
  have \<open>(0x7F :: uint8) = mask 7\<close>
    by (simp add: mask_eq_exp_minus_1)
  then have *: \<open>n AND 0x7F = take_bit 7 n\<close>
    by (simp only: take_bit_eq_mask)
  have **: \<open>(0x80 :: int) = 2 ^ 7\<close>
    by simp
  show ?thesis
  unfolding integer_of_uint8_def integer_of_uint8_signed_def o_def *
  including undefined_transfer integer.lifting
  apply transfer
  apply (auto simp add: bit_take_bit_iff uint_take_bit_eq)
  apply (rule bit_eqI)
  apply (simp add: bit_uint_iff bit_or_iff bit_take_bit_iff)
  apply (simp only: ** bit_exp_iff)
  apply auto
  done
qed

code_printing
  constant "integer_of_uint8" \<rightharpoonup>
  (SML) "IntInf.fromLarge (Word8.toLargeInt _)" and
  (Haskell) "Prelude.toInteger"
| constant "integer_of_uint8_signed" \<rightharpoonup>
  (Scala) "BigInt"

section \<open>Quickcheck setup\<close>

definition uint8_of_natural :: "natural \<Rightarrow> uint8"
where "uint8_of_natural x \<equiv> Uint8 (integer_of_natural x)"

instantiation uint8 :: "{random, exhaustive, full_exhaustive}" begin
definition "random_uint8 \<equiv> qc_random_cnv uint8_of_natural"
definition "exhaustive_uint8 \<equiv> qc_exhaustive_cnv uint8_of_natural"
definition "full_exhaustive_uint8 \<equiv> qc_full_exhaustive_cnv uint8_of_natural"
instance ..
end

instantiation uint8 :: narrowing begin

interpretation quickcheck_narrowing_samples
  "\<lambda>i. let x = Uint8 i in (x, 0xFF - x)" "0"
  "Typerep.Typerep (STR ''Uint8.uint8'') []" .

definition "narrowing_uint8 d = qc_narrowing_drawn_from (narrowing_samples d) d"
declare [[code drop: "partial_term_of :: uint8 itself \<Rightarrow> _"]]
lemmas partial_term_of_uint8 [code] = partial_term_of_code

instance ..
end

no_notation sshiftr_uint8 (infixl ">>>" 55)

end
