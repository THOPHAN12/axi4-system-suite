## AXI_Interconnect_General – Thiết Kế Phiên Bản Tổng Quát Hóa

Tài liệu này ghi lại chi tiết **Phase 1 → Phase 7** cho việc tạo `AXI_Interconnect_General.sv` theo đúng kế hoạch bạn đưa ra, và mô tả rõ **hiện trạng V1** (wrapper general, core vẫn giới hạn 2M×4S).

---

### Phase 1 – Phân tích và thiết kế

#### 1.1. Ràng buộc SystemVerilog

- **Không có port array động theo index** kiểu `input logic [ADDR_WIDTH-1:0] M[i]_AWADDR;`  
  → Tên port phải là identifier tĩnh: `M0_AWADDR`, `M1_AWADDR`, ...
- **generate** chỉ hoạt động cho logic nội bộ, không tạo được tên port động.
- Có thể dùng:
  - **packed arrays** bên trong module: `logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0] m_awaddr;`
  - **interface / struct** để gom nhóm các tín hiệu một channel.

Kết luận Phase 1.1:
- Top-level wrapper nên dùng **individual ports** cho dễ kết nối (M0, M1, S0..S3).
- Bên trong wrapper dùng **packed arrays + generate** để thao tác “theo i”.

#### 1.2. Parameters cần thiết

Trong `AXI_Interconnect_General.sv`:

```systemverilog
parameter int unsigned NUM_MASTERS       = 2;   // số lượng masters
parameter int unsigned NUM_SLAVES        = 4;   // số lượng slaves
parameter int unsigned ADDR_WIDTH        = 32;  // độ rộng địa chỉ
parameter int unsigned DATA_WIDTH        = 32;  // độ rộng dữ liệu
parameter int unsigned ARBITRATION_MODE  = 1;   // 0=FIXED, 1=ROUND_ROBIN, 2=QOS
```

Ghi chú:
- V1 vẫn **bị giới hạn bởi core hiện tại**: `AXI_Interconnect_Full` chỉ có 2 master input (S00, S01) và 4 slave output (M00..M03).  
- Vì vậy:
  - **NUM_MASTERS** V1: meaningful trong khoảng `1..2`.  
  - **NUM_SLAVES** V1: meaningful trong khoảng `1..4`.

#### 1.3. Address ranges cho slaves

Hiện tại, bản wrapper cố định `slave0_addr1..2`, `slave1_addr1..2` trong `AXI_Interconnect.sv`.  
Trong V1 của `AXI_Interconnect_General`:
- Chưa refactor core nên **chưa chuyển sang parameter array hoàn chỉnh**.  
- Trong tương lai có 2 hướng:
  1. **Parameter array**:
     ```systemverilog
     parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] SLAVE_BASE = '{default:32'h0000_0000};
     parameter logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0] SLAVE_LIMIT = '{default:32'h0000_FFFF};
     ```
  2. **Formula**:
     - `slave_i_base  = i * ADDR_RANGE_SIZE`
     - `slave_i_limit = slave_i_base + ADDR_RANGE_SIZE - 1`

Hiện trạng V1:
- Chưa can thiệp vào core decode, wrapper mới chỉ chuẩn hóa IO và internal arrays.  
- Khi refactor core, sẽ map `SLAVE_BASE/LIMIT` vào các decoder `*_Channel_Dec.sv`.

---

### Phase 2 – Cấu trúc file mới

#### 2.1. AXI Interface Package (tùy chọn, đã tạo)

**File:** `SystemVerilog/axi_interconnect/utils/AXI_Interface.sv`

Mục tiêu:
- Định nghĩa các **struct** gói group tín hiệu từng channel:
  - `AXI_Write_Addr_Channel_t`
  - `AXI_Write_Data_Channel_t`
  - `AXI_Write_Resp_Channel_t`
  - `AXI_Read_Addr_Channel_t`
  - `AXI_Read_Data_Channel_t`

Ví dụ (rút gọn):

```systemverilog
package AXI_Interface;
  typedef struct packed {
    logic [31:0] awaddr;
    logic [7:0]  awlen;
    logic [2:0]  awsize;
    logic [1:0]  awburst;
    logic        awvalid;
    logic        awready;
    // ...
  } AXI_Write_Addr_Channel_t;
  // ... các channel khác
endpackage
```

Hiện tại:
- V1 của `AXI_Interconnect_General` **chưa dùng trực tiếp** các struct này để tránh thay đổi lớn.
- Tuy nhiên, package đã sẵn sàng cho các refactor tương lai (ví dụ: dùng trong channel controllers).

#### 2.2. Tạo AXI_Interconnect_General.sv (đã tạo)

**File:** `SystemVerilog/axi_interconnect/core/AXI_Interconnect_General.sv`

Cấu trúc:
1. `module AXI_Interconnect_General #(parameters ...) (ports ...);`
2. Individual ports cho:
   - **2 masters**: `M0_*`, `M1_*`
   - **4 slaves**: `S0_*`..`S3_*`
3. Internal packed arrays `m_*` và `s_*`
4. Mapping giữa ports ↔ arrays
5. Placeholder cho core logic / hook tới `AXI_Interconnect_Full`.

---

### Phase 3 – Implementation chi tiết (Port Declaration Strategy)

#### 3.1. Port Declaration Strategy – Hybrid

Theo plan:
- **Option A:** generate với individual ports (khó vì không tạo được tên port động).  
- **Option B:** packed arrays ở cổng (gọn nhưng kém thân thiện khi tích hợp).

Trong V1, chọn **Hybrid**:

- **Top-level ports:** giữ kiểu **individual**:
  - Masters:
    - `M0_AWADDR`, `M0_WDATA`, `M0_ARADDR`, ...
    - `M1_AWADDR`, `M1_WDATA`, ...
  - Slaves:
    - `S0_AWADDR`, `S0_WDATA`, `S0_ARADDR`, ...
    - `S1_*`, `S2_*`, `S3_*`

- **Bên trong module:**
  - Khai báo packed arrays:
    ```systemverilog
    logic [NUM_MASTERS-1:0][ADDR_WIDTH-1:0]  m_awaddr;
    logic [NUM_SLAVES-1:0][ADDR_WIDTH-1:0]   s_awaddr;
    // ... tương tự cho len/size/burst/data/resp/...
    ```

Lý do:
- Phù hợp với **SystemVerilog constraints**.
- Dễ dàng mapping sang core hiện tại (vì vẫn giữ 2M×4S).
- Mở đường cho refactor sau này (logic “theo i” sẽ làm việc trên arrays).

#### 3.2. Generate Blocks Structure

Do không thể viết `M[i]_AWADDR`, giải pháp:
- **Mapping thủ công** cho số lượng index nhỏ (0..1 cho masters, 0..3 cho slaves).
- Dùng `generate if` để **tie-off** khi `NUM_MASTERS` hoặc `NUM_SLAVES` nhỏ hơn max.

Ví dụ cho Master 1:

```systemverilog
generate
  if (NUM_MASTERS > 1) begin : gen_m1_map
    always_comb begin
      m_awaddr[1] = M1_AWADDR;
      // ...
      M1_AWREADY  = m_awready[1];
      // ...
    end
  end else begin : gen_m1_tied_off
    always_comb begin
      M1_AWREADY = 1'b0;
      M1_WREADY  = 1'b0;
      M1_BRESP   = '0;
      M1_BVALID  = 1'b0;
      M1_ARREADY = 1'b0;
      M1_RDATA   = '0;
      M1_RRESP   = '0;
      M1_RLAST   = 1'b0;
      M1_RVALID  = 1'b0;
    end
  end
endgenerate
```

Tương tự, Slaves 0..3 được map thủ công vào `s_*` arrays:

```systemverilog
always_comb begin
  s_awaddr[0] = S0_AWADDR;
  // ...
  S0_AWREADY  = s_awready[0];
  // ...
end
```

---

### Phase 4 – Chiến lược thực hiện (Hybrid – đã áp dụng)

Tóm tắt chiến lược đã dùng trong V1:

1. **Top-level**:
   - API hướng người dùng: giống `AXI_Interconnect.sv` (2M×4S), nhưng có thêm parameters:
     - `NUM_MASTERS`, `NUM_SLAVES`, `ADDR_WIDTH`, `DATA_WIDTH`, `ARBITRATION_MODE`.
2. **Internal**:
   - Dùng packed arrays `m_*` và `s_*` để xử lý “theo index”.
3. **Mapping**:
   - Master 0 luôn mapped vào index 0 của arrays.
   - Master 1 mapped vào index 1 nếu `NUM_MASTERS > 1`, otherwise tie-off.
   - Slaves 0..3 mapped vào index 0..3 (`NUM_SLAVES` dùng để quyết định logic core trong tương lai).

Hạn chế (có chủ ý, để an toàn):
- Vẫn **chưa thay đổi core logic**, nên thực tế chỉ an toàn cho 2 masters và 4 slaves như cũ.
- Module này là bước đệm để sau đó:
  - Thay `AXI_Interconnect_Full` bằng phiên bản general,
  - Hoặc build logic mới trực tiếp trên arrays `m_*` và `s_*`.

---

### Phase 5 – Implementation steps (đã thực hiện một phần)

#### Step 1 – Tạo file structure

- Đã tạo:
  - `SystemVerilog/axi_interconnect/utils/AXI_Interface.sv`
  - `SystemVerilog/axi_interconnect/core/AXI_Interconnect_General.sv`

#### Step 2 – Khai báo parameters

Trong `AXI_Interconnect_General.sv`:
- `NUM_MASTERS`, `NUM_SLAVES`, `ADDR_WIDTH`, `DATA_WIDTH`, `ARBITRATION_MODE`.

#### Step 3 – Port declaration

- Sử dụng **individual ports**:
  - `M0_*`, `M1_*`
  - `S0_*`..`S3_*`
- Parameter `NUM_MASTERS`, `NUM_SLAVES` quyết định **cách logic nội bộ sử dụng** các index trong arrays, không thay đổi số lượng port vật lý (để giữ tương thích với core hiện tại).

#### Step 4 – Internal signal arrays

- Đã tạo đầy đủ arrays cho tất cả channels:
  - Masters: `m_awaddr`, `m_wdata`, `m_bresp`, `m_araddr`, `m_rdata`, ...
  - Slaves:  `s_awaddr`, `s_wdata`, `s_bresp`, `s_araddr`, `s_rdata`, ...
- `always_comb` và `generate` thực hiện mapping giữa ports ↔ arrays.

#### Step 5 – Core logic (hook – hiện là placeholder)

- Phần comment trong module:
  ```systemverilog
  // AXI_Interconnect_Full #(
  //     .Masters_Num    (NUM_MASTERS),
  //     .Num_Of_Masters (NUM_MASTERS),
  //     .Num_Of_Slaves  (NUM_SLAVES),
  //     .ARBITRATION_MODE(ARBITRATION_MODE)
  // ) u_full_general ( ... );
  ```
- Chưa nối thật vì:
  - Core `AXI_Interconnect_Full` hiện tại có interface *cố định* (S00, S01, M00..M03).
  - Refactor core cần nhiều thay đổi, nên tách bước này để dễ review.

#### Step 6 – Address decoding

- Chưa chỉnh sửa decoder trong V1.  
- Kế hoạch tương lai:
  - Dùng parameters `Num_Of_Slaves` và (sau này) `SLAVE_BASE/LIMIT` để drive:
    - `Write_Addr_Channel_Dec.sv`
    - `Read_Addr_Channel_Dec.sv`

#### Step 7 – Arbitration

- Các arbiter hiện tại (`read_arbiter.sv`, `Qos_Arbiter`, ...) đã support `Masters_Num=2`.  
- Để general hóa:
  - Cần cho phép `Masters_Num` >2 và sửa các case/counter tương ứng.  
- V1 không thay đổi các file arbitration; tham số `ARBITRATION_MODE` vẫn truyền từ wrapper vào core (khi hook hoàn chỉnh).

---

### Phase 6 – Limitations và considerations (V1)

#### 6.1. Tool limitations

- Số lượng ports trong một module bị giới hạn bởi FPGA tool (nhưng 2M×4S vẫn an toàn).
- generate không thể tạo port mới, chỉ áp dụng cho logic bên trong.

#### 6.2. Practical limits

- V1:
  - `NUM_MASTERS` chỉ an toàn ở `{1,2}` vì core chỉ có 2 S-ports (S00, S01).
  - `NUM_SLAVES` chỉ an toàn ở `1..4` vì core chỉ có 4 M-ports (M00..M03).
- Để mở đến 8 masters / 16 slaves:
  - Cần **AXI_Interconnect_Full_General** hoặc core mới:
    - Interface dựa trên arrays hoặc interface bundling,
    - Channel controllers và decoder được parameter hóa hoàn chỉnh.

#### 6.3. Backward compatibility

- Giữ nguyên:
  - `AXI_Interconnect.sv` (2M×4S) – version đơn giản, dùng trực tiếp trong system hiện có.
- Thêm:
  - `AXI_Interconnect_General.sv` – version “general-friendly”:
    - API có parameters,
    - Internal arrays theo plan,
    - Sẵn sàng nối với core general trong tương lai.

---

### Phase 7 – Testing strategy (định hướng)

Hiện tại:
- `AXI_Interconnect_General` V1 **chưa nối core**, nên chưa dùng cho functional simulation.  
- Khi hook core hoàn tất, cần test theo các cấu hình:

#### 7.1. Test cases đề xuất

1. **1 Master × 1 Slave** (minimal sanity test)
2. **2 Masters × 4 Slaves** (matching design hiện tại)
3. **Stress Test**: nhiều transaction song song với đầy đủ 4 slaves
4. **Different ARBITRATION_MODE**:
   - 0: Fixed Priority
   - 1: Round-Robin
   - 2: QoS-based (nếu support)

#### 7.2. Verification

- Tạo testbench parameterized:
  ```systemverilog
  AXI_Interconnect_General #(
      .NUM_MASTERS(2),
      .NUM_SLAVES(4),
      .ADDR_WIDTH(32),
      .DATA_WIDTH(32)
  ) dut (/* connect M0/M1, S0..S3 */);
  ```
- Check:
  - Address decoding mapping đúng đến S0..S3.
  - Arbitration fairness giữa M0 và M1.
  - Handshake và back-pressure hoạt động đúng cho mọi channel.

---

### Tóm tắt hiện trạng V1

- **Đã làm:**
  - Phân tích constraints SystemVerilog và thiết kế strategy Hybrid (Phase 1–4).
  - Tạo:
    - `AXI_Interface.sv` (package struct cho AXI channels).
    - `AXI_Interconnect_General.sv` với:
      - Parameters: `NUM_MASTERS`, `NUM_SLAVES`, `ADDR_WIDTH`, `DATA_WIDTH`, `ARBITRATION_MODE`.
      - Individual ports giống 2M×4S wrapper hiện có.
      - Internal packed arrays `m_*`, `s_*` + mapping (always_comb, generate).
      - Placeholder hook cho core logic (commented instantiation).
- **Chưa làm (cố ý để tách bước):**
  - Chưa refactor `AXI_Interconnect_Full` thành phiên bản general.
  - Chưa sửa decoder + arbitration để support NUM_MASTERS/SLAVES > giới hạn hiện tại.

Khi bạn sẵn sàng, bước tiếp theo sẽ là:
- Thiết kế `AXI_Interconnect_Full_General` dựa trên các arrays `m_*` và `s_*`,
- Hoặc refactor từng channel controller / decoder để nhận arrays thay vì fixed ports,
- Sau đó nối đầy đủ vào `AXI_Interconnect_General.sv` và thêm testbench parameterized.


