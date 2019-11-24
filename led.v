module led(
input clk,
input rst,
input [2:0]led_mode,//1:����  2��ÿ0.2�� ����һ�� 3��pwm ������
output led_sgn
);
reg led_sgn_r ;
assign led_sgn = led_sgn_r ;
wire huxi_sgn;


huxideng u_huxideng
(
	.clk	(clk),
	.rst	(rst),
	.led	(huxi_sgn)
);
reg [25:0] cnt; //---------------------------0.2���ʱ
always @(posedge clk) begin 	
	if(!rst) cnt <= 0 ;
	else if (cnt == 4_800_000)
		cnt <= 0 ;
	else 
		cnt <= cnt + 1;
end 

reg [25:0] cntt; // ------------------------0.1���ʱ��
always @(posedge clk) begin 	
	if(!rst) cntt <= 0 ;
	else if (cntt == 2_400_000)
		cntt <= 0 ;
	else 
		cntt <= cntt + 1;
end 


always @(posedge clk ) begin //----------------��ͬģʽ�����ͬ��led_sgn_r
	if(led_mode == 1) 
		led_sgn_r <= 1;
	else if(led_mode == 0) begin 
		led_sgn_r <= 0;
	end 
	else if(led_mode == 2) begin 
		if(cntt == 2_400_000)
			led_sgn_r <= !led_sgn_r ;
		else 
			led_sgn_r <= led_sgn_r ;
	end 
	else if(led_mode == 3) begin 
		led_sgn_r <= huxi_sgn ;
	end 
end 


 


endmodule
