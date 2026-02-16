package club.doki7.ty90.util;

public enum Greek {
    ALPHA("α"),
    BETA("β"),
    GAMMA("γ"),
    PI("π"),
    SIGMA("σ"),
    TAU("τ");

    public final String symbol;

    Greek(String symbol) {
        this.symbol = symbol;
    }

    @Override
    public String toString() {
        return symbol;
    }
}
