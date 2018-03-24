       function save_settings(fname,settings)
            try
                xml_write(fname,settings);
            catch
                disp('xml_write: error, settings were not saved');
            end
        end