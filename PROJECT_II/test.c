/*-----------------------------------------------------------
 * Title: Test Script for Sum Loop Program
 * Author: Ariel Fajimiyo
 * Student Number: C00300811
 * Date: May 05, 2025
 * Description: Tests the sum loop assembly functions by prompting for user input
 *              using scanf in a for loop, and printing the results.
 *-----------------------------------------------------------
 */

#include <stdio.h>

// Declare the assembly functions from sum_loop_func.asm
extern long compute_sum(long a, long b);   // Returns the actual sum, updates running sum
extern long get_running_sum();             // Returns the current running sum
extern void reset_running_sum();           // Resets the running sum to 0

int main() {
    long num1, num2;

    // Reset the running sum at the start
    reset_running_sum();

    // Loop for 3 iterations to match sum_loop.asm
    for (int i = 0; i < 3; i++) {
        // Prompt for first number
        printf("Enter number: ");
        scanf("%ld", &num1);

        // Prompt for second number
        printf("Enter number: ");
        scanf("%ld", &num2);

        // Compute the sum using the assembly function
        long sum = compute_sum(num1, num2);

        // Print the sum
        printf("The sum is: %ld\n", sum);
    }

    // Print the final running sum
    printf("Final sum is: %ld\n", get_running_sum());

    return 0;
}
