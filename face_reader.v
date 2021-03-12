`timescale 1ns / 1ps

/* 
*/
module face_reader #(
    parameter WIDTH = 256,
    parameter DEPTH = 256,
    parameter FILTER_SIZE = 5,
    parameter COLOR_DEPTH = 8
) (
	image_in_R, image_in_G, image_in_B, enable, enable_process, clk,
    image_output, centroid_x, centroid_y, done, finish
);
    input [COLOR_DEPTH-1:0] image_in_R, image_in_G, image_in_B;
    input enable, enable_process, clk;

	 reg [COLOR_DEPTH-1:0] image [0:(WIDTH * DEPTH) - 1];
    output reg [COLOR_DEPTH-1:0] image_output; // single bit (black or white)
    output wire finish;
	 reg mask_finished = 1'b0;

    reg [8:0] posx, posy;

    parameter WAIT_FOR_IMAGE = 4'd0;
    parameter RECIEVE_IMAGE  = 4'd1;
    parameter WAIT_FOR_PROCESS = 4'd2;
    parameter PROCESS = 4'd3;
    parameter SEND_DATA = 4'd4;
	 parameter WAIT_FOR_CENTROID = 4'd5;

    reg [3:0] state = WAIT_FOR_IMAGE;

    reg end_of_image;
	 
	 reg isWhite;
	 output reg done;
	 wire centroid_done;
	 output [7:0] centroid_x, centroid_y;
	 //centroid find_face(posx, posy, isWhite, finish, centroid_x, centroid_y, centroid_done, clk);
	 
	 reg smooth_enable;
	 wire smoothed_output;
	 low_pass smooth_face(isWhite, smooth_enable, mask_finished, clk, centroid_x, centroid_y, centroid_done, finish, smoothed_output); // when this module finished, start processing
	 
	 /*
	 Y = (R+2G+B)/4
	U = R - G
	V = B - G 
	 */
	 //wire [COLOR_DEPTH:0] Y_sum;
	 wire [COLOR_DEPTH-1:0] Y, U, V;
	 //assign Y_sum = image_in_R + {image_in_G[COLOR_DEPTH-1], (image_in_G << 1)}, + image_in_B; // left shift with keeping the MSB to perform *2
	 assign U = image_in_R < image_in_G ? 0 : image_in_R - image_in_G; // check for underflow
	 //assign isWhite = U > 26 && U < 74;
	 //assign V = image_in_B - image_in-G; // check for underflow

    always @(posedge clk) begin
        if(state == WAIT_FOR_IMAGE) begin
            if(enable) begin    
                state <= RECIEVE_IMAGE;
                posx <= 9'b0;
                posy <= 9'b0;
                end_of_image <= 1'b0;
					 smooth_enable <= 1'b1;
            end
        end else if (state == RECIEVE_IMAGE) begin
            if(end_of_image) begin
					$display("sending");
               posx <= 9'b0;
               posy <= 9'b0;
               mask_finished <= 1'b1;
               end_of_image <= 1'b0;
					isWhite <= 1'b0;
               state <= WAIT_FOR_CENTROID;
					smooth_enable <= 1'b0;
            end else begin
                if (U > 26 && U < 74) begin
						image[(posy*WIDTH)+posx] <= 255;
						isWhite <= 1'b1;
					 end else begin
						image[(posy*WIDTH)+posx] <= 0;
						isWhite <= 1'b0;
					end
					//image[(posy*WIDTH)+posx] <= U;
            end
		  end else if (state == WAIT_FOR_CENTROID) begin
				if (finish) begin
					$display("starting to output\n");
					posx <= 9'b0;
               posy <= 9'b0;
               end_of_image <= 1'b0;
					isWhite <= 1'b0;
               state <= SEND_DATA;
					done <= 1'b1;
            end
        end else if (state == SEND_DATA) begin
				if(end_of_image) begin
                //$display("reader finished sending");
                state <= WAIT_FOR_IMAGE;
                mask_finished <= 1'b0;
					 smooth_enable <= 1'b0;
            end else begin
                //image_output <= image[(posy * WIDTH) + posx];
					 if(smoothed_output) begin
						image_output <= 8'd255;
					 end else begin
						image_output <= 8'd0;
					 end
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