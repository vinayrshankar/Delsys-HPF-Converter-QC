function config = create_example_config()
% CREATE_EXAMPLE_CONFIG Create a generic configuration structure.
%
% Author:  Vinay Shankar
% Email:   vinay@tfaworld.org
% Website: https://tfaworld.org/
% Version: 1.1.0
% Copyright (c) 2026 Vinay Shankar. All rights reserved.
%
% This example intentionally contains no study-specific channel names.

config = struct();
config.version = 1;
config.softwareName = 'Delsys HPF Converter + QC';
config.softwareVersion = '1.1.0';
config.author = 'Vinay Shankar';
config.email = 'vinay@tfaworld.org';
config.website = 'https://tfaworld.org/';
config.copyright = 'Copyright (c) 2026 Vinay Shankar. All rights reserved.';
config.configurationGeneratedAt = datestr(now,'yyyy-mm-ddTHH:MM:SS');

config.dllPath = 'C:\Program Files (x86)\Delsys, Inc\EMGworks\Matlab Conversion Library\HPF.dll';
config.inputRoot = '';
config.outputRoot = '';
config.recursive = true;
config.preserveFolders = true;
config.includeFileKeywords = '';
config.includeFileMode = 'Match ANY';
config.excludeFileKeywords = '';
config.includeFolderKeywords = '';
config.excludeFolderKeywords = '';
config.emgFs = 1925.93;
config.emgTol = 2.0;
config.accFs = 148.15;
config.accTol = 1.0;
config.failUnexpected = true;
config.deepQC = true;

config.channelMap = cell(16,3);
for r = 1:16
    config.channelMap{r,1} = r;
    config.channelMap{r,2} = sprintf('Channel%02d',r);
    config.channelMap{r,3} = 'Ignore';
end

end
