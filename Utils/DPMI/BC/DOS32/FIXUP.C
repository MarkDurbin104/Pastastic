
//----------------------------------------------------------------------//
// Program to extract stub32.exe and to fix 32rtm.exe							//
//----------------------------------------------------------------------//

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <string.h>
			  

// function prototypes
int createstub32(void);
int patch32rtm(void);

//----------------------------------------------------------------------//
// Function:		void main(void)													//
//	Description:	entry point to program											//
// Parameters:		.																		//
// Returns:			.																		//
//----------------------------------------------------------------------//
void main(void)
{
	if (createstub32())
		exit(1);

	exit(patch32rtm());

}

//----------------------------------------------------------------------//
// Function:		void createstub32(void)											//
//	Description:	creates file stub32.exe from tlib.exe						//
// Parameters:		.																		//
// Returns:			error number														//
//----------------------------------------------------------------------//
int createstub32(void)
{

	FILE *infile;
	FILE *outfile;
	int  error;
	char *tbuff;

	tbuff = (char *)malloc(2048);
	if (tbuff == NULL)
		{
		printf("Couldn't allocate 2048 bytes?\n");
		return(1);
		}

	infile = fopen("tlib.exe", "rb");
	if (infile == NULL)
		{
		printf("Can't find tlib.exe\n");
		return(2);
		}

	error = fread(tbuff, 1, 2048, infile);
	fclose(infile);
	if (error != 2048)
		{
		printf("Couldn't read from file tlib.exe\n");
		free(tbuff);
		return(3);
		}

	if (strncmp(&tbuff[0x200], "32STUB", 6))
		{
		printf("Doesn't seem to be right file.\n");
		free(tbuff);
		return(5);
		}

	outfile = fopen("stub32.exe", "w+b");
	error = fwrite(tbuff, 1, 2048, outfile);
	fclose(outfile);

	free(tbuff);
	if (error != 2048)
		{
		printf("Couldn't write to file stub32.exe\n");
		return(4);
		}

	return(0);

}


//----------------------------------------------------------------------//
// Function:		void patch32rtm(void)											//
//	Description:	patch the 32rtm.exe file										//
// Parameters:		.																		//
// Returns:			error number														//
//----------------------------------------------------------------------//
int patch32rtm(void)
{


	FILE *infile;
	unsigned short chkword;
	int error;

	infile = fopen("32rtm.exe", "r+b");
	if (infile == NULL)
		{
		printf("Couldn't open file 32rtm.exe\n");
		return(1);
		}

	fseek(infile, 43590L, SEEK_SET);
	error = fread(&chkword, 1, 2, infile);
	if (error != 2)
		{
		printf("unable to read from 32rtm.exe\n");
		fclose(infile);
		return(2);
		}

	if (chkword == 0xc031)		// reversed bytes
		{
		printf("File 32rtm.exe is already patched\n");
		fclose(infile);
		return(3);
		}

	if (chkword != 0xc23b)		// reversed bytes
		{
		printf("32rtm.exe doesn't seem to be the right file.\n");
		fclose(infile);
		return(4);
		}

	chkword = 0xc031;

	fseek(infile, 43590L, SEEK_SET);
	error = fwrite(&chkword, 1, 2, infile);
	fclose(infile);
	if (error != 2)
		{
		printf("unable to write to 32rtm.exe\n");
		return(2);
		}

	return(0);

}
