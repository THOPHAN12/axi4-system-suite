# AXI Interconnect Architecture Diagrams

Tài liệu này mô tả các sơ đồ kiến trúc của AXI4 Interconnect system.

## 📊 Sơ Đồ Tổng Quan

### 1. Block Diagram - Kiến Trúc Tổng Thể

**File:** `axi_interconnect_diagram.png`

Sơ đồ tổng quan về kiến trúc AXI4 Interconnect với:
- **2 Masters**: Master 0 (Compute) và Master 1 (Dependency)
- **Interconnect**: Bao gồm các IC Ports và 5 Channel Controllers
  - S0, S1 Ports (Slave Ports - kết nối với Masters)
  - 5 Channel Controllers: AW, AR, W, BR, R
  - M0, M1, M2, M3 Ports (Master Ports - kết nối với Slaves)
- **4 Slaves**: 
  - Slave 0: RAM (0x0000_0000)
  - Slave 1: GPIO (0x4000_0000)
  - Slave 2: UART (0x8000_0000)
  - Slave 3: SPI (0xC000_0000)

**Đặc điểm:**
- Tông màu trắng đen đơn giản
- Thể hiện rõ luồng dữ liệu: Masters → Interconnect → Slaves
- Hiển thị các IC Ports bên trong Interconnect

---

## 🔄 Sơ Đồ FSM (Finite State Machine)

### 2. Write Address (AW) Channel Controller FSM

**File:** `fsm_aw_controller.png`

**Các trạng thái:**
- 🟢 **WAIT_REQ**: Chờ request từ master
- 🔵 **ARBITRATE**: Thực hiện arbitration giữa các master
- 🟡 **DECODE**: Giải mã địa chỉ để chọn slave
- 🔴 **TRANSFER**: Truyền địa chỉ đến slave đã chọn
- ⚪ **WAIT_READY**: Chờ slave sẵn sàng (AWREADY)
- ⚫ **IDLE**: Trạng thái nghỉ

**Luồng chính:**
```
IDLE → WAIT_REQ → ARBITRATE → DECODE → TRANSFER → WAIT_READY → IDLE
```

**Luồng phụ:**
- Single master: `WAIT_REQ → DECODE` (bỏ qua arbitration)
- No pending: `TRANSFER → IDLE` (trực tiếp về IDLE)

---

### 3. Write Data (W) Channel Controller FSM

**File:** `fsm_w_controller.png`

**Các trạng thái:**
- 🟢 **WAIT_SELECT**: Chờ slave được chọn từ AW channel
- 🟡 **ROUTE_DATA**: Route dữ liệu đến slave đúng
- 🔴 **TRANSFER**: Truyền dữ liệu
- 🔵 **WAIT_LAST**: Chờ WLAST từ master
- ⚪ **DONE**: Hoàn thành write data
- ⚫ **IDLE**: Trạng thái nghỉ

**Luồng chính:**
```
IDLE → WAIT_SELECT → ROUTE_DATA → TRANSFER → WAIT_LAST → DONE → IDLE
```

**Luồng burst:**
- `TRANSFER → TRANSFER`: Nhiều data beats (WLAST=0)

---

### 4. Write Response (BR) Channel Controller FSM

**File:** `fsm_br_controller.png`

**Các trạng thái:**
- 🟢 **WAIT_RESP**: Chờ response từ slave
- 🔵 **ARBITRATE**: Arbitrate giữa nhiều responses
- 🟡 **ROUTE_RESP**: Match BID với master và route
- 🔴 **TRANSFER**: Truyền response đến master
- ⚪ **DONE**: Hoàn thành
- ⚫ **IDLE**: Trạng thái nghỉ

**Luồng chính:**
```
IDLE → WAIT_RESP → ARBITRATE → ROUTE_RESP → TRANSFER → DONE → IDLE
```

**Luồng lỗi:**
- `WAIT_RESP → IDLE`: Timeout hoặc error

---

### 5. Read Address (AR) Channel Controller FSM

**File:** `fsm_ar_controller.png`

**Các trạng thái:**
- 🟢 **WAIT_REQ**: Chờ read request
- 🔵 **ARBITRATE**: Arbitration giữa các master
- 🟡 **DECODE**: Decode địa chỉ để chọn slave
- 🔴 **TRANSFER**: Truyền địa chỉ read đến slave
- ⚪ **WAIT_READY**: Chờ ARREADY từ slave
- ⚫ **IDLE**: Trạng thái nghỉ

**Luồng chính:**
```
IDLE → WAIT_REQ → ARBITRATE → DECODE → TRANSFER → WAIT_READY → IDLE
```

**Luồng phụ:**
- Single master: `WAIT_REQ → DECODE`

---

### 6. Read Data (R) Channel Controller FSM

**File:** `fsm_r_controller.png`

**Kiến trúc:**
- **2 FSM độc lập**: Mỗi master (M0, M1) có FSM riêng để route read data
- **Parallel operation**: Cả 2 masters có thể đọc từ các slaves khác nhau đồng thời

**Các trạng thái (cho mỗi Master):**
- ⚫ **IDLE**: Trạng thái nghỉ, chờ AR handshake hoàn thành
- 🟢 **WAIT_AR_HANDSHAKE**: Chờ ARVALID/ARREADY handshake hoàn thành
- 🟡 **SLAVE0/1/2/3 (ROUTE)**: Route read data từ slave đã chọn về master
  - SLAVE0: Route từ Slave 0 (RAM)
  - SLAVE1: Route từ Slave 1 (GPIO)
  - SLAVE2: Route từ Slave 2 (UART)
  - SLAVE3: Route từ Slave 3 (SPI)

**Luồng chính (Master 0):**
```
IDLE → WAIT_AR_HANDSHAKE → [SLAVE0|SLAVE1|SLAVE2|SLAVE3] → IDLE
```

**Luồng burst:**
- `SLAVEx → SLAVEx`: Nhiều data beats (RLAST=0)
- `SLAVEx → IDLE`: Khi RLAST=1 (hoàn thành burst)

**Điều kiện chuyển trạng thái:**

1. **IDLE → WAIT_AR_HANDSHAKE:**
   - Khi có ARVALID từ master và ARREADY từ slave
   - Address decode xác định slave đích

2. **WAIT_AR_HANDSHAKE → SLAVEx:**
   - Dựa trên address decode:
     - `M_ADDR` trong range `slave0_addr1..slave0_addr2` → SLAVE0
     - `M_ADDR` trong range `slave1_addr1..slave1_addr2` → SLAVE1
     - `M_ADDR` trong range `slave2_addr1..slave2_addr2` → SLAVE2
     - `M_ADDR` trong range `slave3_addr1..slave3_addr2` → SLAVE3

3. **SLAVEx → SLAVEx (self-loop):**
   - Khi `Mx_RREADY && Sx_RVALID && !Sx_RLAST`
   - Burst transaction đang tiếp diễn

4. **SLAVEx → IDLE:**
   - Khi `Mx_RREADY && Sx_RVALID && Sx_RLAST`
   - Burst transaction hoàn thành

**Outputs:**
- `select_data_M0[1:0]`: Select line cho MUX routing data từ slave về Master 0
- `select_data_M1[1:0]`: Select line cho MUX routing data từ slave về Master 1
- `en_S0/S1/S2/S3[1:0]`: Enable signal để chọn master đích (00=M0, 01=M1)

**Đặc điểm:**
- **Fixed-Priority Arbitration**: Master 1 có priority khi cả 2 masters cùng active
- **Address-based routing**: Routing dựa trên address decode từ AR channel
- **Burst support**: Hỗ trợ burst transfers với RLAST signal
- **Independent operation**: Mỗi master có thể đọc từ slave khác nhau đồng thời

---

## 📝 Ghi Chú

### Màu sắc trạng thái:
- **Trắng (IDLE)**: Trạng thái nghỉ
- **Xanh lá (WAIT_*)**: Trạng thái chờ
- **Xanh dương (ARBITRATE)**: Thực hiện arbitration
- **Vàng (DECODE/ROUTE)**: Giải mã và routing
- **Đỏ (TRANSFER)**: Truyền dữ liệu
- **Xám (DONE/WAIT_READY)**: Hoàn thành hoặc chờ ready

### Cơ chế hoạt động:

1. **Arbitration**: 
   - Round-Robin algorithm
   - Priority cho master có QoS cao hơn
   - Tránh starvation

2. **Address Decoding**:
   - Dựa trên base address của slave
   - Mask để xác định địa chỉ thuộc slave nào

3. **Response Routing**:
   - Sử dụng BID/RID để match với master
   - Đảm bảo response về đúng master gửi request

---

## 🔧 Tạo Lại Sơ Đồ

Các sơ đồ được tạo bằng Python với matplotlib. Nếu cần chỉnh sửa hoặc tạo lại, chỉ cần tạo script Python tương tự với các thông số khác nhau.

**Dependencies:**
```bash
pip install matplotlib numpy
```

---

## 📂 Danh Sách Files

```
docs/architecture/
├── axi_interconnect_diagram.png    # Block diagram tổng quan
├── fsm_aw_controller.png           # FSM Write Address Channel
├── fsm_w_controller.png            # FSM Write Data Channel
├── fsm_br_controller.png           # FSM Write Response Channel
├── fsm_ar_controller.png           # FSM Read Address Channel
├── fsm_r_controller.png            # FSM Read Data Channel
├── generate_fsm_r_controller.py    # Script tạo FSM R channel
└── DIAGRAMS.md                     # Tài liệu này
```

---

**AXI4 System Suite - Comprehensive Verification Report**


