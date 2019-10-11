//Antonio Sánchez
//Memoria del sistema
//h0000 - h0FFF ROM Bios
//h

`define 	Rom_Size		15'h1000
`define	Font_Pos		(`Rom_Size)-15'h0700

module System_RAM(
	input [14:0] Add,
	input [7:0] In_Data,
	output reg[7:0] Out_Data,
	input	we,
	input	clk);

reg [7:0] RAM [4096:32767];
reg [7:0] ROM [0:4095];

initial begin
 $readmemh("ROM_Fonts.txt", ROM,`Font_Pos);
 $readmemh("FillScreen.txt", RAM,`Rom_Size);
end

always @(posedge clk) begin
 if (we && Add>=`Rom_Size)
   RAM[Add]<=In_Data;
 else begin
	if (Add>=`Rom_Size) Out_Data<=RAM[Add];
	else Out_Data<=ROM[Add];end
end
	
endmodule
