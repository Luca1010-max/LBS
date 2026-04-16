#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

static void
usage(FILE *out)
{
	fprintf(out,
	    "usage: genasm [-q qbe-path] [-t target] input.ssa output.s\n");
}

static int
redirect_fd(int oldfd, int newfd)
{
	if (oldfd == newfd)
		return 0;
	if (dup2(oldfd, newfd) < 0)
		return -1;
	return close(oldfd);
}

int
main(int argc, char **argv)
{
	char *qbe;
	char *target;
	char *input;
	char *output;
	int infd, outfd, status, opt;
	pid_t pid;

	qbe = "./qbe";
	target = NULL;

	while ((opt = getopt(argc, argv, "q:t:h")) != -1) {
		switch (opt) {
		case 'q':
			qbe = optarg;
			break;
		case 't':
			target = optarg;
			break;
		case 'h':
			usage(stdout);
			return 0;
		default:
			usage(stderr);
			return 1;
		}
	}

	if (argc - optind != 2) {
		usage(stderr);
		return 1;
	}

	input = argv[optind];
	output = argv[optind + 1];

	infd = open(input, O_RDONLY);
	if (infd < 0) {
		fprintf(stderr, "genasm: cannot open input '%s': %s\n",
		    input, strerror(errno));
		return 1;
	}

	outfd = open(output, O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (outfd < 0) {
		fprintf(stderr, "genasm: cannot open output '%s': %s\n",
		    output, strerror(errno));
		close(infd);
		return 1;
	}

	pid = fork();
	if (pid < 0) {
		fprintf(stderr, "genasm: fork failed: %s\n", strerror(errno));
		close(infd);
		close(outfd);
		return 1;
	}

	if (pid == 0) {
		if (redirect_fd(infd, STDIN_FILENO) < 0 ||
		    redirect_fd(outfd, STDOUT_FILENO) < 0) {
			fprintf(stderr, "genasm: redirection failed: %s\n",
			    strerror(errno));
			_exit(1);
		}

		if (target != NULL)
			execl(qbe, qbe, "-t", target, (char *)NULL);
		else
			execl(qbe, qbe, (char *)NULL);

		fprintf(stderr, "genasm: cannot execute '%s': %s\n",
		    qbe, strerror(errno));
		_exit(127);
	}

	close(infd);
	close(outfd);

	if (waitpid(pid, &status, 0) < 0) {
		fprintf(stderr, "genasm: waitpid failed: %s\n", strerror(errno));
		return 1;
	}

	if (WIFEXITED(status))
		return WEXITSTATUS(status);

	if (WIFSIGNALED(status)) {
		fprintf(stderr, "genasm: qbe terminated by signal %d\n",
		    WTERMSIG(status));
		return 1;
	}

	fprintf(stderr, "genasm: qbe ended unexpectedly\n");
	return 1;
}
