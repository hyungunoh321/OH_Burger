package ohburger.model;

/** 브랜드 한 곳. */
public class Brand {

    private final int id;
    private final String name;

    public Brand(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
