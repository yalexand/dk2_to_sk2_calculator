function varargout = dk2_to_sk2_calculator_gui(varargin)
% DK2_TO_SK2_CALCULATOR_GUI MATLAB code for dk2_to_sk2_calculator_gui.fig
%      DK2_TO_SK2_CALCULATOR_GUI, by itself, creates a new DK2_TO_SK2_CALCULATOR_GUI or raises the existing
%      singleton*.
%
%      H = DK2_TO_SK2_CALCULATOR_GUI returns the handle to a new DK2_TO_SK2_CALCULATOR_GUI or the handle to
%      the existing singleton*.
%
%      DK2_TO_SK2_CALCULATOR_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DK2_TO_SK2_CALCULATOR_GUI.M with the given input arguments.
%
%      DK2_TO_SK2_CALCULATOR_GUI('Property','Value',...) creates a new DK2_TO_SK2_CALCULATOR_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dk2_to_sk2_calculator_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dk2_to_sk2_calculator_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dk2_to_sk2_calculator_gui

% Last Modified by GUIDE v2.5 02-May-2018 12:27:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dk2_to_sk2_calculator_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dk2_to_sk2_calculator_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before dk2_to_sk2_calculator_gui is made visible.
function dk2_to_sk2_calculator_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dk2_to_sk2_calculator_gui (see VARARGIN)

% Choose default command line output for dk2_to_sk2_calculator_gui
handles.output = hObject;

handles.settings_filename = 'dk2_to_sk2_calculator_settings.xml';
handles.settings = load_settings([pwd filesep handles.settings_filename]);

           if isempty(handles.settings)
                hw = waitbar(0,'looking for Excel directory..');
                waitbar(0.1,hw);                
                if ispc
                       prevdir = pwd;
                       cd('c:\');
                       [~,b] = dos('dir /s /b excel.exe');
                       if ~strcmp(b,'File Not Found')
                            filenames = textscan(b,'%s','delimiter',char(10));
                            s = char(filenames{1});
                            s = s(1,:);
                            s = strsplit(s,'excel.exe');
                            handles.settings.ExcelDirectory = s{1};
                            handles.settings.DefaultDirectory = pwd;
                       end
                       cd(prevdir);
                elseif ismac
                    % to do
                else
                    % to do
                end                
                delete(hw); drawnow;                               
           save_settings([pwd filesep handles.settings_filename],handles.settings);                
           end

% these are for dk2 only           
handles.tau_D = 3500;
handles.tau_DA = 1000;
handles.beta_DA = 0.44;

% Update handles structure
guidata(hObject, handles);

recalculate(hObject,handles);

% UIWAIT makes dk2_to_sk2_calculator_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dk2_to_sk2_calculator_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function load_data_and_calculate_correction_Callback(hObject, eventdata, handles)
% hObject    handle to load_data_and_calculate_correction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

        [filename, pathname] = uigetfile('*.xls;*.xlsx;*.csv','Select dk2 data table',handles.settings.DefaultDirectory);
        if pathname == 0, return, end;
        
        try
            full_fname  = [pathname filesep filename];            
            [num,txt,raw] = xlsread(full_fname);
            handles.settings.DefaultDirectory = pathname;
            guidata(hObject, handles);
        catch
            errordlg('incompatible data table - can not continue');
        end
        
        data = [];
        try
            Nrec = size(num,1);
            hw = waitbar(0,'calculating sk2 corrections, please wait');
            for k=1:Nrec
                if ~isempty(hw), waitbar(k/Nrec,hw); drawnow, end;
                tau_D = num(k,1);
                tau_DA = num(k,2);
                beta_DA = num(k,3);
                %
                try
                    ret = adjust_sk2_decay(tau_D,tau_DA,beta_DA);
                catch
                    ret = nan(1,9);
                end
                %
                rec =  [ ret.tau_D ret.eta_dk2 ret.eta_sk2 ret.beta_DA_dk2 ret.beta_DA_sk2 ...    
                         ret.tau_DA_dk2 ret.tau_DA_sk2 ret.E_dk2 ret.E_sk2 ];
                data = [data; rec];     
                %
            end
            if ~isempty(hw), delete(hw), drawnow; end;
        catch 
        end
        %
        data = num2cell(data);
        caption = {'tau_D','eta_dk2','eta_sk2','beta_dk2','beta_sk2', ... 
                        'tau_DA_dk2','tau_DA_sk2','E_dk2','E_sk2'};
        data = [caption; data];
        %
        try
            fname = [tempname '.xls'];
            xlswrite(fname,data);
            old_dir = pwd;
            directory = strrep(handles.settings.ExcelDirectory,'EXCEL.EXE','');
            cd(directory);
            system(['excel ' fname]);
            cd(old_dir);
        catch
                [filename, pathname] = uiputfile( ...
                    {'*.xls';'*.xlsx';'*.csv'}, ...
                    'Save as');
                xlswrite([pathname filesep filename],data);
        end
        %
        save_settings([pwd filesep handles.settings_filename],handles.settings);


function tauD_dk2_Callback(hObject, eventdata, handles)
% hObject    handle to tauD_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauD_dk2 as text
%        str2double(get(hObject,'String')) returns contents of tauD_dk2 as a double
tau_D = str2double(get(hObject,'String'));
if ~isnan(tau_D) && tau_D > handles.tau_DA
    handles.tau_D = tau_D;
    guidata(hObject, handles);
    recalculate(hObject, handles);
else
    set(handles.tauD_dk2,'String',num2str(handles.tau_D));
    set(handles.tauD_sk2,'String',num2str(handles.tau_D));
end


% --- Executes during object creation, after setting all properties.
function tauD_dk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauD_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tauFRET_dk2_Callback(hObject, eventdata, handles)
% hObject    handle to tauFRET_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauFRET_dk2 as text
%        str2double(get(hObject,'String')) returns contents of tauFRET_dk2 as a double
tau_DA = str2double(get(hObject,'String'));
if ~isnan(tau_DA) && tau_DA < handles.tau_D
    handles.tau_DA = tau_DA;
    guidata(hObject, handles);
    recalculate(hObject, handles);
else
    set(handles.tauFRET_dk2,'String',num2str(handles.tau_DA));
end    


% --- Executes during object creation, after setting all properties.
function tauFRET_dk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauFRET_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function beta_dk2_Callback(hObject, eventdata, handles)
% hObject    handle to beta_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta_dk2 as text
%        str2double(get(hObject,'String')) returns contents of beta_dk2 as a double
beta_DA = str2double(get(hObject,'String'));
if ~isnan(beta_DA) && 0 < beta_DA && beta_DA < 1
    handles.beta_DA = beta_DA;
    guidata(hObject, handles);
    recalculate(hObject, handles);
else
    set(handles.beta_dk2,'String',num2str(handles.beta_DA));
end    


% --- Executes during object creation, after setting all properties.
function beta_dk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function eta_dk2_Callback(hObject, eventdata, handles)
% hObject    handle to eta_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eta_dk2 as text
%        str2double(get(hObject,'String')) returns contents of eta_dk2 as a double


% --- Executes during object creation, after setting all properties.
function eta_dk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eta_dk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function tauD_sk2_Callback(hObject, eventdata, handles)
% hObject    handle to tauD_sk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tauD_sk2 as text
%        str2double(get(hObject,'String')) returns contents of tauD_sk2 as a double


% --- Executes during object creation, after setting all properties.
function tauD_sk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauD_sk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function tauFRET_sk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tauFRET_sk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function beta_sk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta_sk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function eta_sk2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eta_sk2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function recalculate(hObject,handles)

tau_D = handles.tau_D;
tau_DA = handles.tau_DA;
beta_DA = handles.beta_DA;
                %
                try
                    ret = adjust_sk2_decay(tau_D,tau_DA,beta_DA);
                catch
                    ret = nan(1,9);
                end
                %
set(handles.tauFRET_sk2,'String',ret.tau_DA_sk2);
set(handles.tauFRET_dk2,'String',ret.tau_DA_dk2);
set(handles.beta_sk2,'String',ret.beta_DA_sk2);
set(handles.beta_dk2,'String',ret.beta_DA_dk2);
set(handles.eta_sk2,'String',ret.eta_sk2);
set(handles.eta_dk2,'String',ret.eta_dk2);
set(handles.sk2_E,'String',ret.E_sk2);
set(handles.dk2_E,'String',ret.E_dk2);
set(handles.tauD_dk2,'String',ret.tau_D);
set(handles.tauD_sk2,'String',ret.tau_D);
    
% Update handles structure
guidata(hObject, handles);
