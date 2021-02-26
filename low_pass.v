/* 
*/
module low_pass #(
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
	 
	 integer FILTER_MIDDLE_INDX = (FILTER_SIZE>>1);
	 reg [7:0] FILTER_MIDDLE = 8'b11100000; // 7/8 //(1 - (1/(FILTER_SIZE*FILTER_SIZE)));
	 reg [7:0] FILTER_OTHER = 8'b00001011; // fractional component 1/8 //(-1/(FILTER_SIZE * FILTER_SIZE)); // 3: 8'b00011110

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
					// Convolution: all indices -1/(FILTER_SIZE * FILTER_SIZE), middle (1 - 1/FILTER_SIZE)
					win_val = 9'b0;
					
					// Use extend for edges
					for (win_x = 0; win_x < FILTER_SIZE; win_x = win_x + 1)
						for (win_y = 0; win_y < FILTER_SIZE; win_y = win_y + 1)
							if (win_x == FILTER_MIDDLE_INDX && win_y == FILTER_MIDDLE_INDX)
								;
							else
								if (win_x + posx < FILTER_MIDDLE_INDX)
									if (win_y + posy < FILTER_MIDDLE_INDX)
										win_val = win_val + FILTER_OTHER * {image[0], 8'd0}; // corner extend
									else if (win_y + posy > DEPTH-1)
										win_val = win_val + FILTER_OTHER * {image[((DEPTH-1)*WIDTH)+0], 8'd0}; // bottom left corner extend
									else
										win_val = win_val + FILTER_OTHER * {image[((win_y+posy-FILTER_MIDDLE_INDX)*WIDTH)+0], 8'd0}; // left wall extend
								else if (win_x + posx > WIDTH-1)
									if (win_y + posy < FILTER_MIDDLE_INDX)
										win_val = win_val + FILTER_OTHER * {image[WIDTH-1], 8'd0}; // top right corner extend
									else if (win_y + posy > DEPTH-1)
										win_val = win_val + FILTER_OTHER * {image[(DEPTH*WIDTH) - 1], 8'd0}; // bottom right corner extend
									else
										win_val = win_val + FILTER_OTHER * {image[((win_y+posy-FILTER_MIDDLE_INDX)*WIDTH)+(WIDTH-1)], 8'd0}; // right wall extend
								else if (win_y + posy < FILTER_MIDDLE_INDX)
									win_val = win_val + FILTER_OTHER * {image[(win_x+posx-FILTER_MIDDLE_INDX)], 8'd0}; // top edge extend
								else if (win_y + posy > DEPTH-1)
									win_val = win_val + FILTER_OTHER * {image[((DEPTH-1)*WIDTH) + (win_x+posx-FILTER_MIDDLE_INDX)], 8'd0}; // bottom edge extend
								else
									win_val = win_val + FILTER_OTHER * {image[((win_y+posy-FILTER_MIDDLE_INDX)*WIDTH)+(win_x+posx-FILTER_MIDDLE_INDX)], 8'd0}; // regular symmetric convolution
					
					win_val = FILTER_OTHER * {image[((posy)*WIDTH)+(posx)], 8'd0} + win_val;
					image[(posy * WIDTH) + posx] <= image[(posy * WIDTH) + posx] - win_val[23:16]; // integer component (bottom 16 is fractional)
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