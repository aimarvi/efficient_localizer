function run_effloc(subj_id, run_id)
% Experiment code for the Efficient Localizer
% Created by Sam Hutchinson for the Kanwisher Lab 06/26/2023
% Last edited 2/4/2025, by Sam Hutchinson
% Added better log file and RT tracking
%
% Email samhutch@mit.edu with any questions, or ask the current
% Kanwisher lab labtech!
%
% IMPORTANT: this code has been tested on Linux, Matlab R2022a
%
% NOTE 1: TIMING
%
% (3 x 18-sec fixations) + (10 x 22-sec blocks) = 274 seconds
% For TR=2sec, that's 137 IPS!
%
%
% NOTE 2: PARADIGM FILES
%
% Para files saved as: 'Onset', 'Vis_Condition'/'Aud_Condition', 'Duration'
%
% Vis Conditions: Fixation (0), Faces (1), Scenes (2), Bodies (3), Objects
% (4), Words on scrambled objects (5)
%
% Aud Conditions: Fixation (0), False Beleif (1), False Photo (2), 
% Nonwords (3), Quilted Nonwords (4), Arithmetic (5)
%
%
% NOTE 3: LOGGING KEYPRESSES
%
% The script will look for button presses corresponding to "1" and "2,"
% 1 corresponding to "match" and 2 to "mismatch," and WILL NOT RECORD
% PRESSES THAT ARE NOT 1 OR 2, so check your scanner setup and change
% the script accordingly!
%
% For MIT scanner buttons, blue is 1 and yellow is 2

sca;
clc;

%CHECK THESE! 1 for yes, 0 for no
full_window = 1;
test_run = 0;
in_scanner = 0;

%define experiment parameters
fixation_time = 18.0; %secs
stim_length = 20.5;
trial_isi = 1.5;

%define visual stimulus blocks
vis_runs = [...
    0 1 2 3 4 5 0 5 4 3 2 1 0
    0 2 3 4 5 1 0 1 5 4 3 2 0
    0 3 4 5 1 2 0 2 1 5 4 3 0
    0 4 5 1 2 3 0 3 2 1 5 4 0
    0 5 1 2 3 4 0 4 3 2 1 5 0];

%define audio stimulus blocks
aud_runs = [...
    0 1 2 3 4 5 0 4 3 2 1 5 0
    0 5 1 2 3 4 0 3 2 1 5 4 0
    0 4 5 1 2 3 0 2 1 5 4 3 0
    0 3 4 5 1 2 0 1 5 4 3 2 0
    0 2 3 4 5 1 0 5 4 3 2 1 0];

%initialzie PTB
fprintf('Initializing PsychToolbox...\n');
Screen('Preference', 'Verbosity', 0);
%Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);

%set keys for scanner
KbName('UnifyKeyNames'); %to ensure cross-computer compatibility
trigger_key = KbName('+');

%where to find the stimuli
proj_path = pwd;
stim_path = strcat(proj_path, '/stims/');

%calculate other experiment parameters
vis_design = vis_runs(run_id, :);
aud_design = aud_runs(run_id, :);
num_blocks = size(vis_design, 2);
answers = cell(num_blocks, 1);
trial_length = stim_length + trial_isi;

%opens the PTB window, pass 1 for full window or 0 for a small window
[window, windowRect, windowData] = make_window(full_window);
if full_window == 1
    HideCursor;
end

%define size of videos
vid_size = [0, 0, round(0.75*windowRect(3)), round(0.75*windowRect(4))];
[vid_rect, vid_left, vid_top] = CenterRect(vid_size, windowRect);

%wait for scanning trigger
DrawFormattedText(window, 'Waiting for scanner trigger...', 'center', 'center');
Screen('Flip', window);
if in_scanner == 1
    KbName('UnifyKeyNames');
    go = 0;
    while go == 0
        [touch, ~, key_code] = KbCheck(-1);
        WaitSecs(0.0001);
        if touch && key_code(trigger_key)
            go = 1;
        end
    end
else
    WaitSecs(2);
end
Screen('Flip', window);

%main experiment loop

%set timing variables to measure latency
experiment_start = GetSecs;
cpu_time = experiment_start;
real_time = 0;

%open log text file
logtext = fopen(['./logs/' subj_id '_run' num2str(run_id) '_log.txt'], 'w');

for block_idx = 1:num_blocks

    %log precise info about timing
    block_start = GetSecs;
    log.block(block_idx).block_start = GetSecs - experiment_start;
    log.block(block_idx).vis_condition = vis_design(block_idx);
    log.block(block_idx).aud_condition = aud_design(block_idx);

    %Fixation blocks
    if vis_design(block_idx) == 0
        
        correction_time = GetSecs - cpu_time;
        real_time = real_time + fixation_time + correction_time;
        cpu_time = cpu_time + fixation_time + correction_time;

        %draws fixation at center
        draw_fix(window, windowData.xCent, windowData.yCent, 0, 0);
        while GetSecs <= cpu_time
        end
        Screen('Flip', window);

        %log timing info
        log.block(block_idx).block_len = GetSecs - block_start;
        log.block(block_idx).block_end = real_time;
    
    %Stimulus blocks
    else

        load_start = GetSecs;

        %log precise info about timing
        log.block(block_idx).start = GetSecs - load_start;
        trial_start = GetSecs;
        correction_time = GetSecs - cpu_time;
        real_time = real_time + correction_time;
        cpu_time = cpu_time + correction_time + trial_length;
        stim_end = trial_start + stim_length;
        resp_ind = trial_start + 15;


        %find appropriate stimulus
        subj_name = subj_id;
        stem = strcat(pwd, '/stims/', sprintf('/run%s_block%s', int2str(run_id), int2str(block_idx)), '*');
        n = dir(stem).name;
        file = strcat(pwd, '/stims/', n);

        %Load movie
        movie = Screen('OpenMovie', window, file);
        Screen('PlayMovie', movie, 1);

        fprintf(['\nPlaying movie: ' file '\n']);
        vis_cond = vis_design(block_idx);
        aud_cond = aud_design(block_idx);
        fprintf(logtext, '%s\n', ['Playing movie (vis ' num2str(vis_cond) ' aud ' num2str(aud_cond) '): ' file]);

        %Run through each frame of the movie
        start_time = GetSecs;
        user_ans = [];

        trial_rt = 0;
        
        while GetSecs <= stim_end
            
            starts = GetSecs;

            % Wait for next movie frame, retrieve texture handle to it
            tex = Screen('GetMovieImage', window, movie);
            
            % Valid texture returned? A negative value means end of movie reached:
            if tex<=0
                % We're done, break out of loop:
                break;
            end
            
            % Draw the new texture immediately to screen:
            Screen('DrawTexture', window, tex, [], vid_rect);
            if GetSecs >= resp_ind
                Screen('FrameRect', window, [255 255 0], [], 10);
            end
            Screen('Flip', window);

            % Release texture:
            Screen('Close', tex);

            %check for a response
            [press, ~, key] = KbCheck(-1);
            if press

                if trial_rt == 0
                    trial_rt = GetSecs() - trial_start;
                end

                if find(key) == KbName('1!')
                    user_ans(end+1) = find(key);
                elseif find(key) == KbName('2@')
                    user_ans(end+1) = find(key);
                end

            end

        end
        
        %Close movie:
        Screen('CloseMovie', movie);
        Screen('FrameRect', window, [255 255 0], [], 10);
        Screen('Flip', window);

        draw_fix(window, windowData.xCent, windowData.yCent, 0, 1);
        while GetSecs < cpu_time

            [press, ~, key] = KbCheck(-1);

            if press

                if trial_rt == 0
                    trial_rt = GetSecs() - trial_start;
                end

                if find(key) == KbName('1!')
                    user_ans(end+1) = find(key);
                elseif find(key) == KbName('2@')
                    user_ans(end+1) = find(key);
                end


            end

        end

        %check for button press after block if not in test trial
        if test_run == 0
            
            match_trial = true;
            if contains(n, 'incorrect')
                match_trial = false;
            end

            if isempty(user_ans)
                answers(block_idx) = {0};
                fprintf('incorrect (no press or buttons are wrong)')
                fprintf(logtext, '%s\n', ['Incorrect, no press or buttons are wrong',]);

            elseif match_trial && user_ans(end) == KbName('1!')
                answers(block_idx) = {1};
                fprintf('correct ')
                fprintf(logtext, '%s\n', ['Correct, pressed 1',]);
        
            elseif ~match_trial && user_ans(end) == KbName('2@')
                answers(block_idx) = {1};
                fprintf('correct ')
                fprintf(logtext, '%s\n', ['Correct, pressed 2',]);

            elseif (~match_trial && user_ans(end) == KbName('1!')) || (match_trial && user_ans(end) == KbName('2@'))
                answers(block_idx) = {0};
                fprintf('incorrect (wrong press)')
                fprintf(logtext, '%s\n', ['Incorrect, wrong press',]);
            end

            fprintf(['Trial RT: ' num2str(trial_rt)]);
            fprintf(logtext, '%s\n', ['Trial RT: ' num2str(trial_rt)]);
        end

        while GetSecs < cpu_time
        end

        %log precise info about timing
        log.block(block_idx).video_end = GetSecs - load_start;
        log.block(block_idx).end = GetSecs - load_start;
        log.block(block_idx).video_len = log.block(block_idx).video_end - log.block(block_idx).start;
        log.block(block_idx).blank_len = log.block(block_idx).end - log.block(block_idx).video_end;
        log.block(block_idx).block_len = GetSecs - block_start;
        log.block(block_idx).block_end = real_time;
        log.block(block_idx).rt = trial_rt;

    end

end

%get summary info and write to para files
total_time = GetSecs - experiment_start;
block_onsets = round([log.block(:).block_start]', 1);
block_vis_nums = [log.block(:).vis_condition]';
block_aud_nums = [log.block(:).aud_condition]';
block_durs = round([log.block(:).block_len]', 1);
trial_rts = round([log.block(:).rt]', 2);

%log answers
log.answers = answers;
acc = length(find(cell2mat(answers)==1))/10;
fprintf(['Run accuracy: ' num2str(acc)]);
fprintf(logtext, '%s\n', ['Run accuracy: ' num2str(acc)]);

%don't save info of test runs
if test_run == 0
    try
        %save out para file with onset, condition, duration
        T1 = table(block_onsets, block_vis_nums, block_durs, 'VariableNames', {'Onset', 'Vis_Condition', 'Duration'});
        para_name1 = sprintf('./paras/%s_%s_vis.para', subj_id, int2str(run_id));
        writetable(T1, para_name1, 'FileType', 'text', 'Delimiter', 'tab', 'WriteVariableNames', false);
        
        T2 = table(block_onsets, block_aud_nums, block_durs, 'VariableNames', {'Onset', 'Aud_Condition', 'Duration'});
        para_name2 = sprintf('./paras/%s_%s_aud.para', subj_id, int2str(run_id));
        writetable(T2, para_name2, 'FileType', 'text', 'Delimiter', 'tab', 'WriteVariableNames', false);
        
        save(sprintf('./logs/log_%s_%s.mat', subj_id, int2str(run_id)), 'log');

        fclose(logtext);
    catch
        fprintf('Error saving run data!')
    end
end

%close the screen and print done
sca;
% fprintf('Run %s done! Task accuracy: %0.5f\n', int2str(run_id), acc)

end