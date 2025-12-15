/* 
 * Parameter: 
 * Input: 
 * Description: 
 * Output: 
 */
module two_digit_display #(
    parameter int X_TENS = 350,
    parameter int X_ONES = 360,
    parameter int Y_DIG  = 170,
    parameter int DIG_W  = 20,
    parameter int DIG_H  = 30
)(
    input  logic       visible,
    input  logic [9:0] col,
    input  logic [9:0] row,

    input  logic [9:0] value,

    output logic       display_on,
    output logic [5:0] display_rgb
);

    logic [3:0] tens_value;
    logic [3:0] ones_value;

    assign ones_value = value % 10;
    assign tens_value = value / 10;

    logic tens_on, ones_on;
    logic [5:0] tens_rgb, ones_rgb;

    number_trans_gen #(.X0(X_TENS), .Y0(Y_DIG), .W(DIG_W), .H(DIG_H)) u_tens (
        .visible    (visible),
        .col        (col),
        .row        (row),
        .digit      (tens_value),
        .number_on  (tens_on),
        .number_rgb (tens_rgb)
    );

    number_trans_gen #(.X0(X_ONES), .Y0(Y_DIG), .W(DIG_W), .H(DIG_H)) u_ones (
        .visible    (visible),
        .col        (col),
        .row        (row),
        .digit      (ones_value),
        .number_on  (ones_on),
        .number_rgb (ones_rgb)
    );

    always_comb begin
        display_on  = 1'b0;
        display_rgb = 6'b0;

        if (tens_on) begin
            display_on  = 1'b1;
            display_rgb = tens_rgb;
        end else if (ones_on) begin
            display_on  = 1'b1;
            display_rgb = ones_rgb;
        end
    end

endmodule


/* 
 * Parameter: 
 * Input: 
 * Description: 
 * Output: 
 */
module number_trans_gen #(
    parameter int X0 = 100, // X coordinate of the top left corner
    parameter int Y0 = 100, // Y coordinate of the top left corner
    parameter int W = 20, // Width of the number sprite
    parameter int H = 30 // Height of the number sprite
)(
    input logic visible,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic [3:0] digit,
    output logic number_on,
    output logic [5:0] number_rgb
);

    logic [5:0]  sx;
    logic [5:0]  sy;
    logic [11:0] pix_idx;
    logic [14:0] addr;
    logic [5:0]  px;

    // Check if the sprite is inside the box
    always_comb begin
        number_on = visible && (col >= X0) && (col < X0 + W) && (row >= Y0) 
                    && (row < Y0 + H);
    end

    // Get the local coords inside the sprite
    assign sx = col - X0;
    assign sy = row - Y0;

    // Get the pixel index inside the sprite (20x30)
    assign pix_idx = sy * 12'd20 + sx;

    // Navigate to the correct number, since each number takes 600 bytes
    assign addr = digit * 15'd600 + pix_idx;

    number_trans_rom u_rom (
        .addr(addr),
        .data(px)
    );

    assign number_rgb = px;
endmodule


/* 
 * Parameter: 
 * Input: 
 * Description: 
 * Output: 
 */
module number_trans_rom (
    input  logic [14:0] addr, // Account for 0 to 9
    output logic [5:0]  data
);
    logic [7:0] mem [0:5999];

    initial begin
        $readmemh("vga_assets/mem File/digits_trans.mem", mem);
    end

    always_comb begin
        data = mem[addr][5:0];
    end
endmodule

