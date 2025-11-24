# Luồng Dữ Liệu - 7 Test Cases

> **Hướng dẫn export sang JPG:**
> 1. Sử dụng Mermaid Live Editor: https://mermaid.live/
> 2. Copy từng diagram vào editor
> 3. Click "Actions" -> "Download PNG" hoặc "Download SVG"
> 4. Hoặc sử dụng Mermaid CLI: `mmdc -i diagram.mmd -o diagram.jpg`

---

## TEST CASE 1: SERV Master -> Instruction Memory (Read at Reset PC)

```mermaid
flowchart TD
    A["SERV RISC-V Core<br/>PC = 0x0000_0000"] --> B["serv_axi_wrapper<br/>(Wishbone -> AXI converter)"]
    B --> C["M00_AXI_araddr = 0x0000_0000<br/>M00_AXI_arvalid = 1"]
    C --> D["AXI Interconnect<br/>Address Decoder: 0x0000_0000 -> Slave0"]
    D --> E["Slave0 (Instruction Memory - ROM)<br/>Reads instruction from memory[0]"]
    E --> F["Instruction = 0x00010037<br/>(LUI x1, 0x10000)"]
    F --> G["M00_AXI_rdata = 0x00010037"]
    G --> H["SERV receives instruction"]
    
    style A fill:#e1f5ff
    style E fill:#fff4e1
    style H fill:#e8f5e9
```

---

## TEST CASE 2: ALU Master -> ALU Memory (Write Operation)

```mermaid
flowchart TD
    A["ALU MASTER<br/>PC = 0x0000_0000<br/>Start execution"] --> B["CPU_ALU_MASTER (AXI Master)<br/>M_AXI_araddr = 0x80000000<br/>M_AXI_arvalid = 1"]
    B --> C["AXI INTERCONNECT<br/>Address Decoder: 0x80000000 -> Slave2"]
    C --> D["SLAVE2 (ALU Memory - RAM)<br/>Reads instruction from memory[0]<br/>Instruction = 0x00404448<br/>(ADD, src1=0x40, src2=0x44, dst=0x48)"]
    D --> E["CPU_CONTROLLER: DECODE<br/>Opcode = 0x0 (ADD)<br/>src_addr1 = 0x40, src_addr2 = 0x44, dst_addr = 0x48"]
    E --> F["CPU_ALU_MASTER: Read Operand A<br/>M_AXI_araddr = 0x80000040"]
    F --> G["SLAVE2 -> M02_AXI_rdata = 0x00000003<br/>(a = 3)"]
    G --> H["CPU_ALU_MASTER: Read Operand B<br/>M_AXI_araddr = 0x80000044"]
    H --> I["SLAVE2 -> M02_AXI_rdata = 0x00000004<br/>(b = 4)"]
    I --> J["ALU_CORE: EXECUTE<br/>Input: a=3, b=4, opcode=ADD<br/>Result: 3 + 4 = 7<br/>alu_result = 0x00000007"]
    J --> K["CPU_ALU_MASTER: Write Result<br/>M_AXI_awaddr = 0x80000048<br/>M_AXI_wdata = 0x00000007"]
    K --> L["AXI INTERCONNECT<br/>Address Decoder: 0x80000048 -> Slave2"]
    L --> M["SLAVE2 (ALU Memory)<br/>Writes result to memory[18]<br/>Memory[0x80000048] = 0x00000007"]
    M --> N["TESTBENCH: Verify<br/>Memory[0x80000048] = 0x00000007 ✓<br/>alu_write_count = 1 ✓<br/>Test Case 2: PASS ✓"]
    
    style A fill:#e1f5ff
    style J fill:#fff4e1
    style M fill:#fff4e1
    style N fill:#e8f5e9
```

---

## TEST CASE 3: ALU Master -> ALU Memory (Read Operation)

```mermaid
flowchart TD
    A["ALU MASTER<br/>(từ Testcase 2)<br/>Đã thực hiện 3 read operations:<br/>1. Read Instruction @ 0x80000000<br/>2. Read Operand A @ 0x80000040<br/>3. Read Operand B @ 0x80000044"] --> B["AXI INTERCONNECT<br/>Address Decoder routes:<br/>- 0x80000000 -> Slave2<br/>- 0x80000040 -> Slave2<br/>- 0x80000044 -> Slave2"]
    B --> C["SLAVE2 (ALU Memory)<br/>Read transactions:<br/>- Read 1: Instruction = 0x00404448<br/>- Read 2: Operand A = 0x00000003<br/>- Read 3: Operand B = 0x00000004"]
    C --> D["MONITORING TASK<br/>alu_read_count = 3<br/>check_address_routing() verified"]
    D --> E["TESTBENCH: Verify<br/>alu_read_count >= 1 ✓<br/>Read channel hoạt động ✓<br/>Test Case 3: PASS ✓"]
    
    style A fill:#e1f5ff
    style C fill:#fff4e1
    style E fill:#e8f5e9
```

---

## TEST CASE 4: Address Routing Verification

```mermaid
flowchart TD
    A["TẤT CẢ TRANSACTIONS<br/>TỪ TESTCASE 1, 2, 3"] --> B["SERV -> 0x0000_0000 -> Slave0 ✓"]
    A --> C["ALU -> 0x80000000 -> Slave2 ✓"]
    A --> D["ALU -> 0x80000040 -> Slave2 ✓"]
    A --> E["ALU -> 0x80000044 -> Slave2 ✓"]
    A --> F["ALU -> 0x80000048 -> Slave2 ✓"]
    B --> G["ADDRESS DECODER<br/>(trong AXI Interconnect)<br/>Routing Rules:<br/>0x0000_0000 - 0x3FFF_FFFF -> Slave0 ✓<br/>0x4000_0000 - 0x7FFF_FFFF -> Slave1<br/>0x8000_0000 - 0xBFFF_FFFF -> Slave2 ✓<br/>0xC000_0000 - 0xFFFF_FFFF -> Slave3"]
    C --> G
    D --> G
    E --> G
    F --> G
    G --> H["MONITORING TASK<br/>(check_address_routing)<br/>Tất cả transactions đã được verify:<br/>- Address routing đúng<br/>- Decoder hoạt động đúng"]
    H --> I["TESTBENCH: Verify<br/>Address routing verified ✓<br/>Test Case 4: PASS ✓"]
    
    style A fill:#e1f5ff
    style G fill:#fff4e1
    style I fill:#e8f5e9
```

---

## TEST CASE 5: Concurrent Access - SERV(Inst) + ALU(ALU Mem)

```mermaid
flowchart TD
    A["TESTBENCH: Start Concurrent Operations<br/>serv_count_before = serv_inst_read_count<br/>alu_count_before = alu_read_count<br/>alu_master_start = 1"] --> B["PARALLEL EXECUTION<br/>(Đồng thời)"]
    B --> C["SERV RISC-V (Master 0)<br/>M00_AXI_araddr = 0x0000_0000<br/>M00_AXI_arvalid = 1"]
    B --> D["ALU Master (Master 1)<br/>M_AXI_araddr = 0x80000000<br/>M_AXI_arvalid = 1"]
    C --> E["AXI INTERCONNECT<br/>(Arbitration)<br/>Read Arbiter: Chọn master dựa trên QoS<br/>Address Decoder:<br/>- 0x0000_0000 -> Slave0 (SERV)<br/>- 0x80000000 -> Slave2 (ALU)"]
    D --> E
    E --> F["Slave0 -> SERV<br/>M00_AXI_rdata = Instruction<br/>serv_inst_read_count++"]
    E --> G["Slave2 -> ALU<br/>M02_AXI_rdata = Instruction<br/>alu_read_count++"]
    F --> H["CONTINUE PARALLEL OPERATIONS<br/>(100 cycles)<br/>SERV tiếp tục fetch instructions<br/>ALU tiếp tục đọc operands và ghi kết quả"]
    G --> H
    H --> I["TESTBENCH: Verify Concurrent Access<br/>serv_count_after > serv_count_before ✓<br/>alu_count_after > alu_count_before ✓<br/>Test Case 5: PASS ✓"]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style E fill:#fff4e1
    style I fill:#e8f5e9
```

---

## TEST CASE 6: System Stability Under Continuous Operation

```mermaid
flowchart TD
    A["TESTBENCH: Start Stability Test<br/>stability_ops = 0<br/>wait_alu_master_reset()"] --> B["REPEAT 3 TIMES<br/>(Operations liên tiếp)"]
    B --> C["Operation 1/3:<br/>alu_master_start = 1<br/>ALU Master: Fetch -> Decode -> Execute -> Store<br/>wait_alu_master_done_with_timeout(10000)<br/>wait_alu_master_reset() (Reset về IDLE)"]
    C --> D["Operation 2/3:<br/>alu_master_start = 1<br/>ALU Master: Fetch -> Decode -> Execute -> Store<br/>wait_alu_master_done_with_timeout(10000)<br/>wait_alu_master_reset() (Reset về IDLE)"]
    D --> E["Operation 3/3:<br/>alu_master_start = 1<br/>ALU Master: Fetch -> Decode -> Execute -> Store<br/>wait_alu_master_done_with_timeout(10000)<br/>wait_alu_master_reset() (Reset về IDLE)"]
    E --> F["TESTBENCH: Verify Stability<br/>stability_ops = 3<br/>Tất cả operations hoàn thành thành công<br/>Không có timeout hoặc error"]
    F --> G["TEST CASE 6: PASS<br/>✓ System stable sau 3 operations<br/>✓ Không có deadlock/timeout<br/>✓ ALU Master reset và start lại thành công"]
    
    style A fill:#e1f5ff
    style B fill:#fff4e1
    style G fill:#e8f5e9
```

---

## TEST CASE 7: Transaction Statistics

```mermaid
flowchart TD
    A["TESTBENCH: Collect Statistics<br/>Đọc tất cả transaction counters:<br/>- serv_inst_read_count<br/>- serv_data_read_count<br/>- serv_data_write_count<br/>- alu_read_count<br/>- alu_write_count<br/>- reserved_read_count"] --> B["CALCULATE TOTAL<br/>total_transactions =<br/>serv_inst_read_count + serv_data_read_count +<br/>serv_data_write_count + alu_read_count +<br/>alu_write_count + reserved_read_count"]
    B --> C["DISPLAY STATISTICS<br/>SERV Instruction Reads: X<br/>SERV Data Reads: Y<br/>SERV Data Writes: Z<br/>ALU Reads: A<br/>ALU Writes: B<br/>Reserved Reads: C<br/>TONG CONG: total_transactions"]
    C --> D["VERIFY<br/>Check: serv_inst_read_count > 0 OR<br/>alu_read_count > 0 OR<br/>alu_write_count > 0"]
    D --> E["TEST CASE 7: PASS<br/>✓ Đã quan sát được transactions<br/>✓ Hệ thống hoạt động với đủ transactions<br/>✓ Tổng cộng: total_transactions transactions"]
    
    style A fill:#e1f5ff
    style C fill:#fff4e1
    style E fill:#e8f5e9
```

---

## Cách Export Sang JPG

### Phương pháp 1: Sử dụng Mermaid Live Editor (Khuyến nghị)

1. Truy cập: https://mermaid.live/
2. Copy từng diagram (từ ````mermaid` đến ````) vào editor
3. Click "Actions" -> "Download PNG" hoặc "Download SVG"
4. Convert PNG sang JPG nếu cần (có thể dùng online converter)

### Phương pháp 2: Sử dụng Mermaid CLI

```bash
# Cài đặt Mermaid CLI
npm install -g @mermaid-js/mermaid-cli

# Export từng diagram
mmdc -i testcase1.mmd -o testcase1.jpg -b white
mmdc -i testcase2.mmd -o testcase2.jpg -b white
# ... và tiếp tục cho các testcase khác
```

### Phương pháp 3: Sử dụng VS Code Extension

1. Cài đặt extension "Markdown Preview Mermaid Support"
2. Mở file .md trong VS Code
3. Preview diagram
4. Right-click -> "Save Image As..." -> chọn JPG

### Phương pháp 4: Sử dụng GitHub/GitLab

1. Push file .md lên GitHub/GitLab
2. GitHub/GitLab tự động render Mermaid diagrams
3. Right-click trên diagram -> "Save image as..." -> JPG
