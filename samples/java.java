import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@FunctionalInterface
interface Auditable {
    void audit(String message);
}

@Deprecated
@SuppressWarnings({"unchecked", "rawtypes"})
public final class java<T extends Number & Serializable> implements Auditable {
    private static final String NAME = "Ergolight";
    private final Map<String, List<T>> values;

    public java(Map<String, List<T>> values) {
        this.values = values;
    }

    public static void main(String[] args) {
        var app = new java<Integer>(Map.of("orders", List.of(1, 2, 3)));
        app.audit("started at " + LocalDateTime.now());
    }

    @Override
    public void audit(String message) {
        if (message instanceof String text && !text.isBlank()) {
            System.out.printf("%s -> %s%n", NAME, text);
        } else {
            throw new IllegalArgumentException("empty message");
        }
    }
}

