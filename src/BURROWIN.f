      SUBROUTINE BURROWIN

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

C     THIS PROGRAM IS CALLED BY THERMO WHEN ANIMAL IS RETREATING UNDERGROUND
C     IT CHOOSES THE DEPTH AND RESETS THE ENVIRONMENT ACCORDINGLY

      USE AACOMMONDAT
      IMPLICIT NONE

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ACTHR,AL,AMASS,ANDENS,AREF
      DOUBLE PRECISION ASIL,ASILP,ATOT,BREF,CREF,CUSTOMGEOM,DEPSEL
      DOUBLE PRECISION DEPSUB,DEPTH,DSHD,EGGSHP,EMISAN,EMISSB,EMISSK,F12
      DOUBLE PRECISION F13,F14,F15,F16,F21,F23,F24,F25,F26,F31,F32,F41
      DOUBLE PRECISION F42,F51,F52,F61,FATOSB,FATOSK,FLSHCOND,FLUID,G
      DOUBLE PRECISION HRN,HSHSOI,HSOIL,MAXSHD,MSHSOI,MSOIL,NEWDEP,PHI
      DOUBLE PRECISION PHIMAX,PHIMIN,POND_DEPTH,PSHSOI,PSOIL,PTCOND
      DOUBLE PRECISION PTCOND_ORIG,QCOND,QCONV,QIRIN,QIROUT,QMETAB,QRESP
      DOUBLE PRECISION QSEVAP,QSOL,QSOLAR,QSOLR,REFSHD,RELHUM,RH,RHO1_3
      DOUBLE PRECISION RHREF,SHADE,SHP,SIDEX,SIG,SUBTK,TA,TALOC,TANNUL
      DOUBLE PRECISION TBASK,TC,TCORES,TDIGPR,TEMERGE,TIME,TMAXPR,TMINPR
      DOUBLE PRECISION TOBJ,TPREF,TQSOL,TRANS1,TREF,TSHSOI,TSKY,TSKYC
      DOUBLE PRECISION TSOIL,TSUB,TSUBST,TWATER,TWING,VEL,VLOC,VREF
      DOUBLE PRECISION WQSOL,Z,ZSOIL,EGGPTCOND,POT,TCOND,SHTCOND
      DOUBLE PRECISION EMISSB_REF,EMISSK_REF
      
      INTEGER AQUATIC,BURROWSHADE,FEEDING,GEOMETRY,IHOUR,INWATER,IYEAR
      INTEGER MICRO,MINNODE,NN,NODNUM,NON,NYEAR,SHDBURROW,WINGCALC
      INTEGER WINGMOD

      CHARACTER*1 BURROW,CKGRSHAD,CLIMB,CREPUS,DAYACT,NOCTURN

      DIMENSION ACTHR(25),CUSTOMGEOM(8),DEPSEL(25),HRN(25),HSHSOI(10)
      DIMENSION HSOIL(10),MSHSOI(10),MSOIL(10),PSHSOI(10),PSOIL(10)
      DIMENSION QSOL(25),RH(25),RHREF(25),SHP(3),TALOC(25),TCORES(25)
      DIMENSION TIME(25),TREF(25),TSHSOI(10),TSKYC(25),TSOIL(10)
      DIMENSION TSUB(25),VLOC(25),VREF(25),Z(25),ZSOIL(10),EGGSHP(3)
      DIMENSION TCOND(10),SHTCOND(10)

      COMMON/BEHAV1/DAYACT,BURROW,CLIMB,CKGRSHAD,CREPUS,NOCTURN
      COMMON/BEHAV2/GEOMETRY,NODNUM,CUSTOMGEOM,SHP,EGGSHP
      COMMON/BEHAV3/ACTHR
      COMMON/BUR/NON,MINNODE
      COMMON/BURROW/SHDBURROW,BURROWSHADE
      COMMON/DAYSTORUN/NN
      COMMON/DEPTHS/DEPSEL,TCORES
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL,VLOC
      COMMON/FUN1/QSOLAR,QIRIN,QMETAB,QRESP,QSEVAP,QIROUT,QCONV,QCOND
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG,
     & EGGPTCOND,POT
      COMMON/PONDDATA/INWATER,AQUATIC,TWATER,POND_DEPTH,FEEDING
      COMMON/REFSHADE/REFSHD
      COMMON/REPYEAR/IYEAR,NYEAR
      COMMON/SHADE/MAXSHD,DSHD
      COMMON/SOIL/TSOIL,TSHSOI,ZSOIL,MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,
     & HSHSOI,TCOND,SHTCOND
      COMMON/TPREFR/TMAXPR,TMINPR,TDIGPR,TPREF,TBASK,TEMERGE
      COMMON/TREG/TC
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,EMISSB_REF,EMISSK_REF,
     & FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52,F61,TQSOL,A1,A2,
     &A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26,WINGCALC,WINGMOD
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/WUNDRG/NEWDEP

      DEPTH=NEWDEP
      IF((BURROW.EQ.'Y').OR.(BURROW.EQ.'Y'))THEN
       IF(BURROWSHADE.EQ.1)THEN
        SHADE=MAXSHD
        CALL SELDEP(TSHSOI,HSHSOI,ZSOIL,RELHUM,PSHSOI,SHTCOND)
       ELSE
        SHADE=REFSHD
        CALL SELDEP(TSOIL,HSOIL,ZSOIL,RELHUM,PSOIL,TCOND)
       ENDIF
       DEPSEL(IHOUR)=NEWDEP*(-1.0)
C      TA DETERMINED IN SELDEP, NEW TCORE SUGGESTED IN UNDRGRD
C      RESET ENVIRONMENTAL CONDITIONS UNDERGROUND
       CALL BELOWGROUND
       CALL RADIN
      ENDIF

      RETURN
      END
