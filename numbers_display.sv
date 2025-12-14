module number_gen #(
    parameter int X0 = 100,
    parameter int Y0 = 100
)(
    input logic visible,
    input logic [9:0] col,
    input logic [9:0] row,
    output logic number_on,
    output logic [5:0] number_rgb
);

    logic [5:0] sx;
    logic [5:0] sy;
    logic [11:0] addr;
    logic [5:0] px;

    // Boolean value to determine if the number is within the specified grid
    always_comb begin
        number_on = visible && (col >= X0) && (col <  X0 + 50) 
                    && (row >= Y0) && (row <  Y0 + 50);
    end

    assign sx = col - X0;
    assign sy = row - Y0;

    // For each block, determine the adress to retrive the rgb data
    assign addr = sy * 12'd50 + sx;

    // Call the rom module to retrieve pixel data
    number_rom u_rom (
        .addr(addr),
        .data(px)
    );

    assign number_rgb = px;
endmodule

module number_rom (
    input  logic [11:0] addr,
    output logic [5:0]  data,
    input logic [3:0] number
);
    logic [7:0] mem [0:2499];

    initial begin
        $readmemh("vga_assets/mem File/zero.mem", mem);
    end

    always_comb begin
        data = mem[addr][5:0];
    end

endmodule
