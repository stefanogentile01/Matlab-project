% Task 1: Read the provided CSV files into MATLAB tables.
opts = detectImportOptions("weather.csv");
opts.VariableNamingRule = 'preserve';                                       % Set to 'preserve' to keep original column headers
weather = readtable("weather.csv", opts);

% I set the delimiter in order to detect the end of oen column 
consumption = readtable("consumption.csv", ...
    VariableNamingRule="preserve", Delimiter=',');                          

consumption.Properties.VariableNames(1) = "time";                           % I renamed time because it cannot start with underscore
consumption.Properties.VariableNames(2) = "value";                          % I renamed value because it cannot start with underscore
weather.Properties.VariableNames(1) = "time";                               % I renamed time because it cannot start with underscore

% Task 1: Convert the timestamp information to the proper format and set it as the row times.
weather.time = datetime(weather.time, ...
    InputFormat= "yyyy-MM-dd'T'HH:mm:ssX", TimeZone="UTC");
consumption.time = datetime(consumption.time, ...
    InputFormat="yyyy-MM-dd'T'HH:mm:ssX", TimeZone="UTC");


%% 
% Task 4: Implement a method to handle NaN values in the consumption data

%sort  the values and see that some are missing 
%interpolation filling with middle value sample
%if 50% of the value are missing 

% Create missing values for consumption data 
% Define the desired date range. - minutes(15) for having the same number
% of rows as weather
startDate = min(consumption.time - minutes(15));
startDate.TimeZone = "UTC";
endDate = max(consumption.time);
endDate.TimeZone = "UTC";
interval = minutes(15);         
desiredDateTimes = startDate:interval:endDate;
desiredDateTimes.TimeZone = "UTC";
% Find missing date-times
missingDateTimes = setdiff(desiredDateTimes, consumption.time);
% Create tuples for missing date-times
nans = nan(length(missingDateTimes), 1);
missingData = table(missingDateTimes' , nans );
% I renamed time because it has to be the same same as the consumption data
missingData.Properties.VariableNames(1) = "time";                           
% I renamed time because it has to be the same same as the consumption data
missingData.Properties.VariableNames(2) = "value";                          
% Combine original data with missing data
consumption = [consumption; missingData];
% Sort the consumption table according to the time
consumption = sortrows(consumption, 1);

% Sort the consumption table according to the time
weather = sortrows(weather, 1);

%summary(consumption)

% Set the NaN values to the average value since interp1 is not working 
consumption.value = fillmissing(consumption.value, 'constant', ...
    mean(consumption.value(~isnan(consumption.value))));




%% 

% Task 2: Join the weather and consumption tables based on the shared timestamp.
weatherconsumption = join( weather, consumption, 'Keys', 'time');

%xlables 
%caption


%%
figure;
% Task 3: Create a subplot with two plots: one for solar GHI and another for electrical consumption
subplot(2, 1, 1); % 2 rows, 1 column, first plot
plot( weatherconsumption.solarGHI);
title('Solar GHI');
ylabel('GHI (W/m^2)');


subplot(2, 1, 2); % 2 rows, 1 column, second plot
plot(weatherconsumption.value);
title('Electrical Consumption');
ylabel('Consumption (kWh)');
%% 
% Task 5: Resample the data using retime() to obtain total daily and weekly consumption.

newTable = timetable(weatherconsumption.time, weatherconsumption.value);
dailyTotal = retime(newTable, 'daily', 'sum');
weeklyTotal = retime(newTable, 'weekly', 'sum');

dailyTotal.Properties.VariableNames(1) = "Sum";                           
weeklyTotal.Properties.VariableNames(1) = "Sum";                           


%% 
figure;

% Task 6: Apply groupsummary() to evaluate total consumption by day of the week.
dayOfWeek = day(newTable.Time, 'dayofweek');                                % Extract the day of the week from the datetime values

newTable.DoF = dayOfWeek;                                                   % Add the day of the week as a variable to the timetable

doWConsumption = groupsummary(newTable, "DoF", "sum", "Var1");              % Use groupsummary to calculate total consumption for each day of the week

% Task 6: Plot the average and deviation of consumption by day of the week.
hold on
plot(doWConsumption.DoF, doWConsumption.sum_Var1 / doWConsumption.GroupCount)
%std(doWConsumption.sum_Var1 / doWConsumption.GroupCount)
title('Consumption By Day Of The Week');
xticklabels({'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'});
xlabel('Day of the week');
ylabel("GHI (W/m^2)")

hold off

% Task 6: Identify and annotate vertical lines for the maximum and minimum day of the week

yline(sum(max(doWConsumption.sum_Var1 / doWConsumption.GroupCount)), 'r-', "Max");

yline(sum(min(doWConsumption.sum_Var1 / doWConsumption.GroupCount)), 'r-', "Min");



%% 

% Task 7: Retrieve week number and day of the week as new parameters.
weekOfYearTable = table(week(newTable.Time));
weekOfYearTable = renamevars(weekOfYearTable, "Var1", "WeekOfYear");
dayOfWeekTable = [timetable2table(newTable) weekOfYearTable];
dayOfWeekTable = renamevars(dayOfWeekTable, "Var1", "Consumption");
%% 

% Task 8: Explore the potential of integrating a solar power plant by analyzing solar GHI data.
creativity
plot()
plotting solar ghi and one for electrical consumption
labling 
changing the scale to logaritmic
correlation

github

%% 
figure;

% Task 9: Plot and visualize the total weekly consumption.
plot(doWConsumption.sum_Var1);                                              % plot
hold on
title('Weekly Consumption');
xticklabels({'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'});
xlabel('Day of the week');
ylabel("GHI (W/m^2)")
hold off
display(doWConsumption)                                                     % visualize

% Task 9: Save the total weekly consumption data in a CSV file.
writetable(doWConsumption, "dayOfWeekConsumption.csv");


% Task 10: Provide comments in the MATLAB code for clarity.

