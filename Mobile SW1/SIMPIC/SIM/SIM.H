/* 
** (C) Copyright on the following code is reserved by 
**     Michael J. McCormack 1998
** Postal address:    PO BOX 1542
**                    Lane Cove 2066
**                    Australia
** email address:     McCormack@ozemail.com.au
** You may use, modify and distribute it freely for non commercial 
** purposes only, provided this header is left intact.
**
** Filename: sim.h
** Description: 
**  functions that can be performed on a GSM SIM card as defined by GSM 11.11
*/

#ifndef __INC_SIM__
#define __INC_SIM__

int sim_status(int sp,uchar *,int);
int sim_select(int sp,int fileid,uchar*buf,int bufsize);
int sim_read_binary(int sp, uchar *x, int offset, int len);
int sim_run_algorithm(int sp, uchar *rand, uchar *resp);
int sim_verify_chv(int sp, uchar *result, int reslen, int chv_no, uchar *chv);

/* SIM file structure */
#define MAINFILE               (0x3f00)

  /* files in MAINFILE */
  #define DF_GSM               (0x7f20)
  #define DF_TELECOM           (0x7f10)
  #define EF_ICCID             (0x2fe2)

    /* files in DF_TELECOM */
    #define EF_ADN             (0x6f3a)
    #define EF_FDN             (0x6f3b)
    #define EF_SMS             (0x6f3c)
    #define EF_CCP             (0x6f3d)
    #define EF_MSISDN          (0x6f40)
    #define EF_SMSP            (0x6f42)

    /* files in DF_GSM */
    #define EF_LP              (0x6f05)
    #define EF_IMSI            (0x6f07)
    #define EF_KC              (0x6f20)
    #define EF_PLMNSEL         (0x6f30)
    #define EF_HPLMN           (0x6f31)
    #define EF_ACMMAX          (0x6f37)

#endif /* __INC_SIM__ */

