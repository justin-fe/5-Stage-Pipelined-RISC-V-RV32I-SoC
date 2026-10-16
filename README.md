# 5-Stage Pipelined RISC-V RV32I SoC

A custom, synthesizable 5-stage pipelined RV32I System-on-Chip (SoC) designed from scratch in VHDL. This project implements a core subset of the RISC-V integer instruction set architecture (RV32I) complete with full hardware hazard detection, data forwarding logic, instruction/data memories, and an automated Python-driven verification environment using Cocotb.

---

## 🏛️ Architecture & Datapath

The processor follows a classic RISC-V 5-stage pipelined architecture. Data hazards (Read-After-Write) are automatically resolved via a dedicated **Forwarding Unit** that bypasses execution results directly back to the ALU inputs, minimizing pipeline stalls.

```mermaid
flowchart LR
    subgraph SoC ["RV32I SoC"]
        IMEM["Instruction Memory (ROM)"] -->|Instruction| CORE
        DMEM["Data Memory (RAM)"] <==>|Load/Store Data| CORE
        
        subgraph CORE ["RISC-V Core (5-Stage Pipeline)"]
            IF["<b>Fetch (IF)</b><br>PC & IMEM"] --> ID["<b>Decode (ID)</b><br>Reg File & Control"]
            ID --> EX["<b>Execute (EX)</b><br>ALU & Forwarding"]
            EX --> MEM["<b>Memory (MEM)</b><br>Data RAM Access"]
            MEM --> WB["<b>Writeback (WB)</b><br>Register File Write"]
            
            EX -.->|Forwarding Paths| EX
            Hazard["Hazard Detection Unit"] -.->|Stall Control| IF
            Hazard -.->|Stall Control| ID
        end
    end
