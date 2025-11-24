# AXI Interconnect - Bảng Tín Hiệu Đầu Vào và Đầu Ra

Tài liệu này liệt kê tất cả các tín hiệu đầu vào và đầu ra của khối `AXI_Interconnect`.

## Tổng Quan

Module `AXI_Interconnect` là một wrapper module cung cấp giao diện đơn giản cho các test case. Module này chuyển đổi giao diện read-only đơn giản sang giao thức AXI4 đầy đủ.

## Bảng Tín Hiệu Đầu Vào (Input Signals)

### 1. Tín Hiệu Global

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `G_clk` | input wire | 1 bit | Clock signal toàn cục |
| `G_reset` | input wire | 1 bit | Reset signal toàn cục |

### 2. Master 0 Interface (Read Only)

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `M0_RREADY` | input wire | 1 bit | Master 0 ready để nhận dữ liệu đọc |
| `M0_ARADDR` | input wire | 32 bits | Master 0 địa chỉ đọc |
| `M0_ARLEN` | input wire | 4 bits | Master 0 độ dài burst đọc |
| `M0_ARSIZE` | input wire | 3 bits | Master 0 kích thước transfer đọc |
| `M0_ARBURST` | input wire | 2 bits | Master 0 loại burst đọc |
| `M0_ARVALID` | input wire | 1 bit | Master 0 valid signal cho địa chỉ đọc |

### 3. Master 1 Interface (Read Only)

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `M1_RREADY` | input wire | 1 bit | Master 1 ready để nhận dữ liệu đọc |
| `M1_ARADDR` | input wire | 32 bits | Master 1 địa chỉ đọc |
| `M1_ARLEN` | input wire | 4 bits | Master 1 độ dài burst đọc |
| `M1_ARSIZE` | input wire | 3 bits | Master 1 kích thước transfer đọc |
| `M1_ARBURST` | input wire | 2 bits | Master 1 loại burst đọc |
| `M1_ARVALID` | input wire | 1 bit | Master 1 valid signal cho địa chỉ đọc |

### 4. Slave 0 Interface (Read Only)

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `S0_ARREADY` | input wire | 1 bit | Slave 0 ready để nhận địa chỉ đọc |
| `S0_RVALID` | input wire | 1 bit | Slave 0 valid signal cho dữ liệu đọc |
| `S0_RLAST` | input wire | 1 bit | Slave 0 signal chỉ thị transfer cuối cùng |
| `S0_RRESP` | input wire | 2 bits | Slave 0 response code |
| `S0_RDATA` | input wire | 32 bits | Slave 0 dữ liệu đọc |

### 5. Slave 1 Interface (Read Only)

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `S1_ARREADY` | input wire | 1 bit | Slave 1 ready để nhận địa chỉ đọc |
| `S1_RVALID` | input wire | 1 bit | Slave 1 valid signal cho dữ liệu đọc |
| `S1_RLAST` | input wire | 1 bit | Slave 1 signal chỉ thị transfer cuối cùng |
| `S1_RRESP` | input wire | 2 bits | Slave 1 response code |
| `S1_RDATA` | input wire | 32 bits | Slave 1 dữ liệu đọc |

### 6. Address Range Configuration

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `slave0_addr1` | input wire | 32 bits | Địa chỉ bắt đầu của vùng địa chỉ Slave 0 |
| `slave0_addr2` | input wire | 32 bits | Địa chỉ kết thúc của vùng địa chỉ Slave 0 |
| `slave1_addr1` | input wire | 32 bits | Địa chỉ bắt đầu của vùng địa chỉ Slave 1 |
| `slave1_addr2` | input wire | 32 bits | Địa chỉ kết thúc của vùng địa chỉ Slave 1 |

## Bảng Tín Hiệu Đầu Ra (Output Signals)

### 1. Master 0 Outputs

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `ARREADY_M0` | output wire | 1 bit | Ready signal cho Master 0 địa chỉ đọc |
| `RVALID_M0` | output wire | 1 bit | Valid signal cho Master 0 dữ liệu đọc |
| `RLAST_M0` | output wire | 1 bit | Signal chỉ thị transfer cuối cùng cho Master 0 |
| `RRESP_M0` | output wire | 2 bits | Response code cho Master 0 |
| `RDATA_M0` | output wire | 32 bits | Dữ liệu đọc cho Master 0 |

### 2. Master 1 Outputs

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `ARREADY_M1` | output wire | 1 bit | Ready signal cho Master 1 địa chỉ đọc |
| `RVALID_M1` | output wire | 1 bit | Valid signal cho Master 1 dữ liệu đọc |
| `RLAST_M1` | output wire | 1 bit | Signal chỉ thị transfer cuối cùng cho Master 1 |
| `RRESP_M1` | output wire | 2 bits | Response code cho Master 1 |
| `RDATA_M1` | output wire | 32 bits | Dữ liệu đọc cho Master 1 |

### 3. Slave 0 Outputs

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `ARADDR_S0` | output wire | 32 bits | Địa chỉ đọc gửi đến Slave 0 |
| `ARLEN_S0` | output wire | 4 bits | Độ dài burst đọc gửi đến Slave 0 |
| `ARSIZE_S0` | output wire | 3 bits | Kích thước transfer đọc gửi đến Slave 0 |
| `ARBURST_S0` | output wire | 2 bits | Loại burst đọc gửi đến Slave 0 |
| `ARVALID_S0` | output wire | 1 bit | Valid signal cho địa chỉ đọc gửi đến Slave 0 |
| `RREADY_S0` | output wire | 1 bit | Ready signal để nhận dữ liệu đọc từ Slave 0 |

### 4. Slave 1 Outputs

| Tên Tín Hiệu | Kiểu | Độ Rộng | Mô Tả |
|--------------|------|---------|-------|
| `ARADDR_S1` | output wire | 32 bits | Địa chỉ đọc gửi đến Slave 1 |
| `ARLEN_S1` | output wire | 4 bits | Độ dài burst đọc gửi đến Slave 1 |
| `ARSIZE_S1` | output wire | 3 bits | Kích thước transfer đọc gửi đến Slave 1 |
| `ARBURST_S1` | output wire | 2 bits | Loại burst đọc gửi đến Slave 1 |
| `ARVALID_S1` | output wire | 1 bit | Valid signal cho địa chỉ đọc gửi đến Slave 1 |
| `RREADY_S1` | output wire | 1 bit | Ready signal để nhận dữ liệu đọc từ Slave 1 |

## Tín Hiệu Được Gán Hằng Số (Tied to Constants)

Module `AXI_Interconnect` chỉ hỗ trợ giao diện Read-Only, do đó tất cả các tín hiệu liên quan đến Write channel đều được gán với giá trị hằng số (thường là 0 hoặc giá trị inactive). Các tín hiệu này được kết nối nội bộ với các wire có giá trị mặc định và không được sử dụng trong module wrapper này.

### 1. Write Address Channel Signals (Từ Master đến Interconnect)

Các tín hiệu Write Address channel từ Master 0 và Master 1 đều được gán giá trị **0** (inactive):

| Tín Hiệu Nội Bộ | Giá Trị Hằng Số | Độ Rộng | Mô Tả |
|-----------------|-----------------|---------|-------|
| `S00_AXI_awaddr` | `32'h0` | 32 bits | Write address từ Master 0 - gán 0 |
| `S00_AXI_awlen` | `8'h0` | 8 bits | Write burst length từ Master 0 - gán 0 |
| `S00_AXI_awsize` | `3'h0` | 3 bits | Write transfer size từ Master 0 - gán 0 |
| `S00_AXI_awburst` | `2'h0` | 2 bits | Write burst type từ Master 0 - gán 0 |
| `S00_AXI_awlock` | `2'h0` | 2 bits | Write lock type từ Master 0 - gán 0 |
| `S00_AXI_awcache` | `4'h0` | 4 bits | Write cache attributes từ Master 0 - gán 0 |
| `S00_AXI_awprot` | `3'h0` | 3 bits | Write protection attributes từ Master 0 - gán 0 |
| `S00_AXI_awqos` | `4'h0` | 4 bits | Write QoS từ Master 0 - gán 0 |
| `S00_AXI_awvalid` | `1'b0` | 1 bit | Write address valid từ Master 0 - gán 0 |
| `S01_AXI_awaddr` | `32'h0` | 32 bits | Write address từ Master 1 - gán 0 |
| `S01_AXI_awlen` | `8'h0` | 8 bits | Write burst length từ Master 1 - gán 0 |
| `S01_AXI_awsize` | `3'h0` | 3 bits | Write transfer size từ Master 1 - gán 0 |
| `S01_AXI_awburst` | `2'h0` | 2 bits | Write burst type từ Master 1 - gán 0 |
| `S01_AXI_awlock` | `2'h0` | 2 bits | Write lock type từ Master 1 - gán 0 |
| `S01_AXI_awcache` | `4'h0` | 4 bits | Write cache attributes từ Master 1 - gán 0 |
| `S01_AXI_awprot` | `3'h0` | 3 bits | Write protection attributes từ Master 1 - gán 0 |
| `S01_AXI_awqos` | `4'h0` | 4 bits | Write QoS từ Master 1 - gán 0 |
| `S01_AXI_awvalid` | `1'b0` | 1 bit | Write address valid từ Master 1 - gán 0 |

### 2. Write Data Channel Signals (Từ Master đến Interconnect)

Các tín hiệu Write Data channel từ Master 0 và Master 1 đều được gán giá trị **0**:

| Tín Hiệu Nội Bộ | Giá Trị Hằng Số | Độ Rộng | Mô Tả |
|-----------------|-----------------|---------|-------|
| `S00_AXI_wdata` | `32'h0` | 32 bits | Write data từ Master 0 - gán 0 |
| `S00_AXI_wstrb` | `4'h0` | 4 bits | Write strobe từ Master 0 - gán 0 |
| `S00_AXI_wlast` | `1'b0` | 1 bit | Write last transfer từ Master 0 - gán 0 |
| `S00_AXI_wvalid` | `1'b0` | 1 bit | Write data valid từ Master 0 - gán 0 |
| `S01_AXI_wdata` | `32'h0` | 32 bits | Write data từ Master 1 - gán 0 |
| `S01_AXI_wstrb` | `4'h0` | 4 bits | Write strobe từ Master 1 - gán 0 |
| `S01_AXI_wlast` | `1'b0` | 1 bit | Write last transfer từ Master 1 - gán 0 |
| `S01_AXI_wvalid` | `1'b0` | 1 bit | Write data valid từ Master 1 - gán 0 |

### 3. Write Response Channel Signals (Từ Master đến Interconnect)

Các tín hiệu Write Response channel từ Master 0 và Master 1 đều được gán giá trị **0**:

| Tín Hiệu Nội Bộ | Giá Trị Hằng Số | Độ Rộng | Mô Tả |
|-----------------|-----------------|---------|-------|
| `S00_AXI_bready` | `1'b0` | 1 bit | Write response ready từ Master 0 - gán 0 |
| `S01_AXI_bready` | `1'b0` | 1 bit | Write response ready từ Master 1 - gán 0 |

### 4. Write Channel Signals (Từ Interconnect đến Slave)

Các tín hiệu Write channel từ Interconnect đến Slave 0 và Slave 1 đều được gán giá trị **0** hoặc **1'b0**:

| Tín Hiệu Nội Bộ | Giá Trị Hằng Số | Độ Rộng | Mô Tả |
|-----------------|-----------------|---------|-------|
| `M00_AXI_awready` | `1'b0` | 1 bit | Write address ready đến Slave 0 - gán 0 |
| `M00_AXI_wready` | `1'b0` | 1 bit | Write data ready đến Slave 0 - gán 0 |
| `M00_AXI_BID` | `1'b0` | 1 bit | Write response ID đến Slave 0 - gán 0 |
| `M01_AXI_awready` | `1'b0` | 1 bit | Write address ready đến Slave 1 - gán 0 |
| `M01_AXI_wready` | `1'b0` | 1 bit | Write data ready đến Slave 1 - gán 0 |
| `M01_AXI_BID` | `1'b0` | 1 bit | Write response ID đến Slave 1 - gán 0 |

### 5. Read Address Channel - Optional Signals

Một số tín hiệu tùy chọn trong Read Address channel cũng được gán giá trị **0** vì không được sử dụng:

| Tín Hiệu Nội Bộ | Giá Trị Hằng Số | Độ Rộng | Mô Tả |
|-----------------|-----------------|---------|-------|
| `S00_AXI_arlock` | `2'h0` | 2 bits | Read lock type từ Master 0 - gán 0 |
| `S00_AXI_arcache` | `4'h0` | 4 bits | Read cache attributes từ Master 0 - gán 0 |
| `S00_AXI_arprot` | `3'h0` | 3 bits | Read protection attributes từ Master 0 - gán 0 |
| `S00_AXI_arqos` | `4'h0` | 4 bits | Read QoS từ Master 0 - gán 0 |
| `S01_AXI_arlock` | `2'h0` | 2 bits | Read lock type từ Master 1 - gán 0 |
| `S01_AXI_arcache` | `4'h0` | 4 bits | Read cache attributes từ Master 1 - gán 0 |
| `S01_AXI_arprot` | `3'h0` | 3 bits | Read protection attributes từ Master 1 - gán 0 |
| `S01_AXI_arqos` | `4'h0` | 4 bits | Read QoS từ Master 1 - gán 0 |

### 6. Read Address Channel - Unconnected Signals

Một số tín hiệu Read Address channel từ Interconnect đến Slave được để trống (unconnected) vì không được sử dụng:

| Tín Hiệu Nội Bộ | Trạng Thái | Độ Rộng | Mô Tả |
|-----------------|------------|---------|-------|
| `M00_AXI_arlock` | Unconnected (`()`)| 2 bits | Read lock type đến Slave 0 - không kết nối |
| `M00_AXI_arcache` | Unconnected (`()`)| 4 bits | Read cache attributes đến Slave 0 - không kết nối |
| `M00_AXI_arprot` | Unconnected (`()`)| 3 bits | Read protection attributes đến Slave 0 - không kết nối |
| `M00_AXI_arqos` | Unconnected (`()`)| 4 bits | Read QoS đến Slave 0 - không kết nối |
| `M00_AXI_bready` | Unconnected (`()`)| 1 bit | Write response ready đến Slave 0 - không kết nối |
| `M01_AXI_arlock` | Unconnected (`()`)| 2 bits | Read lock type đến Slave 1 - không kết nối |
| `M01_AXI_arcache` | Unconnected (`()`)| 4 bits | Read cache attributes đến Slave 1 - không kết nối |
| `M01_AXI_arprot` | Unconnected (`()`)| 3 bits | Read protection attributes đến Slave 1 - không kết nối |
| `M01_AXI_arqos` | Unconnected (`()`)| 4 bits | Read QoS đến Slave 1 - không kết nối |
| `M01_AXI_bready` | Unconnected (`()`)| 1 bit | Write response ready đến Slave 1 - không kết nối |

### Tổng Kết Tín Hiệu Gán Hằng Số

- **Tổng số tín hiệu Write Address channel được gán 0**: 18 tín hiệu
- **Tổng số tín hiệu Write Data channel được gán 0**: 8 tín hiệu
- **Tổng số tín hiệu Write Response channel được gán 0**: 2 tín hiệu
- **Tổng số tín hiệu Write channel đến Slave được gán 0**: 6 tín hiệu
- **Tổng số tín hiệu Read Address optional được gán 0**: 8 tín hiệu
- **Tổng số tín hiệu không kết nối (unconnected)**: 10 tín hiệu

**Tổng cộng**: 52 tín hiệu được gán hằng số hoặc không kết nối (không tính các tín hiệu unused internal wires)

## Tổng Kết

### Thống Kê Tín Hiệu

- **Tổng số tín hiệu đầu vào**: 24 tín hiệu
  - Global: 2 tín hiệu
  - Master 0: 6 tín hiệu
  - Master 1: 6 tín hiệu
  - Slave 0: 5 tín hiệu
  - Slave 1: 5 tín hiệu
  - Address configuration: 4 tín hiệu

- **Tổng số tín hiệu đầu ra**: 16 tín hiệu
  - Master 0 outputs: 5 tín hiệu
  - Master 1 outputs: 5 tín hiệu
  - Slave 0 outputs: 6 tín hiệu
  - Slave 1 outputs: 6 tín hiệu

- **Tổng số tín hiệu**: 40 tín hiệu

## Ghi Chú

- Module này chỉ hỗ trợ giao diện Read-Only (chỉ đọc)
- Các kênh Write (ghi) được kết nối với các giá trị mặc định và không được sử dụng
- Module sử dụng giao thức AXI4 với độ rộng bus 32 bits
- Độ dài burst (ARLEN) được mở rộng từ 4 bits lên 8 bits để tương thích với AXI4

## File Nguồn

File nguồn chính: `src/axi_interconnect/rtl/core/AXI_Interconnect.v`

