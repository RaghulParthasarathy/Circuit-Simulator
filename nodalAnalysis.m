function voltageDrop = nodalAnalysis(numNodes, components, VdcSource, findVoltageBetween)
    % Perform nodal analysis to find the voltage drop between two nodes
    % Inputs:
    % numNodes - Total number of nodes in the circuit
    % components - Cell array of components with {node1, node2, 'type', value}
    % VdcSource - Struct with fields: node1, node2, value (for DC sources)
    % findVoltageBetween - Array [nodeA, nodeB] to calculate voltage drop

    % Initialize matrices
    G = zeros(numNodes, numNodes);    % Conductance matrix
    I = zeros(numNodes, 1);           % Current injection vector

    % Fill in the conductance matrix for each component
    for i = 1:length(components)
        comp = components{i};
        node1 = comp{1};
        node2 = comp{2};
        type = comp{3};
        value = comp{4};

        if strcmp(type, 'R')          % Resistor
            conductance = 1 / value;   % G = 1/R
            if node1 > 0
                G(node1, node1) = G(node1, node1) + conductance;
            end
            if node2 > 0
                G(node2, node2) = G(node2, node2) + conductance;
            end
            if node1 > 0 && node2 > 0
                G(node1, node2) = G(node1, node2) - conductance;
                G(node2, node1) = G(node2, node1) - conductance;
            end

        elseif strcmp(type, 'L')      % Inductor (short circuit for DC)
            conductance = 1e12;        % Very high conductance to simulate a short
            if node1 > 0
                G(node1, node1) = G(node1, node1) + conductance;
            end
            if node2 > 0
                G(node2, node2) = G(node2, node2) + conductance;
            end
            if node1 > 0 && node2 > 0
                G(node1, node2) = G(node1, node2) - conductance;
                G(node2, node1) = G(node2, node1) - conductance;
            end

        elseif strcmp(type, 'C')      % Capacitor (open circuit for DC)
            % For DC, a capacitor acts as an open circuit
            % Do nothing: no conductance contribution
        end
    end

    % Apply the DC voltage source
    if VdcSource.node1 > 0
        I(VdcSource.node1) = I(VdcSource.node1) + VdcSource.value;
    end
    if VdcSource.node2 > 0
        I(VdcSource.node2) = I(VdcSource.node2) - VdcSource.value;
    end

    % Solve the system of equations G * V = I
    V = G \ I;               % Solve for node voltages

    % Calculate the voltage drop between the specified nodes
    nodeA = findVoltageBetween(1);
    nodeB = findVoltageBetween(2);
    voltageDrop = V(nodeA) - V(nodeB);
end