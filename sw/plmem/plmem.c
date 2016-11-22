#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <errno.h>
#include <argp.h>
#include <limits.h>

#define soc_cv_av 1

#include "hwlib.h"
#include "soc_cv_av/socal/socal.h"
#include "soc_cv_av/socal/hps.h"

#include "hps_0.h"

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

const char *argp_program_version =
  "plmem 1.0";
const char *argp_program_bug_address =
  "<mas9439@rit.edu>";

/* Program documentation. */
static char doc[] =
  "plmem -- a program for peeking and poking FPGA memory on the Cyclone V";

/* A description of the arguments we accept. */
static char args_doc[] = "";

/* The options we understand. */
static struct argp_option options[] = {
  {"verbose",  'v', 0,      0,  "Produce verbose output" },
  {"addr",     'a', "ADDR", 0,  "PL address" },
  {"data",     'd', "DATA", 0,  "Data value to write" },
  { 0 }
};

/* Used by main to communicate with parse_opt. */
struct arguments
{
  int verbose;
  uint32_t addr;
  uint32_t data;
};

/* Parse a single option. */
static error_t
parse_opt (int key, char *arg, struct argp_state *state)
{
  /* Get the input argument from argp_parse, which we
     know is a pointer to our arguments structure. */
  struct arguments *arguments = state->input;

  char *endptr;
  long val;

  switch (key)
    {
    case 'v':
		arguments->verbose = 1;
		break;
    case 'a': case 'd':
		errno = 0;    /* To distinguish success/failure after call */
        val = strtoul(arg, &endptr, 0);

		if ((errno == ERANGE && (val == LONG_MAX || val == LONG_MIN))
				|| (errno != 0 && val == 0)) {
			perror("strtoul");
			argp_usage (state);
		}

		if (endptr == arg) {
			argp_usage (state);
		}

		if (key == 'a') {
			arguments->addr = val;
		} else {
			arguments->data = val;
		}
    case ARGP_KEY_END:
		//if (arguments->addr_str == -1 || arguments->data_str == NULL)
			/* Not enough arguments. */
		//	argp_usage (state);
		break;
    default:
      return ARGP_ERR_UNKNOWN;
    }
  return 0;
}

int write_to_fpga(uint32_t addr, uint32_t data, int verbose)
{
	void *virtual_base;
	int fd;
	void *full_addr;



	// map the address space for the LED registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span

	if (verbose)
	{
		printf("Attempting to write 0x%x to address 0x%x", data, addr);
		printf("Opening /dev/mem...\r\n");
	}

	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) {
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( -1 );
	}

	if (verbose)
	{
		printf("Mapping /dev/mem...\r\n");
	}

	virtual_base = mmap( NULL, HW_REGS_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, HW_REGS_BASE );

	if( virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap() failed...\n" );
		close( fd );
		return( -1 );
	}
	
	full_addr = virtual_base + 
		( ( unsigned long  )( ALT_LWFPGASLVS_OFST + addr ) 
		& ( unsigned long)( HW_REGS_MASK ) );
	
	*(uint32_t *)full_addr = data;	

	// clean up our memory mapping and exit
	
	if( munmap( virtual_base, HW_REGS_SPAN ) != 0 ) {
		printf( "ERROR: munmap() failed...\n" );
		close( fd );
		return( 1 );
	}

	close( fd );

	return 0;
}

/* Our argp parser. */
static struct argp argp = { options, parse_opt, args_doc, doc };

int main(int argc, char **argv) 
{
	struct arguments arguments;

	/* Default values. */
	arguments.verbose = 0;
	arguments.addr = 0;
	arguments.data = 0;

	/* Parse our arguments; every option seen by parse_opt will
		be reflected in arguments. */
	argp_parse (&argp, argc, argv, 0, 0, &arguments);

	write_to_fpga(arguments.addr, arguments.data, arguments.verbose);

	return( 0 );
}
