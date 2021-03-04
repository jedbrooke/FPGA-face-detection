module num_bit #(
    parameter WIDTH=8
) (
    signal,count,ones
);
    input [WIDTH-1:0] signal;
    input ones; //when high count 1's, else count 0's

    output [WIDTH-1:0] count;

    wire [WIDTH-1:0] sums [0:WIDTH]; //really it only needs to be log2(width) bits, but this is fine

    wire [WIDTH-1:0] working_signal = ones ? signal : ~signal; //if we are counting 0's, invert and count 1's

    assign sums[0] = 0;

    genvar i;
    for (i = 0; i < WIDTH; i = i + 1) begin
        assign sums[i + 1] = sums[i] + working_signal[i];
    end

    assign count = sums[WIDTH];

endmodule


module TMDS_encode (
    data_enable,data_in,control,count_in,data_out,count_out,clk
);

    parameter CTRL_00 = 10'b1101010100;
    parameter CTRL_01 = 10'b0010101011;
    parameter CTRL_10 = 10'b0101010100;
    parameter CTRL_11 = 10'b1010101011;
    
    input data_enable; //DE
    input [7:0] data_in; //D[0:7]
    input [1:0] control; //{C1,C0}
    input signed [7:0] count_in; //cnt(t-1)
    output reg [9:0] data_out; //q_out
    output reg [7:0] count_out; //cnt(t)

    input clk;

    wire [7:0] num_ones_data_in;
    num_bit count_ones_data_in(data_in,num_ones_data_in,1'b1);

    wire [7:0] data_xor;
    assign data_xor[0] = data_in[0];
    genvar i;
    for (i = 1; i < 8; i++) begin
        assign data_xor[i] = data_xor[i - 1] ^ data_in[i];
    end

    wire [7:0] data_xnor;
    assign data_xnor[0] = data_in[0];
    for (i = 1; i < 8; i++) begin
        assign data_xnor[i] = data_xnor[i - 1] ~^ data_in[i];
    end

    wire xnor_or_xor = (num_ones_data_in > 4) || (num_ones_data_in == 4 &&  data_in[0] == 1'b0); //true is xnor, false is xor
    wire [7:0] working_q = xnor_or_xor ? data_xnor : data_xor;

    

    wire [7:0] num_ones_working_q;
    num_bit count_ones_working_q(working_q, num_ones_data_in,1'b1);
    wire[7:0] num_zeros_working_q;
    num_bit count_zeros_working_q(working_q, num_ones_data_in,1'b0);

    //try to come up with more descriptive names
    wire branch1 = (count_in == 0) || (num_ones_working_q == num_zeros_working_q);
    wire branch2 = ((count_in > 0) && num_ones_working_q > num_zeros_working_q) || ((count_in < 0) && (num_zeros_working_q > num_ones_working_q));



    always @(posedge clk) begin
        if(data_enable) begin
            if(branch1) begin
                //if xnor is true, q_m[8] is 0, else it is 1
                data_out[9] <= xnor_or_xor; //~q_m[8];
                data_out[8] <= ~xnor_or_xor; //q_m[8];
                data_out[7:0] <= (~xnor_or_xor) ? working_q : ~working_q;
                
                if(xnor_or_xor) begin
                    count_out <= count_in + (num_zeros_working_q - num_ones_working_q);
                end else begin
                    count_out <= count_in + (num_zeros_working_q + num_ones_working_q);
                end
            end else begin
                data_out[9] <= 1'b1;
                data_out[8] <= ~xnor_or_xor;
                if (branch2) begin
                    data_out[7:0] <= ~working_q;
                    count_out <= count_in + (2*(~xnor_or_xor)) + (num_zeros_working_q - num_ones_working_q);
                end else begin
                    data_out[7:0] <= working_q;
                    count_out <= (2*xnor_or_xor) + (num_ones_working_q - num_zeros_working_q);
                end
            end
        end else begin
            case (control)
                2'b00: data_out <= 10'b1101010100;
                2'b01: data_out <= 10'b0010101011;
                2'b10: data_out <= 10'b0101010100;
                2'b11: data_out <= 10'b1010101011;
            endcase
        end
    end
    



    
endmodule