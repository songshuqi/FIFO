module write_full
    #(
        parameter   FIFO_DEPTH_BIT  =   10'd5
    )
    (
        input                           w_clk,
        input                           w_rst,
        input                           w_en,
        input   [FIFO_DEPTH_BIT:0]      read_addr_gray_sync,

        output                          flag_full,
        output  [FIFO_DEPTH_BIT-1:0]    write_addr,
        output  [FIFO_DEPTH_BIT:0]      write_addr_gray
    );

    //扩展一位写地址，高位用于判断FIFO的满状态
    reg [FIFO_DEPTH_BIT:0]  write_addr_bit;


    always @(posedge w_clk or posedge w_rst) begin
        if(w_rst) 
            write_addr_bit  <=  0;
        else if(w_en && (!flag_full))
            write_addr_bit  <=  write_addr_bit + 1;
        else 
            write_addr_bit  <=  write_addr_bit;
    end
    //将写地址转变成格雷码
    assign write_addr_gray  =   (write_addr_bit >> 1) ^ write_addr_bit;
    //判断满信号，写、读的高位与次高位相反，其余相同，说明已满
    assign  flag_full       =   (write_addr_gray == {~read_addr_gray_sync[FIFO_DEPTH_BIT],~read_addr_gray_sync[FIFO_DEPTH_BIT-1],read_addr_gray_sync[FIFO_DEPTH_BIT-2:0]});
    //将宽位信号变成写信号
    assign  write_addr      =   write_addr_bit[FIFO_DEPTH_BIT-1:0];

endmodule