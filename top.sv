module top (
    input logic clk_12M,
    output logic HSYNC,
    output logic VSYNC,
    output logic [5:0] RGB
);

    // Instantiate PLL module to generate 25.1 MHz clock from 
    // the external 12MHz input
    logic pll_clk;
    mypll mypll_inst(.ref_clk_i (clk_12M), .rst_n_i (1'b1), .outcore_o (),
                     .outglobal_o (pll_clk));

    
    logic [9:0] row, col;
    logic visible;

    // Instantiate VGA controller module to generate sync signals
    vga u_vga(
        .clk (pll_clk),
        .hsync (HSYNC),
        .vsync (VSYNC),
        .col (col),
        .row (row),
        .visible (visible)
    );

    logic [5:0] bg_rgb;

    // Insrtantiate background generator module to create background
    background_gen u_bggen(
        .visible (visible),
        .col (col),
        .row (row),
        .bg_rgb (bg_rgb)
    );

    // Aribtary, change layer pls daniel pls pls pls 
    logic [3:0] dividend_tens_value  = 4'd6;
    logic [3:0] dividend_ones_value  = 4'd7;

    // Dividend display module to display dividend
    // Change position of word by altering .X_TENS()),.X_ONES(),.Y_DIG()
    // Change blink speed by altering .BLINK_BIT()
    // Input the dividend digits by changing dividend_tens_value and
    // dividend_ones_value, respectively.
    dividend_display #(.X_TENS(82),.X_ONES(107),.Y_DIG(130),.BLINK_BIT(27)) 
        u_dividend_display (.clk (pll_clk), .visible (visible), .col (col),
                            .row (row), .bg_rgb (bg_rgb),
                            .dividend_tens_value(dividend_tens_value),
                            .dividend_ones_value(dividend_ones_value),
                            .rgb_out(RGB));

endmodule
