module TWIn_wakeup_tb;


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
    

    wire sda_o, scl_o;
    reg sda_i, scl_i;
    

    reg [7:0] read_data;
    
    // Parameters for register addresses
    parameter [11:0] TWBRn_Address = 12'h0B8;    // TWBR0
    parameter [11:0] TWSRn_Address = 12'h0B9;    // TWSR0
    parameter [11:0] TWARn_Address = 12'h0BA;    // TWAR0
    parameter [11:0] TWDRn_Address = 12'h0BB;    // TWDR0
    parameter [11:0] TWCRn_Address = 12'h0BC;    // TWCR0
    parameter [11:0] TWAMRn_Address = 12'h0BD;   // TWAMR0
    parameter [5:0]  TwiIRQ_Address = 6'h18;     // IRQ address
    
    // Status code definitions
    parameter [7:0] STATUS_START = 8'h08;        // START transmitted
    parameter [7:0] STATUS_ADDR_ACK = 8'h18;     // SLA+W transmitted, ACK received
    parameter [7:0] STATUS_ADDR_RECEIVED = 8'h60; // Own SLA+W received, ACK returned
    parameter [7:0] STATUS_DATA_ACK = 8'h28;     // Data transmitted, ACK received
    parameter [7:0] STATUS_DATA_NACK = 8'h30;    // Data transmitted, NACK received
    
    // slave address for testing
    parameter [6:0] OUR_ADDR = 7'b0101010;
    

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
    

    always #5 cp2 = ~cp2;  // 100 MHz clock
    

    task write_register;
        input [11:0] addr;
        input [7:0] data;
        begin
            @(posedge cp2);
            ram_Addr = addr;
            dbus_in = data;
            ramwe = 1;
            ramre = 0;
            @(posedge cp2);
            ramwe = 0;
            @(posedge cp2); 
        end
    endtask
    
    task read_register;
        input [11:0] addr;
        output [7:0] data;
        begin
            @(posedge cp2);
            ram_Addr = addr;
            ramwe = 0;
            ramre = 1;
            @(posedge cp2);
            data = dbus_out;
            ramre = 0;
            @(posedge cp2); 
        end
    endtask
    
    task wait_for_twi_flag;
        reg [7:0] twcr_value;
        integer timeout_count;
        begin
            timeout_count = 0;
            repeat(5) @(posedge cp2);  
            
            read_register(TWCRn_Address, twcr_value);
            while (twcr_value[7] == 0 && timeout_count < 1000) begin
                read_register(TWCRn_Address, twcr_value);
                @(posedge cp2);
                timeout_count = timeout_count + 1;
            end
            
            if (timeout_count >= 1000) begin
                $display("WARNING: TWINT timeout at time %0t - proceeding anyway", $time);
            end
            
            read_register(TWSRn_Address, read_data);
            $display("TWI Status: %h at time %t", read_data & 8'hF8, $time);
        end
    endtask
    
    // task to simulate another master sending START condition
    task simulate_external_start;
        begin
            // Pull SDA low while SCL is high (START condition)
            scl_i = 1;
            repeat(5) @(posedge cp2);
            sda_i = 0;
            repeat(10) @(posedge cp2);
            // Start of clock for first bit
            scl_i = 0;
            repeat(10) @(posedge cp2);
        end
    endtask
    
    // task to simulate a master sending a byte on the bus
    task simulate_external_send_byte;
        input [7:0] data;
        begin
            for (int i = 7; i >= 0; i--) begin

                sda_i = data[i];
                repeat(5) @(posedge cp2);
                

                scl_i = 1;
                repeat(10) @(posedge cp2);
                

                scl_i = 0;
                repeat(10) @(posedge cp2);
            end
            
            // Release SDA for ACK (allow slave to control it)
            sda_i = 1;
            repeat(5) @(posedge cp2);
            
            // Clock SCL high for ACK bit
            scl_i = 1;
            repeat(10) @(posedge cp2);
            
            // Check if the peripheral acknowledged (sda_o should be 0)
            if (!sda_o) begin
                $display("RECEIVED ACK from peripheral at time %t", $time);
            end else begin
                $display("NO ACK from peripheral at time %t", $time);
            end
            

            scl_i = 0;
            repeat(10) @(posedge cp2);
        end
    endtask
    
    // task to simulate external STOP condition
    task simulate_external_stop;
        begin

            sda_i = 0;
            repeat(5) @(posedge cp2);
            

            scl_i = 1;
            repeat(10) @(posedge cp2);
            
            // Bring SDA high while SCL is high (STOP condition)
            sda_i = 1;
            repeat(10) @(posedge cp2);
        end
    endtask
    

    initial begin

        ireset = 0;
        cp2 = 0;
        irqack = 0;
        irqack_addr = 6'h00;
        ram_Addr = 0;
        ramre = 0;
        ramwe = 0;
        dbus_in = 0;
        
        // Configure pullups for I2C bus
        sda_i = 1;
        scl_i = 1;
        
        // Reset
        #20 ireset = 1;
        #20;
        
        $display("\n=== TWI Wake-Up from Power Save Mode Test ===");
        
        // Set up the TWI as a slave
        write_register(TWARn_Address, {OUR_ADDR, 1'b1});  // Set slave address with General Call enabled
        
        // Enable TWI and set it to respond to address
        write_register(TWCRn_Address, 8'h44);  // TWEA=1, TWEN=1 (Enable TWI and acknowledge)
        
        // Simulate going into power-save mode 
        // For this testbench, we'll just assume the rest of the system is "sleeping"
        $display("System entering power save mode with TWI address recognition active");
        repeat(50) @(posedge cp2);
        
        // Simulate another master sending START condition + TWI's address
        $display("External master sending START condition");
        simulate_external_start;
        
        // Simulate another master sending our address + write bit
        $display("External master sending our address (SLA+W)");
        simulate_external_send_byte({OUR_ADDR, 1'b0});  // SLA+W
        
        // Check if peripheral woke up (interrupt should be triggered)
        repeat(20) @(posedge cp2);
        
        if (TwiIRQ) begin
            $display("SUCCESS: TWI generated interrupt on address match");
        end else begin
            $display("ERROR: No interrupt generated on address match");
        end
        
        // Check status register to confirm address recognition
        read_register(TWSRn_Address, read_data);
        if ((read_data & 8'hF8) == STATUS_ADDR_RECEIVED) begin
            $display("SUCCESS: TWI recognized its address (status 0x60)");
        end else begin
            $display("ERROR: TWI did not report address recognition. Status: %h", read_data & 8'hF8);
        end
        
        // Acknowledge the interrupt and clear the flag
        irqack_addr = TwiIRQ_Address;
        irqack = 1;
        @(posedge cp2);
        irqack = 0;
        
        // clear TWINT flag and keep TWEA to continue as slave
        write_register(TWCRn_Address, 8'hC4);  // TWINT=1, TWEA=1, TWEN=1
        
        // Simulate master sending a data byte
        $display("External master sending data byte");
        simulate_external_send_byte(8'h42);  // Some test data
        
        // Check if data was received
        repeat(20) @(posedge cp2);
        
        if (TwiIRQ) begin
            $display("SUCCESS: TWI generated interrupt on data reception");
            
            // Acknowledge the interrupt
            irqack_addr = TwiIRQ_Address;
            irqack = 1;
            @(posedge cp2);
            irqack = 0;
            
            // Read received data
            read_register(TWDRn_Address, read_data);
            $display("Received data: 0x%h", read_data);
        end else begin
            $display("ERROR: No interrupt generated on data reception");
        end
        
        // Simulate master sending STOP condition
        $display("External master sending STOP condition");
        simulate_external_stop;
        
        repeat(50) @(posedge cp2);
        
        $display("\n=== TWI Wake-Up Test completed ===");
        $finish;
    end


    initial begin
        $monitor("Time=%0t SCL=%b SDA_o=%b SDA_i=%b TwiIRQ=%b", $time, scl_o, sda_o, sda_i, TwiIRQ);
    end

endmodule