# Fix Address Decoding Conflict

## 1. Van de

**Address decoding conflict:**
- `Read_Addr_Channel_Dec` su dung bits [31:30] de decode:
  - `00` -> Slave 0 (M00)
  - `01` -> Slave 1 (M01)
  - `10` -> Slave 2 (M02)
  - `11` -> Slave 3 (M03)

- Address ranges cu:
  - Slave 0: `0x0000_0000` to `0x0000_FFFF` (bits [31:30] = `00`) ✅ Match!
  - Slave 1: `0x1000_0000` to `0x1FFF_FFFF` (bits [31:30] = `00`) ❌ **CONFLICT!**

**Ket qua:** Address `0x1000_0000` (data memory) se bi route den **Slave 0** thay vi **Slave 1**!

## 2. Fix da thuc hien

### 2.1. Thay doi address ranges trong serv_axi_system.v

**Address ranges moi:**
- Slave 0: `0x0000_0000` to `0x3FFF_FFFF` (bits [31:30] = `00`) - Instruction memory
- Slave 1: `0x4000_0000` to `0x7FFF_FFFF` (bits [31:30] = `01`) - Data memory

**Code:**
```verilog
parameter SLAVE0_ADDR1 = 32'h0000_0000,  // Instruction memory start (bits [31:30] = 00)
parameter SLAVE0_ADDR2 = 32'h3FFF_FFFF,  // Instruction memory end (bits [31:30] = 00)
parameter SLAVE1_ADDR1 = 32'h4000_0000,  // Data memory start (bits [31:30] = 01)
parameter SLAVE1_ADDR2 = 32'h7FFF_FFFF   // Data memory end (bits [31:30] = 01)
```

### 2.2. Update testbench

**serv_axi_system_tb.v:**
```verilog
.SLAVE0_ADDR1       (32'h0000_0000),  // Instruction memory start (bits [31:30] = 00)
.SLAVE0_ADDR2       (32'h3FFF_FFFF),  // Instruction memory end (bits [31:30] = 00)
.SLAVE1_ADDR1       (32'h4000_0000),  // Data memory start (bits [31:30] = 01)
.SLAVE1_ADDR2       (32'h7FFF_FFFF)   // Data memory end (bits [31:30] = 01)
```

## 3. Memory address mapping

### 3.1. Instruction Memory (M00 - ROM)
- **Address range**: `0x0000_0000` to `0x3FFF_FFFF`
- **Memory size**: 1024 words (32-bit words) = 4KB
- **Address calculation**: Memory index = `(araddr[ADDR_BITS+1:2]) % MEM_SIZE`
- **Note**: Memory slaves se tu dong mask address de lay offset trong memory

### 3.2. Data Memory (M01 - RAM)
- **Address range**: `0x4000_0000` to `0x7FFF_FFFF`
- **Memory size**: 1024 words (32-bit words) = 4KB
- **Address calculation**: Memory index = `(araddr[ADDR_BITS+1:2]) % MEM_SIZE`
- **Note**: Memory slaves se tu dong mask address de lay offset trong memory

## 4. Impact

### 4.1. Memory slaves
- Memory slaves (`axi_rom_slave.v`, `axi_memory_slave.v`) su dung address offset
- Chúng se tu dong mask address de lay offset: `rd_addr_current[ADDR_BITS+1:2]`
- **Khong can thay doi** memory slaves - chúng se hoat dong dung voi address ranges moi

### 4.2. SERV processor
- SERV se gui addresses trong ranges moi:
  - Instruction fetches: `0x0000_0000` to `0x3FFF_FFFF`
  - Data accesses: `0x4000_0000` to `0x7FFF_FFFF`
- **Can update** test programs neu co hardcoded addresses

## 5. Verification

### 5.1. Address routing
- Address `0x0000_0000` -> Slave 0 (M00) ✅
- Address `0x0000_0004` -> Slave 0 (M00) ✅
- Address `0x4000_0000` -> Slave 1 (M01) ✅
- Address `0x4000_0004` -> Slave 1 (M01) ✅

### 5.2. Memory access
- Instruction memory: Addresses trong range `0x0000_0000` to `0x3FFF_FFFF`
- Data memory: Addresses trong range `0x4000_0000` to `0x7FFF_FFFF`

## 6. Notes

- Address ranges da duoc fix de match voi MSB bits [31:30]
- Memory slaves khong can thay doi - chúng tu dong mask address
- Testbench da duoc update
- Can test de verify address routing dung

