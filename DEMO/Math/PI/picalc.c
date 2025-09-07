/*
 * PICALC1 V1.0 09/08/2007
 *
 * F.G.Kaal
 * De Dadelboom 81
 * 1911 KK Uitgeest
 *
 * Adapted from the Extended basic program
 * PiCalc by Walid Maalouli
 *
 * Remarks:
 * 1)Number of decimals that fit in a 32bit number is
 *   INT( LOG(SQR(2^31)) / LOG(10)) = 4
 *
 * 2)TI/EX Basic INT() function:
 *   INT(3.2)=3, INT(-3.2)=-4, INT(-0.2)=-1
 *
 * 3) Some magic numbers explained
 *    Number of decimals per long value is 4
 *    Therefore max number of decimals is 4*arraysize-2*4
 *    =4*652-8=2600
 *    PI=16*ATAN(1/5) - 4*ATAN(1/239)
 *    1/5 = 0.2000, the number 2000 is exactly that in 4 decimals
 *    25=5^2 and 57121=239^2
 *
 */
#include ".\..\TILIB\CGLOB_H"
#include ".\..\TILIB\MISC_H"
#include ".\..\TILIB\CONV_H"
#include ".\..\TILIB\CTYPE_H"
#include ".\..\TILIB\LONG_H"
#include ".\..\TILIB\SPRINTF_H"
#include "PICALC_H"

extern getyxts(),getkey(),waitkey(),clearw();

entry SUM,SUM1,TERM,TEMP;

#define SIGNED 1 /* SIGNED OR UNSIGNED MPY AND DIV */

#ifdef SIGNED
#define LMPY lsmpyl
#define LDIV lsdivl
#endif

#ifdef UNSIGNED
#define LMPY lmpyl
#define LDIV ldivl
#endif

#define LONGSIZE 4
#define ARRSIZE  652

char inpline[40];
int N,I,D,S,ITR,DENOM1,TBASE,MULT,FLAG;
int CPYBYTES;

/* long variables */
int L10000[2]  = {0x0000, 0x2710};
int L0[2]      = {0x0000, 0x0000};

int SUM[ARRSIZE][2],SUM1[ARRSIZE][2];
int TERM[ARRSIZE][2],TEMP[ARRSIZE][2];

int lval[2];
int DIVIDEND[2], REMAINDER[2], LDENOM[2];
int QUOTIENT[2];
char *lp1,*lp2;

main()
{
    locate(1,8); puts("Pi Calculator");
    locate(3,8); puts("By Walid Maalouli");
    locate(5,8); puts("August 2007");
    locate(7,8); puts("Converted to C99");
    locate(9,8); puts("By Fred G. Kaal");

    memset(SUM ,0,ARRSIZE*LONGSIZE);
    memset(SUM1,0,ARRSIZE*LONGSIZE);
    memset(TERM,0,ARRSIZE*LONGSIZE);
    memset(TEMP,0,ARRSIZE*LONGSIZE);
    do
    {
        locate(12,2);  puts("# of decimals (mult. of 4)");
        locate(13,2);  puts("(Maximum of 2600 decimals)");
        getyxts(14,12,CT_DIGIT,4,inpline);
        D=atoi(inpline);
    }
    while ((D<=0) || (D>2600) || (D%4!=0));

/*160 ITR=INT(D/1.4) :: D=D/5+2 */
    ITR=(D*10)/14+1; D=D/4+2;

/*170 SUM(1)=3 :: SUM(2)=20000 :: TERM(1)=0 :: TERM(2)=20000
  :: S=0 :: DENOM1=3 :: TBASE=25 :: MULT=16*/

    lcpys(&SUM[1][0],3);  lcpys(&SUM[2][0],2000);
    lcpys(&TERM[1][0],0); lcpys(&TERM[2][0],2000);

    CPYBYTES=D*LONGSIZE+LONGSIZE; /* Array size in bytes */

    CalcPi();
    OutScreen();

    exit(0);
}

CalcPi()
{
/*170*/ DENOM1=3; TBASE=25; MULT=16; FLAG=0;
/*180*/ Iterate();

/*460 IF FLAG=1 THEN 620*/
/*470*/ DENOM1=3; TBASE=57121; MULT=4;

/*480 FOR I=1 TO D*/
/*490 SUM1(I)=SUM(I)*/
/*500 SUM(I)=0 :: TERM(I)=0*/
/*510 NEXT I*/
    memcpy(SUM1,SUM,CPYBYTES);
    memset(SUM,  0, CPYBYTES);
    memset(TERM, 0, CPYBYTES);

/*520 TERM(1)=4*/
    lcpys(&TERM[1][0],4);

/*530 DENOM=239 :: REMAINDER=0*/
/*540 GOSUB 1050*/
    SubDivide(239);

/*550 FOR I=1 TO D*/
/*560 SUM(I)=TERM(I) :: TERM(I)=0*/
/*570 NEXT I*/
    memcpy(SUM,TERM,CPYBYTES);
    memset(TERM, 0, CPYBYTES);

/*580 DENOM=239 :: TERM(1)=1 :: REMAINDER=0*/
/*590 GOSUB 1050*/
    lcpys(&TERM[1][0],1);
    SubDivide(239);

/*600 FLAG=1 :: S=0*/
/*610 GOTO 180*/
    Iterate();

/*620 PRINT :: PRINT "Finalizing calculations..." :: PRINT*/
    puts("\nFinalizing calculations...\n\n");

/*630 FOR I=1 TO D*/
    lp1=&SUM[1][0]; lp2=&SUM1[1][0];
    for (I=1; I<=D; ++I)
    {
/*640 SUM1(I)=SUM1(I)-SUM(I) :: SUM(I)=SUM1(I)*/
        lsubl(lp2,lp1); lcpyl(lp1,lp2);
        lp1=lp1+LONGSIZE; lp2=lp2+LONGSIZE;
/*650 NEXT I*/
    }

/*660 FLAG=2*/
/*670 GOTO 330*/
    DoCarry();
/*680 ready!*/
}

Iterate()
{
    FLAG=FLAG+1; S=0;

/*180 FOR N=1 TO ITR+1*/
    for (N=1; N<=ITR; ++N)
    {
/*190 IF FLAG=0 THEN PRINT "Term 1 iteration #";N ELSE PRINT "Term 2 iteration #
";N*/
        printf("Term %u iteration #%u\n", FLAG, N);

/*200 IF N=1 THEN 220*/
/*210 FOR I=1 TO D :: TERM(I)=TEMP(I) :: NEXT I*/
        if (N!=1) memcpy(TERM, TEMP, CPYBYTES);

/*220 DENOM=TBASE :: REMAINDER=0*/
/*230 GOSUB 1050*/
        SubDivide(TBASE);

/*240 FOR I=1 TO D :: TEMP(I)=TERM(I) :: NEXT I*/
        memcpy(TEMP, TERM, CPYBYTES);

/*250 DENOM=DENOM1 :: REMAINDER=0*/
/*260 GOSUB 1050*/
        SubDivide(DENOM1);

/*270 FOR I=1 TO D*/
        lp1=&SUM[1][0]; lp2=&TERM[1][0];
        for (I=1; I<=D; ++I)
        {
/*280 IF S=0 THEN 300*/
            lcpys(lval,MULT);
            LMPY(lval,lp2);
            if (S!=0)
            {
/*290 SUM(I)=SUM(I)+MULT*TERM(I) :: GOTO 310*/
                laddl(lp1,lval);
            }
            else
            {
/*300 SUM(I)=SUM(I)-MULT*TERM(I)*/
                lsubl(lp1,lval);
            }
            lp1=lp1+LONGSIZE; lp2=lp2+LONGSIZE;
/*310 NEXT I*/
        }

/*320 IF S=0 THEN S=1 ELSE S=0*/
        S = (S==0) ? 1 : 0;
/*330*/
        DoCarry();

/*440 DENOM1=DENOM1+2*/
        DENOM1=DENOM1+2;
/*450 NEXT N*/
/*Out();*/
    }
}

/* Check values of SUM[] */

DoCarry()
{
/*330 FOR I=D TO 2 STEP-1*/
    lp1=&SUM[D][0]; lp2=&SUM[D-1][0];
    for(I=D; I>=2; --I)
    {
/*340 IF SUM(I)==0 420*/
        if (ltst(lp1)!=0)
        {
/*350 QUOTIENT=INT(SUM(I)/100000)*/
            lcpyl(QUOTIENT,lp1);
            LDIV(QUOTIENT,L10000);
            lgsmod(REMAINDER);
            if (REMAINDER[0]<0) ldec(QUOTIENT);

/*370 SUM(I-1)=SUM(I-1)+QUOTIENT*/
            laddl(lp2,QUOTIENT);

/*360 SUM(I)=SUM(I)-QUOTIENT*100000*/
            LMPY(QUOTIENT,L10000);
            lsubl(lp1,QUOTIENT);
/*380 GOTO 420*/
        }
        lp1=lp1-LONGSIZE; lp2=lp2-LONGSIZE;
/*420 NEXT I*/
    }
/*430 IF FLAG=2 THEN 680*/
}

/* DIVIDE SUBROUTINE */

SubDivide(DENOM) int DENOM;
{
int I;

    lclr(REMAINDER);
    lcpys(LDENOM,DENOM);

    lp1 = &TERM[1][0];
    for (I=1; I<=D; ++I)
    {
/*      DIVIDEND=REMAINDER*100000+TERM[I];*/
        lcpyl(DIVIDEND,REMAINDER);
        LMPY(DIVIDEND,L10000);
        laddl(DIVIDEND,lp1);

/*      TERM[I]=INT(DIVIDEND/DENOM);*/
        lcpyl(lp1,DIVIDEND);
        LDIV(lp1,LDENOM);
lgsmod(REMAINDER);
if (REMAINDER[0]<0) ldec(lp1);

/*      REMAINDER=DIVIDEND-TERM[I]*DENOM;*/
        lcpyl(REMAINDER,DIVIDEND);
/*printf("1 L=%08lX D=%08lX R=%08lX\n",LVAL,DIVIDEND,REMAINDER);*/
        lcpyl(lval,lp1);
/*printf("2 L=%08lX D=%08lX R=%08lX\n",LVAL,DIVIDEND,REMAINDER);*/
        LMPY(lval,LDENOM);
/*printf("3 L=%08lX D=%08lX R=%08lX\n",LVAL,DIVIDEND,REMAINDER);*/
        lsubl(REMAINDER,lval);
/*printf("4 L=%08lX D=%08lX R=%08lX\n",LVAL,DIVIDEND,REMAINDER);*/

/*printf("%d T=%08lX D=%08lX R=%08lX\n",DENOM, lp1,DIVIDEND,REMAINDER);
waitkey();*/

        lp1=lp1+LONGSIZE;
    }
}


/* Output to screen */
OutScreen()
{
int ix,jx,kx;

    putchar('\f');
    locate(1,1); puts("Calculations complete!");

    locate(3,1); printf("Pi=3.");
    locate(4,1);
    for(ix=2, jx=0, kx=4; ix<D; ++ix)
    {
        printf(" %04lu", &SUM[ix][0]);
        if (++jx>4)
        {
            putchar('\n');
            jx = 0;
            if (++kx >= 22)
            {
                locate(24,1); puts("Press any key to continue");
                waitkey();
                kx=4;
                clearw(kx,20);
            }
        }
    }
    locate(24,1); puts("End. Press any key to exit");
    waitkey();
}

/* test output */
Out()
{
    Out1("SUM  ", SUM);
    Out1("SUM1 ", SUM1);
    Out1("TERM ", TERM);
    Out1("TEMP ", TEMP);
    waitkey();
}

Out1(n, lp) char *n, *lp;
{
int ix;

    puts(n);
    for(ix=1; ix<=D; ++ix)
    {
         lp=lp+LONGSIZE; printf(" %5ld", lp);
    }
    putchar('\n');
}
#ifdef SIGNED
#asm
*lsmpyl(long1, long2) int *long1, *long2;
*
* unsigned multiply
*
* long1 *= long2 = (LOW(long2) * LOW(long1))            overflow if:
*                + (HOW(long2) * LOW(long1)) 0000       HOW(result)!=0
*                + (LOW(long2) * HOW(long1)) 0000       HOW(result)!=0
*                + (HOW(long2) * HOW(long1)) 0000 0000      result !=0
*
* returns &long1, if overflow occured long1=0xFFFFFFFF
*
       REF LMPY#S

LSMPYL CLR  0           Sign of the result
       STWP 1
       AI   1,2*6 R1=&R6
       MOV  @2(8),@2(1) R7=LOW(long2)
       MOV  *8,*1       R6=HOW(long2)
       BL   @LABS$1
       INC  R0          Set sign flag, <>0 means negative

       MOV  @4(14),8    R8=&long1
       MOV  8,1
       MOV  *1,3
       BL   @LABS$1
       DEC  0           Set sign flag, <>0 means negative

       BL   @LMPY#S     Signed multiply

       JMP  LDIV#Q
#endasm

#asm
* lsdivl(long1, long2) int *long1,*long2;
*
* signed divide
*
* long1 = long1 / long2
* returns &long1
*
* R0   = sign of the result
* R4,5 = long1 / long2
* R2,3 = long1 % long2
*
       REF  LDIV#S

LSDIVL CLR  R0          Sign of the result
       MOV  @2(14),2    R2=&long2
       STWP R1
       AI   1,2*6       R1=&R6
       BL   @LABS$2
       INC  0

LDIV#A MOV  @4(14),2    R2=&long1
       STWP R1
       AI   1,2*8       R1=&R8
       BL   @LABS$2
       DEC  0

       BL   @LDIV#S     Signed divide

LDIV#B MOV  4,*8        R8=&long1
       MOV  5,@2(8)

LDIV#Q MOV  0,1         Must result be negative?
       JEQ  LDIV#C      No!
       MOV  8,1
       BL   @LNEG$
LDIV#C B    *13
#endasm

#asm
* lgumod(long) int *long;
* lgsmod(long) int *long;
*
* get unsigned or signed modulo, returns &long;
*
* call the apropriate function directly after
* ldivl() or lsdivl() to retrieve the modulo
* (remainder) of the division.
*
* R1  = sign of the result
* R2,3 = long1 % long2
*
LGUMOD CLR  1        Clear sign flag
LGSMOD MOV  2,*8     R8=&long1
       MOV  3,@2(8)
       MOV  1,1      Must result be negative?
       JEQ  LGSMD#   No!
       MOV  8,1
       BL   @LNEG$
LGSMD# B    *13
#endasm

#asm
* LABS$2 R1=&long dest, R2=&long src
* LABS$1 R1=&long dest, ST according to HOW(long)
*
* LABS$: if (long<0) abs(long) returns to *R11
*        if (long>=0) returns to R11+2
*
* LNEG$: long = -long returns to *R11
*
LABS$2 MOV  @2(2),@2(1) LOW
       MOV  *2,*1       HOW
LABS$1 JGT  LABS$#      Long>=0
       JEQ  LABS$#
LNEG$  INV *1           /HOW->HOW
       NEG @2(1)        -LOW->LOW
       JNC LNEG$#
       INC *1           HOW+C
LNEG$# B   *11

LABS$# INCT 11
       B   *11
#endasm
#endif
