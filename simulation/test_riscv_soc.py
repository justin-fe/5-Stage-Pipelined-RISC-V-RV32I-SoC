import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Timer

@cocotb.test()
async def test_riscv_execution(dut):
    """Cocotb test to boot the RISC-V SoC and monitor execution."""
    
    # 1. Start a 100 MHz clock (10 ns period) on the 'clk' input signal
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # 2. Apply Reset
    dut.rst.value = 1
    dut.dmem_rdata.value = 0
    await Timer(40, units="ns")
    
    # Release Reset
    dut.rst.value = 0
    dut._log.info("Reset released. RISC-V SoC booting up...")

    # 3. Run simulation for 20 clock cycles to watch instructions execute
    for cycle in range(20):
        await RisingEdge(dut.clk)
        
        # Log the current Program Counter and active instruction address
        pc = dut.core_inst.pc_out.value.integer
        dmem_we = dut.core_inst.dmem_we.value
        dmem_addr = dut.core_inst.dmem_addr.value.integer
        dmem_wdata = dut.core_inst.dmem_wdata.value.integer
        
        dut._log.info(f"Cycle {cycle:2d}: PC=0x{pc:08X} | DMEM_WE={dmem_we} | Addr=0x{dmem_addr:08X} | Data=0x{dmem_wdata:08X}")

    dut._log.info("RISC-V Simulation completed successfully!")
