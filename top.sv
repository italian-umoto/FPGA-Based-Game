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

    logic trigger_d;
    logic trigger_pulse;
    logic [28:0] frame_counter;

    always_ff @(posedge pll_clk) begin
        frame_counter <= frame_counter + 29'd1;
        trigger_d     <= frame_counter[27];
    end

    assign trigger_pulse = frame_counter[27] & ~trigger_d; // 1-clock pulse

    // ------------------------------------------------------------
    // RNG outputs
    // ------------------------------------------------------------
    logic [6:0] num1_rng, num2_dummy, num2_rng;

    rng u_rng (
        .clk            (pll_clk),
        .trigger        (trigger_pulse),
        .seed           (7'b1010101),
        .random_number  (num1_rng)
    );

    rng u_rng2 (
        .clk            (pll_clk),
        .trigger        (trigger_pulse),
        .seed           (7'b0110011),
        .random_number  (num2_dummy)
    );

    assign num2_rng = num2_dummy[3:0];

    // Widen to what equation_display expects
    logic [6:0] num1, num2;
    assign num1 = {3'b0, num1_rng};
    assign num2 = {3'b0, num2_rng};

    logic eq_on;
    logic [5:0] eq_rgb;

    equation_display u_eq (.num1 (num1), .num2 (num2), .operator(3'd4),
                           .visible (visible), .col (col), .row (row),
                           .clk (pll_clk), .eq_on (eq_on), .eq_rgb (eq_rgb)
                           );

    logic timer_on;
    logic [5:0] timer_rgb;

    two_digit_display #(.X_TENS(345), .X_ONES(365), .Y_DIG(175)) 
        u_health (
            .visible    (visible),
            .col        (col),
            .row        (row),
            .value      (10'd69), // Enter time value here
            .display_on (timer_on),
            .display_rgb(timer_rgb)
            );

    always_comb begin
        RGB = 6'b0;

        if (visible) begin
            RGB = bg_rgb;

            if (timer_on)
                RGB = timer_rgb;

            if (eq_on)
                RGB = eq_rgb;
        end
    end

endmodule
