      SUBROUTINE THERMOREG(QUIT)

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


C     THIS THERMOREGULATION SUBROUTINE ALLOWS FOR BURROW RETREAT,
C     IF ALLOWED, AND FOR SHADE SEEKING, EITHER ONLY ON THE
C     GROUND OR CLIMBING TO 2M (REFERENCE) HEIGHT TO SEEK
C     COOLER TEMPERATURES AND HIGHER WIND SPEEDS.

      USE AACOMMONDAT

      IMPLICIT NONE

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ABSAN,ABSMAX,ABSMIN,ABSSB
      DOUBLE PRECISION ACTHR,AL,AMASS,ANDENS,AREF,ASIL,ASILN,ASILP,ATOT
      DOUBLE PRECISION BREF,CREF,CTMAX,CTMIN,CUSTOMGEOM,DELTAR,DEPSEL
      DOUBLE PRECISION DEPSUB,DEPTH,DSHD,EGGSHP,EMISAN,EMISSB,EMISSK
      DOUBLE PRECISION EXTREF,F12,F13,F14,F15,F16,F21,F23,F24,F25,F26
      DOUBLE PRECISION F31,F32,F41,F42,F51,F52,F61,FATOBJ,FATOSB,FATOSK
      DOUBLE PRECISION FLSHCOND,FLUID,FLYMETAB,FLYSPEED,FLYTIME,FOODLIM
      DOUBLE PRECISION G,GUTFILL,GUTFULL,HRN,HSHSOI,HSOIL,MAXSHD,MR_1
      DOUBLE PRECISION MR_2,MR_3,MSHSOI,MSOIL,NEWDEP,PDIF,PHI,PHIMAX
      DOUBLE PRECISION PHIMIN,PSHSOI,PSOIL,PTCOND,PTCOND_ORIG,QCOND
      DOUBLE PRECISION QCONV,QIRIN,QIROUT,QMETAB,QRESP,QSEVAP,QSOL
      DOUBLE PRECISION QSOLAR,QSOLR,QUIT,REFSHD,RELHUM,RH,RHO1_3,RHREF
      DOUBLE PRECISION RQ,SHADE,SHP,SIDEX,SIG,SPHEAT,SUBTK,TA,TALOC
      DOUBLE PRECISION TANNUL,TBASK,TC,TCORES,TDIGPR,TEMERGE,TIME,TLUNG
      DOUBLE PRECISION TMAXPR,TMINPR,TOBJ,TPREF,TQSOL,TRANS1,TREF,TSHLOW
      DOUBLE PRECISION TSHOIL,TSHSKI,TSHSOI,TSKY,TSKYC,TSOIL,TSOILS,TSUB
      DOUBLE PRECISION TSUBST,TWING,VEL,VLOC,VREF,WC,WQSOL,Z,ZEN,ZSOIL
      DOUBLE PRECISION WEYES,WRESP,WCUT,AEFF,CUTFA,HD,PEYES,SKINW,
     & SKINT,HC,CONVAR,PMOUTH,PANT,PANTMAX,EGGPTCOND

      INTEGER BURROWSHADE,CLIMBING,CTKILL,CTMINCUM,CTMINTHRESH,DEB1
      INTEGER FLIGHT,FLYER,FLYTEST,GEOMETRY,IHOUR,LIVE,MICRO,MINNODE,NM
      INTEGER NODNUM,NON,POSTUR,SHDBURROW,WINGCALC,WINGMOD

      CHARACTER*1 BURROW,DAYACT,CLIMB,CKGRSHAD,CREPUS,NOCTURN

      DIMENSION ACTHR(25),CUSTOMGEOM(8),DEPSEL(25),HRN(25),HSHSOI(25)
      DIMENSION HSOIL(25),MSHSOI(25),MSOIL(25),PSHSOI(25),PSOIL(25)
      DIMENSION QSOL(25),RH(25),RHREF(25),SHP(3),TALOC(25),TCORES(25)
      DIMENSION TIME(25),TREF(25),TSHLOW(25),TSHOIL(25),TSHSKI(25)
      DIMENSION TSHSOI(25),TSKYC(25),TSOIL(25),TSOILS(25),TSUB(25)
      DIMENSION VLOC(25),VREF(25),Z(25),ZSOIL(10),EGGSHP(3)

      COMMON/BEHAV1/DAYACT,BURROW,CLIMB,CKGRSHAD,CREPUS,NOCTURN
      COMMON/BEHAV2/GEOMETRY,NODNUM,CUSTOMGEOM,SHP,EGGSHP
      COMMON/BEHAV3/ACTHR
      COMMON/BUR/NON,MINNODE
      COMMON/BURROW/SHDBURROW,BURROWSHADE
      COMMON/CLIMB/CLIMBING
      COMMON/CTMAXMIN/CTMAX,CTMIN,CTMINCUM,CTMINTHRESH,CTKILL
      COMMON/DEPTHS/DEPSEL,TCORES
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL,VLOC
      COMMON/ENVIRS/TSOILS,TSHOIL
      COMMON/EVAP1/WEYES,WRESP,WCUT,AEFF,CUTFA,HD,PEYES,SKINW,
     & SKINT,HC,CONVAR,PMOUTH,PANT,PANTMAX 
      COMMON/FLY/FLYTIME,FLYSPEED,FLYMETAB,FLIGHT,FLYER,FLYTEST
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG,
     & EGGPTCOND
      COMMON/FUN5/WC,ZEN,PDIF,ABSSB,ABSAN,ASILN,FATOBJ,NM
      COMMON/FUN6/SPHEAT,ABSMAX,ABSMIN,LIVE
      COMMON/GUT/GUTFULL,GUTFILL,FOODLIM
      COMMON/POSTURE/POSTUR
      COMMON/REFSHADE/REFSHD
      COMMON/REVAP1/TLUNG,DELTAR,EXTREF,RQ,MR_1,MR_2,MR_3,DEB1
      COMMON/SHADE/MAXSHD,DSHD
      COMMON/SHENV1/TSHSKI,TSHLOW
      COMMON/SOIL/TSOIL,TSHSOI,ZSOIL,MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,
     & HSHSOI
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26
     &,WINGCALC,WINGMOD      
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/WUNDRG/NEWDEP
      
      DEPTH = NEWDEP
      
      IF((TC.LT.TMINPR).AND.(ASIL.NE.ASILN))THEN
       ASIL=ASILN ! NORMAL TO SUN'S RAYS
       POSTUR=1
       CALL SOLAR
       IF(TSUBST.GT.TC)THEN
        PTCOND=PTCOND_ORIG*1.2 ! INCREASE CONTACT WITH SUBSTRATE
       ELSE
        PTCOND=PTCOND_ORIG
       ENDIF
       RETURN
      ENDIF
      
C     REVERT TO ACTIVITY POSTURE IF >= TMINPR OR <=TPREF
      IF(((TC.GE.TMINPR).AND.(POSTUR.EQ.1)).OR.
     & ((TC.LE.TPREF).AND.(POSTUR.EQ.2)))THEN        
       ASIL=(ASILN+ASILP)/2.
       POSTUR=0
       PTCOND=PTCOND_ORIG
       CALL SOLAR
      ENDIF
      
      
C     TRY WING ANGLE CHANGE (IF BUTTERFLY)
      IF((WINGMOD.GT.0).AND.(FLYTEST.NE.1))THEN
       IF(PHIMIN.NE.PHIMAX)THEN
        IF(PHI.NE.PHIMAX)THEN
         IF(DEPTH.LE.0.0001)THEN
C         ON THE SURFACE.  WHAT'S THE CORE TEMPERATURE, TOO HOT OR TOO COLD?
          IF(TC.LT.TPREF)THEN
           IF(PHI.LT.PHIMAX)THEN
            PHI=PHI+20
            CALL SOLAR
            IF(PHI.GT.PHIMAX)THEN
             PHI=PHIMAX
            ENDIF
            RETURN
           ENDIF
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF

C     COLOUR CHANGE
C     CHECK REFLECTIVITY (NEED MAX/MIN VALUES) IF NO CHANGE POSSIBLE, USE SAME VALUES FOR MAX, MIN.
C     IN GENERAL, ANIMALS THAT CAN CHANGE COLOR ARE DARK BELOW THEIR MINIMUM ACTIVITY TEMPERATURE.
      IF((QSOLAR.GT.0.0000).AND.(DEPTH.LE.0.00001))THEN
       IF(TC.GT.TPREF)THEN
        IF(ABSAN.GT.ABSMIN)THEN
C        USE MIN VALUE
         ABSAN = ABSAN-0.05
         IF(ABSAN.LT.ABSMIN)THEN
          ABSAN=ABSMIN
         ENDIF
         CALL SOLAR
        ENDIF
       ELSE
        ABSAN = ABSMAX
        CALL SOLAR
       ENDIF
      ENDIF

      IF((DEPTH.LE.0.00001).AND.(Z(IHOUR).LT.90.))THEN
C      ON THE SURFACE, SUN IS UP. DIURNAL BEHAVIOURAL THERMOREGULATION WHAT'S THE CORE TEMPERATURE, TOO HOT OR TOO COLD?
       IF(TC.GT.TPREF)THEN
        IF((ASIL.GT.ASILP).AND.(SHADE.EQ.0))THEN
         ASIL=ASILP ! FIRST TRY POINTING PARALLEL TO SUN'S RAYS
         POSTUR=2
         CALL SOLAR
         RETURN
        ENDIF
C       NEED SOME SHADE, LESS SUN
        IF((CKGRSHAD.EQ.'Y').OR.(CKGRSHAD.EQ.'Y')) THEN
         IF(SHADE.LT.MAXSHD)THEN
C         INCREASE THE SHADE (CALL SHADEADJUST) & RECALCULATE LOCAL ENVIRONMENT (CALL ABOVEGROUND)
          ASIL=(ASILN+ASILP)/2. ! REVERT TO FORAGING POSTURE
          POSTUR=0
          CALL SOLAR
          CALL SHADEADJUST
          RETURN
         ENDIF
         SHADE=MAXSHD
        ENDIF
        IF(TPREF .LE. TMAXPR)THEN
         TPREF=TPREF+0.5
         IF(TPREF .GT. TMAXPR)THEN
          TPREF = TMAXPR
         ELSE
          RETURN
         ENDIF
        ENDIF
C       IF GOT THIS FAR SHADE MAXED OUT. CLIMB?
        IF ((CLIMB.EQ.'Y').OR.(CLIMB.EQ.'Y')) THEN
         IF(DEPSEL(IHOUR).NE.150.0)THEN
C         TRY CLIMBING
          IF ((TREF(IHOUR).GE.TMINPR).AND.(TREF(IHOUR).LE.TPREF))THEN
C          IT'S OK UP HIGH
C          CLIMB TO 150 CM HEIGHT
           DEPSEL(IHOUR) = 150.0
C          REFERENCE HEIGHT AIR TEMPERATURE IS THE SAME IN SUN OR SHADE.
           TA = TREF(IHOUR)
           VEL = VREF(IHOUR)
           CLIMBING = 1
           RETURN
C          NO ASSUMPTION OF INCREASE IN SHADE DUE TO CLIMBING.  MAY STILL BE IN THE SUN.
          ENDIF
         ENDIF
        ENDIF
        IF(PANT.LT.PANTMAX)THEN
         PANT=PANT+0.1 ! start panting
         RETURN
        ENDIF
C       IF GOT THIS FAR, THEN SHADE AND CLIMBING MAXED OUT. BURROW?
        IF((BURROW.EQ.'Y').OR.(BURROW.EQ.'Y'))THEN
         PANT=1. ! GOING UNDERGROUND SO MAKE SURE NOT STILL PANTING
         IF(DEPSEL(IHOUR).GE.0.)THEN
          IF((TC.LT.TMAXPR).AND.(TC.GT.TBASK))THEN
           QUIT=1
           RETURN
          ELSE
C          CURRENTLY ABOVE GROUND, ALLOW BURROW ENTRY & RESET LOCAL ENVIRONMENT
           CALL BURROWIN
           RETURN
          ENDIF
         ENDIF
        ELSE
C        NO BURROW ALLOWED. MUST STAY ABOVE GROUND EVEN THOUGH
C        OUTSIDE OF PREFERRED TEMPERATURE RANGE. NOT ACTIVE.
C        TRY A PHYSIOLOGICAL SOLUTION
        ENDIF
       ELSE
C       TOO COLD, TRY BURROW
        IF(DEPSEL(IHOUR).GE.0.)THEN
         IF((BURROW.EQ.'Y').OR.(BURROW.EQ.'Y'))THEN
          IF((TC.GT.CTMIN).AND.(DEPSEL(IHOUR).GE.ZSOIL(MINNODE)))THEN
           QUIT=1
           RETURN
          ELSE
C          CURRENTLY ABOVE GROUND, ALLOW BURROW ENTRY & RESET LOCAL ENVIRONMENT
           CALL BURROWIN
           RETURN
          ENDIF
         ELSE
C         NO BURROW ALLOWED. MUST STAY ABOVE GROUND EVEN THOUGH
C         OUTSIDE OF PREFERRED TEMPERATURE RANGE. NOT ACTIVE.
C         TRY A PHYSIOLOGICAL SOLUTION
         ENDIF
        ENDIF
       ENDIF
      ENDIF

      IF((DEPTH.LE.0.00001).AND.(Z(IHOUR).EQ.90))THEN
C     ON THE SURFACE, SUN IS DOWN. NOCTURNAL BEHAVIOURAL THERMOREGULATION WHAT'S THE CORE TEMPERATURE, TOO HOT OR TOO COLD?
       IF(TC.LT.TMINPR)THEN
C      NEED SOME SHADE, LESS COLD SKY
        IF ((CKGRSHAD .EQ. 'Y') .OR. (CKGRSHAD .EQ. 'Y')) THEN
         IF(SHADE.LT. MAXSHD)THEN
C        INCREASE THE SHADE (CALL SHADEADJUST) & RECALCULATE LOCAL ENVIRONMENT (CALL ABOVEGROUND)
          CALL SHADEADJUST
          RETURN
         ENDIF
        ENDIF
        IF ((CLIMB .EQ. 'Y') .OR. (CLIMB .EQ. 'Y')) THEN
         IF(DEPSEL(IHOUR).NE.150.0)THEN
C        TRY CLIMBING
          IF ((TREF(IHOUR).GE.TMINPR).AND.(TREF(IHOUR).LE.TPREF))THEN
C         IT'S OK UP HIGH
C         CLIMB TO 200 CM HEIGHT
           DEPSEL(IHOUR) = 150.0
C         REFERENCE HEIGHT AIR TEMPERATURE IS THE SAME IN SUN OR SHADE.
           TA = TREF(IHOUR)
           VEL = VREF(IHOUR)
           CLIMBING = 1
           RETURN
C         NO ASSUMPTION OF INCREASE IN SHADE DUE TO CLIMBING.  MAY STILL BE IN THE SUN.
          ENDIF
         ENDIF
        ENDIF
C       IT MAY STILL BE TOO COLD
        IF((BURROW.EQ.'Y').OR.(BURROW.EQ.'Y')) THEN
         !IF(TC.GT.CTMIN)THEN
         ! QUIT=1
         ! RETURN
         !ELSE
          SHADE=REFSHD
          CALL BURROWIN
          RETURN
         !ENDIF
        ENDIF
C       NO BURROW ALLOWED. MUST STAY ABOVE GROUND EVEN THOUGH
C       OUTSIDE OF PREFERRED TEMPERATURE RANGE. NOT ACTIVE.
C       TRY A PHYSIOLOGICAL SOLUTION
       ELSE
C       TOO HOT, TRY BURROW
        IF((BURROW.EQ.'Y').OR.(BURROW.EQ.'Y'))THEN
         IF(TC.LT.TMAXPR)THEN
          QUIT=1
          RETURN
         ELSE
          CALL BURROWIN
          RETURN
         ENDIF
        ELSE
        ENDIF
       ENDIF
      ENDIF

C     TRY PHYSIOLOGY CHANGES
C     INCREASE THERMAL CONDUCTIVITY OF TISSUES
      IF(FLSHCOND.LT.0.6)THEN
       FLSHCOND=0.6 ! MAX THAT OF WATER
       RETURN
      ENDIF

C     IF IT IS A CLIMBER AND THE ENVIRONMENT IS STILL TOO STRESSFUL, LEAVE IT UP THE TREE TO MINIMIZE STRESS
      IF((CLIMB.EQ.'Y').OR.(CLIMB.EQ.'Y'))THEN
       IF((TC.GT.TMAXPR).OR.(TC.LT.CTMIN))THEN
        IF((DEPSEL(IHOUR).NE.150.0).AND.(DEPSEL(IHOUR).GE.0))THEN
C        TRY CLIMBING
C        IT'S OK UP HIGH
C        CLIMB TO 150 CM HEIGHT
         DEPSEL(IHOUR) = 150.0
C        REFERENCE HEIGHT AIR TEMPERATURE IS THE SAME IN SUN OR SHADE.
         TA = TREF(IHOUR)
         VEL = VREF(IHOUR)
         CLIMBING = 1
         RETURN
C        NO ASSUMPTION OF INCREASE IN SHADE DUE TO CLIMBING.  MAY STILL BE IN THE SUN.
        ENDIF
       ENDIF
      ENDIF

C     IF REACH HERE, OUT OF OPTIONS, SET EXIT FLAG
      QUIT = 1.

C     RETURN TO ITADAY AND RUN ANOTHER SIMULATION WITH NEW ENVIRONMENTAL CONDITIONS
      RETURN
      END