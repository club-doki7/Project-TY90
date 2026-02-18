package club.doki7.ty90.part1_aw;

import club.doki7.ty90.ann.PreferStaticMethod;
import club.doki7.ty90.util.Greek;
import club.doki7.ty90.util.ImmSeq;

@PreferStaticMethod({"Var", "Arrow", "Tuple", "Int", "Bool"})
public sealed interface Type {
    record Var(Greek greek, int id) implements Type {}
    record Arrow(Type from, Type to) implements Type {}
    record Tuple(ImmSeq<Type> elements) implements Type {}
    enum Int implements Type { INSTANCE }
    enum Bool implements Type { INSTANCE }

    Type.Int INT = Int.INSTANCE;
    Type.Bool BOOL = Bool.INSTANCE;
}
