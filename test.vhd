module traffic_light_controller (
    input wire clk,          // 50 MHz clock input
    input wire reset,        // Reset button
    output reg [2:0] ns_lights, // North-South lights (Red, Yellow, Green)
    output reg [2:0] ew_lights  // East-West lights (Red, Yellow, Green)
);

    typedef enum reg [1:0] {
        S0 = 2'b00, // NS Green, EW Red
        S1 = 2'b01, // NS Yellow, EW Red
        S2 = 2'b10, // NS Red, EW Green
        S3 = 2'b11  // NS Red, EW Yellow
    } state_t;

    state_t current_state, next_state;

  
    reg [25:0] clk_divider = 0; // 26-bit counter for 50 MHz to 1 Hz
    reg slow_clk = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_divider <= 0;
            slow_clk <= 0;
        end else if (clk_divider == 25_000_000) begin // Toggle every 1 second
            clk_divider <= 0;
            slow_clk <= ~slow_clk;
        end else begin
            clk_divider <= clk_divider + 1;
        end
    end

    reg [3:0] timer = 0; // 4-bit counter for state duration

    always @(posedge slow_clk or posedge reset) begin
        if (reset) begin
            timer <= 0;
            current_state <= S0;
        end else if (timer == 5) begin // 5 seconds for Green, 2 seconds for Yellow
            timer <= 0;
            current_state <= next_state;
        end else begin
            timer <= timer + 1;
        end
    end


    always @(*) begin
        case (current_state)
            S0: next_state = S1; // NS Green → NS Yellow
            S1: next_state = S2; // NS Yellow → EW Green
            S2: next_state = S3; // EW Green → EW Yellow
            S3: next_state = S0; // EW Yellow → NS Green
            default: next_state = S0;
        endcase
    end

    always @(*) begin
        case (current_state)
            S0: begin // NS Green, EW Red
                ns_lights = 3'b001; // Green
                ew_lights = 3'b100; // Red
            end
            S1: begin // NS Yellow, EW Red
                ns_lights = 3'b010; // Yellow
                ew_lights = 3'b100; // Red
            end
            S2: begin // NS Red, EW Green
                ns_lights = 3'b100; // Red
                ew_lights = 3'b001; // Green
            end
            S3: begin // NS Red, EW Yellow
                ns_lights = 3'b100; // Red
                ew_lights = 3'b010; // Yellow
            end
            default: begin
                ns_lights = 3'b100; // Default to Red
                ew_lights = 3'b100; // Default to Red
            end
        endcase
    end

endmodule
