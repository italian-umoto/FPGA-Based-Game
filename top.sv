module top (
    input logic clk_12M,
    output logic HSYNC,
    output logic VSYNC,
    output logic [5:0] RGB,
);

    // Instantiate the clk using PLL
    logic pll_clk;
    mypll mypll_inst(
        .ref_clk_i (clk_12M),
        .rst_n_i (1'b1),
        .outcore_o (),
        .outglobal_o (pll_clk)
    );

    // Instantiate the vga module 
    logic [9:0] row, col;
    logic visible;
    vga u_vga(
        .clk (pll_clk),
        .hsync (HSYNC),
        .vsync (VSYNC),
        .col (col),
        .row (row),
        .visible (visible)
    );

    // Instantiate the background generator to produce background pixels
    logic [5:0] bg_rgb;
    background_gen u_bggen(
        .visible (visible),
        .col (col),
        .row (row),
        .bg_rgb (bg_rgb)
    );

    // Dummy variable to cause the screen to black for now 
    logic [28:0] counter;
    logic blink;    // Modify Later

    always_ff @(posedge pll_clk) begin
        counter <= counter + 29'd1;
    end

    assign blink = counter[27];

    logic number_on;
    logic [5:0] number_rgb;

    // Instantiate the number module to genreate the number pixels
    number_gen #(.X0(80), .Y0(130)) u_number (
        .visible (visible),
        .col (col),
        .row (row),
        .number_on (number_on),
        .number_rgb (number_rgb)
    );

    // If blink is triggered, then switch to blink, otherwise choose bg pixels
    always_comb begin
        RGB = 6'b0;            

        if (visible) begin
            RGB = bg_rgb;
            if (blink && number_on)
                RGB = number_rgb;
        end
    end

endmodule
