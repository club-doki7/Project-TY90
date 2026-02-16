package club.doki7.ty90.part1_aw;

import club.doki7.ty90.ann.PreferStaticMethod;
import club.doki7.ty90.util.ImmSeq;

@PreferStaticMethod({"Var", "App", "Abs", "Let", "Lit", "Tuple"})
public sealed interface Expr {
    record Var(String name) implements Expr {}
    record App(Expr f, Expr arg) implements Expr {}
    record Abs(String paramName, Expr body) implements Expr {}
    record Let(String name, Expr value, Expr body) implements Expr {}
    record Lit(int value) implements Expr {}
    record Tuple(ImmSeq<Expr> elements) implements Expr {}

    static Expr Var(String name) { return new Var(name); }
    static Expr App(Expr f, Expr arg) { return new App(f, arg); }
    static Expr Abs(String paramName, Expr body) { return new Abs(paramName, body); }
    static Expr Let(String name, Expr value, Expr body) { return new Let(name, value, body); }
    static Expr Lit(int value) { return new Lit(value); }
    static Expr Tuple(ImmSeq<Expr> elements) { return new Tuple(elements); }
    static Expr Tuple(Expr... elements) { return new Tuple(ImmSeq.ofUnsafe(elements)); }
}
