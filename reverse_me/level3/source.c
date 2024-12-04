#include <stdlib.h>
#include <stdio.h>
#include <string.h>

void no()
{
	puts("Nope.");
	exit(1);
}

void ok()
{
	puts("Good job.");
	exit(0);
}

int main(void)
{
	const char	key[] = "********";
	char		input [31];
	char		output [9];
	char		temp_chars[4];
	char		check_end;
	int			diff;
	int			output_pos;
	size_t		input_pos;

	printf("Please enter key: ");
	if (scanf("%23s", input) != 1)
		no();
	if (input[0] != '4' || input[1] != '2')
		no();

	fflush(stdin);
	memset(output,0,9);
	output[0] = '*';
	input_pos = 2;
	output_pos = 1;
	while(1)
	{
		check_end = 0;
		if (strlen(output) < 8)
			check_end = input_pos < strlen(input);
		if (!check_end)
			break;
		temp_chars[0] = input[input_pos++];
		temp_chars[1] = input[input_pos++];
		temp_chars[2] = input[input_pos++];
		temp_chars[3] = 0;
		output[output_pos++] = atoi(temp_chars);
	}
	output[output_pos] = '\0';
	diff = strcmp(output, key);
	if (diff == -2)
		no();
	else if (diff == -1)
		no();
	else if (diff == 0)
		ok();
	else if (diff == 1)
		no();
	else if (diff == 2)
		no();
	else if (diff == 3)
		no();
	else if (diff == 4)
		no();
	else if (diff == 5)
		no();
	else if (diff == 0x73)
		no();
	else
		no();
	return (0);
}
