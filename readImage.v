`timescale 1ns/100ps
`define NOISY
module readImage (
);
    parameter IMG_WIDTH = 256;
    parameter IMG_HEIGHT = 256;
    parameter DEPTH = 8;

    reg [DEPTH-1:0] pixel;

    reg [8:0] posx,posy;
    reg data_ready, output_ready;
	 reg [1:0] centroid_written; // 0 - can't write yet, 1 - write next cycle, 2 - written
	 wire centroid_ready;
	 wire [7:0] output_centroid_x, output_centroid_y;


    reg [DEPTH-1:0] image_R [0:(IMG_WIDTH * IMG_HEIGHT) - 1];
	 reg [DEPTH-1:0] image_G [0:(IMG_WIDTH * IMG_HEIGHT) - 1];
	 reg [DEPTH-1:0] image_B [0:(IMG_WIDTH * IMG_HEIGHT) - 1];

    reg clk;

    reg [DEPTH-1:0] image_input [2:0];
    reg enable, enable_process;

    wire [DEPTH-1:0] image_output;
    wire finish;

    integer i, j;
    integer data_file, scan_file, out_file, centroid_file;

    `ifdef NOISY
        initial begin
            data_file = $fopen("image/face.txt","r");
            if (data_file == 0) begin
                $display("error reading file\n");
                $finish;
            end
        end
    `endif
    `ifdef CLEAN
        initial begin 
            data_file = $fopen("image/grey_image.text","r");
            if (data_file == 0) begin
                $display("error reading file\n");
                $finish;
            end
        end
    `endif

    /* change this filter here */
    face_reader filter (image_input[2], image_input[1], image_input[0], enable, enable_process, clk, image_output,
								output_centroid_x, output_centroid_y, centroid_ready, finish);
    initial begin
		out_file = $fopen("image/face_mask.text","w");
		centroid_file = $fopen("image/face_centroid.text","w");
	 end
	
    initial begin
        posx = 9'b0;
        posy = 9'b0;
        clk = 1'b0;
        data_ready = 1'b0;
        output_ready = 1'b0;
		  centroid_written = 1'b0;

        
		$display("looping\n");
        for (i = 0; i < (IMG_HEIGHT*IMG_WIDTH); i = i + 1) begin
				scan_file = $fscanf(data_file, "%d,",pixel);
				image_R[i] = pixel;
				scan_file = $fscanf(data_file, "%d,",pixel);
				image_G[i] = pixel;
				scan_file = $fscanf(data_file, "%d,",pixel);
				image_B[i] = pixel;
        end
        $fclose(data_file);
        #100;
        $display("finished reading image, sending to filter");
        i = 0;
        enable = 1'b1;
        data_ready = 1'b1;

    end



    always @(posedge clk) begin
        if(data_ready) begin
            if (i < (IMG_HEIGHT*IMG_WIDTH)) begin
                image_input[2] <= image_R[i];
					 image_input[1] <= image_G[i];
					 image_input[0] <= image_B[i];
                i <= i + 1;
            end else begin
                $display("loaded image into filter, starting processing");
                data_ready <= 1'b0;
                enable_process <= 1'b1;
            end
        end else if (output_ready) begin
            if(finish) begin
                $fwrite(out_file,"%d,",image_output);
            end else if (~finish) begin
					$fclose(out_file);
					$finish;
				end
        end else begin
            output_ready <= finish;
        end
		  //
		  if (centroid_ready && centroid_written == 2'd0) begin
			centroid_written <= 2'd1;
		  end else if (centroid_written == 2'd1) begin
			$display("centroid ready %d\n", centroid_ready);
			$fwrite(centroid_file,"%d,%d",output_centroid_x, output_centroid_y);
			$fclose(centroid_file);
			centroid_written <= 2'd2;
		  end
    end

    always #5 clk = ~clk;

endmodule