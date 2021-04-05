      SUBROUTINE DEB_EULER(HOUR)

C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2018 MICHAEL R. KEARNEY AND WARREN P. PORTER

C     THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C     IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C     THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR (AT
C      YOUR OPTION) ANY LATER VERSION.

C     THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C     WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C     MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C     GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C     YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C     ALONG WITH THIS PROGRAM. IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.

C     IMPLEMENTATION OF KOOIJMAN'S KAPPA-RULE STANDARD DEB MODEL WITH METABOLIC
C     ACCELERATION INVOKED IF E_HJ != E_HP AND ABP (HEMIMETABOLOUS INSECT) MODEL
C     IF METAB_MODE=1. USES EULER INTEGRATION

      USE AACOMMONDAT
      IMPLICIT NONE

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ACTHR,AL,AMASS,ANDENS_DEB
      DOUBLE PRECISION ANNFOOD,AREF,ATOT,BATCHPREP,BREEDRAINTHRESH
      DOUBLE PRECISION BREEDTEMPTHRESH,BREF,CAUSEDEATH,CLUTCHA,CLUTCHB
      DOUBLE PRECISION CLUTCHENERGY,CLUTCHES,CLUTCHSIZE,CO2FLUX,CONTDEP
      DOUBLE PRECISION CONTH,CONTHOLE,CONTVOL,CONTW,CONTWET,CREF,CTMAX
      DOUBLE PRECISION CTMIN,CUMBATCH,CUMBATCH_INIT,CUMREPRO
      DOUBLE PRECISION CUMREPRO_INIT,D_V,DAYLENGTHFINISH,DAYLENGTHSTART
      DOUBLE PRECISION DE_HDT,DEATHSTAGE,DEBFIRST,DEBQMET,DEBQMET_INIT
      DOUBLE PRECISION DEDT,DELTA_DEB,DELTAR,DEPRESS,DEPSEL,DEPSUB,DESDT
      DOUBLE PRECISION DHSDS,DLDT,DQDT,DRYFOOD,DSURVDT,DUEDT,DUHDT,DVDT
      DOUBLE PRECISION E_BABY,E_BABY_INIT,E_BABY1,E_EGG,E_G,E_H,E_H_INIT
      DOUBLE PRECISION E_H_PRES,E_H_START,E_HB,E_HE,E_HJ,E_HP,E_HPUP
      DOUBLE PRECISION E_HPUP_INIT,E_INIT,E_INIT_BABY,E_M,E_M2,E_PRES
      DOUBLE PRECISION E_SCALED,E_TEMP,ECTOINPUT,ED,EGGDRYFRAC,EGGSOIL
      DOUBLE PRECISION EH_BABY,EH_BABY_INIT,EH_BABY1,EMISAN,EPUP
      DOUBLE PRECISION EPUP_INIT,E_S,E_S_INIT,E_S_PAST,E_S_PRES,E_SM
      DOUBLE PRECISION ETA_PA,ETAO,EXTREF,F,F12,F13,F14,F15,F16,F21
      DOUBLE PRECISION F23,F24,F25,F26,F31,F32,F41,F42,F51,F52,F61
      DOUBLE PRECISION FAECES,FATOSB,FATOSK,FECUNDITY,FLSHCOND,FOOD
      DOUBLE PRECISION FOODLIM,FUNCT,G,GH2OMET,GH2OMET_INIT,GUTFILL
      DOUBLE PRECISION GUTFREEMASS,GUTFULL,H_A,H_AREF,HALFSAT,HS,HS_INIT
      DOUBLE PRECISION HS_PRES,HRN,J_O,J_M,JM_JO,JMCO2,JMCO2_GM,JMH2O
      DOUBLE PRECISION JMH2O_GM,JMNWASTE,JMNWASTE_GM,JMO2,JMO2_GM,JOJE
      DOUBLE PRECISION JOJE_GM,JOJP,JOJP_GM,JOJV,JOJV_GM,JOJX,JOJX_GM
      DOUBLE PRECISION K_EL,K_EV,K_J,K_JREF,K_M,KAP,KAP_G,KAP_R,KAP_V
      DOUBLE PRECISION KAP_X,KAP_X_P,L_B,L_J,L_M,L_PRES,L_T,L_THRESH,L_W
      DOUBLE PRECISION L_WREPRO,LAMBDA,LAT,LENGTHDAY,LENGTHDAYDIR,LONGEV
      DOUBLE PRECISION M_V,MAXMASS,MINCLUTCH,MINED,MLO2,MLO2_INIT
      DOUBLE PRECISION MONMATURE,MONREPRO,MR_1,MR_2,MR_3,MU_AX,MU_E,MU_M
      DOUBLE PRECISION MU_N,MU_O,MU_P,MU_V,MU_X,NEWCLUTCH,NWASTE,O2FLUX
      DOUBLE PRECISION ORIG_CLUTCHSIZE,ORIG_E_SM,P_A,P_AM,P_B,P_C,P_D
      DOUBLE PRECISION P_G,P_J,P_M,P_MREF,P_MV,P_R,P_X,P_XM,P_XMREF,PAS
      DOUBLE PRECISION PBS,PCS,PDS,PGS,PJS,PMS,PRS,PHI,PHIMAX,PHIMIN,PI
      DOUBLE PRECISION POND_DEPTH,POTFREEMASS,PREVDAYLENGTH,PTCOND
      DOUBLE PRECISION PTCOND_ORIG,Q,Q_INIT,Q_PRES,QCOND,QCONV,QIRIN
      DOUBLE PRECISION QIROUT,QMETAB,QRESP,QSEVAP,QSOL,QSOLAR,R
      DOUBLE PRECISION RAINDRINK,RAINFALL,RELHUM,REPRO,RESID,RH,RHO1_3
      DOUBLE PRECISION RHREF,RQ,S_G,S_J,S_M,SC,SCALED_L,SIDEX,SIG,STAGE
      DOUBLE PRECISION STAGE_REC,STARVE,SUBTK,SURVIV,SURVIV_INIT
      DOUBLE PRECISION SURVIV_PRES,T_A,T_A2,T_AH,T_AH2,T_AL
      DOUBLE PRECISION T_AL2,T_H,T_H2,T_L,T_L2,T_REF,TA,TALOC
      DOUBLE PRECISION TB,TBASK,TC,TCORES,TCORR,TCORR2,TDIGPR,TEMERGE
      DOUBLE PRECISION TESTCLUTCH,TIME,TLUNG,TMAXPR,TMINPR,TPREF,TQSOL
      DOUBLE PRECISION TRANS1,TREF,TSKYC,TSUBST,TWATER,TWING,U_H_PRES
      DOUBLE PRECISION V,V_BABY,V_BABY_INIT,V_BABY1,V_INIT,V_INIT_BABY
      DOUBLE PRECISION V_M,V_PRES,V_TEMP,VDOT,VDOTREF,VEL,VOLD,VOLD_INIT
      DOUBLE PRECISION VPUP,VPUP_INIT,W_E,W_N,W_P,W_V,W_X,WETFOOD
      DOUBLE PRECISION WETGONAD,WETMASS,WETSTORAGE,WQSOL,X_FOOD
      DOUBLE PRECISION YEX,YPX,YXE,ZFACT
      DOUBLE PRECISION RAINMULT

      INTEGER AEST,AESTIVATE,AQUABREED,AQUASTAGE,AQUATIC,BATCH,BREEDACT
      INTEGER BREEDACTTHRES,BREEDING,BREEDTEMPCUM,BREEDVECT,CENSUS
      INTEGER COMPLETE,COMPLETION,CONTONLY,CONTYPE,COUNTDAY,COUNTER
      INTEGER CTKILL,CTMINCUM,CTMINTHRESH,DAYCOUNT,DEAD,DEADEAD,DEB1
      INTEGER DEHYDRATED,DOY,F1COUNT,FEEDING,FIRSTDAY,HOUR,I,INWATER
      INTEGER IYEAR,METAB_MODE,METAMORPH,NN,NYEAR,PHOTODIRF,PHOTODIRS
      INTEGER PHOTOFINISH,PHOTOSTART,PREGNANT,PREVDEAD,RESET,STAGES
      INTEGER STARTDAY,STARVING,VIVIPAROUS,WAITING,WETMOD,WINGCALC
      INTEGER WINGMOD
      INTEGER RAINHOUR

      CHARACTER*1 TRANST

      DIMENSION ACTHR(25),BREEDVECT(24),CUMBATCH(24),CUMREPRO(24)
      DIMENSION DEBFIRST(13),DEBQMET(24),DEPSEL(25),DRYFOOD(24)
      DIMENSION E_BABY1(24),E_H(24),E_HPUP(24),ECTOINPUT(127)
      DIMENSION ED(24),EGGSOIL(24),EH_BABY1(24),EPUP(24),E_S(24)
      DIMENSION ETAO(4,3),FAECES(24),FOOD(50),GH2OMET(24),HS(24),HRN(25)
      DIMENSION J_M(4),J_O(4),JM_JO(4,4),L_W(24),MLO2(24),MU_O(4)
      DIMENSION MU_M(4),NWASTE(24),PAS(24),PCS(24)
      DIMENSION PMS(24),PGS(24),PDS(24),PJS(24),PRS(24),PBS(24),Q(24)
      DIMENSION REPRO(24),RHREF(25),STAGE_REC(25),SURVIV(24),TALOC(25)
      DIMENSION TCORES(25),TIME(25),TREF(25),V(24),V_BABY1(24),VOLD(24)
      DIMENSION VPUP(24),WETFOOD(24),WETGONAD(24),WETMASS(24)
      DIMENSION WETSTORAGE(24)
           
      DATA PI/3.14159265/

      COMMON/ARRHEN/T_A,T_AL,T_AH,T_L,T_H,T_REF
      COMMON/ARRHEN2/T_A2,T_AL2,T_AH2,T_L2,T_H2
      COMMON/BEHAV3/ACTHR
      COMMON/BODYTEMP/BREEDTEMPTHRESH,BREEDTEMPCUM
      COMMON/BREEDER/BREEDING,BREEDVECT
      COMMON/CONT/CONTH,CONTW,CONTVOL,CONTDEP,CONTHOLE,CONTWET,RAINMULT,
     & WETMOD,CONTONLY,CONTYPE,RAINHOUR
      COMMON/COUNTDAY/COUNTDAY,DAYCOUNT
      COMMON/CTMAXMIN/CTMAX,CTMIN,CTMINCUM,CTMINTHRESH,CTKILL
      COMMON/DAYSTORUN/NN
      COMMON/DEATH/CAUSEDEATH,DEATHSTAGE
      COMMON/DEBBABY/V_BABY,E_BABY,EH_BABY
      COMMON/DEBINIT1/V_INIT,E_INIT,CUMREPRO_INIT,CUMBATCH_INIT,
     & VOLD_INIT,VPUP_INIT,EPUP_INIT
      COMMON/DEBINIT2/E_S_INIT,Q_INIT,HS_INIT,P_MREF,VDOTREF,H_AREF,
     & E_BABY_INIT,V_BABY_INIT,EH_BABY_INIT,K_JREF,S_G,SURVIV_INIT,
     & HALFSAT,X_FOOD,E_HPUP_INIT,P_XMREF
      COMMON/DEBINPUT/DEBFIRST,ECTOINPUT
      COMMON/DEBMASS/ETAO,JM_JO
      COMMON/DEBMOD/V,ED,WETMASS,WETSTORAGE,WETGONAD,WETFOOD,O2FLUX,
     & CO2FLUX,CUMREPRO,HS,E_S,L_W,CUMBATCH,Q,V_BABY1,E_BABY1,
     & E_H,STAGE,EH_BABY1,GUTFREEMASS,SURVIV,VOLD,VPUP,EPUP,E_HPUP,
     & RAINDRINK,POTFREEMASS,PAS,PBS,PCS,PDS,PGS,PJS,PMS,PRS,CENSUS,
     & RESET,DEADEAD,STARTDAY,DEAD
      COMMON/DEBMOD2/REPRO,ORIG_CLUTCHSIZE,NEWCLUTCH,ORIG_E_SM,MINCLUTCH
      COMMON/DEBOUTT/FECUNDITY,CLUTCHES,MONREPRO,L_WREPRO,MONMATURE,
     & MINED,ANNFOOD,FOOD,LONGEV,COMPLETION,COMPLETE
      COMMON/DEBPAR1/CLUTCHSIZE,ANDENS_DEB,D_V,EGGDRYFRAC,W_E,MU_E,MU_V,
     & W_V,E_EGG,KAP_V,KAP_X,KAP_X_P,MU_X,MU_P,W_N,W_P,W_X,FUNCT,MU_N
      COMMON/DEBPAR2/ZFACT,KAP,E_G,KAP_R,DELTA_DEB,E_H_START,MAXMASS,
     & E_INIT_BABY,V_INIT_BABY,E_H_INIT,E_HB,E_HP,E_HJ,E_SM,LAMBDA,
     & BREEDRAINTHRESH,DAYLENGTHSTART,DAYLENGTHFINISH,LENGTHDAY,
     & LENGTHDAYDIR,PREVDAYLENGTH,LAT,CLUTCHA,CLUTCHB,E_HE,
     & AQUABREED,AQUASTAGE,PHOTODIRS,PHOTODIRF,
     & BREEDACTTHRES,METAMORPH,PHOTOSTART,PHOTOFINISH,BREEDACT,BATCH
      COMMON/DEBPAR3/METAB_MODE,STAGES,K_EL,K_EV
      COMMON/DEBPAR4/S_J,L_B,L_J,E_M2
      COMMON/DEBRESP/MLO2,GH2OMET,DEBQMET,MLO2_INIT,GH2OMET_INIT,
     & DEBQMET_INIT,DRYFOOD,FAECES,NWASTE
      COMMON/DEPTHS/DEPSEL,TCORES
      COMMON/DOYMON/DOY
      COMMON/EGGSOIL/EGGSOIL
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG
      COMMON/GUT/GUTFULL,GUTFILL,FOODLIM
      COMMON/METDEP/DEPRESS,AESTIVATE,AEST,DEHYDRATED,STARVING
      COMMON/PONDDATA/INWATER,AQUATIC,TWATER,POND_DEPTH,FEEDING
      COMMON/RAINFALL/RAINFALL
      COMMON/REPYEAR/IYEAR,NYEAR
      COMMON/REVAP1/TLUNG,DELTAR,EXTREF,RQ,MR_1,MR_2,MR_3,DEB1
      COMMON/STAGE_R/STAGE_REC,F1COUNT,COUNTER
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/USROPT/TRANST
      COMMON/VIVIP/VIVIPAROUS,PREGNANT
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51,
     & SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F61,TQSOL,A1,A2,
     & A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,WINGCALC,WINGMOD

      PREVDEAD=0
      DEAD=0
      WAITING=0
      L_W(HOUR)=0.
      WETGONAD(HOUR)=0.
      WETSTORAGE(HOUR)=0.
      WETFOOD(HOUR)=0.
      WETMASS(HOUR)=0.
      MLO2(HOUR)=0.
      O2FLUX=0.
      CO2FLUX=0.
      V(HOUR)=0.
      E_H(HOUR)=0.
      CUMREPRO(HOUR)=0.
      CUMBATCH(HOUR)=0.
      VPUP(HOUR)=0.
      VOLD(HOUR)=0.
      ED(HOUR)=0.
      HS(HOUR)=0.
      SURVIV(HOUR)=1.
      E_S(HOUR)=0.
      SC=0.
      L_THRESH=0.
      STARVE=0.

      IF(HOUR.EQ.1)THEN
       COMPLETE=0
      ENDIF

C     CHECK IF FIRST DAY OF SIMULATION
      IF((DAYCOUNT.EQ.1).AND.(HOUR.EQ.1))THEN
       FIRSTDAY=1
      ELSE
       FIRSTDAY=0
      ENDIF

C     RESET CLUTCH SIZE AND MAXIMUM STOMACH ENERGY CONTENT (LATTER MAY BE REDUCED IF VIVIPAROUS)
      IF((HOUR.EQ.1).AND.(DAYCOUNT.EQ.1))THEN
       ORIG_CLUTCHSIZE=CLUTCHSIZE
       ORIG_E_SM=E_SM
      ELSE
       IF(PREGNANT.EQ.0)THEN
        CLUTCHSIZE = ORIG_CLUTCHSIZE
        E_SM=ORIG_E_SM
       ENDIF
      ENDIF

C     CHECK IF DEAD OR SIMULATION STILL WAITING FOR START DAY TO OCCUR
      IF((DAYCOUNT.LT.STARTDAY).OR.((COUNTDAY.LT.STARTDAY).AND.
     & (V_INIT.LE.3E-9)).OR.(DEADEAD.EQ.1))THEN
       DEAD=1
       GOTO 987
      ENDIF

C     CHECK IF START OF A NEW DAY
      IF(HOUR.EQ.1)THEN
       V_PRES = V_INIT
       E_PRES = E_INIT
       E_S_PRES = E_S_INIT
       MINED = E_PRES
       E_H_PRES = E_H_INIT
       Q_PRES = Q_INIT
       HS_PRES = HS_INIT
       SURVIV_PRES = SURVIV_INIT
      ELSE
       V_PRES = V(HOUR-1)
       E_PRES = ED(HOUR-1)
       E_S_PRES = E_S(HOUR-1)
       E_H_PRES = E_H(HOUR-1)
       Q_PRES = Q(HOUR-1)
       HS_PRES = HS(HOUR-1)
       SURVIV_PRES = SURVIV(HOUR-1)
      ENDIF
      
C     FOR SIZE-DEPENDENT CLUTCH
      IF((CLUTCHA.GT.0).AND.(PREGNANT.EQ.0))THEN ! MAKE SURE CLUTCH SIZE DOESN'T INCREASE DURING PREGNANCY BECAUSE OTHERWISE GET JUMP UP IN MASS OF GONAD
       CLUTCHSIZE=FLOOR(CLUTCHA*(L_W(HOUR)/10)-CLUTCHB)
       NEWCLUTCH=CLUTCHSIZE
      ENDIF
      IF(CLUTCHSIZE.GT.ORIG_CLUTCHSIZE)THEN
       CLUTCHSIZE=ORIG_CLUTCHSIZE
       NEWCLUTCH=CLUTCHSIZE
      ENDIF

      E_H_START = E_H_INIT

C     SET BODY TEMPERATURE
      TB = MIN(CTMAX, TC) ! DON'T LET IT GO TOO HIGH
      IF(TB.GT.31)THEN
      TB=TB*1.0000001
      ENDIF
      IF((AQUABREED.EQ.1).OR.(AQUABREED.EQ.2))THEN
       CONTDEP=POND_DEPTH
       IF((STAGE.EQ.1).OR.((STAGE.EQ.0).AND.(AQUABREED.EQ.1)))THEN
        TB=TWATER
       ENDIF
      ENDIF

C     IF RUNNING AN AQUATIC ANIMAL (E.G. FROG), CHECK IF TERRESTRIAL BREEDER AND SET TB TO SOIL TEMP
      IF(E_H_PRES.LT.E_HB)THEN
       IF((AQUABREED.EQ.2).OR.(AQUABREED.EQ.4))THEN
        TB = EGGSOIL(HOUR)
       ENDIF
      ENDIF

C     ARRHENIUS TEMPERATURE CORRECTION FACTOR
C       TCORR = EXP(T_A*(1/(273+T_REF)-1/(273+TB)))/(1+EXP(T_AL
C     & *(1/(273+TB)-1/T_L))+EXP(T_AH*(1/T_H-1/(273+TB))))
       TCORR = EXP(T_A/(273.15+T_REF)-T_A/(273.15+TB))*((1+EXP(T_AL/
     &(273.15+T_REF)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+T_REF)))/(1+EXP
     &(T_AL/(273.15+TB)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+TB))))
       TCORR2 = EXP(T_A2/(273.15+T_REF)-T_A2/(273.15+TB))*((1+EXP( ! THIS VERSION ALLOWS K_REF TO VARY FROM WHAT IS SPECIFIED AS A PARAMETER (USED IN DEBTOOL)
     &T_AL2/(273.15+T_REF)-T_AL2/T_L2)+EXP(T_AH2/T_H2-T_AH2/(273.15+
     &T_REF)))/(1+EXP(T_AL2/(273.15+TB)-T_AL2/T_L2)+EXP(T_AH2/T_H2-
     &T_AH2/(273.15+TB))))
     
C     METABOLIC ACCELERATION IF PRESENT
      S_M = 1.
      IF(E_HJ.NE.E_HB)THEN
       IF(E_H_PRES.LT.E_HB)THEN
        S_M = 1. ! -, MULTIPLICATION FACTOR FOR V AND {P_AM}
       ELSE
        IF(E_H_PRES.LT.E_HJ)THEN
         S_M = V_PRES ** (1. / 3.) / L_B
        ELSE
         S_M = L_J / L_B
        ENDIF
       ENDIF
      ENDIF

C     TEMPERATURE CORRECTIONS AND COMPOUND PARAMETERS
      M_V = ANDENS_DEB/W_V
      P_MV = P_MREF*TCORR
      K_M = P_MV/E_G
      K_J = K_JREF*TCORR2
      VDOT = VDOTREF*TCORR*S_M
      P_AM = P_MV*ZFACT/KAP*S_M
      P_XM = P_XMREF*TCORR*S_M
      H_A = H_AREF*TCORR
      IF(AEST.EQ.1)THEN
       P_MV = P_MV*DEPRESS
       K_M = P_MV/E_G
       K_J = K_J*DEPRESS
       VDOT=VDOT*DEPRESS
       P_AM = P_MREF*TCORR*ZFACT/KAP*DEPRESS
       P_XM = P_XMREF*TCORR*DEPRESS
       H_A = H_AREF*TCORR*DEPRESS
      ENDIF

C     HARDWIRING IN FOR LOCUSTS AT THE MOMENT      
C     IF((STAGE.EQ.3).AND.(LENGTHDAY.LE.11).AND.(METAB_MODE.EQ.1))THEN
C      P_MV = P_MV*DEPRESS
C      K_M = P_MV/E_G
C      K_J = K_J*DEPRESS
C      VDOT=VDOT*DEPRESS
C      P_AM = P_MREF*TCORR*ZFACT/KAP*DEPRESS
C      P_XM = P_XMREF*TCORR*DEPRESS
C      H_A = H_AREF*TCORR*DEPRESS
C     ENDIF  
      
      E_M = P_AM/VDOT
      G = E_G/(KAP*E_M)
      E_SCALED=E_PRES/E_M
      V_M=(KAP*P_AM/P_MV)**(3.)
      L_T = 0.
      L_PRES = V_PRES**(1./3.)
      L_M = V_M**(1./3.)
      SCALED_L = L_PRES/L_M
      KAP_G = (D_V*MU_V)/(W_V*E_G)
      YEX=KAP_X*MU_X/MU_E
      YXE=1/YEX
      YPX=KAP_X_P*MU_X/MU_P
      MU_AX=MU_E/YXE
      ETA_PA=YPX/MU_AX
      
      IF(CLUTCHSIZE.LT.1)THEN
       CLUTCHSIZE=1
       NEWCLUTCH=CLUTCHSIZE
      ENDIF
      CLUTCHENERGY = E_EGG*CLUTCHSIZE

      X_FOOD = FOODLEVELS(DAYCOUNT)

      IF(PREGNANT.EQ.1)THEN
        F=FUNCT
       LAMBDA=LAMBDA-1./(24.*365.)
       IF(LAMBDA.LT.0)THEN
        LAMBDA=0.1
       ENDIF
      ELSE
       F=FUNCT
      ENDIF
      ! OPTION FOR SPECIFIC LIFE STAGES TO NOT BE FOOD LIMITED
      IF(INT(FOODLIM).EQ.0)THEN
       FUNCT=1.
       X_FOOD = HALFSAT*10000.
      ENDIF
C     IF(VIVIPAROUS.EQ.1)THEN
C      IF((CUMBATCH(HOUR)/CLUTCHENERGY).GT.1)THEN
C       E_SM=E_SM*0.5
C      ELSE
C       E_SM=E_SM*(1-(CUMBATCH(HOUR)/CLUTCHENERGY)*.5)
C      ENDIF
C      IF(E_SM.LT.0)THEN
C       E_SM=0
C      ENDIF
C     ENDIF
      IF((AESTIVATE.EQ.1).AND.(AQUATIC.EQ.1).AND.(POND_DEPTH.EQ.0).OR.
     & (DEHYDRATED.EQ.1))THEN
       AEST=1
      ELSE
       AEST=0
      ENDIF
 
C     CALL SUBROUTINE THAT ASSESSES PHOTOPERIOD CUES ON BREEDING
      CALL BREED(DOY,PHOTOSTART,PHOTOFINISH,LENGTHDAY,
     &DAYLENGTHSTART,DAYLENGTHFINISH,PHOTODIRS,PHOTODIRF,PREVDAYLENGTH,
     &LAT,FIRSTDAY,BREEDACT,BREEDACTTHRES,HOUR,
     &BREEDTEMPTHRESH,BREEDTEMPCUM,DAYCOUNT,DEAD,PREVDEAD,ACTHR(HOUR))

      BREEDVECT(HOUR)=BREEDING

C     CALL SUBROUTINE (FOR FROGS AT THIS STAGE) THAT ASSESSES IF USER WANTS CUMULATIVE RESETS OF DEVELOPMENT AFTER METAMORPHOSIS
      CALL DEVRESET(DEAD,E_H_PRES,E_HB,AQUABREED,BREEDING,CONTDEP,
     &STAGE,AQUASTAGE,RESET,COMPLETE,WAITING,HOUR,STAGES,COMPLETION)

C     DIAPAUSE BEFORE POND FILL
      IF(AQUABREED.EQ.1)THEN
       IF((E_H_PRES.GE.E_HB).AND.(STAGE.LT.1))THEN
        IF(CONTDEP.LE.0.1)THEN
         WAITING=1
        ENDIF
       ENDIF
      ENDIF
C     NOW CHECKING TO SEE IF STARTING WITH EMBRYO, AND IF SO SETTING THE APPROPRIATE RESERVE DENSITY
      IF(HOUR.EQ.1)THEN
       IF(DAYCOUNT.EQ.1)THEN
        IF(E_H_PRES.LT.E_HB)THEN
         E_PRES=E_INIT
        ENDIF
       ENDIF
C      CHECKING TO SEE IF ANIMAL DIED RECENTLY AND NEEDS TO START AGAIN AS AN EMBRYO
       IF((DAYCOUNT.GT.1).AND.(DEAD.EQ.1))THEN
        IF(E_H_PRES.LT.E_HB)THEN
         E_PRES=E_EGG/DEBFIRST(3)
        ENDIF
       ENDIF
      ENDIF
      
      R=VDOT*(E_SCALED/L_PRES-(1+L_T/L_PRES)/L_M)/(E_SCALED+G)
      P_C=E_PRES*(VDOT/L_PRES-R)*V_PRES ! J / t, mobilisation rate, equation 2.12 DEB3
      IF(E_H_PRES.LT.E_HB)THEN
C      USE EMBRYO EQUATION FOR LENGTH, FROM KOOIJMAN 2009 EQ. 2
       IF(WAITING.EQ.1)THEN
        DLDT = 0.
        V_TEMP=(V_PRES**(1./3.)+DLDT)**3
        DVDT = 0.
        R=0.
       ELSE
        DLDT=(VDOT*E_SCALED-K_M*G*V_PRES**(1./3.))/(3*(E_SCALED+G))
        V_TEMP=(V_PRES**(1./3.)+DLDT)**3
        DVDT = V_TEMP-V_PRES
        R=VDOT*(E_SCALED/L_PRES-(1+L_T/L_PRES)/L_M)/(E_SCALED+G)
       ENDIF
      ELSE
       IF((METAB_MODE.EQ.1).AND.(E_H_PRES.GE.E_HJ))THEN
        R=MIN(0.0D0, r) ! no growth in abp after puberty, but could still be negative because starving
        p_C=E_PRES*V_PRES*VDOT/L_PRES !# J / t, mobilisation rate
       ENDIF
       DVDT = V_PRES*R
       IF(V_PRES*R.LT.0.)THEN
        STARVING=1
        STARVE=V_PRES*R*(-1.)*MU_V*D_V/W_V  !CM3 * G/CM3 (G) * MOL/G (MOL) * J/MOL (J)
        IF(HOUR.EQ.1)THEN
         IF(CUMBATCH_INIT.LT.STARVE)THEN
          DVDT=R*V_PRES
          STARVE=0.
          STARVING=1
         ENDIF
         ELSE
         IF(CUMBATCH(HOUR-1).LT.STARVE)THEN
          DVDT=R*V_PRES
          STARVE=0.
          STARVING=1
         ENDIF
        ENDIF
       ELSE
        STARVE=0.
        STARVING=0
       ENDIF
      ENDIF

      IF(HOUR.EQ.1)THEN
       IF(E_S_INIT.GT.V_PRES**(2./3.)*P_AM*F)THEN
        P_A = V_PRES**(2./3.)*P_AM*F
       ELSE
        P_A = E_S_INIT
       ENDIF
      ELSE
       IF(E_S(HOUR-1).GT.V_PRES**(2./3.)*P_AM*F)THEN
        P_A = V_PRES**(2./3.)*P_AM*F
       ELSE
        P_A = E_S(HOUR-1)
       ENDIF
      ENDIF
      
      IF(HOUR.EQ.1)THEN
       IF(E_H_PRES.LT.E_HB)THEN
C       USE EMBRYO EQUATION FOR SCALED RESERVE, U_E, FROM KOOIJMAN 2009 EQ. 1
        SC = L_PRES**2*(G*E_SCALED)/(G+E_SCALED)*(1+((K_M*L_PRES)/
     &   VDOT))
        DUEDT = -1.*SC
        E_TEMP=((E_PRES*V_PRES/P_AM)+DUEDT)*P_AM/(V_PRES+DVDT)
        DEDT=E_TEMP-E_PRES
       ELSE
        IF(E_S_INIT.GT.P_A)THEN
C        EQUATION 2.10 DEB3
         DEDT = P_A/V_PRES-(E_PRES*VDOT)/L_PRES
        ELSE
         DEDT = E_S_INIT/V_PRES-(E_PRES*VDOT)/L_PRES
        ENDIF
       ENDIF
      ELSE
       IF(E_H_PRES.LT.E_HB)THEN
C       USE EMBRYO EQUATION FOR SCALED RESERVE, U_E, FROM KOOIJMAN 2009 EQ. 1
        SC = L_PRES**2*(G*E_SCALED)/(G+E_SCALED)*(1+((K_M*L_PRES)/
     &   VDOT))
        DUEDT = -1.*SC
        E_TEMP=((E_PRES*V_PRES/P_AM)+DUEDT)*P_AM/(V_PRES+DVDT)
        DEDT=E_TEMP-E_PRES
       ELSE
        IF(E_S(HOUR-1).GT.P_A)THEN
         DEDT = P_A/V_PRES-(E_PRES*VDOT)/L_PRES
        ELSE
         DEDT = E_S(HOUR-1)/V_PRES-(E_PRES*VDOT)/L_PRES
        ENDIF
       ENDIF
      ENDIF

C     MATURITY
      P_J = K_J * E_H_PRES
      IF(E_H_PRES.LT.E_HP)THEN
       IF(E_H_PRES.LT.E_HB)THEN
C       USE EMBRYO EQUATION FOR SCALED MATURITY, U_H, FROM KOOIJMAN 2009 EQ. 3
        IF(WAITING.EQ.1)THEN
         U_H_PRES=E_H_PRES/P_AM
         DUHDT=0.
         DE_HDT=DUHDT*P_AM
        ELSE
         U_H_PRES=E_H_PRES/P_AM
         DUHDT=(1-KAP)*SC-K_J*U_H_PRES
         DE_HDT=DUHDT*P_AM
        ENDIF
       ELSE
        DE_HDT = (1-KAP)*P_C-P_J
       ENDIF
      ELSE
       DE_HDT = 0.
      ENDIF

      IF(HOUR.EQ.1)THEN
       E_H(HOUR) = E_H_INIT + DE_HDT
      ELSE
       E_H(HOUR) = E_H(HOUR-1) + DE_HDT
      ENDIF

      V(HOUR)=V_PRES+DVDT
      IF(V(HOUR).LT.0.)THEN
       V(HOUR)=0.
      ENDIF
      
      IF((E_H(HOUR).GE.E_HB).AND.(E_H_PRES.LT.E_HB))THEN
       L_B = V(HOUR)**(1./3.) ! BIRTH LENGTH (NEEDED FOR ABJ MODEL)
      ENDIF
      IF((E_H(HOUR).GE.E_HJ).AND.(E_H_PRES.LT.E_HJ))THEN
       L_J = V(HOUR)**(1./3.) ! METAMORPHOSIS HAS OCCURRED (ABJ MODEL)
      ENDIF

      IF((METAB_MODE.EQ.1).AND.(E_H(HOUR).GE.E_HJ))THEN
       R=0. ! NO GROWTH IN ABP AFTER PUBERTY - NOT SETTING THIS TO ZERO MESSES UP AGEING CALCULATION
      ENDIF
      
      ED(HOUR) = E_PRES+DEDT
C     MAKE SURE ED DOESN'T GO BELOW ZERO
      IF(ED(HOUR).LT.0.)THEN
       ED(HOUR)=0.
      ENDIF
C     FIND MIN VALUE OF ED FOR THE SIMULATION
      IF(ED(HOUR).LT.MINED)THEN
       MINED=ED(HOUR)
      ENDIF

C     LENGTH IN MM
      L_W(HOUR) = V(HOUR)**(1./3.)/DELTA_DEB*10. 
      
C	  AGEING      
      DQDT = (Q_PRES*(V_PRES/V_M)*S_G+H_A)*(E_PRES/E_M)*
     & ((VDOT/L_PRES)-R)-R*Q_PRES

      IF(E_H(HOUR).GE.E_HB)THEN
       IF(HOUR.EQ.1)THEN
        Q(HOUR) = Q_INIT + DQDT
       ELSE
        Q(HOUR) = Q(HOUR-1)+DQDT
       ENDIF
      ELSE
        Q(HOUR) = 0.
      ENDIF

      DHSDS = Q_PRES-R*HS_PRES

      IF(E_H(HOUR).GE.E_HB)THEN
       IF(HOUR.EQ.1)THEN
        HS(HOUR) = HS_INIT + DHSDS
       ELSE
        HS(HOUR) = HS(HOUR-1)+DHSDS
       ENDIF
      ELSE
       HS(HOUR) = 0.
      ENDIF

C     POWERS
      IF((METAB_MODE.EQ.1).AND.(E_H(HOUR).GE.E_HJ))THEN
       P_C = P_A - DEDT * V(HOUR)
      ENDIF  
      P_J = K_J * E_H(HOUR)
      P_M = P_MV * V(HOUR)    
      
      IF((METAB_MODE.EQ.1).AND.(E_H(HOUR).GE.E_HJ))THEN
       P_R = (1. - KAP) * P_A - P_J
      ELSE
       P_R = (1. - KAP) * P_C - P_J
      ENDIF

      IF((E_H(HOUR).LT.E_HP).OR.(PREGNANT.EQ.1))THEN
       P_B = 0.
      ELSE
       IF(BATCH.EQ.1)THEN
         BATCHPREP=(KAP_R/LAMBDA)*((1.-KAP)*(E_M*(VDOT*V(HOUR)**(2./3.)+
     &    K_M*V_PRES)/(1.+(1./G)))-P_J)
        IF(BREEDING.EQ.0)THEN
         P_B=0.
        ELSE
         IF(HOUR.EQ.1)THEN
C         IF THE REPRO BUFFER IS LOWER THAN WHAT P_B WOULD BE (SEE BELOW), P_B IS P_R
          IF(CUMREPRO_INIT.LT.BATCHPREP)THEN
           P_B = P_R
          ELSE
C         OTHERWISE IT IS A FASTER RATE, AS SPECIFIED IN PECQUERIE ET. AL JSR 2009 ANCHOVY PAPER,
C         WITH LAMBDA (THE FRACTION OF THE YEAR THE ANIMALS BREED IF FOOD/TEMPERATURE NOT LIMITING) = 0.583 OR 7 MONTHS OF THE YEAR
           P_B = MAX(BATCHPREP, P_R)
          ENDIF
         ELSE
C         IF THE REPRO BUFFFER IS LOWER THAN WHAT P_B WOULD BE (SEE BELOW), P_B IS P_R
          IF(CUMREPRO(HOUR-1).LT.BATCHPREP)THEN
           P_B = P_R
          ELSE
C          OTHERWISE IT IS A FASTER RATE, AS SPECIFIED IN PECQUERIE ET. AL JSR 2009 ANCHOVY PAPER,
C          WITH LAMBDA (THE FRACTION OF THE YEAR THE ANIMALS BREED IF FOOD/TEMPERATURE NOT LIMITING) = 0.583 OR 7 MONTHS OF THE YEAR
           P_B = MAX(BATCHPREP, P_R)
          ENDIF
         ENDIF
        ENDIF
       ELSE
        P_R = P_B
C       END CHECK FOR WHETHER BATCH MODE IS OPERATING
       ENDIF
C     END CHECK FOR IMMATURE OR MATURE
      ENDIF
      P_R = P_R - P_B ! TAKE FINALISED VALUE OF P_B FROM P_R
 
      ! DRAW FROM REPRODUCTION AND THEN BATCH BUFFERS UNDER STARVATION
      IF(HOUR.EQ.1)THEN
       IF((STARVE.GT.0.).AND.(CUMREPRO_INIT.GT.STARVE))THEN
        P_R = P_R - STARVE
        STARVE = 0.
        STARVING = 0
       ENDIF
       IF((STARVE.GT.0.).AND.(CUMREPRO_INIT.GT.STARVE))THEN
        P_B = P_B - STARVE
        STARVE = 0.
        STARVING = 0
       ENDIF
      ELSE
       IF((STARVE.GT.0.).AND.(CUMREPRO(HOUR-1).GT.STARVE))THEN
        P_R = P_R - STARVE
        STARVE = 0.
        STARVING = 0
       ENDIF
       IF((STARVE.GT.0.).AND.(CUMBATCH(HOUR-1).GT.STARVE))THEN
        P_B = P_B - STARVE
        STARVE = 0.
        STARVING = 0
       ENDIF
      ENDIF

      IF(METAB_MODE.EQ.1)THEN ! ABP (E.G. HEMIMETABOLOUS INSECT)
       IF(E_H(HOUR).GE.E_HJ)THEN
        !R=min(0.0D0,R)
        !p_C=ED(HOUR) * VDOT / V(HOUR)**(1./3.) !# J / t, mobilisation rate
        P_A = P_R + P_B + P_M + P_J + (E_PRES - ED(HOUR)) * V(HOUR)
        P_C = P_A - (E_PRES - ED(HOUR)) * V(HOUR)
        !P_M = P_C - P_R - P_B - P_J
        !DVDT=0.
       ENDIF
      ENDIF 

      IF(HOUR.EQ.1)THEN
       IF(E_S_INIT.LT.P_A)THEN
        P_A = V_PRES**(2./3.)*P_AM*F
       ENDIF
      ELSE
       IF(E_S(HOUR-1).LT.P_A)THEN
        P_A = E_S(HOUR-1)
       ENDIF
      ENDIF      
      
      IF(E_H(HOUR).GE.E_HP)THEN
       P_D = P_M + P_J + (1 - KAP_R) * P_B
      ELSE
       P_D = P_M + P_J + P_R
      ENDIF
      
      IF((METAB_MODE.EQ.1).AND.(E_H(HOUR).GE.E_HJ))THEN
       P_G = 0.
      ELSE
       P_G = P_C - P_M - P_J - P_R - P_B
      ENDIF

C      H_W = ((H_A*(E_PRES/E_M)*VDOT)/(6*V_PRES**(1./3.)))**(1./3.)
      DSURVDT = -1*SURVIV_PRES*HS(HOUR)
      SURVIV(HOUR) = SURVIV_PRES+DSURVDT
      
      IF(COUNTDAY.EQ.365)THEN
       IF(HOUR.EQ.24)THEN
        SURV(IYEAR)=SURVIV(HOUR)
       ENDIF
      ENDIF

      IF(TC.LT.CTMIN)THEN
       CTMINCUM=CTMINCUM+1
      ELSE
       CTMINCUM=0
      ENDIF

C     CHECK IF DIED, AND RECORD WHY

C     AVERAGE LONGEVITY IN YEARS
      IF(LONGEV.EQ.0.)THEN
       IF(CTKILL.EQ.1)THEN
        IF((CTMINCUM.GT.CTMINTHRESH).OR.(TC.GT.CTMAX+2))THEN
         IF(RESET.GT.0)THEN
          DEAD=1
          IF(CTMINCUM.GT.CTMINTHRESH)THEN
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=1. ! COLD STRESS
            DEATHSTAGE=STAGE
            CTMINCUM=0
           ENDIF
          ELSE
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=2. ! HEAT STRESS
            DEATHSTAGE=STAGE
           ENDIF
          ENDIF
         ELSE
          CENSUS=COUNTDAY
          DEADEAD=1
          SURV(IYEAR)=SURVIV(HOUR)
          SURVIV(HOUR)=0.49
          IF(CTMINCUM.GT.CTMINTHRESH)THEN
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=1. ! COLD STRESS
            DEATHSTAGE=STAGE
            CTMINCUM=0
           ENDIF
          ELSE
           IF(STAGE.GT.DEATHSTAGE)THEN
            CAUSEDEATH=2. ! HEAT STRESS
            DEATHSTAGE=STAGE
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
       IF(SURVIV(HOUR).LT.0.5)THEN
        LONGEV=(REAL(DAYCOUNT,4)+REAL(HOUR)/24.)/365.
        NYEAR=IYEAR
        DEAD=1
        IF(RESET.EQ.0)THEN
         SURV(IYEAR)=SURVIV(HOUR)
         DEADEAD=1
         SURVIV(HOUR)=0.49
        ENDIF
         IF(STAGE.GT.DEATHSTAGE)THEN
          CAUSEDEATH=5. ! OLD AGE
          DEATHSTAGE=STAGE
         ENDIF
       ENDIF
      ENDIF

      IF((ED(HOUR).LT.(P_MREF*ZFACT/KAP/VDOTREF)*0.1).AND.
     & (DEAD.EQ.0))THEN
       DEAD=1
       LONGEV=(REAL(DAYCOUNT,4)+REAL(HOUR)/24.)/365.
       NYEAR=IYEAR
       IF(STAGE.GT.DEATHSTAGE)THEN
        CAUSEDEATH=4. ! STARVING
        DEATHSTAGE=STAGE
       ENDIF
       IF(RESET.EQ.0)THEN
        SURVIV(HOUR)=0.49
        DEADEAD=1
        CENSUS=COUNTDAY
       ENDIF
      ENDIF

      IF(E_H(HOUR).GE.E_HP)THEN
C      ACCUMULATE ENERGY IN REPRODUCTION BUFFER
C      IF IT IS THE BEGINNING OF THE DAY
       IF(HOUR.EQ.1)THEN
         CUMREPRO(HOUR) = MAX(0.0D0, CUMREPRO_INIT+P_R)
       ELSE
         CUMREPRO(HOUR) = MAX(0.0D0, CUMREPRO(HOUR-1)+P_R)
       ENDIF
C      ACCUMULATE ENERGY IN EGG BATCH BUFFER
C      IF IT IS THE BEGINNING OF THE DAY
       IF(HOUR.EQ.1)THEN
        CUMBATCH(HOUR) = MAX(0.0D0, CUMBATCH_INIT+P_B*KAP_R)
       ELSE
        CUMBATCH(HOUR) = MAX(0.0D0, CUMBATCH(HOUR-1)+P_B*KAP_R)
       ENDIF
      ENDIF

      TESTCLUTCH=FLOOR((CUMREPRO(HOUR)+CUMBATCH(HOUR))/E_EGG)
C     FOR VARIABLE CLUTCH SIZE FROM REPRO AND BATCH BUFFERS
      IF((MINCLUTCH.GT.0).AND.(FLOOR((CUMREPRO(HOUR)+CUMBATCH(HOUR))
     & /E_EGG).GT.MINCLUTCH))THEN
       IF(TESTCLUTCH.LE.ORIG_CLUTCHSIZE)THEN ! MAKE SMALLEST CLUTCH ALLOWABLE FOR THIS REPRO EVENT
        CLUTCHSIZE=MINCLUTCH
        CLUTCHENERGY=CLUTCHSIZE*E_EGG
       ENDIF
      ENDIF

C     DETERMINE LIFE STAGE
      
C     STD MODEL
      IF((METAB_MODE.EQ.0).AND.(E_HB.EQ.E_HJ))THEN   
       IF(E_H(HOUR).LT.E_HB)THEN
        STAGE=0
       ELSE   
        IF(E_H(HOUR).LT.E_HP)THEN
         STAGE=1
        ELSE
         STAGE=2
        ENDIF
       ENDIF
       IF(CUMBATCH(HOUR).GT.0)THEN
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=3
        ELSE
         STAGE=STAGE
        ENDIF
       ENDIF
      ENDIF
      
C     ABJ MODEL
      IF((METAB_MODE.EQ.0).AND.(E_HB.NE.E_HJ))THEN  
       IF(E_H(HOUR).LT.E_HB)THEN
        STAGE=0.0D0
       ELSE
        IF(E_H(HOUR).LT.E_HJ)THEN
         STAGE=1.0D0
        ENDIF
        IF(E_H(HOUR).GE.E_HJ)THEN
          STAGE=2.0D0
        ENDIF
        IF(E_H(HOUR).GE.E_HP)THEN        
          STAGE=3.0D0
        ENDIF
       ENDIF
       IF(CUMBATCH(HOUR).GT.0)THEN
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=4.0D0
        ELSE
         STAGE=STAGE
        ENDIF
       ENDIF
      ENDIF

      ! ABP MODEL
      IF(METAB_MODE.EQ.1)THEN
       IF((STAGE.GT.0).AND.(STAGE.LT.STAGES-1))THEN
C       LARVA/NYMPH, USE CRITICAL LENGTH THRESHOLDS
        L_THRESH=L_INSTAR(INT(STAGE))
       ENDIF
       IF(STAGE.EQ.0)THEN
        IF(E_H(HOUR).GE.E_HB)THEN
         STAGE=STAGE+1.0D0
        ENDIF
       ELSE
        IF(STAGE.LT.STAGES-1)THEN
         IF(V(HOUR)**(1./3.).GT.L_THRESH)THEN
          STAGE=STAGE+1.0D0
         ENDIF
        ENDIF
        IF(E_H(HOUR).GE.E_HP)THEN
         STAGE=STAGES-1.0D0
        ENDIF
       ENDIF
      ENDIF     
      IF(STAGE.GT.STAGES-1)THEN
       STAGE=STAGES-1.0D0
      ENDIF

C     REPRODUCTION

      IF(CUMBATCH(HOUR).GT.0)THEN
       IF(MONMATURE.EQ.0)THEN
        MONMATURE=(COUNTDAY+365*(IYEAR-1))/30.5
       ENDIF
      ENDIF
      
      IF((CUMBATCH(HOUR).GT.CLUTCHENERGY).OR.(PREGNANT.EQ.1))THEN
C      BATCH IS READY SO IF VIVIPAROUS, START GESTATION, ELSE DUMP IT
       IF(VIVIPAROUS.EQ.1)THEN
        IF((PREGNANT.EQ.0).AND.(BREEDING.EQ.1))THEN
         V_BABY=V_INIT_BABY
         E_BABY=E_INIT_BABY
         EH_BABY=0.
         PREGNANT=1
        ENDIF
        IF(HOUR.EQ.1)THEN
         V_BABY=V_BABY_INIT
         E_BABY=E_BABY_INIT
         EH_BABY=EH_BABY_INIT
        ENDIF
        IF(PREGNANT.EQ.1)THEN
        CALL DEB_BABY
        ENDIF
        IF(EH_BABY.GE.E_HB)THEN
         IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
          GOTO 898
         ENDIF
         CUMBATCH(HOUR) = 0.
         !CUMBATCH_INIT = 0.
         REPRO(HOUR)=1
         PREGNANT=0
         V_BABY=V_INIT_BABY
         E_BABY=E_INIT_BABY
         EH_BABY=0
         NEWCLUTCH=CLUTCHSIZE
         FEC(IYEAR)=FEC(IYEAR)+CLUTCHSIZE
         FECUNDITY=FECUNDITY+CLUTCHSIZE
         CLUTCHES=CLUTCHES+1
         IF(FECUNDITY.GE.CLUTCHSIZE)THEN
          MONREPRO=(COUNTDAY+365.*(IYEAR-1))/30.5
          L_WREPRO=L_W(HOUR)
         ENDIF
         PREGNANT=0
         CLUTCHSIZE = ORIG_CLUTCHSIZE
        ENDIF
       ELSE
C      NOT VIVIPAROUS, SO LAY THE EGGS AT NEXT PERIOD OF ACTIVITY
        IF(BREEDRAINTHRESH.GT.0)THEN
         IF(RAINFALL.LT.BREEDRAINTHRESH)THEN
          GOTO 898
         ENDIF
        ENDIF
        IF((AQUABREED.EQ.1).AND.(POND_DEPTH.EQ.1))THEN
          GOTO 898
         ENDIF
        IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
         GOTO 898
        ENDIF
C       CHANGE BELOW TO ACTIVE OR NOT ACTIVE RATHER THAN DEPTH-BASED, IN CASE OF FOSSORIAL
        IF((TB .LT. TMINPR) .OR. (TB .GT. TMAXPR))THEN
         GOTO 898
        ENDIF
        TESTCLUTCH=REAL(FLOOR(CUMBATCH(HOUR)/E_EGG),8)
        IF(TESTCLUTCH.GT.CLUTCHSIZE)THEN
         CLUTCHSIZE=TESTCLUTCH
         NEWCLUTCH=CLUTCHSIZE
         CLUTCHENERGY=CLUTCHSIZE*E_EGG
        ENDIF
        CUMBATCH(HOUR) = CUMBATCH(HOUR)-CLUTCHENERGY
        !CUMBATCH_INIT = CUMBATCH(HOUR)
        REPRO(HOUR)=1
        FEC(IYEAR)=FEC(IYEAR)+CLUTCHSIZE
        FECUNDITY=FECUNDITY+CLUTCHSIZE
        CLUTCHES=CLUTCHES+1
        IF(FECUNDITY.GE.CLUTCHSIZE)THEN
         MONREPRO=(COUNTDAY+365.*(IYEAR-1))/30.5
         L_WREPRO=L_W(HOUR)
        ENDIF
         CLUTCHSIZE = ORIG_CLUTCHSIZE
       ENDIF
      ENDIF

898   CONTINUE

      IF((RESET.GT.0).AND.(RESET.NE.8))THEN
       FEC(IYEAR)=COMPLETION
      ENDIF

C     J FOOD EATEN PER HOUR
      IF(E_H(HOUR).GE.E_HB)THEN
       IF(ACTHR(HOUR) .GT. 1.)THEN
        P_X=FUNCT*P_XM*((X_FOOD/HALFSAT)/(1.+X_FOOD/HALFSAT))*
     &  V(HOUR)**(2./3.)! J/TIME, FOOD ENERGY INTAKE RATE
       ELSE
        P_X = 0.
       ENDIF
       DESDT=P_X-(P_AM/KAP_X)*V(HOUR)**(2./3.)
      ELSE
       P_X = 0.
       DESDT=0.
      ENDIF

      IF(V(HOUR).EQ.0.)THEN
      DESDT=0.
      ENDIF

      IF(HOUR.EQ.1)THEN
       E_S(HOUR) = E_S_INIT+DESDT
      ELSE
       E_S(HOUR) = E_S(HOUR-1)+DESDT
      ENDIF
      IF(E_S(HOUR).LT.0.)THEN
       E_S(HOUR)=0.
      ENDIF

      IF(E_S(HOUR).GT.E_SM*V(HOUR))THEN
       RESID=E_S(HOUR)-E_SM*V(HOUR)
       P_X=P_X-RESID
       E_S(HOUR)=E_SM*V(HOUR)
      ENDIF

      GUTFULL=E_S(HOUR)/(E_SM*V(HOUR))
      IF(GUTFULL.GT.1)THEN
       GUTFULL=1
      ENDIF
      
C     TALLYING J FOOD EATEN PER YEAR
      FOOD(IYEAR)=FOOD(IYEAR)+P_X
C     TALLYING LIFETIME FOOD EATEN
      IF(IYEAR.EQ.NYEAR)THEN
       IF(HOUR.EQ.24)THEN
        DO 1 I=1,NYEAR
         ANNFOOD=ANNFOOD+FOOD(I)
1       CONTINUE
       ENDIF
      ENDIF

      E_S_PAST=E_S(HOUR)

      PAS(HOUR)=P_A
      PCS(HOUR)=P_C
      PMS(HOUR)=P_M
      PGS(HOUR)=P_G
      PDS(HOUR)=P_D
      PJS(HOUR)=P_J
      PRS(HOUR)=P_R
      PBS(HOUR)=P_B

C     MASS BALANCE

      ! MOLAR FLUXES OF FOOD, STRUCTURE, RESERVE AND FAECES (MOL/HOUR)
      JOJX=P_A*ETAO(1,1)+P_D*ETAO(1,2)+P_G*ETAO(1,3) 
      JOJV=P_A*ETAO(2,1)+P_D*ETAO(2,2)+P_G*ETAO(2,3)
      JOJE=P_A*ETAO(3,1)+P_D*ETAO(3,2)+P_G*ETAO(3,3)
      JOJP=P_A*ETAO(4,1)+P_D*ETAO(4,2)+P_G*ETAO(4,3)

      ! NON-ASSIMILATION (I.E. GROWTH AND MAINTENANCE) MOLAR FLUXES AS ABOVE
      JOJX_GM=P_D*ETAO(1,2)+P_G*ETAO(1,3)
      JOJV_GM=P_D*ETAO(2,2)+P_G*ETAO(2,3)
      JOJE_GM=P_D*ETAO(3,2)+P_G*ETAO(3,3)
      JOJP_GM=P_D*ETAO(4,2)+P_G*ETAO(4,3)

      ! MOLAR FLUXES OF 'MINERALS', CO2, H2O, O2 AND NITROGENOUS WASTE (MOL/H)
      JMCO2=JOJX*JM_JO(1,1)+JOJV*JM_JO(1,2)+JOJE*JM_JO(1
     &    ,3)+JOJP*JM_JO(1,4)
      JMH2O=JOJX*JM_JO(2,1)+JOJV*JM_JO(2,2)+JOJE*JM_JO(
     &    2,3)+JOJP*JM_JO(2,4)
      JMO2=JOJX*JM_JO(3,1)+JOJV*JM_JO(3,2)+JOJE*JM_JO
     &    (3,3)+JOJP*JM_JO(3,4)
      JMNWASTE=JOJX*JM_JO(4,1)+JOJV*JM_JO(4,2)+JOJE*
     &    JM_JO(4,3)+JOJP*JM_JO(4,4)

      RQ = JMCO2/JMO2 ! RESPIRATORY QUOTIENT

      ! NON-ASSLIMILATION MOLAR FLUXES OF 'MINERALS', CO2, H2O, O2 AND NITROGENOUS WASTE (MOL/H)
      JMCO2_GM=JOJX_GM*JM_JO(1,1)+JOJV_GM*JM_JO(1,2)
     & +JOJE_GM*JM_JO(1,3)+JOJP_GM*JM_JO(1,4)
      JMH2O_GM=JOJX_GM*JM_JO(2,1)+JOJV_GM*JM_JO(2,2)
     & +JOJE_GM*JM_JO(2,3)+JOJP_GM*JM_JO(2,4)
      JMO2_GM=JOJX_GM*JM_JO(3,1)+JOJV_GM*JM_JO(3,2)
     & +JOJE_GM*JM_JO(3,3)+JOJP_GM*JM_JO(3,4)
      JMNWASTE_GM=JOJX_GM*JM_JO(4,1)+JOJV_GM*JM_JO(4,2)
     & +JOJE_GM*JM_JO(4,3)+JOJP_GM*JM_JO(4,4)

C     RESPIRATION IN ML/H, TEMPERATURE CORRECTED (INCLUDING SDA)

C     PV=nRT
C     T=273.15 #K
C     R=0.082058 #L*atm/mol*K
C     n=1 #mole
C     P=1 #atm
C     V=nRT/P=1*0.082058*273.15=22.41414
C     T=293.15
C     V=nRT/P=1*0.082058*293.15/1=24.0553
C     P_atm <- 1
C     R_const <- 0.082058
C     gas_cor <- R_const * T_REF / P_atm * (Tb + 273.15) / T_REF * 1000 # 1 mole to ml/h at Tb and atmospheric pressure

      IF(DEB1.EQ.1)THEN
       O2FLUX = -1.*JMO2*(0.082058*(T_REF+273.15)/1.*(TB+273.15)/
     &  (T_REF+273.15))*1000. ! ml/h at Tb and atmospheric pressure
      ELSE
C      SEND THE ALLOMETRIC VALUE TO THE OUTPUT FILE
       O2FLUX = 10.**(MR_3*TC)*MR_1*(AMASS*1000.)**MR_2 ! REGRESSION-BASED
      ENDIF

      CO2FLUX = JMCO2*(0.082058*(T_REF+273.15)/1.*(TB+273.15)/
     &  (T_REF+273.15))*1000.
     
C     G METABOLIC WATER/H
      GH2OMET(HOUR) = JMH2O*18.01528
      
C     METABOLIC HEAT PRODUCTION (WATTS) - GROWTH OVERHEAD PLUS DISSIPATION POWER (MAINTENANCE, MATURITY MAINTENANCE,
C     MATURATION/REPRO OVERHEADS) PLUS ASSIMILATION OVERHEADS - CORRECT TO 20 DEGREES SO IT CAN BE TEMPERATURE CORRECTED
C     IN MET.F FOR THE NEW GUESSED TB
      DEBQMET(HOUR) = ((1.-KAP_G)*P_G+P_D+(P_A/KAP_X-P_A-P_A*MU_P
     & *ETA_PA))/3600./TCORR
      MU_O = (/MU_X, MU_V, MU_E, MU_P/) ! J/mol, chemical potentials of organics
      MU_M = (/0.D0, 0.D0, 0.D0, MU_N/)          ! J/mol, chemical potentials of minerals C: CO2, H: H2O, O: O2, N: nitrogenous waste
      J_O = (/JOJX, JOJV, JOJE, JOJP/) ! eta_O * diag(p_ADG(2,:)); # mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
      J_M = (/JMCO2, JMH2O, JMO2, JMNWASTE/) ! - (n_M\n_O) * J_O;        # mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
      DEBQMET(HOUR) = sum(-J_O * MU_O -J_M * MU_M)/3600./TCORR ! W    
      
      DRYFOOD(HOUR)=-1*JOJX*W_X ! DRY FOOD INTAKE (G)
      FAECES(HOUR)=JOJP*W_P ! FAECES PRODUCTION (G)
      NWASTE(HOUR)=JMNWASTE*W_N ! NITROGENOUS WASTE PRODUCTION (G)
      IF(PREGNANT.EQ.1)THEN ! REPRODUCTIVE WET BIOMASS (G)
       WETGONAD(HOUR) = ((CUMREPRO(HOUR)/MU_E)*W_E)/EGGDRYFRAC
     & +((((V_BABY*E_BABY)/MU_E)*W_E)/D_V + V_BABY)*CLUTCHSIZE
      ELSE
       WETGONAD(HOUR) = ((CUMREPRO(HOUR)/MU_E)*W_E)/EGGDRYFRAC
     & +((CUMBATCH(HOUR)/MU_E)*W_E)/EGGDRYFRAC
      ENDIF
      WETSTORAGE(HOUR) = (((V(HOUR)*ED(HOUR))/MU_E)*W_E)/D_V ! RESERVE WET MASS (G)
      WETFOOD(HOUR) = ((E_S(HOUR)/MU_E)*W_E)/(1-FOODWATERS(DAYCOUNT)) ! WET FOOD MASS (G)
      WETMASS(HOUR) = V(HOUR)*ANDENS_DEB+WETGONAD(HOUR)+ ! TOTAL WET MASS (G)
     &WETSTORAGE(HOUR)+WETFOOD(HOUR)
      GUTFREEMASS=V(HOUR)*ANDENS_DEB+WETGONAD(HOUR)+
     &WETSTORAGE(HOUR)
      POTFREEMASS=V(HOUR)*ANDENS_DEB+(((V(HOUR)*E_M)/MU_E)*W_E)/D_V ! NON REPRODUCTIVE AND NON FOOD WET MASS

C     STATE OF BABY IF VIVIPAROUS AND PREGNANT     
      V_BABY1(HOUR)=V_BABY
      E_BABY1(HOUR)=E_BABY
      EH_BABY1(HOUR)=EH_BABY

      IF(CONTH.EQ.0)THEN
       IF((VIVIPAROUS.EQ.1).AND.(E_H(HOUR).LT.E_HB))THEN
C       MAKE THE MASS, METABOLIC HEAT AND O2 FLUX THAT OF A FULLY GROWN INDIVIDUAL TO GET THE HEAT BALANCE OF
C       A THERMOREGULATING MOTHER WITH FULL RESERVES
        AMASS=MAXMASS/1000.
        P_M = P_MV*V_M
        P_C = (E_M*(VDOT/L_M+K_M*(1+L_T/L_M))*
     &    (1*G)/(1+G))*V_M
        P_J = K_J*E_HP
        P_G = 0.
        P_R = (1.-KAP)*P_C-P_J
        P_D = P_M+P_J+(1-KAP_R)*P_R
        P_A = V_M**(2./3.)*P_AM*F
        IF(ACTHR(HOUR).GT.1)THEN
         P_X = F * P_XM * V_M**(2./3.)*((X_FOOD / HALFSAT)
     &  / (1. + X_FOOD / HALFSAT))
        ELSE
         P_X = 0.
        ENDIF
        IF((METAB_MODE.EQ.1).AND.(E_H(HOUR).GE.E_HJ))THEN
         P_G = 0.
         P_C = E_M*V_M*VDOT/L_M  
         P_R = (1.-KAP)*P_A-P_J
        ELSE
         P_G = P_C-P_M-P_J-P_R
        ENDIF        
        JOJX=P_A*ETAO(1,1)+P_D*ETAO(1,2)+P_G*ETAO(1,3)
        JOJV=P_A*ETAO(2,1)+P_D*ETAO(2,2)+P_G*ETAO(2,3)
        JOJE=P_A*ETAO(3,1)+P_D*ETAO(3,2)+P_G*ETAO(3,3)
        JOJP=P_A*ETAO(4,1)+P_D*ETAO(4,2)+P_G*ETAO(4,3)
        JMO2=JOJX*JM_JO(3,1)+JOJV*JM_JO(3,2)+JOJE*JM_JO(3,3)+
     &        JOJP*JM_JO(3,4)
C       MLO2(HOUR)=-1*JMO2/(T_REF/TB/24.4)*1000
        MLO2(HOUR)=(-1*JMO2*(0.082058*(TB+273.15))/
     &    (0.082058*293.15))*24.06*1000.
        DEBQMET(HOUR)=(P_D+(P_A/KAP_X-P_A-P_A*MU_P*ETA_PA))/3600./TCORR
       ELSE
        AMASS=WETMASS(HOUR)/1000.
       ENDIF
      ENDIF

987   CONTINUE

      V_INIT=V(HOUR)
      E_INIT=ED(HOUR)
      E_S_INIT=E_S(HOUR)
      E_H_INIT=E_H(HOUR)
      Q_INIT=Q(HOUR)
      HS_INIT=HS(HOUR)
      SURVIV_INIT=SURVIV(HOUR)
      CUMREPRO_INIT=CUMREPRO(HOUR)
      CUMBATCH_INIT=CUMBATCH(HOUR)
      
C     RESET IF DEAD
      IF(DEAD.EQ.1)THEN
       E_S_PAST=0.
       P_B=0.
       L_W(HOUR)=0.
       WETGONAD(HOUR)=0.
       WETSTORAGE(HOUR)=0.
       WETFOOD(HOUR)=0.
       WETMASS(HOUR)=0.
       E_H(HOUR)=0.
       ED(HOUR)=0.
       V(HOUR)=0.
       AMASS=((((V_INIT*E_INIT)/MU_E)*W_E)/D_V + V_INIT)/1000.
       BREEDVECT(HOUR)=0
      ENDIF

      IF(HOUR.EQ.24)THEN
       IF(COMPLETE.EQ.1)THEN
        COMPLETION=COMPLETION+1
        COMPLETE=0
       ENDIF
      ENDIF

      IF((DEAD.EQ.0).AND.(DVDT.GT.0))THEN
       DEAD=0
      ENDIF

      STAGE_REC(HOUR)=STAGE

      RETURN
      END