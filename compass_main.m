classdef CompassPresentation < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        Image                         matlab.ui.control.Image
        ClearAccelerationDataButton   matlab.ui.control.Button
        ClearCompassDataButton        matlab.ui.control.Button
        LoadDataButton                matlab.ui.control.Button
        ClearMagneticFieldDataButton  matlab.ui.control.Button
        SensorGroupOneCompassLabel    matlab.ui.control.Label
        UIAccelerationTable           matlab.ui.control.Table
        CreateAccelerationCSVButton   matlab.ui.control.Button
        DisplayStdEditField           matlab.ui.control.NumericEditField
        UICompassTable                matlab.ui.control.Table
        DisplayMeanXButton            matlab.ui.control.Button
        EditField                     matlab.ui.control.NumericEditField
        DisplayStdXButton             matlab.ui.control.Button
        CreateCompassCSVButton        matlab.ui.control.Button
        ReadThingSpeakButton          matlab.ui.control.Button
        UploadtoThingSpeakButton      matlab.ui.control.Button
        DisplayMeanYButton            matlab.ui.control.Button
        EditField_2                   matlab.ui.control.NumericEditField
        DisplayStdYButton             matlab.ui.control.Button
        DisplayStdEditField_2         matlab.ui.control.NumericEditField
        UIAccelerationGraph           matlab.ui.control.UIAxes
        UICompassGraph                matlab.ui.control.UIAxes
        UIMagneticFieldGraph          matlab.ui.control.UIAxes
    end

 
  % Group Members: Jasleen Sohal, Isha Date, Mark Hagiwara, and Abraham Hadaf
    
    properties (Access = public)
     c1 % Description
        readAPIKey= '2EECXRX1VUDSKFLX' % Description
       im 
    end
    

    methods (Access = private)
        
        function results = func(app)
            
        end
    end


    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadDataButton
        function LoadDataButtonPushed(app, event)
           
            
         [filename,filepath] = uigetfile('*.mat','Select a File to Open');
          if filename == 0
              return;
          end
          fullname = [filepath, filename];
          data = load(fullname);
           app.im = data
          if isfield(data, 'Acceleration')
              app.UIAccelerationTable.Data = timetable2table(data.Acceleration);
              accelerationX = table2array(data.Acceleration(:,1));
              accelerationY = table2array(data.Acceleration(:,2));
              accelerationZ = table2array(data.Acceleration(:,3));

            x=  plot(app.UIAccelerationGraph, accelerationX, 'r');
            y=  plot(app.UIAccelerationGraph, accelerationY);
                
            [X,Y]= meshgrid(x,y) % could not use surf command because component library lacks 3D axis 
            % meshgrid function creates a 2D grid with x and y coordinates 
          
           
             figure 
             boxplot(table2array(data.Acceleration(:,1:2)));xlabel('X-Y')              
             
          end   
          
          if isfield(data, 'Position')
              app.UICompassTable.Data = timetable2table(data.Position);
              positionX = table2array(data.Position(:,1));
              plot(app.UICompassGraph, positionX, 'r');
              
              figure
              v = data.Position(:,2) % represents longitude
              u = data.Position(:,1) % represents latitude 
              th = linspace(pi/4,2*pi,10); % represents angle with respect to pi 
              r =linspace(min(table2array(u)),max(table2array(u)),10) % represents the distance from the center 
              [u,v] = pol2cart(th,r); % represents the conversion from recangular to polar
              hold on % in an effort to not overwrite the previous graph
              c = compass(u,v) % This function converts from polar to compass coordinates 
              c1 = c(end); % the last data point collected 
              c1.LineWidth = 2;  
              c1.Color = 'r'; 

          end
          
          if isfield(data, 'MagneticField')
              app.UICompassTable.Data = timetable2table(data.MagneticField);
              magneticFieldX = table2array(data.MagneticField(:,1));
              magneticFieldY = table2array(data.MagneticField(:,2));
              plot(app.UIMagneticFieldGraph, magneticFieldX, magneticFieldY, 'r');
          end
        end

        % Button pushed function: ClearAccelerationDataButton
        function ClearAccelerationDataButtonPushed(app, event)
            if isempty(app.UIAccelerationTable.Data)
                return
            else
                app.UIAccelerationTable.Data(:,:)= [] ;
                cla(app.UIAccelerationGraph)
                cla(app.UIAccelerationBoxPlotGraph)
                
            end
        end

        % Button pushed function: ClearMagneticFieldDataButton
        function ClearMagneticFieldDataButtonPushed(app, event)
            if isempty(app.UIMagneticFieldGraph)
                return
            else
                cla(app.UIMagneticFieldGraph)
                
            end
        end

        % Button pushed function: ClearCompassDataButton
        function ClearCompassDataButtonPushed(app, event)
            if isempty(app.UICompassTable.Data)
                return
            else
                app.UICompassTable.Data(:,:)= [] ;
                cla(app.UICompassGraph)
                
            end        
        end

        % Button pushed function: DisplayMeanXButton
        function DisplayMeanXButtonPushed2(app, event)
           if isempty(app.UIAccelerationTable.Data)
               errordlg('Load Acceleration data first.', 'Error!')
           else 
               app.EditField.Value = mean(app.UIAccelerationTable.Data.X)
           end
        end

        % Button pushed function: DisplayStdXButton
        function DisplayStdXButtonPushed(app, event)
            if isempty(app.UIAccelerationTable.Data)
                errordlg('Load Acceleration data first.', 'Error!')
            else 
                app.DisplayStdEditField.Value = std(app.UIAccelerationTable.Data.X)
            end
        end

        % Button pushed function: CreateAccelerationCSVButton
        function CreateAccelerationCSVButtonPushed(app, event)
            
            accelerationTable = app.UIAccelerationTable.Data;                        
            [filename, ~]=uiputfile('*.csv', 'Save');
            if filename == 0
                return;
            end
            
            writetable(accelerationTable,filename)
        end

        % Button pushed function: CreateCompassCSVButton
        function CreateCompassCSVButtonPushed(app, event)
            
            compassTable = app.UICompassTable.Data;                        
            [filename, ~]=uiputfile('*.csv', 'Save');
            if filename == 0
                return;
            end
            
            writetable(compassTable,filename)
        end

        % Button pushed function: UploadtoThingSpeakButton
        function UploadtoThingSpeakButtonPushed(app, event)
            writeApiKey= '865SJC4TZYYNP3CK'
            channelID= 1249643

             
             Test= app.UIAccelerationTable.Data
             thingSpeakWrite(channelID,'Fields', [1,2,3], 'Values', Test(1:100:end, 2:end), 'WriteKey', writeApiKey, 'Timestamp', Test.Timestamp(1:100:end))
             
             Test2= app.UICompassTable.Data
             thingSpeakWrite(channelID,'Fields', [4,5,6], 'Values', Test2(1:100:end, 2:end), 'WriteKey', writeApiKey, 'Timestamp', Test2.Timestamp(1:100:end))
             msgbox('Data sent to thingspeak')
        end

        % Button pushed function: ReadThingSpeakButton
        function ReadThingSpeakButtonPushed(app, event)
            channelID= 1249643;
            data= thingSpeakRead(channelID,'Fields', [1,2,3])
            data2= thingSpeakRead(channelID,'Fields', [4,5,6])                    

        end

        % Button pushed function: DisplayMeanYButton
        function DisplayMeanYButtonPushed(app, event)
            if isempty(app.UIAccelerationTable.Data)
                 errordlg('Load Acceleration data first.', 'Error!')
           else 
               app.EditField_2.Value = mean(app.UIAccelerationTable.Data.Y)
          
            end
        end

        % Button pushed function: DisplayStdYButton
        function DisplayStdYButtonPushed(app, event)
            if isempty(app.UIAccelerationTable.Data)
                errordlg('Load Acceleration data first.', 'Error!')
            else 
                app.DisplayStdEditField_2.Value = std(app.UIAccelerationTable.Data.Y)
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.702 0.651 0.651];
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [249 154 140 134];
            app.Image.ImageSource = 'Compass Image.jpg';

            % Create ClearAccelerationDataButton
            app.ClearAccelerationDataButton = uibutton(app.UIFigure, 'push');
            app.ClearAccelerationDataButton.ButtonPushedFcn = createCallbackFcn(app, @ClearAccelerationDataButtonPushed, true);
            app.ClearAccelerationDataButton.Position = [72 266 100 22];
            app.ClearAccelerationDataButton.Text = 'Clear Data';

            % Create ClearCompassDataButton
            app.ClearCompassDataButton = uibutton(app.UIFigure, 'push');
            app.ClearCompassDataButton.ButtonPushedFcn = createCallbackFcn(app, @ClearCompassDataButtonPushed, true);
            app.ClearCompassDataButton.Position = [481 266 100 22];
            app.ClearCompassDataButton.Text = 'Clear Data';

            % Create LoadDataButton
            app.LoadDataButton = uibutton(app.UIFigure, 'push');
            app.LoadDataButton.ButtonPushedFcn = createCallbackFcn(app, @LoadDataButtonPushed, true);
            app.LoadDataButton.Position = [481 127 110 22];
            app.LoadDataButton.Text = 'Load Data Button';

            % Create ClearMagneticFieldDataButton
            app.ClearMagneticFieldDataButton = uibutton(app.UIFigure, 'push');
            app.ClearMagneticFieldDataButton.ButtonPushedFcn = createCallbackFcn(app, @ClearMagneticFieldDataButtonPushed, true);
            app.ClearMagneticFieldDataButton.Position = [271 294 100 22];
            app.ClearMagneticFieldDataButton.Text = 'Clear Data';

            % Create SensorGroupOneCompassLabel
            app.SensorGroupOneCompassLabel = uilabel(app.UIFigure);
            app.SensorGroupOneCompassLabel.HorizontalAlignment = 'center';
            app.SensorGroupOneCompassLabel.FontSize = 24;
            app.SensorGroupOneCompassLabel.FontWeight = 'bold';
            app.SensorGroupOneCompassLabel.Position = [151 439 353 32];
            app.SensorGroupOneCompassLabel.Text = 'Sensor Group One - Compass';

            % Create UIAccelerationTable
            app.UIAccelerationTable = uitable(app.UIFigure);
            app.UIAccelerationTable.ColumnName = {'Timestamp'; 'AccelerationX'; 'AccelerationY'; 'AccelerationZ'};
            app.UIAccelerationTable.RowName = {};
            app.UIAccelerationTable.Position = [26 34 191 92];

            % Create CreateAccelerationCSVButton
            app.CreateAccelerationCSVButton = uibutton(app.UIFigure, 'push');
            app.CreateAccelerationCSVButton.ButtonPushedFcn = createCallbackFcn(app, @CreateAccelerationCSVButtonPushed, true);
            app.CreateAccelerationCSVButton.Position = [461 90 149 22];
            app.CreateAccelerationCSVButton.Text = 'Create Acceleration CSV';

            % Create DisplayStdEditField
            app.DisplayStdEditField = uieditfield(app.UIFigure, 'numeric');
            app.DisplayStdEditField.Position = [118 169 94 22];

            % Create UICompassTable
            app.UICompassTable = uitable(app.UIFigure);
            app.UICompassTable.ColumnName = {'Timestamp'; 'Latitude'; 'Longitude'; 'Speed'};
            app.UICompassTable.RowName = {};
            app.UICompassTable.Position = [405 160 227 92];

            % Create DisplayMeanXButton
            app.DisplayMeanXButton = uibutton(app.UIFigure, 'push');
            app.DisplayMeanXButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayMeanXButtonPushed2, true);
            app.DisplayMeanXButton.Position = [18 230 102 22];
            app.DisplayMeanXButton.Text = 'Display Mean X ';

            % Create EditField
            app.EditField = uieditfield(app.UIFigure, 'numeric');
            app.EditField.Position = [119 230 94 22];

            % Create DisplayStdXButton
            app.DisplayStdXButton = uibutton(app.UIFigure, 'push');
            app.DisplayStdXButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayStdXButtonPushed, true);
            app.DisplayStdXButton.Position = [20 169 99 22];
            app.DisplayStdXButton.Text = 'Display Std X';

            % Create CreateCompassCSVButton
            app.CreateCompassCSVButton = uibutton(app.UIFigure, 'push');
            app.CreateCompassCSVButton.ButtonPushedFcn = createCallbackFcn(app, @CreateCompassCSVButtonPushed, true);
            app.CreateCompassCSVButton.Position = [469 57 134 22];
            app.CreateCompassCSVButton.Text = 'Create Compass CSV';

            % Create ReadThingSpeakButton
            app.ReadThingSpeakButton = uibutton(app.UIFigure, 'push');
            app.ReadThingSpeakButton.ButtonPushedFcn = createCallbackFcn(app, @ReadThingSpeakButtonPushed, true);
            app.ReadThingSpeakButton.Position = [261 69 111 22];
            app.ReadThingSpeakButton.Text = 'Read ThingSpeak';

            % Create UploadtoThingSpeakButton
            app.UploadtoThingSpeakButton = uibutton(app.UIFigure, 'push');
            app.UploadtoThingSpeakButton.ButtonPushedFcn = createCallbackFcn(app, @UploadtoThingSpeakButtonPushed, true);
            app.UploadtoThingSpeakButton.Position = [249 104 136 22];
            app.UploadtoThingSpeakButton.Text = 'Upload to ThingSpeak';

            % Create DisplayMeanYButton
            app.DisplayMeanYButton = uibutton(app.UIFigure, 'push');
            app.DisplayMeanYButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayMeanYButtonPushed, true);
            app.DisplayMeanYButton.Position = [18 209 103 22];
            app.DisplayMeanYButton.Text = 'Display Mean Y ';

            % Create EditField_2
            app.EditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.EditField_2.Position = [119 209 94 22];

            % Create DisplayStdYButton
            app.DisplayStdYButton = uibutton(app.UIFigure, 'push');
            app.DisplayStdYButton.ButtonPushedFcn = createCallbackFcn(app, @DisplayStdYButtonPushed, true);
            app.DisplayStdYButton.Position = [20 148 99 22];
            app.DisplayStdYButton.Text = 'Display Std Y';

            % Create DisplayStdEditField_2
            app.DisplayStdEditField_2 = uieditfield(app.UIFigure, 'numeric');
            app.DisplayStdEditField_2.Position = [118 148 94 22];

            % Create UIAccelerationGraph
            app.UIAccelerationGraph = uiaxes(app.UIFigure);
            title(app.UIAccelerationGraph, 'Acceleration vs. Time')
            xlabel(app.UIAccelerationGraph, 'Time (s)')
            ylabel(app.UIAccelerationGraph, 'Acceleration (m/s^2)')
            zlabel(app.UIAccelerationGraph, 'Z')
            app.UIAccelerationGraph.PlotBoxAspectRatio = [1.8121546961326 1 1];
            app.UIAccelerationGraph.FontSize = 10;
            app.UIAccelerationGraph.Position = [19 294 206 138];

            % Create UICompassGraph
            app.UICompassGraph = uiaxes(app.UIFigure);
            title(app.UICompassGraph, 'Compass')
            xlabel(app.UICompassGraph, 'Longitude')
            ylabel(app.UICompassGraph, 'Latitude ')
            app.UICompassGraph.PlotBoxAspectRatio = [1.75879396984925 1 1];
            app.UICompassGraph.FontSize = 10;
            app.UICompassGraph.Position = [405 294 217 147];

            % Create UIMagneticFieldGraph
            app.UIMagneticFieldGraph = uiaxes(app.UIFigure);
            title(app.UIMagneticFieldGraph, 'Magnetic Field ')
            xlabel(app.UIMagneticFieldGraph, 'x')
            ylabel(app.UIMagneticFieldGraph, 'y')
            app.UIMagneticFieldGraph.PlotBoxAspectRatio = [2.27350427350427 1 1];
            app.UIMagneticFieldGraph.FontSize = 10;
            app.UIMagneticFieldGraph.Position = [224 327 173 106];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CompassPresentation

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end