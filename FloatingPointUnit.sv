module FloatingPointUnit #(
    parameter DATA_WIDTH = 16, 
    parameter EXP_WIDTH = 8)
(
    input clk,
    input rst,
    input op,  // ADD: op = 0, MULT = op=1
    input a_valid,
    input b_valid,
    input [DATA_WIDTH-1:0] op_a,
    input [DATA_WIDTH-1:0] op_b,
    output [(2*DATA_WIDTH-1):0] out,
    output error
);

localparam MAN_WIDTH = DATA_WIDTH-1-EXP_WIDTH;
// Floating point addition step
// 1. compare exponent
// 2. equate the exponent to a bigger value, move mantissa
// 3. add mantissa
// 4. normalize the output
logic sign_a, sign_b;
logic [EXP_WIDTH-1:0] exp_a, exp_b;
logic [MAN_WIDTH-1:0] man_a, man_b;
logic [EXP_WIDTH-1:0] out_exp;
logic [MAN_WIDTH-1:0] out_man;
logic [EXP_WIDTH-1:0] exp_diff;
logic [MAN_WIDTH+1:0] man_sum;
always@(*) begin
    // extract sign, exp and mantissa
    sign_a = op_a[DATA_WIDTH-1];
    sign_b = op_b[DATA_WIDTH-1];
    exp_a = op_a[DATA_WIDTH-2:(DATA_WIDTH-1-EXP_WIDTH)];
    exp_b = op_b[DATA_WIDTH-2:(DATA_WIDTH-1-EXP_WIDTH)];
    man_a = op_a[MAN_WIDTH-1:0];
    man_b = op_b[MAN_WIDTH-1:0];

    // step 1. compare and shift mantissa
    if ( exp_a > exp_b) begin 
        exp_diff = exp_a - exp_b;
        man_b = man_b>>(exp_diff);
        out_exp = exp_a;
    end
    else begin 
        exp_diff = exp_b-exp_a;
        man_a = man_a >> (exp_diff);
        out_exp = exp_b;
    end

    // step 2. add mantissa
    man_sum = $signed( {sign_a,man_a}) +$signed({sign_b, man_b});
    if (man_sum[MAN_WIDTH]) begin
        man_sum= man_sum >>1;
        man_sum = man_sum[MAN_WIDTH-1:0];
        out_exp = out_exp+1;
        out_sign = man_sum[MAN_WIDTH+1];
    end
    else begin 
        out_man = man_sum[MAN_WIDTH-1:0];
        out_sign = man_sum[MAN_WIDTH+1]; 
    end
end


// multiply
// step 1. extract
// step 2. add exponent
// step 3. multiply mantissa
// step 4. normalize
logic [EXP_WIDTH-1:0] exp_mul;


always@(*) begin
    // extract sign, exp and mantissa
    sign_a = op_a[DATA_WIDTH-1];
    sign_b = op_b[DATA_WIDTH-1];
    exp_a = op_a[DATA_WIDTH-2:(DATA_WIDTH-1-EXP_WIDTH)];
    exp_b = op_b[DATA_WIDTH-2:(DATA_WIDTH-1-EXP_WIDTH)];
    man_a = op_a[MAN_WIDTH-1:0];
    man_b = op_b[MAN_WIDTH-1:0];
    
    // in case when both of them are normlized number
    exp_mul = (exp_a-127) + (exp_b-127)+127;

    out_man = man_a * man_b;

    exp_sign = sign_a ^ sign_b;
    
end
endmodule