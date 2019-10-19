// Video driver for XERA4
// 320x200x4 bits
// http://tinyvga.com/vga-timing/640x480@60Hz
// Antonio Sánchez

// Data for 640x480@60Hz 25.175MHz pixel clock
`define	XVisible		640
`define	XFrontPorch	16
`define	XSync			96
`define	XBackPorch	48
`define	XTotal		800
`define	YVisible		480
`define	YFrontPorch	10
`define	YSync			2
`define	YBackPorch	33
`define	YTotal		525
`define	VoidPenPos	15'h7D2F

// Video RAM map
// 0000 - 7CFF pixels
// 7D00 - 7D1F	inks
//	7D20 - 7D22	graphic window area X1-Y1
// 7D23 - 7D25 graphic window area X2-Y2
//	7D26 - 7D28	graphic window visible X1-Y1
// 7D29 - 7D2B graphic window visible X2-Y2
// 7D2C - 7D2E graphic window offset X - Y
// 7D2F void pen

module Video_Chip (
	input clk,
	output VSync,HSync,
	output [3:0] Red,
	output [3:0] Green,
	output [3:0] Blue,
	output [14:0] RAM_Add,
	input [7:0] RAM_Data);
	
reg int_clk=0;
reg [9:0] HCounter=0;
reg [9:0] VCounter=0;
reg [3:0]Pixel=0;
reg [7:0] Inks[31:0];
reg [7:0] WArea[0:5];
reg [7:0] WVisible[5:0];
reg [7:0] WOffset[2:0];

wire VisibleArea=((HCounter>`XBackPorch)&(HCounter<`XBackPorch+`XVisible)&(VCounter<10'd400))?1'h1:1'h0;
wire [8:0]PixelX=(HCounter-`XBackPorch)>>1;
wire [8:0]PixelY=(VCounter)>>1;
wire [8:0]DimmX={WArea[4],WArea[3]}-{ WArea[1],WArea[0]};
wire [8:0]DimmY=WArea[5]-WArea[2];
wire [8:0]InnerX=({WOffset[1],WOffset[0]}>(DimmX))?
						PixelX:
						(PixelX+{WOffset[1],WOffset[0]})>({ WArea[4],WArea[3]})?
						(PixelX+{WOffset[1],WOffset[0]}-DimmX)
						:(PixelX+{WOffset[1],WOffset[0]});
wire [8:0]InnerY=(WOffset[2]>DimmY)?
						PixelY:
						(PixelY+WOffset[2])>(WArea[5])?
						(PixelY+WOffset[2]-DimmY)
						:(PixelY+WOffset[2]);

assign Red=(VisibleArea)?Color[11:8]:4'h0;
assign Green=(VisibleArea)?Color[7:4]:4'h0;
assign Blue=(VisibleArea)?Color[3:0]:4'h0;

assign RAM_Add=(VCounter<10'd400)?
					(PixelX>={ WVisible[1],WVisible[0]})&&
					(PixelX<={ WVisible[4],WVisible[3]})&&
					(PixelY>={ 1'h0,WVisible[2]})&&
					(PixelY<={ 1'h0,WVisible[5]})?
					(InnerY*15'd160)+(InnerX>>1):
					(PixelX>={ WArea[1],WArea[0]})&&
					(PixelX<={ WArea[4],WArea[3]})&&
					(PixelY>={ 1'h0,WArea[2]})&&
					(PixelY<={ 1'h0,WArea[5]})?`VoidPenPos:
					(PixelY*15'd160)+(PixelX>>1):
					(VCounter<10'd448)?((VCounter-15'd400)+15'd32000):
					15'h0000;

wire [11:0]Color	= {Inks[{Pixel,1'b1}][3:0],Inks[{Pixel,1'b0}]};
assign HSync=(HCounter>(`XBackPorch+`XVisible+`XFrontPorch-1)) ?1'h0:1'h1;
assign VSync=(VCounter>(`YVisible+`YFrontPorch-1)) && (VCounter<(`YVisible+`YFrontPorch+`YSync)) ?1'h0:1'h1;

always @(posedge clk) int_clk=int_clk+1'b1;

always @(posedge int_clk) begin
	Pixel<= HCounter[1]? RAM_Data[3:0]: RAM_Data [7:4];
	if (HCounter==`XTotal-1) begin
		HCounter<=0;
		if (VCounter==`YTotal-1)
			VCounter<=0;
		else begin 
			VCounter<=VCounter+10'h1;
			if (VCounter>10'd399) begin
				if (VCounter<10'd432) Inks[VCounter-10'd400]<=RAM_Data;
				else if (VCounter<10'd438) WArea[VCounter-10'd432]<=RAM_Data;
				else if (VCounter<10'd444) WVisible[VCounter-10'd438]<=RAM_Data;
				else if (VCounter<10'd447) WOffset[VCounter-10'd444]<=RAM_Data;
			end
		end
		end
	else HCounter<=HCounter+10'h1;
end	

endmodule

