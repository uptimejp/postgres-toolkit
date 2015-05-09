/*
 * verifychecksum.c
 *
 * Copyright(c) 2015 Uptime Technologies, LLC.
 */
#include <stdio.h>
#include <unistd.h>

#include "c.h"
#include "pg_config.h"
#include "storage/checksum_impl.h"

int verbose = 0;

int
verify_page(const char *page, BlockNumber blkno, const char *filepath)
{
  PageHeader	phdr = (PageHeader) page;
  uint16 checksum;

  checksum = pg_checksum_page((char *)page, blkno);

  if (phdr->pd_checksum != checksum)
    {
      printf("%s: blkno %d, expected %x, found %x\n",
	     filepath, blkno, checksum, phdr->pd_checksum);
      return FALSE;
    }

  return TRUE;
}

int
verify_segmentfile(const char *filepath)
{
  int fd;
  char page[BLCKSZ];
  BlockNumber blkno = 0;
  BlockNumber corrupted = 0;

  fd = open(filepath, O_RDONLY);
  if (fd <= 0)
    {
      fprintf(stderr, "%s: %s\n", strerror(errno), filepath);
      exit(2);
    }

  while (read(fd, page, BLCKSZ) == BLCKSZ)
    {
      if (!verify_page(page, blkno, filepath))
	{
	  corrupted++;
	}
      blkno++;
    }

  close(fd);

  if (corrupted > 0)
    {
      printf("%d blocks corrupted in %s.\n", corrupted, filepath);
      return FALSE;
    }

  if (verbose)
    printf("Verified %d blocks in %s.\n", blkno, filepath);

  return TRUE;
}

int
main(int argc, char *argv[])
{
  //  printf("BLCKSZ: %d\n", BLCKSZ);
  char *file = NULL;
  int i;

  for (i=1 ; i<argc ; i++)
    {
      if (strcmp(argv[i], "-v") == 0)
	{
	  verbose = 1;
	  continue;
	}

      if (argv[i] != NULL)
	{
	  file = argv[i];
	  continue;
	}
    }

  if (file == NULL)
    {
      printf("Usage: verifychecksum [-v] [segment file]\n");
      return 0;
    }

  if (!verify_segmentfile(file))
    {
      /* corrupted blocks found. */
      return 1;
    }

  return 0;
}
