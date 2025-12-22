# Chương 3. TỔNG QUAN VỀ AXI INTERCONNECT

## 3.1. Giới thiệu về chuẩn AXI4

### 3.1.1. Khái niệm AXI4

**AXI4 (Advanced eXtensible Interface 4)** là một giao thức bus được phát triển bởi ARM, được sử dụng rộng rãi trong các hệ thống SoC (System-on-Chip) hiện đại. AXI4 là phiên bản cải tiến của AXI3, được thiết kế để cung cấp hiệu năng cao, độ linh hoạt và khả năng mở rộng cho các hệ thống nhúng.

### 3.1.2. Các phiên bản AXI4

AXI4 bao gồm ba biến thể chính:

1. **AXI4 Full**: Hỗ trợ đầy đủ các tính năng AXI, bao gồm:
   - Burst transactions (INCR, WRAP, FIXED)
   - Multiple outstanding transactions
   - Out-of-order completion
   - ID signals để phân biệt transactions

2. **AXI4-Lite**: Phiên bản đơn giản hóa:
   - Chỉ hỗ trợ single-beat transactions
   - Không có ID signals
   - Phù hợp cho các peripheral đơn giản (GPIO, UART, Timer)

3. **AXI4-Stream**: Giao thức streaming:
   - Không có địa chỉ
   - Phù hợp cho luồng dữ liệu liên tục (video, audio)

### 3.1.3. Cấu trúc AXI4 Channel

AXI4 sử dụng kiến trúc **5 channels độc lập** để tối ưu hóa hiệu năng:

```
┌─────────────────────────────────────────────────────────┐
│                    AXI4 MASTER                          │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │
│  │ Write Address│  │ Write Data   │  │ Write Response│ │
│  │   Channel    │  │   Channel    │  │   Channel     │ │
│  │   (AW)       │  │   (W)        │  │   (B)         │ │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘ │
│         │                  │                  │          │
│         │ AWVALID/AWREADY  │ WVALID/WREADY   │ BVALID/ │
│         │ AWADDR[31:0]     │ WDATA[31:0]     │ BREADY   │
│         │ AWLEN[7:0]       │ WSTRB[3:0]      │ BRESP[1:0]│
│         │ AWSIZE[2:0]      │ WLAST           │ BID[15:0] │
│         │ AWBURST[1:0]     │                 │          │
│         │ AWID[15:0]       │                 │          │
│         │                  │                 │          │
│  ┌──────┴──────────────────┴─────────────────┴──────┐  │
│  │              Read Address Channel (AR)            │  │
│  │              Read Data Channel (R)               │  │
│  │                                                   │  │
│  │  ARVALID/ARREADY  │  RVALID/RREADY               │  │
│  │  ARADDR[31:0]     │  RDATA[31:0]                 │  │
│  │  ARLEN[7:0]       │  RRESP[1:0]                  │  │
│  │  ARSIZE[2:0]      │  RLAST                       │  │
│  │  ARBURST[1:0]     │  RID[15:0]                   │  │
│  │  ARID[15:0]       │                              │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

**Đặc điểm của từng channel:**

- **Write Address (AW)**: Chứa thông tin địa chỉ, kích thước, burst type cho write transaction
- **Write Data (W)**: Chứa dữ liệu cần ghi, byte strobes, và WLAST signal
- **Write Response (B)**: Phản hồi từ slave về kết quả write transaction
- **Read Address (AR)**: Chứa thông tin địa chỉ, kích thước, burst type cho read transaction
- **Read Data (R)**: Chứa dữ liệu đọc được từ slave

### 3.1.4. Handshake Protocol

AXI4 sử dụng **handshake protocol** dựa trên VALID/READY signals:

```
Master                    Slave
  │                        │
  │  ┌─────────────────┐  │
  │  │ Assert VALID    │  │
  │  │ (data ready)    │  │
  │  └────────┬────────┘  │
  │           │            │
  │           ▼            │
  │  ┌─────────────────┐  │
  │  │ Wait for READY  │  │
  │  └────────┬────────┘  │
  │           │            │
  │           ▼            │
  │                    ┌───┴──────┐
  │                    │ Assert   │
  │                    │ READY    │
  │                    │ (ready   │
  │                    │ to accept)│
  │                    └───┬──────┘
  │                        │
  │                        ▼
  │  ┌─────────────────┐  │
  │  │ Transfer occurs │  │
  │  │ on rising edge  │  │
  │  │ of ACLK when    │  │
  │  │ both VALID &    │  │
  │  │ READY are HIGH  │  │
  │  └─────────────────┘  │
```

**Quy tắc handshake:**
- Master phải giữ VALID HIGH cho đến khi READY được assert
- Slave có thể assert READY trước khi VALID được assert
- Transfer xảy ra khi cả VALID và READY đều HIGH tại rising edge của ACLK

---

## 3.2. Khái niệm AXI Interconnect

### 3.2.1. Định nghĩa

**AXI Interconnect** là một thành phần quan trọng trong kiến trúc AXI4, đóng vai trò là **switch matrix** kết nối nhiều AXI masters với nhiều AXI slaves. Interconnect cho phép các masters truy cập vào các slaves thông qua một bus chung, đồng thời quản lý việc phân phối tài nguyên và đảm bảo tính nhất quán của dữ liệu.

### 3.2.2. Vai trò của AXI Interconnect

AXI Interconnect thực hiện các chức năng chính sau:

1. **Kết nối nhiều Masters với nhiều Slaves**: Cho phép nhiều masters truy cập vào cùng một hoặc nhiều slaves khác nhau

2. **Arbitration**: Quyết định master nào được phục vụ khi có nhiều masters cùng request

3. **Address Decoding**: Xác định slave đích dựa trên địa chỉ từ master

4. **Data Routing**: Định tuyến dữ liệu từ master đến slave đúng và ngược lại

5. **Protocol Conversion**: Chuyển đổi giữa các phiên bản AXI (Full, Lite, Stream)

### 3.2.3. Kiến trúc cơ bản

```
┌─────────────┐         ┌─────────────┐
│  Master 0   │         │  Master 1   │
│  (CPU)      │         │  (DMA)      │
└──────┬──────┘         └──────┬──────┘
       │                        │
       │  AXI4 Channels         │  AXI4 Channels
       │  (AW, W, B, AR, R)     │  (AW, W, B, AR, R)
       │                        │
       └──────────┬─────────────┘
                  │
                  ▼
        ┌─────────────────────┐
        │  AXI INTERCONNECT   │
        │   (2M × 4S)         │
        │                      │
        │  • Arbitration       │
        │  • Address Decode    │
        │  • Data Routing      │
        │  • Response Routing  │
        └──────┬───────────────┘
               │
       ┌───────┼───────┬───────┬───────┐
       │       │       │       │       │
       ▼       ▼       ▼       ▼       ▼
    ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐
    │RAM │ │GPIO│ │UART│ │SPI │ │... │
    └────┘ └────┘ └────┘ └────┘ └────┘
    Slave0 Slave1 Slave2 Slave3 Slave4
```

### 3.2.4. Lợi ích của AXI Interconnect

- **Tăng hiệu quả sử dụng bus**: Nhiều masters có thể chia sẻ cùng một bus
- **Giảm độ phức tạp**: Không cần kết nối trực tiếp từng master đến từng slave
- **Hỗ trợ mở rộng**: Dễ dàng thêm masters hoặc slaves mới
- **Tối ưu hiệu năng**: Hỗ trợ concurrent transactions và out-of-order completion

---

## 3.3. Kiến trúc tổng thể của AXI Interconnect

### 3.3.1. Cấu trúc tổng quan

AXI Interconnect trong dự án này được thiết kế với kiến trúc **2 Masters × 4 Slaves (2M × 4S)**, sử dụng **Channel Controllers** chuyên biệt cho từng AXI channel.

```
┌─────────────────────────────────────────────────────────────┐
│              AXI INTERCONNECT (2M × 4S)                     │
│                                                              │
│  ┌──────────────┐              ┌──────────────┐            │
│  │ IC S0 Port   │              │ IC S1 Port   │            │
│  │ (Master 0)   │              │ (Master 1)   │            │
│  │              │              │              │            │
│  │ AW  AR  W    │              │ AW  AR  W    │            │
│  │ BR  R        │              │ BR  R        │            │
│  └───┬───┬───┬──┘              └───┬───┬───┬──┘            │
│      │   │   │                     │   │   │                │
│      │   │   │                     │   │   │                │
│  ┌───▼───▼───▼─────────────────────▼───▼───▼───┐        │
│  │         AW_Channel_Controller                 │        │
│  │  • Arbitration (Round-Robin)                 │        │
│  │  • Address Decoder (S0-S3)                   │        │
│  └───────────────┬───────────────────────────────┘        │
│                  │                                         │
│  ┌───────────────▼───────────────────────────────┐        │
│  │         AR_Channel_Controller                 │        │
│  │  • Arbitration (Round-Robin)                  │        │
│  │  • Address Decoder (S0-S3)                    │        │
│  └───────────────┬───────────────────────────────┘        │
│                  │                                         │
│  ┌───────────────▼───────────────────────────────┐        │
│  │         WD_Channel_Controller                 │        │
│  │  • Data Demux (1→4)                          │        │
│  │  • Write Data Routing                        │        │
│  └───────────────┬───────────────────────────────┘        │
│                  │                                         │
│  ┌───────────────▼───────────────────────────────┐        │
│  │         Read Data Channel                     │        │
│  │  • Data Mux (4→1)                            │        │
│  │  • Read Data Routing                         │        │
│  └───────────────┬───────────────────────────────┘        │
│                  │                                         │
│  ┌───────────────▼───────────────────────────────┐        │
│  │         BR_Channel_Controller                 │        │
│  │  • Response Arbiter                          │        │
│  │  • Response Mux (4→1)                        │        │
│  │  • BID Matcher                               │        │
│  └───────────────┬───────────────────────────────┘        │
│                  │                                         │
│  ┌───────────────┼───────────┬───────────┬───────────┐  │
│  │ IC M0 Port    │ IC M1 Port│ IC M2 Port│ IC M3 Port│  │
│  │ (Slave 0)     │ (Slave 1) │ (Slave 2) │ (Slave 3) │  │
│  │               │           │           │           │  │
│  │ AW  AR  W     │ AW  AR  W │ AW  AR  W │ AW  AR  W │  │
│  │ BR  R         │ BR  R     │ BR  R     │ BR  R     │  │
│  └───────┬───────┴───────┬───┴───────┬───┴───────┬───┘  │
└──────────┼───────────────┼───────────┼───────────┼──────┘
           │               │           │           │
   ┌───────▼───────┐ ┌─────▼─────┐ ┌──▼─────┐ ┌───▼──────┐
   │   Slave 0:    │ │Slave 1:   │ │Slave 2:│ │Slave 3:  │
   │   RAM         │ │  GPIO     │ │  UART  │ │   SPI    │
   │               │ │           │ │        │ │          │
   │0x00000000     │ │0x40000000 │ │0x800000│ │0xC0000000│
   │- 0x1FFFFFFF   │ │-0x5FFFFF  │ │-0x9FFF │ │-0xDFFFFFF│
   └───────────────┘ └───────────┘ └────────┘ └──────────┘
```

### 3.3.2. Channel Controllers

Hệ thống sử dụng **4 Channel Controllers** chuyên biệt:

#### 1. AW_Channel_Controller_Top (Write Address Channel)

```
┌─────────────────────────────────────────┐
│   AW_Channel_Controller_Top             │
│                                         │
│  Input:                                 │
│  • S00_AXI_awvalid (M0 request)         │
│  • S01_AXI_awvalid (M1 request)        │
│  • S00_AXI_awaddr[31:0]                │
│  • S01_AXI_awaddr[31:0]                │
│                                         │
│  Process:                                │
│  ┌──────────────┐                       │
│  │ Arbitration  │───► Select Master     │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                       │
│  │Address Decode│───► Select Slave     │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  Output:                                │
│  • M00_AXI_awvalid (to Slave 0)        │
│  • M01_AXI_awvalid (to Slave 1)        │
│  • M02_AXI_awvalid (to Slave 2)        │
│  • M03_AXI_awvalid (to Slave 3)        │
│  • AW_Access_Grant (grant signal)       │
└─────────────────────────────────────────┘
```

**Chức năng:**
- Arbitration giữa Master 0 và Master 1
- Address decoding để xác định slave đích (S0, S1, S2, S3)
- Handshake protocol control (AWVALID/AWREADY)

#### 2. WD_Channel_Controller_Top (Write Data Channel)

```
┌─────────────────────────────────────────┐
│   WD_Channel_Controller_Top             │
│                                         │
│  Input:                                 │
│  • S00_AXI_wdata[31:0] (from M0)       │
│  • S01_AXI_wdata[31:0] (from M1)       │
│  • Selected Slave (from AW Controller) │
│                                         │
│  Process:                                │
│  ┌──────────────┐                       │
│  │ Data Demux   │───► Route to Slave   │
│  │   (1→4)      │                       │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  Output:                                │
│  • M00_AXI_wdata[31:0] (to Slave 0)    │
│  • M01_AXI_wdata[31:0] (to Slave 1)    │
│  • M02_AXI_wdata[31:0] (to Slave 2)    │
│  • M03_AXI_wdata[31:0] (to Slave 3)    │
└─────────────────────────────────────────┘
```

**Chức năng:**
- Routing write data từ master đã được grant đến slave đã chọn
- Demultiplexer 1→4 để route data đến đúng slave
- Write data handshake management (WVALID/WREADY/WLAST)

#### 3. BR_Channel_Controller_Top (Write Response Channel)

```
┌─────────────────────────────────────────┐
│   BR_Channel_Controller_Top             │
│                                         │
│  Input:                                 │
│  • M00_AXI_bvalid (from Slave 0)      │
│  • M01_AXI_bvalid (from Slave 1)       │
│  • M02_AXI_bvalid (from Slave 2)       │
│  • M03_AXI_bvalid (from Slave 3)       │
│  • BID[15:0] (from slaves)             │
│                                         │
│  Process:                                │
│  ┌──────────────┐                       │
│  │ Response     │───► Select Response  │
│  │ Arbiter      │                       │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                       │
│  │ BID Matcher  │───► Match to Master  │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                       │
│  │ Response Mux │───► Route to Master  │
│  │   (4→1)      │                       │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  Output:                                │
│  • S00_AXI_bvalid (to Master 0)        │
│  • S01_AXI_bvalid (to Master 1)        │
│  • S00_AXI_bresp[1:0]                  │
│  • S01_AXI_bresp[1:0]                  │
└─────────────────────────────────────────┘
```

**Chức năng:**
- Arbitration cho write responses từ 4 slaves
- Multiplexer 4→1 để route response về đúng master
- Response ID matching (BID) để đảm bảo response về đúng master

#### 4. AR_Channel_Controller_Top (Read Address Channel)

```
┌─────────────────────────────────────────┐
│   AR_Channel_Controller_Top             │
│                                         │
│  Input:                                 │
│  • S00_AXI_arvalid (M0 request)        │
│  • S01_AXI_arvalid (M1 request)        │
│  • S00_AXI_araddr[31:0]                │
│  • S01_AXI_araddr[31:0]                │
│                                         │
│  Process:                                │
│  ┌──────────────┐                       │
│  │ Arbitration  │───► Select Master   │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  ┌──────────────┐                       │
│  │Address Decode│───► Select Slave     │
│  └──────┬───────┘                       │
│         │                               │
│         ▼                               │
│  Output:                                │
│  • M00_AXI_arvalid (to Slave 0)        │
│  • M01_AXI_arvalid (to Slave 1)        │
│  • M02_AXI_arvalid (to Slave 2)        │
│  • M03_AXI_arvalid (to Slave 3)        │
└─────────────────────────────────────────┘
```

**Chức năng:**
- Arbitration giữa Master 0 và Master 1 cho read address
- Address decoding để xác định slave đích
- Handshake protocol control (ARVALID/ARREADY)

### 3.3.3. Luồng dữ liệu Write Transaction

```
Master 0                    AXI Interconnect                    Slave 1 (GPIO)
    │                              │                                 │
    │  ┌──────────────────────┐    │                                 │
    │  │ 1. AWVALID=1         │    │                                 │
    │  │    AWADDR=0x40000000│    │                                 │
    │  └──────────┬───────────┘    │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ AW Controller   │        │                                 │
    │    │ • Arbitrate     │        │                                 │
    │    │ • Decode: S1    │        │                                 │
    │    └────────┬────────┘        │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ M01_AXI_awvalid │────────┼───────────────────────────────►│
    │    │ M01_AXI_awaddr  │        │                                 │
    │    └─────────────────┘        │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │  ┌──────────────────────┐    │                                 │
    │  │ 2. WVALID=1          │    │                                 │
    │  │    WDATA=0xDEADBEEF  │    │                                 │
    │  │    WLAST=1           │    │                                 │
    │  └──────────┬───────────┘    │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ WD Controller    │        │                                 │
    │    │ • Route to S1    │        │                                 │
    │    └────────┬────────┘        │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ M01_AXI_wvalid  │────────┼───────────────────────────────►│
    │    │ M01_AXI_wdata   │        │                                 │
    │    └─────────────────┘        │                                 │
    │             │                 │                                 │
    │             │                 │                                 │
    │             │                 │  ┌──────────────────────┐      │
    │             │                 │  │ 3. BVALID=1         │      │
    │             │                 │  │    BRESP=OKAY       │      │
    │             │                 │  └──────────┬───────────┘      │
    │             │                 │             │                   │
    │             │                 │             ▼                   │
    │             │                 │    ┌─────────────────┐        │
    │             │                 │    │ BR Controller    │        │
    │             │                 │    │ • Match BID      │        │
    │             │                 │    │ • Route to M0     │        │
    │             │                 │    └────────┬────────┘        │
    │             │                 │             │                   │
    │             │                 │             ▼                   │
    │             │                 │    ┌─────────────────┐        │
    │             │◄────────────────┼────│ S00_AXI_bvalid  │        │
    │             │                 │    │ S00_AXI_bresp    │        │
    │             │                 │    └─────────────────┘        │
    │             │                 │                                 │
    │  ┌──────────▼───────────┐    │                                 │
    │  │ 4. BREADY=1          │    │                                 │
    │  │    Transaction Done │    │                                 │
    │  └──────────────────────┘    │                                 │
```

### 3.3.4. Luồng dữ liệu Read Transaction

```
Master 0                    AXI Interconnect                    Slave 0 (RAM)
    │                              │                                 │
    │  ┌──────────────────────┐    │                                 │
    │  │ 1. ARVALID=1         │    │                                 │
    │  │    ARADDR=0x00000000│    │                                 │
    │  └──────────┬───────────┘    │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ AR Controller   │        │                                 │
    │    │ • Arbitrate     │        │                                 │
    │    │ • Decode: S0    │        │                                 │
    │    └────────┬────────┘        │                                 │
    │             │                 │                                 │
    │             ▼                 │                                 │
    │    ┌─────────────────┐        │                                 │
    │    │ M00_AXI_arvalid  │────────┼───────────────────────────────►│
    │    │ M00_AXI_araddr   │        │                                 │
    │    └─────────────────┘        │                                 │
    │             │                 │                                 │
    │             │                 │                                 │
    │             │                 │  ┌──────────────────────┐      │
    │             │                 │  │ 2. RVALID=1          │      │
    │             │                 │  │    RDATA=0x12345678   │      │
    │             │                 │  │    RLAST=1           │      │
    │             │                 │  └──────────┬───────────┘      │
    │             │                 │             │                   │
    │             │                 │             ▼                   │
    │             │                 │    ┌─────────────────┐        │
    │             │                 │    │ Read Data Mux    │        │
    │             │                 │    │ • Route to M0     │        │
    │             │                 │    └────────┬────────┘        │
    │             │                 │             │                   │
    │             │                 │             ▼                   │
    │             │                 │    ┌─────────────────┐        │
    │             │◄────────────────┼────│ S00_AXI_rvalid   │        │
    │             │                 │    │ S00_AXI_rdata    │        │
    │             │                 │    │ S00_AXI_rlast    │        │
    │             │                 │    └─────────────────┘        │
    │             │                 │                                 │
    │  ┌──────────▼───────────┐    │                                 │
    │  │ 3. RREADY=1          │    │                                 │
    │  │    Data Received     │    │                                 │
    │  └──────────────────────┘    │                                 │
```

---

## 3.4. Cơ chế Arbitration trong AXI Interconnect

### 3.4.1. Khái niệm Arbitration

**Arbitration** là quá trình quyết định master nào được phục vụ khi có nhiều masters cùng yêu cầu truy cập vào cùng một slave hoặc tài nguyên bus. Arbitration đảm bảo rằng chỉ có một master được phục vụ tại một thời điểm, tránh xung đột và đảm bảo tính nhất quán của dữ liệu.

### 3.4.2. Các thuật toán Arbitration

Dự án này hỗ trợ **3 chế độ arbitration**:

#### 1. Fixed Priority (Ưu tiên cố định)

```
Priority: Master 0 > Master 1

┌─────────────────────────────────────┐
│         Arbitration Logic           │
│                                     │
│  if (M0_request && M1_request)      │
│      Grant = M0  (M0 always wins)   │
│  else if (M0_request)               │
│      Grant = M0                      │
│  else if (M1_request)               │
│      Grant = M1                      │
└─────────────────────────────────────┘

Example:
  Cycle 1: M0 request, M1 request → M0 wins
  Cycle 2: M0 request, M1 request → M0 wins
  Cycle 3: M0 request, M1 request → M0 wins
  → M1 may starve if M0 always requests
```

**Ưu điểm:**
- Đơn giản, dễ triển khai
- Latency thấp cho master ưu tiên
- Deterministic (dự đoán được)

**Nhược điểm:**
- Master có priority thấp có thể bị starvation
- Không công bằng

**Ứng dụng:** Real-time systems, master quan trọng cần đảm bảo latency

#### 2. Round-Robin (Luân phiên)

```
Turn-based: Masters take turns

State Machine:
  turn = 0 → M0's turn (M0 has priority)
  turn = 1 → M1's turn (M1 has priority)

┌─────────────────────────────────────┐
│         Arbitration Logic           │
│                                     │
│  if (M0_request && M1_request)      │
│      if (turn == 0)                 │
│          Grant = M0, turn = 1       │
│      else                            │
│          Grant = M1, turn = 0       │
│  else if (M0_request)               │
│      Grant = M0                      │
│  else if (M1_request)               │
│      Grant = M1                      │
└─────────────────────────────────────┘

Example:
  Cycle 1: M0 & M1 request, turn=0 → M0 wins, turn=1
  Cycle 2: M0 & M1 request, turn=1 → M1 wins, turn=0
  Cycle 3: M0 & M1 request, turn=0 → M0 wins, turn=1
  → Perfect alternation!
```

**Ưu điểm:**
- Công bằng giữa các masters
- Tránh starvation
- Phù hợp cho hầu hết ứng dụng

**Nhược điểm:**
- Có thể không tối ưu cho real-time systems
- Cần thêm logic để quản lý turn

**Ứng dụng:** General-purpose systems, đây là chế độ mặc định

#### 3. QoS-based (Dựa trên chất lượng dịch vụ)

```
Priority based on QoS value

QoS Register:
  M0_QoS = 3 (High priority)
  M1_QOS = 1 (Low priority)

┌─────────────────────────────────────┐
│         Arbitration Logic           │
│                                     │
│  if (M0_request && M1_request)     │
│      if (M0_QoS > M1_QoS)           │
│          Grant = M0                 │
│      else if (M1_QoS > M0_QoS)     │
│          Grant = M1                 │
│      else                            │
│          Grant = Round-Robin         │
└─────────────────────────────────────┘
```

**Ưu điểm:**
- Linh hoạt, có thể điều chỉnh priority động
- Kết hợp ưu điểm của Fixed Priority và Round-Robin

**Nhược điểm:**
- Phức tạp hơn
- Cần quản lý QoS values

**Ứng dụng:** Systems cần điều chỉnh priority động

### 3.4.3. Arbitration trong các Channel

Arbitration được thực hiện độc lập cho từng channel:

#### Write Address Channel (AW)

```
┌─────────────────────────────────────────┐
│   AW Channel Arbitration                 │
│                                         │
│  M0_AWVALID ──┐                         │
│               ├──► Arbiter ──► Grant   │
│  M1_AWVALID ──┘                         │
│                                         │
│  Selected Master ──► Address Decode    │
│                      ──► Select Slave   │
└─────────────────────────────────────────┘
```

#### Read Address Channel (AR)

```
┌─────────────────────────────────────────┐
│   AR Channel Arbitration                │
│                                         │
│  M0_ARVALID ──┐                         │
│               ├──► Arbiter ──► Grant   │
│  M1_ARVALID ──┘                         │
│                                         │
│  Selected Master ──► Address Decode    │
│                      ──► Select Slave   │
└─────────────────────────────────────────┘
```

#### Write Response Channel (BR)

```
┌─────────────────────────────────────────┐
│   BR Channel Arbitration                │
│                                         │
│  S0_BVALID ──┐                          │
│  S1_BVALID ──┤                          │
│  S2_BVALID ──├──► Response Arbiter      │
│  S3_BVALID ──┘                          │
│                                         │
│  Selected Response ──► BID Match       │
│                        ──► Route to M   │
└─────────────────────────────────────────┘
```

### 3.4.4. Ví dụ Arbitration

**Scenario:** Master 0 và Master 1 cùng request write đến Slave 0 (RAM)

```
Timeline với Round-Robin:

Cycle 1:
  M0: AWVALID=1, AWADDR=0x00000000 (S0)
  M1: AWVALID=1, AWADDR=0x00000000 (S0)
  Turn = 0
  ──► Arbiter: Grant M0 (turn=0)
  ──► M0_AWREADY=1, M1_AWREADY=0
  ──► M0 transaction proceeds

Cycle 2:
  M0: AWVALID=1, AWADDR=0x00000004 (S0)
  M1: AWVALID=1, AWADDR=0x00000008 (S0)
  Turn = 1 (updated from Cycle 1)
  ──► Arbiter: Grant M1 (turn=1)
  ──► M0_AWREADY=0, M1_AWREADY=1
  ──► M1 transaction proceeds

Cycle 3:
  M0: AWVALID=1, AWADDR=0x0000000C (S0)
  M1: AWVALID=1, AWADDR=0x00000010 (S0)
  Turn = 0 (updated from Cycle 2)
  ──► Arbiter: Grant M0 (turn=0)
  ──► M0_AWREADY=1, M1_AWREADY=0
  ──► M0 transaction proceeds

Result: Fair alternation between M0 and M1
```

---

## 3.5. Data Routing và Address Mapping

### 3.5.1. Address Mapping

**Address Mapping** là quá trình xác định slave đích dựa trên địa chỉ từ master. Mỗi slave được gán một vùng địa chỉ (address range) cụ thể.

#### Address Map trong dự án

```
┌─────────────────────────────────────────────────────────┐
│              Address Space (32-bit)                     │
│                                                          │
│  0x0000_0000 ──────────────────── 0x1FFF_FFFF            │
│  │                                                       │
│  │  Slave 0: RAM                                        │
│  │  Size: 512 MB                                        │
│  │                                                       │
│  0x4000_0000 ──────────────────── 0x5FFF_FFFF           │
│  │                                                       │
│  │  Slave 1: GPIO                                       │
│  │  Size: 512 MB (64 KB actual)                         │
│  │                                                       │
│  0x8000_0000 ──────────────────── 0x9FFF_FFFF           │
│  │                                                       │
│  │  Slave 2: UART                                       │
│  │  Size: 512 MB (64 KB actual)                         │
│  │                                                       │
│  0xC000_0000 ──────────────────── 0xDFFF_FFFF           │
│  │                                                       │
│  │  Slave 3: SPI                                        │
│  │  Size: 512 MB (64 KB actual)                         │
│  │                                                       │
└─────────────────────────────────────────────────────────┘
```

#### Address Decoding Logic

```
┌─────────────────────────────────────────┐
│   Address Decoder                        │
│                                         │
│  Input: AWADDR[31:0] or ARADDR[31:0]   │
│                                         │
│  if (ADDR >= 0x00000000 &&             │
│      ADDR <= 0x1FFFFFFF)               │
│      Selected_Slave = S0 (RAM)          │
│                                         │
│  else if (ADDR >= 0x40000000 &&         │
│           ADDR <= 0x5FFFFFFF)           │
│      Selected_Slave = S1 (GPIO)         │
│                                         │
│  else if (ADDR >= 0x80000000 &&         │
│           ADDR <= 0x9FFFFFFF)           │
│      Selected_Slave = S2 (UART)         │
│                                         │
│  else if (ADDR >= 0xC0000000 &&         │
│           ADDR <= 0xDFFFFFFF)           │
│      Selected_Slave = S3 (SPI)          │
│                                         │
│  else                                   │
│      Error: Address out of range        │
│                                         │
│  Output: select_slave[1:0]             │
└─────────────────────────────────────────┘
```

### 3.5.2. Data Routing

**Data Routing** là quá trình định tuyến dữ liệu từ master đến slave đúng và ngược lại.

#### Write Data Routing

```
Master 0 ──► AW Controller ──► Decode: S1 (GPIO)
    │
    │  Write Data
    ▼
WD Controller ──► Demux (1→4) ──► Route to S1
    │
    ▼
Slave 1 (GPIO) receives data
```

**Quá trình:**
1. AW Controller decode address → xác định S1
2. WD Controller nhận write data từ M0
3. Demux route data đến S1 dựa trên decode result
4. S1 nhận data và xử lý

#### Read Data Routing

```
Master 0 ──► AR Controller ──► Decode: S0 (RAM)
    │
    │  Read Request
    ▼
Slave 0 (RAM) ──► Read Data
    │
    │  Read Response
    ▼
Read Data Mux (4→1) ──► Route to M0
    │
    ▼
Master 0 receives data
```

**Quá trình:**
1. AR Controller decode address → xác định S0
2. S0 nhận read request và trả về data
3. Read Data Mux route data từ S0 về M0
4. M0 nhận data

### 3.5.3. Response Routing với ID Matching

AXI4 Full sử dụng **ID signals** để hỗ trợ out-of-order completion. Response routing phải match ID để đảm bảo response về đúng master.

```
┌─────────────────────────────────────────┐
│   Response Routing với ID Matching     │
│                                         │
│  Master 0 Request:                     │
│    AWID = 0x1234                       │
│    AWADDR = 0x40000000 (S1)           │
│                                         │
│  ──► AW Controller: Grant M0           │
│  ──► Address Decode: S1                │
│  ──► Store: M0_ID = 0x1234, Slave = S1│
│                                         │
│  Slave 1 Response:                     │
│    BID = 0x1234                        │
│    BRESP = OKAY                        │
│                                         │
│  ──► BR Controller:                    │
│      • Match BID (0x1234) with stored │
│      • Find: M0_ID = 0x1234            │
│      • Route response to M0            │
│                                         │
│  ──► M0 receives:                      │
│      • BVALID = 1                      │
│      • BRESP = OKAY                    │
│      • BID = 0x1234 (matched)          │
└─────────────────────────────────────────┘
```

### 3.5.4. Concurrent Transactions

AXI Interconnect hỗ trợ **concurrent transactions** khi các masters truy cập vào các slaves khác nhau:

```
Timeline:

Cycle 1:
  M0: Request to S0 (RAM) ──► Proceeds
  M1: Request to S1 (GPIO) ──► Proceeds
  ──► Both transactions proceed concurrently

Cycle 2:
  M0: Request to S2 (UART) ──► Proceeds
  M1: Request to S3 (SPI) ──► Proceeds
  ──► Both transactions proceed concurrently

Cycle 3:
  M0: Request to S0 (RAM) ──► Proceeds
  M1: Request to S0 (RAM) ──► Arbitration needed
  ──► Round-Robin: Grant M0 (turn=0)
```

**Lợi ích:**
- Tăng throughput
- Tận dụng bandwidth của bus
- Giảm latency khi không có conflict

---

## 3.6. AXI Interconnect trong hệ thống PS–PL

### 3.6.1. Kiến trúc PS–PL

Trong các hệ thống Zynq UltraScale+, **PS (Processing System)** là phần ARM processor và **PL (Programmable Logic)** là phần FPGA. AXI Interconnect kết nối PS với PL, cho phép ARM cores truy cập vào các peripherals và custom IPs trong PL.

```
┌─────────────────────────────────────────────────────────┐
│              Zynq UltraScale+ MPSoC                       │
│                                                           │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  PS (Processing System)                            │ │
│  │                                                     │ │
│  │  ┌──────────────┐  ┌──────────────┐               │ │
│  │  │ ARM Cortex   │  │ ARM Cortex   │               │ │
│  │  │ A53 Core 0   │  │ A53 Core 1   │               │ │
│  │  └──────┬───────┘  └──────┬───────┘               │ │
│  │         │                  │                        │ │
│  │         ▼                  ▼                        │ │
│  │  ┌──────────────────────────────────┐              │ │
│  │  │  AXI Master Ports                │              │ │
│  │  │  M_AXI_HPM0_FPD                  │              │ │
│  │  │  M_AXI_HPM1_FPD                  │              │ │
│  │  └──────┬──────────────────┬────────┘              │ │
│  │         │                  │                        │ │
│  │         │ pl_clk0          │                        │ │
│  │         │ pl_resetn0       │                        │ │
│  └─────────┼──────────────────┼────────────────────────┘ │
│            │                  │                          │
│            │  AXI4 GP         │  AXI4 GP                 │
│            │  (General        │  (General                │
│            │   Purpose)       │   Purpose)               │
│            │                  │                          │
└────────────┼──────────────────┼──────────────────────────┘
             │                  │
             │                  │
             ▼                  ▼
┌─────────────────┐  ┌─────────────────┐
│ AXI Master      │  │ AXI Master      │
│ Bridge 0        │  │ Bridge 1        │
│                 │  │                 │
│ AXI4 GP →      │  │ AXI4 GP →       │
│ AXI4 Full       │  │ AXI4 Full       │
└────────┬────────┘  └────────┬────────┘
         │                    │
         └──────────┬─────────┘
                    │
                    ▼
        ┌───────────────────────┐
        │  AXI INTERCONNECT     │
        │  (2M × 4S)            │
        │  Custom IP in PL      │
        │                       │
        │  • Arbitration        │
        │  • Address Decode     │
        │  • Data Routing       │
        └───────┬───────────────┘
                │
    ┌───────────┼───────────┬───────────┐
    │           │           │           │
    ▼           ▼           ▼           ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│ BRAM   │ │ GPIO   │ │ UART   │ │ SPI    │
│ Ctrl   │ │        │ │ Lite   │ │ Quad   │
└────────┘ └────────┘ └────────┘ └────────┘
  (S0)      (S1)       (S2)       (S3)
```

### 3.6.2. AXI Master Bridges

**AXI Master Bridges** là các IP custom được thiết kế để kết nối Zynq PS AXI masters (AXI4 GP) với Custom AXI Interconnect (AXI4 Full).

#### Chức năng của Master Bridge

```
┌─────────────────────────────────────────┐
│   AXI Master Bridge                    │
│                                         │
│  Input (from PS):                      │
│  • AXI4 GP (General Purpose)           │
│  • ID signals present                  │
│  • Optional signals (QoS, etc.)        │
│                                         │
│  Conversion:                            │
│  • Pass-through main signals           │
│  • Map ID signals                      │
│  • Drop optional signals if needed     │
│                                         │
│  Output (to Interconnect):              │
│  • AXI4 Full                           │
│  • Compatible with Interconnect        │
└─────────────────────────────────────────┘
```

**Lý do cần Bridge:**
- PS masters sử dụng AXI4 GP (có một số khác biệt với AXI4 Full)
- Custom Interconnect yêu cầu AXI4 Full
- Bridge đảm bảo protocol compatibility

### 3.6.3. AXI Slave Bridges

**AXI Slave Bridges** là các IP custom được thiết kế để kết nối AXI Interconnect (AXI4 Full) với AXI4-Lite Peripherals.

#### Chức năng của Slave Bridge

```
┌─────────────────────────────────────────┐
│   AXI Slave Bridge                      │
│                                         │
│  Input (from Interconnect):             │
│  • AXI4 Full                           │
│  • May have burst transactions          │
│                                         │
│  Conversion:                            │
│  • Convert to AXI4-Lite                │
│  • Reject burst transactions            │
│  • Enforce single-beat only            │
│  • Remove ID signals                   │
│                                         │
│  Output (to Peripheral):                │
│  • AXI4-Lite                           │
│  • Single-beat transactions only       │
└─────────────────────────────────────────┘
```

**Lý do cần Bridge:**
- Peripherals (GPIO, UART, SPI) chỉ hỗ trợ AXI4-Lite
- Interconnect hỗ trợ AXI4 Full với burst
- Bridge đảm bảo protocol compatibility và reject bursts

### 3.6.4. Clock và Reset Domain

```
┌─────────────────────────────────────────┐
│   Clock Domain                          │
│                                         │
│  PS:                                    │
│    pl_clk0 (100 MHz) ──►                │
│                                         │
│    ──► Master Bridge 0 (ACLK)          │
│    ──► Master Bridge 1 (ACLK)          │
│    ──► AXI Interconnect (ACLK)         │
│    ──► Slave Bridge S1 (ACLK)          │
│    ──► Slave Bridge S2 (ACLK)          │
│    ──► Slave Bridge S3 (ACLK)          │
│    ──► Peripherals (ACLK)               │
│                                         │
│  Reset Domain:                          │
│    pl_resetn0 (active low) ──►          │
│                                         │
│    ──► Reset Controller                │
│        └─► peripheral_aresetn          │
│            └─► All components          │
└─────────────────────────────────────────┘
```

**Đặc điểm:**
- Tất cả components trong cùng một clock domain (100 MHz)
- Synchronous reset (ARESETN active low)
- Reset được phân phối qua Reset Controller

### 3.6.5. Address Map trong hệ thống PS–PL

```
┌─────────────────────────────────────────────────────────┐
│              Address Map (PS View)                      │
│                                                          │
│  PS Address Space:                                      │
│                                                          │
│  0x0000_0000 ──────────────────── 0x1FFF_FFFF            │
│  │                                                       │
│  │  PL: Slave 0 - BRAM Controller                       │
│  │  (Mapped to PL through Interconnect)                 │
│  │                                                       │
│  0x4000_0000 ──────────────────── 0x5FFF_FFFF           │
│  │                                                       │
│  │  PL: Slave 1 - GPIO                                  │
│  │  (Mapped to PL through Interconnect)                 │
│  │                                                       │
│  0x8000_0000 ──────────────────── 0x9FFF_FFFF           │
│  │                                                       │
│  │  PL: Slave 2 - UART Lite                             │
│  │  (Mapped to PL through Interconnect)                 │
│  │                                                       │
│  0xC000_0000 ──────────────────── 0xDFFF_FFFF           │
│  │                                                       │
│  │  PL: Slave 3 - Quad SPI                              │
│  │  (Mapped to PL through Interconnect)                 │
│  │                                                       │
└─────────────────────────────────────────────────────────┘
```

**Lưu ý:**
- PS cores truy cập PL peripherals như thể chúng là memory-mapped devices
- Address mapping được cấu hình trong Block Design
- Interconnect thực hiện address decoding và routing

### 3.6.6. Luồng giao dịch từ PS đến PL

```
ARM Core (PS)                    AXI Interconnect (PL)              Peripheral (PL)
    │                                    │                                 │
    │  1. Write Request                  │                                 │
    │     AWADDR = 0x40000000           │                                 │
    │     WDATA = 0xDEADBEEF            │                                 │
    │                                    │                                 │
    │  ──► M_AXI_HPM0_FPD                │                                 │
    │      (AXI4 GP)                    │                                 │
    │                                    │                                 │
    │                                    │  ──► Master Bridge 0            │
    │                                    │      (GP → Full)                │
    │                                    │                                 │
    │                                    │  ──► AW Controller              │
    │                                    │      • Arbitrate                │
    │                                    │      • Decode: S1 (GPIO)        │
    │                                    │                                 │
    │                                    │  ──► WD Controller             │
    │                                    │      • Route to S1              │
    │                                    │                                 │
    │                                    │  ──► Slave Bridge S1            │
    │                                    │      (Full → Lite)              │
    │                                    │                                 │
    │                                    │  ──► GPIO Peripheral           │
    │                                    │      • Write register           │
    │                                    │                                 │
    │                                    │  ──► BR Controller              │
    │                                    │      • Route response           │
    │                                    │                                 │
    │  2. Write Response                │                                 │
    │     BRESP = OKAY                   │                                 │
    │  ◄─── M_AXI_HPM0_FPD               │                                 │
    │                                    │                                 │
```

### 3.6.7. Lợi ích của kiến trúc PS–PL với AXI Interconnect

1. **Tích hợp linh hoạt**: ARM cores có thể truy cập vào custom IPs trong PL
2. **Hiệu năng cao**: AXI4 cung cấp bandwidth cao và low latency
3. **Dễ mở rộng**: Có thể thêm masters hoặc slaves mới dễ dàng
4. **Tái sử dụng**: Custom Interconnect có thể được sử dụng trong nhiều dự án
5. **Standard interface**: Sử dụng chuẩn AXI4 được hỗ trợ rộng rãi

---

## Tóm tắt Chương 3

Chương 3 đã trình bày tổng quan về AXI Interconnect, bao gồm:

1. **Chuẩn AXI4**: Các phiên bản AXI4, cấu trúc 5 channels, và handshake protocol
2. **Khái niệm AXI Interconnect**: Vai trò, kiến trúc cơ bản, và lợi ích
3. **Kiến trúc tổng thể**: Channel Controllers, luồng dữ liệu write/read
4. **Cơ chế Arbitration**: Fixed Priority, Round-Robin, QoS-based
5. **Data Routing và Address Mapping**: Address decoding, data routing, response routing với ID matching
6. **AXI Interconnect trong PS–PL**: Kiến trúc PS–PL, Master/Slave Bridges, clock/reset domain, và luồng giao dịch

AXI Interconnect là thành phần quan trọng kết nối các masters và slaves trong hệ thống, đảm bảo hiệu năng cao, tính linh hoạt và khả năng mở rộng.

