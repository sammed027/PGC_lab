#!/usr/bin/env python3
"""Small two-core MSI/MESI/MOESI cache-coherence trace simulator."""
import sys

def run(protocol, layout, iterations):
    states = [{"A": "I", "B": "I"} for _ in range(2)]
    stats = {"BusRd": 0, "BusRdX": 0, "BusUpgr": 0,
             "invalidations": 0, "writeback": 0, "c2c": 0,
             "silent E->M": 0}
    xline, yline = ("A", "A") if layout == "adjacent" else ("A", "B")
    trace = []
    for _ in range(iterations):
        trace.extend([(0, xline, "R"), (0, xline, "W"),
                      (1, yline, "R"), (1, yline, "W")])
    log = []
    for core, line, op in trace:
        mine = states[core][line]
        other = states[1-core][line]
        if op == "R":
            if mine == "I":
                stats["BusRd"] += 1
                if other in ("M", "O"):
                    if protocol == "MOESI":
                        states[1-core][line] = "O"
                        stats["c2c"] += 1
                    else:
                        states[1-core][line] = "S"
                        stats["writeback"] += 1
                elif other == "E":
                    states[1-core][line] = "S"
                states[core][line] = "E" if other == "I" and protocol != "MSI" else "S"
        else:
            if mine == "E":
                states[core][line] = "M"
                stats["silent E->M"] += 1
            elif mine == "M":
                pass
            else:
                if mine in ("S", "O"):
                    stats["BusUpgr"] += 1
                else:
                    stats["BusRdX"] += 1
                    if other in ("M", "O"):
                        if protocol == "MOESI":
                            stats["c2c"] += 1
                        else:
                            stats["writeback"] += 1
                if other != "I":
                    stats["invalidations"] += 1
                states[1-core][line] = "I"
                states[core][line] = "M"
        log.append((core, op, states[0][line], states[1][line]))
    stats["bus transactions"] = stats["BusRd"] + stats["BusRdX"] + stats["BusUpgr"]
    return stats, log

if __name__ == "__main__":
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 1000
    print(f"State trace, first 2 iterations, adjacent layout (line A: core0 / core1)")
    for proto in ("MSI", "MESI", "MOESI"):
        _, log = run(proto, "adjacent", 2)
        print(f"\n{proto}:")
        for core, op, c0, c1 in log:
            print(f" core{core} {op} -> C0={c0} C1={c1}")
    keys = ["bus transactions", "BusRd", "BusRdX", "BusUpgr",
            "invalidations", "writeback", "c2c", "silent E->M"]
    print(f"\nTotals for {n} iterations")
    print("layout    protocol " + " ".join(f"{k:>16}" for k in keys))
    for layout in ("adjacent", "padded"):
        for proto in ("MSI", "MESI", "MOESI"):
            st, _ = run(proto, layout, n)
            print(f"{layout:9} {proto:8} " + " ".join(f"{st[k]:16d}" for k in keys))
