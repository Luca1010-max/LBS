#include <stdio.h>
#include <string.h>

int timing_check_secret(const char *guess);

int
main(int argc, char **argv)
{
	char buf[128];
	size_t n;

	if (argc == 2)
		return timing_check_secret(argv[1]) ? 0 : 1;
	for (;;) {
		if (!fgets(buf, sizeof buf, stdin))
			return 0;
		n = strcspn(buf, "\n");
		buf[n] = 0;
		printf("%d\n", timing_check_secret(buf));
		fflush(stdout);
	}
}
