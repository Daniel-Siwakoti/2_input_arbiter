module arbitar (
clock      , // clock
reset      , // Active high, syn reset
req_0      , // Request 0
req_1      , // Request 1
gnt_0      , // Grant 0
gnt_1      //Grant 1
);
//-------------Input Ports-----------------------------
input   clock,reset,req_0,req_1;
 //-------------Output Ports----------------------------
output  gnt_0,gnt_1;
//-------------Input ports Data Type-------------------
wire    clock,reset,req_0,req_1;
//-------------Output Ports Data Type------------------
reg     gnt_0,gnt_1;
//-------------Internal Constants--------------------------
parameter SIZE = 3           ;
parameter IDLE  = 3'b001,GNT0 = 3'b010,GNT1 = 3'b100 ;//one hot encoding of states
//-------------Internal Variables(to track the above encoded states)---------------------------
reg   [SIZE-1:0]          present_state        ;// Seq part of the FSM
reg   [SIZE-1:0]          next_state   ;// combo part of FSM
//----------STATE TRANSITION i.e. finding next state------------------------
  always @ (present_state or req_0 or req_1)//combinational  block as clk is not required to find next state(see simulation initially next state will be IDLE=001)
begin : FSM_COMBO
 next_state = IDLE;
 case(present_state)//as next_state depends solely on present_state and inputs so whenever any of this change next_state changes immediately. see simulation
   IDLE : if (req_0 == 1'b1) begin //more priority to req_0
                next_state = GNT0;
              end else if (req_1 == 1'b1) begin
                next_state= GNT1;
              end else begin
                next_state = IDLE;// if req_0=0 or req_1=0 comes
              end
   GNT0 : if (req_0 == 1'b1) begin//more priority to req_0
                next_state = GNT0;
              end else begin
                next_state = IDLE;
              end
   GNT1 : if (req_1 == 1'b1) begin//more priority to req_0
                next_state = GNT1;
              end else begin
                next_state = IDLE;
              end
   default : next_state = IDLE;
  endcase
end
//----------STATE UPDATION-----------------------------
always @ (posedge clock)//active high synchronous reset
begin : FSM_SEQ
  if (reset == 1'b1) begin
    present_state <= #1 IDLE;
  end else begin
    present_state <= #1 next_state;
  end
end
//----------Output Logic-----------------------------
// for Moore machine, in output logic we check for clock because with clock, present state
//might have changed and output depends on present state for Moore machine.
always @ (posedge clock)//check for rst first and check present_state to find output
begin : OUTPUT_LOGIC
if (reset == 1'b1) begin//if reset is high then outputs are zero.
  gnt_0 <= #1 1'b0;//make both outputs to zero.
  gnt_1 <= #1 1'b0;
end
else begin
  case(present_state)//if no reset then check for present state
    IDLE : begin
                  gnt_0 <= #1 1'b0;
                  gnt_1 <= #1 1'b0;
               end
   GNT0 : begin
                   gnt_0 <= #1 1'b1;
                   gnt_1 <= #1 1'b0;
                end
   GNT1 : begin
                   gnt_0 <= #1 1'b0;
                   gnt_1 <= #1 1'b1;
                end
   default : begin
                    gnt_0 <= #1 1'b0;
                    gnt_1 <= #1 1'b0;
                  end
  endcase
end
end // End Of Block OUTPUT_LOGIC

endmodule // End of Module arbiter