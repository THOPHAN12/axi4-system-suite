# Master Controller - Hướng Dẫn Sử Dụng

## 📋 Tổng Quan

**Master Controller** là một module điều khiển cấp cao được thiết kế để quản lý và điều phối nhiều AXI master modules trong hệ thống. Controller này cung cấp một lớp trừu tượng (abstraction layer) giúp testbench dễ dàng điều khiển các master modules mà không cần viết hàng trăm dòng code phức tạp.

---

## 🎯 Mục Đích

### Vấn Đề Trước Khi Có Controller:

```systemverilog
// Testbench phải viết rất nhiều code để điều khiển masters
@(posedge ACLK);
m0_start = 1;
@(posedge ACLK);
m0_start = 0;
wait(m0_busy);
wait(m0_completed);
@(posedge ACLK);
m1_start = 1;
@(posedge ACLK);
m1_start = 0;
wait(m1_busy);
wait(m1_completed);
// ... hàng trăm dòng code tương tự
```

### Giải Pháp Với Controller:

```systemverilog
// Chỉ cần vài dòng code đơn giản
controller.start_m0_task();
wait(m0_completed);
controller.start_m1_task();
wait(m1_completed);
// Hoặc sử dụng high-level tasks
sequential_m0_then_m1();
```

---

## 🏗️ Kiến Trúc

### Sơ Đồ Khối

```
┌─────────────────────────────────────────────────────────┐
│                  Master Controller                       │
│                                                          │
│  ┌──────────────┐      ┌──────────────┐                │
│  │   State      │      │   Control    │                │
│  │   Machine    │◄────►│   Logic      │                │
│  └──────────────┘      └──────────────┘                │
│         │                      │                        │
│         ▼                      ▼                        │
│  ┌──────────────┐      ┌──────────────┐                │
│  │   Status     │      │   Start      │                │
│  │   Monitor    │      │   Signals    │                │
│  └──────────────┘      └──────────────┘                │
│         │                      │                        │
└─────────┼──────────────────────┼────────────────────────┘
          │                      │
          ▼                      ▼
    ┌──────────┐          ┌──────────┐
    │ Master 0 │          │ Master 1 │
    │ (busy/   │          │ (busy/   │
    │  done)   │          │  done)   │
    └──────────┘          └──────────┘
```

### Cấu Trúc Module

```systemverilog
module master_controller #(
    parameter NUM_MASTERS = 2
)(
    input logic ACLK,
    input logic ARESETN,
    
    // Master 0 Control Interface
    output logic m0_start,
    input logic m0_busy,
    input logic m0_completed,
    
    // Master 1 Control Interface
    output logic m1_start,
    input logic m1_busy,
    input logic m1_completed,
    
    // Status outputs
    output logic all_idle,
    output logic any_busy,
    output logic all_completed,
    output logic [1:0] controller_state
);
```

---

## ⚙️ Cách Hoạt Động

### 1. State Machine

Controller sử dụng state machine để theo dõi trạng thái của các master modules:

```
┌──────┐
│ IDLE │ ◄──────────────────┐
└──┬───┘                    │
   │                        │
   │ M0 busy                │ Both idle
   ▼                        │
┌─────────────┐             │
│ M0_RUNNING  │             │
└──┬──────────┘             │
   │                        │
   │ M1 busy                │
   ▼                        │
┌─────────────┐             │
│BOTH_RUNNING │─────────────┘
└──┬──────────┘
   │
   │ M0 idle
   ▼
┌─────────────┐
│ M1_RUNNING  │
└─────────────┘
```

#### Các Trạng Thái:

| State | Mô Tả |
|-------|-------|
| `IDLE` (2'b00) | Không có master nào đang busy |
| `M0_RUNNING` (2'b01) | Chỉ Master 0 đang busy |
| `M1_RUNNING` (2'b10) | Chỉ Master 1 đang busy |
| `BOTH_RUNNING` (2'b11) | Cả 2 masters đều đang busy |

#### Chuyển Đổi Trạng Thái:

```systemverilog
case (state)
    IDLE: begin
        if (m0_busy && m1_busy)      state <= BOTH_RUNNING;
        else if (m0_busy)            state <= M0_RUNNING;
        else if (m1_busy)            state <= M1_RUNNING;
    end
    
    M0_RUNNING: begin
        if (m1_busy)                 state <= BOTH_RUNNING;
        else if (!m0_busy)           state <= IDLE;
    end
    
    M1_RUNNING: begin
        if (m0_busy)                 state <= BOTH_RUNNING;
        else if (!m1_busy)           state <= IDLE;
    end
    
    BOTH_RUNNING: begin
        if (!m0_busy && !m1_busy)    state <= IDLE;
        else if (!m0_busy)           state <= M1_RUNNING;
        else if (!m1_busy)           state <= M0_RUNNING;
    end
endcase
```

### 2. Control Logic

#### Start Signal Generation:

- Start signals được tạo từ internal registers (`m0_start_reg`, `m1_start_reg`)
- Tự động clear sau 1 clock cycle để tạo pulse
- Có thể được set thông qua tasks từ testbench

```systemverilog
assign m0_start = m0_start_reg;
assign m1_start = m1_start_reg;

// Auto-clear after one cycle
always_ff @(posedge ACLK) begin
    if (m0_start_reg) m0_start_reg <= 1'b0;
    if (m1_start_reg) m1_start_reg <= 1'b0;
end
```

### 3. Status Monitoring

Controller cung cấp các status outputs để testbench dễ dàng monitor:

```systemverilog
assign all_idle = !m0_busy && !m1_busy;
assign any_busy = m0_busy || m1_busy;
assign all_completed = m0_completed && m1_completed;
```

| Signal | Mô Tả |
|--------|-------|
| `all_idle` | Tất cả masters đều idle (không busy) |
| `any_busy` | Có ít nhất 1 master đang busy |
| `all_completed` | Tất cả masters đã hoàn thành operation |
| `controller_state` | Trạng thái hiện tại của state machine |

---

## 📖 Cách Sử Dụng

### 1. Instantiate Controller

```systemverilog
master_controller #(
    .NUM_MASTERS(2)
) controller (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .m0_start(m0_start),
    .m0_busy(m0_busy),
    .m0_completed(m0_completed),
    .m1_start(m1_start),
    .m1_busy(m1_busy),
    .m1_completed(m1_completed),
    .all_idle(all_idle),
    .any_busy(any_busy),
    .all_completed(all_completed),
    .controller_state(controller_state)
);
```

### 2. Kết Nối Với Master Modules

```systemverilog
// Master 0
axi_master_0 master0 (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .start(m0_start),        // ← Từ controller
    .busy(m0_busy),          // → Đến controller
    .completed(m0_completed), // → Đến controller
    // ... AXI signals
);

// Master 1
axi_master_1 master1 (
    .ACLK(ACLK),
    .ARESETN(ARESETN),
    .start(m1_start),        // ← Từ controller
    .busy(m1_busy),          // → Đến controller
    .completed(m1_completed), // → Đến controller
    // ... AXI signals
);
```

### 3. Sử Dụng Tasks Trong Testbench

#### Basic Tasks:

```systemverilog
// Start Master 0
controller.start_m0_task();

// Start Master 1
controller.start_m1_task();

// Start cả 2 masters
controller.start_both_task();
```

#### High-Level Tasks:

```systemverilog
// Sequential operation: M0 rồi đến M1
task sequential_m0_then_m1();
    controller.start_m0_task();
    wait(m0_completed);
    controller.start_m1_task();
    wait(m1_completed);
endtask

// Parallel operation: cả 2 cùng chạy
task parallel_both();
    controller.start_both_task();
    wait(all_idle);
endtask

// Contention test: M1 start khi M0 đang chạy
task contention_test();
    controller.start_m0_task();
    wait(m0_busy);
    #(CLK_PERIOD * 2);
    controller.start_m1_task();
    wait(all_idle);
endtask
```

---

## 💡 Ví Dụ Sử Dụng

### Ví Dụ 1: Sequential Operation

```systemverilog
initial begin
    // Reset
    ARESETN = 0;
    #100;
    ARESETN = 1;
    #20;
    
    // Sequential: M0 rồi M1
    $display("Starting sequential operation...");
    controller.start_m0_task();
    wait(m0_completed);
    $display("M0 completed");
    
    controller.start_m1_task();
    wait(m1_completed);
    $display("M1 completed");
end
```

### Ví Dụ 2: Parallel Operation

```systemverilog
initial begin
    // Reset
    ARESETN = 0;
    #100;
    ARESETN = 1;
    #20;
    
    // Parallel: cả 2 cùng chạy
    $display("Starting parallel operation...");
    controller.start_both_task();
    
    // Monitor busy flags
    while (any_busy) begin
        @(posedge ACLK);
        $display("Status: M0_busy=%b, M1_busy=%b, State=%0d",
                 m0_busy, m1_busy, controller_state);
    end
    
    $display("Both masters completed");
end
```

### Ví Dụ 3: Contention Test

```systemverilog
initial begin
    // Reset
    ARESETN = 0;
    #100;
    ARESETN = 1;
    #20;
    
    // Contention: M1 start khi M0 đang chạy
    $display("Starting contention test...");
    controller.start_m0_task();
    
    wait(m0_busy);
    $display("M0 is busy, starting M1...");
    
    #(CLK_PERIOD * 2);
    controller.start_m1_task();
    
    // Monitor cả 2
    wait(all_idle);
    $display("Contention test completed");
end
```

### Ví Dụ 4: Monitor Busy Flags

```systemverilog
// Monitor busy flags trong một khoảng thời gian
task monitor_busy_flags(int duration_ns);
    int start_time = $time;
    while (($time - start_time) < duration_ns) begin
        @(posedge ACLK);
        if (any_busy) begin
            $display("[%0t] BUSY: M0=%b, M1=%b, State=%0d",
                     $time, m0_busy, m1_busy, controller_state);
        end
    end
endtask

// Sử dụng
initial begin
    // ... setup ...
    fork
        controller.start_both_task();
        monitor_busy_flags(1000);  // Monitor trong 1000ns
    join
end
```

---

## 🔄 So Sánh: Trước và Sau

### Trước Khi Có Controller (100+ dòng code):

```systemverilog
initial begin
    // Reset
    ARESETN = 0;
    #100;
    ARESETN = 1;
    #20;
    
    // Start M0
    @(posedge ACLK);
    m0_start = 1;
    @(posedge ACLK);
    m0_start = 0;
    
    // Wait for M0 busy
    wait(m0_busy);
    $display("M0 is busy");
    
    // Wait for M0 completed
    wait(m0_completed);
    $display("M0 completed");
    
    // Start M1
    @(posedge ACLK);
    m1_start = 1;
    @(posedge ACLK);
    m1_start = 0;
    
    // Wait for M1 busy
    wait(m1_busy);
    $display("M1 is busy");
    
    // Wait for M1 completed
    wait(m1_completed);
    $display("M1 completed");
    
    // ... nhiều dòng code tương tự cho các test cases khác ...
end
```

### Sau Khi Có Controller (Chỉ vài dòng):

```systemverilog
initial begin
    // Reset
    ARESETN = 0;
    #100;
    ARESETN = 1;
    #20;
    
    // Sequential operation - chỉ 1 dòng!
    sequential_m0_then_m1();
    
    // Hoặc parallel operation
    parallel_both();
    
    // Hoặc contention test
    contention_test();
end
```

---

## 🎨 Advanced Features

### 1. BFM Class (SystemVerilog)

Controller cung cấp BFM class để sử dụng trong testbench:

```systemverilog
// Khai báo interface
master_controller_if controller_if(ACLK);

// Instantiate BFM
master_controller_bfm bfm = new(controller_if);

// Sử dụng BFM tasks
bfm.start_m0();
bfm.wait_m0_complete();
bfm.sequential_m0_then_m1();
bfm.parallel_both();
bfm.contention_test();
```

### 2. Interface Definition

```systemverilog
interface master_controller_if(input logic ACLK);
    logic m0_start;
    logic m0_busy;
    logic m0_completed;
    logic m1_start;
    logic m1_busy;
    logic m1_completed;
    logic all_idle;
    logic any_busy;
    logic all_completed;
    logic [1:0] controller_state;
    
    // Clocking block
    clocking cb @(posedge ACLK);
        output m0_start, m1_start;
        input m0_busy, m1_busy, m0_completed, m1_completed;
        input all_idle, any_busy, all_completed, controller_state;
    endclocking
endinterface
```

---

## 📊 Timing Diagram

### Sequential Operation:

```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
m0_start:  ____|‾‾|________________________________________________
m0_busy:   ________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________
m0_done:   ________________________________________|‾‾|____________
m1_start:  ________________________________________|‾‾|____________
m1_busy:   __________________________________________|‾‾‾‾‾‾‾‾‾‾‾‾|__
m1_done:   ________________________________________________|‾‾|____
State:     IDLE    M0_RUN    IDLE    M1_RUN    IDLE
```

### Parallel Operation:

```
Clock:     __|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__|‾|__
m0_start:  ____|‾‾|____________________________________________
m1_start:  ____|‾‾|____________________________________________
m0_busy:   ________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|__________
m1_busy:   ________|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|____
State:     IDLE    BOTH_RUN    M1_RUN    IDLE
```

---

## ✅ Lợi Ích

1. **Code Gọn Gàng**: Giảm từ 100+ dòng xuống chỉ vài dòng
2. **Dễ Bảo Trì**: Logic điều khiển tập trung ở một nơi
3. **Tái Sử Dụng**: Có thể dùng cho nhiều testbench khác nhau
4. **Dễ Debug**: State machine rõ ràng, dễ theo dõi
5. **High-Level Abstraction**: Testbench tập trung vào test scenarios, không phải low-level control

---

## 📁 File Locations

- **SystemVerilog**: `SystemVerilog/axi_masters/master_controller.sv`
- **Verilog**: `src/axi_masters/master_controller.v`
- **Testbench**: `SystemVerilog/testbenches/axi_masters/master_controller_tb.sv`
- **Example**: `SystemVerilog/testbenches/axi_masters/dual_master_with_controller_tb.sv`

---

## 🔗 Xem Thêm

- [AXI Master Modules](../axi_masters/README.md)
- [Testbench Guidelines](../../verification/README.md)
- [System Architecture Overview](./DUAL_MASTER_SYSTEM_DIAGRAM.md)

---

**Tác giả**: Auto-generated  
**Ngày tạo**: 2024  
**Phiên bản**: 1.0


