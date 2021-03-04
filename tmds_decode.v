module TMDS_decode (
    data_enable,tmds_in,data_out,control,clk
);
    parameter CTRL_00 = 10'b1101010100;
    parameter CTRL_01 = 10'b0010101011;
    parameter CTRL_10 = 10'b0101010100;
    parameter CTRL_11 = 10'b1010101011;

    input [9:0] tmds_in; //D
    input data_enable; //DE
    output reg [7:0] data_out; //Q
    output reg [1:0] control; //C

    input clk;

    wire [7:0] working_d = tmds_in[9] ? ~tmds_in[7:0] : tmds_in[7:0];

    genvar i;
    generate
        always @(posedge clk) begin
            if(data_enable) data_out[0] <= working_d[0];
        end
        for (i = 1; i < 8; i = i + 1) begin
            always @(posedge clk) begin
                if(data_enable) begin
                    if(tmds_in[9]) data_out[i] <= working_d[i] ^ working_d[i - 1];
                    else data_out[i] <= working_d[i] ~^ working_d[i - 1];
                end
            end
        end
    endgenerate 

    always @(posedge clk) begin
        if(~data_enable) begin     
            case (tmds_in)
                CTRL_00: control <= 2'b00;
                CTRL_01: control <= 2'b01;
                CTRL_10: control <= 2'b10;
                CTRL_11: control <= 2'b11;
                default: control <= 00;
            endcase
        end
    end
    
endmodule