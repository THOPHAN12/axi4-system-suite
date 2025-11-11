# Kiem tra AXI Interconnect

## 1. Cau truc Interconnect

### 1.1. Top Level: AXI_Interconnect_Full.v
- **Masters**: 2 (S00, S01) - SERV instruction bus, SERV data bus
- **Slaves**: 4 (M00, M01, M02, M03)
  - M00: Instruction Memory (ROM)
  - M01: Data Memory (RAM)
  - M02: Read-only (optional)
  - M03: Read-only (optional)

### 1.2. Cac module chinh
1. **Read_Arbiter**: Chon master (QoS-based)
2. **Read_Addr_Channel_Dec**: Decode address -> chon slave
3. **AR_Channel_Controller_Top**: Control AR channel
4. **Controller**: Control R channel (read data routing)

## 2. Phan tich logic

### 2.1. Address Muxing
```verilog
wire [Address_width-1:0] M_ADDR_muxed;
Mux_2x1 #(.width(Address_width-1)) mux_m_addr (
    .in1        (S00_AXI_araddr),
    .in2        (S01_AXI_araddr),
    .sel        (AR_Selected_Slave),  // ⚠️ TEN SAI: nen la AR_Selected_Master
    .out        (M_ADDR_muxed)
);
```

**Van de:**
- `AR_Selected_Slave` la ten sai - no chon master, khong phai slave
- Nhung logic dung: chon address tu master da duoc arbiter chon

### 2.2. Address Decoding

**Co 2 cach decode address:**

#### Cach 1: Read_Addr_Channel_Dec
- Su dung 2 MSB cua address: `Base_Addr_Master = ARADDR[31:30]`
- Decode nhanh, don gian
- **Van de**: Chi phu hop voi address space co dinh (0x00000000, 0x40000000, 0x80000000, 0xC0000000)

#### Cach 2: Controller
- Su dung address range: `slave0_addr1 <= addr <= slave0_addr2`
- Linh hoat hon, co the config
- **Van de**: Can set address ranges tu ben ngoai

**Ket luan**: Hai cach nay co the conflict neu khong config dung!

### 2.3. Read Data Channel Routing

**Controller.v** su dung `M_ADDR` de route read data:
```verilog
if(M_ADDR >= slave0_addr1 && M_ADDR <= slave0_addr2) begin
    select_data_M0 = 2'b00;  // Route to Slave 0
end
```

**Van de:**
- `M_ADDR` duoc update khi address handshake xong
- Nhung neu co nhieu transactions, `M_ADDR` co the bi thay doi
- Can ensure `M_ADDR` duoc latched cho moi transaction

## 3. Van de phat hien

### 3.1. ⚠️ TEN BIEN SAI
- `AR_Selected_Slave` nen la `AR_Selected_Master` (chon master, khong phai slave)
- Khong anh huong logic, nhung de gay nham lan

### 3.2. ⚠️ ADDRESS DECODING CONFLICT
- `Read_Addr_Channel_Dec` su dung MSB bits [31:30]
- `Controller` su dung address ranges
- Neu khong config dung, co the route sai

### 3.3. ⚠️ M_ADDR TIMING
- `M_ADDR` duoc mux tu master address
- Nhung neu master thay doi, `M_ADDR` se thay doi
- Can ensure `M_ADDR` duoc latched cho moi transaction

### 3.4. ✅ ADDRESS MUXING
- Logic dung: Mux chon address tu master active
- `AR_Selected_Slave` (ten sai nhung logic dung) chon master

### 3.5. ✅ READ DATA ROUTING
- Controller route read data dung slave based on `M_ADDR`
- Logic dung, nhung can ensure `M_ADDR` on dinh

## 4. Kiem tra port connections

### 4.1. Controller ports
```verilog
.M_ADDR                        (M_ADDR_muxed),  // ✅ Dung: Muxed address
.S0_ARREADY                    (M00_AXI_arready),  // ✅ Dung
.S1_ARREADY                    (M01_AXI_arready),  // ✅ Dung
.S2_ARREADY                    (M02_AXI_arready),  // ✅ Dung
.S3_ARREADY                    (M03_AXI_arready),  // ✅ Dung
.M0_ARVALID                    (S00_AXI_arvalid),  // ✅ Dung
.M1_ARVALID                    (S01_AXI_arvalid),  // ✅ Dung
```

**Ket luan**: Port connections dung!

## 5. Recommendations

### 5.1. Fix ten bien
- Doi ten `AR_Selected_Slave` thanh `AR_Selected_Master` de ro rang hon

### 5.2. Address decoding
- Chon 1 trong 2 cach:
  - **Option 1**: Su dung `Read_Addr_Channel_Dec` (MSB bits) - nhanh, don gian
  - **Option 2**: Su dung `Controller` (address ranges) - linh hoat hon
- Neu su dung ca 2, can ensure chung consistent

### 5.3. M_ADDR latching
- Can latch `M_ADDR` khi address handshake xong
- Ensure `M_ADDR` khong thay doi trong suot transaction

## 6. Van de nghiem trong phat hien

### 6.1. ❌ ADDRESS DECODING CONFLICT

**Van de:**
- `Read_Addr_Channel_Dec` su dung bits [31:30] de decode:
  - `00` -> Slave 0 (M00)
  - `01` -> Slave 1 (M01)
  - `10` -> Slave 2 (M02)
  - `11` -> Slave 3 (M03)

- Address ranges trong `serv_axi_system.v`:
  - Slave 0: `0x0000_0000` to `0x0000_FFFF` (bits [31:30] = `00`) ✅ Match!
  - Slave 1: `0x1000_0000` to `0x1FFF_FFFF` (bits [31:30] = `00`) ❌ **CONFLICT!**

**Ket qua:**
- Address `0x1000_0000` (data memory) se bi route den **Slave 0** thay vi **Slave 1**!
- Day la loi nghiem trong!

**Giai phap:**
1. **Option 1**: Thay doi address ranges de match voi MSB bits:
   - Slave 0: `0x0000_0000` to `0x3FFF_FFFF` (bits [31:30] = `00`)
   - Slave 1: `0x4000_0000` to `0x7FFF_FFFF` (bits [31:30] = `01`)
   - Slave 2: `0x8000_0000` to `0xBFFF_FFFF` (bits [31:30] = `10`)
   - Slave 3: `0xC000_0000` to `0xFFFF_FFFF` (bits [31:30] = `11`)

2. **Option 2**: Thay doi `Read_Addr_Channel_Dec` de su dung address ranges thay vi MSB bits

3. **Option 3**: Disable `Read_Addr_Channel_Dec` va chi su dung `Controller` cho address decoding

## 7. Ket luan

### 7.1. Logic chinh
- ✅ Address muxing: Dung
- ✅ Read data routing: Dung (nhung conflict voi address decoding)
- ✅ Port connections: Dung
- ❌ **Address decoding: CONFLICT NGHIEM TRONG!**
- ⚠️ M_ADDR timing: Can ensure on dinh

### 7.2. Van de
- ❌ **Address decoding conflict**: Address `0x1000_0000` se bi route sai
- ⚠️ Ten bien sai (`AR_Selected_Slave` -> `AR_Selected_Master`)
- ⚠️ Address decoding co 2 cach (conflict voi nhau)

### 7.3. Overall
- **Interconnect co loi nghiem trong**: Address decoding conflict
- **CAN FIX NGAY**: Thay doi address ranges hoac address decoding logic
- Sau khi fix, can test de verify address routing dung

