module tmds_tb (
    clk,
    data_enable,
    r_in, g_in, b_in, control_in_r, control_in_g, control_in_b,
    r_out,g_out,b_out,control_out_r,control_out_g,control_out_b 
);
    input clk;
    
    // still not really sure where the data_enable signal is coming from on the recieving end
    // on the sending end it corresponds to the time not during the blanking interval or control period of the scan
    input data_enable;

    input[7:0] r_in,g_in,b_in;
    
    // I'm not really sure what the control signal is for yet
    input[1:0] control_in_r, control_in_g, control_in_b; 

    output [7:0] r_out,g_out,b_out;
    output [1:0] control_out_r,control_out_g,control_out_b;

    wire [9:0] tmds_r, tmds_g, tmds_b;

    wire [7:0] count_r,count_g,count_b;

    // encode the signal, then deocde it with the decoder module
    // if it deocdes successfuly then it probably works, and we can test with other encoder/decoder pairs from github
    TMDS_encode encoder_r (data_enable,r_in,control_in_r,count_r,tmds_r,count_r,clk);
    TMDS_encode encoder_g (data_enable,g_in,control_in_g,count_g,tmds_g,count_g,clk);
    TMDS_encode encoder_b (data_enable,b_in,control_in_b,count_b,tmds_b,count_b,clk);

    TMDS_decode decoder_r (data_enable,tmds_r,r_out,control_out_r,clk);
    TMDS_decode decoder_g (data_enable,tmds_g,g_out,control_out_g,clk);
    TMDS_decode decoder_b (data_enable,tmds_b,b_out,control_out_b,clk);

endmodule