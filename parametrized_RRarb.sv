module RRarb #(
    parameter NUM_REQ = 4
) (
    input clk,
    input rstb,
    input [NUM_REQ-1:0] req,
    output [NUM_REQ-1:0] grant
);

logic [NUM_REQ-1:0] last_grant;
logic [NUM_REQ-1:0] mask;
integer i;


always_ff@(posedge clk) begin
  if( ~rstb) begin last_grant<= '0; end
  else begin last_grant <= grant;   end
end

always_comb begin
    mask = '1;
    for ( i  = 0; i < NUM_REQ; i++) begin
        if( last_grant[i]) begin mask[i:0] = '0; end
    end
end

logic [NUM_REQ-1:0] masked_req, masked_grant, unmaksed_grant;
assign masked_req = mask & req;

prioArb unmasked_inst (.req(req), .grant(unmasked_grant));
prioArb masked_inst (.req(masked_req), .grant(masked_grant));

assign grant = (masked_req == '0) ? unmasked_grant: masked_grant;
endmodule

module PrioArb #(
    parameter NUM_REQ = 4
) (
    input [NUM_REQ-1:0] req,
    output [NUM_REQ-1:0] grant
);
  integer i;
  always_comb begin
    grant = '0;
    for (i = 0; i< NUM_REQ; i++) begin
        if(req[i]) begin 
            grant[i] = 1'b1;
            break; 
        end 
    end
  end
endmodule