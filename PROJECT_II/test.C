/*-----------------------------------------------------------
 * Title: Test Script for Sum Loop Program
 * Author: Ariel Fajimiyo
 * Student Number: C00300811
 * Description: Tests the sum loop assembly functions using predefined inputs
 *              and assert statements
 *-----------------------------------------------------------
 */

#include <assert.h>
#include <stdio.h>

// Declare the assembly functions from sum_loop_func.asm
extern long compute_sum(long a, long b);   // Returns the second number, updates running sum
extern long get_running_sum();             // Returns the current running sum
extern void reset_running_sum();           // Resets the running sum to 0

int main(int argc, char *argv[]) {
    // Test Case 1: Basic addition
    reset_running_sum();                   // Reset running sum at the start
    printf("Running Test 1 - Basic addition:\n");

    // Perform three iterations and verify sums (compute_sum returns second number)
    long sum1 = compute_sum(123, 456);    // Returns 456, running sum += 123 + 456
    assert(sum1 == 456);                   // Verify returned value is second number
    long sum2 = compute_sum(100, 200);    // Returns 200, running sum += 100 + 200
    assert(sum2 == 200);
    long sum3 = compute_sum(50, 75);      // Returns 75, running sum += 50 + 75
    assert(sum3 == 75);
    assert(get_running_sum() == 1004);     // Verify running sum: 579 + 300 + 125 = 1004
    printf("Test 1 passed\n");

    // Test Case 2: Overflow wrapping (demonstrating overflow behavior)
    reset_running_sum();                   // Reset running sum
    printf("Running Test 2 - Overflow wrapping:\n");

    // Use numbers that cause overflow in a 64-bit long
    long sum4 = compute_sum(9223372036854775807, 1);  // Returns 1, running sum += wrapped value
    assert(sum4 == 1);                                // Verify returned value is second number
    long sum5 = compute_sum(1, 1);                    // Returns 1, running sum += 2
    assert(sum5 == 1);
    long sum6 = compute_sum(1, 1);                    // Returns 1, running sum += 2
    assert(sum6 == 1);
    assert(get_running_sum() == -9223372036854775804); // Verify running sum
    printf("Test 2 passed\n");

    // Test Case 3: Negative numbers
    reset_running_sum();                   // Reset running sum
    printf("Running Test 3 - Negative numbers:\n");

    // Perform three iterations with negative numbers
    long sum7 = compute_sum(-100, 50);     // Returns 50, running sum += -50
    assert(sum7 == 50);
    long sum8 = compute_sum(20, -30);      // Returns -30, running sum += -10
    assert(sum8 == -30);
    long sum9 = compute_sum(-10, -20);     // Returns -20, running sum += -30
    assert(sum9 == -20);
    assert(get_running_sum() == -90);      // Verify running sum: -50 + (-10) + (-30) = -90
    printf("Test 3 passed\n");

    printf("All tests passed successfully!\n");  // Indicate all assertions passed
    return 0;                                    // Exit program
}
