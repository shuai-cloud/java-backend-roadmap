/**
 * 装饰器模式演示
 */
public class DecoratorDemo {
    interface Coffee {
        double cost();
        String description();
    }

    static class SimpleCoffee implements Coffee {
        public double cost() { return 5.0; }
        public String description() { return "Simple coffee"; }
    }

    static abstract class CoffeeDecorator implements Coffee {
        protected Coffee decorated;
        public CoffeeDecorator(Coffee coffee) { this.decorated = coffee; }
        public double cost() { return decorated.cost(); }
        public String description() { return decorated.description(); }
    }

    static class MilkDecorator extends CoffeeDecorator {
        public MilkDecorator(Coffee coffee) { super(coffee); }
        public double cost() { return super.cost() + 2.0; }
        public String description() { return super.description() + ", milk"; }
    }

    static class SugarDecorator extends CoffeeDecorator {
        public SugarDecorator(Coffee coffee) { super(coffee); }
        public double cost() { return super.cost() + 1.0; }
        public String description() { return super.description() + ", sugar"; }
    }

    public static void main(String[] args) {
        Coffee coffee = new SugarDecorator(new MilkDecorator(new SimpleCoffee()));
        System.out.println(coffee.description() + " costs $" + coffee.cost());
    }
}