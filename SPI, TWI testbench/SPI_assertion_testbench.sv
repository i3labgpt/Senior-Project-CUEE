module tb_SPI0();


reg clk;
reg reset_n;

// SPI0 Signals
reg [5:0] IO_Addr;
reg [7:0] dbus_in;
wire [7:0] dbus_out;
reg iore, iowe;
wire out_en;
wire miso_o, mosi_o, sck_o, ss_o;
reg miso_i, mosi_i, sck_i, ss_i;

// IRQ signals
wire SpiIRQ;
reg [5:0] irqack_addr;
reg irqack;


wire SPE0, MSTR0;

// Additional connections from NVM
reg NVM_iore, NVM_iowe;
reg SpiCRn, SpiSRn, SpiDRn;
reg Disable_ireset;
wire [7:0] NVM_dbus_out;

// Add this register to track SPCR state in the testbench
reg [7:0] spcr_shadow;



always #5 clk = ~clk;  // Clock period of 10ns (100MHz)


always @* miso_i = mosi_o;  // loopback connection


SPI_0 uut (
    .ireset(reset_n),
    .cp2(clk),
    .IO_Addr(IO_Addr),
    .iore(iore),
    .iowe(iowe),
    .out_en(out_en),
    .dbus_in(dbus_in),
    .dbus_out(dbus_out),
    
    // NVM-related ports
    .NVM_iore(NVM_iore),
    .NVM_iowe(NVM_iowe),
    .SpiCRn(SpiCRn),
    .SpiSRn(SpiSRn),
    .SpiDRn(SpiDRn),
    .Disable_ireset(Disable_ireset),
    .NVM_dbus_out(NVM_dbus_out),
    
    // SPI signals  
    .miso_i(miso_i),
    .mosi_i(mosi_i),
    .sck_i(sck_i),
    .ss_i(ss_i),
    .ss_o(ss_o),
    .miso_o(miso_o),
    .mosi_o(mosi_o),
    .sck_o(sck_o),
    
    // IRQ
    .SpiIRQ(SpiIRQ),
    .irqack_addr(irqack_addr),
    .irqack(irqack),
    

    .SPE0(SPE0),
    .MSTR0(MSTR0)
);


// Property: When SPE0 is 0, the SPI should be disabled
property spi_disabled_check;
  @(posedge clk) (!SPE0) |-> (!sck_o && ss_o);
endproperty
assert property (spi_disabled_check) else $error("Assert failed: SPI signals active when SPE0=0");

// Property: After reset, SPI should be disabled
property reset_disables_spi;
  @(posedge clk) $fell(reset_n) |=> (!SPE0);
endproperty
assert property (reset_disables_spi) else $error("Assert failed: SPI not disabled after reset");

// Property: After transmit starts, SPIF should be set when transmission completes
property transmission_sets_spif;
  @(posedge clk) 
    (iowe && IO_Addr == 6'h2E) |-> 
    ##[1:1000] (iore && IO_Addr == 6'h2D && dbus_out[7]);
endproperty
assert property (transmission_sets_spif) else $error("Assert failed: SPIF not set after transmission");

// Property: SS should be active (low) during transmission in master mode
property ss_active_during_transmission;
  @(posedge clk) 
    (MSTR0 && SPE0 && uut.MstSMSt_Current inside {1,2,3}) |-> (!ss_o);
endproperty
assert property (ss_active_during_transmission) else $error("Assert failed: SS not active during transmission");

// Property: SPI interrupt should be raised when SPIE is set and SPIF is set
property spi_interrupt_generation;
  @(posedge clk) 
    (dbus_out[7] && (IO_Addr == 6'h2D) && spcr_shadow[7]) |-> (SpiIRQ);
endproperty
assert property (spi_interrupt_generation) else $error("Assert failed: SPI interrupt not generated when expected");

// Property: Reading SPSR followed by SPDR should clear SPIF
sequence clear_spif_seq;
  (iore && IO_Addr == 6'h2D && dbus_out[7]) ##1 
  (iore && IO_Addr == 6'h2E) ##1
  (iore && IO_Addr == 6'h2D);
endsequence

property clear_spif_check;
  @(posedge clk) 
    clear_spif_seq |-> (!dbus_out[7]);
endproperty
assert property (clear_spif_check) else $error("Assert failed: SPIF not cleared after reading SPSR and SPDR");

// Property: Data should be transferred correctly (loopback test)
property data_transfer_check;
  logic [7:0] data_sent;
  @(posedge clk)
    (iowe && IO_Addr == 6'h2E, data_sent = dbus_in) |-> 
    ##[8:100] (iore && IO_Addr == 6'h2E && dbus_out == data_sent);
endproperty
assert property (data_transfer_check) else $error("Assert failed: Data not correctly transferred in loopback");

// End of Assertions

initial begin
    $monitor("Time=%0t | CPOL=%0b | SCK=%0b | SpiIRQ=%0b | SPIF=%0b | WCOL=%0b | MOSI=%0b | State=%d",
             $time, dbus_in[3], sck_o, SpiIRQ, 
             (IO_Addr == 6'h2D) ? dbus_out[7] : 1'bz,  // SPIF (bit 7 of SPSR)
             (IO_Addr == 6'h2D) ? dbus_out[6] : 1'bz,  // WCOL (bit 6 of SPSR)
             mosi_o,                                   // MOSI output
             uut.MstSMSt_Current);                     // Current master state for debugging
end


initial begin

    clk = 0;
    reset_n = 0;
    IO_Addr = 6'h00;
    dbus_in = 8'h00;
    iore = 0;
    iowe = 0;
    miso_i = 0;
    mosi_i = 0;
    sck_i = 0;
    ss_i = 1;  // SS inactive (high)
    irqack_addr = 6'h11;
    irqack = 0;
    spcr_shadow = 8'h00;
    

    NVM_iore = 0;
    NVM_iowe = 0;
    SpiCRn = 0;
    SpiSRn = 0;
    SpiDRn = 0;
    Disable_ireset = 0;
    
    //  Test Case 1: Reset Behavior 
    $display("\n=== TEST CASE 1: RESET BEHAVIOR ===");
    // Apply reset - This tests reset_disables_spi assertion
    reset_n = 0;
    #20;
    reset_n = 1;
    #20;  
    

    $display("After reset: SPE0=%b (Expected: 0)", SPE0);

    //  Test Case 2: SPI Configuration and Enabled State 
    $display("\n=== TEST CASE 2: SPI CONFIGURATION ===");

    IO_Addr = 6'h3F;  // SREG address
    dbus_in = 8'b10000000;  // Enable global interrupt
    iowe = 1;
    #20 iowe = 0;
    
    // SPIE=1, SPE=1, MSTR=1, CPOL=0, CPHA=0, clock div = /4
    $display("Configuring SPI with SPIE=1, SPE=1, MSTR=1");
    write_spcr0(8'b11010000);
    #20;
    
    // Check SPI configurations
    read_register(6'h2C);  // Read SPCR
    $display("After configuration: SPE0=%b, MSTR0=%b (Expected: 1, 1)", SPE0, MSTR0);
    #20;

    // Test Case 3: Basic Data Transfer 
    $display("\n=== TEST CASE 3: BASIC DATA TRANSFER (0xAA) ===");
    transmit_data(8'hAA);  // 10101010
    
    // Wait for transmission to complete - tests transmission_sets_spif assertion
    wait_for_spi_completion();
    
    // Read the received data - tests data_transfer_check assertion
    read_received_data();
    
    // Check SPIF flag - tests spi_interrupt_generation assertion
    $display("Checking SPIF flag after transfer");
    monitor_SPIF();
    
    // Verify SpiIRQ is asserted
    $display("SpiIRQ=%b (Expected: 1 when SPIF=1 and SPIE=1)", SpiIRQ);
    
    //  Test Case 4: SPIF Clearing Mechanism 
    $display("\n=== TEST CASE 4: CLEARING SPIF ===");
    repeat(5) @(posedge clk);
    
    // Clear SPIF by proper sequence - tests clear_spif_check assertion
    clear_SPIF();
    
    // Verify SPIF is cleared
    monitor_SPIF();
    
    //  Test Case 5: Second Data Transfer 
    $display("\n=== TEST CASE 5: SECOND DATA TRANSFER (0x55) ===");
    repeat(10) @(posedge clk);
    transmit_data(8'h55);  // 01010101
    
    // Wait for second transmission to complete
    wait_for_spi_completion();
    
    // Read the received data
    read_received_data();

    //  Test Case 6: SPI Disable Test 
    $display("\n=== TEST CASE 6: SPI DISABLE TEST ===");
    // Disable SPI by clearing SPE bit - tests spi_disabled_check assertion
    write_spcr0(8'b10010000); // Same as before but with SPE=0
    #20;
    
    // Verify that SPI signals are inactive
    $display("After SPE disabled: sck_o=%b, ss_o=%b (Expected: 0, 1)", sck_o, ss_o);
    
    // Try transmission with SPI disabled
    $display("Attempting transfer with SPI disabled");
    transmit_data(8'h33);
    repeat(20) @(posedge clk);
    
    // Check if SPIF is set (should not be)
    monitor_SPIF();

    //  Test Case 7: Write Collision Test 
    $display("\n=== TEST CASE 7: WRITE COLLISION TEST ===");
    // Re-enable SPI
    write_spcr0(8'b11010000); // SPIE=1, SPE=1, MSTR=1
    #20;
    
    // First transmission
    transmit_data(8'hAA);
    // Immediately try second transmission without waiting - should cause collision
    repeat(2) @(posedge clk);
    $display("Attempting second write before first completes (should set WCOL)");
    transmit_data(8'h55);
    
    // Check SPSR for WCOL flag
    repeat(5) @(posedge clk);
    monitor_SPIF(); // This also shows WCOL
    
    // Complete the test
    wait_for_spi_completion();
    repeat(20) @(posedge clk);
    
    $display("\n=== SPI Tests Complete ===");
    $finish;
end


task read_register;
    input [5:0] address;
    begin
        @(posedge clk);
        IO_Addr = address;
        iore = 1;
        @(posedge clk);
        $display("Register @0x%h = 0x%h", address, dbus_out);
        iore = 0;
    end
endtask


task write_spcr0;
    input [7:0] value;
    begin
        @(posedge clk); 
        IO_Addr = 6'h2C;  // SPCR0 address
        dbus_in = value;  
        iowe = 1;
        spcr_shadow = value;  // Update shadow register 
        @(posedge clk); 
        iowe = 0;  
        #10; 
        $display("Configured SPCR0 with value 0x%h at time %0t", value, $time);
    end
endtask


task transmit_data;
    input [7:0] data;
    begin
        @(posedge clk); 
        IO_Addr = 6'h2E;  // SPDR address
        dbus_in = data;   
        iowe = 1;         
        @(posedge clk);   
        iowe = 0;
        $display("Transmitting data: 0x%h (binary %b) at time %0t", data, data, $time);
        
        repeat(5) @(posedge clk);
    end
endtask


task monitor_SPIF;
    begin
        @(posedge clk);
        IO_Addr = 6'h2D;  // SPSR address
        iore = 1;         
        @(posedge clk);   
        $display("SPSR value: 0x%h (SPIF=%0b, WCOL=%0b) at time %0t", 
                 dbus_out, dbus_out[7], dbus_out[6], $time);
        iore = 0;         
    end
endtask


task clear_SPIF;
    begin
        // Read SPSR
        @(posedge clk);
        IO_Addr = 6'h2D;  
        iore = 1;
        @(posedge clk);
        $display("Read SPSR: 0x%h", dbus_out);
        iore = 0;
        
        // Access SPDR
        @(posedge clk);
        IO_Addr = 6'h2E;  
        iore = 1;       
        @(posedge clk);
        $display("Read SPDR: 0x%h", dbus_out);
        iore = 0;
        
        $display("Cleared SPIF by reading SPSR and SPDR at time %0t", $time);
    end
endtask


task wait_for_spi_completion;
    reg spif_value;
    begin
        spif_value = 0;
        while (!spif_value) begin
        
            @(posedge clk);
            IO_Addr = 6'h2D;  
            iore = 1;
            @(posedge clk);
            spif_value = dbus_out[7]; // SPIF bit
            iore = 0;
            
            if (!spif_value) begin
                repeat(10) @(posedge clk);  
            end
        end
        $display("SPI transmission completed (SPIF=1) at time %0t", $time);
    end
endtask


task read_received_data;
    begin
        repeat(3) @(posedge clk);
        IO_Addr = 6'h2E;  
        iore = 1;         
        @(posedge clk);   
        
        if (!out_en) begin
            $display("WARNING: out_en not active when reading SPDR!");
        end
        
        $display("=== Received data in SPDR: 0x%h (binary %b) at time %0t ===", 
                 dbus_out, dbus_out, $time);
        iore = 0;         
    end
endtask

endmodule
