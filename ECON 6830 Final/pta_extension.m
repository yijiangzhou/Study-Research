% Extension of Egger, Larch, Staub, and Winkelmann (2011)
% by Yijiang Zhou, MPhil student at CUHK Economics
% Partly based on original MATLAB codes by the authors

clear;clc;warning off all;

%% Importing variables

importfile('data.txt');

%% Defining groups of variables

% Dependent variables: 
%       x ... exports
%       i ... =1 if exports>0
% 
% Groups of regressors:
%       pta ... PTA (regressor in x and in i)
%       z   ... other remaining regressors for x 
%       fe  ... fixed effects: x_x_1 - x_x_250
%       q   ... other remaining regressors for i: z and instruments
%       w   ... regressors for pta: z and instruments

const = ones(length(x),1);
instr = [colony comcol smctry];
z = [dist bord lang cont durab polcomp autoc curcol const]; % z already includes a constant
w = [z(:,1:end-1) instr const];
q = z;

fe = [x_x_1	 x_x_2	x_x_3	x_x_4	x_x_5	x_x_6	x_x_7	x_x_8	x_x_9  ...	
   x_x_10	x_x_11	x_x_12	x_x_13	x_x_14	x_x_15	x_x_16	x_x_17	x_x_18 ...	
   x_x_19	x_x_20	x_x_21	x_x_22	x_x_23	x_x_24	x_x_25	x_x_26	x_x_27 ...	
   x_x_28	x_x_29	x_x_30	x_x_31	x_x_32	x_x_33	x_x_34	x_x_35	x_x_36 ...	
   x_x_37	x_x_38	x_x_39	x_x_40	x_x_41	x_x_42	x_x_43	x_x_44	x_x_45 ...	
   x_x_46	x_x_47	x_x_48	x_x_49	x_x_50	x_x_51	x_x_52	x_x_53	x_x_54 ...	
   x_x_55	x_x_56	x_x_57	x_x_58	x_x_59	x_x_60	x_x_61	x_x_62	x_x_63 ...	
   x_x_64	x_x_65	x_x_66	x_x_67	x_x_68	x_x_69	x_x_70	x_x_71	x_x_72 ...	
   x_x_73	x_x_74	x_x_75	x_x_76	x_x_77	x_x_78	x_x_79	x_x_80	x_x_81 ...	
   x_x_82	x_x_83	x_x_84	x_x_85	x_x_86	x_x_87	x_x_88	x_x_89	x_x_90 ...	
   x_x_91	x_x_92	x_x_93	x_x_94	x_x_95	x_x_96	x_x_97	x_x_98	x_x_99 ...	
   x_x_100	x_x_101	x_x_102	x_x_103	x_x_104	x_x_105	x_x_106	x_x_107	x_x_108...	
   x_x_109	x_x_110	x_x_111	x_x_112	x_x_113	x_x_114	x_x_115	x_x_116	x_x_117...	
   x_x_118	x_x_119	x_x_120	x_x_121	x_x_122	x_x_123	x_x_124	x_x_125	x_x_126... 
   x_x_127	x_x_128	x_x_129	x_x_130	x_x_131	x_x_132	x_x_133	x_x_134	x_x_135...	
   x_x_136	x_x_137	x_x_138	x_x_139	x_x_140	x_x_141	x_x_142	x_x_143	x_x_144...	
   x_x_145	x_x_146	x_x_147	x_x_148	x_x_149	x_x_150	x_x_151	x_x_152	x_x_153...	
   x_x_154	x_x_155	x_x_156	x_x_157	x_x_158	x_x_159	x_x_160	x_x_161	x_x_162...	
   x_x_163	x_x_164	x_x_165	x_x_166	x_x_167	x_x_168	x_x_169	x_x_170	x_x_171...	
   x_x_172	x_x_173	x_x_174	x_x_175	x_x_176	x_x_177	x_x_178	x_x_179	x_x_180...	
   x_x_181	x_x_182	x_x_183	x_x_184	x_x_185	x_x_186	x_x_187	x_x_188	x_x_189...	
   x_x_190	x_x_191	x_x_192	x_x_193	x_x_194	x_x_195	x_x_196	x_x_197	x_x_198...	
   x_x_199	x_x_200	x_x_201	x_x_202	x_x_203	x_x_204	x_x_205	x_x_206	x_x_207...	
   x_x_208	x_x_209	x_x_210	x_x_211	x_x_212	x_x_213	x_x_214	x_x_215	x_x_216...	
   x_x_217	x_x_218	x_x_219	x_x_220	x_x_221	x_x_222	x_x_223	x_x_224	x_x_225...	
   x_x_226	x_x_227	x_x_228	x_x_229	x_x_230	x_x_231	x_x_232	x_x_233	x_x_234...	
   x_x_235	x_x_236	x_x_237	x_x_238	x_x_239	x_x_240	x_x_241	x_x_242	x_x_243...	
   x_x_244	x_x_245	x_x_246	x_x_247	x_x_248	x_x_249	x_x_250];

%% OLS of log(X) on PTA and Z

fem = fe;
fem(:,162) = []; % deleting _x_162 because of collinearity
fem(:,59) = [];  % idem for _x_59
wfe = [w fem];

zex=[pta z fem]; % independent variable: PTA,Z and fixed effects (dummies)

pose_0 = logical(i); % drop observations with zero exports
xpo_0 = x(pose_0);
lnxpo_0 = log(xpo_0);
zexpo_0 = zex(pose_0,:);

% OLS: 2 methods, same results
[b_ols1,olsdev1,olsstats1] = glmfit(zexpo_0,lnxpo_0,'normal','link','identity','constant','off');
b_ols2 = inv(zexpo_0' * zexpo_0) * zexpo_0' * lnxpo_0;
disp('OLS of log(X) on PTA and Z');
disp('coeff         coeff         se');
disp([b_ols1(1:size(z,2)+1,1) b_ols2(1:size(z,2)+1,1) olsstats1.se(1:size(z,2)+1,1)]);

nnn = length(lnxpo_0); % sample size
uhat = lnxpo_0 - zexpo_0 * b_ols2;
sih2 = uhat' * uhat / nnn;

% B matrix estimation
ss1 = uhat .* zexpo_0 / sih2;
ss2 = uhat.^2 / (2*sih2^2) - ones(nnn,1) / (2*sih2);
sss = [ss1 ss2]; % the score matrix
Bhat = sss' * sss / nnn;

% A matrix estimation
lenb = length(Bhat);
Ahat = zeros(lenb,lenb);
Ahat(1:lenb-1,1:lenb-1) = -zexpo_0' * zexpo_0 / (sih2*nnn);
Ahat(1:lenb-1,lenb) = -zexpo_0' * uhat / (nnn*sih2^2);
Ahat(lenb,1:lenb-1) = Ahat(1:lenb-1,lenb)';
Ahat(lenb,lenb) = -uhat' * uhat / (nnn*sih2^3) + 1/(2*sih2^2);

% H matrix estimation
Hhat = -Bhat * inv(Ahat);
hhh = size(Hhat,1);

% Cho and White/Philips testing basis
Tstar = trace(Hhat) / hhh - 1;
Dstar = det(Hhat)^(1/hhh) - 1;
Sstar = Tstar - Dstar;
Hstar = hhh / trace(inv(Hhat)) - 1;
Cstar = Tstar - Hstar;
Gstar = Dstar - Hstar;

% Cho and White/Philips testing statistics
B1 = nnn * hhh * (1/4) * (Tstar^2 + Dstar^2);
B2 = nnn * hhh * (1/2) * (Tstar^2 + 2*Sstar);
B3 = nnn * hhh * (1/2) * (Dstar^2 + 2*Sstar);
D2 = nnn * hhh * (1/2) * (Tstar^2 + Cstar);
D3 = nnn * hhh * (1/2) * (Hstar^2 + Cstar);
Bm = max([B2 B3 D2 D3]);

% Horowitz parametric bootstrap
itermax = 1000; % maximum number of iterations
container = zeros(itermax,3);
iter = 1;

tic;
while iter < itermax + 1
    uub = sqrt(sih2) * randn(nnn,1);
    lnxpo_0b = zexpo_0 * b_ols2 + uub;
    
    % OLS estimation
    b_olsb = inv(zexpo_0' * zexpo_0) * zexpo_0' * lnxpo_0b;
    uhatb = lnxpo_0b - zexpo_0 * b_olsb;
    sih2b = uhatb' * uhatb / nnn;
    
    % B matrix estimation
    ss1b = uhatb .* zexpo_0 / sih2b;
    ss2b = uhatb.^2 / (2*sih2b^2) - ones(nnn,1) / (2*sih2b);
    sssb = [ss1b ss2b]; % the score matrix
    Bhatb = sssb' * sssb / nnn;
    
    % A matrix estimation
    lenb = length(Bhatb);
    Ahatb = zeros(lenb,lenb);
    Ahatb(1:lenb-1,1:lenb-1) = -zexpo_0' * zexpo_0 / (sih2b*nnn);
    Ahatb(1:lenb-1,lenb) = -zexpo_0' * uhatb / (nnn*sih2b^2);
    Ahatb(lenb,1:lenb-1) = Ahatb(1:lenb-1,lenb)';
    Ahatb(lenb,lenb) = -uhatb' * uhatb / (nnn*sih2b^3) + 1/(2*sih2b^2);
    
    % H matrix estimation
    Hhatb = -Bhatb * inv(Ahatb);
    hhh = size(Hhatb,1);

    % Cho and White/Philips testing basis
    Tstarb = trace(Hhatb) / hhh - 1;
    Dstarb = det(Hhatb)^(1/hhh) - 1;
    Sstarb = Tstarb - Dstarb;
    Hstarb = hhh / trace(inv(Hhatb)) - 1;
    Cstarb = Tstarb - Hstarb;
    Gstarb = Dstarb - Hstarb;

    % Cho and White/Philips testing statistics
    B1b = nnn * hhh * (1/4) * (Tstarb^2 + Dstarb^2);
    B2b = nnn * hhh * (1/2) * (Tstarb^2 + 2*Sstarb);
    B3b = nnn * hhh * (1/2) * (Dstarb^2 + 2*Sstarb);
    D2b = nnn * hhh * (1/2) * (Tstarb^2 + Cstarb);
    D3b = nnn * hhh * (1/2) * (Hstarb^2 + Cstarb);

    % I will focus on B2, B3, D2 and D3 (4 testing statistics)   
    container(iter,1) = iter;
    container(iter,2) = B1b;
    container(iter,3) = max([B2b B3b D2b D3b]);
    
    iter = iter + 1;
end
toc;

p1 = mean(container(:,2) > B1);
pm = mean(container(:,3) > Bm);

disp('OLS of log(X) on PTA and Z');
disp('IMT test 1    IMT test 2');
disp([B1 Bm]);
disp('p-value 1     p-value 2');
disp([p1 pm]);

%% OLS of log(X+1) on PTA and Z

fem = fe;
fem(:,162) = []; % deleting _x_162 because of collinearity
fem(:,59) = [];  % idem for _x_59
wfe = [w fem];

zex=[pta z fem]; % independent variable: PTA,Z and fixed effects (dummies)

lnxpo_1 = log(x+1);


% OLS: 2 methods, same results
[b_ols3,olsdev3,olsstats3] = glmfit(zex,lnxpo_1,'normal','link','identity','constant','off');
b_ols4 = inv(zex' * zex) * zex' * lnxpo_1;
disp('OLS of log(X+1) on PTA and Z');
disp('coeff         coeff         se');
disp([b_ols3(1:size(z,2)+1,1) b_ols4(1:size(z,2)+1,1) olsstats3.se(1:size(z,2)+1,1)]);

nnn = length(lnxpo_1); % sample size
uhat = lnxpo_1 - zex * b_ols4;
sih2 = uhat' * uhat / nnn;

% B matrix estimation
ss1 = uhat .* zex / sih2;
ss2 = uhat.^2 / (2*sih2^2) - ones(nnn,1) / (2*sih2);
sss = [ss1 ss2]; % the score matrix
Bhat = sss' * sss / nnn;

% A matrix estimation
lenb = length(Bhat);
Ahat = zeros(lenb,lenb);
Ahat(1:lenb-1,1:lenb-1) = -zex' * zex / (sih2*nnn);
Ahat(1:lenb-1,lenb) = -zex' * uhat / (nnn*sih2^2);
Ahat(lenb,1:lenb-1) = Ahat(1:lenb-1,lenb)';
Ahat(lenb,lenb) = -uhat' * uhat / (nnn*sih2^3) + 1/(2*sih2^2);

% H matrix estimation
Hhat = -Bhat * inv(Ahat);
hhh = size(Hhat,1);

% Cho and White/Philips testing basis
Tstar = trace(Hhat) / hhh - 1;
Dstar = det(Hhat)^(1/hhh) - 1;
Sstar = Tstar - Dstar;
Hstar = hhh / trace(inv(Hhat)) - 1;
Cstar = Tstar - Hstar;
Gstar = Dstar - Hstar;

% Cho and White/Philips testing statistics
B1 = nnn * hhh * (1/4) * (Tstar^2 + Dstar^2);
B2 = nnn * hhh * (1/2) * (Tstar^2 + 2*Sstar);
B3 = nnn * hhh * (1/2) * (Dstar^2 + 2*Sstar);
D2 = nnn * hhh * (1/2) * (Tstar^2 + Cstar);
D3 = nnn * hhh * (1/2) * (Hstar^2 + Cstar);
Bm = max([B2 B3 D2 D3]);

% Horowitz parametric bootstrap
itermax = 1000; % maximum number of iterations
container = zeros(itermax,3);
iter = 1;

tic;
while iter < itermax + 1
    uub = sqrt(sih2) * randn(nnn,1);
    lnxpo_1b = zex * b_ols4 + uub;
    
    % OLS estimation
    b_olsb = inv(zex' * zex) * zex' * lnxpo_1b;
    uhatb = lnxpo_1b - zex * b_olsb;
    sih2b = uhatb' * uhatb / nnn;
    
    % B matrix estimation
    ss1b = uhatb .* zex / sih2b;
    ss2b = uhatb.^2 / (2*sih2b^2) - ones(nnn,1) / (2*sih2b);
    sssb = [ss1b ss2b]; % the score matrix
    Bhatb = sssb' * sssb / nnn;
    
    % A matrix estimation
    lenb = length(Bhatb);
    Ahatb = zeros(lenb,lenb);
    Ahatb(1:lenb-1,1:lenb-1) = -zex' * zex / (sih2b*nnn);
    Ahatb(1:lenb-1,lenb) = -zex' * uhatb / (nnn*sih2b^2);
    Ahatb(lenb,1:lenb-1) = Ahatb(1:lenb-1,lenb)';
    Ahatb(lenb,lenb) = -uhatb' * uhatb / (nnn*sih2b^3) + 1/(2*sih2b^2);
    
    % H matrix estimation
    Hhatb = -Bhatb * inv(Ahatb);
    hhh = size(Hhatb,1);

    % Cho and White/Philips testing basis
    Tstarb = trace(Hhatb) / hhh - 1;
    Dstarb = det(Hhatb)^(1/hhh) - 1;
    Sstarb = Tstarb - Dstarb;
    Hstarb = hhh / trace(inv(Hhatb)) - 1;
    Cstarb = Tstarb - Hstarb;
    Gstarb = Dstarb - Hstarb;

    % Cho and White/Philips testing statistics
    B1b = nnn * hhh * (1/4) * (Tstarb^2 + Dstarb^2);
    B2b = nnn * hhh * (1/2) * (Tstarb^2 + 2*Sstarb);
    B3b = nnn * hhh * (1/2) * (Dstarb^2 + 2*Sstarb);
    D2b = nnn * hhh * (1/2) * (Tstarb^2 + Cstarb);
    D3b = nnn * hhh * (1/2) * (Hstarb^2 + Cstarb);

    % I will focus on B2, B3, D2 and D3 (4 testing statistics)   
    container(iter,1) = iter;
    container(iter,2) = B1b;
    container(iter,3) = max([B2b B3b D2b D3b]);
    
    iter = iter + 1;
end
toc;

p1 = mean(container(:,2) > B1);
pm = mean(container(:,3) > Bm);

disp('OLS of log(X+1) on PTA and Z');
disp('IMT test 1    IMT test 2');
disp([B1 Bm]);
disp('p-value 1     p-value 2');
disp([p1 pm]);


































