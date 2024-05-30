module fixedPriorityArbiter #(
    parameter NUM_REQ = 4
)(
    input [3:0] req,
    output [3:0] grant
);

// req[0] highest probability, req[3] lowest probablity
  always@(*) begin
    if      (req[0]) begin grant = 4'b0001; end
    else if (req[1]) begin grant = 4'b0010; end
    else if (req[2]) begin grant = 4'b0100; end
    else if (req[3]) begin grant = 4'b1000; end
    else begin grant = 4'b0000; end
  end
endmodule