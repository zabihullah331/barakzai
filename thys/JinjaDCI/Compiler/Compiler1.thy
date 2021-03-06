(*  Title:      JinjaDCI/Compiler/Compiler1.thy
    Author:     Tobias Nipkow, Susannah Mansky
    Copyright   TUM 2003, UIUC 2019-20

    Based on the Jinja theory Compiler/Compiler1.thy by Tobias Nipkow
*)

section \<open> Compilation Stage 1 \<close>

theory Compiler1 imports PCompiler J1 Hidden begin

text\<open> Replacing variable names by indices. \<close>

primrec compE\<^sub>1  :: "vname list \<Rightarrow> expr \<Rightarrow> expr\<^sub>1"
  and compEs\<^sub>1 :: "vname list \<Rightarrow> expr list \<Rightarrow> expr\<^sub>1 list" where
  "compE\<^sub>1 Vs (new C) = new C"
| "compE\<^sub>1 Vs (Cast C e) = Cast C (compE\<^sub>1 Vs e)"
| "compE\<^sub>1 Vs (Val v) = Val v"
| "compE\<^sub>1 Vs (e\<^sub>1 \<guillemotleft>bop\<guillemotright> e\<^sub>2) = (compE\<^sub>1 Vs e\<^sub>1) \<guillemotleft>bop\<guillemotright> (compE\<^sub>1 Vs e\<^sub>2)"
| "compE\<^sub>1 Vs (Var V) = Var(last_index Vs V)"
| "compE\<^sub>1 Vs (V:=e) = (last_index Vs V):= (compE\<^sub>1 Vs e)"
| "compE\<^sub>1 Vs (e\<bullet>F{D}) = (compE\<^sub>1 Vs e)\<bullet>F{D}"
| "compE\<^sub>1 Vs (C\<bullet>\<^sub>sF{D}) = C\<bullet>\<^sub>sF{D}"
| "compE\<^sub>1 Vs (e\<^sub>1\<bullet>F{D}:=e\<^sub>2) = (compE\<^sub>1 Vs e\<^sub>1)\<bullet>F{D} := (compE\<^sub>1 Vs e\<^sub>2)"
| "compE\<^sub>1 Vs (C\<bullet>\<^sub>sF{D}:=e\<^sub>2) = C\<bullet>\<^sub>sF{D} := (compE\<^sub>1 Vs e\<^sub>2)"
| "compE\<^sub>1 Vs (e\<bullet>M(es)) = (compE\<^sub>1 Vs e)\<bullet>M(compEs\<^sub>1 Vs es)"
| "compE\<^sub>1 Vs (C\<bullet>\<^sub>sM(es)) = C\<bullet>\<^sub>sM(compEs\<^sub>1 Vs es)"
| "compE\<^sub>1 Vs {V:T; e} = {(size Vs):T; compE\<^sub>1 (Vs@[V]) e}"
| "compE\<^sub>1 Vs (e\<^sub>1;;e\<^sub>2) = (compE\<^sub>1 Vs e\<^sub>1);;(compE\<^sub>1 Vs e\<^sub>2)"
| "compE\<^sub>1 Vs (if (e) e\<^sub>1 else e\<^sub>2) = if (compE\<^sub>1 Vs e) (compE\<^sub>1 Vs e\<^sub>1) else (compE\<^sub>1 Vs e\<^sub>2)"
| "compE\<^sub>1 Vs (while (e) c) = while (compE\<^sub>1 Vs e) (compE\<^sub>1 Vs c)"
| "compE\<^sub>1 Vs (throw e) = throw (compE\<^sub>1 Vs e)"
| "compE\<^sub>1 Vs (try e\<^sub>1 catch(C V) e\<^sub>2) =
    try(compE\<^sub>1 Vs e\<^sub>1) catch(C (size Vs)) (compE\<^sub>1 (Vs@[V]) e\<^sub>2)"
| "compE\<^sub>1 Vs (INIT C (Cs,b) \<leftarrow> e) = INIT C (Cs,b) \<leftarrow> (compE\<^sub>1 Vs e)"
| "compE\<^sub>1 Vs (RI(C,e);Cs \<leftarrow> e') = RI(C,(compE\<^sub>1 Vs e));Cs \<leftarrow> (compE\<^sub>1 Vs e')"

| "compEs\<^sub>1 Vs []     = []"
| "compEs\<^sub>1 Vs (e#es) = compE\<^sub>1 Vs e # compEs\<^sub>1 Vs es"

lemma [simp]: "compEs\<^sub>1 Vs es = map (compE\<^sub>1 Vs) es"
(*<*)by(induct es type:list) simp_all(*>*)

lemma [simp]: "\<And>Vs. sub_RI (compE\<^sub>1 Vs e) = sub_RI e"
 and [simp]: "\<And>Vs. sub_RIs (compEs\<^sub>1 Vs es) = sub_RIs es"
proof(induct rule: sub_RI_sub_RIs_induct) qed(auto)

primrec fin\<^sub>1:: "expr \<Rightarrow> expr\<^sub>1" where
  "fin\<^sub>1(Val v) = Val v"
| "fin\<^sub>1(throw e) = throw(fin\<^sub>1 e)"

lemma comp_final: "final e \<Longrightarrow> compE\<^sub>1 Vs e = fin\<^sub>1 e"
(*<*)by(erule finalE, simp_all)(*>*)


lemma [simp]:
      "\<And>Vs. max_vars (compE\<^sub>1 Vs e) = max_vars e"
and "\<And>Vs. max_varss (compEs\<^sub>1 Vs es) = max_varss es"
(*<*)by (induct e and es rule: max_vars.induct max_varss.induct) simp_all(*>*)


text\<open> Compiling programs: \<close>

definition compP\<^sub>1 :: "J_prog \<Rightarrow> J\<^sub>1_prog"
where
  "compP\<^sub>1  \<equiv>  compP (\<lambda>b (pns,body). compE\<^sub>1 (case b of NonStatic \<Rightarrow> this#pns | Static \<Rightarrow> pns) body)"

(*<*)
declare compP\<^sub>1_def[simp]
(*>*)

end
