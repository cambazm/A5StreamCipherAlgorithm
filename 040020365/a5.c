/*************************************
 * SYSTEMS PROGRAMMING ASSIGNMENT 1  *
 * Ogrenci : MEHMET CAMBAZ           *
 * No      : 040020365               *
 *************************************/

#include<stdio.h>

typedef struct {
    unsigned long r1, r2, r3;
} a5_ctx;


void a5_key(a5_ctx *, char *);
void a5_encrypt(a5_ctx *, char *, int);
void a5_decrypt(a5_ctx *, char *, int);

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
}
