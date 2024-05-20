
module addlist_tb;
  timeunit 10ns; timeprecision 1ns;

  logic clk;
  logic rst = 0;

  parameter BUF_SIZE = 4;
  
  integer test_sum = 'b1000110111100110111101111101000; // 31165.953799999992
  logic[31:0] source_data [$] = {'b1000100111100011011010010001010, 'b1000101110000011010110001011111, 'b11000101111010100011001000000100, 'b1000110000011111111101011101100, 'b11000110000010111101001111001011, 'b1000101001110111111110010011000, 'b1000101100011000110000110111000, 'b1000101110111101111000100010010, 'b1000101111001000110000001111000, 'b1000101001011010000010110010100, 'b11000101101010111001011010101010, 'b1000101101110000000001110100010, 'b11000100001100111001011101001111, 'b1000110000010110000101100001110, 'b1000101100000111001100011010011, 'b11000101111000100010001101110011};

  logic[31:0] tmp_buffer[BUF_SIZE-1:0];
  logic[2:0] buffer_ptr = 0;

  logic data_provided;
  logic data_requested;
  logic result_available;
  logic[31:0] result;
  addlist adder(
    clk,
    rst,
    tmp_buffer,
    data_provided,
    data_requested,
    result_available,
    result
  );

  always @(posedge clk) begin
    if(data_requested) begin
      if (source_data.size() == 0) begin
        data_provided = 0;
        // check if last batch was processed, and no data left in buffer
        if(result_available) begin
          $display("TEST RESULTS:");
          $display(
            "Sum = 0b%b; sign=%d exp=%d frac=%d", 
            result, result >> 31, result >> 23, result & 'h7fffff
          );
          $display(
            "Real sum = 0b%b; sign=%d exp=%d frac=%d", 
            test_sum, test_sum >> 31, test_sum >> 23, test_sum & 'h7fffff
          );
          $finish;
        end

      end else begin
        
        // push data to buffer by value in one cycle
        if(buffer_ptr <= (BUF_SIZE-1)) begin
          tmp_buffer[buffer_ptr[1:0]] = source_data.pop_front();   
          buffer_ptr = buffer_ptr + 1;
        end else begin
          buffer_ptr = 0;
          data_provided = 0;
        end

        // mark that buffer filled
        if(buffer_ptr == BUF_SIZE) begin
          data_provided = 1;
        end
        
      end

    end
  end

  initial begin
    #100000 $finish;
  end

  always begin
    #1 clk = ~clk;
  end

  initial begin
    $dumpfile("trace.vcd");
    $dumpvars();
  end

endmodule
