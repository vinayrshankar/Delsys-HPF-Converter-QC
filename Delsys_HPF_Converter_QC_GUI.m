function Delsys_HPF_Converter_QC_GUI
% DELSYS_HPF_CONVERTER_QC_GUI
% Universal, study-agnostic GUI for Delsys HPF discovery, QC, and export.
%
% Author:  Vinay Shankar
% Website: https://tfaworld.org/
% Email:   vinay@tfaworld.org
% Version: 1.1.0
% Copyright (c) 2026 Vinay Shankar. All rights reserved.
%
% Features
%   - Recursive or single-folder HPF discovery
%   - Include/exclude filename keywords
%   - Include/exclude folder-path keywords
%   - Configurable EMG/ACC sample-rate QC
%   - Up to 16 ordered sensor definitions
%   - Sensor types: Ignore, EMG only, ACC only, EMG + ACC
%   - Stream-by-stream QC before conversion
%   - Separate EMG and ACC tab-delimited outputs
%   - Never overwrites existing converted files
%   - Save/load reusable MATLAB .mat configuration profiles
%
% Requirements
%   - MATLAB with UI components (uifigure)
%   - Delsys EMGworks MATLAB Conversion Library (HPF.dll)
%
% NOTE: This application never modifies source HPF files.
%
% Project attribution: Vinay Shankar | vinay@tfaworld.org | https://tfaworld.org/

%% -------------------------- Application metadata -------------------------
APP_NAME = 'Delsys HPF Converter + QC';
APP_VERSION = '1.1.0';
APP_AUTHOR = 'Vinay Shankar';
APP_WEBSITE = 'https://tfaworld.org/';
APP_EMAIL = 'vinay@tfaworld.org';
APP_COPYRIGHT = 'Copyright (c) 2026 Vinay Shankar. All rights reserved.';

%% ---------------------------- State -------------------------------------
state = struct();
state.files = struct([]);
state.dllLoadedPath = '';
state.qcFingerprint = '';
state.lastQCReport = '';

%% ----------------------------- Figure -----------------------------------
fig = uifigure( ...
    'Name',sprintf('%s v%s | %s | %s',APP_NAME,APP_VERSION,APP_AUTHOR,APP_WEBSITE), ...
    'Position',[80 80 1280 820]);

tg = uitabgroup(fig,'Position',[10 10 1260 800]);
setupTab = uitab(tg,'Title','1. Setup');
mapTab   = uitab(tg,'Title','2. Channel Map');
qcTab    = uitab(tg,'Title','3. Files & QC');
logTab   = uitab(tg,'Title','Log');
aboutTab = uitab(tg,'Title','About');

%% ----------------------------- Setup tab --------------------------------
sg = uigridlayout(setupTab,[15 4]);
sg.ColumnWidth = {180,'1x',110,110};
sg.RowHeight = repmat({34},1,15);
sg.Padding = [14 14 14 14];
sg.RowSpacing = 8;
sg.ColumnSpacing = 8;

tmpLbl = uilabel(sg,'Text','Delsys HPF.dll','FontWeight','bold'); tmpLbl.Layout.Row = 1; tmpLbl.Layout.Column = 1;
dllField = uieditfield(sg,'text','Value',defaultDLLPath());
dllField.Layout.Row = 1; dllField.Layout.Column = [2 3];
dllBrowse = uibutton(sg,'Text','Browse...','ButtonPushedFcn',@browseDLL);
dllBrowse.Layout.Row = 1; dllBrowse.Layout.Column = 4;

tmpLbl = uilabel(sg,'Text','Input root folder','FontWeight','bold'); tmpLbl.Layout.Row = 2; tmpLbl.Layout.Column = 1;
inputField = uieditfield(sg,'text','Value','');
inputField.Layout.Row = 2; inputField.Layout.Column = [2 3];
inputBrowse = uibutton(sg,'Text','Browse...','ButtonPushedFcn',@browseInput);
inputBrowse.Layout.Row = 2; inputBrowse.Layout.Column = 4;

tmpLbl = uilabel(sg,'Text','Output root folder','FontWeight','bold'); tmpLbl.Layout.Row = 3; tmpLbl.Layout.Column = 1;
outputField = uieditfield(sg,'text','Value','');
outputField.Layout.Row = 3; outputField.Layout.Column = [2 3];
outputBrowse = uibutton(sg,'Text','Browse...','ButtonPushedFcn',@browseOutput);
outputBrowse.Layout.Row = 3; outputBrowse.Layout.Column = 4;

recursiveCheck = uicheckbox(sg,'Text','Search subfolders recursively','Value',true);
recursiveCheck.Layout.Row = 4; recursiveCheck.Layout.Column = [1 2];
preserveCheck = uicheckbox(sg,'Text','Preserve source folder structure in output','Value',true);
preserveCheck.Layout.Row = 4; preserveCheck.Layout.Column = [3 4];

tmpLbl = uilabel(sg,'Text','Include filename keywords'); tmpLbl.Layout.Row = 5; tmpLbl.Layout.Column = 1;
includeFileField = uieditfield(sg,'text','Placeholder','e.g. MVC, Walk, Trial');
includeFileField.Layout.Row = 5; includeFileField.Layout.Column = 2;
includeMode = uidropdown(sg,'Items',{'Match ANY','Match ALL'},'Value','Match ANY');
includeMode.Layout.Row = 5; includeMode.Layout.Column = 3;
tmpLbl = uilabel(sg,'Text','comma or ; separated','FontAngle','italic'); tmpLbl.Layout.Row = 5; tmpLbl.Layout.Column = 4;

tmpLbl = uilabel(sg,'Text','Exclude filename keywords'); tmpLbl.Layout.Row = 6; tmpLbl.Layout.Column = 1;
excludeFileField = uieditfield(sg,'text','Placeholder','e.g. test, backup');
excludeFileField.Layout.Row = 6; excludeFileField.Layout.Column = [2 4];

tmpLbl = uilabel(sg,'Text','Include folder/path keywords'); tmpLbl.Layout.Row = 7; tmpLbl.Layout.Column = 1;
includeFolderField = uieditfield(sg,'text','Placeholder','Optional: folders/path terms; ANY match');
includeFolderField.Layout.Row = 7; includeFolderField.Layout.Column = [2 4];

tmpLbl = uilabel(sg,'Text','Exclude folder/path keywords'); tmpLbl.Layout.Row = 8; tmpLbl.Layout.Column = 1;
excludeFolderField = uieditfield(sg,'text','Placeholder','Optional: archive, output, backup, etc.');
excludeFolderField.Layout.Row = 8; excludeFolderField.Layout.Column = [2 4];

tmpLbl = uilabel(sg,'Text','Expected EMG sample rate (Hz)'); tmpLbl.Layout.Row = 9; tmpLbl.Layout.Column = 1;
emgFsField = uieditfield(sg,'numeric','Value',1925.93,'Limits',[0 Inf]);
emgFsField.Layout.Row = 9; emgFsField.Layout.Column = 2;
tmpLbl = uilabel(sg,'Text','Tolerance ± Hz'); tmpLbl.Layout.Row = 9; tmpLbl.Layout.Column = 3;
emgTolField = uieditfield(sg,'numeric','Value',2.0,'Limits',[0 Inf]);
emgTolField.Layout.Row = 9; emgTolField.Layout.Column = 4;

tmpLbl = uilabel(sg,'Text','Expected ACC sample rate (Hz)'); tmpLbl.Layout.Row = 10; tmpLbl.Layout.Column = 1;
accFsField = uieditfield(sg,'numeric','Value',148.15,'Limits',[0 Inf]);
accFsField.Layout.Row = 10; accFsField.Layout.Column = 2;
tmpLbl = uilabel(sg,'Text','Tolerance ± Hz'); tmpLbl.Layout.Row = 10; tmpLbl.Layout.Column = 3;
accTolField = uieditfield(sg,'numeric','Value',1.0,'Limits',[0 Inf]);
accTolField.Layout.Row = 10; accTolField.Layout.Column = 4;

failUnexpectedCheck = uicheckbox(sg, ...
    'Text','Fail QC on unexpected sample rates', ...
    'Value',true);
failUnexpectedCheck.Layout.Row = 11; failUnexpectedCheck.Layout.Column = [1 2];

deepQCCheck = uicheckbox(sg, ...
    'Text','Deep QC: verify stream data lengths', ...
    'Value',true);
deepQCCheck.Layout.Row = 11; deepQCCheck.Layout.Column = [3 4];

neverOverwriteLabel = uilabel(sg, ...
    'Text','Safety: existing output files are NEVER overwritten.', ...
    'FontWeight','bold');
neverOverwriteLabel.Layout.Row = 12; neverOverwriteLabel.Layout.Column = [1 4];

saveCfgBtn = uibutton(sg,'Text','Save Configuration...','ButtonPushedFcn',@saveConfig);
saveCfgBtn.Layout.Row = 13; saveCfgBtn.Layout.Column = 1;
loadCfgBtn = uibutton(sg,'Text','Load Configuration...','ButtonPushedFcn',@loadConfig);
loadCfgBtn.Layout.Row = 13; loadCfgBtn.Layout.Column = 2;
resetBtn = uibutton(sg,'Text','Reset Channel Map','ButtonPushedFcn',@resetChannelMap);
resetBtn.Layout.Row = 13; resetBtn.Layout.Column = 3;
openOutBtn = uibutton(sg,'Text','Open Output Folder','ButtonPushedFcn',@openOutputFolder);
openOutBtn.Layout.Row = 13; openOutBtn.Layout.Column = 4;

tmpLbl = uilabel(sg,'Text',sprintf('Author: %s  |  %s  |  %s  |  Configuration profiles are portable .mat files.',APP_AUTHOR,APP_EMAIL,APP_WEBSITE), ...
    'FontAngle','italic');
tmpLbl.Layout.Row = 14; tmpLbl.Layout.Column = [1 4];

tmpLbl = uilabel(sg,'Text','Workflow: Setup → Channel Map → Scan Files → Run QC → Convert Passed', ...
    'FontWeight','bold');
tmpLbl.Layout.Row = 15; tmpLbl.Layout.Column = [1 4];

%% --------------------------- Channel map tab -----------------------------
mg = uigridlayout(mapTab,[3 1]);
mg.RowHeight = {60,'1x',60};
mg.Padding = [14 14 14 14];

mapHelp = uilabel(mg, ...
    'Text',['Define sensors in the exact order they occur in the HPF stream. ', ...
            'ACC means 3-axis X/Y/Z. EMG + ACC means 1 EMG stream followed by X/Y/Z ACC streams.'], ...
    'WordWrap','on');
mapHelp.Layout.Row = 1;

mapData = cell(16,3);
for r = 1:16
    mapData{r,1} = r;
    mapData{r,2} = sprintf('Channel%02d',r);
    mapData{r,3} = 'Ignore';
end

channelTable = uitable(mg, ...
    'Data',mapData, ...
    'ColumnName',{'Order','Label','Sensor Type'}, ...
    'ColumnEditable',[false true true], ...
    'ColumnFormat',{'numeric','char',{'Ignore','EMG only','ACC only','EMG + ACC'}}, ...
    'ColumnWidth',{80,260,180});
channelTable.Layout.Row = 2;

mapFooter = uilabel(mg, ...
    'Text',['Examples: an accelerometer-only head sensor = ACC only; ', ...
            'a muscle sensor with EMG and accelerometer = EMG + ACC. ', ...
            'Unused rows should remain Ignore.'], ...
    'WordWrap','on');
mapFooter.Layout.Row = 3;

%% -------------------------- Files & QC tab -------------------------------
qg = uigridlayout(qcTab,[5 1]);
qg.RowHeight = {44,260,34,'1x',28};
qg.Padding = [12 12 12 12];
qg.RowSpacing = 8;

bg = uigridlayout(qg,[1 6]);
bg.ColumnWidth = {120,120,140,145,150,'1x'};
bg.Layout.Row = 1;
scanBtn = uibutton(bg,'Text','Scan Files','ButtonPushedFcn',@scanFiles);
qcBtn = uibutton(bg,'Text','Run QC','ButtonPushedFcn',@runQC);
convertBtn = uibutton(bg,'Text','Convert Passed','ButtonPushedFcn',@convertPassed);
exportQCBtn = uibutton(bg,'Text','Export QC Report','ButtonPushedFcn',@exportQCReport);
clearBtn = uibutton(bg,'Text','Clear Results','ButtonPushedFcn',@clearResults);
qcStatus = uilabel(bg,'Text','Ready','HorizontalAlignment','right');

summaryTable = uitable(qg, ...
    'Data',cell(0,10), ...
    'ColumnName',{'Use','File','Folder','QC Status','Streams','EMG','ACC','Unexpected','Expected','Note'}, ...
    'ColumnEditable',[true false false false false false false false false false], ...
    'ColumnFormat',{'logical','char','char','char','numeric','numeric','numeric','numeric','numeric','char'}, ...
    'ColumnWidth',{45,260,290,110,65,55,55,85,75,300}, ...
    'CellSelectionCallback',@summarySelection);
summaryTable.Layout.Row = 2;

tmpLbl = uilabel(qg,'Text','Selected file stream audit','FontWeight','bold'); tmpLbl.Layout.Row = 3; tmpLbl.Layout.Column = 1;

streamTable = uitable(qg, ...
    'Data',cell(0,8), ...
    'ColumnName',{'Stream','Sample Rate (Hz)','Observed','Expected Sensor','Expected Signal','Output Label','Match','Comment'}, ...
    'ColumnEditable',false, ...
    'ColumnWidth',{60,120,100,160,110,160,70,300});
streamTable.Layout.Row = 4;

qcHint = uilabel(qg, ...
    'Text','QC is required before conversion. Changing the configuration invalidates prior QC.', ...
    'FontAngle','italic');
qcHint.Layout.Row = 5;

%% ------------------------------ Log tab ----------------------------------
lg = uigridlayout(logTab,[1 1]);
lg.Padding = [10 10 10 10];
logArea = uitextarea(lg,'Editable','off','Value',{sprintf('%s v%s started. Author: %s | %s | %s',APP_NAME,APP_VERSION,APP_AUTHOR,APP_EMAIL,APP_WEBSITE)});

%% ------------------------------ About tab --------------------------------
ag = uigridlayout(aboutTab,[8 1]);
ag.RowHeight = {60,36,36,36,36,70,36,'1x'};
ag.Padding = [24 24 24 24];
ag.RowSpacing = 10;

aboutTitle = uilabel(ag,'Text',sprintf('%s v%s',APP_NAME,APP_VERSION), ...
    'FontSize',24,'FontWeight','bold','HorizontalAlignment','center');
aboutTitle.Layout.Row = 1;

authorLabel = uilabel(ag,'Text',['Author: ' APP_AUTHOR], ...
    'FontSize',16,'FontWeight','bold','HorizontalAlignment','center');
authorLabel.Layout.Row = 2;

emailLink = uihyperlink(ag,'Text',APP_EMAIL,'URL',['mailto:' APP_EMAIL], ...
    'HorizontalAlignment','center','FontSize',15);
emailLink.Layout.Row = 3;

websiteLink = uihyperlink(ag,'Text',APP_WEBSITE,'URL',APP_WEBSITE, ...
    'HorizontalAlignment','center','FontSize',15);
websiteLink.Layout.Row = 4;

copyrightLabel = uilabel(ag,'Text',APP_COPYRIGHT,'HorizontalAlignment','center');
copyrightLabel.Layout.Row = 5;

aboutBody = uilabel(ag, ...
    'Text',['A generic MATLAB interface for discovering, quality-checking, and converting Delsys EMGworks HPF recordings. ' ...
            'Configurations define file filters, sampling-rate rules, and ordered EMG/ACC sensor layouts without hard-coded study names.'], ...
    'WordWrap','on','HorizontalAlignment','center');
aboutBody.Layout.Row = 6;

aboutSite = uilabel(ag,'Text',['Project website: ' APP_WEBSITE], ...
    'HorizontalAlignment','center','FontAngle','italic');
aboutSite.Layout.Row = 7;

%% ========================================================================
% Nested callbacks and helpers
% ========================================================================

    function browseDLL(~,~)
        [f,p] = uigetfile({'*.dll','DLL files (*.dll)'},'Select Delsys HPF.dll');
        if isequal(f,0), return; end
        dllField.Value = fullfile(p,f);
        invalidateQC();
    end

    function browseInput(~,~)
        p = uigetdir(inputField.Value,'Select input root folder');
        if isequal(p,0), return; end
        inputField.Value = p;
        invalidateQC();
    end

    function browseOutput(~,~)
        startDir = outputField.Value;
        if isempty(startDir) || ~isfolder(startDir)
            startDir = inputField.Value;
        end
        p = uigetdir(startDir,'Select output root folder');
        if isequal(p,0), return; end
        outputField.Value = p;
        invalidateQC();
    end

    function openOutputFolder(~,~)
        p = strtrim(outputField.Value);
        if isempty(p) || ~isfolder(p)
            uialert(fig,'The output folder does not exist yet.','Output Folder');
            return
        end
        if ispc
            winopen(p);
        else
            uialert(fig,p,'Output Folder');
        end
    end

    function saveConfig(~,~)
        cfg = getConfigFromUI(false);
        if isempty(cfg), return; end
        [f,p] = uiputfile('*.mat','Save Delsys configuration','Delsys_HPF_Config.mat');
        if isequal(f,0), return; end
        config = cfg; %#ok<NASGU>
        save(fullfile(p,f),'config');
        appendLog(['Saved configuration: ' fullfile(p,f)]);
    end

    function loadConfig(~,~)
        [f,p] = uigetfile('*.mat','Load Delsys configuration');
        if isequal(f,0), return; end
        s = load(fullfile(p,f));
        if ~isfield(s,'config') || ~isstruct(s.config)
            uialert(fig,'The selected MAT file does not contain a valid variable named "config".','Invalid Configuration');
            return
        end
        applyConfigToUI(s.config);
        clearResults();
        appendLog(['Loaded configuration: ' fullfile(p,f)]);
    end

    function resetChannelMap(~,~)
        d = channelTable.Data;
        for rr = 1:16
            d{rr,1} = rr;
            d{rr,2} = sprintf('Channel%02d',rr);
            d{rr,3} = 'Ignore';
        end
        channelTable.Data = d;
        invalidateQC();
    end

    function scanFiles(~,~)
        cfg = getConfigFromUI(true);
        if isempty(cfg), return; end

        qcStatus.Text = 'Scanning...';
        drawnow;
        appendLog(['Scanning: ' cfg.inputRoot]);

        if cfg.recursive
            allHPF = dir(fullfile(cfg.inputRoot,'**','*.hpf'));
        else
            allHPF = dir(fullfile(cfg.inputRoot,'*.hpf'));
        end

        % Exclude the configured output tree if it sits inside input root.
        keep = true(numel(allHPF),1);
        if ~isempty(cfg.outputRoot)
            for i = 1:numel(allHPF)
                if pathIsInside(allHPF(i).folder,cfg.outputRoot)
                    keep(i) = false;
                end
            end
        end
        allHPF = allHPF(keep);

        incFile = splitKeywords(cfg.includeFileKeywords);
        excFile = splitKeywords(cfg.excludeFileKeywords);
        incFolder = splitKeywords(cfg.includeFolderKeywords);
        excFolder = splitKeywords(cfg.excludeFolderKeywords);

        selected = false(numel(allHPF),1);
        for i = 1:numel(allHPF)
            nm = lower(allHPF(i).name);
            fp = lower(allHPF(i).folder);

            ok = true;
            if ~isempty(incFile)
                hits = cellfun(@(k) contains(nm,lower(k)),incFile);
                if strcmp(cfg.includeFileMode,'Match ALL')
                    ok = ok && all(hits);
                else
                    ok = ok && any(hits);
                end
            end
            if ~isempty(excFile)
                ok = ok && ~any(cellfun(@(k) contains(nm,lower(k)),excFile));
            end
            if ~isempty(incFolder)
                ok = ok && any(cellfun(@(k) contains(fp,lower(k)),incFolder));
            end
            if ~isempty(excFolder)
                ok = ok && ~any(cellfun(@(k) contains(fp,lower(k)),excFolder));
            end
            selected(i) = ok;
        end
        allHPF = allHPF(selected);

        state.files = repmat(emptyFileRecord(),numel(allHPF),1);
        for i = 1:numel(allHPF)
            state.files(i).use = true;
            state.files(i).name = allHPF(i).name;
            state.files(i).folder = allHPF(i).folder;
            state.files(i).fullPath = fullfile(allHPF(i).folder,allHPF(i).name);
            state.files(i).status = 'NOT RUN';
        end

        state.qcFingerprint = '';
        refreshSummaryTable();
        streamTable.Data = cell(0,8);
        qcStatus.Text = sprintf('%d HPF file(s) found',numel(state.files));
        appendLog(sprintf('Scan complete: %d matching HPF file(s).',numel(state.files)));
    end

    function runQC(~,~)
        if isempty(state.files)
            uialert(fig,'Scan for HPF files first.','QC');
            return
        end
        cfg = getConfigFromUI(true);
        if isempty(cfg), return; end
        expected = buildExpectedStreams(cfg.channelMap);
        if isempty(expected.types)
            uialert(fig,'Define at least one non-Ignored channel in the Channel Map.','Channel Map Required');
            return
        end

        syncUseColumn();
        if ~ensureDLL(cfg.dllPath), return; end

        qcStatus.Text = 'Running QC...';
        drawnow;
        appendLog('Starting stream QC.');

        for i = 1:numel(state.files)
            if ~state.files(i).use
                state.files(i).status = 'NOT SELECTED';
                continue
            end
            try
                reader = HPF.HPFReader(state.files(i).fullPath);
                rates = double(reader.GetAllSampleRates);
                rates = rates(:);

                result = qcOneFile(rates,expected,cfg);
                if cfg.deepQC && strcmp(result.status,'PASS')
                    [dataOK,dataNote] = verifyStreamData(reader,expected);
                    if ~dataOK
                        result.status = 'FAIL';
                        result.note = [result.note ' ' dataNote];
                    elseif ~isempty(dataNote)
                        result.note = [result.note ' ' dataNote];
                    end
                end
                clear reader;
                state.files(i).sampleRates = rates;
                state.files(i).qc = result.detail;
                state.files(i).status = result.status;
                state.files(i).note = result.note;
                state.files(i).totalStreams = numel(rates);
                state.files(i).emgCount = result.emgCount;
                state.files(i).accCount = result.accCount;
                state.files(i).unexpectedCount = result.unexpectedCount;
                state.files(i).expectedCount = numel(expected.types);
            catch ME
                state.files(i).status = 'ERROR';
                state.files(i).note = ME.message;
                state.files(i).qc = cell(0,8);
                state.files(i).sampleRates = [];
                appendLog(['QC ERROR: ' state.files(i).fullPath ' | ' ME.message]);
            end
            if mod(i,10)==0 || i==numel(state.files)
                qcStatus.Text = sprintf('QC %d / %d',i,numel(state.files));
                drawnow;
            end
        end

        state.qcFingerprint = makeFingerprint(cfg);
        refreshSummaryTable();
        saveQCReports(cfg,false);

        nPass = sum(strcmp({state.files.status},'PASS'));
        nFail = sum(strcmp({state.files.status},'FAIL'));
        nErr  = sum(strcmp({state.files.status},'ERROR'));
        qcStatus.Text = sprintf('QC complete: %d PASS, %d FAIL, %d ERROR',nPass,nFail,nErr);
        appendLog(qcStatus.Text);
    end

    function convertPassed(~,~)
        if isempty(state.files)
            uialert(fig,'Scan and run QC first.','Convert');
            return
        end
        cfg = getConfigFromUI(true);
        if isempty(cfg), return; end
        if isempty(state.qcFingerprint) || ~strcmp(state.qcFingerprint,makeFingerprint(cfg))
            uialert(fig,'The configuration has changed since QC. Run QC again before conversion.','QC Required');
            return
        end
        if ~ensureDLL(cfg.dllPath), return; end

        expected = buildExpectedStreams(cfg.channelMap);
        syncUseColumn();
        if ~isfolder(cfg.outputRoot)
            mkdir(cfg.outputRoot);
        end

        passIdx = find([state.files.use] & strcmp({state.files.status},'PASS'));
        if isempty(passIdx)
            uialert(fig,'No selected files currently have PASS QC status.','Convert');
            return
        end

        qcStatus.Text = 'Converting...';
        appendLog(sprintf('Starting conversion of %d PASS file(s).',numel(passIdx)));
        converted = 0; skipped = 0; failed = 0;

        for z = 1:numel(passIdx)
            i = passIdx(z);
            try
                [didConvert,msg] = convertOneFile(state.files(i),expected,cfg);
                if didConvert
                    converted = converted + 1;
                    appendLog(['CONVERTED: ' state.files(i).fullPath]);
                else
                    skipped = skipped + 1;
                    appendLog(['SKIPPED: ' state.files(i).fullPath ' | ' msg]);
                end
            catch ME
                failed = failed + 1;
                appendLog(['CONVERSION ERROR: ' state.files(i).fullPath ' | ' ME.message]);
            end
            qcStatus.Text = sprintf('Convert %d / %d',z,numel(passIdx));
            drawnow;
        end

        qcStatus.Text = sprintf('Done: %d converted, %d skipped, %d failed',converted,skipped,failed);
        appendLog(qcStatus.Text);
    end

    function exportQCReport(~,~)
        cfg = getConfigFromUI(false);
        if isempty(cfg), return; end
        if isempty(state.files)
            uialert(fig,'There are no QC results to export.','QC Report');
            return
        end
        saveQCReports(cfg,true);
    end

    function clearResults(~,~)
        state.files = struct([]);
        state.qcFingerprint = '';
        state.lastQCReport = '';
        summaryTable.Data = cell(0,10);
        streamTable.Data = cell(0,8);
        qcStatus.Text = 'Ready';
    end

    function summarySelection(~,event)
        if isempty(event.Indices), return; end
        r = event.Indices(1);
        if r < 1 || r > numel(state.files), return; end
        if isempty(state.files(r).qc)
            streamTable.Data = cell(0,8);
        else
            streamTable.Data = state.files(r).qc;
        end
    end

    function syncUseColumn()
        d = summaryTable.Data;
        if isempty(d), return; end
        for ii = 1:min(size(d,1),numel(state.files))
            state.files(ii).use = logical(d{ii,1});
        end
    end

    function refreshSummaryTable()
        n = numel(state.files);
        d = cell(n,10);
        for ii = 1:n
            d{ii,1} = state.files(ii).use;
            d{ii,2} = state.files(ii).name;
            d{ii,3} = state.files(ii).folder;
            d{ii,4} = state.files(ii).status;
            d{ii,5} = state.files(ii).totalStreams;
            d{ii,6} = state.files(ii).emgCount;
            d{ii,7} = state.files(ii).accCount;
            d{ii,8} = state.files(ii).unexpectedCount;
            d{ii,9} = state.files(ii).expectedCount;
            d{ii,10} = state.files(ii).note;
        end
        summaryTable.Data = d;
    end

    function invalidateQC()
        state.qcFingerprint = '';
    end

    function cfg = getConfigFromUI(requireFolders)
        cfg = struct();
        cfg.version = 1;
        cfg.softwareName = APP_NAME;
        cfg.softwareVersion = APP_VERSION;
        cfg.author = APP_AUTHOR;
        cfg.website = APP_WEBSITE;
        cfg.email = APP_EMAIL;
        cfg.copyright = APP_COPYRIGHT;
        cfg.configurationGeneratedAt = datestr(now,'yyyy-mm-ddTHH:MM:SS');
        cfg.dllPath = strtrim(dllField.Value);
        cfg.inputRoot = strtrim(inputField.Value);
        cfg.outputRoot = strtrim(outputField.Value);
        cfg.recursive = recursiveCheck.Value;
        cfg.preserveFolders = preserveCheck.Value;
        cfg.includeFileKeywords = includeFileField.Value;
        cfg.includeFileMode = includeMode.Value;
        cfg.excludeFileKeywords = excludeFileField.Value;
        cfg.includeFolderKeywords = includeFolderField.Value;
        cfg.excludeFolderKeywords = excludeFolderField.Value;
        cfg.emgFs = emgFsField.Value;
        cfg.emgTol = emgTolField.Value;
        cfg.accFs = accFsField.Value;
        cfg.accTol = accTolField.Value;
        cfg.failUnexpected = failUnexpectedCheck.Value;
        cfg.deepQC = deepQCCheck.Value;
        cfg.channelMap = channelTable.Data;

        if isempty(cfg.dllPath)
            uialert(fig,'Select the Delsys HPF.dll file.','Missing DLL');
            cfg = [];
            return
        end
        if requireFolders
            if isempty(cfg.inputRoot) || ~isfolder(cfg.inputRoot)
                uialert(fig,'Select a valid input root folder.','Input Folder');
                cfg = [];
                return
            end
            if isempty(cfg.outputRoot)
                uialert(fig,'Select an output root folder.','Output Folder');
                cfg = [];
                return
            end
            if pathsEqual(cfg.inputRoot,cfg.outputRoot)
                uialert(fig,'Input and output root folders must be different.','Safety Check');
                cfg = [];
                return
            end
        end
    end

    function applyConfigToUI(cfg)
        fields = fieldnames(cfg); %#ok<NASGU>
        if isfield(cfg,'dllPath'), dllField.Value = cfg.dllPath; end
        if isfield(cfg,'inputRoot'), inputField.Value = cfg.inputRoot; end
        if isfield(cfg,'outputRoot'), outputField.Value = cfg.outputRoot; end
        if isfield(cfg,'recursive'), recursiveCheck.Value = logical(cfg.recursive); end
        if isfield(cfg,'preserveFolders'), preserveCheck.Value = logical(cfg.preserveFolders); end
        if isfield(cfg,'includeFileKeywords'), includeFileField.Value = cfg.includeFileKeywords; end
        if isfield(cfg,'includeFileMode') && any(strcmp(includeMode.Items,cfg.includeFileMode)), includeMode.Value = cfg.includeFileMode; end
        if isfield(cfg,'excludeFileKeywords'), excludeFileField.Value = cfg.excludeFileKeywords; end
        if isfield(cfg,'includeFolderKeywords'), includeFolderField.Value = cfg.includeFolderKeywords; end
        if isfield(cfg,'excludeFolderKeywords'), excludeFolderField.Value = cfg.excludeFolderKeywords; end
        if isfield(cfg,'emgFs'), emgFsField.Value = cfg.emgFs; end
        if isfield(cfg,'emgTol'), emgTolField.Value = cfg.emgTol; end
        if isfield(cfg,'accFs'), accFsField.Value = cfg.accFs; end
        if isfield(cfg,'accTol'), accTolField.Value = cfg.accTol; end
        if isfield(cfg,'failUnexpected'), failUnexpectedCheck.Value = logical(cfg.failUnexpected); end
        if isfield(cfg,'deepQC'), deepQCCheck.Value = logical(cfg.deepQC); end
        if isfield(cfg,'channelMap') && size(cfg.channelMap,2)==3
            d = channelTable.Data;
            nr = min(16,size(cfg.channelMap,1));
            d(1:nr,:) = cfg.channelMap(1:nr,:);
            channelTable.Data = d;
        end
        invalidateQC();
    end

    function ok = ensureDLL(path)
        ok = false;
        if ~isfile(path)
            uialert(fig,['HPF.dll was not found:' newline path],'Delsys DLL');
            return
        end
        try
            if ~strcmpi(state.dllLoadedPath,path)
                NET.addAssembly(path);
                state.dllLoadedPath = path;
                appendLog(['Loaded Delsys DLL: ' path]);
            end
            ok = true;
        catch ME
            uialert(fig,ME.message,'Could Not Load HPF.dll');
            appendLog(['DLL ERROR: ' ME.message]);
        end
    end

    function expected = buildExpectedStreams(map)
        expected.types = {};
        expected.sensors = {};
        expected.labels = {};

        for rr = 1:size(map,1)
            label = strtrim(char(string(map{rr,2})));
            mode = char(string(map{rr,3}));
            if isempty(label)
                label = sprintf('Channel%02d',rr);
            end
            switch mode
                case 'EMG only'
                    expected.types{end+1,1} = 'EMG'; %#ok<AGROW>
                    expected.sensors{end+1,1} = label; %#ok<AGROW>
                    expected.labels{end+1,1} = label; %#ok<AGROW>
                case 'ACC only'
                    [expected.types,expected.sensors,expected.labels] = addACC(expected.types,expected.sensors,expected.labels,label);
                case 'EMG + ACC'
                    expected.types{end+1,1} = 'EMG'; %#ok<AGROW>
                    expected.sensors{end+1,1} = label; %#ok<AGROW>
                    expected.labels{end+1,1} = label; %#ok<AGROW>
                    [expected.types,expected.sensors,expected.labels] = addACC(expected.types,expected.sensors,expected.labels,label);
                otherwise
                    % Ignore = no streams expected from this row.
            end
        end
    end

    function [types,sensors,labels] = addACC(types,sensors,labels,label)
        axesNames = {'X','Y','Z'};
        for aa = 1:3
            types{end+1,1} = 'ACC'; %#ok<AGROW>
            sensors{end+1,1} = label; %#ok<AGROW>
            labels{end+1,1} = [label axesNames{aa}]; %#ok<AGROW>
        end
    end

    function result = qcOneFile(rates,expected,cfg)
        nActual = numel(rates);
        nExpected = numel(expected.types);
        nRows = max(nActual,nExpected);
        detail = cell(nRows,8);

        observed = cell(nActual,1);
        for kk = 1:nActual
            if abs(rates(kk)-cfg.emgFs) <= cfg.emgTol
                observed{kk} = 'EMG';
            elseif abs(rates(kk)-cfg.accFs) <= cfg.accTol
                observed{kk} = 'ACC';
            else
                observed{kk} = 'UNEXPECTED';
            end
        end

        mismatch = false;
        for kk = 1:nRows
            detail{kk,1} = kk;
            if kk <= nActual
                detail{kk,2} = rates(kk);
                detail{kk,3} = observed{kk};
            else
                detail{kk,2} = NaN;
                detail{kk,3} = 'MISSING';
            end

            if kk <= nExpected
                detail{kk,4} = expected.sensors{kk};
                detail{kk,5} = expected.types{kk};
                detail{kk,6} = expected.labels{kk};
            else
                detail{kk,4} = '';
                detail{kk,5} = 'EXTRA';
                detail{kk,6} = '';
            end

            if kk <= nActual && kk <= nExpected
                isMatch = strcmp(observed{kk},expected.types{kk});
                detail{kk,7} = ternary(isMatch,'PASS','FAIL');
                if ~isMatch
                    mismatch = true;
                    detail{kk,8} = 'Observed signal type does not match configured stream order.';
                else
                    detail{kk,8} = '';
                end
            else
                detail{kk,7} = 'FAIL';
                mismatch = true;
                if kk > nActual
                    detail{kk,8} = 'Expected stream missing from HPF.';
                else
                    detail{kk,8} = 'Extra HPF stream not represented in channel map.';
                end
            end
        end

        unexpectedCount = sum(strcmp(observed,'UNEXPECTED'));
        emgCount = sum(strcmp(observed,'EMG'));
        accCount = sum(strcmp(observed,'ACC'));
        countMismatch = nActual ~= nExpected;

        fail = mismatch || countMismatch || (cfg.failUnexpected && unexpectedCount>0);
        if fail
            status = 'FAIL';
        else
            status = 'PASS';
        end

        notes = {};
        if countMismatch
            notes{end+1} = sprintf('Expected %d streams, found %d.',nExpected,nActual); %#ok<AGROW>
        end
        if unexpectedCount>0
            notes{end+1} = sprintf('%d unexpected sample-rate stream(s).',unexpectedCount); %#ok<AGROW>
        end
        if mismatch && ~countMismatch
            notes{end+1} = 'One or more streams do not match the configured EMG/ACC order.'; %#ok<AGROW>
        end
        if isempty(notes)
            note = 'Sampling rates and stream order match configuration.';
        else
            note = strjoin(notes,' ');
        end

        result = struct('status',status,'note',note,'detail',{detail}, ...
            'emgCount',emgCount,'accCount',accCount,'unexpectedCount',unexpectedCount);
    end

    function [ok,note] = verifyStreamData(reader,expected)
        ok = true;
        note = '';
        emgLens = [];
        accLens = [];
        try
            for kk = 1:numel(expected.types)
                x = double(reader.GetData(int32(kk-1)));
                n = numel(x);
                if n == 0
                    ok = false;
                    note = sprintf('Deep QC failed: stream %d returned zero samples.',kk);
                    return
                end
                if strcmp(expected.types{kk},'EMG')
                    emgLens(end+1) = n; %#ok<AGROW>
                else
                    accLens(end+1) = n; %#ok<AGROW>
                end
            end
            if ~isempty(emgLens) && numel(unique(emgLens)) ~= 1
                ok = false;
                note = ['Deep QC failed: EMG streams have unequal sample counts: ' mat2str(emgLens) '.'];
                return
            end
            if ~isempty(accLens) && numel(unique(accLens)) ~= 1
                ok = false;
                note = ['Deep QC failed: ACC streams have unequal sample counts: ' mat2str(accLens) '.'];
                return
            end
            note = 'Deep QC data-length check passed.';
        catch ME
            ok = false;
            note = ['Deep QC could not read stream data: ' ME.message];
        end
    end

    function [didConvert,msg] = convertOneFile(fileRec,expected,cfg)
        didConvert = false;
        msg = '';

        [~,base,~] = fileparts(fileRec.fullPath);
        if cfg.preserveFolders
            rel = relativeFolder(fileRec.folder,cfg.inputRoot);
            outDir = fullfile(cfg.outputRoot,rel);
        else
            outDir = cfg.outputRoot;
        end
        if ~isfolder(outDir), mkdir(outDir); end

        emgExpected = strcmp(expected.types,'EMG');
        accExpected = strcmp(expected.types,'ACC');
        emgOut = fullfile(outDir,[base '_EMG.txt']);
        accOut = fullfile(outDir,[base '_ACC.txt']);
        metadataOut = fullfile(outDir,[base '_ConversionMetadata.txt']);

        requiredOutputs = {metadataOut};
        if any(emgExpected), requiredOutputs{end+1} = emgOut; end %#ok<AGROW>
        if any(accExpected), requiredOutputs{end+1} = accOut; end %#ok<AGROW>
        for oo = 1:numel(requiredOutputs)
            if isfile(requiredOutputs{oo})
                msg = ['Existing output found; nothing overwritten: ' requiredOutputs{oo}];
                return
            end
        end

        reader = HPF.HPFReader(fileRec.fullPath);
        emgData = {};
        emgLabels = {};
        emgRates = [];
        accData = {};
        accLabels = {};
        accRates = [];

        for kk = 1:numel(expected.types)
            x = double(reader.GetData(int32(kk-1)));
            x = x(:);
            if strcmp(expected.types{kk},'EMG')
                emgData{end+1} = x; %#ok<AGROW>
                emgLabels{end+1} = expected.labels{kk}; %#ok<AGROW>
                emgRates(end+1) = fileRec.sampleRates(kk); %#ok<AGROW>
            else
                accData{end+1} = x; %#ok<AGROW>
                accLabels{end+1} = expected.labels{kk}; %#ok<AGROW>
                accRates(end+1) = fileRec.sampleRates(kk); %#ok<AGROW>
            end
        end
        clear reader;

        if ~isempty(emgData)
            lens = cellfun(@numel,emgData);
            if numel(unique(lens))~=1
                error('EMG streams have unequal sample counts. No output written.');
            end
        end
        if ~isempty(accData)
            lens = cellfun(@numel,accData);
            if numel(unique(lens))~=1
                error('ACC streams have unequal sample counts. No output written.');
            end
        end

        % Re-check no output appeared between initial check and write.
        for oo = 1:numel(requiredOutputs)
            if isfile(requiredOutputs{oo})
                msg = ['Existing output appeared; nothing overwritten: ' requiredOutputs{oo}];
                return
            end
        end

        if ~isempty(emgData)
            writeSignalTable(emgData,emgLabels,mean(emgRates),emgOut);
        end
        if ~isempty(accData)
            writeSignalTable(accData,accLabels,mean(accRates),accOut);
        end
        writeConversionMetadata(metadataOut,fileRec,cfg,expected,emgRates,accRates,emgOut,accOut);
        didConvert = true;
    end

    function writeConversionMetadata(outFile,fileRec,cfg,expected,emgRates,accRates,emgOut,accOut)
        fid = fopen(outFile,'w');
        if fid < 0
            error('Could not create conversion metadata file: %s',outFile);
        end
        cleaner = onCleanup(@() fclose(fid)); %#ok<NASGU>
        fprintf(fid,'Software: %s\n',APP_NAME);
        fprintf(fid,'Version: %s\n',APP_VERSION);
        fprintf(fid,'Author: %s\n',APP_AUTHOR);
        fprintf(fid,'Website: %s\n',APP_WEBSITE);
        fprintf(fid,'Email: %s\n',APP_EMAIL);
        fprintf(fid,'%s\n',APP_COPYRIGHT);
        fprintf(fid,'ConvertedAt: %s\n',datestr(now,'yyyy-mm-ddTHH:MM:SS'));
        fprintf(fid,'SourceFile: %s\n',fileRec.fullPath);
        fprintf(fid,'ConfiguredEMGSampleRateHz: %.12g\n',cfg.emgFs);
        fprintf(fid,'ConfiguredACCSampleRateHz: %.12g\n',cfg.accFs);
        if ~isempty(emgRates), fprintf(fid,'ObservedEMGSampleRateMeanHz: %.12g\n',mean(emgRates)); end
        if ~isempty(accRates), fprintf(fid,'ObservedACCSampleRateMeanHz: %.12g\n',mean(accRates)); end
        fprintf(fid,'ExpectedStreamCount: %d\n',numel(expected.types));
        if any(strcmp(expected.types,'EMG')), fprintf(fid,'EMGOutput: %s\n',emgOut); end
        if any(strcmp(expected.types,'ACC')), fprintf(fid,'ACCOutput: %s\n',accOut); end
    end

    function writeSignalTable(dataCells,labels,fs,outFile)
        n = numel(dataCells{1});
        M = zeros(n,numel(dataCells)+1);
        M(:,1) = (0:n-1)' ./ fs;
        for cc = 1:numel(dataCells)
            M(:,cc+1) = dataCells{cc};
        end
        varNames = [{'Time'},labels];
        varNames = matlab.lang.makeValidName(varNames,'ReplacementStyle','delete');
        varNames = matlab.lang.makeUniqueStrings(varNames);
        T = array2table(M,'VariableNames',varNames);
        writetable(T,outFile,'Delimiter','tab');
    end

    function saveQCReports(cfg,showMessage)
        if nargin < 2, showMessage = false; end
        if isempty(cfg.outputRoot)
            if showMessage
                uialert(fig,'Select an output folder before exporting QC.','QC Report');
            end
            return
        end
        reportDir = fullfile(cfg.outputRoot,'QC_Reports');
        if ~isfolder(reportDir), mkdir(reportDir); end
        stamp = datestr(now,'yyyymmdd_HHMMSS_FFF');

        summaryRows = cell(numel(state.files),15);
        for ii = 1:numel(state.files)
            summaryRows(ii,:) = {APP_AUTHOR,APP_EMAIL,APP_WEBSITE,APP_VERSION, ...
                state.files(ii).use,state.files(ii).name,state.files(ii).folder, ...
                state.files(ii).fullPath,state.files(ii).status,state.files(ii).totalStreams, ...
                state.files(ii).emgCount,state.files(ii).accCount,state.files(ii).unexpectedCount, ...
                state.files(ii).expectedCount,state.files(ii).note};
        end
        Ts = cell2table(summaryRows,'VariableNames', ...
            {'SoftwareAuthor','SoftwareEmail','SoftwareWebsite','SoftwareVersion','Use','FileName','Folder','SourceFile','QCStatus','TotalStreams','EMGCount','ACCCount','UnexpectedCount','ExpectedStreams','Note'});
        summaryFile = fullfile(reportDir,['Delsys_QC_Summary_' stamp '.csv']);
        writetable(Ts,summaryFile);

        detailRows = {};
        for ii = 1:numel(state.files)
            q = state.files(ii).qc;
            for rr = 1:size(q,1)
                detailRows(end+1,:) = {APP_AUTHOR,APP_EMAIL,APP_WEBSITE,APP_VERSION, ...
                    state.files(ii).fullPath,state.files(ii).name, ...
                    q{rr,1},q{rr,2},q{rr,3},q{rr,4},q{rr,5},q{rr,6},q{rr,7},q{rr,8}}; %#ok<AGROW>
            end
        end
        if ~isempty(detailRows)
            Td = cell2table(detailRows,'VariableNames', ...
                {'SoftwareAuthor','SoftwareEmail','SoftwareWebsite','SoftwareVersion','SourceFile','FileName','Stream','SampleRateHz','ObservedType','ExpectedSensor','ExpectedSignal','OutputLabel','Match','Comment'});
            detailFile = fullfile(reportDir,['Delsys_QC_StreamAudit_' stamp '.csv']);
            writetable(Td,detailFile);
        else
            detailFile = '';
        end

        state.lastQCReport = summaryFile;
        appendLog(['QC summary saved: ' summaryFile]);
        if ~isempty(detailFile), appendLog(['QC stream audit saved: ' detailFile]); end
        if showMessage
            uialert(fig,['QC report saved to:' newline reportDir],'QC Report');
        end
    end

    function fp = makeFingerprint(cfg)
        qcCfg = struct();
        qcCfg.dllPath = cfg.dllPath;
        qcCfg.inputRoot = cfg.inputRoot;
        qcCfg.includeFileKeywords = cfg.includeFileKeywords;
        qcCfg.includeFileMode = cfg.includeFileMode;
        qcCfg.excludeFileKeywords = cfg.excludeFileKeywords;
        qcCfg.includeFolderKeywords = cfg.includeFolderKeywords;
        qcCfg.excludeFolderKeywords = cfg.excludeFolderKeywords;
        qcCfg.emgFs = cfg.emgFs;
        qcCfg.emgTol = cfg.emgTol;
        qcCfg.accFs = cfg.accFs;
        qcCfg.accTol = cfg.accTol;
        qcCfg.failUnexpected = cfg.failUnexpected;
        qcCfg.deepQC = cfg.deepQC;
        qcCfg.channelMap = cfg.channelMap;
        fp = jsonencode(qcCfg);
    end

    function kw = splitKeywords(txt)
        txt = strtrim(char(string(txt)));
        if isempty(txt)
            kw = {};
            return
        end
        parts = regexp(txt,'[,;]','split');
        parts = cellfun(@strtrim,parts,'UniformOutput',false);
        kw = parts(~cellfun(@isempty,parts));
    end

    function tf = pathIsInside(candidate,parent)
        if isempty(parent)
            tf = false;
            return
        end
        c = normalizePath(candidate);
        p = normalizePath(parent);
        tf = strcmpi(c,p) || startsWith(lower(c),[lower(p) filesep]);
    end

    function tf = pathsEqual(a,b)
        tf = strcmpi(normalizePath(a),normalizePath(b));
    end

    function p = normalizePath(p)
        p = char(string(p));
        p = strrep(p,'/',filesep);
        p = strrep(p,'\',filesep);
        while numel(p)>1 && p(end)==filesep
            p(end) = [];
        end
    end

    function rel = relativeFolder(folder,root)
        f = normalizePath(folder);
        r = normalizePath(root);
        if strcmpi(f,r)
            rel = '';
        elseif startsWith(lower(f),[lower(r) filesep])
            rel = f(numel(r)+2:end);
        else
            rel = '';
        end
    end

    function rec = emptyFileRecord()
        rec = struct( ...
            'use',true, ...
            'name','', ...
            'folder','', ...
            'fullPath','', ...
            'status','NOT RUN', ...
            'note','', ...
            'sampleRates',[], ...
            'qc',{cell(0,8)}, ...
            'totalStreams',0, ...
            'emgCount',0, ...
            'accCount',0, ...
            'unexpectedCount',0, ...
            'expectedCount',0);
    end

    function appendLog(msg)
        t = datestr(now,'HH:MM:SS');
        current = logArea.Value;
        current{end+1,1} = sprintf('[%s] %s',t,msg);
        if numel(current)>500
            current = current(end-499:end);
        end
        logArea.Value = current;
        drawnow limitrate;
    end

    function out = ternary(cond,a,b)
        if cond, out = a; else, out = b; end
    end

end

function p = defaultDLLPath()
% Delsys HPF Converter + QC | Vinay Shankar | vinay@tfaworld.org | https://tfaworld.org/
% Default installation location; editable in the GUI.
p = 'C:\Program Files (x86)\Delsys, Inc\EMGworks\Matlab Conversion Library\HPF.dll';
end
