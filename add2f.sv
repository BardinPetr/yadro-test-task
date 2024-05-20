module add2f (
	input logic clk,
	input logic exec,
  input logic[31:0] op_a,
  input logic[31:0] op_b,
  output logic[31:0] result,
	output logic out_ready
);

	logic ready;

	adder adder_unit (
		.clk(clk),
		.rst(0),

		.input_a(op_a),
		.input_a_stb(exec),
		.input_a_ack(),

		.input_b(op_b),
		.input_b_stb(1),
		.input_b_ack(),

		.output_z(result),
		.output_z_stb(ready),
		.output_z_ack(1)
	);

	always @(posedge exec, posedge ready) begin
		out_ready = ~exec;
	end

endmodule