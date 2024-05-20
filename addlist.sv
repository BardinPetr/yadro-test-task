module addlist(
  input logic clk,
  input logic rst,
  input logic[31:0] buffer[3:0],
  input logic data_available,
  output logic data_request,
  output logic result_available,
  output logic[31:0] sum
);

  parameter SCHEME_DEPTH = 4;

  logic[2:0] state = 0;
  logic in_progress = 0;

  logic[31:0] out_regs[2:0];
  logic[3:0] out_ready;
  logic[2:0] step_ready;
  logic[2:0] step_tick;

  add2f add2f_inst00(
    clk, step_tick[0], 
    buffer[0], buffer[1], out_regs[0], out_ready[0]
  );
  add2f add2f_inst01(
    clk, step_tick[0], 
    buffer[2], buffer[3], out_regs[1], out_ready[1]
  );
  assign step_ready[0] = &out_ready[1:0];

  add2f add2f_inst1(
    clk, step_tick[1], 
    out_regs[0], out_regs[1], out_regs[2], out_ready[2]
  );
  assign step_ready[1] = out_ready[2];

  add2f add2f_inst2(
    clk, step_tick[2], 
    sum, out_regs[2], sum, out_ready[3]
  );
  assign step_ready[2] = out_ready[3];


  always @(posedge rst) begin
    state = 0;
    in_progress = 0;
  
    out_regs = '{default:'0};
    step_tick = 0;
  end

  always @(posedge clk) begin
    if(data_available) begin
      data_request = 0;
    end

    case (state)
      0: begin
        // check if data was preloaded to buffer, or load it
        if(data_available) begin
          state = 1;
          result_available = 0;
        end else begin
          data_request = 1;
        end
      end 
      
      SCHEME_DEPTH: begin 
        result_available = 1;
        state = 0;      
      end

      default: begin
        // trigger stage according to (state-1)
        // untill stage adder didn't return value, in_progress=1
        if(in_progress) begin
          step_tick[state-1] = 0;
          if(step_ready[state-1]) begin
            in_progress = 0;
            state = state + 1;
          end
        end else begin
          step_tick[state-1] = 1;
          in_progress = 1;

          if (state == 2) begin // preload memory data
            data_request = 1;
          end
        end
      end
  
    endcase
  end


endmodule