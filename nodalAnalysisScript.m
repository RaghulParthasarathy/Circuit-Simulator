function [voltageDrop, nodeVoltages, componentCurrents] = nodalAnalysisScript(filename)
    % Read the input data from a text file and perform nodal analysis
    % Input: filename - Name of the text file containing circuit configuration
    % Output: 
    %   voltageDrop - Voltage difference between specified nodes
    %   nodeVoltages - Voltages at all nodes
    %   componentCurrents - Currents through each component

    try
        % Open the file for reading
        fileID = fopen(filename, 'r');
        if fileID == -1
            error('Could not open file %s.', filename);
        end

        % Read the number of nodes
        line = fgetl(fileID);
        if ~contains(line, 'numNodes:')
            error('Invalid file format. First line should contain numNodes:');
        end
        numNodes = str2double(strrep(line, 'numNodes: ', ''));

        % Read voltage sources
        line = fgetl(fileID);
        if ~contains(line, 'VdcSources:')
            error('Invalid file format. Expected VdcSources: section');
        end
        
        % Read multiple voltage sources
        vSources = {};
        while true
            line = fgetl(fileID);
            if isempty(line) || strcmp(line, 'Components:')
                break;
            end
            tokens = strsplit(strtrim(line));
            vSource.node1 = str2double(tokens{1});
            vSource.node2 = str2double(tokens{2});
            vSource.value = str2double(tokens{3});
            vSources{end+1} = vSource;
        end

        % Read the components
        components = {};
        while ~feof(fileID)
            line = fgetl(fileID);
            if isempty(line)
                continue;
            end
            if startsWith(line, 'findVoltageBetween:')
                break;
            end
            tokens = strsplit(strtrim(line));
            if length(tokens) < 4
                continue;
            end
            node1 = str2double(tokens{1});
            node2 = str2double(tokens{2});
            type = tokens{3};
            value = str2double(tokens{4});
            % Optional component name
            name = '';
            if length(tokens) >= 5
                name = tokens{5};
            end
            components{end+1} = {node1, node2, type, value, name};
        end

        % Read voltage measurement points
        tokens = strsplit(strrep(line, 'findVoltageBetween: ', ''));
        findVoltageBetween = [str2double(tokens{1}), str2double(tokens{2})];

        % Close the file
        fclose(fileID);

        % Input validation
        if numNodes < 2
            error('Circuit must have at least 2 nodes');
        end
        if isempty(vSources)
            error('Circuit must have at least one voltage source');
        end
        if isempty(components)
            error('Circuit must have at least one component');
        end

        % Perform nodal analysis
        [voltageDrop, nodeVoltages, componentCurrents] = nodalAnalysis(numNodes, components, vSources, findVoltageBetween);

        % Display results
        fprintf('\nCircuit Analysis Results:\n');
        fprintf('------------------------\n');
        fprintf('Voltage drop between nodes %d and %d: %.3f V\n', ...
                findVoltageBetween(1), findVoltageBetween(2), voltageDrop);
        
        fprintf('\nNode Voltages:\n');
        for i = 1:length(nodeVoltages)
            fprintf('Node %d: %.3f V\n', i, nodeVoltages(i));  % 1-indexed
        end
        
        fprintf('\nComponent Currents:\n');
        for i = 1:length(components)
            comp = components{i};
            if ~isempty(comp{5})
                name = comp{5};
            else
                name = sprintf('%s%d', comp{3}, i);
            end
            fprintf('%s (between nodes %d-%d): %.3f A\n', ...
                    name, comp{1}, comp{2}, componentCurrents(i));
        end

    catch ME
        % Error handling
        if fileID ~= -1
            fclose(fileID);
        end
        fprintf('Error: %s\n', ME.message);
        rethrow(ME);
    end
end