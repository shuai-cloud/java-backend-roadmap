import java.io.*;

/**
 * 异常处理演示
 */
public class ExceptionDemo {

    // 自定义受检异常
    static class InsufficientFundsException extends Exception {
        public InsufficientFundsException(String message) {
            super(message);
        }
    }

    // 自定义非受检异常
    static class InvalidAmountException extends RuntimeException {
        public InvalidAmountException(String message) {
            super(message);
        }
    }

    public static void withdraw(double amount) throws InsufficientFundsException {
        double balance = 100.0;
        if (amount > balance) {
            throw new InsufficientFundsException("余额不足，当前余额: " + balance);
        }
        if (amount <= 0) {
            throw new InvalidAmountException("金额必须为正数");
        }
        System.out.println("取款成功: " + amount);
    }

    public static void main(String[] args) {
        // try-catch-finally
        try {
            int result = 10 / 0;
        } catch (ArithmeticException e) {
            System.out.println("捕获异常: " + e.getMessage());
        } finally {
            System.out.println("finally 总会执行");
        }

        // 自定义异常
        try {
            withdraw(200);
        } catch (InsufficientFundsException e) {
            System.out.println("业务异常: " + e.getMessage());
        }

        // try-with-resources (Java 7+)
        try (BufferedReader br = new BufferedReader(new FileReader("test.txt"))) {
            String line = br.readLine();
            System.out.println(line);
        } catch (FileNotFoundException e) {
            System.out.println("文件未找到: " + e.getMessage());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}