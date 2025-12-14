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

    logic [9:0] num1, num2;
    logic [2:0] op;

    // PLEASE READ: THIS IS WHERE YOU WILL ENTER THE TWO NUMBERS AND THE OPERATOR
    // FYI: Operators are represented as follows: +0, -1, *2, /3, %4
    assign num1 = 10'd54;
    assign num2 = 10'd36;
    assign op = 3'd4;

    logic eq_on;
    logic [5:0] eq_rgb;

    equation_display u_eq (.num1 (num1), .num2 (num2), .operator(op),
                           .visible (visible), .col (col), .row (row),
                           .clk (pll_clk), .eq_on (eq_on), .eq_rgb (eq_rgb)
                           );

    always_comb begin
        RGB = 6'b0;
        if (visible) begin
            RGB = bg_rgb;
            if (eq_on) RGB = eq_rgb;
        end
    end

endmodule
