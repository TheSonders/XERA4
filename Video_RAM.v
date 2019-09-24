module Video_RAM(
	input [14:0] CPU_Add,
	input [7:0] CPU_In_Data,
	output reg[7:0] CPU_Out_Data,
	input	we,
	input	clk,
	input [14:0] Video_Add,
	output reg [7:0] Video_Data);

reg [7:0] RAM [32767:0];

initial
	$readmemh("inks.txt", RAM, 32000, 32031);

always @(posedge clk) begin
	Video_Data<=RAM[Video_Add];
	if (we) RAM[CPU_Add]<=CPU_In_Data;
	else	CPU_Out_Data<=RAM[CPU_Add]; end
	
endmodule
