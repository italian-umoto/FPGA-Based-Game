/* 
 * Parameter: 
 * Input: 
 * Description: 
 * Output: 
 */
module vga(
    input logic clk,
    output logic hsync,
    output logic vsync,
    output logic [9:0] col,
    output logic [9:0] row,
    output logic visible
);

    initial begin
        col = 10'd0;
        row = 10'd0;
    end

    always_ff @(posedge clk) begin
        if (col == 10'd799)
            col <= 10'd0;
        else
            col <= col + 10'd1;
    end

    always_ff @(posedge clk) begin
        if (col == 10'd799) begin
            if (row == 10'd524)
                row <= 10'd0;
            else
                row <= row + 10'd1;
        end
    end

    assign hsync = ~((col >= 10'd656) && (col < 10'd752));
    assign vsync = ~((row >= 10'd490) && (row < 10'd492));
    assign visible = (col < 10'd640) && (row < 10'd480);

endmodule

/**
* PLL configuration
*
* This Verilog module was generated automatically
* using the icepll tool from the IceStorm project.
* Use at your own risk.
*
* Given input frequency: 12.000 MHz
* Requested output frequency: 25.175 MHz
* Achieved output frequency: 25.125 MHz
*/
module mypll (
	input ref_clk_i, 	// 12 MHz clock from Upduino pin
	input rst_n_i, 	// active-low reset
	output outcore_o,	// internal routed clock
	output outglobal_o  // global clock (preferred)
);

wire lock;

SB_PLL40_CORE #(
	.DIVR(4'd0),
	.DIVF(7'd66),
	.DIVQ(3'd5),
	.FILTER_RANGE(3'b001),
	.FEEDBACK_PATH("SIMPLE")
) pll_inst (
	.REFERENCECLK(ref_clk_i),  // take clock from fabric
	.PLLOUTCORE(outcore_o),
	.PLLOUTGLOBAL(outglobal_o),
	.RESETB(rst_n_i),
	.BYPASS(1'b0),
	.LOCK(lock)
);

endmodule