`default_nettype none
module MC68K(
input logic	RS232_RxData,
input logic	CLOCK_50,
input logic	Reset_L,
input logic	TraceRequest_L,
input logic	IRQ2_L,
input logic	IRQ4_L,
input logic	[9:0] SW,
output logic	RS232_TxData,
output logic	DRAM_CLK,
output logic	DRAM_CKE,
output logic	DRAM_CS_N,
output logic	DRAM_CAS_N,
output logic	DRAM_RAS_N,
output logic	DRAM_WE_N,
output logic	DRAM_UDQM,
output logic	DRAM_LDQM,
output logic	CPUClock,
output logic	Dtack_L,
output logic	RomSelect_H,
output logic	RamSelect_H,
output logic	DramRamSelect_H,
output logic	IOSelect_H,
output logic	ResetOut,
output logic	DramDtack_L,
output logic	AS_L,
output logic	UDS_L,
output logic	RW,
output logic	[31:0] AddressBus,
output logic	[15:0] DataBusIn,
output logic	[15:0] DataBusOut,
output logic	[12:0] DRAM_ADDR,
output logic	[1:0] DRAM_BA,
inout logic	[15:0] DRAM_DQ,
output logic	[6:0] HEX0,
output logic	[6:0] HEX1,
output logic	[6:0] HEX2,
output logic	[6:0] HEX3,
output logic	[6:0] HEX4,
output logic	[6:0] HEX5,
output logic	[9:0] LEDR,


// output logic [7:0] octl_out_test,


//////////// Audio //////////
input                       AUD_ADCDAT,
inout                       AUD_ADCLRCK,
inout                       AUD_BCLK,
output                      AUD_DACDAT,
inout                       AUD_DACLRCK,
output                      AUD_XCK,

//////////// I2C for Audio  //////////
output                      FPGA_I2C_SCLK,
inout                       FPGA_I2C_SDAT,

///////// ADC /////////
output              ADC_CONVST,
output             ADC_DIN,
input              ADC_DOUT,
output             ADC_SCLK,

///////// VGA /////////
output      [7:0]  VGA_B,
output             VGA_BLANK_N,
output             VGA_CLK,
output      [7:0]  VGA_G,
output             VGA_HS,
output      [7:0]  VGA_R,
output             VGA_SYNC_N,
output             VGA_VS
);

// assign octl_out_test = octl;

logic [7:0] octl;
initial begin
	octl = 8'hF2; //FF030000
end

always_ff @(posedge Clock50Mhz) begin
	if (RESET_H) begin
		octl <= 8'hF2; //FF00FF04
	end else begin
		if (CPU_Address[31:16] == 16'hFF03) begin
			octl <= CPU_DataBusOut[7:0];
		end
	end
end
logic wrencursor;
vga80x40_Altera vga80x40_Altera_1(
	.reset(RESET_H), // Looks like it is active high
	.wren(update_graphics && ~AS_L && ~LDS_L),
	.wrencolor(update_graphics && ~AS_L && ~UDS_L),
	.wrencursor(wrencursor),
	.wraddress({1'b0, CPU_Address[11:1]}),
	.wrdata(CPU_DataBusOut[7:0]),
	.wcolor(octl),
	.clk25MHz(Clock25Mhz),
	.R(VGA_R),
	.G(VGA_G),
	.B(VGA_B),
	.wcursor(CPU_DataBusOut[7:0]),
	.wcursorAddress(CPU_Address[2:1]),
	.hsync(VGA_HS), // horizontal sync
	.vsync(VGA_VS) // vertical sync
);
logic update_graphics;
assign VGA_CLK = Clock25Mhz;
assign VGA_BLANK_N = 1'b1;
assign VGA_SYNC_N = 1'b0;



logic	[31:0] Address;
logic	Clock25Mhz;
logic	Clock30Mhz;
logic	Clock50Mhz;
logic	Clock50Mhz_Inverted;
logic	[15:0] DataBusIn_Composite;
logic	[15:0] DataBusOut_Composite;
logic	[31:0] DMA_Address;
logic	DMA_AS_L;
logic	[15:0] DMA_DataOut;
logic	DMA_LDS_L;
logic	DMA_RW;
logic	DMA_UDS_L;
logic	[7:0] InPortA;
logic	[7:0] InPortB;
logic	[7:0] OutPortB;
logic	TraceException_H;
logic	Timer1_IRQ;
logic	Timer3_IRQ;
logic	Timer2_IRQ;
logic	Timer4_IRQ;
logic	Timer7_IRQ;
logic	Timer6_IRQ;
logic	Timer8_IRQ;
logic	Timer5_IRQ;
logic	CPU_AS_L;
logic	CPU_UDS_L;
logic	CPU_LDS_L;
logic	CPU_RW;
logic	[31:0] CPU_Address;
logic	[15:0] CPU_DataBusOut;
logic	BR_L;
logic	[2:0] IPL;
logic	CanBusSelect_H;
logic	CanBusDtack_L;
logic	DataBusIn_OE;
logic	Trdata_OE;
logic	TraceIRQ_L;
logic	ACIA_IRQ;
logic	OffBoardMemory_H;
logic	RESET_H;
logic	BG_L;
logic	LDS_L;

logic  ltc2308_start;
logic  ltc2308_start_raw;
logic  ltc2308_finish;
logic  [5:0] ltc2308_word_to_write_raw;
logic  [5:0] ltc2308_word_to_write;
logic  [11:0] ltc2308_parallel_data_read_by_spi_master;
logic  [1:0]dummy;




OnChipM68xxIO	b2v_inst11(
	.Clock_50Mhz(Clock50Mhz),
	.IOSelect(IOSelect_H),
	.UDS_L(UDS_L),
	.AS_L(AS_L),
	.WE_L(RW),
	.Clk(Clock25Mhz),
	.Reset_L(Reset_L),
	.RS232_RxData(RS232_RxData),
	.Address(Address),
	.DataIn(DataBusOut_Composite[15:8]),
	.ACIA_IRQ(ACIA_IRQ),
	.RS232_TxData(RS232_TxData),
	.DataOut(DataBusIn_Composite[15:8]));


assign	RESET_H =  ~Reset_L;


CPU_DMA_Mux	b2v_inst14(
	.CPU_DMA_Select(1'b1),
	.DMA_AS_L(DMA_AS_L),
	.DMA_RW(DMA_RW),
	.DMA_UDS_L(DMA_UDS_L),
	.DMA_LDS_L(DMA_LDS_L),
	.CPU_AS_L(CPU_AS_L),
	.CPU_UDS_L(CPU_UDS_L),
	.CPU_LDS_L(CPU_LDS_L),
	.CPU_RW(CPU_RW),
	.CPU_Address(CPU_Address),
	.CPU_DataBusOut(CPU_DataBusOut),
	.DMA_Address(DMA_Address),
	.DMA_DataBusOut(DMA_DataOut),
	.AS_L(AS_L),
	.UDS_L(UDS_L),
	.LDS_L(LDS_L),
	.RW(RW),
	.AddressOut(Address),
	.DataOut(DataBusOut_Composite)
);



OnChipROM16KWords	b2v_inst16(
	.RomSelect_H(RomSelect_H),
	.Clock(Clock25Mhz),
	.Address(Address[14:1]),
	.DataOut(DataBusIn_Composite));


M68000CPU	b2v_inst17(
	.Clk(Clock25Mhz),
	.Reset_L(Reset_L),
	.Dtack_L(Dtack_L),
	.BR_L(1'b1),
	.BGACK_L(1'b1),
	.DataBusIn(DataBusIn_Composite),
	.IPL(IPL),
	.AS_L(CPU_AS_L),
	.UDS_L(CPU_UDS_L),
	.LDS_L(CPU_LDS_L),
	.RW(CPU_RW),
	.BG_L(BG_L),
	.Address(CPU_Address),
	.DataBusOut(CPU_DataBusOut));

Dram	b2v_inst2(
	.WE_L(RW),
	.Clock50Mhz_Inverted(Clock50Mhz_Inverted),
	.Reset_L(Reset_L),
	.DramSelect_H(DramRamSelect_H),
	.LDS_L(LDS_L),
	.UDS_L(UDS_L),
	.AS_L(AS_L),
	.Address(Address),
	.DataIn(DataBusOut_Composite),
	.sdram_dq(DRAM_DQ),
	.sdram_cke(DRAM_CKE),
	.sdram_cs_n(DRAM_CS_N),
	.sdram_ras_n(DRAM_RAS_N),
	.sdram_cas_n(DRAM_CAS_N),
	.sdram_we_n(DRAM_WE_N),
	.DramDtack_L(DramDtack_L),
	.ResetOut_L(ResetOut),
	.DataOut(DataBusIn_Composite),
	
	.sdram_a(DRAM_ADDR),
	.sdram_ba(DRAM_BA),
	
	.sdram_dqm({DRAM_UDQM,DRAM_LDQM})
	);
               

AddressDecoder_Verilog	b2v_inst20(
	.Address(Address),
	.OnChipRomSelect_H(RomSelect_H),
	.OnChipRamSelect_H(RamSelect_H),
	.DramSelect_H(DramRamSelect_H),
	.IOSelect_H(IOSelect_H),
	.DMASelect_L(),
	.GraphicsCS_L(update_graphics),
	.OffBoardMemory_H(OffBoardMemory_H),
	.VoiceControl_H(VoiceControl_H),
	.wrencursor(wrencursor),
	.CanBusSelect_H(CanBusSelect_H));

logic VoiceDtack_L;
Dtack_Generator_Verilog	b2v_inst21(
	.AS_L(AS_L),
	.DramSelect_H(DramRamSelect_H),
	.DramDtack_L(DramDtack_L),
	.CanBusSelect_H(CanBusSelect_H),
	.CanBusDtack_L(CanBusDtack_L),
	.VoiceControl_H(VoiceControl_H),
	.VoiceDtack_L(VoiceDtack_L),
	.DtackOut_L(Dtack_L));


	logic [15:0] tr_data;
	assign tr_data = Trdata_OE ? DataBusOut_Composite : 16'bzzzz_zzzz_zzzz_zzzz;	
   assign DataBusIn_Composite = DataBusIn_OE ? tr_data : 16'bzzzz_zzzz_zzzz_zzzz;
	

InterruptPriorityEncoder	b2v_inst28(
	.IRQ7_L(1),
	.IRQ6_L(Timer1_IRQ),
	.IRQ5_L(TraceIRQ_L),
	.IRQ4_L(IRQ2_L),
	.IRQ3_L(1),
	.IRQ2_L(IRQ4_L),
	.IRQ1_L(ACIA_IRQ),
	.IPL(IPL));


TraceExceptionGenerator	b2v_inst30(
	.Clock(Clock25Mhz),
	.Reset(Reset_L),
	.AS_L(AS_L),
	.RW_L(RW),
	.SingleStep_H(TraceException_H),
	.TraceRequest_L(TraceRequest_L),
	.Address(Address),
	.TraceIRQ_L(TraceIRQ_L));

assign	Trdata_OE = RW & OffBoardMemory_H;

assign	DataBusIn_OE = ~(RW | AS_L);

OnChipRam256kbyte	b2v_inst6(
	.RamSelect_H(RamSelect_H),
	.UDS_L(UDS_L),
	.LDS_L(LDS_L),
	.WE_L(RW),
	.AS_L(AS_L),
	.Clock(Clock25Mhz),
	.Address(Address[17:1]),
	.DataIn(DataBusOut_Composite),
	.DataOut({DataBusIn_Composite[15:8],DataBusIn_Composite[7:0]}));


ClockGen	b2v_inst7(
	.refclk(CLOCK_50),
	.rst(RESET_H),
	.outclk_0(Clock25Mhz),
	.outclk_1(Clock30Mhz),
	.outclk_2(Clock50Mhz),
	.outclk_3(Clock50Mhz_Inverted)
	);


OnChipIO	b2v_inst8(
	.IOSelect(IOSelect_H),
	.WE_L(RW),
	.UDS_L(UDS_L),
	.AS_L(AS_L),
	.Clk(Clock25Mhz),
	.Reset_L(Reset_L),
	.Address(Address),
	.DataIn(DataBusOut_Composite[15:8]),
	.InPortA(InPortA),
	.InPortB(InPortB),
	.InPortC(),
	.InPortD(),
	.TraceExceptionBit_H(TraceException_H),
	.LCD_RS(),
	.LCD_E(),
	.LCD_RW(),
	.Timer1_IRQ(Timer1_IRQ),
	.Timer2_IRQ(Timer2_IRQ),
	.Timer3_IRQ(Timer3_IRQ),
	.Timer4_IRQ(Timer4_IRQ),
	.Timer5_IRQ(Timer5_IRQ),
	.Timer6_IRQ(Timer6_IRQ),
	.Timer7_IRQ(Timer7_IRQ),
	.Timer8_IRQ(Timer8_IRQ),
	.DataOut(DataBusIn_Composite[15:8]),
	.HexDisplay0(HEX0),
	.HexDisplay1(HEX1),
	.HexDisplay2(HEX2),
	.HexDisplay3(HEX3),
	.HexDisplay4(HEX4),
	.HexDisplay5(HEX5),	
	.LCD_DataOut(/*LCD_Data*/),
	.OutPortA(),
	.OutPortB(),
	.OutPortC()	
	);



assign	DRAM_CLK = Clock50Mhz;
assign	CPUClock = Clock25Mhz;
assign	AddressBus = Address;
assign	DataBusIn = DataBusIn_Composite;
assign	DataBusOut = DataBusOut_Composite;
assign	InPortA[7:0] = SW[7:0];
assign	InPortB[1] = SW[9];

logic [7:0] phoneme_sel;
logic phoneme_speech_busy  ;
logic phoneme_speech_finish;
logic start_phoneme_output;
logic VoiceControl_H;


// speech_synthesizer_wrapper 
// speech_synthesizer_inst
// (
// .clk(Clock50Mhz),
// .rst(1'b0), //active high
// .phoneme_speech_busy  (phoneme_speech_busy                 ),
// .phoneme_speech_finish(phoneme_speech_finish               ),
// .phoneme_sel          (phoneme_sel          ),
// .start_phoneme_output (start_phoneme_output )
// );
Speech_Controller speech(
	.rst(Reset_L),
	.clk(Clock50Mhz),
	.phoneme_speech_finish(phoneme_speech_finish),
	.phoneme_speech_busy(phoneme_speech_busy),
	.VoiceControl_H(VoiceControl_H),
	.data(DataBusOut_Composite[15:0]),
	.phoneme_sel(phoneme_sel),
	.start_phoneme_output(start_phoneme_output),
	.VoiceDtack_L(VoiceDtack_L)
	);


 

speech_subsystem
speech_subsystem_inst(

    //////////// CLOCK //////////
    .CLOCK_50(Clock50Mhz),

    //////////// LED //////////
    .LEDR(LEDR),

    //////////// Audio //////////
    .AUD_ADCDAT(AUD_ADCDAT),
    .AUD_ADCLRCK(AUD_ADCLRCK),
    .AUD_BCLK(AUD_BCLK),
    .AUD_DACDAT(AUD_DACDAT),
    .AUD_DACLRCK(AUD_DACLRCK),
    .AUD_XCK(AUD_XCK),

    //////// PS2 //////////
    .phoneme_speech_busy(phoneme_speech_busy),  
	.phoneme_speech_finish(1'b1),
	.phoneme_sel(phoneme_sel),          
	.start_phoneme_output(start_phoneme_output)	
);

I2C_AV_Config 
I2C_Configure_Audio_Chip(	
//	Host Side
  .iCLK(Clock50Mhz),
  .iRST_N(1'b1),
//	I2C Side
  .I2C_SDAT(FPGA_I2C_SDAT), // I2C Data
  .I2C_SCLK(FPGA_I2C_SCLK) // I2C Clock
);


endmodule
//`default_nettype logic