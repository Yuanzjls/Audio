module IIC_AV_Config(
	Clk_In, //Clock
	Reset, // Reset
	IIC_Sclk,
	IIC_Sda,
	LEDR
			);
input Clk_In;
input Reset;
output IIC_Sclk;
inout IIC_Sda;
output [9:0] LEDR;

reg IIC_Clk;
reg [15:0]IIC_ClkDiv;
reg [5:0] Register_Index;
reg [23:0] IIC_Data;
reg [3:0] IIC_State;
reg IIC_Go;
wire IIC_End;
wire IIC_Ack;
reg [9:0] LEDR;

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

reg [15:0] Device_Register_Ram [LUT_SIZE];

always@(negedge Reset or posedge Clk_In) begin
	if (!Reset) begin
		IIC_Clk <= 0;
		IIC_ClkDiv <= 0;
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
IIC_Control u0 (.Clk(IIC_Clk),
				.IIC_Sclk(IIC_Sclk),
				.IIC_Sda(IIC_Sda),
				.IIC_data(IIC_Data),//data
				.Go(IIC_Go), // flag for start
				.End(IIC_End), // flag for finish
				.Ack(IIC_Ack), // signal for AsK
				.Reset(Reset)
				);		
always@(negedge Reset or posedge IIC_Clk) begin
	if (!Reset) begin
		IIC_Go <= 0;
		Register_Index <= 0;
		IIC_State <= 0;
	end
	else begin
		if (Register_Index < LUT_SIZE) begin
			case(IIC_State)
			0:	begin
//				if (Register_Index < SET_VIDEO) begin
//					IIC_Data <= { 8'h34, Device_Register_Ram[Register_Index]};
//				end
//				else begin
//					IIC_Data <= { 8'h40, Device_Register_Ram[Register_Index]};
//				end
				IIC_Data <= { 8'h34, 16'h0Cff};
				IIC_Go <= 1;
				IIC_State = 1;
				end
			1:	begin
				if (IIC_End) begin
					if (!IIC_Ack) begin
						IIC_State <= 2;
					end
					else begin
						IIC_State <= 0;
					end
					IIC_Go <= 0;					
				end				
				end
			2:	begin
				Register_Index <= Register_Index + 1;
				IIC_State <= 0;
				end
			endcase
		end
	end
end



//always begin
//	LEDR<={4'b000, Register_Index};
//	case (Register_Index)
//		SET_LIN_L	:	Device_Register_Ram[Register_Index]	<=	16'h001A;
//		SET_LIN_R	:	Device_Register_Ram[Register_Index]	<=	16'h021A;
//		SET_HEAD_L	:	Device_Register_Ram[Register_Index]	<=	16'h047B;
//		SET_HEAD_R	:	Device_Register_Ram[Register_Index]	<=	16'h067B;
//		A_PATH_CTRL	:	Device_Register_Ram[Register_Index]	<=	16'h08F8;
//		D_PATH_CTRL	:	Device_Register_Ram[Register_Index]	<=	16'h0A06;
//		POWER_ON	:		Device_Register_Ram[Register_Index]	<=	16'h0Cff;
//		SET_FORMAT	:	Device_Register_Ram[Register_Index]	<=	16'h0E01;
//		SAMPLE_CTRL	:	Device_Register_Ram[Register_Index]	<=	16'h1002;
//		SET_ACTIVE	:	Device_Register_Ram[Register_Index]	<=	16'h1201;
//	
//		default : Device_Register_Ram[Register_Index] <= 16'h0000;
//	endcase
//end


endmodule

















