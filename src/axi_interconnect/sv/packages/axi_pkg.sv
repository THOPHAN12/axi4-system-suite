//=============================================================================
// AXI Package - SystemVerilog
// 
// Package chứa các constants, types, và functions cho AXI4 protocol
//=============================================================================

`ifndef AXI_PKG_SV
`define AXI_PKG_SV

package axi_pkg;

    //=========================================================================
    // AXI4 Protocol Constants
    //=========================================================================
    
    // Address and Data Widths
    parameter int unsigned ADDR_WIDTH = 32;
    parameter int unsigned DATA_WIDTH = 32;
    parameter int unsigned ID_WIDTH = 4;
    
    // Burst Length (AXI4 supports up to 256 transfers)
    parameter int unsigned AXI4_AW_LEN = 8;
    parameter int unsigned AXI4_AR_LEN = 8;
    
    // Default AXI4 Parameters
    parameter int unsigned DEFAULT_AW_LEN = 8;
    parameter int unsigned DEFAULT_AR_LEN = 8;
    parameter int unsigned DEFAULT_WRITE_DATA_WIDTH = 32;
    parameter int unsigned DEFAULT_READ_DATA_WIDTH = 32;
    
    //=========================================================================
    // AXI4 Response Codes
    //=========================================================================
    typedef enum logic [1:0] {
        AXI_RESP_OKAY   = 2'b00,  // Normal access success
        AXI_RESP_EXOKAY = 2'b01,  // Exclusive access okay
        AXI_RESP_SLVERR = 2'b10,  // Slave error
        AXI_RESP_DECERR = 2'b11   // Decode error
    } axi_resp_t;
    
    //=========================================================================
    // AXI4 Burst Types
    //=========================================================================
    typedef enum logic [1:0] {
        AXI_BURST_FIXED = 2'b00,  // Fixed address
        AXI_BURST_INCR  = 2'b01,  // Incrementing address
        AXI_BURST_WRAP  = 2'b10,  // Wrapping address
        AXI_BURST_RESERVED = 2'b11 // Reserved
    } axi_burst_t;
    
    //=========================================================================
    // AXI4 Size Encoding
    //=========================================================================
    typedef enum logic [2:0] {
        AXI_SIZE_1BYTE   = 3'b000,  // 1 byte
        AXI_SIZE_2BYTE   = 3'b001,  // 2 bytes
        AXI_SIZE_4BYTE   = 3'b010,  // 4 bytes
        AXI_SIZE_8BYTE   = 3'b011,  // 8 bytes
        AXI_SIZE_16BYTE  = 3'b100,  // 16 bytes
        AXI_SIZE_32BYTE  = 3'b101,  // 32 bytes
        AXI_SIZE_64BYTE  = 3'b110,  // 64 bytes
        AXI_SIZE_128BYTE = 3'b111   // 128 bytes
    } axi_size_t;
    
    //=========================================================================
    // AXI4 Lock Type
    //=========================================================================
    typedef enum logic [1:0] {
        AXI_LOCK_NORMAL     = 2'b00,  // Normal access
        AXI_LOCK_EXCLUSIVE  = 2'b01,  // Exclusive access
        AXI_LOCK_LOCKED     = 2'b10,  // Locked access
        AXI_LOCK_RESERVED   = 2'b11   // Reserved
    } axi_lock_t;
    
    //=========================================================================
    // AXI4 Protection Type
    //=========================================================================
    typedef struct packed {
        logic [0:0] priv;   // Privileged (1) or User (0)
        logic [1:1] nonsec; // Secure (0) or Non-secure (1)
        logic [2:2] instr;  // Data (0) or Instruction (1)
    } axi_prot_t;
    
    //=========================================================================
    // AXI4 Cache Attributes
    //=========================================================================
    typedef struct packed {
        logic [0:0] bufferable;  // Bufferable
        logic [1:1] cacheable;    // Cacheable
        logic [2:2] read_alloc;  // Read allocate
        logic [3:3] write_alloc; // Write allocate
    } axi_cache_t;
    
    //=========================================================================
    // AXI4 QoS (Quality of Service)
    //=========================================================================
    typedef logic [3:0] axi_qos_t;
    
    //=========================================================================
    // AXI4 Region (AXI4 only)
    //=========================================================================
    typedef logic [3:0] axi_region_t;
    
    //=========================================================================
    // Helper Functions
    //=========================================================================
    
    // Calculate number of bytes from size encoding
    function automatic int unsigned get_bytes_from_size(axi_size_t size);
        case (size)
            AXI_SIZE_1BYTE:   return 1;
            AXI_SIZE_2BYTE:   return 2;
            AXI_SIZE_4BYTE:   return 4;
            AXI_SIZE_8BYTE:   return 8;
            AXI_SIZE_16BYTE:  return 16;
            AXI_SIZE_32BYTE:  return 32;
            AXI_SIZE_64BYTE:  return 64;
            AXI_SIZE_128BYTE: return 128;
            default:          return 4; // Default to 4 bytes
        endcase
    endfunction
    
    // Calculate number of strobe bits from data width
    function automatic int unsigned get_strobe_width(int unsigned data_width);
        return data_width / 8;
    endfunction
    
    // Calculate ID width from number of masters
    function automatic int unsigned get_id_width(int unsigned num_masters);
        return (num_masters > 1) ? $clog2(num_masters) : 1;
    endfunction
    
endpackage

`endif // AXI_PKG_SV

