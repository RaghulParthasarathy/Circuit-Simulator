# Circuit Simulator (DC + Transient Analysis using Modified Nodal Analysis)

This MATLAB-based circuit simulator performs DC and Laplace-domain (transient) analysis using Modified Nodal Analysis (MNA). It supports resistors, capacitors, inductors, and multiple DC voltage sources, allowing users to compute node voltages, component currents, and voltage differences between nodes.

## 🚀 Features

- Supports DC voltage sources, resistors (R), inductors (L), and capacitors (C)
- Uses Modified Nodal Analysis (MNA)
- Approximates transient behavior (DC limits: capacitors as open, inductors as short)
- Reads circuit configurations from text files
- Reports node voltages, component currents, and voltage differences
- Well-suited for circuit theory and electrical engineering education

## 📁 File Structure

- `nodalAnalysis.m`: Core function implementing MNA for solving the circuit
- `nodalAnalysisScript.m`: File I/O and result display wrapper for `nodalAnalysis.m`
- `example_circuit.txt`: Sample input file (user-provided or to be created)
  
## 📄 Input File Format

The input file should follow this structure:

```plaintext
numNodes: 6
VdcSources:
1 0 12       # 12V source between node 1 and ground
5 0 5        # 5V source between node 5 and ground
Components:
1 2 R 100    R1      # 100 ohm resistor from node 1 to 2
2 3 L 0.1    L1      # 0.1 H inductor from node 2 to 3
3 0 C 1e-6   C1      # 1 µF capacitor from node 3 to ground
2 4 R 220    R2      # 220 ohm resistor from node 2 to 4
4 5 R 470    R3      # 470 ohm resistor from node 4 to 5
4 0 R 1000   R4      # 1k ohm resistor to ground
3 5 L 0.2    L2      # 0.2 H inductor from node 3 to 5
5 6 C 2e-6   C2      # 2 µF capacitor from node 5 to 6
6 0 R 330    R5      # 330 ohm resistor to ground
findVoltageBetween: 1 0
