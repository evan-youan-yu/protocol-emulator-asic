// SPDX-License-Identifier: Apache-2.0
`default_nettype none

// M1 experimental programmable protocol engine. See docs/pin_map.md.
module tt_um_evan_youan_yu_ppe (
    input wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input wire clk,
    input wire rst_n
);
    reg [15:0] imem [0:15];
    reg [15:0] valid;
    reg [3:0] pc;
    reg [11:0] wait_count;
    reg waiting;
    reg running;
    reg fault;
    reg [7:0] gpio_out;
    reg [7:0] gpio_oe;
    reg [7:0] gpio_meta;
    reg [7:0] gpio_sync;
    reg req_meta;
    reg req_sync;
    reg ack;
    reg [3:0] load_addr;
    reg [1:0] nibble_idx;
    reg [11:0] load_shift;
    reg loader_full;

    wire [15:0] instr = imem[pc];
    wire [2:0] cmd = ui_in[6:4];
    wire [3:0] nibble = ui_in[3:0];
    wire request = req_sync != ack;

    assign uo_out = {ack, running, fault, loader_full, pc};
    assign uio_out = gpio_out;
    assign uio_oe = (rst_n && ena && running) ? gpio_oe : 8'h00;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            valid <= 16'h0000;
            pc <= 4'h0;
            wait_count <= 12'h000;
            waiting <= 1'b0;
            running <= 1'b0;
            fault <= 1'b0;
            gpio_out <= 8'h00;
            gpio_oe <= 8'h00;
            gpio_meta <= 8'h00;
            gpio_sync <= 8'h00;
            req_meta <= 1'b0;
            req_sync <= 1'b0;
            ack <= 1'b0;
            load_addr <= 4'h0;
            nibble_idx <= 2'h0;
            load_shift <= 12'h000;
            loader_full <= 1'b0;
        end else begin
            gpio_meta <= uio_in;
            gpio_sync <= gpio_meta;
            req_meta <= ui_in[7];
            req_sync <= req_meta;
            if (ena) begin
                if (request) begin
                    ack <= req_sync;
                    case (cmd)
                        3'd0: begin
                            if (running || loader_full) begin
                                fault <= 1'b1;
                            end else begin
                                case (nibble_idx)
                                    2'd0: load_shift[3:0] <= nibble;
                                    2'd1: load_shift[7:4] <= nibble;
                                    2'd2: load_shift[11:8] <= nibble;
                                    2'd3: begin
                                        imem[load_addr] <= {nibble, load_shift};
                                        valid[load_addr] <= 1'b1;
                                        if (load_addr == 4'hf)
                                            loader_full <= 1'b1;
                                        else
                                            load_addr <= load_addr + 4'h1;
                                    end
                                endcase
                                nibble_idx <= nibble_idx + 2'h1;
                            end
                        end
                        3'd1: begin
                            if (valid[0]) begin
                                pc <= 4'h0;
                                wait_count <= 12'h000;
                                waiting <= 1'b0;
                                running <= 1'b1;
                                gpio_out <= 8'h00;
                                gpio_oe <= 8'h00;
                            end else begin
                                fault <= 1'b1;
                            end
                        end
                        3'd2: begin
                            running <= 1'b0;
                            waiting <= 1'b0;
                            wait_count <= 12'h000;
                        end
                        3'd3: begin
                            running <= 1'b0;
                            fault <= 1'b0;
                            valid <= 16'h0000;
                            pc <= 4'h0;
                            wait_count <= 12'h000;
                            waiting <= 1'b0;
                            gpio_out <= 8'h00;
                            gpio_oe <= 8'h00;
                            load_addr <= 4'h0;
                            nibble_idx <= 2'h0;
                            load_shift <= 12'h000;
                            loader_full <= 1'b0;
                        end
                        default: fault <= 1'b1;
                    endcase
                end else if (running) begin
                    if (!valid[pc]) begin
                        fault <= 1'b1;
                        running <= 1'b0;
                    end else if (waiting) begin
                        if (wait_count == 12'd1) begin
                            wait_count <= 12'h000;
                            waiting <= 1'b0;
                            pc <= pc + 4'h1;
                        end else begin
                            wait_count <= wait_count - 12'h001;
                        end
                    end else begin
                        case (instr[15:12])
                            4'h1: begin
                                gpio_out <= instr[7:0];
                                pc <= pc + 4'h1;
                            end
                            4'h2: begin
                                if (instr[11:0] == 12'h000)
                                    pc <= pc + 4'h1;
                                else begin
                                    wait_count <= instr[11:0];
                                    waiting <= 1'b1;
                                end
                            end
                            4'h3: pc <= instr[3:0];
                            4'h4: begin
                                gpio_oe <= instr[7:0];
                                pc <= pc + 4'h1;
                            end
                            4'h5: begin
                                if (gpio_sync[instr[2:0]] == instr[3])
                                    pc <= pc + 4'h1;
                            end
                            4'hf: running <= 1'b0;
                            default: begin
                                fault <= 1'b1;
                                running <= 1'b0;
                            end
                        endcase
                    end
                end
            end
        end
    end

`ifdef FORMAL
    reg formal_past_valid = 1'b0;
    always @(posedge clk) begin
        if (!formal_past_valid)
            assume (!rst_n);
        formal_past_valid <= 1'b1;
        if (!rst_n || !ena || !running)
            assert (uio_oe == 8'h00);
        if (rst_n && formal_past_valid && $past(rst_n)) begin
            if ($past(running && waiting && ena && !request && wait_count > 12'd1))
                assert (pc == $past(pc));
            if ($past(!running && ena && !request))
                assert (pc == $past(pc));
            if ($past(request && cmd == 3'd0 && loader_full && ena))
                assert (valid == $past(valid));
        end
        cover (running && waiting);
    end
`endif
endmodule

`default_nettype wire
