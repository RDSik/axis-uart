`ifndef TEST_SV
`define TEST_SV

class test_base;

    virtual axis_if s_axis;
    virtual axis_if m_axis;

    test_cfg_base cfg;

    env_base env;

    mailbox #(packet) gen2drv;
    mailbox #(packet) in_mbx;
    mailbox #(packet) out_mbx;

    function new(virtual axis_if s_axis, virtual axis_if m_axis);
        this.s_axis = s_axis;
        this.m_axis = m_axis;

        cfg         = new();
        env         = new();
        gen2drv     = new();
        in_mbx      = new();
        out_mbx     = new();
        void'(cfg.randomize());

        env.master.master_gen.cfg        = cfg;
        env.master.master_driver.cfg     = cfg;
        env.slave.slave_driver.cfg       = cfg;
        env.check.cfg                    = cfg;

        env.master.master_gen.gen2drv    = gen2drv;
        env.master.master_driver.gen2drv = gen2drv;
        env.master.master_monitor.in_mbx = in_mbx;
        env.slave.slave_monitor.out_mbx  = out_mbx;
        env.check.in_mbx                 = in_mbx;
        env.check.out_mbx                = out_mbx;

        env.master.master_driver.axis    = this.m_axis;
        env.master.master_monitor.axis   = this.m_axis;
        env.slave.slave_driver.axis      = this.s_axis;
        env.slave.slave_monitor.axis     = this.s_axis;
    endfunction

    virtual task run();
        bit done;
        begin
            fork
                env.run();
                reset_checker();
                timeout();
            join_none
            wait (env.check.done);
            $display("Test was finished!");
`ifdef VERILATOR
            $finish();
`else
            $stop();
`endif
        end
    endtask

    virtual task reset_checker();
        begin
            forever begin
                wait (~m_axis.rstn_i);
                env.check.in_reset = 1'b1;
                wait (m_axis.rstn_i);
                env.check.in_reset = 1'b0;
            end
        end
    endtask

    task timeout();
        begin
            repeat (cfg.sim_time) @(posedge m_axis.clk_i);
            $display("Test timeout in: %0t ns\n", $time());
`ifdef VERILATOR
            $finish();
`else
            $stop();
`endif
        end
    endtask

endclass

`endif  // TEST_SV
