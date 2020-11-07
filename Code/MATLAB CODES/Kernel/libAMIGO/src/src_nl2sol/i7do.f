      SUBROUTINE I7DO(M,N,INDROW,JPNTR,INDCOL,IPNTR,NDEG,LIST,
     *               MAXCLQ,IWA1,IWA2,IWA3,IWA4,BWA)
      INTEGER M,N,MAXCLQ
      INTEGER INDROW(1),JPNTR(1),INDCOL(1),IPNTR(1),NDEG(N),LIST(N),
     *        IWA1(N),IWA2(N),IWA3(N),IWA4(N)
      LOGICAL BWA(N)
C     **********
C
C     SUBROUTINE I7DO
C
C     GIVEN THE SPARSITY PATTERN OF AN M BY N MATRIX A, THIS
C     SUBROUTINE DETERMINES AN INCIDENCE-DEGREE ORDERING OF THE
C     COLUMNS OF A.
C
C     THE INCIDENCE-DEGREE ORDERING IS DEFINED FOR THE LOOPLESS
C     GRAPH G WITH VERTICES A(J), J = 1,2,...,N WHERE A(J) IS THE
C     J-TH COLUMN OF A AND WITH EDGE (A(I),A(J)) IF AND ONLY IF
C     COLUMNS I AND J HAVE A NON-ZERO IN THE SAME ROW POSITION.
C
C     AT EACH STAGE OF I7DO, A COLUMN OF MAXIMAL INCIDENCE IS
C     CHOSEN AND ORDERED. IF JCOL IS AN UN-ORDERED COLUMN, THEN
C     THE INCIDENCE OF JCOL IS THE NUMBER OF ORDERED COLUMNS
C     ADJACENT TO JCOL IN THE GRAPH G. AMONG ALL THE COLUMNS OF
C     MAXIMAL INCIDENCE,I7DO CHOOSES A COLUMN OF MAXIMAL DEGREE.
C
C     THE SUBROUTINE STATEMENT IS
C
C       SUBROUTINE I7DO(M,N,INDROW,JPNTR,INDCOL,IPNTR,NDEG,LIST,
C                      MAXCLQ,IWA1,IWA2,IWA3,IWA4,BWA)
C
C     WHERE
C
C       M IS A POSITIVE INTEGER INPUT VARIABLE SET TO THE NUMBER
C         OF ROWS OF A.
C
C       N IS A POSITIVE INTEGER INPUT VARIABLE SET TO THE NUMBER
C         OF COLUMNS OF A.
C
C       INDROW IS AN INTEGER INPUT ARRAY WHICH CONTAINS THE ROW
C         INDICES FOR THE NON-ZEROES IN THE MATRIX A.
C
C       JPNTR IS AN INTEGER INPUT ARRAY OF LENGTH N + 1 WHICH
C         SPECIFIES THE LOCATIONS OF THE ROW INDICES IN INDROW.
C         THE ROW INDICES FOR COLUMN J ARE
C
C               INDROW(K), K = JPNTR(J),...,JPNTR(J+1)-1.
C
C         NOTE THAT JPNTR(N+1)-1 IS THEN THE NUMBER OF NON-ZERO
C         ELEMENTS OF THE MATRIX A.
C
C       INDCOL IS AN INTEGER INPUT ARRAY WHICH CONTAINS THE
C         COLUMN INDICES FOR THE NON-ZEROES IN THE MATRIX A.
C
C       IPNTR IS AN INTEGER INPUT ARRAY OF LENGTH M + 1 WHICH
C         SPECIFIES THE LOCATIONS OF THE COLUMN INDICES IN INDCOL.
C         THE COLUMN INDICES FOR ROW I ARE
C
C               INDCOL(K), K = IPNTR(I),...,IPNTR(I+1)-1.
C
C         NOTE THAT IPNTR(M+1)-1 IS THEN THE NUMBER OF NON-ZERO
C         ELEMENTS OF THE MATRIX A.
C
C       NDEG IS AN INTEGER INPUT ARRAY OF LENGTH N WHICH SPECIFIES
C         THE DEGREE SEQUENCE. THE DEGREE OF THE J-TH COLUMN
C         OF A IS NDEG(J).
C
C       LIST IS AN INTEGER OUTPUT ARRAY OF LENGTH N WHICH SPECIFIES
C         THE INCIDENCE-DEGREE ORDERING OF THE COLUMNS OF A. THE J-TH
C         COLUMN IN THIS ORDER IS LIST(J).
C
C       MAXCLQ IS AN INTEGER OUTPUT VARIABLE SET TO THE SIZE
C         OF THE LARGEST CLIQUE FOUND DURING THE ORDERING.
C
C       IWA1,IWA2,IWA3, AND IWA4 ARE INTEGER WORK ARRAYS OF LENGTH N.
C
C       BWA IS A LOGICAL WORK ARRAY OF LENGTH N.
C
C     SUBPROGRAMS CALLED
C
C       MINPACK-SUPPLIED ... N7MSRT
C
C       FORTRAN-SUPPLIED ... MAX0
C
C     ARGONNE NATIONAL LABORATORY. MINPACK PROJECT. JUNE 1982.
C     THOMAS F. COLEMAN, BURTON S. GARBOW, JORGE J. MORE
C
C     **********
      INTEGER DEG,HEAD,IC,IP,IPL,IPU,IR,JCOL,JP,JPL,JPU,L,MAXINC,
     *        MAXLST,NCOMP,NUMINC,NUMLST,NUMORD,NUMWGT
C
C     SORT THE DEGREE SEQUENCE.
C
      CALL N7MSRT(N,N-1,NDEG,-1,IWA4,IWA1,IWA3)
C
C     INITIALIZATION BLOCK.
C
C     CREATE A DOUBLY-LINKED LIST TO ACCESS THE INCIDENCES OF THE
C     COLUMNS. THE POINTERS FOR THE LINKED LIST ARE AS FOLLOWS.
C
C     EACH UN-ORDERED COLUMN JCOL IS IN A LIST (THE INCIDENCE LIST)
C     OF COLUMNS WITH THE SAME INCIDENCE.
C
C     IWA1(NUMINC+1) IS THE FIRST COLUMN IN THE NUMINC LIST
C     UNLESS IWA1(NUMINC+1) = 0. IN THIS CASE THERE ARE
C     NO COLUMNS IN THE NUMINC LIST.
C
C     IWA2(JCOL) IS THE COLUMN BEFORE JCOL IN THE INCIDENCE LIST
C     UNLESS IWA2(JCOL) = 0. IN THIS CASE JCOL IS THE FIRST
C     COLUMN IN THIS INCIDENCE LIST.
C
C     IWA3(JCOL) IS THE COLUMN AFTER JCOL IN THE INCIDENCE LIST
C     UNLESS IWA3(JCOL) = 0. IN THIS CASE JCOL IS THE LAST
C     COLUMN IN THIS INCIDENCE LIST.
C
C     IF JCOL IS AN UN-ORDERED COLUMN, THEN LIST(JCOL) IS THE
C     INCIDENCE OF JCOL IN THE GRAPH. IF JCOL IS AN ORDERED COLUMN,
C     THEN LIST(JCOL) IS THE INCIDENCE-DEGREE ORDER OF COLUMN JCOL.
C
      MAXINC = 0
      DO 10 JP = 1, N
         LIST(JP) = 0
         BWA(JP) = .FALSE.
         IWA1(JP) = 0
         L = IWA4(JP)
         IF (JP .NE. 1) IWA2(L) = IWA4(JP-1)
         IF (JP .NE. N) IWA3(L) = IWA4(JP+1)
   10    CONTINUE
      IWA1(1) = IWA4(1)
      L = IWA4(1)
      IWA2(L) = 0
      L = IWA4(N)
      IWA3(L) = 0
C
C     DETERMINE THE MAXIMAL SEARCH LENGTH FOR THE LIST
C     OF COLUMNS OF MAXIMAL INCIDENCE.
C
      MAXLST = 0
      DO 20 IR = 1, M
         MAXLST = MAXLST + (IPNTR(IR+1) - IPNTR(IR))**2
   20    CONTINUE
      MAXLST = MAXLST/N
      MAXCLQ = 1
C
C     BEGINNING OF ITERATION LOOP.
C
      DO 140 NUMORD = 1, N
C
C        CHOOSE A COLUMN JCOL OF MAXIMAL DEGREE AMONG THE
C        COLUMNS OF MAXIMAL INCIDENCE.
C
         JP = IWA1(MAXINC+1)
         NUMLST = 1
         NUMWGT = -1
   30    CONTINUE
            IF (NDEG(JP) .LE. NUMWGT) GO TO 40
            NUMWGT = NDEG(JP)
            JCOL = JP
   40       CONTINUE
            JP = IWA3(JP)
            NUMLST = NUMLST + 1
            IF (JP .GT. 0 .AND. NUMLST .LE. MAXLST) GO TO 30
         LIST(JCOL) = NUMORD
C
C        DELETE COLUMN JCOL FROM THE LIST OF COLUMNS OF
C        MAXIMAL INCIDENCE.
C
         L = IWA2(JCOL)
         IF (L .EQ. 0) IWA1(MAXINC+1) = IWA3(JCOL)
         IF (L .GT. 0) IWA3(L) = IWA3(JCOL)
         L = IWA3(JCOL)
         IF (L .GT. 0) IWA2(L) = IWA2(JCOL)
C
C        UPDATE THE SIZE OF THE LARGEST CLIQUE
C        FOUND DURING THE ORDERING.
C
         IF (MAXINC .EQ. 0) NCOMP = 0
         NCOMP = NCOMP + 1
         IF (MAXINC + 1 .EQ. NCOMP) MAXCLQ = MAX0(MAXCLQ,NCOMP)
C
C        UPDATE THE MAXIMAL INCIDENCE COUNT.
C
   50    CONTINUE
            IF (IWA1(MAXINC+1) .GT. 0) GO TO 60
            MAXINC = MAXINC - 1
            IF (MAXINC .GE. 0) GO TO 50
   60    CONTINUE
C
C        FIND ALL COLUMNS ADJACENT TO COLUMN JCOL.
C
         BWA(JCOL) = .TRUE.
         DEG = 0
C
C        DETERMINE ALL POSITIONS (IR,JCOL) WHICH CORRESPOND
C        TO NON-ZEROES IN THE MATRIX.
C
         JPL = JPNTR(JCOL)
         JPU = JPNTR(JCOL+1) - 1
         IF (JPU .LT. JPL) GO TO 100
         DO 90 JP = JPL, JPU
            IR = INDROW(JP)
C
C           FOR EACH ROW IR, DETERMINE ALL POSITIONS (IR,IC)
C           WHICH CORRESPOND TO NON-ZEROES IN THE MATRIX.
C
            IPL = IPNTR(IR)
            IPU = IPNTR(IR+1) - 1
            DO 80 IP = IPL, IPU
               IC = INDCOL(IP)
C
C              ARRAY BWA MARKS COLUMNS WHICH ARE ADJACENT TO
C              COLUMN JCOL. ARRAY IWA4 RECORDS THE MARKED COLUMNS.
C
               IF (BWA(IC)) GO TO 70
               BWA(IC) = .TRUE.
               DEG = DEG + 1
               IWA4(DEG) = IC
   70          CONTINUE
   80          CONTINUE
   90       CONTINUE
  100    CONTINUE
C
C        UPDATE THE POINTERS TO THE INCIDENCE LISTS.
C
         IF (DEG .LT. 1) GO TO 130
         DO 120 JP = 1, DEG
            IC = IWA4(JP)
            IF (LIST(IC) .GT. 0) GO TO 110
            NUMINC = -LIST(IC) + 1
            LIST(IC) = -NUMINC
            MAXINC = MAX0(MAXINC,NUMINC)
C
C           DELETE COLUMN IC FROM THE NUMINC-1 LIST.
C
            L = IWA2(IC)
            IF (L .EQ. 0) IWA1(NUMINC) = IWA3(IC)
            IF (L .GT. 0) IWA3(L) = IWA3(IC)
            L = IWA3(IC)
            IF (L .GT. 0) IWA2(L) = IWA2(IC)
C
C           ADD COLUMN IC TO THE NUMINC LIST.
C
            HEAD = IWA1(NUMINC+1)
            IWA1(NUMINC+1) = IC
            IWA2(IC) = 0
            IWA3(IC) = HEAD
            IF (HEAD .GT. 0) IWA2(HEAD) = IC
  110       CONTINUE
C
C           UN-MARK COLUMN IC IN THE ARRAY BWA.
C
            BWA(IC) = .FALSE.
  120       CONTINUE
  130    CONTINUE
         BWA(JCOL) = .FALSE.
C
C        END OF ITERATION LOOP.
C
  140    CONTINUE
C
C     INVERT THE ARRAY LIST.
C
      DO 150 JCOL = 1, N
         NUMORD = LIST(JCOL)
         IWA1(NUMORD) = JCOL
  150    CONTINUE
      DO 160 JP = 1, N
         LIST(JP) = IWA1(JP)
  160    CONTINUE
      RETURN
C
C     LAST CARD OF SUBROUTINE I7DO.
C
      END