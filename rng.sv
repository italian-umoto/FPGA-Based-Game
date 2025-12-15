module rng (
    input  logic       clk,
    input  logic       trigger,        // clock enable (1-clock pulse recommended)
    input  logic [6:0] seed,           // must be non-zero; if 0, default used
    output logic [6:0] random_number
);

    logic [6:0] lfsr;
    logic       feedback;

    // x^7 + x^6 + 1 (max-length)
    assign feedback = lfsr[6] ^ lfsr[5];

    always_ff @(posedge clk) begin
        if (lfsr == 7'd0) begin
            lfsr <= (seed != 7'd0) ? seed : 7'b1010101;
        end else if (trigger) begin
            lfsr <= {lfsr[5:0], feedback};
        end
    end

    always_comb begin
        random_number = lfsr % 7'd100;   // 0..99
    end

endmodule

