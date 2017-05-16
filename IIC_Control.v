module IIC_Control(
	Clk,//whole module clk
	IIC_Sclk,//output clk
	IIC_Sda,//output sda
	IIC_data,//data
	Go, // flag for start
	End, // flag for finish
	Ack, // signal for AsK
	Reset
	
);
	
	input Clk;
	output IIC_Sclk;
	inout IIC_Sda;
	input [23:0]IIC_data;
	input Go;
	output End;
	output Ack;
	input Reset;
	
	reg [5:0] Sda_Count;
	reg Ack1 = 0, Ack2 = 0, Ack3 = 0;
	reg Sclk;
	reg Sda;
	reg [23:0]Sda_Data;
	reg End = 1;
	
	wire IIC_Sclk = Sclk | ((Sda_Count >= 4 & Sda_Count <= 30) ? ~Clk:0);
	wire IIC_Sda = Sda ? 1'bz : 0;
	
	wire Ack = Ack1 | Ack2 | Ack3;
	
//IIC count	
always @(negedge Reset or posedge Clk) begin
	if (!Reset) begin
		Sda_Count <= 6'b111111;
	end
	else begin
		if (Go==0) begin
			Sda_Count <= 0;
		end
		else begin
			if (Sda_Count < 6'b111111) begin
				Sda_Count <= Sda_Count + 1;
			end
		end
	end
end

always @(negedge Reset or posedge Clk) begin
	if (!Reset) begin
		Sda <= 1;
		Sclk <= 1;
		End <= 1;
		Ack1 <= 0;
		Ack2 <= 0;
		Ack3 <= 0;
	end
	else begin
			case (Sda_Count)
			6'd0: begin  Ack1 <= 0; Ack2 <= 0; Ack3 <= 0; Sda <= 1; Sclk <= 1;End <= 0; end
			
			// Start
			6'd1: begin Sda <= 0; Sda_Data <= IIC_data; end
			6'd2: Sclk <= 0;
			
			//Slave Address
			6'd3: Sda <= Sda_Data[23];
			6'd4: Sda <= Sda_Data[22];
			6'd5: Sda <= Sda_Data[21];
			6'd6: Sda <= Sda_Data[20];
			6'd7: Sda <= Sda_Data[19];
			6'd8: Sda <= Sda_Data[18];
			6'd9: Sda <= Sda_Data[17];
			6'd10: Sda <= Sda_Data[16];
			6'd11: Sda <= 1; // Ack
			
			//Register address
			6'd12: begin Sda <= Sda_Data[15]; Ack1 <= IIC_Sda; end
			6'd13: Sda <= Sda_Data[14];
			6'd14: Sda <= Sda_Data[13];
			6'd15: Sda <= Sda_Data[12];
			6'd16: Sda <= Sda_Data[11];
			6'd17: Sda <= Sda_Data[10];
			6'd18: Sda <= Sda_Data[9];
			6'd19: Sda <= Sda_Data[8];
			6'd20: Sda <= 1;
			
			//Data
			
			6'd21: begin Sda <= Sda_Data[7]; Ack2 <= IIC_Sda; end
			6'd22: Sda <= Sda_Data[6];
			6'd23: Sda <= Sda_Data[5];
			6'd24: Sda <= Sda_Data[4];
			6'd25: Sda <= Sda_Data[3];
			6'd26: Sda <= Sda_Data[2];
			6'd27: Sda <= Sda_Data[1];
			6'd28: Sda <= Sda_Data[0];
			6'd29: Sda <= 1;
			
			
			//stop
			6'd30: begin Ack3 <= IIC_Sda; Sda <= 0; Sclk <= 0; end
			6'd31: Sclk <= 1;
			6'd32: begin Sda <= 1; End <= 1; end 
			
			
			endcase
		end
	
end



endmodule 