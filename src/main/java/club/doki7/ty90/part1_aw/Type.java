package club.doki7.ty90.part1_aw;

import club.doki7.ty90.ann.PreferStaticMethod;
import club.doki7.ty90.util.ImmSeq;

@PreferStaticMethod({"Var", "Arrow", "Tuple", "Int", "Bool"})
public interface Type {
    record Var(String name) implements Type {}
    record Arrow(Type from, Type to) implements Type {}
    record Tuple(ImmSeq<Type> elements) implements Type {}

    final class Int implements Type {
        private static final Int INSTANCE = new Int();
        private Int() {}
    }

    final class Bool implements Type {
        private static final Bool INSTANCE = new Bool();
        private Bool() {}
    }

    static Type Var(String name) { return new Var(name); }
    static Type Arrow(Type from, Type to) { return new Arrow(from, to); }
    static Type Tuple(ImmSeq<Type> elements) { return new Tuple(elements); }
    static Type Tuple(Type... elements) { return new Tuple(ImmSeq.ofUnsafe(elements)); }
    static Type Int() { return Int.INSTANCE; }
    static Type Bool() { return Bool.INSTANCE; }
}
