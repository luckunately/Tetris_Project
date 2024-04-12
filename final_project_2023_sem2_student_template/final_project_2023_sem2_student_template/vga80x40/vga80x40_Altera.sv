module vga80x40_Altera (
    input logic reset, wren, wrencolor, wrencursor,
    input logic [11:0] wraddress,
    input logic [1:0] wcursorAddress,
    input logic [7:0] wrdata, wcolor, wcursor,
    input logic clk25MHz,
    output logic [7:0] R, G, B,
    output logic hsync,
    output logic vsync
);


    // Text Buffer RAM Memory Signals, Port B (to CPU core)
    logic [7:0] ram_doB;
    logic [11:0] ram_adB;

    // Font Buffer RAM Memory Signals
    logic [11:0] rom_adB;
    logic [7:0] rom_doB, what;
    logic out_R, out_G, out_B;

    logic start;
    initial begin
        start = 1;
    end

    always_ff @(posedge clk25MHz) begin
        if (reset) begin
            start <= 1;
        end else if (wren) begin
            start <= 0;
        end
    end

    always_comb begin
        R = {out_R, out_R, out_R, out_R, out_R, out_R, out_R, out_R};
        G = {out_G, out_G, out_G, out_G, out_G, out_G, out_G, out_G};
        B = {out_B, out_B, out_B, out_B, out_B, out_B, out_B, out_B};
        if (start || ram_clor == 8'h00) 
            intoit = 8'hF2;
        else
            intoit = ram_clor; // octl[7:3]   
    end
 
    logic [7:0]intoit;
    vga80x40 vga80x40 (
        .reset(reset),
        .clk25MHz(clk25MHz),
        .R(out_R),
        .G(out_G),
        .B(out_B),
        .hsync(hsync),
        .vsync(vsync),
        .TEXT_A(ram_adB),
        .TEXT_D(ram_doB),
        .FONT_A(rom_adB),
        .FONT_D(rom_doB),
        .ocrx(mem_ocrx),
        .ocry(mem_ocry),
        .octl(intoit) // 8'b11110010
    );

    mem_init U_TEXT (
        .rdaddress(ram_adB),
        .q(ram_doB),
        .clock(clk25MHz),
        .wren(wren),
        .wraddress(wraddress),
        .data(wrdata)
    );

    logic [7:0] ram_clor;
    mem_color U_COLOR (
        .rdaddress(ram_adB),
        .q(ram_clor),
        .clock(clk25MHz),
        .wren(wrencolor),
        .wraddress(wraddress),
        .data(wcolor)
    );

    mem_font U_FONT (
        .clock(clk25MHz),
        .address(rom_adB),
        .q(rom_doB)
    );

    enum logic [1:0] {X, Y} state, next_state;
    always_ff @(posedge clk25MHz) begin
        if (reset) begin
            state <= X;
        end else begin
            state <= next_state;
        end
        case (state)
            X: begin
                mem_ocrx <= cursor_data;
            end
            Y: begin
                mem_ocry <= cursor_data;
            end
        endcase
    end
    logic [1:0] cursor_read;
    always_comb begin
        case (state)
            X: begin
                next_state = Y;
                cursor_read = 0;
            end
            Y: begin
                next_state = X;
                cursor_read = 1;
            end
            default: begin
                next_state = X;
                cursor_read = 0;
            end
        endcase
    end
    logic [7:0] cursor_data, mem_ocrx, mem_ocry, mem_octl;
    mem_cursor U_cursor(
	.clock(clk25MHz),
	.data(wcursor),
	.rdaddress(cursor_read),
    .wren(wrencursor),
    .wraddress(wcursorAddress),
    .q(cursor_data)                
);

endmodule
