#include <stdio.h>
#include <string.h>

int	main()
{
	char const key[] = "__stack_check";
	printf("Please enter key: ");
	char input[108];
	scanf("%s", input);
	if (strcmp(input, key))
		printf("Nope.\n");
	else
		printf("Good job.\n");
	return 0;
}
