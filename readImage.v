`timescale 1ns/100ps
module readImage (
);
    parameter IMG_WIDTH = 410;
    parameter IMG_HEIGHT = 361;
    parameter DEPTH = 8;

    reg [DEPTH-1:0] pixel;

    reg [8:0] posx,posy;
    reg data_ready, output_ready;


    reg [DEPTH-1:0] image [0:(IMG_WIDTH * IMG_HEIGHT) - 1];

    reg clk;

    reg [DEPTH-1:0] image_input;
    reg enable, enable_process;

    wire [DEPTH-1:0] image_output;
    wire finish;

    integer i;
    integer data_file, scan_file, out_file;

    `ifdef NOISY
        initial begin
            data_file = $fopen("image/noisy_image.text","r");
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
    face_reader filter (image_input, enable, enable_process, clk, image_output, finish);
    
    initial begin
        posx = 9'b0;
        posy = 9'b0;
        clk = 1'b0;
        data_ready = 1'b0;
        output_ready = 1'b0;

        

        for (i = 0; i < (IMG_HEIGHT*IMG_WIDTH); i = i + 1) begin
            scan_file = $fscanf(data_file, "%d,",pixel);
            image[i] = pixel;
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
                image_input <= image[i];
                i <= i + 1;
            end else begin
                $display("loaded image into filter, starting processing");
                data_ready <= 1'b0;
                enable_process <= 1'b1;
            end
        end else if (output_ready) begin
            if(~finish) begin
                $fclose(out_file);
                $finish;
            end else begin
                $fwrite(out_file,"%d,",image_output);
            end

        end else begin
            output_ready <= finish;
        end
    end

    always #5 clk = ~clk;

endmodule