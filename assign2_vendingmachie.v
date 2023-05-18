module vending_machine_tb;

  
  reg clk;
  reg [1:0] in_product;
  reg [3:0] in_coin;
  wire out_dispense;
  wire [3:0] out_change;
  
  
  vending_machine uut (
    .clk(clk),
    .in_product(in_product),
    .in_coin(in_coin),
    .out_dispense(out_dispense),
    .out_change(out_change)
  );

  initial begin
    
    in_product = 2'b00;
    in_coin = 4'b0000;
    

    #100;
    
    // Insert a 5 Rs. coin
    in_coin = 4'b0101;
    #10;
    
    // Select product A
    in_product = 2'b01;
    #10;
    
    // Expect product A to be dispensed and 0 Rs. change
    assert(out_dispense == 1'b1);
    assert(out_change == 4'b0000);
    
    // Insert a 10 Rs. coin
    in_coin = 4'b1010;
    #10;
    
    // Select product C
    in_product = 2'b10;
    #10;
    
    // product C to be dispensed and 5 Rs. change
    assert(out_dispense == 1'b1);
    assert(out_change == 4'b0101);
    
    // Insert a 10 Rs. coin
    in_coin = 4'b1010;
    #10;
    
    // Select product D
    in_product = 2'b11;
    #10;
    
    // product D to be dispensed and 0 Rs. change
    assert(out_dispense == 1'b1);
    assert(out_change == 4'b0000);
    
    // Insert a 5 Rs. coin
    in_coin = 4'b0101;
    #10;
    
    // Select product B
    in_product = 2'b10;
    #10;
    
    // product B to NOT be dispensed due to insufficient coins
    assert(out_dispense == 1'b0);
    $finish;
  end
  
  always #10 clk = ~clk;

endmodule


module vending_machine (
  input clk,                                         // clock input
  input rst,                                          // reset input
  input in_coin,                             // input coin signal (5 or 10)
  input [1:0] in_product,            // input product signal (00:A, 01:B, 10:C, 11:D)
  output reg out_dispense,        // output dispense signal (1 if product dispensed, otherwise 0)
  output reg [3:0] out_change              // output change signal (binary value representing 0-15 Rs)
);

  // states
  parameter IDLE = 2'b00;
  parameter WAIT_COIN = 2'b01;
  parameter DISPENSE = 2'b10;
  
  // define the products
  parameter PRODUCT_A = 2'b00;
  parameter PRODUCT_B = 2'b01;
  parameter PRODUCT_C = 2'b10;
  parameter PRODUCT_D = 2'b11;
  
  // coin values
  parameter COIN_5 = 1'b0;
  parameter COIN_10 = 1'b1;
  
  // product costs
  parameter COST_A = 5;
  parameter COST_B = 10;
  parameter COST_C = 15;
  parameter COST_D = 20;
  
  // change values
  parameter CHANGE_0 = 4'b0000;
  parameter CHANGE_5 = 4'b0001;
  parameter CHANGE_10 = 4'b0010;
  parameter CHANGE_15 = 4'b0100;
  parameter CHANGE_20 = 4'b1000;
  
  // current state variable
  reg [1:0] current_state = IDLE;
  
  // current product variable
  reg [1:0] current_product;
  
  // define the current cost variable
  reg [3:0] current_cost;
  
  // current change variable
  reg [3:0] current_change;
  
  // input coin value variable
  reg [1:0] input_coin_value;
  
  // coin inserted variable
  reg coin_inserted;
  
  always @(posedge clk, posedge rst) begin
    if (rst) begin
      current_state <= IDLE;
      current_product <= 2'b00;
      current_cost <= 4'b0000;
      current_change <= 4'b0000;
      input_coin_value <= 2'b00;
      coin_inserted <= 1'b0;
      out_dispense <= 1'b0;
      out_change <= 4'b0000;
    end else begin
      case (current_state)
        IDLE: begin
          if (in_product != 2'b00) begin
            current_product <= in_product;
            current_cost <= {4'd0, COST_A, COST_B, COST_C, COST_D}[current_product];
            current_state <= WAIT_COIN;
          end
        end
        
        WAIT_COIN: begin
          input_coin_value <= in_coin;
          
          if (input_coin_value == COIN_5 || input_coin_value == COIN_10) begin
            coin_inserted <= 1'b1;
            current_change <= current_change + {4'd0, CHANGE_5, CHANGE_10}[input_coin_value];
          end
          
          if (coin_inserted && current_change >= current_cost) begin
            out_dispense <= 1'b1;
            out_change <= current_change - current_cost
            current_change <= current_change - current_cost;
            current_state <= DISPENSE;
          end
        end
        
        DISPENSE: begin
          out_dispense <= 1'b0;
          out_change <= current_change;
          coin_inserted <= 1'b0;
          current_product <= 2'b00;
          current_cost <= 4'b0000;
          current_change <= 4'b0000;
          current_state <= IDLE;
        end
      endcase
    end
  end

endmodule



