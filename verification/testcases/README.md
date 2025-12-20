# Testcases: Master-Slave Arbitration Tests

This folder contains 5 testcases to verify arbitration when both masters request the same slave simultaneously.

## Testcases

1. **testcase1_m0_ram.v**: M0 wins arbitration and communicates with RAM
2. **testcase2_m1_ram.v**: M1 wins arbitration and communicates with RAM  
3. **testcase3_m0_uart.v**: M0 wins arbitration and communicates with UART
4. **testcase4_m1_spi.v**: M1 wins arbitration and communicates with SPI
5. **testcase5_m0_gpio.v**: M0 wins arbitration and communicates with GPIO

## Address Map

- RAM:  0x00000000 - 0x1FFFFFFF
- GPIO: 0x40000000 - 0x5FFFFFFF
- UART: 0x80000000 - 0xBFFFFFFF
- SPI:  0xC0000000 - 0xFFFFFFFF

## Running Tests

Each testcase can be compiled and simulated independently. See individual testcase files for details.

