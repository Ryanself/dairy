#include <stdio.h>
/**
 * there is a file
 * a b c d
 * e f g h
 * i j k l
 *
 * i want to get 
 * a
 * b
 * c
 * d
 * e 
 * ... 
 * so that i can copy it to excel to create a table.
 *                  
 *write this .c
 */
int main()
{
		FILE *fp, *fp2 = NULL;

		fp = fopen("./tem.txt", "r+");
		fp2 = fopen("./temh.txt", "w");
		int a, i;
		char buff[6] = {0};
		// EOF end of file.
		while (EOF != a) {
			i = 0;
			a = fgetc(fp);
			// the file content is a float type number. use ascill code to spilt space.
			while (a >= 48 || a == '.') {
					if (a >= '0' || a == '.')
							buff[i] = a;
					a = fgetc(fp);
					i ++;
			}
			// printf for test.
			// printf("%s\n", buff);
			fprintf(fp2, "%s\n", buff);
			// if we do not clean buff here, cause error output.
			buff[5] = buff[4] = buff[3] = buff[2] = buff[1] = buff[0] = 0;
	}
		return 0;
}

