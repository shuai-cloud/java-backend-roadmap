/**
 * 策略模式演示
 */
public class StrategyDemo {
    // 策略接口
    interface PaymentStrategy {
        void pay(double amount);
    }

    static class CreditCardPayment implements PaymentStrategy {
        private String cardNumber;
        public CreditCardPayment(String cardNumber) { this.cardNumber = cardNumber; }
        public void pay(double amount) { System.out.println("Paid " + amount + " via credit card ending in " + cardNumber.substring(cardNumber.length()-4)); }
    }

    static class PayPalPayment implements PaymentStrategy {
        private String email;
        public PayPalPayment(String email) { this.email = email; }
        public void pay(double amount) { System.out.println("Paid " + amount + " via PayPal (" + email + ")"); }
    }

    static class ShoppingCart {
        private PaymentStrategy strategy;
        public void setPaymentStrategy(PaymentStrategy strategy) { this.strategy = strategy; }
        public void checkout(double amount) { strategy.pay(amount); }
    }

    public static void main(String[] args) {
        ShoppingCart cart = new ShoppingCart();
        cart.setPaymentStrategy(new CreditCardPayment("1234-5678-9012-3456"));
        cart.checkout(100.0);

        cart.setPaymentStrategy(new PayPalPayment("user@example.com"));
        cart.checkout(200.0);
    }
}