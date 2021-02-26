`timescale 1ns / 1ps

/* 
*/
module face_reader #(
    parameter WIDTH = 410,
    parameter DEPTH = 361,
    parameter FILTER_SIZE = 5,
    parameter COLOR_DEPTH = 8
) (
	image_input, enable, enable_process, clk,
    image_output, finish
);
    input [COLOR_DEPTH-1:0] image_input;
    input enable, enable_process, clk;

    output reg [(COLOR_DEPTH-1):0] image_output;
    output reg finish = 1'b0;

    reg [8:0] posx, posy;

    parameter WAIT_FOR_IMAGE = 4'd0;
    parameter RECIEVE_IMAGE  = 4'd1;
    parameter WAIT_FOR_PROCESS = 4'd2;
    parameter PROCESS = 4'd3;
    parameter SEND_DATA = 4'd4;

    reg [3:0] state = WAIT_FOR_IMAGE;


    reg [COLOR_DEPTH-1:0] image [(WIDTH * DEPTH) - 1: 0];
	 
	 reg [(COLOR_DEPTH-1)*4:0] product;

    reg end_of_image;


    reg [31:0] counter;
	 
    integer win_x, win_y;
	 reg [31:0] win_val;


    always @(posedge clk) begin
        if(state == WAIT_FOR_IMAGE) begin
            if(enable) begin    
                state <= RECIEVE_IMAGE;
                posx <= 9'b0;
                posy <= 9'b0;
                end_of_image <= 1'b0;
            end
        end else if (state == RECIEVE_IMAGE) begin
            if(end_of_image) begin
                state <= WAIT_FOR_PROCESS;
            end else begin
                image[(posy * WIDTH) + posx] <= image_input;
            end
        end else if (state == WAIT_FOR_PROCESS) begin
            if(enable_process) begin
                $display("starting processing");
                state <= PROCESS;
                posx <= 9'b0;
                posy <= 9'b0;
                end_of_image <= 1'b0;
            end
            $display("waiting for enable process signal");
        end else if (state == PROCESS) begin
            if(end_of_image) begin
                $display("processing finished, sending data");
                state <= SEND_DATA;
                posx <= 9'b0;
                posy <= 9'b0;
                finish <= 1'b1;
                end_of_image <= 1'b0;
            end else begin
					// Mask the image
					if (image[(posy * WIDTH) + posx] > 100 && image[(posy * WIDTH) + posx] < 200)
						; // check for HUE to be in a certain range
				end
        end else if (state == SEND_DATA) begin
            if(end_of_image) begin
                $display("finished sending");
                state <= WAIT_FOR_IMAGE;
                finish <= 1'b0;
            end else begin
                image_output <= image[(posy * WIDTH) + posx];
            end
        end
    end

    always @(posedge clk) begin
        // increment x and y position properly
        if (state == RECIEVE_IMAGE || state == PROCESS || state == SEND_DATA) begin
            if(posx == (WIDTH - 1)) begin
                posx <= 9'b0;
                if (posy == (DEPTH - 1)) begin
                    end_of_image <= 1'b1;
                end else begin
                    posy <= posy + 1'b1;
                end
            end else begin
                posx <= posx + 1'b1;
            end
        end
    end

endmodule