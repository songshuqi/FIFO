module ram
    #(
        parameter   DATAIN_WIDTH    =   10'd8,
        parameter   DATAOUT_WIDTH   =   10'd16,
        parameter   FIFO_WIDTH      =   10'd8,
        parameter   FIFO_WIDTH_BIT  =   10'd3,
        parameter   FIFO_DEPTH      =   10'd32,
        parameter   FIFO_DEPTH_BIT  =   10'd5
    )
    (
        input                           w_clk,r_clk,
        input                           w_rst,r_rst,
        input                           w_en,r_en,
        input                           flag_full,flag_empty,
        input   [FIFO_DEPTH_BIT-1:0]    write_addr, 
        input   [FIFO_DEPTH_BIT-1:0]    read_addr,
        input   [DATAIN_WIDTH-1:0]      data_write,

        output  reg [DATAOUT_WIDTH-1:0] data_read
    );

    parameter   MUL_FACTOR  =   DATAOUT_WIDTH/DATAIN_WIDTH; //  2
    parameter   DIV_FACTOR  =   DATAIN_WIDTH/DATAOUT_WIDTH; //  0.5

    reg [FIFO_WIDTH-1:0]    mem [FIFO_DEPTH-1:0];           //位宽8，深度32
    reg [DATAIN_WIDTH-1:0]  data_read_temp;
    reg [FIFO_DEPTH_BIT:0]    index,count;

    //RAM的初始化+数据写入
    always @(posedge w_clk or posedge w_rst) begin 
        if(w_rst) begin
            for(index = 0;index < FIFO_DEPTH;index = index + 1)begin
                mem[index] <=   0;
            end
        end
        else if(w_en && (!flag_full))  //可写条件
            mem[write_addr] <=  data_write;
        else ;
    end

    //数据读取
    always @(posedge r_clk or posedge r_rst) begin
        if(r_en && (!flag_empty)) begin    //可读条件
            if(MUL_FACTOR == 5'd2) begin   //输出位宽扩大2倍
                data_read <=    {mem[read_addr+1],mem[read_addr]};
            end
            else if(DIV_FACTOR == 5'd2) begin    //输出位宽缩小2倍
                data_read_temp  <=  mem[read_addr];
                if(count == 0) 
                    data_read   <=  data_read_temp[DATAIN_WIDTH-1:DATAIN_WIDTH/2];  //先读高位
                else 
                    data_read   <=  data_read_temp[(DATAIN_WIDTH/2-1):0];           //在读低位
            end
            else 
                data_read   <=  mem[read_addr];
        end
        else ;
    end

endmodule