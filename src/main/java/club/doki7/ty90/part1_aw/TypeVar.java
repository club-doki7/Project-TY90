package club.doki7.ty90.part1_aw;

import club.doki7.ty90.util.Greek;
import club.doki7.ty90.util.TextUtil;
import org.jetbrains.annotations.NotNull;

public record TypeVar(Greek greek, int id) {
    @Override
    public @NotNull String toString() {
        return TextUtil.subscriptNum(greek.symbol, id);
    }
}
