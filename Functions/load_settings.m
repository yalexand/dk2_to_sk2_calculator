       function settings = load_settings(fname,~)
             settings = [];   
             if exist(fname,'file') 
                 try
                [ xml_settings, ~ ] = xml_read (fname);                                 
                settings.DefaultDirectory = xml_settings.DefaultDirectory;                                                                  
                settings.ExcelDirectory = xml_settings.ExcelDirectory;
                 catch
                     disp('error loading settings file');
                 end
             end
        end