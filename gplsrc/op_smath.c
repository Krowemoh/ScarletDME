/* OP_SMATH.C
 * Arithmetic opcodes
 * Copyright (c) 2007 Ladybridge Systems, All Rights Reserved
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 * 
 * Ladybridge Systems can be contacted via the www.openqm.com web site.
 * 
 * ScarletDME Wiki: https://scarlet.deltasoft.com
 * 
 * START-HISTORY (ScarletDME):
 * 04 AUG 2023 nt  Began Development
 *
 * START-HISTORY (OpenQM):
 * END-HISTORY
 *
 * START-DESCRIPTION:
 *
 * op_sadd         SADD
 * op_ssub         SSUB
 * op_smul         SMUL
 * op_sdiv         SDIV
 *
 * END-DESCRIPTION
 *
 * START-CODE
 */

#include "qm.h"
#include "config.h"
#include "options.h"

#include <math.h>
#include <time.h>
#include <openssl/bn.h>
#include <openssl/crypto.h>
#include <stdint.h>

#define MAX_STRING_LEN 1024

/* ======================================================================
   op_sadd()  - BigInteger Addition                                       */

void op_saddC() {
    /* Stack:
       |=============================|=============================|
       |            BEFORE           |           AFTER             |
       |=============================|=============================|
   top |  Number 2                   |  Result string              |
       |-----------------------------|-----------------------------| 
       |  Number 1                   |                             |
       |=============================|=============================|
     */

    DESCRIPTOR* num1_descr;
    DESCRIPTOR* num2_descr;

    bool ok;

    char num1_string[MAX_STRING_LEN + 1];
    char num2_string[MAX_STRING_LEN + 1];

    BIGNUM *n1 = BN_new();
    BIGNUM *n2 = BN_new();
    BIGNUM *n3 = BN_new();

    num2_descr = e_stack - 1;
    ok = k_get_c_string(num2_descr, num2_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n2, num2_string);

    num1_descr = e_stack - 1;
    ok = k_get_c_string(num1_descr, num1_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n1, num1_string);

    BN_add(n3, n1, n2);

    char *r = BN_bn2dec(n3);

    process.status = 0;
    k_put_c_string(r, e_stack++);

    OPENSSL_free(r);

exit_op_sadd:
    BN_free(n1);
    BN_free(n2);
    BN_free(n3);

    return;

bad_string:
    process.status = 2;
    goto exit_op_sadd;
}

/* ======================================================================
   op_ssub()  - BigInteger Subtraction                                       */

void op_ssub() {
    /* Stack:
       |=============================|=============================|
       |            BEFORE           |           AFTER             |
       |=============================|=============================|
   top |  Number 2                   |  Result string              |
       |-----------------------------|-----------------------------| 
       |  Number 1                   |                             |
       |=============================|=============================|
     */

    DESCRIPTOR* num1_descr;
    DESCRIPTOR* num2_descr;

    bool ok;

    char num1_string[MAX_STRING_LEN + 1];
    char num2_string[MAX_STRING_LEN + 1];

    BIGNUM *n1 = BN_new();
    BIGNUM *n2 = BN_new();
    BIGNUM *n3 = BN_new();

    num2_descr = e_stack - 1;
    ok = k_get_c_string(num2_descr, num2_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n2, num2_string);

    num1_descr = e_stack - 1;
    ok = k_get_c_string(num1_descr, num1_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n1, num1_string);

    BN_sub(n3, n1, n2);

    char *r = BN_bn2dec(n3);

    process.status = 0;
    k_put_c_string(r, e_stack++);

    OPENSSL_free(r);

exit_op_ssub:
    BN_free(n1);
    BN_free(n2);
    BN_free(n3);

    return;

bad_string:
    process.status = 2;
    goto exit_op_ssub;
}

/* ======================================================================
   op_smul()  - BigInteger Multiplication                                       */

void op_smul() {
    /* Stack:
       |=============================|=============================|
       |            BEFORE           |           AFTER             |
       |=============================|=============================|
   top |  Number 2                   |  Result string              |
       |-----------------------------|-----------------------------| 
       |  Number 1                   |                             |
       |=============================|=============================|
     */

    DESCRIPTOR* num1_descr;
    DESCRIPTOR* num2_descr;

    bool ok;

    char num1_string[MAX_STRING_LEN + 1];
    char num2_string[MAX_STRING_LEN + 1];

    BIGNUM *n1 = BN_new();
    BIGNUM *n2 = BN_new();
    BIGNUM *n3 = BN_new();

    num2_descr = e_stack - 1;
    ok = k_get_c_string(num2_descr, num2_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n2, num2_string);

    num1_descr = e_stack - 1;
    ok = k_get_c_string(num1_descr, num1_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n1, num1_string);

    BN_CTX *ctx = BN_CTX_new();
    BN_mul(n3, n1, n2, ctx);
    BN_CTX_free(ctx);

    char *r = BN_bn2dec(n3);

    process.status = 0;
    k_put_c_string(r, e_stack++);

    OPENSSL_free(r);

exit_op_smul:
    BN_free(n1);
    BN_free(n2);
    BN_free(n3);

    return;

bad_string:
    process.status = 2;
    goto exit_op_smul;
}
/* ======================================================================
   op_sdiv()  - BigInteger Division                                       */

void op_sdiv() {
    /* Stack:
       |=============================|=============================|
       |            BEFORE           |           AFTER             |
       |=============================|=============================|
   top |  Number 2                   |  Result string              |
       |-----------------------------|-----------------------------| 
       |  Number 1                   |                             |
       |=============================|=============================|
     */

    DESCRIPTOR* num1_descr;
    DESCRIPTOR* num2_descr;

    bool ok;

    char num1_string[MAX_STRING_LEN + 1];
    char num2_string[MAX_STRING_LEN + 1];

    BIGNUM *n1 = BN_new();
    BIGNUM *n2 = BN_new();
    BIGNUM *n3 = BN_new();
    BIGNUM *rem = BN_new();

    num2_descr = e_stack - 1;
    ok = k_get_c_string(num2_descr, num2_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n2, num2_string);

    num1_descr = e_stack - 1;
    ok = k_get_c_string(num1_descr, num1_string, MAX_STRING_LEN) >= 0;
    k_dismiss();
    if (!ok) 
        goto bad_string;
    BN_dec2bn(&n1, num1_string);

    BN_CTX *ctx = BN_CTX_new();
    BN_div(n3, rem, n1, n2, ctx);
    BN_CTX_free(ctx);

    char *r = BN_bn2dec(n3);

    process.status = 0;
    k_put_c_string(r, e_stack++);

    OPENSSL_free(r);

exit_op_sdiv:
    BN_free(n1);
    BN_free(n2);
    BN_free(n3);
    BN_free(rem);

    return;

bad_string:
    process.status = 2;
    goto exit_op_sdiv;
}

/* END-CODE */
