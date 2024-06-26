function write_to_file(data, filename)
    % Open file for writing
    fid = fopen(filename, 'w');
    if fid == -1
        error('Unable to open file for writing.');
    end
    
    % Write data to file in hexadecimal format
    for i = 1:numel(data)
        fprintf(fid, '0x%s , ', hex(data(i)));
    end
    
    % Close file
    fclose(fid);
end