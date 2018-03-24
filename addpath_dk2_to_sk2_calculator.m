function addpath_dk2_to_sk2_calculator()
        
    if ~isdeployed    
            thisdir = fileparts( mfilename( 'fullpath' ) );
            addpath( thisdir,...
                    [thisdir filesep 'Functions'],...
                    [thisdir filesep 'Functions' filesep 'xml_io_tools'],...
                    [thisdir filesep 'GUIDEInterfaces']); 
    end
            
end