`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent
// Engineer: Arthur Brown
// 
// Create Date: 03/23/2018 01:23:15 PM
// Module Name: axis_i2s2
// Description: AXI-Stream I2S controller intended for use with Pmod I2S2.
//              Generates clocks and select signals required to place each of the ICs on the Pmod I2S2 into slave mode.
//              Data is 24-bit, left aligned, shifted one serial clock right from the LRCK boundaries.
//              This module only supports 44.1KHz sample rate, and expects the frequency of axis_clk to be approx 22.591MHz.
//              At the end of each I2S frame, a 2-word packet is made available on the AXIS master interface. Further packets will be discarded
//              until the current packet is accepted by an AXIS slave.
//              Whenever a 2-word packet is received on the AXIS slave interface, it is transmitted over the I2S interface on the next frame.
//              Each packet consists of two 3-byte words, starting with left audio channel data, followed by right channel data.
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module axis_i2s2 (
    input  wire        axis_clk, // require: approx 22.591MHz
    input  wire        axis_resetn,
    
    input  wire [31:0] tx_axis_s_data,
    input  wire        tx_axis_s_valid,
    output reg         tx_axis_s_ready = 1'b0,
    input  wire        tx_axis_s_last,
    
    output wire [31:0] rx_axis_m_data,
    output reg         rx_axis_m_valid = 1'b0,
    input  wire        rx_axis_m_ready,
    output reg         rx_axis_m_last = 1'b0,
    
    output wire tx_mclk, // JA[0]
    output wire tx_lrck, // JA[1]
    output wire tx_sclk, // JA[2]
    output reg  tx_sdout, // JA[3]
    output wire rx_mclk, // JA[4]
    output wire rx_lrck, // JA[5]
    output wire rx_sclk, // JA[6]
    input  wire rx_sdin // JA[7]
);
    reg [8:0] count = 9'd0;
    localparam EOF_COUNT = 9'd455; // end of full I2S frame
    
    always@(posedge axis_clk)
        count <= count + 1;
    
    wire lrck = count[8];
    wire sclk = count[2];
    wire mclk = axis_clk;
    assign tx_lrck = lrck;
    assign tx_sclk = sclk;
    assign tx_mclk = mclk;
    assign rx_lrck = lrck;
    assign rx_sclk = sclk;
    assign rx_mclk = mclk;
    
    /* AXIS SLAVE CONTROLLER */
    reg [31:0] tx_data_l = 0;
    reg [31:0] tx_data_r = 0;
    
    always@(posedge axis_clk)
        if (axis_resetn == 1'b0)
            tx_axis_s_ready <= 1'b0;
        else if (tx_axis_s_ready == 1'b1 && tx_axis_s_valid == 1'b1 && tx_axis_s_last == 1'b1) // end of packet, cannot accept data until current one has been transmitted
            tx_axis_s_ready <= 1'b0;
        else if (count == 9'b0) // beginning of I2S frame, in order to avoid tearing, cannot accept data until frame complete
            tx_axis_s_ready <= 1'b0;
        else if (count == EOF_COUNT) // end of I2S frame, can accept data
            tx_axis_s_ready <= 1'b1;
            
    always@(posedge axis_clk)
        if (axis_resetn == 1'b0) begin
            tx_data_r <= 32'b0;
            tx_data_l <= 32'b0;
        end else if (tx_axis_s_valid == 1'b1 && tx_axis_s_ready == 1'b1)
            if (tx_axis_s_last == 1'b1)
                tx_data_r <= tx_axis_s_data;
            else
                tx_data_l <= tx_axis_s_data;
    
    /* I2S TRANSMIT SHIFT REGISTERS */
    reg [23:0] tx_data_l_shift = 24'b0;
    reg [23:0] tx_data_r_shift = 24'b0;
    
    always@(posedge axis_clk)
        if (count == 3'b000000111) begin
            tx_data_l_shift <= tx_data_l[23:0];
            tx_data_r_shift <= tx_data_r[23:0];
        end else if (count[2:0] == 3'b111 && count[7:3] >= 5'd1 && count[7:3] <= 5'd24) begin
            if (count[8] == 1'b1)
                tx_data_r_shift <= {tx_data_r_shift[22:0], 1'b0};
            else
                tx_data_l_shift <= {tx_data_l_shift[22:0], 1'b0};
        end
        
    always@(count, tx_data_l_shift, tx_data_r_shift)
        if (count[7:3] <= 5'd24 && count[7:3] >= 4'd1)
            if (count[8] == 1'b1)
                tx_sdout = tx_data_r_shift[23];
            else
                tx_sdout = tx_data_l_shift[23];
        else
            tx_sdout = 1'b0;
        
    /* SYNCHRONIZE DATA IN TO AXIS CLOCK DOMAIN */
    reg [2:0] din_sync_shift = 3'd0;
    wire din_sync = din_sync_shift[2];
    always@(posedge axis_clk)
        din_sync_shift <= {din_sync_shift[1:0], rx_sdin};
        
    /* I2S RECEIVE SHIFT REGISTERS */
    reg [23:0] rx_data_l_shift = 24'b0;
    reg [23:0] rx_data_r_shift = 24'b0;
    always@(posedge axis_clk)
        if (count[2:0] == 3'b011 && count[7:3] <= 5'd24 && count[7:3] >= 5'd1)
            if (lrck == 1'b1)
                rx_data_r_shift <= {rx_data_r_shift, din_sync};
            else
                rx_data_l_shift <= {rx_data_l_shift, din_sync};
    
    /* AXIS MASTER CONTROLLER */
    reg [31:0] rx_data_l = 32'b0;
    reg [31:0] rx_data_r = 32'b0;
    always@(posedge axis_clk)
        if (axis_resetn == 1'b0) begin
            rx_data_l <= 32'b0;
            rx_data_r <= 32'b0;
        end else if (count == EOF_COUNT && rx_axis_m_valid == 1'b0) begin
            rx_data_l <= {8'b0, rx_data_l_shift};
            rx_data_r <= {8'b0, rx_data_r_shift};
        end
        
    assign rx_axis_m_data = (rx_axis_m_last == 1'b1) ? rx_data_r : rx_data_l;
        
    always@(posedge axis_clk)
        if (axis_resetn == 1'b0)    
            rx_axis_m_valid <= 1'b0;
        else if (count == EOF_COUNT && rx_axis_m_valid == 1'b0)
            rx_axis_m_valid <= 1'b1;
        else if (rx_axis_m_valid == 1'b1 && rx_axis_m_ready == 1'b1 && rx_axis_m_last == 1'b1)
            rx_axis_m_valid <= 1'b0;
    
    always@(posedge axis_clk)
        if (axis_resetn == 1'b0)
            rx_axis_m_last <= 1'b0;
        else if (count == EOF_COUNT && rx_axis_m_valid == 1'b0)
            rx_axis_m_last <= 1'b0;
        else if (rx_axis_m_valid == 1'b1 && rx_axis_m_ready == 1'b1)
            rx_axis_m_last <= ~rx_axis_m_last;
        
        
endmodule
