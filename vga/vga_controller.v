module vga_controller
#(
	parameter H_CNT_MAX = 800,
	parameter V_CNT_MAX = 525,
	
	parameter H_SYNC_CNT = 96,
	parameter H_BACK_PORCH_CNT = 48,
	parameter H_DISPLAY_CNT = 640,
	parameter H_FRONT_PORCH_CNT = 16,
	
	parameter V_SYNC_CNT = 2,
	parameter V_BACK_PORCH_CNT = 33,
	parameter V_DISPLAY_CNT = 480,
	parameter V_FRONT_PORCH_CNT = 10
)
(
	input wire clk, // assume 25mhz
	input wire reset,
	
	output wire hs, // active low
	output wire vs, // active low
	output wire blank,
	output wire sync,
	
	output reg [9:0] h_counter,
	output reg [9:0] v_counter,
	
	output wire [9:0] h_coor,
	output wire [9:0] v_coor,
	
	output wire is_display_area
	
);

assign is_display_area =
    (h_counter >= H_SYNC_CNT + H_BACK_PORCH_CNT) &&
    (h_counter <  H_SYNC_CNT + H_BACK_PORCH_CNT + H_DISPLAY_CNT) &&
    (v_counter >= V_SYNC_CNT + V_BACK_PORCH_CNT) &&
    (v_counter <  V_SYNC_CNT + V_BACK_PORCH_CNT + V_DISPLAY_CNT);
assign hs = ~((h_counter >= 0) && (h_counter < H_SYNC_CNT));
assign vs = ~((v_counter >= 0) && (v_counter < V_SYNC_CNT));
assign blank = is_display_area;
assign sync = 1'b0;

assign h_coor = h_counter - H_SYNC_CNT - H_BACK_PORCH_CNT;
assign v_coor = v_counter - V_SYNC_CNT - V_BACK_PORCH_CNT;

always @(posedge clk) begin
	if (reset) begin
		// reset
		h_counter <= 0;
		v_counter <= 0;
		
	end else begin
		if (h_counter == H_CNT_MAX - 1) begin
			h_counter <= 0;
			if (v_counter == V_CNT_MAX - 1)
				v_counter <= 0;
			else
				v_counter <= v_counter + 1;
		end else
			h_counter <= h_counter + 1;
	end
end
endmodule

module vga_clk_gen
(
	input wire clk_in,
	input wire reset,
	
	output reg clk_out
);

// assume clk_in is 50MHz
// and we need clk_out to be 25MHz

always @(posedge clk_in) begin
	if (reset)
		clk_out <= 1'b0;
	else
		clk_out <= ~clk_out;
end

endmodule
