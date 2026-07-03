/**
 * 动态规划算法演示
 */
public class DynamicProgrammingDemo {
    // 斐波那契数列（空间优化）
    public int fib(int n) {
        if (n <= 1) return n;
        int prev2 = 0, prev1 = 1;
        for (int i = 2; i <= n; i++) {
            int curr = prev1 + prev2;
            prev2 = prev1;
            prev1 = curr;
        }
        return prev1;
    }

    // 爬楼梯
    public int climbStairs(int n) {
        if (n <= 2) return n;
        int prev2 = 1, prev1 = 2;
        for (int i = 3; i <= n; i++) {
            int curr = prev1 + prev2;
            prev2 = prev1;
            prev1 = curr;
        }
        return prev1;
    }

    // 最长递增子序列
    public int lengthOfLIS(int[] nums) {
        int n = nums.length;
        int[] dp = new int[n];
        Arrays.fill(dp, 1);
        int maxLen = 1;
        for (int i = 1; i < n; i++) {
            for (int j = 0; j < i; j++) {
                if (nums[j] < nums[i]) {
                    dp[i] = Math.max(dp[i], dp[j] + 1);
                }
            }
            maxLen = Math.max(maxLen, dp[i]);
        }
        return maxLen;
    }

    public static void main(String[] args) {
        DynamicProgrammingDemo demo = new DynamicProgrammingDemo();
        System.out.println("fib(10): " + demo.fib(10));
        System.out.println("climbStairs(5): " + demo.climbStairs(5));
        System.out.println("LIS [10,9,2,5,3,7,101,18]: " + demo.lengthOfLIS(new int[]{10,9,2,5,3,7,101,18}));
    }
}