module pwm_judge(
input clk,
input rst,
input [7:0]rx_data,
input [25:0] distance1, //ǰ�ֵ�
input [25:0] distance2, //���ֵ�
output m1_1,
output m1_2,
output m2_1,
output m2_2,
output m0,
output [2:0] led_mode //�ҹ�1 ���2 ֱ��3 ����0
);
parameter  duo_initial = 60 ; //�������ǰ����ʱ��pwmռ�ձ� ��ʱ8��
parameter  safe_distance = 0 ;//����������ƶ��İ�ȫ���� 30cm
reg  [10:0]	per_duo;   ///���ռ�ձ� ��λǧ��֮�������������������Ǽٵ�
reg  [10:0]	per_dian1; /////���ռ�ձ�
reg  [10:0]	per_dian2;
reg  [2:0]  led_mode_r ;
wire [10:0]	per_duo_w;
wire [10:0]	per_dian1_w;
wire [10:0]	per_dian2_w;
assign per_duo_w   = per_duo;
assign per_dian1_w = per_dian1;
assign per_dian2_w = per_dian2;
assign led_mode    = led_mode_r;

pwm u_pwm1_1 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian1_w),
	.pwm_sgn	(m1_1)
);
pwm u_pwm1_2 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian2_w),
	.pwm_sgn	(m1_2)
);
pwm u_pwm2_1 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian1_w),
	.pwm_sgn	(m2_1)
);
pwm u_pwm2_2 
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_dian2_w),
	.pwm_sgn	(m2_2)
);
pwm  
#(
	.pwm_fre	(50)
) u_pwm0
(
	.clk_24M	(clk),
	.rst 		(rst),
	.perctg		(per_duo_w),
	.pwm_sgn	(m0)
);

reg [2:0] mode;//-------------------------------------------------ģʽ���ж�
//--------------------------7������0 �ڶ�1  ����̬ 6������1 �ƶ�0  5:ֱ��1 ����0  4��ǰ��1 ����0 /���1 �ҹ�0 
// 										  ����̬ 10000000 ֹͣ ǰ��λ1111ǰ�� 
always @(posedge clk) begin 
	if (!rx_data[7]&&!rx_data[6]&&rx_data[5]&&rx_data[4]) begin 
		mode <= 0 ; ////�ƶ�
	end 
	else if (!rx_data[7]&&rx_data[6]&&rx_data[5]&&rx_data[4]) begin 
		mode <= 1 ;	 /////ǰ��ֱ��
	end 
	else if (!rx_data[7]&&rx_data[6]&&rx_data[5]&&!rx_data[4]) begin 
		mode <= 2 ;	 /////����ֱ��
	end 
	else if (!rx_data[7] && rx_data[6] && !rx_data[5] && rx_data[4]) begin 
		mode <= 3 ; //////ǰ����ת��΢����
	end 
	else if (!rx_data[7] && rx_data[6] && !rx_data[5] && !rx_data[4]) begin 
		mode <= 4 ; //////ǰ����ת��΢����
	end  
	else if	(rx_data[7]== 1 && rx_data[6:0] == 0) begin 
		mode <= 5 ; ///////����״̬�µ�ֹ̬ͣ
	end 
	else if (rx_data[7:4] == 4'b1111 ) begin 
		mode <= 6 ; ///////����ʱ��ֱ��ǰ��״̬
	end 
	else begin 
		mode <= mode ;
	end 
end 

//-----------------------------------0.125���������ÿ����ǰ�ֽǶȸı�һ��
reg [25:0] cnt;
always @(posedge clk) begin 
	if(!rst) cnt <= 0 ;
	else if (cnt == 3_000_001)  //Ӧ�ò���Ҫ��1��
		cnt <= 0 ;
	else  
		cnt <= cnt + 1;
end 

//-------------------------- 0.5������� �ƶ�ʱת�����õ�
reg [25:0] cntt;
always @(posedge clk) begin 
	if(!rst) cntt <= 0 ;
	else if (cntt == 12_000_001)  //Ӧ�ò���Ҫ��1��
		cntt <= 0 ;
	else  
		cntt <= cntt + 1;
end 
//-----------------------------------
always @(posedge clk) begin 

	if(!rst) begin 
		per_dian1 <= 0 ;
		per_dian2 <= 0 ;
		per_duo   <= 60;
	end 	
//	else if (distance1 <safe_distance && mode != 0 && mode != 2) //���ǰ�־��ϰ���С�ڰ�ȫ���룬��ֻ�ܽ���ģʽ0 2 �����˻�ԭ��ת�����֣�
//		per_dian1 <= 0;
//	else if (distance2 <safe_distance && mode == 2 ) /////�������С�ڰ�ȫ���룬�Ͳ��ܽ���ģʽ2������ģʽ��
//		per_dian2 <= 0;
	else if (mode == 0 ) begin //---------------------�ƶ�̬
		if(rx_data[3:2] == 2'b00 ) begin //ǰ�ֲ���
			per_duo <= per_duo;
			per_dian1 <= 0 ;
			per_dian2 <= 0 ;
			led_mode_r<= 0 ;
		end 
		else if (rx_data[3:2] == 2'b10 ) begin //ǰ�����
			led_mode_r<= 2 ;
			if(per_duo <= 20) begin 
				per_duo   <= per_duo ; 
				per_dian1 <= 0 ;
				per_dian2 <= 0 ;
			end 
			else begin  
				if(cnt == 3_000_000) begin 
					per_duo   <= per_duo - rx_data[1:0];
					per_dian1 <= 0 ;
					per_dian2 <= 0 ;
				end 
			end 
		end  
		else if (rx_data[3:2] == 2'b01 )begin ///ǰ���ҹ�
			led_mode_r<= 1 ;
			if(per_duo >= 90) begin 
				per_duo <= per_duo ;
				per_dian1 <= 0 ;
				per_dian2 <= 0 ;
			end			
			else begin 
				if(cnt == 3_000_000) begin 
					per_duo   <= per_duo + rx_data[1:0];
					per_dian1 <= 0 ;
					per_dian2 <= 0 ;
				end 
			end 
		end 	
	end 
	else if (mode == 1 /*&& distance1 >= safe_distance*/) begin //ǰ��ֱ��
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		led_mode_r<= 3 ;

	end  
	else if (mode == 2 /*&& distance2 >= safe_distance*/) begin //����ֱ��
		per_dian1 <= 0 ;
		per_dian2 <= 500 + 500*rx_data[3:2]/4;
		led_mode_r<= 3 ;
	end 
	else if (mode == 3 /*&& distance1 >= safe_distance*/) begin //ǰ����ת��΢����
		led_mode_r<= 2 ;
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		if(cntt == 12_000_000) begin 
			per_duo <= per_duo - rx_data[1:0];  
		end 
	end 
	else if (mode == 4/* && distance1 >= safe_distance*/) begin //ǰ����ת��΢����
		led_mode_r<= 1 ;
		per_dian1 <= 500 + 500*rx_data[3:2]/4;
		per_dian2 <= 0 ;
		if(cntt == 12_000_000) 
			per_duo <= per_duo + rx_data[1:0];
	end
	else if (mode == 5) begin  //����ʱ��ֹ̬ͣ
		per_dian1 <= 0 ;
		per_dian2 <= 0 ;
		per_duo   <= duo_initial;
		led_mode_r<= 0 ;
	end 	  
	else if (mode == 6 /*&& distance1 >= safe_distance*/) begin  //����ʱ��ֱ��ǰ̬
		per_dian1 <= 500 + 500*rx_data[1:0]/4 ;
		per_dian2 <= 0 ;
		per_duo	  <= duo_initial ;
		led_mode_r<= 3 ;
	end 
	else begin 
		per_dian1  <= per_dian1 ; 
		per_dian2  <= per_dian2 ; 
	end 
end 
endmodule
