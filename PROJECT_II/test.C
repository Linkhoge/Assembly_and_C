/*-----------------------------------------------------------
 * Title: Test Script for Sum Loop Program
 * Author: Ariel Fajimiyo
 * Student Number: C00300811
 * Date: May 05, 2025
 * Description: Tests the sum loop assembly functions by prompting the user
 *              for two numbers over three iterations, computing their sum,
 *              and printing the results for verification.
 *-----------------------------------------------------------
 */

#include <stdio.h>

// Declare the assembly functions
extern long compute_sum(long a, long b);
extern long get_running_sum();
extern void reset_running_sum();

int main(int argc, char *argv[]) {
    int num1, num2;
    reset_running_sum();

    // Loop three times, mimicking the assembly program
    for (int i = 1; i <= 3; i++) {
        printf("Test %d - Enter two numbers:\n", i);
        printf("Enter number: ");
        scanf("%d", &num1);
        printf("Enter number: ");
        scanf("%d", &num2);

        // Call the assembly function to compute the sum
        long sum = compute_sum(num1, num2);
        printf("The sum is: %ld\n", sum);
    }

    // Print the final running sum
    printf("Final sum is: %ld\n", get_running_sum());

    return 0;
}
