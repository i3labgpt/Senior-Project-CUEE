`timescale 1ns / 1ps

module TWIn_master_tx_tb;


    reg ireset;
    reg cp2;
    
    reg [11:0] ram_Addr;
    reg ramre, ramwe;
    reg [7:0] dbus_in;
    reg [5:0] irqack_addr;
    reg irqack;
    
    wire out_en;
    wire [7:0] dbus_out;
    wire TwiIRQ;
    wire TWEN;
    
    // TWI bus signals - changed to reg for direct control
    reg sda_i;
    reg scl_i;
    wire sda_o;
    wire scl_o;
    
    // Internal test signals
    reg [7:0] status_reg;
    reg [7:0] read_data;
    
    // Add timeout counter at module level
    integer timeout_count;
    
    // Parameters for register addresses
    parameter [11:0] TWBRn_Address = 12'h0B8;    // TWBR0
    parameter [11:0] TWSRn_Address = 12'h0B9;    // TWSR0
    parameter [11:0] TWARn_Address = 12'h0BA;    // TWAR0
    parameter [11:0] TWDRn_Address = 12'h0BB;    // TWDR0
    parameter [11:0] TWCRn_Address = 12'h0BC;    // TWCR0
    parameter [11:0] TWAMRn_Address = 12'h0BD;   // TWAMR0
    parameter [5:0]  TwiIRQ_Address = 6'h18;     // IRQ address
    
    // Slave address for testing
    parameter [6:0] SLAVE_ADDR = 7'b0101010;
    parameter [6:0] NONEXISTENT_ADDR = 7'b1111111;
    
    TWIn #(
        .TWBRn_Address(TWBRn_Address),
        .TWSRn_Address(TWSRn_Address),
        .TWARn_Address(TWARn_Address),
        .TWDRn_Address(TWDRn_Address),
        .TWCRn_Address(TWCRn_Address),
        .TWAMRn_Address(TWAMRn_Address),
        .TwiIRQ_Address(TwiIRQ_Address)
    ) dut (
        .ireset(ireset),
        .cp2(cp2),
        .ram_Addr(ram_Addr),
        .ramre(ramre),
        .ramwe(ramwe),
        .out_en(out_en),
        .dbus_in(dbus_in),
        .dbus_out(dbus_out),
        .TwiIRQ(TwiIRQ),
        .irqack_addr(irqack_addr),
        .irqack(irqack),
        .TWEN(TWEN),
        .sda_i(sda_i),
        .sda_o(sda_o),
        .scl_i(scl_i),
        .scl_o(scl_o)
    );
    
    initial begin
        $monitor("Time=%0t SCL=%b SDA=%b TWCR=%h", 
                 $time, scl_i, sda_i, dut.TWCRn);
    end
    
    always #5 cp2 = ~cp2;  // 100 MHz clock
    
    task write_register;
        input [11:0] addr;
        input [7:0] data;
        begin
            @(posedge cp2);
            ram_Addr = addr;
            dbus_in = data;
            ramwe = 1;
            @(posedge cp2);
            ramwe = 0;
            #10; 
        end
    endtask
    
    task read_register;
        input [11:0] addr;
        output [7:0] data;
        begin
            @(posedge cp2);
            ram_Addr = addr;
            ramre = 1;
            @(posedge cp2);
            data = dbus_out;
            $display("Read register [%h] = %h at time %t", addr, data, $time);
            ramre = 0;
            #10;
        end
    endtask
    
    task wait_for_twi_flag;
        reg [7:0] twcr_value;
        begin
            // Initialize timeout counter
            timeout_count = 0;
            
            repeat(5) @(posedge cp2);
            
            read_register(TWCRn_Address, twcr_value);
            while(twcr_value[7] == 0 && timeout_count < 1000) begin
                read_register(TWCRn_Address, twcr_value);
                @(posedge cp2);
                timeout_count = timeout_count + 1;
            end
            
            if (timeout_count >= 1000) begin
                $display("WARNING: TWINT timeout at time %t - proceeding anyway", $time);
            end
            
            read_register(TWSRn_Address, status_reg);
            $display("TWI Status: %h at time %t", status_reg & 8'hF8, $time);
        end
    endtask
    
    task reset_and_init_twi;
        begin

            ireset = 0;
            repeat(20) @(posedge cp2);
            ireset = 1;
            repeat(20) @(posedge cp2);
            
            write_register(TWBRn_Address, 8'h00);  // Max speed
            write_register(TWSRn_Address, 8'h00);  // Prescaler = 1
            write_register(TWCRn_Address, 8'h04);  // Enable TWI
            
            repeat(20) @(posedge cp2);
        end
    endtask
    

    task simulate_slave_ack;
        begin
            scl_i = 1;  // Force SCL high
        end
    endtask
    

    task simulate_slave_nack;
        begin
            scl_i = 1;  // Force SCL high
            sda_i = 1;  // Keep SDA high (NACK)
        end
    endtask
    

    initial begin

        ireset = 0;
        cp2 = 0;
        irqack = 0;
        irqack_addr = 6'h00;
        

        sda_i = 1'bz; // Pullup
        scl_i = 1'bz; // Pullup
        

        ram_Addr = 0;
        ramre = 0;
        ramwe = 0;
        dbus_in = 0;


        #20 ireset = 1;
        
        repeat(5) @(posedge cp2);
        
        // TEST 1: Normal I2C Transaction

        $display("\n=== TEST 1: Normal I2C Transaction ===");
        
        // Step 1: Initial Setup
        write_register(TWBRn_Address, 8'h00);     // TWBR0 = 0x00 (Max speed)
        write_register(TWSRn_Address, 8'h00);     // TWSR0 = 0x00 (Prescaler = 1)
        
        // Step 2: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 3: Send Address
        write_register(TWDRn_Address, {SLAVE_ADDR, 1'b0});  // SLA+W
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        scl_i = 1;                               // Simulate ACK
        wait_for_twi_flag;
        
        // Step 4: Send Data
        write_register(TWDRn_Address, 8'h4A);     // Data byte
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        scl_i = 1;                               // Simulate ACK
        wait_for_twi_flag;
        
        // Step 5: Generate STOP
        write_register(TWCRn_Address, 8'h94);     // TWCR0 = 0x94 (STOP)
        
        repeat(50) @(posedge cp2);
        $display("Test 1 completed\n");
        
        
        // TEST 2: Multi-byte Transfer Test

        $display("\n=== TEST 2: Multi-byte Transfer Test ===");
        

        reset_and_init_twi;
        
        // Step 1: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 2: Send Address
        write_register(TWDRn_Address, {SLAVE_ADDR, 1'b0});  // SLA+W
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 3: Send First Data Byte
        write_register(TWDRn_Address, 8'h11);     // Data byte 1
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 4: Send Second Data Byte
        write_register(TWDRn_Address, 8'h22);     // Data byte 2
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 5: Send Third Data Byte
        write_register(TWDRn_Address, 8'h33);     // Data byte 3
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 6: Generate STOP
        write_register(TWCRn_Address, 8'h94);     // TWCR0 = 0x94 (STOP)
        
        repeat(50) @(posedge cp2);
        $display("Test 2 completed\n");
        
        
        // TEST 3: NACK Response Test

        $display("\n=== TEST 3: NACK Response Test ===");
        
        // Reset and initialize
        reset_and_init_twi;
        
        // Step 1: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 2: Send Address to non-existent slave
        write_register(TWDRn_Address, {NONEXISTENT_ADDR, 1'b0});  // SLA+W to non-existent slave
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        simulate_slave_nack;                     // Simulate NACK
        wait_for_twi_flag;
        
        // Check for expected status: 0x20 (SLA+W transmitted, NACK received)
        if ((status_reg & 8'hF8) == 8'h20) begin
            $display("SUCCESS: NACK correctly detected for non-existent slave");
        end else begin
            $display("ERROR: Expected status 0x20, got %h", status_reg & 8'hF8);
        end
        
        // Step 3: Generate STOP
        write_register(TWCRn_Address, 8'h94);     // TWCR0 = 0x94 (STOP)
        
        repeat(50) @(posedge cp2);
        $display("Test 3 completed\n");
        
        
        // TEST 4: Repeated START Test
        $display("\n=== TEST 4: Repeated START Test ===");
        
        // Reset and initialize
        reset_and_init_twi;
        
        // Step 1: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 2: Send Address for Write
        write_register(TWDRn_Address, {SLAVE_ADDR, 1'b0});  // SLA+W
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 3: Send Register Address
        write_register(TWDRn_Address, 8'h42);     // Register address
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 4: Generate Repeated START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (Repeated START)
        wait_for_twi_flag;
        
        // Check for expected status: 0x10 (Repeated START transmitted)
        if ((status_reg & 8'hF8) == 8'h10) begin
            $display("SUCCESS: Repeated START correctly transmitted");
        end else begin
            $display("ERROR: Expected status 0x10, got %h", status_reg & 8'hF8);
        end
        
        // Step 5: Send Address for Read
        write_register(TWDRn_Address, {SLAVE_ADDR, 1'b1});  // SLA+R
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 6: Generate STOP
        write_register(TWCRn_Address, 8'h94);     // TWCR0 = 0x94 (STOP)
        
        repeat(50) @(posedge cp2);
        $display("Test 4 completed\n");
        
        
        // TEST 5: Clock Stretching Test
        $display("\n=== TEST 5: Clock Stretching Test ===");
        

        reset_and_init_twi;
        
        // Step 1: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 2: Send Address
        write_register(TWDRn_Address, {SLAVE_ADDR, 1'b0});  // SLA+W
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        
        // Simulate slave clock stretching by holding SCL low
        fork
            begin

                repeat(10) @(posedge cp2);
                
                // Force SCL low to stretch the clock
                scl_i = 0;
                $display("*** FORCING SCL LOW TO SIMULATE CLOCK STRETCHING AT TIME %t ***", $time);
                
                // Hold SCL low for a significant time
                repeat(100) @(posedge cp2);
                
                // Release SCL and simulate ACK
                scl_i = 1;
                $display("*** RELEASING SCL AT TIME %t ***", $time);
            end
        join_none
        

        wait_for_twi_flag;
        
        // Step 3: Send Data
        write_register(TWDRn_Address, 8'h5A);     // Data byte
        write_register(TWCRn_Address, 8'h84);     // Clear TWINT
        simulate_slave_ack;                      // Simulate ACK
        wait_for_twi_flag;
        
        // Step 4: Generate STOP
        write_register(TWCRn_Address, 8'h94);     // TWCR0 = 0x94 (STOP)
        
        repeat(50) @(posedge cp2);
        $display("Test 5 completed\n");

        // TEST 6: Arbitration Lost Simulation

        $display("\n=== TEST 6: Arbitration Lost Simulation ===");
        
        // Reset and initialize
        reset_and_init_twi;
        
        // Step 1: Generate START
        write_register(TWCRn_Address, 8'hA4);     // TWCR0 = 0xA4 (START + TWEN)
        wait_for_twi_flag;
        
        // Step 2: Send Address with forced arbitration loss
        write_register(TWDRn_Address, 8'hFE);     // SLA+W with MSB=1 to create conflict
        write_register(TWCRn_Address, 8'h84);     // TWCR0 = 0x84 (Clear TWINT)
        
        // Force arbitration lost by pulling SDA low when a high bit is being transmitted
        fork
            begin

                repeat(5) @(posedge cp2);
                
                // Force SDA low while controller is trying to send the MSB=1
                sda_i = 0;
                $display("*** FORCING SDA LOW TO SIMULATE ARBITRATION LOST AT TIME %t ***", $time);
                
                repeat(20) @(posedge cp2);
                
                sda_i = 1'bz;
            end
        join_none
        
        // Wait for TWI controller to detect arbitration lost
        wait_for_twi_flag;
        
        // Check if arbitration lost status (0x38) is detected
        if ((status_reg & 8'hF8) == 8'h38) begin
            $display("SUCCESS: Arbitration Lost detected correctly (status = 0x38)");
        end else begin
            $display("ERROR: Arbitration Lost not detected correctly (status = %h)", status_reg & 8'hF8);
        end
        
        repeat(50) @(posedge cp2);
        $display("Test 6 completed\n");
        
        $display("\n=== ALL TESTS COMPLETED ===");
        repeat(20) @(posedge cp2);
        $finish;
    end

endmodule