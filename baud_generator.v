module baud_generator(
	input clk,
	output  baud_tick
);
parameter clk_frequency = 24_000_000 ;
parameter baud = 9600;
parameter baud_cnt_width = 17; /////��������16 ��Ȼ�����Ⱥܵ�  �ٸߵ�18Ҳ���У�ֱ��ը�ˣ����Ƴ�λ���ˣ�
parameter baud_temp = (baud<<baud_cnt_width)/clk_frequency;//���Ƽ�λ���ǳ�2�ļ��η�


reg [baud_cnt_width:0] baud_cnt;//��һλ�Ƿ�Ƶ��λ��
reg baud_tick_r;

always @(posedge clk) begin 
	baud_cnt <= baud_cnt[baud_cnt_width-1:0] + baud_temp;
	baud_tick_r <= baud_cnt[baud_cnt_width];
end 

assign baud_tick = baud_tick_r;
endmodule
