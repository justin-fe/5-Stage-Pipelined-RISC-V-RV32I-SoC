// firmware/main.c
// Simple bare-metal C program for the RISC-V SoC

volatile int *led_register = (int *) 0x40000000; // Memory-mapped LED register

int main(void) {
    int a = 10;
    int b = 20;
    int sum = 0;

    while(1) {
        sum = a + b;
        *led_register = sum; // Write result to memory-mapped hardware
        a++;
    }

    return 0;
}
