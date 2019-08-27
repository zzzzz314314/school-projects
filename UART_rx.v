module UART_rs232_rx (Clk,Rst_n,RxEn,RxData,RxDone,Rx,Tick,NBits, count_Rx);	

input Clk, Rst_n, RxEn,Rx,Tick;	
input [7:0]NBits;			


output RxDone;			
output [7:0]RxData;			
output [7:0] count_Rx;


parameter  IDLE = 1'b0, READ = 1'b1; 	
reg [1:0] State, Next;		
reg  read_enable = 1'b0;		
reg  start_bit = 1'b1;		
reg  RxDone = 1'b0;		
reg [4:0]Bit = 5'b00000;	
reg [3:0] counter = 4'b0000;	
reg [7:0] Read_data= 8'b00000000;	
reg [7:0] RxData;		

reg [7:0] count_Rx = 0;
reg [25:0] clk_counter= 0;
reg [3:0] clk_counter_controler;

always @ (posedge Clk or negedge Rst_n)			
begin
if (!Rst_n)	State <= IDLE;				
else 		State <= Next;				
end



always @ (State or Rx or RxEn or RxDone)
begin
    case(State)	
	IDLE:	if(!Rx & RxEn)		Next = READ;	
		else			Next = IDLE;
	READ:	if(RxDone)		Next = IDLE; 	
		else			Next = READ;
	default 			Next = IDLE;
    endcase
end

always @ (State or RxDone)
begin
    case (State)
	READ: begin
		read_enable <= 1'b1;			
	      end
	
	IDLE: begin
		read_enable <= 1'b0;		
	      end
    endcase
end

always @ (posedge Tick)

	begin
	if (read_enable)
	begin
	RxDone <= 1'b0;							
	counter <= counter+1;					
	

	if ((counter == 4'b1000) & (start_bit))			
	begin
	start_bit <= 1'b0;
	counter <= 4'b0000;
	end

	if ((counter == 4'b1111) & (!start_bit) & (Bit < NBits))
	begin
	Bit <= Bit+1;
	Read_data <= {Rx,Read_data[7:1]};
	counter <= 4'b0000;
	end
	
	if ((counter == 4'b1111) & (Bit == NBits)  & (!Rx))		
	begin
	Bit <= 4'b0000;
	RxDone <= 1'b1;
	counter <= 4'b0000;
	start_bit <= 1'b1;				
	end
	end
	
	
end


always @ (posedge Clk)
begin

if(Rx == 1)begin
    clk_counter <= 0;
   
end
else begin
    clk_counter <= clk_counter + 1;

end

if (NBits == 4'b1000)
begin
RxData[7:0] <= Read_data[7:0];	
end

end


always@(posedge Rx) begin
    if(clk_counter > 26'd1000000)begin
        count_Rx <= 26'd1;
    end
    else begin
        count_Rx <= count_Rx+1;
    end
end


endmodule

