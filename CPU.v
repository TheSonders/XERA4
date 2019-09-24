
//Antonio Sánchez
module XERA4_CPU(
	input clk,
	output reg [14:0] Video_Add=0,
	input [7:0] Video_In_Data,
	output reg [7:0] Video_Out_Data,
	output reg Video_we=0);

reg [11:0] int_counter=12'h0;
always @(posedge clk)int_counter<=int_counter+12'h1;

reg [8:0]Xcount=0;
reg [7:0]Ycount=0;

wire int_clk;
assign int_clk=int_counter[10];

always @(posedge int_clk)begin
	if (Video_we) Video_we<=1'h0;
	else begin
		if (Xcount==9'd319)begin
			if (Ycount<8'd199)begin
				Xcount<=9'd0;
				Ycount<=Ycount+8'd1;
			end;end 
			else begin 
				Xcount<=Xcount+9'd1;
		end
		Video_Add<=(Ycount*14'd160)+(Xcount>>1);
		Video_we<=1'h1;
		Video_Out_Data<=	(Ycount<12)?8'H00:
								(Ycount<24)?8'H11:
								(Ycount<36)?8'H22:
								(Ycount<48)?8'H33:
								(Ycount<60)?8'H44:
								(Ycount<72)?8'H55:
								(Ycount<84)?8'H66:
								(Ycount<96)?8'H77:
								(Ycount<108)?8'H88:
								(Ycount<120)?8'H99:
								(Ycount<132)?8'HAA:
								(Ycount<144)?8'HBB:
								(Ycount<156)?8'HCC:
								(Ycount<168)?8'HDD:
								(Ycount<180)?8'HEE:
								8'HFF;							
	end
end

endmodule
