#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define SIZE 32
#define OPSIZE 16
#define NOPS 512

char rd1[OPSIZE], rn1[OPSIZE], src1[OPSIZE];	// Line 1
char rd2[OPSIZE], rn2[OPSIZE], src2[OPSIZE];	// Line 2
char rd3[OPSIZE], rn3[OPSIZE], src3[OPSIZE];	// Line 3
char rd4[OPSIZE], rn4[OPSIZE], src4[OPSIZE];	// Line 4
char rd5[OPSIZE], rn5[OPSIZE], src5[OPSIZE];	// Line 5

int line = 1;
int ind = 0;

int nops[NOPS];

int detect_risk()
{
	int n = 0;
	if (strcmp(rd1, rn2) == 0 || strcmp(rd1, src2) == 0)
	{
		n += 2;
	}
	if (strcmp(rd1, rn3) == 0 || strcmp(rd1, src3) == 0)
	{
		if (n != 2) n++;
	}
	nops[ind] = n;
	ind++;
}

void pipeline()
{
	strcpy(rd1, rd2);
	strcpy(rn1, rn2);
	strcpy(src1, src2);

	strcpy(rd2, rd3);
	strcpy(rn2, rn3);
	strcpy(src2, src3);

	strcpy(rd3, rd4);
	strcpy(rn3, rn4);
	strcpy(src3, src4);

	strcpy(rd4, rd5);
	strcpy(rn4, rn5);
	strcpy(src4, src5);
}

void clean(char *buffer, char *dst)
{
	int j = 0;
	for (int i = 0; i < strlen(buffer); i++)
	{
		if (buffer[i] != '[' && buffer[i] != ']' && buffer[i] != ',' && buffer[i] != '\n')
		{
			dst[j] = buffer[i];
			j++;
		}
	}
	dst[j] = '\0';
}

void tokenize_line(char *line, int stage)
{
	char *buffer;
	char *inst = strtok(line, " ");
	if (stage == 1)
	{
		buffer = strtok(NULL, " ");
		clean(buffer, rd1);
		buffer = strtok(NULL, " ");
		clean(buffer, rn1);
		buffer = strtok(NULL, " ");
		clean(buffer, src1);
	}
	else if (stage == 2)
	{
		buffer = strtok(NULL, " ");
		clean(buffer, rd2);
		buffer = strtok(NULL, " ");
		clean(buffer, rn2);
		buffer = strtok(NULL, " ");
		clean(buffer, src2);
	}
	else if (stage == 3)
	{
		buffer = strtok(NULL, " ");
		clean(buffer, rd3);
		buffer = strtok(NULL, " ");
		clean(buffer, rn3);
		buffer = strtok(NULL, " ");
		clean(buffer, src3);
	}
	else if (stage == 4)
	{
		buffer = strtok(NULL, " ");
		clean(buffer, rd4);
		buffer = strtok(NULL, " ");
		clean(buffer, rn4);
		buffer = strtok(NULL, " ");
		clean(buffer, src4);
	}
	else if (stage == 5)
	{
		buffer = strtok(NULL, " ");
		clean(buffer, rd5);
		buffer = strtok(NULL, " ");
		clean(buffer, rn5);
		buffer = strtok(NULL, " ");
		clean(buffer, src5);
	}
	else
	{
		detect_risk();
		pipeline();
		buffer = strtok(NULL, " ");
		clean(buffer, rd5);
		buffer = strtok(NULL, " ");
		clean(buffer, rn5);
		buffer = strtok(NULL, " ");
		clean(buffer, src5);
	}
}

int risk_detection(char *filename)
{
	FILE *f = fopen(filename, "r");
	if (f == NULL)
	{
		printf("Cannot open file %s\n", filename);
		return -1;
	}
	
	char line[SIZE];

	int control = 1;
	while (fgets(line, SIZE, f) != NULL)
	{
		tokenize_line(line, control);
		control++;
	}

	fclose(f);

	f = fopen(filename, "r");
	FILE *out = fopen("out.asm", "w+");

	int i = 0;
	while (fgets(line, SIZE, f) != NULL)
	{
		fprintf(out, "%s", line);
		for (int j = 0; j < nops[i]; j++)
		{
			fprintf(out, "NOP\n");
		}
		i++;
	}

	fclose(f);
	fclose(out);
	
	return 0;
}

int main(int argc, char* argv[])
{
	if (argc != 2)
	{
		printf("Usage: %s <filename>\n", argv[0]);
		return -1;
	}
	
	risk_detection(argv[1]);

	return 0;
}
