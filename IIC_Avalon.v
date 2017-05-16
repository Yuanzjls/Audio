module IIC_Avalon(
	Clk_In, //Clock
	Reset, // Reset
	Avalon_Writedata,
	Avalon_Write,
	Avalon_Address,
	Conduit_IIC_Sclk,
	Conduit_IIC_Sda


);

input Clk_In;
input Reset;
output Conduit_IIC_Sclk;
inout Conduit_IIC_Sda;
input [1:0] Avalon_Address;

input Avalon_Write;
input [7:0] Avalon_Writedata;


//reg [15:0] Avalon_ReadData;
reg IIC_Clk;
reg [15:0]IIC_ClkDiv;
reg [23:0] IIC_Data;
reg [2:0] IIC_State=2;
reg IIC_Go=0;
wire IIC_End;
wire IIC_Ack;
wire [7:0] Register_Index;
reg [31:0] Register_Ram;



//	Clock Setting
parameter	CLK_Freq	=	50000000;	//	50	MHz
parameter	I2C_Freq	=	20000;		//	20	KHz
//	LUT Data Number
parameter	LUT_SIZE	=	51;
//	Audio Data Index
parameter	Dummy_DATA	=	0;
parameter	SET_LIN_L	=	1;
parameter	SET_LIN_R	=	2;
parameter	SET_HEAD_L	=	3;
parameter	SET_HEAD_R	=	4;
parameter	A_PATH_CTRL	=	5;
parameter	D_PATH_CTRL	=	6;
parameter	POWER_ON	=	7;
parameter	SET_FORMAT	=	8;
parameter	SAMPLE_CTRL	=	9;
parameter	SET_ACTIVE	=	10;
//	Video Data Index
parameter	SET_VIDEO	=	11;



always@(negedge Reset or posedge Clk_In) begin
	if (!Reset) begin
//		IIC_Clk <= 0;
//		IIC_ClkDiv <= 0;
	end
	else begin
		if (IIC_ClkDiv < (CLK_Freq / I2C_Freq)) begin
			IIC_ClkDiv <= IIC_ClkDiv + 1;
		end
		else begin
			IIC_ClkDiv <= 0;
			IIC_Clk <= ~IIC_Clk;
		end
	end
end

always@(posedge Clk_In) begin
	if (Avalon_Write == 1) begin
		if (Avalon_Address == 0) begin
			Register_Ram[7:0] <= Avalon_Writedata;
		end
		else if (Avalon_Address == 1)	begin
			Register_Ram[15:8] <= Avalon_Writedata;
		end
		else if (Avalon_Address == 2)	begin
			Register_Ram[23:16] <= Avalon_Writedata;
		end
		else if (Avalon_Address == 3) begin
			Register_Ram[31:24] <= Avalon_Writedata;
		end
	end
	if (IIC_State == 0) begin
		Register_Ram[24] = 0;
	end	
end

IIC_Control u0 (.Clk(IIC_Clk),
				.IIC_Sclk(Conduit_IIC_Sclk),
				.IIC_Sda(Conduit_IIC_Sda),
				.IIC_data(IIC_Data),//data
				.Go(IIC_Go), // flag for start
				.End(IIC_End), // flag for finish
				.Ack(IIC_Ack), // signal for AsK
				.Reset(1)
				);		
always@(negedge Reset or posedge Clk_In) begin

	if (!Reset) begin
//		IIC_State<=2;
	end

	else if (Clk_In == 1)begin	

		case(IIC_State)
		0:	begin
				IIC_Data <= Register_Ram[23:0];
				IIC_Go <= 1;
				IIC_State <= 1;
			end
		1:	begin
			if (IIC_End) begin
				if (!IIC_Ack) begin
					IIC_State <= 2;
				end
				else begin
					IIC_State<=0;
				end
				IIC_Go <= 0;					
			end				
			end
		default:	begin
			if (Register_Ram[24] == 1) begin
				IIC_State<=0;
			end
			end
		endcase
	end
end




endmodule

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

