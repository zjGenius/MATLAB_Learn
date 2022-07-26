clear
clc
close all

%% 
%% ****修 改**** 
% fileStr='C:\Users\Administrator\Desktop\测试\5840\CWPulseResult.txt';
% fileLenCell = strsplit(fileStr,'\');
% fileLen = size(fileLenCell);
% ListFileLen = size(char(fileLenCell(fileLen(1,2))));
% logFileLen = ListFileLen(1,2);

fileStr='C:\Users\Administrator\Desktop\测试\111\';
sFileDir = dir(fileStr);
collPath = strcat(fileStr,'collData\');
if ~exist(collPath,'dir')
    collPath = mkdir(fileStr,'collData\');
else
    warning('存在该文件夹');
end

for i = 3:length(sFileDir)-1
    sFilePath = strcat(fileStr,sFileDir(i).name,'\');
    sFile = dir(fullfile(sFilePath,'*PulseResult.txt'));
    
    fileStrs = strcat(sFilePath,sFile.name);
    fileLenCell = strsplit(fileStrs,'\');
    fileLen = size(fileLenCell);
    ListFileLen = size(char(fileLenCell(fileLen(1,2))));
    logFileLen = ListFileLen(1,2);


    ref_angle = 270;   
    %% ************* 
    fp=fopen(fileStrs,'r');
    data=textscan(fp,'frameCount=%dcompassAng=%f%s%santFace=%finitPhase=%f%f%f%f%f%f%f%f%s%s%s%s%s%s%s%snum=%d%sID=%dname=%spr=%dfreq=%dpulseBW=%fazimuth=%frange=%fOnAnt:%d%d%d%d%d%d%d%dpulseTime=%fpulseW=%fangle=%fmeanPhase=%f%f%f%f%f%f%f%fmeanAmp=%f%f%f%f%f%f%f%fphaseVar=%f%f%f%f%f%f%f%f','Delimiter',',');

    compassAng = data{2};
    freq = data{27};
    vidangle = data{29};
    initphase = [data{6},data{7},data{8},data{9},data{10},data{11},data{12},data{13}];
    vidPhase = [data{42},data{43},data{44},data{45},data{46},data{47},data{48},data{49}];
    vidAmp = [data{50},data{51},data{52},data{53},data{54},data{55},data{56},data{57}];
    addPhase = mod(vidPhase + initphase + pi,2 * pi) - pi;
    %% 同compassAng取幅度相位平均
    angle_avg(:,1) = 0:5:355;

    %% 4通道
    if data{46}(1) == 0
        CH = 4;
        [amp_avg,phase_avg] = Average4(compassAng,addPhase(:,1:4),vidAmp(:,1:4),ref_angle);
            % 组合数据
            calibration = [amp_avg,phase_avg,angle_avg];
            if or(calibration(:,1:4) < 30,calibration(:,1:4) > 200) %异常处理
                calibration(:,1:4) = 0;
            end

            if or(calibration(:,5:8) < -3.14,calibration(:,5:8) > 3.14) %异常处理
                calibration(:,5:8) = 0;
            end

            % 写txt文件
            name = sprintf('coll_data_refAmpPhase_%d.txt',freq(1));
            fileID = fopen(name,'w');
            for i = 1:72
                fprintf(fileID,'refAmp=%.2f,%.2f,%.2f,%.2f, refPhase=%.2f,%.2f,%.2f,%.2f, angle=%d\n',calibration(i,:));    
            end
            fclose(fileID);
            figure
            plot(0:5:355,phase_avg+repmat(0:7:21,72,1))
            title("phase avg")
            figure
            plot(0:5:355,amp_avg)
            title("amp avg")
            figure
            plot(vidAmp(:,1:4));
            title("vidAmp")
            figure
                for i = 1:4
                    plot(vidPhase(:,i)+(i-1)*7)
                    hold on;
                end
                title("vidPhase")
            figure
                for i = 1:4
                    plot(addPhase(:,i)+(i-1)*7)
                    hold on;
                end
                title("vidPhase + initphase")
            % figure
            % for i = 1:8
            % subplot(4,2,i)
            %  plot(mod(compassAng-52,360),vidMeanPhase0(:,i))
            % end
    else
    %% 8通道
        CH = 8;
        [amp_avg,phase_avg] = Average(compassAng,addPhase,vidAmp,ref_angle);
        % 组合数据
        calibration = [amp_avg,phase_avg,angle_avg];
        if or(calibration(:,1:8) < 30,calibration(:,1:8) > 200) %异常处理
            calibration(:,1:8) = 0;
        end

        if or(calibration(:,9:16) < -3.14,calibration(:,9:16) > 3.14) %异常处理
            calibration(:,9:16) = 0;
        end
        % 写txt文件
        name = sprintf('coll_data_refAmpPhase_%d.txt',freq(1));
        filePath = fileStrs(1:end-logFileLen);

        name = [filePath,name];
        if ~exist(name,'file')
            fileID = fopen(name,'w');
            for i = 1:72
                fprintf(fileID,'refAmp=%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f, refPhase=%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f, angle=%d\n',calibration(i,:));
            end
            fclose(fileID);
            copyfile(name,collPath);
            fprintf("coll_data_refAmpPhase_%d.txt file write success!",freq(1));
            disp(" ");
        else
            warning("coll_data_refAmpPhase_%d.txt file already exists!!!",freq(1));
            delete(name);
            continue;
        end

    %     figure
    %     plot(0:5:355,phase_avg+repmat(0:7:49,72,1))
    %     figure
    %     plot(0:5:355,amp_avg)
    %     figure
    %     plot(vidAmp);
    %     figure
    %         for i = 5:6
    %             plot(vidPhase(:,i))
    %             hold on;
    %         end
    %     title("vidPhase")
    %     figure
    %         for i = 5:6
    %             plot(addPhase(:,i))
    %             hold on;
    %         end
    %     title("vidPhase + initphase")
    %     ylim([-pi pi])
        % figure
        % for i = 1:8
        % subplot(4,2,i)
        %  plot(mod(compassAng-52,360),vidMeanPhase0(:,i))
        % end
        
    end
   
end
disp('OK!!')

