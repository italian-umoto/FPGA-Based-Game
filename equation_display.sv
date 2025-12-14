module equation_display (
    input logic [9:0] num1,
    input logic [9:0] num2,
    input logic [2:0] operator,

    input logic visible,
    input logic [9:0] col,
    input logic [9:0] row,
    input logic clk,

    output logic eq_on,
    output logic [5:0] eq_rgb
);

    // Convert numbers to digits
    logic [3:0] num1_ones, num1_tens;
    logic [3:0] num2_ones, num2_tens;

    DDDD u_num1(.nummber(num1), .ones(num1_ones), .tens(num1_tens));
    DDDD u_num2(.nummber(num2), .ones(num2_ones), .tens(num2_tens));

    // Layout parameters
    localparam int W = 20;
    localparam int H = 30;

    // Starting coordinates for the equation display
    localparam int X0 = 100;
    localparam int Y0 = 140;

    // FYI RESULT START AT X0 + 6*W
    localparam int X_NUM1_TENS = X0;
    localparam int X_NUM1_ONES = X0 + W;
    localparam int X_OP = X0 + 2*W;
    localparam int X_NUM2_TENS = X0 + 3*W;
    localparam int X_NUM2_ONES = X0 + 4*W;
    localparam int X_EQ = X0 + 5*W;

    logic on_n1t, on_n1o, on_n2t, on_n2o;
    logic [5:0] rgb_n1t, rgb_n1o, rgb_n2t, rgb_n2o;

    number_gen #(.X0(X_NUM1_TENS), .Y0(Y0), .W(W), .H(H)) 
        u_n1t (.visible (visible), .col (col), .row (row), .digit (num1_tens),
               .number_on (on_n1t), .number_rgb (rgb_n1t)
               );

    number_gen #(.X0(X_NUM1_ONES), .Y0(Y0), .W(W), .H(H)) 
        u_n1o (.visible (visible), .col (col), .row (row), .digit (num1_ones),
               .number_on (on_n1o), .number_rgb (rgb_n1o)
               );

    number_gen #(.X0(X_NUM2_TENS), .Y0(Y0), .W(W), .H(H)) 
        u_n2t (.visible (visible), .col (col), .row (row), .digit (num2_tens),
               .number_on (on_n2t), .number_rgb (rgb_n2t)
               );

    number_gen #(.X0(X_NUM2_ONES), .Y0(Y0), .W(W), .H(H)) 
        u_n2o (.visible (visible), .col (col), .row (row), .digit (num2_ones),
               .number_on (on_n2o), .number_rgb (rgb_n2o)
               );


    logic op_on;
    logic [5:0] op_rgb;

    operator_gen #(.X0(X_OP), .Y0(Y0), .W(W), .H(H)) 
        u_op (.visible (visible), .col (col), .row (row), .operator (operator),
              .op_on (op_on), .op_rgb (op_rgb)
              );


    logic eqsign_on;
    logic [5:0] eqsign_rgb;

    operator_gen #(.X0(X_EQ), .Y0(Y0), .W(W), .H(H)) 
    u_eqsign (.visible (visible), .col (col), .row (row), .operator (3'd5),
              .op_on (eqsign_on), .op_rgb (eqsign_rgb)
              );

    always_comb begin
        eq_on  = 1'b0;
        eq_rgb = 6'b0;

        if (visible) begin
            if (on_n1t) begin eq_on = 1'b1; eq_rgb = rgb_n1t; end
            else if (on_n1o) begin eq_on = 1'b1; eq_rgb = rgb_n1o; end
            else if (op_on)  begin eq_on = 1'b1; eq_rgb = op_rgb;  end
            else if (on_n2t) begin eq_on = 1'b1; eq_rgb = rgb_n2t; end
            else if (on_n2o) begin eq_on = 1'b1; eq_rgb = rgb_n2o; end
            else if (eqsign_on) begin eq_on = 1'b1; eq_rgb = eqsign_rgb; end
        end
    end

endmodule


module DDDD(
    input  logic [9:0] nummber,
    output logic [3:0] ones,
    output logic [3:0] tens
);

    assign ones = nummber % 10;
    assign tens = nummber / 10;

endmodule

module operator_gen #(
    parameter int X0 = 100,
    parameter int Y0 = 100,
    parameter int W  = 20,
    parameter int H  = 30
)(
    input  logic       visible,
    input  logic [9:0] col,
    input  logic [9:0] row,
    input  logic [2:0] operator,
    output logic       op_on,
    output logic [5:0] op_rgb
);

    logic [5:0] sx;
    logic [5:0] sy;
    logic [11:0] pix_idx;   // 0..599
    logic [12:0] addr;      // 0..3599
    logic [5:0] px;

    always_comb begin
        op_on = visible &&
                (col >= X0) && (col < X0 + W) &&
                (row >= Y0) && (row < Y0 + H);
    end

    assign sx = col - X0;
    assign sy = row - Y0;

    assign pix_idx = sy * 12'd20 + sx;

    // 6 operators packed back-to-back: operator*600 + pix_idx
    assign addr = operator * 13'd600 + pix_idx;

    operator_rom u_oprom (
        .addr(addr),
        .rgb_data(px)
    );

    always_comb begin
        if (!op_on) op_rgb = 6'b0;
        else        op_rgb = px;
    end

endmodule



module operator_rom (
    input  logic [12:0] addr,
    output logic [5:0]  rgb_data
);

    logic [7:0] mem [0:3599];

    initial begin
        $readmemh("vga_assets/mem File/operations.mem", mem);
    end

    always_comb begin
        rgb_data = mem[addr][5:0];
    end

endmodule

