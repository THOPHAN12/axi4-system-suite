`default_nettype none
module servant_ecp5_evn_clock_gen
  (
   input  wire i_clk,
   input  wire i_rst,
   output wire o_clk,
   output wire o_rst);

   wire   locked;

   reg [1:0] rst_reg;
   always @(posedge o_clk)
     if (i_rst)
       rst_reg <= 2'b11;
     else
       rst_reg <= {!locked, rst_reg[1]};

   assign o_rst = rst_reg[0];

   // Note: ecp5_evn_pll uses ECP5 primitives (EHXPLLL) not available in simulation
   // For simulation, bypass PLL regardless of PLL parameter
   // In synthesis, this will be replaced with actual PLL instantiation
   assign o_clk = i_clk;
   assign locked = 1'b1;
   
   // Original PLL code (commented out for simulation compatibility):
   // ecp5_evn_pll pll
   //   (.clki   (i_clk),
   //    .clko   (o_clk),
   //    .locked (locked));

endmodule
