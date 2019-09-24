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

// Video RAM map
// 0000 - 7CFF pixels
// 7D00 - 7D1F	inks

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
wire [10:0] RamPos;

wire VisibleArea;
wire [11:0]Color;
wire [3:0]Pixel;

reg [7:0] Inks[31:0];

assign VisibleArea=((HCounter<`XVisible)&(VCounter<10'd400))?1'h1:1'h0;
assign Red=(VisibleArea)?Color[11:8]:4'h0;
assign Green=(VisibleArea)?Color[7:4]:4'h0;
assign Blue=(VisibleArea)?Color[3:0]:4'h0;

assign RAM_Add=(VCounter<10'd400)?((VCounter>>1)*15'd160)+(HCounter>>2):
					(VCounter<10'd432)?((VCounter-15'd400)+15'd32000):
					15'h0000;

assign Pixel= HCounter[1]? RAM_Data[3:0]: RAM_Data [7:4];
assign Color= {Inks[{Pixel,1'b1}][3:0],Inks[{Pixel,1'b0}]};
assign HSync=(HCounter>(`XVisible+`XFrontPorch-1)) && (HCounter<(`XVisible+`XFrontPorch+`XSync)) ?1'h0:1'h1;
assign VSync=(VCounter>(`YVisible+`YFrontPorch-1)) && (VCounter<(`YVisible+`YFrontPorch+`YSync)) ?1'h0:1'h1;

always @(posedge clk) int_clk=int_clk+1'b1;

always @(posedge int_clk) begin
	if (HCounter==`XTotal-1) begin
		HCounter<=0;
		if (VCounter==`YTotal-1) VCounter<=0;
		else begin 
			VCounter<=VCounter+10'h1;
			if ((VCounter>10'd399) && (VCounter<10'd432)) Inks[VCounter-10'd400]<=RAM_Data;
		end
		end
	else HCounter<=HCounter+10'h1;
end	

endmodule

