/* 
*/
module low_pass #(
    parameter WIDTH = 256,
    parameter DEPTH = 256,
    parameter FILTER_SIZE = 5,
    parameter COLOR_DEPTH = 8
) (
	image_input, enable, enable_process, clk,
    centroid_x, centroid_y, done, image_output
);
    input image_input;
    input enable, enable_process, clk;

    reg finish = 1'b0;
	 
	 reg isWhite;
	 output [COLOR_DEPTH-1:0] centroid_x, centroid_y;
	 output reg done;
    wire centroid_done;
	 output reg image_output;
	 centroid find_face(posx, posy, isWhite, finish, centroid_x, centroid_y, centroid_done, clk);

    reg [8:0] posx, posy;

    parameter WAIT_FOR_IMAGE = 4'd0;
    parameter RECIEVE_IMAGE  = 4'd1;
    parameter WAIT_FOR_PROCESS = 4'd2;
    parameter PROCESS = 4'd3;
    parameter SEND_DATA = 4'd4;
	 parameter WAIT_FOR_CENTROID = 4'd5;
	 
    reg [3:0] state = WAIT_FOR_IMAGE;


    reg image [(WIDTH * DEPTH) - 1: 0];
	 reg output_image [(WIDTH * DEPTH) - 1: 0];
	 
	 reg [(COLOR_DEPTH-1)*4:0] product;

    reg end_of_image;


    reg [31:0] counter;
	 
	 parameter FILTER_MIDDLE_INDX = (FILTER_SIZE>>1);
    integer win_x, win_y;
	 integer window_count, bounds_count;
	 parameter WINDOW_SIZE = FILTER_SIZE*FILTER_SIZE;
	 parameter MIN_RATIO = 8'b0000_1110; // 7/8
	 reg [31:0] window_coverage;


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
                state <= WAIT_FOR_CENTROID;
                posx <= 9'b0;
                posy <= 9'b0;
                end_of_image <= 1'b0;
            end else begin
					// Convolution: all indices -1/(FILTER_SIZE * FILTER_SIZE), middle (1 - 1/FILTER_SIZE)
					window_count = 9'b0;
					bounds_count = 0;
					
					// Use extend for edges
					for (win_x = 0; win_x < FILTER_SIZE; win_x = win_x + 1)
						for (win_y = 0; win_y < FILTER_SIZE; win_y = win_y + 1)
							if (win_x + posx < FILTER_MIDDLE_INDX)
								if (win_y + posy < FILTER_MIDDLE_INDX)
									bounds_count = bounds_count + 1; // corner extend
								else if (win_y + posy > DEPTH-1)
									bounds_count = bounds_count + 1; // bottom left corner extend
								else
									bounds_count = bounds_count + 1; // left wall extend
							else if (win_x + posx > WIDTH-1)
								if (win_y + posy < FILTER_MIDDLE_INDX)
									bounds_count = bounds_count + 1; // top right corner extend
								else if (win_y + posy > DEPTH-1)
									bounds_count = bounds_count + 1; // bottom right corner extend
								else
									bounds_count = bounds_count + 1; // right wall extend
							else if (win_y + posy < FILTER_MIDDLE_INDX)
								bounds_count = bounds_count + 1; // top edge extend
							else if (win_y + posy > DEPTH-1)
								bounds_count = bounds_count + 1; // bottom edge extend
							else
								window_count = window_count + image[((win_y+posy-FILTER_MIDDLE_INDX)*WIDTH)+(win_x+posx-FILTER_MIDDLE_INDX)]; // value is 0 or 1
					
					window_coverage = ({WINDOW_SIZE - bounds_count, 4'd0}*MIN_RATIO);
					//$display("%d / %d\n", window_count, window_coverage[15:8]);
					if (window_coverage > 0 && window_count > window_coverage[15:8])
						output_image[(posy * WIDTH) + posx] <= 1;
					else
						output_image[(posy * WIDTH) + posx] <= 0;
            end
		  end else if (state == WAIT_FOR_CENTROID) begin
				if (centroid_done) begin
					$display("Centroid done");
                state <= SEND_DATA;
                posx <= 9'b0;
                posy <= 9'b0;
                end_of_image <= 1'b0;
					 done <= 1'b1;
            end else if(end_of_image) begin
                finish <= 1'b1; 
				end else begin
					//$display("white: %d\n", output_image[(posy * WIDTH) + posx]);
					isWhite <= output_image[(posy * WIDTH) + posx];
				end
        end else if (state == SEND_DATA) begin
            if(end_of_image) begin
                //$display("finished sending");
                //state <= WAIT_FOR_IMAGE;
                //finish <= 1'b0;
            end else begin
                image_output <= output_image[(posy * WIDTH) + posx];
            end
        end
    end

    always @(posedge clk) begin
        // increment x and y position properly
        if (state == RECIEVE_IMAGE || state == PROCESS || state == WAIT_FOR_CENTROID || state == SEND_DATA) begin
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