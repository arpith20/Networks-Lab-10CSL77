#include<iostream>
#include<stdio.h>
#include<string.h>

using namespace std;

// mode=1 is for calculating CRC of original message and create final message to be transmitted at sender's end
// mode=0 is for calculating CRC of recieved message at reciever's end
int crc(char *input,char *output,const char *gp,int mode)
{
	int j,k;
	strcpy(output,input);	// copy original message to output
	if(mode)
	{
		for(j=1; j<strlen(gp); j++) 
			strcat(output,"0");	// append as many zeroes as the width(position of the highest 1 bit) of generator polynomial.
	}
	for(j=0; j<strlen(input); j++) // calculate final message to be transmitted and store it in output - loop simulates CRC division and finding of remainder
		if(*(output+j) == '1')
			for(k=0; k<strlen(gp); k++)
			{
				if (((*(output+j+k) =='0') && (gp[k] == '0') ||	(*(output+j+k) == '1') && (gp[k] == '1'))) // equivalent to performing XOR operation
					*(output+j+k)='0';
				else
					*(output+j+k)='1';
			}
	for(j=0; j<strlen(output); j++)
		if(output[j] == '1') // if any of the bits is 1, then output is not 0, hence there is error
			return 1;
	return 0; // error free
}

int main()
{
	char input[50],output[50],recv[50];
	const char gp[18]="10001000000100001"; // 16-bit CRC-CCITT specification G(x): x^16+x^12+x^5+1
	
	cout<<"\nEnter the input message in binary\n";
	cin>>input;
	crc(input,output,gp,1);
	cout<<"\nThe transmitted message is: "<<input<<output+strlen(input)<<"\n";
	cout<<"\n\nEnter the recevied message in binary \n";
	cin>>recv;
		
	if(!crc(recv,output,gp,0))
		cout<<"\nNo error in data\n";
	else
		cout<<"\nError in data transmission has occurred\n";
	
	return 0;
}
