/*
 * In writing this program, I've had to guess a few pices of information:
 *
 * 1. Which bits of the key are loaded into which bits of the shift register
 * 2. Which order the frame sequence number is shifted into the SR (MSB
 *    first or LSB first)
 * 3. The position of the feedback taps on R2 and R3 (R1 is known).
 * 4. The position of the clock control taps. These are on the `middle' one, 
 *    I've assumed to be 9 on R1, 11 on R2, 11 on R3.
 */

/*
 * Look at the `middle' stage of each of the 3 shift registers.
 * Either 0, 1, 2 or 3 of these 3 taps will be set high.
 * If 0 or 1 or one of them are high, return true. This will cause each of
 * the middle taps to be inverted before being used as a clock control. In
 * all cases either 2 or 3 of the clock enable lines will be active. Thus,
 * at least two shift registers change on every clock-tick and the system
 * never becomes stuck.
 */

#include<stdio.h>
#include<stdlib.h>

typedef struct {
    unsigned long r1, r2, r3;
} a5_ctx;

static int threshold(r1, r2, r3)
unsigned int r1;
unsigned int r2;
unsigned int r3;
{
int total;

  total = (((r1 >>  9) & 0x1) == 1) +
          (((r2 >> 11) & 0x1) == 1) +
          (((r3 >> 11) & 0x1) == 1);

	if (total > 1)
		return (0);
	else
		return (1);
}

unsigned long clock_r1(ctl, r1)
int ctl;
unsigned long r1;
{
unsigned long feedback;

 /*
  * Primitive polynomial x**19 + x**5 + x**2 + x + 1
  */

	ctl ^= ((r1 >> 9) & 0x1);
	if (ctl)
	{
		feedback = (r1 >> 18) ^ (r1 >> 17) ^ (r1 >> 16) ^ (r1 >> 13);
		r1 = (r1 << 1) & 0x7ffff;
	    if (feedback & 0x01)
			r1 ^= 0x01;
	}
	return (r1);
}

unsigned long clock_r2(ctl, r2)
int ctl;
unsigned long r2;
{
unsigned long feedback;

 /*
  * Primitive polynomial x**22 + x**9 + x**5 + x + 1
  */   

	ctl ^= ((r2 >> 11) & 0x1);
	if (ctl)
	{
	    feedback = (r2 >> 21) ^ (r2 >> 20) ^ (r2 >> 16) ^ (r2 >> 12);
		r2 = (r2 << 1) & 0x3fffff;
		if (feedback & 0x01)
			r2 ^= 0x01;
	}
	return (r2);
}

unsigned long clock_r3(ctl, r3)
int ctl;
unsigned long r3;
{
unsigned long feedback;

 /*
  * Primitive polynomial x**23 + x**5 + x**4 + x + 1
  */

	ctl ^= ((r3 >> 11) & 0x1);
	if (ctl)
	{
		feedback = (r3 >> 22) ^ (r3 >> 21) ^ (r3 >> 18) ^ (r3 >> 17);
		r3 = (r3 << 1) & 0x7fffff;
		if (feedback & 0x01)
			r3 ^= 0x01;
	}
	return (r3);
}



void a5_key(a5_ctx *c, char *k){
    c->r1 = k[0]<<11|k[1]<<3 | k[2]>>5;				/* 19 */
    c->r2 = k[2]<<17|k[3]<<9 | k[4]>>1 | k[5]>>7;	/* 22 */
    c->r3 = k[5]<<15|k[6]<<8 | k[7];				/* 23 */
}

/* Step one bit in A5, return 0 or 1 as output bit. */
int a5_step(a5_ctx *c){
    int control;
    control = threshold(c->r1, c->r2, c->r3);	
    c->r1=clock_r1(control, c->r1);				
    c->r2=clock_r2(control, c->r2);					
    c->r3=clock_r3(control, c->r3);
    return((c->r1^c->r2^c->r3)&1);
}

/* Encrypts a buffer of len bytes */
void a5_encrypt(a5_ctx *c, char *data, int len)          
{
	int i,j;
    char t;
    for(i=0; i<len; i++)
    {
        for(j=0; j<8; j++)
            t = t<<1 | a5_step(c);
        data[i]^=t;
    }
}

void a5_decrypt(a5_ctx *c, char *data, int len)
{
    a5_encrypt(c, data, len);
}

void main(void)
{

    a5_ctx c;
    char data [100];
    char key[] = {1,2,3,4,5,6,7,8};
    int i, flag;
    for(i=0; i<100; i++)
        data[i] = i;
        
    a5_key(&c, key);
    a5_encrypt(&c, data, 100);
    
    a5_key(&c, key);
    
    a5_decrypt(&c, data, 1);
    a5_decrypt(&c, data+1, 99);
    
    flag=0;
    for(i=0; i<100; i++)
    {
        if(data[i] != i)
            flag = 1;
    }
    if(flag)
        printf("Decrypt failed\n");
    else
        printf("Decrypt succeeded\n");
        
    system("pause");
}
