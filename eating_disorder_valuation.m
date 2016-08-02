function eating_disorder_valuation(Display, Joyconfig, Subject, path)
    d = clock;
    commandwindow;
    cd('./Data/Behavior');


    Config.stimuluscount = 20;
    Config.edcount = length(Subject.edlist);
    
    if Subject.mri == 1
        j = [2 3 4 5 6];
    else j = 2;
    end
    Config.jitter = BalanceTrials(Config.stimuluscount*3, 1, j);
    
    cd('./Data/Behavior');
    
    Stimulus.scenarios = importdata('scenarios.txt');
    Stimulus.neutrals = importdata('neutral_behav.txt');
    
    
