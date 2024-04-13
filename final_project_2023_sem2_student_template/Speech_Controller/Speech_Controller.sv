module Speech_Controller (
    input logic rst,
    clk,
    phoneme_speech_busy,
    input logic VoiceControl_H,
    // output logic sub_clk,
    input logic [15:0] data,
    output logic [7:0] phoneme_sel,
    output logic phoneme_speech_finish,
    start_phoneme_output,
    VoiceDtack_L
);

  // assign sub_clk = gotMission ? clk : 1'b0;
  enum logic [7:0] {
    Idel = 8'h00,
    BackToWork = 8'h01,
    WorkWork = 8'h02,
    YesMeLord = 8'h03
  }
      current_state, next_state;

  assign phoneme_speech_finish = (current_state == YesMeLord);
  assign start_phoneme_output  = (current_state == BackToWork);

  logic gotMission;
  // give a special address: 32'hFF00_FFFE

  always_ff @(posedge clk, posedge rst) begin
    if (rst) begin
      current_state <= Idel;
      gotMission <= 1'b0;
    end else begin
      current_state <= next_state;
      if (VoiceControl_H) gotMission <= 1'b1;
      case (current_state)
        Idel: begin

        end
        BackToWork: begin

        end
        WorkWork: begin

        end
        YesMeLord: begin
          gotMission <= 1'b0;
        end
        default: begin

        end
      endcase
    end
  end


  always_comb begin
    VoiceDtack_L = 1'b1;
    if (~gotMission) phoneme_sel = 8'h00;
    else if (data[7:0] != 0) phoneme_sel = data[7:0];
    else phoneme_sel = data[15:8];
    case (current_state)
      Idel: begin
        if (gotMission) next_state = BackToWork;
        else next_state = Idel;
      end
      BackToWork: begin
        // make sure it starts working
        if (~phoneme_speech_busy) next_state = BackToWork;
        else next_state = WorkWork;
      end
      WorkWork: begin
        // if busy, keep working
        if (~phoneme_speech_busy) next_state = YesMeLord;
        else next_state = WorkWork;
      end
      YesMeLord: begin
        if (VoiceControl_H) next_state = YesMeLord;
        else next_state = Idel;
        VoiceDtack_L = 1'b0;
      end
      default: next_state = Idel;
    endcase
  end



endmodule
