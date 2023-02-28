      SUBROUTINE DEB_BABY

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

C     IMPLEMENTATION OF KOOIJMAN'S KAPPA-RULE STANDARD DEB MODEL FOR VIVIPAROUSLY DEVELOPING OFFSPRING

      IMPLICIT NONE

      DOUBLE PRECISION ANDENS_DEB,BREEDRAINTHRESH,CLUTCHA,CLUTCHB
      DOUBLE PRECISION CLUTCHSIZE,CTMAX,CTMIN,CUMBATCH_INIT
      DOUBLE PRECISION CUMREPRO_INIT,D_V,DAYLENGTHFINISH,DAYLENGTHSTART
      DOUBLE PRECISION DE_HDT,DEDT,DELTA_DEB,DLDT,DUEDT,DUHDT,DVDT
      DOUBLE PRECISION E_BABY,E_BABY_INIT,E_EGG,E_G,E_H_INIT,E_HE
      DOUBLE PRECISION E_H_PRES,E_H_START,E_HB,E_HJ,E_HO,E_HP
      DOUBLE PRECISION E_HPUP_INIT,E_INIT,E_INIT_BABY,E_M,E_M2,E_PRES
      DOUBLE PRECISION E_SCALED,E_TEMP,EGGDRYFRAC,EH_BABY,EH_BABY_INIT
      DOUBLE PRECISION EPUP_INIT,E_S_INIT,E_SM,F,FUNCT,G,H_AREF,HALFSAT
      DOUBLE PRECISION HS_INIT,K_EL,K_EV,K_J,K_JREF,K_M,KAP,KAP_R,KAP_V
      DOUBLE PRECISION KAP_X,KAP_X_P,L_B,L_J,L_M,L_PRES,L_T,LAMBDA,LAT
      DOUBLE PRECISION LENGTHDAY,LENGTHDAYDIR,M_V,MAXMASS,MU_E,MU_N,MU_P
      DOUBLE PRECISION MU_V,MU_X,P_AM,P_MREF,P_MV,P_XMREF,PREVDAYLENGTH
      DOUBLE PRECISION Q_INIT,S_G,S_J,SC,SCALED_L,SURVIV_INIT,T_A,T_A2
      DOUBLE PRECISION T_AH,T_AH2,T_AL,T_AL2,T_H,T_H2,T_L,T_L2,T_REF,TB
      DOUBLE PRECISION TC,TCORR,TCORR2,U_H_PRES,V_BABY,V_BABY_INIT
      DOUBLE PRECISION V_INIT,V_INIT_BABY,V_M,V_PRES,V_TEMP,VDOT,VDOTREF
      DOUBLE PRECISION VOLD_INIT,VPUP_INIT,W_E,W_N,W_P,W_V,W_X,X_FOOD
      DOUBLE PRECISION ZFACT

      INTEGER AQUABREED,AQUASTAGE,BATCH,BREEDACT,BREEDACTTHRES,BREEDING
      INTEGER BREEDVECT,COUNTDAY,CTKILL,CTMINCUM,CTMINTHRESH,DAYCOUNT
      INTEGER METAB_MODE,METAMORPH,PHOTODIRF,PHOTODIRS,PHOTOFINISH
      INTEGER PHOTOSTART,PREGNANT,STAGES,VIVIPAROUS,ARRHEN,STARVEMODE
      INTEGER FOODMODE
      
      DIMENSION BREEDVECT(24)
      
      COMMON/ARRHEN/T_A,T_AL,T_AH,T_L,T_H,T_REF,ARRHEN
      COMMON/ARRHEN2/T_A2,T_AL2,T_AH2,T_L2,T_H2
      COMMON/BREEDER/BREEDING,BREEDVECT
      COMMON/COUNTDAY/COUNTDAY,DAYCOUNT
      COMMON/CTMAXMIN/CTMAX,CTMIN,CTMINCUM,CTMINTHRESH,CTKILL
      COMMON/DEBBABY/V_BABY,E_BABY,EH_BABY
      COMMON/DEBINIT1/V_INIT,E_INIT,CUMREPRO_INIT,CUMBATCH_INIT,
     &  VOLD_INIT,VPUP_INIT,EPUP_INIT
      COMMON/DEBINIT2/E_S_INIT,Q_INIT,HS_INIT,P_MREF,VDOTREF,H_AREF,
     & E_BABY_INIT,V_BABY_INIT,EH_BABY_INIT,K_JREF,S_G,SURVIV_INIT,
     & HALFSAT,X_FOOD,E_HPUP_INIT,P_XMREF
      COMMON/DEBPAR1/CLUTCHSIZE,ANDENS_DEB,D_V,EGGDRYFRAC,W_E,MU_E,MU_V,
     & W_V,E_EGG,KAP_V,KAP_X,KAP_X_P,MU_X,MU_P,W_N,W_P,W_X,FUNCT,MU_N
      COMMON/DEBPAR2/ZFACT,KAP,E_G,KAP_R,DELTA_DEB,E_H_START,MAXMASS,
     & E_INIT_BABY,V_INIT_BABY,E_H_INIT,E_HB,E_HP,E_HJ,E_HO,E_SM,
     & LAMBDA,BREEDRAINTHRESH,DAYLENGTHSTART,DAYLENGTHFINISH,LENGTHDAY,
     & LENGTHDAYDIR,PREVDAYLENGTH,LAT,CLUTCHA,CLUTCHB,E_HE,
     & AQUABREED,AQUASTAGE,PHOTODIRS,PHOTODIRF,
     & BREEDACTTHRES,METAMORPH,PHOTOSTART,PHOTOFINISH,BREEDACT,BATCH
      COMMON/DEBPAR3/METAB_MODE,STAGES,K_EL,K_EV,STARVEMODE,FOODMODE
      COMMON/DEBPAR4/S_J,L_B,L_J,E_M2
      COMMON/TREG/TC
      COMMON/VIVIP/VIVIPAROUS,PREGNANT

C     BODY TEMPERATURE
      TB = MIN(CTMAX, TC) ! DON'T LET IT GO TOO HIGH
      
C     ARRHENIUS TEMPERATURE CORRECTION FACTOR
      IF(ARRHEN.EQ.0)THEN
       TCORR = EXP(T_A*(1./(273.15+T_REF)-1./(273.15+TB)))/(1.+EXP(T_AL ! EQUATION FROM ORIGINAL SCHOOLFIELD PAPER
     & *(1./(273.15+TB)-1./T_L))+EXP(T_AH*(1./T_H-1./(273.15+TB))))
       TCORR2 = EXP(T_A*(1./(273.15+T_REF)-1./(273.15+TB)))/(1.+EXP( ! EQUATION FROM ORIGINAL SCHOOLFIELD PAPER
     & T_AL2*(1./(273.15+TB)-1./T_L))+EXP(T_AH2*(1./T_H-1./
     & (273.15+TB))))
      ELSE
       TCORR = EXP(T_A/(273.15+T_REF)-T_A/(273.15+TB))*((1.+EXP(T_AL/ ! THIS VERSION ALLOWS K_REF TO VARY FROM WHAT IS SPECIFIED AS A PARAMETER (USED IN DEBTOOL)
     &(273.15+T_REF)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+T_REF)))/(1.
     &+EXP(T_AL/(273.15+TB)-T_AL/T_L)+EXP(T_AH/T_H-T_AH/(273.15+TB))))
       TCORR2 = EXP(T_A2/(273.15+T_REF)-T_A2/(273.15+TB))*((1.+EXP( ! THIS VERSION ALLOWS K_REF TO VARY FROM WHAT IS SPECIFIED AS A PARAMETER (USED IN DEBTOOL)
     &T_AL2/(273.15+T_REF)-T_AL2/T_L2)+EXP(T_AH2/T_H2-T_AH2/(273.15+
     &T_REF)))/(1.+EXP(T_AL2/(273.15+TB)-T_AL2/T_L2)+EXP(T_AH2/T_H2-
     &T_AH2/(273.15+TB))))
      ENDIF
     
      V_PRES = V_BABY
      E_PRES = E_BABY
      E_H_PRES = EH_BABY

      IF(V_PRES.EQ.V_INIT_BABY)THEN
       E_PRES=E_EGG/V_PRES
      ENDIF
      F = 1.

C     TEMPERATURE CORRECTIONS AND COMPOUND PARAMETERS
      M_V = ANDENS_DEB/W_V
      P_MV = P_MREF*TCORR
      K_M = P_MV/E_G
      K_J = K_JREF*TCORR2
      P_AM = P_MV*ZFACT/KAP
      VDOT = VDOTREF*TCORR
      E_M = P_AM/VDOT
      G = E_G/(KAP*E_M)
      E_SCALED=E_PRES/E_M
      V_M = (KAP*P_AM/P_MV)**(3.)
      L_T = 0.
      L_PRES = V_PRES**(1./3.)
      L_M = V_M**(1./3.)
      SCALED_L = L_PRES/L_M

C     EMBRYO EQUATION FOR LENGTH, FROM KOOIJMAN 2009 EQ. 2
      DLDT = (VDOT*E_SCALED-K_M*G*V_PRES**(1./3.))/(3.*(E_SCALED+G))
      V_TEMP=(V_PRES**(1./3.)+DLDT)**3.
      DVDT = V_TEMP-V_PRES

C     EMBRYO EQUATION FOR SCALED RESERVE, U_E, FROM KOOIJMAN 2009 EQ. 1
      SC=L_PRES**2.*(G*E_SCALED)/(G+E_SCALED)*(1.+((K_M*L_PRES)/VDOT))
      DUEDT=-1.*SC
      E_TEMP=((E_PRES*V_PRES/P_AM)+DUEDT)*P_AM/(V_PRES+DVDT)
      DEDT=E_TEMP-E_PRES

C     EMBRYO EQUATION FOR SCALED MATURITY, U_H, FROM KOOIJMAN 2009 EQ. 3
      U_H_PRES=E_H_PRES/P_AM
      DUHDT=(1.-KAP)*SC-K_J*U_H_PRES
      DE_HDT=DUHDT*P_AM

      V_BABY = V_PRES+DVDT
      E_BABY = E_PRES+DEDT
      EH_BABY = E_H_PRES+DE_HDT
C     MAKE SURE ED DOESN'T GO BELOW ZERO
      IF(E_BABY.LT.0)THEN
       E_BABY=0.0D0
      ENDIF

      RETURN
      END



