# Tín Hiệu Chọn Master trong AXI Interconnect

## Tổng Quan

AXI Interconnect sử dụng **arbitration logic** để chọn master nào được truy cập bus khi nhiều master cùng request. Có 2 loại arbitration:
- **Fixed Priority**: Master 0 luôn có priority cao hơn Master 1
- **Round-Robin**: Luân phiên giữa các master để tránh starvation
- **QoS-based**: Dựa vào QoS value để quyết định

## 1. Tín Hiệu Đầu Vào (Input Signals)

### 1.1. Tín Hiệu VALID - Xác Định Master Đang Request

#### Write Address Channel:
```verilog
S00_AXI_awvalid  // Master 0 (SERV RISC-V) write request
S01_AXI_awvalid  // Master 1 (ALU Master) write request
```

#### Read Address Channel:
```verilog
S00_AXI_arvalid  // Master 0 (SERV RISC-V) read request
S01_AXI_arvalid  // Master 1 (ALU Master) read request
```

**Logic:**
- Khi `S00_AXI_awvalid = 1`: Master 0 đang muốn ghi dữ liệu
- Khi `S01_AXI_awvalid = 1`: Master 1 đang muốn ghi dữ liệu
- Khi cả hai = 1: Cả hai master cùng request → Cần arbitration

### 1.2. Tín Hiệu QoS (Quality of Service) - Cho Read Channel

```verilog
S00_AXI_arqos[3:0]  // QoS của Master 0 (0-15, cao hơn = ưu tiên hơn)
S01_AXI_arqos[3:0]  // QoS của Master 1 (0-15, cao hơn = ưu tiên hơn)
```

**Sử dụng trong Read_Arbiter.v:**
- So sánh `S00_AXI_arqos >= S01_AXI_arqos` để quyết định master nào được chọn
- Nếu bằng nhau → Master 0 được ưu tiên (default)

## 2. Logic Chọn Master (Arbitration Logic)

### 2.1. Write Address Channel (Write_Arbiter.v)

**Fixed Priority:**
```verilog
always @(*) begin
    if (S00_AXI_awvalid) begin
        Selected_Master = 1'b0;  // Master 0 luôn thắng
    end else if (S01_AXI_awvalid) begin
        Selected_Master = 1'b1;  // Chỉ khi M0 không request
    end else begin
        Selected_Master = 1'b0;  // Default
    end
end
```

**Truth Table:**
| M0_valid | M1_valid | Selected | Ghi chú |
|----------|---------|----------|---------|
| 0 | 0 | M0 (default) | Không có request |
| 1 | 0 | M0 | Chỉ M0 request |
| 0 | 1 | M1 | Chỉ M1 request |
| 1 | 1 | M0 | **Fixed Priority: M0 luôn thắng** |

**⚠️ Lưu ý:** Fixed Priority có thể gây starvation cho Master 1 nếu Master 0 liên tục request.

### 2.2. Read Address Channel (Read_Arbiter.v)

**QoS-based Priority:**
```verilog
always @(*) begin
    if (S00_AXI_arvalid && S01_AXI_arvalid) begin
        // Cả hai request → So sánh QoS
        if (S00_AXI_arqos >= S01_AXI_arqos) begin
            Master = 1'b0;  // M0 có QoS cao hơn hoặc bằng
        end else begin
            Master = 1'b1;  // M1 có QoS cao hơn
        end
    end else if (S00_AXI_arvalid) begin
        Master = 1'b0;  // Chỉ M0 request
    end else if (S01_AXI_arvalid) begin
        Master = 1'b1;  // Chỉ M1 request
    end else begin
        Master = 1'b0;  // Default
    end
end
```

**Truth Table:**
| M0_valid | M1_valid | M0_QoS | M1_QoS | Selected | Ghi chú |
|----------|---------|--------|--------|----------|---------|
| 0 | 0 | x | x | M0 (default) | Không có request |
| 1 | 0 | x | x | M0 | Chỉ M0 request |
| 0 | 1 | x | x | M1 | Chỉ M1 request |
| 1 | 1 | >= | < | M0 | M0 có QoS cao hơn |
| 1 | 1 | < | >= | M1 | M1 có QoS cao hơn |
| 1 | 1 | == | == | M0 | Bằng nhau → M0 ưu tiên |

### 2.3. Round-Robin (Write_Arbiter_RR.v)

**Round-Robin Logic:**
```verilog
always @(*) begin
    if (S00_AXI_awvalid && S01_AXI_awvalid) begin
        // Cả hai request → Round-Robin
        if (last_served == 1'b0) begin
            Slave = 1'b1;  // M0 được serve lần trước → Serve M1
        end else begin
            Slave = 1'b0;  // M1 được serve lần trước → Serve M0
        end
    end else if (S00_AXI_awvalid) begin
        Slave = 1'b0;
    end else if (S01_AXI_awvalid) begin
        Slave = 1'b1;
    end else begin
        Slave = 1'b0;
    end
end
```

**Ưu điểm:** Tránh starvation, đảm bảo công bằng giữa các master.

## 3. Tín Hiệu Đầu Ra (Output Signals)

### 3.1. Selected Master Signal

```verilog
Selected_Master  // [Masters_ID_Size-1:0]
// 0 = Master 0 (SERV RISC-V)
// 1 = Master 1 (ALU Master)
```

**Sử dụng:**
- Điều khiển MUX để route address/data từ master được chọn
- Lưu trữ trong register để đảm bảo timing

### 3.2. Selected Slave Signal

```verilog
Selected_Slave  // [1:0]
// 00 = Slave 0 (Instruction Memory)
// 01 = Slave 1 (Data Memory)
// 10 = Slave 2 (ALU Memory)
// 11 = Slave 3 (Reserved Memory)
```

**Được decode từ address:**
```verilog
if (addr >= SLAVE0_ADDR1 && addr <= SLAVE0_ADDR2) begin
    Selected_Slave = 2'b00;  // Instruction Memory
end else if (addr >= SLAVE1_ADDR1 && addr <= SLAVE1_ADDR2) begin
    Selected_Slave = 2'b01;  // Data Memory
end
// ...
```

## 4. Write Response Channel - Route Response Về Đúng Master

### 4.1. Tín Hiệu BID (Write Response ID)

```verilog
M00_AXI_BID  // ID từ Slave 0
M01_AXI_BID  // ID từ Slave 1
M02_AXI_BID  // ID từ Slave 2
M03_AXI_BID  // ID từ Slave 3
```

**Logic trong Write_Resp_Channel_Arb.v:**
```verilog
casez (Slaves_Valid)
    4'b???1: begin  // Slave 0 có priority cao nhất
        Sel_Resp_ID_Comb = M00_AXI_BID;
    end
    4'b??10: begin  // Slave 1
        Sel_Resp_ID_Comb = M01_AXI_BID;
    end
    4'b?100: begin  // Slave 2
        Sel_Resp_ID_Comb = M02_AXI_BID;
    end
    4'b1000: begin  // Slave 3
        Sel_Resp_ID_Comb = M03_AXI_BID;
    end
endcase
```

**Mục đích:** Route write response về đúng master dựa vào BID.

## 5. Ví Dụ Thực Tế

### Scenario 1: Chỉ Master 0 Request
```
S00_AXI_awvalid = 1
S01_AXI_awvalid = 0
→ Selected_Master = 0 (SERV RISC-V)
```

### Scenario 2: Cả Hai Master Cùng Request (Write)
```
S00_AXI_awvalid = 1
S01_AXI_awvalid = 1
→ Selected_Master = 0 (Fixed Priority: M0 luôn thắng)
```

### Scenario 3: Cả Hai Master Cùng Request (Read với QoS)
```
S00_AXI_arvalid = 1, S00_AXI_arqos = 5
S01_AXI_arvalid = 1, S01_AXI_arqos = 8
→ Selected_Master = 1 (M1 có QoS cao hơn: 8 > 5)
```

### Scenario 4: Round-Robin
```
Lần 1: M0 và M1 cùng request → Chọn M0 (last_served = 0)
Lần 2: M0 và M1 cùng request → Chọn M1 (last_served = 1)
Lần 3: M0 và M1 cùng request → Chọn M0 (last_served = 0)
→ Luân phiên công bằng
```

## 6. Tóm Tắt

| Tín Hiệu | Mô Tả | Sử Dụng |
|----------|-------|---------|
| `S00_AXI_*valid` | Master 0 đang request | Đầu vào arbitration |
| `S01_AXI_*valid` | Master 1 đang request | Đầu vào arbitration |
| `S00_AXI_arqos` | QoS của Master 0 | So sánh priority (Read) |
| `S01_AXI_arqos` | QoS của Master 1 | So sánh priority (Read) |
| `Selected_Master` | Master được chọn | Điều khiển MUX |
| `Selected_Slave` | Slave được chọn | Route đến đúng slave |
| `M*_AXI_BID` | Response ID từ slave | Route response về master |

## 7. Files Liên Quan

- `src/axi_interconnect/rtl/arbitration/Read_Arbiter.v` - Read channel arbitration (QoS-based)
- `src/axi_interconnect/rtl/arbitration/Write_Arbiter.v` - Write channel arbitration (Fixed Priority)
- `src/axi_interconnect/rtl/arbitration/Write_Arbiter_RR.v` - Write channel arbitration (Round-Robin)
- `src/axi_interconnect/rtl/decoders/Write_Resp_Channel_Arb.v` - Write response routing

