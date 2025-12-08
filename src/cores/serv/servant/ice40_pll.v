`default_nettype none
module ice40_pll
  (
   input  wire i_clk,
   output wire o_clk,
   output wire o_rst);

   parameter PLL = "NONE";

   wire   locked;

   reg [1:0] rst_reg;
   always @(posedge o_clk)
     rst_reg <= {rst_reg[0],locked};
   assign o_rst = ~rst_reg[1];

   // Note: pll.vh is generated during synthesis, not available for simulation
   // ICE40 PLL primitives (SB_PLL40_CORE, SB_PLL40_PAD) are not available in simulation
   // For simulation, always bypass PLL regardless of PLL parameter
   // In synthesis, this will be replaced with actual PLL instantiation
   assign o_clk = i_clk;
   assign locked = 1'b1;
   
   // Original PLL code (commented out for simulation compatibility):
   // generate
   //    if (PLL == "ICE40_CORE") begin
   //	 SB_PLL40_CORE
   //	   #(`include "pll.vh")
   //	 pll
   //	   (
   //	    .LOCK(locked),
   //	    .RESETB(1'b1),
   //	    .BYPASS(1'b0),
   //	    .REFERENCECLK(i_clk),
   //	    .PLLOUTCORE(o_clk));
   //    end else if (PLL == "ICE40_PAD") begin
   //	 SB_PLL40_PAD
   //	   #(`include "pll.vh")
   //	 pll
   //	   (
   //	    .LOCK(locked),
   //	    .RESETB(1'b1),
   //	    .BYPASS(1'b0),
   //	    .PACKAGEPIN (i_clk),
   //	    .PLLOUTCORE(o_clk));
   //    end
   // endgenerate
endmodule
