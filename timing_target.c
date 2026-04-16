#include <stdio.h>
#include <string.h>

enum {
	Repeat = 200000,
};

static const char secret[] = "SECRETSX";

int
timing_check_secret(const char *guess)
{
	int i;
	int diff;

	diff = 0;
	for (i = 0; i < Repeat; i++)
		diff |= strcmp(guess, secret);
	return diff == 0;
}

int
main(int argc, char **argv)
{
	char buf[128];
	size_t n;

	if (argc != 2)
		for (;;) {
			if (!fgets(buf, sizeof buf, stdin))
				return 0;
			n = strcspn(buf, "\n");
			buf[n] = 0;
			printf("%d\n", timing_check_secret(buf));
			fflush(stdout);
		}
	return timing_check_secret(argv[1]) ? 0 : 1;
}
