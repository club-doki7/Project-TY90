package club.doki7.ty90.part1_aw;

import club.doki7.ty90.util.ImmSeq;
import org.jetbrains.annotations.NotNull;

public record TypeScheme(ImmSeq<Type.Var> vars, Type type) {
    @Override
    public @NotNull String toString() {
        if (vars.isEmpty()) {
            return type.toString();
        } else {
            StringBuilder sb = new StringBuilder();
            for (Type.Var var : vars) {
                sb.append("∀").append(var);
            }
            sb.append(". ").append(type);
            return sb.toString();
        }
    }
}
