#include "all.h"
#include "config.h"
#include <ctype.h>
#include <getopt.h>

Target T;

char debug['Z'+1] = {
	['P'] = 0, /* parsing */
	['M'] = 0, /* memory optimization */
	['N'] = 0, /* ssa construction */
	['C'] = 0, /* copy elimination */
	['F'] = 0, /* constant folding */
	['A'] = 0, /* abi lowering */
	['I'] = 0, /* instruction selection */
	['L'] = 0, /* liveness */
	['S'] = 0, /* spilling */
	['R'] = 0, /* reg. allocation */
};

extern Target T_amd64_sysv;
extern Target T_amd64_apple;
extern Target T_arm64;
extern Target T_arm64_apple;
extern Target T_rv64;

static Target *tlist[] = {
	&T_amd64_sysv,
	&T_amd64_apple,
	&T_arm64,
	&T_arm64_apple,
	&T_rv64,
	0
};
static FILE *outf;
static int dbg;

typedef struct RawOut RawOut;
typedef struct FunOut FunOut;

struct RawOut {
	FILE *f;
};

struct FunOut {
	FILE *f;
};

static RawOut *rawout;
static FunOut *funout;
static uint nrawout;
static uint nfunout;
static FILE *curoutf;

static FILE *
newtmpf(void)
{
	FILE *f;

	f = tmpfile();
	if (!f) {
		fprintf(stderr, "cannot create temporary file\n");
		exit(1);
	}
	return f;
}

static void
startrawout(void)
{
	vgrow(&rawout, nrawout + 1);
	curoutf = newtmpf();
	rawout[nrawout++].f = curoutf;
}

static void
initfuncperm(void)
{
	rawout = vnew(1, sizeof rawout[0], PHeap);
	funout = vnew(1, sizeof funout[0], PHeap);
	nrawout = 0;
	nfunout = 0;
	curoutf = 0;
	startrawout();
}

static FILE *
txtout(void)
{
	if (!dbg && divstate.enabled && divstate.funcperm)
		return curoutf;
	return outf;
}

static void
copyout(FILE *src, FILE *dst)
{
	char buf[4096];
	size_t n;

	fflush(src);
	rewind(src);
	while ((n = fread(buf, 1, sizeof buf, src)) != 0)
		if (fwrite(buf, 1, n, dst) != n) {
			fprintf(stderr, "write error\n");
			exit(1);
		}
	if (ferror(src)) {
		fprintf(stderr, "read error\n");
		exit(1);
	}
}

static void
flushfuncperm(void)
{
	uint i, j, t;
	uint *ord;

	if (!rawout)
		return;
	ord = vnew(nfunout ? nfunout : 1, sizeof ord[0], PHeap);
	for (i = 0; i < nfunout; i++)
		ord[i] = i;
	for (i = nfunout; i > 1; i--) {
		j = divpickfun(i);
		t = ord[i-1];
		ord[i-1] = ord[j];
		ord[j] = t;
	}
	for (i = 0; i < nfunout; i++) {
		copyout(rawout[i].f, outf);
		copyout(funout[ord[i]].f, outf);
	}
	copyout(rawout[nfunout].f, outf);
	for (i = 0; i < nrawout; i++)
		fclose(rawout[i].f);
	for (i = 0; i < nfunout; i++)
		fclose(funout[i].f);
	vfree(rawout);
	vfree(funout);
	vfree(ord);
	rawout = 0;
	funout = 0;
	nrawout = 0;
	nfunout = 0;
	curoutf = 0;
}

static void
data(Dat *d)
{
	if (dbg)
		return;
	emitdat(d, txtout());
	if (d->type == DEnd) {
		fputs("/* end data */\n\n", txtout());
		freeall();
	}
}

static void
func(Fn *fn)
{
	uint n;

	if (dbg)
		fprintf(stderr, "**** Function %s ****", fn->name);
	if (debug['P']) {
		fprintf(stderr, "\n> After parsing:\n");
		printfn(fn, stderr);
	}
	T.abi0(fn);
	fillrpo(fn);
	fillpreds(fn);
	filluse(fn);
	promote(fn);
	filluse(fn);
	ssa(fn);
	filluse(fn);
	ssacheck(fn);
	fillalias(fn);
	loadopt(fn);
	filluse(fn);
	fillalias(fn);
	coalesce(fn);
	filluse(fn);
	ssacheck(fn);
	copy(fn);
	filluse(fn);
	fold(fn);
	T.abi1(fn);
	simpl(fn);
	fillpreds(fn);
	filluse(fn);
	T.isel(fn);
	fillrpo(fn);
	filllive(fn);
	fillloop(fn);
	fillcost(fn);
	spill(fn);
	rega(fn);
	fillrpo(fn);
	simpljmp(fn);
	fillpreds(fn);
	fillrpo(fn);
	assert(fn->rpo[0] == fn->start);
	for (n=0;; n++)
		if (n == fn->nblk-1) {
			fn->rpo[n]->link = 0;
			break;
		} else
			fn->rpo[n]->link = fn->rpo[n+1];
	if (!dbg) {
		if (divstate.enabled && divstate.funcperm) {
			vgrow(&funout, nfunout + 1);
			funout[nfunout].f = newtmpf();
			T.emitfn(fn, funout[nfunout].f);
			fprintf(funout[nfunout].f, "/* end function %s */\n\n", fn->name);
			nfunout++;
			startrawout();
		} else {
			T.emitfn(fn, outf);
			fprintf(outf, "/* end function %s */\n\n", fn->name);
		}
	} else
		fprintf(stderr, "\n");
	freeall();
}

static void
dbgfile(char *fn)
{
	emitdbgfile(fn, txtout());
}

int
main(int ac, char *av[])
{
	Target **t;
	static struct option lopt[] = {
		{ "diversify", no_argument, 0, 1000 },
		{ "no-diversify", no_argument, 0, 1001 },
		{ "div-seed", required_argument, 0, 1002 },
		{ "div-nop", required_argument, 0, 1003 },
		{ "div-regrand", no_argument, 0, 1004 },
		{ "div-funcperm", no_argument, 0, 1005 },
		{ "no-div-nop", no_argument, 0, 1006 },
		{ "no-div-regrand", no_argument, 0, 1007 },
		{ "no-div-funcperm", no_argument, 0, 1008 },
		{ "sc-ctstrcmp", no_argument, 0, 1009 },
		{ "no-sc-ctstrcmp", no_argument, 0, 1010 },
		{ 0, 0, 0, 0 },
	};
	FILE *inf, *hf;
	char *f, *sep;
	int c;
	char *end;
	unsigned long long u;

	T = Deftgt;
	outf = stdout;
	while ((c = getopt_long(ac, av, "hd:o:t:", lopt, 0)) != -1)
		switch (c) {
		case 1000:
			divstate.enabled = 1;
			break;
		case 1001:
			divstate.enabled = 0;
			break;
		case 1002:
			u = strtoull(optarg, &end, 0);
			if (*end != 0) {
				fprintf(stderr, "invalid diversity seed '%s'\n", optarg);
				exit(1);
			}
			divstate.seed = u;
			divstate.enabled = 1;
			break;
		case 1003:
			u = strtoull(optarg, &end, 0);
			if (*end != 0 || u > 100) {
				fprintf(stderr, "invalid nop probability '%s'\n", optarg);
				exit(1);
			}
			divstate.nop_pct = u;
			divstate.nop = 1;
			divstate.enabled = 1;
			break;
		case 1004:
			divstate.regrand = 1;
			divstate.enabled = 1;
			break;
		case 1005:
			divstate.funcperm = 1;
			divstate.enabled = 1;
			break;
		case 1006:
			divstate.nop = 0;
			divstate.nop_pct = 0;
			break;
		case 1007:
			divstate.regrand = 0;
			break;
		case 1008:
			divstate.funcperm = 0;
			break;
		case 1009:
			divstate.ctstrcmp = 1;
			break;
		case 1010:
			divstate.ctstrcmp = 0;
			break;
		case 'd':
			for (; *optarg; optarg++)
				if (isalpha(*optarg)) {
					debug[toupper(*optarg)] = 1;
					dbg = 1;
				}
			break;
		case 'o':
			if (strcmp(optarg, "-") != 0) {
				outf = fopen(optarg, "w");
				if (!outf) {
					fprintf(stderr, "cannot open '%s'\n", optarg);
					exit(1);
				}
			}
			break;
		case 't':
			if (strcmp(optarg, "?") == 0) {
				puts(T.name);
				exit(0);
			}
			for (t=tlist;; t++) {
				if (!*t) {
					fprintf(stderr, "unknown target '%s'\n", optarg);
					exit(1);
				}
				if (strcmp(optarg, (*t)->name) == 0) {
					T = **t;
					break;
				}
			}
			break;
		case 'h':
		default:
			hf = c != 'h' ? stderr : stdout;
			fprintf(hf, "%s [OPTIONS] {file.ssa, -}\n", av[0]);
			fprintf(hf, "\t%-11s prints this help\n", "-h");
			fprintf(hf, "\t%-11s output to file\n", "-o file");
			fprintf(hf, "\t%-11s generate for a target among:\n", "-t <target>");
			fprintf(hf, "\t%-11s ", "");
			for (t=tlist, sep=""; *t; t++, sep=", ") {
				fprintf(hf, "%s%s", sep, (*t)->name);
				if (*t == &Deftgt)
					fputs(" (default)", hf);
			}
			fprintf(hf, "\n");
			fprintf(hf, "\t%-11s dump debug information\n", "-d <flags>");
			fprintf(hf, "\t%-11s enable diversification\n", "--diversify");
			fprintf(hf, "\t%-11s disable diversification\n", "--no-diversify");
			fprintf(hf, "\t%-11s set deterministic seed\n", "--div-seed=N");
			fprintf(hf, "\t%-11s enable nop insertion with N percent probability\n", "--div-nop=N");
			fprintf(hf, "\t%-11s disable nop insertion\n", "--no-div-nop");
			fprintf(hf, "\t%-11s enable randomized register tie-breaks\n", "--div-regrand");
			fprintf(hf, "\t%-11s disable randomized register tie-breaks\n", "--no-div-regrand");
			fprintf(hf, "\t%-11s enable function permutation\n", "--div-funcperm");
			fprintf(hf, "\t%-11s disable function permutation\n", "--no-div-funcperm");
			fprintf(hf, "\t%-11s replace direct strcmp calls with a constant-time helper when supported\n", "--sc-ctstrcmp");
			fprintf(hf, "\t%-11s disable the constant-time strcmp mitigation\n", "--no-sc-ctstrcmp");
			exit(c != 'h');
		}

	divseed(divstate.seed);
	if (!dbg && divstate.enabled && divstate.funcperm)
		initfuncperm();

	do {
		f = av[optind];
		if (!f || strcmp(f, "-") == 0) {
			inf = stdin;
			f = "-";
		} else {
			inf = fopen(f, "r");
			if (!inf) {
				fprintf(stderr, "cannot open '%s'\n", f);
				exit(1);
			}
		}
		parse(inf, f, dbgfile, data, func);
		fclose(inf);
	} while (++optind < ac);

	if (!dbg && divstate.enabled && divstate.funcperm)
		flushfuncperm();
	if (!dbg)
		T.emitfin(outf);

	exit(0);
}
