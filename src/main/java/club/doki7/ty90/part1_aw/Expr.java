package club.doki7.ty90.part1_aw;

import club.doki7.ty90.ann.PreferStaticMethod;

import java.util.List;

@PreferStaticMethod({"Var", "App", "Abs", "Let", "Lit", "Tuple"})
public sealed interface Expr {
    record Var(String name) implements Expr {}
    record App(Expr f, Expr arg) implements Expr {}
    record Abs(String paramName, Expr body) implements Expr {}
    record Let(String name, Expr value, Expr body) implements Expr {}
    record LitInt(int value) implements Expr {}
    record LitString(String value) implements Expr {}
    record Tuple(List<Expr> elements) implements Expr {}
}
