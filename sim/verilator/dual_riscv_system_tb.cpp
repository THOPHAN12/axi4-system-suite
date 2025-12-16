//==============================================================================
// dual_riscv_system_tb.cpp
// C++ wrapper for Verilator simulation
// This file is automatically included by Verilator when using --exe
//==============================================================================

#include "Vdual_riscv_system_tb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>
#include <iomanip>

// Simulation parameters
#define SIM_TIMEOUT 20000
#define CLK_PERIOD 10  // 10ns = 100MHz

int main(int argc, char** argv) {
    // Initialize Verilator
    Verilated::commandArgs(argc, argv);
    
    // Create instance
    Vdual_riscv_system_tb* top = new Vdual_riscv_system_tb;
    
    // Enable waveform tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("dual_riscv_system.vcd");
    
    // Initialize simulation
    vluint64_t sim_time = 0;
    top->ACLK = 0;
    top->ARESETN = 0;
    
    // Reset sequence
    std::cout << "Starting simulation..." << std::endl;
    std::cout << "Applying reset..." << std::endl;
    
    for (int i = 0; i < 10; i++) {
        top->eval();
        tfp->dump(sim_time);
        sim_time += CLK_PERIOD / 2;
        top->ACLK = !top->ACLK;
    }
    
    // Release reset
    top->ARESETN = 1;
    std::cout << "Reset released at time " << sim_time << " ns" << std::endl;
    
    // Run simulation
    int cycle_count = 0;
    while (sim_time < SIM_TIMEOUT * CLK_PERIOD && !Verilated::gotFinish()) {
        // Toggle clock
        top->ACLK = !top->ACLK;
        top->eval();
        tfp->dump(sim_time);
        sim_time += CLK_PERIOD / 2;
        
        if (top->ACLK) {
            cycle_count++;
        }
        
        // Print progress every 1000 cycles
        if (cycle_count % 1000 == 0 && top->ACLK) {
            std::cout << "Cycle: " << cycle_count 
                      << " (Time: " << sim_time << " ns)" << std::endl;
        }
    }
    
    // Finalize
    std::cout << std::endl;
    std::cout << "Simulation completed!" << std::endl;
    std::cout << "Total cycles: " << cycle_count << std::endl;
    std::cout << "Total time: " << sim_time << " ns" << std::endl;
    
    top->final();
    tfp->close();
    
    delete top;
    delete tfp;
    
    return 0;
}


