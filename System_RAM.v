//Antonio Sánchez
//Memoria del sistema
//h0000 - h0FFF 	ROM Bios
//h0900 - h0FFF	8x8 Font

`define 	Rom_Size		15'h1000
`define	Font_Pos		(`Rom_Size)-15'h0700

module System_RAM(
	input [14:0] Add,
	input [7:0] In_Data,
	output reg[7:0] Out_Data,
	input	we,
	input	clk);

reg [7:0] RAM [0:32767];

initial begin
 $readmemh("ROM_BIOS.txt", RAM, 0);
 $readmemh("ROM_Fonts.txt", RAM, `Font_Pos);
 $readmemh("FillScreen.txt", RAM,`Rom_Size);
end

wire write_enable = (we && Add>=`Rom_Size);

always @(posedge clk) begin
 if (write_enable)
   RAM[Add]<=In_Data;
 Out_Data<=RAM[Add];
end
	
endmodule


