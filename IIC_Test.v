module IIC_Test
(Clk_In,
Conduit_IIC_Sclk,
Conduit_IIC_Sda,
Reset,
LEDR);

input Clk_In;
output Conduit_IIC_Sclk;
inout Conduit_IIC_Sda;
input Reset;
output [9:0] LEDR;

reg Clk_trans;
reg [32:0]clk_div;
reg [5:0] Reg_state=0;
reg [7:0] Avalon_Writedata;
reg Avalon_Write;
reg [9:0] LEDR;
reg [1:0] Address;

always@(posedge Clk_In) begin
	if (clk_div < 5000000) begin
		clk_div <= clk_div + 1;		
	end
	else begin
		Clk_trans <= ~Clk_trans;
		clk_div <= 0;
	end
end

IIC_Avalon u3 (.Clk_In(Clk_In),
			.Avalon_Writedata(Avalon_Writedata),
			.Avalon_Write(Avalon_Write),
			.Conduit_IIC_Sclk(Conduit_IIC_Sclk),
			.Conduit_IIC_Sda(Conduit_IIC_Sda),
			.Avalon_Address(Address),
			.Reset(Reset));

always@(posedge Clk_trans) begin
	case (Reg_state)
	
	0: begin Avalon_Write <= 1; Reg_state<=Reg_state+1; Avalon_Writedata <= 8'hff; Address <= 0;end
//	Avalon_Writedata <= {8'd0,24'h34001A}; 
	1: begin Reg_state<=Reg_state+1; Avalon_Writedata <= 8'h0c; Address <= 1;end
	2: begin Reg_state<=Reg_state+1; Avalon_Writedata <= 8'h34; Address <= 2; end
	3: begin Reg_state<=Reg_state+1; Avalon_Writedata <= 8'h01; Address <= 3; end
	4: begin Avalon_Write <= 0; Reg_state<=Reg_state+1;end
	
	
//	2: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h34021A};end
//	3: begin Avalon_Write <= 1; Reg_state<=Reg_state+1; end
//	4: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h34047B};end
//	5: begin Avalon_Write <= 1; Reg_state<=Reg_state+1; end
//	6: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h34067B}; end
//	7: begin Avalon_Write <= 1; Reg_state<=Reg_state+1; end
//	8: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h3408F8};end
//	9: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
//	10: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h340A06};end
//	11: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
//	12: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h340Cff};end
//	13: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
//	14: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h340E01};end
//	15: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
//	16: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h341002};end
//	17: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
//	18: begin Avalon_Write <= 0; Reg_state<=Reg_state+1; Avalon_Writedata <= {8'd0,24'h341201};end
//	19: begin Avalon_Write <= 1;  Reg_state<=Reg_state+1; end
	endcase

	LEDR <= {4'd0, Reg_state};
end

endmodule 