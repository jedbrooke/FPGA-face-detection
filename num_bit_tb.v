module num_bit_tb (

);

    reg [7:0] signal;
    reg ones;

    wire [7:0] count;


    num_bit uut (signal,count,ones);

    integer i;
    reg[7:0] C0,C1;

    initial begin
        for (i = 0; i < 256; i=i+1) begin
            signal <= i;
            ones <= 1'b0;
            #5
            C0 <= count;

            ones <= 1'b1;
            #5;
            C1 <= count;
            #5
            $display("%b,%d,%d",i[7:0],C0,C1);

        end

        $finish;
    end

    
endmodule