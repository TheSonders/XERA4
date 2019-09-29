
//Antonio Sánchez
module System_RAM(
	input [14:0] Add,
	input [7:0] In_Data,
	output reg[7:0] Out_Data,
	input	we,
	input	clk);
	
reg [7:0] RAM [32767:0];

initial
	$readmemh("FillScreen.txt", RAM);

always @(posedge clk) begin
	if (we) RAM[Add]<=In_Data;
	else	Out_Data<=RAM[Add]; end
	
endmodule
