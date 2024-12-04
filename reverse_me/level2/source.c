#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void no(void)
{
	printf("Nope.\n");
	exit(0);
}

void ok(void)
{
	printf("Good job.\n");
	exit(0);
}

int	main()
{
	char const key[] = "delabere";
	printf("Please enter key: ");
	char input[24];
	if (scanf("%23s", input) != 1)
		no();
	if (input[0] != '0')
		no();
	if (input[1] != '0')
		no();

	fflush(stdout);
	char output[9];
	memset(output, 0, 9);
	output[0] = 'd';

	int	out_pos = 1;
	int	in_pos = 2;
	while (1)
	{
		char tmp = 0;
		if (strlen(output) < 8)
			tmp = in_pos < strlen(input);
		if (!tmp)
			break;

		char str[4];
		str[0] = input[in_pos++];
		str[1] = input[in_pos++];
		str[2] = input[in_pos++];
		str[3] = 0;
		output[out_pos++] = atoi(str);
	}

	if (strcmp(output, key))
		printf("Nope.\n");
	else
		printf("Good job.\n");
	return (0);
}
