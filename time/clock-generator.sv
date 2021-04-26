/*******************************************************************

    @module ClockGenerator

    Generates a clock signal.

********************************************************************/
module ClockGenerator #(
    parameter PERIOD = 10,              // Clock cycle time
    parameter PHASE = 0,                // Clock phase (offset)
    parameter DUTY = 50                 // Clock duty (how long the signal is on)
) (
    input enable,                       // Enables the clock signal
    output reg clk                      // Generated clock signal
);

    // How long the clock should be on
    real onDelay = DUTY / 100.0 * PERIOD;

    // How long the clock should be off
    real offDelay = (100.0 - DUTY) / 100.0 * PERIOD;

    // One quarter of the period
    real quarter = PERIOD / 4.0;

    // How long to delay the clock to emulate the phase effect
    real startDelay = quarter * PHASE / 90.0;

    // Signals that the clock should start
    reg startClk;

    initial begin
        clk <= 0;
        startClk <= 0;
    end 

    always @(posedge enable, negedge enable) begin
        // Enable
        if (enable) begin
            #(startDelay) startClk = 1;
        end
        // Disable
        else begin
            #(startDelay) startClk = 0;
        end
    end

    // Clock output loop
    always @(posedge startClk) begin
        if (startClk) begin
            clk = 1;

            while (startClk) begin
                #(onDelay) clk = 0;
                #(offDelay) clk = 1;
            end

            clk = 0;
        end
    end
        
endmodule