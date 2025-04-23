`timescale 1ns / 1ps

module SPI_transmission_tb;


    reg clk;
    reg reset_n;
    

    wire miso_wire; 
    wire mosi_wire; 
    wire sck_wire;  
    wire ss_wire;   
    
    // Bus interface signals for SPI_0 (Master)
    reg [5:0] io_addr_0;
    reg iore_0;
    reg iowe_0;
    reg [11:0] ram_addr_0;
    reg ramre_0;
    reg ramwe_0;
    reg [7:0] dbus_in_0;
    wire [7:0] dbus_out_0;
    wire out_en_0;
    
    // Bus interface signals for SPI_1 (Slave)
    reg [11:0] ram_addr_1;
    reg ramre_1;
    reg ramwe_1;
    reg [7:0] dbus_in_1;
    wire [7:0] dbus_out_1;
    wire out_en_1;
    
    // IRQ signals
    wire spi_irq_0, spi_irq_1;
    reg [5:0] irqack_addr;
    reg irqack;
    

    reg [7:0] tx_data [0:2];  // Array for 3 bytes of data
    reg [7:0] rx_data [0:2];  // Array for received data
    
    // register addresses
    localparam [5:0] SPCR0_ADDR = 6'h2C;
    localparam [5:0] SPSR0_ADDR = 6'h2D;
    localparam [5:0] SPDR0_ADDR = 6'h2E;
    localparam [5:0] SPI0_IRQ_ADDR = 6'h11;
    
    // register addresses
    localparam [11:0] SPCR1_ADDR = 12'h0AC;
    localparam [11:0] SPSR1_ADDR = 12'h0AD;
    localparam [11:0] SPDR1_ADDR = 12'h0AE;
    localparam [5:0]  SPI1_IRQ_ADDR = 6'h27;


    SPI_0 #(
        .SPCRn_Address(SPCR0_ADDR),
        .SPSRn_Address(SPSR0_ADDR),
        .SPDRn_Address(SPDR0_ADDR),
        .SpiIRQ_Address(SPI0_IRQ_ADDR)
    ) spi_master (
        .ireset(reset_n),
        .cp2(clk),
        .IO_Addr(io_addr_0),
        .iore(iore_0),
        .iowe(iowe_0),
        .ram_Addr(ram_addr_0),
        .ramre(ramre_0),
        .ramwe(ramwe_0),
        .out_en(out_en_0),
        .dbus_in(dbus_in_0),
        .dbus_out(dbus_out_0),
        .NVM_iore(1'b0),
        .NVM_iowe(1'b0),
        .SpiCRn(1'b0),
        .SpiSRn(1'b0),
        .SpiDRn(1'b0),
        .Disable_ireset(1'b0),
        .NVM_dbus_out(),
        .miso_i(miso_wire),
        .mosi_i(1'b1),       // Not used in master mode
        .sck_i(1'b1),        // Not used in master mode
        .ss_i(1'b1),         // Pull high to avoid slave mode
        .ss_o(ss_wire),
        .miso_o(),           // Not used in master mode
        .mosi_o(mosi_wire),
        .sck_o(sck_wire),
        .SpiIRQ(spi_irq_0),
        .irqack_addr(irqack_addr),
        .irqack(irqack),
        .SPE0(),
        .MSTR0()
    );


    SPI_1 #(
        .SPCRn_Address(SPCR1_ADDR),
        .SPSRn_Address(SPSR1_ADDR),
        .SPDRn_Address(SPDR1_ADDR),
        .SpiIRQ_Address(SPI1_IRQ_ADDR)
    ) spi_slave (
        .ireset(reset_n),
        .cp2(clk),
        .ram_Addr(ram_addr_1),
        .ramre(ramre_1),
        .ramwe(ramwe_1),
        .out_en(out_en_1),
        .dbus_in(dbus_in_1),
        .dbus_out(dbus_out_1),
        .miso_i(1'b1),       // Not used in slave mode
        .mosi_i(mosi_wire),
        .sck_i(sck_wire),
        .ss_i(ss_wire),
        .ss_o(),            // Not used in slave mode
        .miso_o(miso_wire),   
        .mosi_o(),          // Not used in slave mode
        .sck_o(),           // Not used in slave mode
        .SpiIRQ(spi_irq_1),
        .irqack_addr(irqack_addr),
        .irqack(irqack),
        .SPE1(),
        .MSTR1()
    );


    always begin
        #5 clk = ~clk;  // 100 MHz clock
    end


    task write_spi0_io_reg;
        input [5:0] addr;
        input [7:0] data;
        begin
            @(posedge clk);
            io_addr_0 = addr;
            dbus_in_0 = data;
            iowe_0 = 1;
            @(posedge clk);
            iowe_0 = 0;
            @(posedge clk);
        end
    endtask

    task read_spi0_io_reg;
        input [5:0] addr;
        output [7:0] data;
        begin
            @(posedge clk);
            io_addr_0 = addr;
            iore_0 = 1;
            @(posedge clk);
            data = dbus_out_0;
            iore_0 = 0;
            @(posedge clk);
        end
    endtask

    task write_spi1_ram_reg;
        input [11:0] addr;
        input [7:0] data;
        begin
            @(posedge clk);
            ram_addr_1 = addr;
            dbus_in_1 = data;
            ramwe_1 = 1;
            @(posedge clk);
            ramwe_1 = 0;
            @(posedge clk);
        end
    endtask

    task read_spi1_ram_reg;
        input [11:0] addr;
        output [7:0] data;
        begin
            @(posedge clk);
            ram_addr_1 = addr;
            ramre_1 = 1;
            @(posedge clk);
            data = dbus_out_1;
            ramre_1 = 0;
            @(posedge clk);
        end
    endtask


    task wait_for_spi0_complete;
        reg [7:0] spsr;
        begin
            spsr = 0;
            while(spsr[7] != 1'b1) begin
                read_spi0_io_reg(SPSR0_ADDR, spsr);
                #10;
            end
        end
    endtask


    initial begin

        clk = 0;
        reset_n = 0;
        io_addr_0 = 0;
        iore_0 = 0;
        iowe_0 = 0;
        ram_addr_0 = 0;
        ramre_0 = 0;
        ramwe_0 = 0;
        dbus_in_0 = 0;
        
        ram_addr_1 = 0;
        ramre_1 = 0;
        ramwe_1 = 0;
        dbus_in_1 = 0;
        
        irqack_addr = 0;
        irqack = 0;
        

        tx_data[0] = 8'hA5;  // data pattern 10100101
        tx_data[1] = 8'h3C;  // data pattern 00111100
        tx_data[2] = 8'hF0;  // data pattern 11110000
        

        #20 reset_n = 1;
        #50;
        
        // Configure SPI_0 as Master
        $display("Configuring SPI_0 as Master at time %t", $time);
        write_spi0_io_reg(SPCR0_ADDR, 8'h50);  // SPE=1, MSTR=1 (0101_0000)
        
        // Configure SPI_1 as Slave
        $display("Configuring SPI_1 as Slave at time %t", $time);
        write_spi1_ram_reg(SPCR1_ADDR, 8'h40);  // SPE=1, MSTR=0 (0100_0000)
        

        // FIRST BYTE TRANSMISSION
        $display("\n=== FIRST BYTE TRANSMISSION ===");
        $display("Sending data from Master (SPI_0) to Slave (SPI_1): 0x%h at time %t", tx_data[0], $time);
        write_spi0_io_reg(SPDR0_ADDR, tx_data[0]);
        

        wait_for_spi0_complete();
        $display("First byte transmission complete at time %t", $time);
        
        // Read received data from Slave
        read_spi1_ram_reg(SPDR1_ADDR, rx_data[0]);
        $display("Data received by Slave (SPI_1): 0x%h at time %t", rx_data[0], $time);
        

        if (rx_data[0] == tx_data[0])
            $display("TEST PASSED: First byte correctly received at time %t", $time);
        else
            $display("TEST FAILED: Expected 0x%h, got 0x%h at time %t", tx_data[0], rx_data[0], $time);
        
        // Clear interrupt
        irqack_addr = SPI0_IRQ_ADDR;
        irqack = 1;
        #20 irqack = 0;
        #50;  
        

        // SECOND BYTE TRANSMISSION
        $display("\n=== SECOND BYTE TRANSMISSION ===");
        $display("Sending data from Master (SPI_0) to Slave (SPI_1): 0x%h at time %t", tx_data[1], $time);
        write_spi0_io_reg(SPDR0_ADDR, tx_data[1]);
        

        wait_for_spi0_complete();
        $display("Second byte transmission complete at time %t", $time);
        

        read_spi1_ram_reg(SPDR1_ADDR, rx_data[1]);
        $display("Data received by Slave (SPI_1): 0x%h at time %t", rx_data[1], $time);
        

        if (rx_data[1] == tx_data[1])
            $display("TEST PASSED: Second byte correctly received at time %t", $time);
        else
            $display("TEST FAILED: Expected 0x%h, got 0x%h at time %t", tx_data[1], rx_data[1], $time);
            

        irqack_addr = SPI0_IRQ_ADDR;
        irqack = 1;
        #20 irqack = 0;
        #50; 
        

        // THIRD BYTE TRANSMISSION
        $display("\n=== THIRD BYTE TRANSMISSION ===");
        $display("Sending data from Master (SPI_0) to Slave (SPI_1): 0x%h at time %t", tx_data[2], $time);
        write_spi0_io_reg(SPDR0_ADDR, tx_data[2]);
        

        wait_for_spi0_complete();
        $display("Third byte transmission complete at time %t", $time);
        

        read_spi1_ram_reg(SPDR1_ADDR, rx_data[2]);
        $display("Data received by Slave (SPI_1): 0x%h at time %t", rx_data[2], $time);
        

        if (rx_data[2] == tx_data[2])
            $display("TEST PASSED: Third byte correctly received at time %t", $time);
        else
            $display("TEST FAILED: Expected 0x%h, got 0x%h at time %t", tx_data[2], rx_data[2], $time);
        

        irqack_addr = SPI0_IRQ_ADDR;
        irqack = 1;
        #20 irqack = 0;
        

        $display("\n=== TEST SUMMARY ===");
        $display("Byte 1: Sent 0x%h, Received 0x%h - %s", 
                tx_data[0], rx_data[0], (tx_data[0] == rx_data[0]) ? "PASSED" : "FAILED");
        $display("Byte 2: Sent 0x%h, Received 0x%h - %s", 
                tx_data[1], rx_data[1], (tx_data[1] == rx_data[1]) ? "PASSED" : "FAILED");
        $display("Byte 3: Sent 0x%h, Received 0x%h - %s", 
                tx_data[2], rx_data[2], (tx_data[2] == rx_data[2]) ? "PASSED" : "FAILED");
                

        #200 $finish;
    end

    // Monitor SPI signals
    initial begin
        $monitor("Time=%t: SCK=%b, MOSI=%b, MISO=%b, SS=%b", 
                 $time, sck_wire, mosi_wire, miso_wire, ss_wire);
    end

endmodule