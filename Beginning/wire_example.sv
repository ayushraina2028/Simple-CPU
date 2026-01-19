module wire_example;

    logic a; // Remember this is a wire/register named a, which holds a value (State)
    initial begin

        a = 1;
        #10; // this is like sleep(10)
        $display("a = %0d", a);
        $finish;
        
    end
endmodule

// assign describes a wire connection (function)
