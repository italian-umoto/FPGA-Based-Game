/* background_gen.sv
 * Parameter: None
 * Input: visible signal, column and row positions
 * Description: This module generates background pixel data based on the
 *              current column and row positions. It uses a ROM module to
 *              retrieve pixel data for the background image.
 * Output: bg_rgb - 6-bit background pixel data
 */
module background_gen (
    input  logic visible,
    input  logic [9:0] col,
    input  logic [9:0] row,
    output logic [5:0] bg_rgb
);
    logic [7:0] bg_x;
    logic [6:0] bg_y;
    logic [14:0] addr;
    logic [5:0] px;

    assign bg_x = col[9:2];
    assign bg_y = row[9:2];
    assign addr = bg_y * 160 + bg_x; 

    bg_rom u_bg (
        .addr(addr),
        .data(px)
    );

    always_comb begin
        if (!visible) bg_rgb = 6'b0;
        else          bg_rgb = px;
    end
endmodule

/* bg_rom.sv
 * Parameter: W (width), H (height) - specify the background image dimensions
 * Input: addr - address to specify which pixel to retrieve
 * Description: This module implements a ROM to store background pixel data and
 *              retrieve pixel data based on the input address.
 * Output: data - 6-bit pixel data
 */
module bg_rom #(
    parameter int W = 160,
    parameter int H = 120
)(
    input  logic [$clog2(W*H)-1:0] addr,
    output logic [5:0] data
);
    localparam int DEPTH = W*H;

    logic [7:0] mem [0:DEPTH-1];

    initial begin
        $readmemh("vga_assets/mem File/bg.mem", mem);
    end

    always_comb begin
        data = mem[addr][5:0];
    end
endmodule

