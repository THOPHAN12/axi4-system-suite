# 📊 WAVEFORM VIEWING GUIDE - Dual RISC-V AXI System

**Script**: `run_complete_waveform.tcl`  
**Status**: ✅ **GUI NOW OPEN**

---

## 🎨 **WAVEFORM ORGANIZATION**

### 7 Organized Groups:

```
┌─────────────────────────────────────────┐
│ 1. SYSTEM CLOCK & RESET                 │
│    • ACLK (Yellow)                      │
│    • ARESETN (Cyan)                     │
├─────────────────────────────────────────┤
│ 2. SERV CORE 0 (Master 0)               │
│    • Instruction Bus (ibus)             │
│    • Data Bus (dbus)                    │
│    • AXI Master Port                    │
├─────────────────────────────────────────┤
│ 3. SERV CORE 1 (Master 1)               │
│    • Instruction Bus (ibus)             │
│    • Data Bus (dbus)                    │
│    • AXI Master Port                    │
├─────────────────────────────────────────┤
│ 4. AXI INTERCONNECT                     │
│    • Arbitration Logic                  │
│    • Master 0 Interface                 │
│    • Master 1 Interface                 │
├─────────────────────────────────────────┤
│ 5. SLAVE 0 - RAM                        │
│    • Interconnect Interface             │
│    • RAM Internal Signals               │
├─────────────────────────────────────────┤
│ 6. TRANSACTION COUNTERS                 │
│    • m0_read_count (Gold)               │
│    • m1_read_count (Gold)               │
│    • m0/m1_write_count                  │
├─────────────────────────────────────────┤
│ 7. PERIPHERALS                          │
│    • GPIO                               │
│    • UART                               │
└─────────────────────────────────────────┘
```

---

## 🎨 **COLOR CODING**

| Color | Meaning | Signals |
|-------|---------|---------|
| **🟠 Orange Red** | Request signals | ARVALID, RVALID, AWVALID, WVALID |
| **🟢 Spring Green** | Ready/Grant signals | ARREADY, RREADY, AWREADY, WREADY |
| **🟡 Yellow** | System clock | ACLK |
| **🔵 Cyan** | Reset | ARESETN |
| **🟣 Magenta** | Active states | read_active, write_active |
| **🟤 Light Blue** | Grants | grant_r_m0, grant_r_m1 |
| **🟨 Gold** | Counters | Transaction counts |

---

## 🔍 **KEY TIMING POINTS**

### Initial Zoom: 0-2µs (automatically set)

```
Time        Event                           What to Look For
────────────────────────────────────────────────────────────
0ns         Start                           All signals = 0
0-95ns      Reset Period                    ARESETN = 0
95ns        Reset Released                  ARESETN = 0→1
145ns       System Running                  Cores initialize
445ns       ⭐ FIRST TRANSACTION            M1 Read from 0x00000000
            - M1_ARVALID = 1
            - M1_ARREADY = 1
            - S0_ARVALID = 1
            - S0_ARREADY = 1
            - m1_read_count: 0→1
```

---

## 📐 **HOW TO USE WAVEFORM**

### Basic Navigation:
```
Zoom In:        Ctrl + Mouse Wheel Up
Zoom Out:       Ctrl + Mouse Wheel Down
Zoom Full:      Wave → Zoom → Zoom Full (or press 'F')
Zoom Range:     Click & Drag on timeline
Pan:            Click & Drag waveform area
```

### Measurements:
```
Add Cursor:     Click on timeline
Add 2nd Cursor: Ctrl + Click
Move Cursor:    Drag cursor line
Delta Time:     Shown at top when 2 cursors present
```

### Signal Inspection:
```
Hover Signal:   Tooltip shows value
Click Signal:   Select for highlighting
Right Click:    
  • Change radix (hex/dec/bin)
  • Change color
  • Add to group
  • Expand/collapse
```

---

## 🎯 **WHAT TO VERIFY**

### 1. Reset Sequence (0-100ns):
- [ ] ARESETN: 0 → 1 at ~95ns
- [ ] All other signals stable/reset

### 2. First Transaction (~445ns):
- [ ] M1_ARVALID goes high
- [ ] M1_ARREADY goes high (same cycle or next)
- [ ] M1_ARADDR = 0x00000000
- [ ] S0_ARVALID goes high (forwarded)
- [ ] S0_ARREADY = 1 (always ready)
- [ ] S0_RVALID goes high (response)
- [ ] S0_RDATA = 0x40000437 (first instruction)
- [ ] m1_read_count: 0 → 1

### 3. Arbitration (ongoing):
- [ ] ARBITRATION_MODE = 1
- [ ] rd_turn toggles: 0 ↔ 1
- [ ] grant_r_m0 and grant_r_m1 alternate
- [ ] read_active = 1 when transaction in progress

### 4. Handshakes Pattern:
```
ARVALID ────┐         ┌────
            └─────────┘
ARREADY ────────┐ ┌────────
                └─┘        
            ↑
         Handshake!
```

---

## 📊 **ANALYSIS TIPS**

### Finding Transactions:
1. Look at **transaction counters** (bottom group)
2. When counter increments, **scroll back** to see handshake
3. **Cursors** to measure transaction duration

### Debugging No Activity:
1. Check **ARESETN** released
2. Check **ARVALID** signals go high
3. Check **ARREADY** responses
4. Verify **address** targets RAM (0x00→0x3F)

### Understanding Arbitration:
1. Watch **grant_r_m0** and **grant_r_m1**
2. When both masters request simultaneously:
   - One gets grant = 1
   - Other gets grant = 0
3. **rd_turn** shows whose turn in round-robin

---

## 🎬 **RECOMMENDED VIEWING SEQUENCE**

### Step 1: Overview (0-2µs)
```
Goal: See reset and first activity
Zoom: Already set to 0-2µs
Look: Reset release, first transaction
```

### Step 2: Transaction Detail (400-500ns)
```
Goal: Analyze first transaction in detail
Action: Zoom to 400-500ns range
Look: All handshake signals
Measure: Transaction latency
```

### Step 3: Extended View (0-100µs)
```
Goal: See overall system behavior
Action: Wave → Zoom → Zoom Full
Look: Pattern of activity
Check: Counter increments
```

### Step 4: Specific Signal Tracking
```
Goal: Follow one master's activity
Action: Hide unnecessary groups
Focus: One master + interconnect + RAM
```

---

## 💡 **COMMON PATTERNS**

### Successful Read Transaction:
```
1. Master: ARVALID ↑
2. Arbitration: grant ↑
3. Interconnect: S0_ARVALID ↑
4. RAM: S0_ARREADY = 1
5. RAM: S0_RVALID ↑
6. Master: RREADY ↑
7. Counter: +1
```

### Round-Robin Arbitration:
```
Time    M0_REQ  M1_REQ  GRANT_M0  GRANT_M1  TURN
T0      1       0       1         0         0
T1      0       1       0         1         1
T2      1       1       1         0         0
T3      1       1       0         1         1
```

### Idle System:
```
ARVALID = 0
ARREADY = 0
read_active = 0
Counters = constant
```

---

## 🔧 **CUSTOMIZATION**

### Add More Signals:
```tcl
add wave /path/to/signal
add wave -radix hex /path/to/signal
add wave -color Red /path/to/signal
```

### Create Custom Group:
```tcl
add wave -noupdate -divider "My Group"
add wave /signal1
add wave /signal2
```

### Save Waveform Format:
```
File → Save Format → my_wave.do
```

### Reload Format:
```tcl
do my_wave.do
```

---

## 📈 **PERFORMANCE ANALYSIS**

### Measure Transaction Latency:
1. Place cursor at ARVALID ↑
2. Place cursor at RVALID & RREADY
3. Read Δt (typically 1-3 cycles for RAM)

### Count Transactions:
- Check **transaction counters** (gold signals)
- Or manually count ARVALID & ARREADY = 1

### Throughput Calculation:
```
Rate = Total Transactions / Simulation Time
     = 1 / 64.345µs
     = ~15.5 trans/ms
```

---

## 🎊 **QUICK START**

**Waveform is ALREADY OPEN and CONFIGURED!**

Just:
1. ✅ Look at waveform window
2. ✅ Scroll to ~445ns (first transaction)
3. ✅ Use mouse wheel to zoom
4. ✅ Click signals to inspect values
5. ✅ Press 'F' to zoom full

**Everything is ready to analyze!** 📊

---

## 📞 **COMMANDS REFERENCE**

### Re-run if needed:
```powershell
cd D:\AXI\sim\modelsim
vsim -gui -do "do run_complete_waveform.tcl"
```

### Console test:
```powershell
vsim -c -do "do run_verbose.tcl"
```

### Quick recompile:
```powershell
vsim -c -do "do compile_verilog.tcl; quit"
```

---

**Waveform Guide Complete!** 🎉  
**Happy Analyzing!** 📊✨



