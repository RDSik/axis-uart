`ifndef PACKET_SV
`define PACKET_SV

class packet;
    rand logic [7:0] tdata;
    rand logic       tlast;
    rand int         delay;
endclass

`endif  // PACKET_SV
