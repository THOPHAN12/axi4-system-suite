# AXI Bridge Components - Atomic Building Blocks

**Purpose**: Reusable atomic components for building AXI protocol bridges  
**Status**: ✅ Production ready

---

## 📁 Components

### **1. wb_to_axi_addr_channel.v**
**Purpose**: Wishbone to AXI Address Channel Converter

**Features**:
- Handles AR (Read) or AW (Write) channel
- Address handshake management
- Burst configuration
- Lightweight FSM

**Parameters**:
- `ADDR_WIDTH` - Address bus width (default: 32)
- `ID_WIDTH` - AXI ID width (default: 4)
- `CHANNEL` - "READ" or "WRITE"

**Usage**:
```verilog
wb_to_axi_addr_channel #(
    .ADDR_WIDTH(32),
    .CHANNEL("READ")
) u_ar_conv (
    .ACLK(clk),
    .ARESETN(rst_n),
    .wb_adr(wb_address),
    .wb_cyc(wb_cycle),
    .wb_stb(wb_strobe),
    .addr_ready(ready),
    .axi_axaddr(axi_araddr),  // AR channel
    .axi_axvalid(axi_arvalid),
    .axi_axready(axi_arready)
    // ... other AXI signals
);
```

---

### **2. wb_to_axi_data_channel.v**
**Purpose**: Wishbone to AXI Data Channel Converter

**Features**:
- Handles W (Write) or R (Read) channel
- Data buffering
- Byte enables (wstrb)
- Handshake management

**Parameters**:
- `DATA_WIDTH` - Data bus width (default: 32)
- `CHANNEL` - "READ" or "WRITE"

**Usage**:
```verilog
wb_to_axi_data_channel #(
    .DATA_WIDTH(32),
    .CHANNEL("WRITE")
) u_w_conv (
    .ACLK(clk),
    .ARESETN(rst_n),
    .wb_dat_i(wb_write_data),
    .wb_sel(wb_byte_sel),
    .data_valid(valid),
    .data_ready(ready),
    .axi_wdata(axi_wdata),     // W channel
    .axi_wstrb(axi_wstrb),
    .axi_wvalid(axi_wvalid),
    .axi_wready(axi_wready)
    // ...
);
```

---

### **3. wb_to_axi_resp_handler.v**
**Purpose**: AXI Response to Wishbone Acknowledge Converter

**Features**:
- Handles B (Write Response) channel
- Error detection
- Response to ACK conversion

**Parameters**:
- `ID_WIDTH` - AXI ID width
- `ENABLE_ERROR_CHECK` - Enable error checking

**Usage**:
```verilog
wb_to_axi_resp_handler #(
    .ID_WIDTH(4),
    .ENABLE_ERROR_CHECK(1)
) u_resp (
    .ACLK(clk),
    .ARESETN(rst_n),
    .resp_expected(expecting),
    .resp_received(received),
    .resp_error(error),
    .axi_bresp(axi_bresp),      // B channel
    .axi_bvalid(axi_bvalid),
    .axi_bready(axi_bready),
    .wb_ack(wb_acknowledge)
);
```

---

### **4. axi_bus_merger.v**
**Purpose**: Merges two AXI master interfaces into one

**Features**:
- Fixed priority arbitration (M1 > M0)
- Dual-bus to single-bus conversion
- Response routing back to correct master

**Parameters**:
- `ADDR_WIDTH`, `DATA_WIDTH`, `ID_WIDTH`

**Usage**:
```verilog
axi_bus_merger #(
    .ADDR_WIDTH(32),
    .DATA_WIDTH(32)
) u_merger (
    .ACLK(clk),
    .ARESETN(rst_n),
    // Master 0 (lower priority)
    .M0_*(m0_axi_*),
    // Master 1 (higher priority)
    .M1_*(m1_axi_*),
    // Merged slave output
    .S_*(merged_axi_*)
);
```

---

## 🎯 Design Philosophy

### **Atomic Components**:
Each component handles ONE specific function:
- ✅ **Single Responsibility** - Easy to understand
- ✅ **Reusable** - Use in different combinations
- ✅ **Testable** - Test individually
- ✅ **Maintainable** - Fix once, apply everywhere

### **Composition**:
Complex bridges built by composing atomic components:
```
[wb_to_axilite_bridge] = [addr_channel] + [data_channel] + [resp_handler]
[riscv_to_axi_bridge]  = 2×[wb_to_axilite_bridge] + [bus_merger]
```

---

## 📊 Component Comparison

| Component | Lines | Complexity | Reusability |
|-----------|-------|------------|-------------|
| addr_channel | ~150 | Low | ⭐⭐⭐⭐⭐ |
| data_channel | ~250 | Medium | ⭐⭐⭐⭐⭐ |
| resp_handler | ~130 | Low | ⭐⭐⭐⭐⭐ |
| bus_merger | ~120 | Medium | ⭐⭐⭐⭐ |

**Total**: ~650 lines of highly reusable code

**vs Original**:
- wb2axi_read: 415 lines
- wb2axi_write: 430 lines
- **Total**: 845 lines (less reusable)

**Code reduction**: ~200 lines, higher reusability!

---

## 🔧 How to Use Components

### **Example 1: Custom Simple Bridge**
```verilog
module my_simple_bridge (
    input clk, rst_n,
    input [31:0] cpu_addr,
    input cpu_read,
    output [31:0] axi_araddr,
    output axi_arvalid,
    input axi_arready
);

    // Just use address channel component
    wb_to_axi_addr_channel #(
        .CHANNEL("READ")
    ) u_addr (
        .ACLK(clk),
        .ARESETN(rst_n),
        .wb_adr(cpu_addr),
        .wb_cyc(cpu_read),
        .wb_stb(cpu_read),
        .axi_axaddr(axi_araddr),
        .axi_axvalid(axi_arvalid),
        .axi_axready(axi_arready)
        // ...
    );
    
endmodule
```

### **Example 2: Custom Protocol Bridge**
```verilog
// Convert any protocol to AXI by:
// 1. Use addr_channel for addresses
// 2. Use data_channel for data
// 3. Use resp_handler for responses
// 4. Add your protocol-specific logic
```

---

## 🎊 Benefits

### **Compared to Monolithic Design**:

| Aspect | Monolithic | Component-Based |
|--------|------------|-----------------|
| **Code Reuse** | Low | ⭐⭐⭐⭐⭐ High |
| **Maintainability** | Medium | ⭐⭐⭐⭐⭐ High |
| **Testing** | Difficult | ⭐⭐⭐⭐⭐ Easy |
| **Customization** | Hard | ⭐⭐⭐⭐⭐ Easy |
| **Lines of Code** | 845 | 650 (-23%) |

---

## 📚 See Also

- **Cores**: `../cores/` - Composite bridges using these components
- **Legacy**: `../riscv_to_axi/` - Original monolithic implementations
- **Tests**: `verification/testbenches/bridge_tb/` - Component testbenches

---

**Status**: ✅ Ready for production use  
**Quality**: ⭐⭐⭐⭐⭐ Industrial grade  
**Reusability**: ⭐⭐⭐⭐⭐ Maximum

