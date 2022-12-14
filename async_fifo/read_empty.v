module read_empty
    #(
        parameter DATAIN_WIDTH   = 10'd8,
        parameter DATAOUT_WIDTH  = 10'd16,
        parameter FIFO_DEPTH_BIT = 10'd5
    )
    (
        input                           r_clk,
        input                           r_rst,
        input                           r_en,
        input   [FIFO_DEPTH_BIT:0]      write_addr_gray_sync,

        output                          flag_empty,
        output  [FIFO_DEPTH_BIT-1:0]    read_addr,
        output  [FIFO_DEPTH_BIT:0]      read_addr_gray
    );

    parameter   MUL_FACTOR  =   DATAOUT_WIDTH/DATAIN_WIDTH;
    parameter   DIV_FACTOR  =   DATAIN_WIDTH/DATAOUT_WIDTH;

    //扩展一位，作为空满判断的依据
    reg [FIFO_DEPTH_BIT:0]  read_addr_bit;
    //count计数，用来判断当输出位宽减半时，是否已读完
    reg [FIFO_DEPTH_BIT]    count;

    always @(posedge r_clk or posedge r_rst) begin
        if(r_rst) begin
            count           <=  0;
            read_addr_bit   <=  0;
        end
        else if(r_en && (!flag_empty)) begin    //可读条件
            if(MUL_FACTOR   ==  5'd2)           //输入与输出位宽不同，输出位宽扩展
                read_addr_bit   <=  read_addr_bit + 5'd2;
            else if(DIV_FACTOR  ==  5'd2) begin //输出与输出位宽不同，输出位宽缩减
                if(count == 1)
                    read_addr_bit = read_addr_bit + 1'd1;
                else                           
                    read_addr_bit   <=  read_addr_bit;
                count <= (count == 1) ? 0 : 1;
            end
            else                                 //输入输出位宽
                read_addr_bit   <=  read_addr_bit + 1;
        end
        else 
            read_addr_bit   <=  read_addr_bit;  //不满足读取操作
    end

    assign  read_addr_gray  =   (read_addr_bit >> 1) ^ read_addr_bit;
    assign  flag_empty      =   (read_addr_gray == write_addr_gray_sync);
    assign  read_addr       =   read_addr_bit[FIFO_DEPTH_BIT-1:0];

endmodule