module centroid #(
    parameter DATA_WIDTH = 8,
    parameter INTERNAL_WIDTH = 32
) (
    data_in_x, data_in_y, data_enable, data_end, centroid_x, centroid_y, done, clk
);
    input [DATA_WIDTH-1:0] data_in_x, data_in_y;
    input data_enable, data_end;

    output reg [DATA_WIDTH-1:0] centroid_x, centroid_y;
    output done;

    input clk;


    reg [INTERNAL_WIDTH-1:0] sum_x;
    reg [INTERNAL_WIDTH-1:0] sum_y;
    reg [INTERNAL_WIDTH-1:0] counter;

    parameter WAIT_DATA = 4'd0;
    parameter RECV_DATA = 4'd1;
    parameter DIV_DATA = 4'd2;
    
    reg [3:0] state = WAIT_DATA;

    always @(posedge clk) begin
        if(state == WAIT_DATA) begin
            if (data_enable) begin
                done <= 1'b0;
                state <= RECV_DATA;
                counter <= 0;
            end
        end else if (state == RECV_DATA) begin
            if(data_end) begin
                state <= DIV_DATA;
            end
            if(data_enable) begin
                counter <= counter + 1;
                sum_x <= sum_x + data_in_x;
                sum_y <= sum_y + data_in_y;
            end
        end else if (state == DIV_DATA) begin
            // implementing with division operator for now, but will probably upgrade to Goldshmidt
            // or perhaps something that would take more than one cycle
            centroid_x <= sum_x / counter;
            centroid_y <= sum_y / counter;
            done <= 1'b1;
            state <= WAIT_DATA;
        end
    end
    
endmodule