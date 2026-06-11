module sccb_tb
(
	input wire clk,
	input wire key,
	output wire [7:0] rx_data,
	
    output wire scl,
    inout wire sda,
    
    output wire busy,
    output wire done,
    
    output wire xclk,
    
    output wire error,
    output wire sda_led,

	input wire pclk,
	output wire pclk_alive_led,
	
	input wire vsync,
	output wire vsync_led,

	input wire href,
	output wire href_led

);


reg [23:0] pclk_cnt = 0;

always @(posedge pclk) begin
    pclk_cnt <= pclk_cnt + 1'b1;
end

assign pclk_alive_led = pclk_cnt[23];

reg [7:0] vsync_cnt = 0;
reg [23:0] href_cnt = 0;

always @(posedge vsync) begin
    vsync_cnt <= vsync_cnt + 1'b1;
end

always @(posedge href) begin
    href_cnt <= href_cnt + 1'b1;
end

assign vsync_led = vsync_cnt[0];
assign href_led  = href_cnt[23];


wire clk_400kHz;
wire stop;
wire tmp;

assign stop = done;
assign sda_led = sda;

reg button_prev;

initial begin
	button_prev <= 0;
end

always @(posedge clk_400kHz) begin
    button_prev <= ~key; // (KEY is active-low on the DE2-70)
end

reg xclk_reg = 0;
always @(posedge clk) begin
    xclk_reg <= ~xclk_reg;
end
assign xclk = xclk_reg;

wire start_pulse = ~key & ~button_prev;

sccb_clk_gen clk_gen(
	.clk_in(clk),
	.reset(1'b0),
	.clk_out(clk_400kHz)
);

sccb_master master(
	.clk(clk_400kHz),
	.reset(1'b0),
	.start(start_pulse),
	.stop(stop),
	.rw_mode(1'b0),
	.reg_addr(8'h12),
	.tx_data(8'h80),
	.rx_data(rx_data),
	.busy(busy),
	.done(done),
	.scl(scl),
	.sda(sda),
	.ack_error(error)
);

endmodule
